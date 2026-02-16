# ifx max token size on large array constructor

`ifx` rejects bracket `[]` array constructors that exceed its internal
token limit of ~41,000 tokens. A 1.56M-element `real(dp)` array hits
this limit immediately.

This is a flat 1D array with no `reshape` — the simplest possible case.

## Reproduce

```bash
ifx -c big_array.F90        # error: maximum token size exceeded
```

## Results

| Compiler | Result |
|---|---|
| ifx | Max token size exceeded |
| nvfortran 26.1 | Compiles (very slowly) |
| flang 21.1.3 | Compiles and runs correctly |
| gfortran | Compiles with `-fmax-array-constructor=1600000` |
