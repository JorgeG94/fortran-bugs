!> OpenMP target version of the MRE.
!! Same trigger pattern as the OpenACC version (mre_final.F90).
!! Tests whether the bug is OpenACC-specific or also affects OpenMP target offload.
module mre_omp_types
    use iso_fortran_env, only: dp => real64
    implicit none
    type :: grid_type
        integer :: isd, ied, jsd, jed, isc, iec, jsc, jec
        real(dp), allocatable :: scale(:,:)
    end type grid_type
end module mre_omp_types

program mre_openmp
    use iso_fortran_env, only: dp => real64
    use mre_omp_types
    implicit none
    integer, parameter :: ni = 32, nj = 32, nhalo = 2
    integer :: isd, ied, jsd, jed, isc, iec, jsc, jec, i, j
    type(grid_type) :: G
    real(dp), allocatable :: out(:,:)

    isd=1; ied=ni+2*nhalo; jsd=1; jed=nj+2*nhalo
    isc=nhalo+1; iec=nhalo+ni; jsc=nhalo+1; jec=nhalo+nj
    G%isd=isd; G%ied=ied; G%jsd=jsd; G%jed=jed
    G%isc=isc; G%iec=iec; G%jsc=jsc; G%jec=jec
    allocate(G%scale(isd:ied,jsd:jed)); G%scale = 1.0e4_dp
    allocate(out(isd:ied,jsd:jed)); out = 0.0_dp

    !$omp target enter data map(to: out, G, G%scale)
    call the_kernel(out, G)
    !$omp target exit data map(from: out)
    !$omp target exit data map(delete: G%scale, G)

    i=(isc+iec)/2; j=(jsc+jec)/2
    write(*,'(A,ES12.4)') 'result = ', out(i,j)
    write(*,'(A)') 'PASS'

contains

    subroutine the_kernel(out, G)
        type(grid_type), intent(in) :: G
        real(dp), dimension(G%isd:G%ied,G%jsd:G%jed), intent(inout) :: out
        real(dp) :: du, ddu, err, deriv, uadj, f, df, live
        integer :: k, itt, i, j
        integer, parameter :: max_itt = 2, nk = 1

        !$omp target teams loop collapse(2) &
        !$omp   private(du, ddu, err, deriv, uadj, f, df, live, k, itt)
        do j = G%jsc, G%jec
            do i = G%isc-1, G%iec
                du = 0.0_dp; err = 1.0_dp; deriv = 1.0e6_dp
                do itt = 1, max_itt
                    ddu = -err / deriv
                    du = du + ddu
                    if (abs(ddu) < 1.0e-15_dp * abs(du)) exit
                    err = 0.0_dp; deriv = 0.0_dp
                    do k = 1, nk
                        uadj = 0.01_dp + du
                        if (uadj > 0.0_dp) then
                            f    = G%scale(i,j) * uadj * 10.0_dp
                            live = 10.0_dp
                        else
                            f    = -G%scale(i,j) * uadj * 10.0_dp
                            live = -10.0_dp
                        end if
                        df    = G%scale(i,j) * live
                        err   = err + f
                        deriv = deriv + df
                    end do
                end do
                out(i,j) = du
            end do
        end do
    end subroutine the_kernel

end program mre_openmp
