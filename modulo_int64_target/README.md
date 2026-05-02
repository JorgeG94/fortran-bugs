# `modulo(int64)` not supported inside target regions (nvfortran)

`modulo()` applied to `integer(int64)` operands fails to compile when used
inside an OpenMP `target` or OpenACC compute region.

## Error

```
NVFORTRAN-S-1058-Call to Compiler runtime function not supported - pgf90_i8modulov_i8
```

## Reproduce

```bash
module load nvhpc
make test
```

Both compilations fail with the same `pgf90_i8modulov_i8` error.

## Trigger

Confirmed minimal trigger:

| Case | Result |
|---|---|
| `modulo(int64, int64)` on the host | OK |
| `modulo(int32, int32)` inside target | OK |
| `mod(int64, int64)` inside target | OK |
| `modulo(int64, int64)` inside target | **fails** |

The failure is specific to the combination of:
1. The `modulo` intrinsic (not `mod`)
2. `integer(int64)` operands
3. Inside an OpenMP `target` or OpenACC compute region

## Workarounds

- Use `mod()` if truncated-toward-zero semantics are acceptable.
- Cast operands to `integer(int32)` if the values fit.
- Implement `modulo` by hand: `r = a - b * floor(real(a,dp)/real(b,dp))`,
  or `r = mod(a,b); if (r /= 0 .and. (r<0 .neqv. b<0)) r = r + b`.

## Environment

- nvfortran 26.3-0 (nvhpc/26.3)
