program test_reshape
  use big_array_mod
  implicit none

  integer :: nerr
  real(dp) :: expected

  nerr = 0

  print '(a,i0,a,i0)', "Array shape: ", size(data, 1), " x ", size(data, 2)
  if (size(data, 1) /= NCOLS .or. size(data, 2) /= NROWS) then
    print *, "FAIL: shape mismatch"
    nerr = nerr + 1
  else
    print *, "PASS: shape"
  end if

  ! data(1,1) should be 0.0
  if (data(1, 1) /= 0.0_dp) then
    print '(a,es22.15)', "FAIL: data(1,1) = ", data(1, 1)
    nerr = nerr + 1
  else
    print *, "PASS: data(1,1) == 0"
  end if

  ! data(1,2) = element index 4 (column-major: 4*1+0) = 4e-10
  expected = 4.0_dp * 1.0e-10_dp
  if (abs(data(1, 2) - expected) > 1.0e-20_dp) then
    print '(a,es22.15,a,es22.15)', "FAIL: data(1,2) = ", data(1, 2), &
      " expected ", expected
    nerr = nerr + 1
  else
    print *, "PASS: data(1,2)"
  end if

  ! last element
  expected = real(NCOLS * NROWS - 1, dp) * 1.0e-10_dp
  if (abs(data(NCOLS, NROWS) - expected) > 1.0e-6_dp) then
    print '(a,es22.15,a,es22.15)', "FAIL: data(last) = ", data(NCOLS, NROWS), &
      " expected ", expected
    nerr = nerr + 1
  else
    print *, "PASS: data(last)"
  end if

  if (nerr == 0) then
    print *, "All tests PASSED"
  else
    print '(a,i0,a)', " ", nerr, " test(s) FAILED"
    stop 1
  end if

end program test_reshape
