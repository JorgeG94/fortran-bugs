program test_flat
  use big_array_mod
  implicit none

  integer :: nerr
  real(dp) :: expected

  nerr = 0

  print '(a,i0)', "Array size: ", size(data)
  if (size(data) /= N) then
    print *, "FAIL: wrong size"
    nerr = nerr + 1
  else
    print *, "PASS: size"
  end if

  ! data(1) should be 0.0
  if (data(1) /= 0.0_dp) then
    print '(a,es22.15)', "FAIL: data(1) = ", data(1)
    nerr = nerr + 1
  else
    print *, "PASS: data(1) /= 0"
  end if

  ! spot check data(1001) = 1000 * 1e-10
  expected = 1000.0_dp * 1.0e-10_dp
  if (abs(data(1001) - expected) > 1.0e-20_dp) then
    print '(a,es22.15,a,es22.15)', "FAIL: data(1001) = ", data(1001), &
      " expected ", expected
    nerr = nerr + 1
  else
    print *, "PASS: data(1001)"
  end if

  ! last element
  expected = real(N - 1, dp) * 1.0e-10_dp
  if (abs(data(N) - expected) > 1.0e-6_dp) then
    print '(a,es22.15,a,es22.15)', "FAIL: data(N) = ", data(N), &
      " expected ", expected
    nerr = nerr + 1
  else
    print *, "PASS: data(N)"
  end if

  if (nerr == 0) then
    print *, "All tests PASSED"
  else
    print '(a,i0,a)', " ", nerr, " test(s) FAILED"
    stop 1
  end if

end program test_flat
