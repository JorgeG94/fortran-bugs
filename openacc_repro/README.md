# nvfortran GPU Codegen Bug — Minimum Reproducer

## Bug

`CUDA_ERROR_ILLEGAL_ADDRESS` (error 700) in GPU kernels compiled with `nvfortran -O3`. Works correctly at `-O1`.

Affects:
- **OpenACC**: `!$acc parallel loop` (`-acc=gpu -gpu=mem:separate`)
- **OpenMP**: `!$omp target teams loop` (`-mp=gpu -gpu=mem:separate`)

Does **not** affect:
- **OpenMP**: `!$omp target teams distribute parallel do` — passes at all optimization levels

## Reproduce

```bash
make test
```

This builds and runs four binaries:

| Binary | Source | API | Flags | Expected |
|--------|--------|-----|-------|----------|
| `mre_O1` | `mre_final.F90` | OpenACC | `-O1 -acc=gpu` | PASS |
| `mre_O3` | `mre_final.F90` | OpenACC | `-O3 -acc=gpu` | CRASH |
| `mre_omp_O1` | `mre_openmp.F90` | OpenMP `target teams loop` | `-O1 -mp=gpu` | PASS |
| `mre_omp_O3` | `mre_openmp.F90` | OpenMP `target teams loop` | `-O3 -mp=gpu` | CRASH |

Note: changing `!$omp target teams loop` to `!$omp target teams distribute parallel do` makes the OpenMP version pass at `-O3`.

## Trigger Pattern

The crash requires all of the following inside a GPU parallel loop:

```fortran
!$acc parallel loop collapse(2) present(G, G%scale)  ! or !$omp target teams loop
do j = ...
  do i = ...
    do itt = 1, N       ! outer loop, 2+ iterations
      do k = 1, K       ! inner loop (even K=1 crashes)
        if (cond) then
          f    = G%scale(i,j) * val    ! (1) derived-type member in if-branch
          live = const_A               ! (3) scalar set in if-branch
        else
          f    = -G%scale(i,j) * val   ! (2) derived-type member in else-branch
          live = const_B               !     scalar set in else-branch
        end if
        df = G%scale(i,j) * live       ! (4) derived-type member * cross-branch scalar
      end do
    end do
  end do
end do
```

### Required ingredients

1. **Derived type with allocatable member** accessed via `present(G, G%scale)` — plain arrays do not crash
2. **`G%scale(i,j)` accessed inside both branches** of the `if/else`
3. **A scalar set in both branches** of the `if/else` (cross-branch live variable)
4. **`G%scale(i,j)` used again after the `if/else`** multiplied by that live variable
5. **An outer `do` loop** (minimum 2 iterations) — manually unrolled or single-pass does not crash
6. **An inner `do k` loop** (even `nk=1` is sufficient)

### Not required

- Multiple derived types or array members — one 2D allocatable suffices
- Large grid — 32x32 with `nk=1` crashes
- `collapse(2)` — `collapse(1)` also crashes
- Any complex convergence logic or additional computation phases

## Workarounds

1. Compile at `-O1`
2. Duplicate `df = G%scale(i,j) * live` inside each branch so the scalar is never live across the `if/else` boundary
3. Use `!$omp target teams distribute parallel do` instead of `!$acc parallel loop` or `!$omp target teams loop`

## Environment

- NVHPC (nvfortran)
- Tested on NVIDIA V100 GPUs
