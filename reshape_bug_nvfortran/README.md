# nvfortran fort1 crash on reshape with large array constructor

`nvfortran`'s `fort1` frontend crashes with signal 11 (SIGSEGV) when
compiling a module variable initialized with `reshape([ ... ], shape)`
where the array constructor has ~88,000+ elements.

The same data without `reshape` (flat 1D) compiles fine, so the bug is
specifically in `fort1`'s handling of `reshape` over large constructors.

The crash threshold (~21,800 rows of 4) is non-deterministic: some sizes
crash, some don't, suggesting a memory corruption bug in the frontend.

## Reproduce

```bash
nvfortran -c big_array.F90       # fort1 TERMINATED by signal 11
```

FC=nvfortran make

## Results

| Compiler | Result |
|---|---|
| nvfortran 26.1 | `fort1 TERMINATED by signal 11` |
| flang 21.1.3 | Compiles and runs correctly |
| gfortran | Compiles with `-fmax-array-constructor=100000` |
