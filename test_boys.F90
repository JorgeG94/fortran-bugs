program test_boys
  use liberi_boys_host_data
  implicit none

  integer :: m, g, nerr
  real(dp) :: val, expected, tol, T, a0, a1, a2, a3, u, u2, u3, Tgrid

  nerr = 0
  tol = 1.0e-6_dp

  ! --- Test 1: Array shape ---
  print *, "Test 1: Array shape"
  print *, "  chebyshev_coefs shape: ", shape(boys_chebyshev_coefs)
  print *, "  expected:              ", 4, BOYS_MAX_ORDER + 1, BOYS_N_GRID + 1
  if (size(boys_chebyshev_coefs, 1) /= 4 .or. &
      size(boys_chebyshev_coefs, 2) /= BOYS_MAX_ORDER + 1 .or. &
      size(boys_chebyshev_coefs, 3) /= BOYS_N_GRID + 1) then
    print *, "  FAIL: shape mismatch"
    nerr = nerr + 1
  else
    print *, "  PASS"
  end if

  ! --- Test 2: F_m(0) = 1/(2m+1) via Chebyshev at T=0 ---
  ! At T=0: grid_pos=0, u=0, val = a0 - a2  (Chebyshev T_1(0)=-1)
  print *, ""
  print *, "Test 2: F_m(0) = 1/(2m+1) via Chebyshev interpolation at T=0"
  do m = 0, BOYS_MAX_ORDER
    a0 = boys_chebyshev_coefs(1, m, 0)
    a2 = boys_chebyshev_coefs(3, m, 0)
    val = a0 - a2
    expected = 1.0_dp / real(2 * m + 1, dp)
    if (abs(val - expected) > tol) then
      print '(a,i2,a,es22.15,a,es22.15)', "  FAIL m=", m, &
        ": got ", val, " expected ", expected
      nerr = nerr + 1
    else
      print '(a,i2,a,es22.15,a,es22.15)', "  PASS m=", m, &
        ": got ", val, " expected ", expected
    end if
  end do

  ! --- Test 3: Full Chebyshev evaluation at T=1.5 ---
  ! F_0(1.5) = sqrt(pi)/(2*sqrt(1.5)) * erf(sqrt(1.5))
  ! Known: F_0(1.5) ~ 0.5268959...
  print *, ""
  print *, "Test 3: F_0(T=1.5) via full Chebyshev evaluation"
  T = 1.5_dp
  g = int(T * 1000.0_dp)  ! grid_pos = 1500
  a0 = boys_chebyshev_coefs(1, 0, g)
  a1 = boys_chebyshev_coefs(2, 0, g)
  a2 = boys_chebyshev_coefs(3, 0, g)
  a3 = boys_chebyshev_coefs(4, 0, g)
  Tgrid = real(g, dp) * 0.001_dp
  u = (T - Tgrid) * boys_inv_scal_fact(0)
  u2 = u * u
  u3 = u2 * u
  val = a0 + a1 * u + a2 * (2.0_dp * u2 - 1.0_dp) &
      + a3 * (4.0_dp * u3 - 3.0_dp * u)
  ! Reference: F_0(1.5) = sqrt(pi)/(2*sqrt(1.5)) * erf(sqrt(1.5))
  expected = 0.6633509458403348_dp
  print '(a,es22.15)', "  computed: ", val
  print '(a,es22.15)', "  expected: ", expected
  if (abs(val - expected) > 1.0e-10_dp) then
    print *, "  FAIL"
    nerr = nerr + 1
  else
    print *, "  PASS"
  end if

  ! --- Test 4: Spot-check last grid point is nonzero ---
  print *, ""
  print *, "Test 4: Last grid point (T=30) data is nonzero"
  val = boys_chebyshev_coefs(1, 0, BOYS_N_GRID)
  if (val == 0.0_dp) then
    print *, "  FAIL: a0 at last grid point is zero"
    nerr = nerr + 1
  else
    print '(a,es22.15)', "  a0(m=0, T=30) = ", val
    print *, "  PASS"
  end if

  ! --- Summary ---
  print *, ""
  if (nerr == 0) then
    print *, "All tests PASSED"
  else
    print '(a,i0,a)', " ", nerr, " test(s) FAILED"
    stop 1
  end if

end program test_boys
