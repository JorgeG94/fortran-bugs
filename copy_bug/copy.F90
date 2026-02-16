module testm

    implicit none
    ! derived type to demo problem with allocatable member
    type container_type
        double precision, allocatable :: a(:, :)
        integer :: data1
    end type container_type

contains

    subroutine init(c)
        type(container_type), intent(inout) :: c
        integer :: i, j

        allocate(c%a(10, 20), source = 0.d0)

        ! send derived type + allocated member
        !$omp target enter data map(to: c, c%a)

        ! update member int
        c%data1 = 1

        ! update c to get data1 onto GPU
#ifdef BORK
        !$omp target update to(c)
#elif NOBORK
        !$omp target update to(c%data1)
#endif

        do concurrent (j=1:20, i=1:10)
            c%a(i,j) = dble(i+j + c%data1)
        enddo

        ! copy data back for inspection
        !$omp target exit data map(from: c%a)

    end subroutine init


end module testm

program test

    use testm

    implicit none
    type(container_type) :: c
    double precision, parameter :: expected = 3400.000000000000
    double precision, parameter :: tolerance = 1.0d-8
    double precision :: sum_of_values
    call init(c)

    write(*, *) sum(c%a)

    sum_of_values = sum(c%a)

    if (abs((sum_of_values - expected)) > tolerance) then
      stop "Wrong, answer should be 3400!"
    else
      print *, "yay!"
    end if

end program
