!> FINAL MRE: Minimum reproducer for nvfortran -O3 -acc=gpu -gpu=mem:separate crash.
!!
!! BUG: CUDA_ERROR_ILLEGAL_ADDRESS in OpenACC parallel loop at -O3.
!!      Works at -O1.
!!
!! TRIGGER PATTERN:
!!   !$acc parallel loop ... present(G, G%dy_Cu)
!!   do j / do I (outer collapsed loop)
!!     do itt = 1, N  (Newton-like outer iteration)
!!       do k = 1, K  (inner loop)
!!         if (cond) then
!!           result1 = G%dy_Cu(I,j) * val
!!           live_var = val1          ! set inside if-branch
!!         else
!!           result1 = -G%dy_Cu(I,j) * val
!!           live_var = val2          ! set inside else-branch
!!         end if
!!         result2 = G%dy_Cu(I,j) * live_var  ! live_var consumed AFTER if/else
!!       end do
!!     end do
!!   end do
!!
!! Required ingredients:
!!   1. Derived type with allocatable member, accessed via present(G, G%member)
!!   2. G%member accessed INSIDE both branches of if/else
!!   3. A variable set in the if/else branches and consumed AFTER (cross-branch live var)
!!   4. G%member accessed again AFTER the if/else using that live var
!!   5. An outer do loop (Newton-like) that feeds results back; single-pass does NOT crash
!!   6. An inner k-loop (can be nk=1)
!!
!! Workaround: compute result2 INSIDE each branch (duplicate code), or compile at -O1.
module mre_final_types
    use iso_fortran_env, only: dp => real64
    implicit none
    type :: grid_type
        integer :: isd, ied, jsd, jed, isc, iec, jsc, jec
        real(dp), allocatable :: scale(:,:)   ! the single allocatable member
    end type grid_type
end module mre_final_types

program mre_final
    use iso_fortran_env, only: dp => real64
    use mre_final_types
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

    !$acc enter data copyin(out, G, G%scale)
    call the_kernel(out, G)
    !$acc exit data copyout(out)
    !$acc exit data delete(G%scale, G)

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

        !$acc parallel loop collapse(2) &
        !$acc   present(out, G, G%scale) &
        !$acc   private(du, ddu, err, deriv, uadj, f, df, live, k, itt, i, j)
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
                        ! PATTERN: live set in if/else, consumed after via G%scale
                        if (uadj > 0.0_dp) then
                            f    = G%scale(i,j) * uadj * 10.0_dp
                            live = 10.0_dp       ! set in if-branch
                        else
                            f    = -G%scale(i,j) * uadj * 10.0_dp
                            live = -10.0_dp      ! set in else-branch
                        end if
                        df    = G%scale(i,j) * live   ! live consumed after if/else
                        err   = err + f
                        deriv = deriv + df
                    end do
                end do
                out(i,j) = du
            end do
        end do
    end subroutine the_kernel

end program mre_final
