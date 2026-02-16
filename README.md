# Fortran compiler bugs with large array constructors

Minimal reproducers for compiler bugs with large `real(dp)` bracket `[]`
array constructors in module variable initializers.

## Bugs

| Directory | Compiler | Bug | MRE size |
|---|---|---|---|
| `reshape_bug_nvfortran/` | nvfortran 26.1 | `fort1 TERMINATED by signal 11` on `reshape()` | 88K elements (2.9 MB) |
| `token_bug_ifx/` | ifx | Max token size exceeded (41k limit) | 1.56M elements (51 MB) |

## Quick start

Each directory has its own `generate.py`, `Makefile`, `test.F90`, and `README.md`.

```bash
cd reshape_bug_nvfortran
python3 generate.py
FC=nvfortran make test    # crashes

cd ../token_bug_ifx
python3 generate.py
FC=ifx make test          # crashes
```

## Compilers that handle both cases

| Compiler | Notes |
|---|---|
| flang 21.1.3 | No issues |
| gfortran | Needs `-fmax-array-constructor=N` flag |
