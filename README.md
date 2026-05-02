# Fortran compiler bugs with large array constructors

Minimal reproducers for compiler bugs with large `real(dp)` bracket `[]`
array constructors in module variable initializers.

## Bugs

| Directory | Compiler | Bug | MRE size |
|---|---|---|---|
| `reshape_bug_nvfortran/` | nvfortran 26.1 | `fort1 TERMINATED by signal 11` on `reshape()` | 88K elements (2.9 MB) |
| `token_bug_ifx/` | ifx | Max token size exceeded (41k limit) | 1.56M elements (51 MB) |
| `modulo_int64_target/` | nvfortran 26.3 | `modulo(int64)` inside OpenMP/OpenACC target — `pgf90_i8modulov_i8 not supported` | tiny |

## Quick start

Each directory has its own `Makefile`, `test.F90`, and `README.md`.

```bash
cd reshape_bug_nvfortran
FC=nvfortran make test    # sefaults the compiler

cd ../token_bug_ifx
FC=ifx make test          # does not compile
```

## Compilers that handle both cases

| Compiler | Notes |
|---|---|
| flang 21.1.3 | No issues |
| gfortran | Needs `-fmax-array-constructor=N` flag |
