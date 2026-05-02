!> MRE: modulo() of integer(int64) inside an OpenACC compute region fails to
!! compile with nvfortran.
!!
!! Error:
!!   NVFORTRAN-S-1058-Call to Compiler runtime function not supported -
!!   pgf90_i8modulov_i8
!!
!! Boundaries (verified):
!!   - modulo(int64, int64) on the host: OK
!!   - modulo(int32, int32) inside acc serial: OK
!!   - mod(int64, int64)    inside acc serial: OK
!!   - modulo(int64, int64) inside acc serial: FAILS
program mre_acc_modulo_int64
    use iso_fortran_env, only: int64
    implicit none
    integer(int64) :: a, b, r
    a = 10_int64
    b = 3_int64
    r = 0_int64
    !$acc serial copy(r) copyin(a, b)
    r = modulo(a, b)
    !$acc end serial
    print *, 'r = ', r
end program mre_acc_modulo_int64
