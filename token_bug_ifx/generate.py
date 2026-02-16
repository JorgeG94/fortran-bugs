#!/usr/bin/env python3
"""Generate MRE: ifx fails on large 1D array constructor (max token size).

ifx rejects bracket [] array constructors exceeding its internal token
limit (~41,000 tokens). A 1.56M-element array hits this easily.

Usage: python3 generate.py
"""

N = 13662# same element count as the real use case

outfile = "big_array.F90"

with open(outfile, "w") as f:
    f.write("! MRE: ifx max token size exceeded on large 1D array constructor\n")
    f.write("! %d elements\n" % N)
    f.write("!\n")
    f.write("! Compile: ifx -c %s\n" % outfile)
    f.write("! Expected: error about maximum token size\n")
    f.write("! Works with: flang, gfortran (-fmax-array-constructor=%d)\n" % (N + 100))
    f.write("module big_array_mod\n")
    f.write("  implicit none\n")
    f.write("  integer, parameter :: dp = selected_real_kind(15, 307)\n")
    f.write("  integer, parameter, public :: N = %d\n" % N)
    f.write("  real(dp), dimension(N), protected :: data = [ &\n")
    for i in range(N):
        val = float(i) * 1.0e-10
        comma = ", &" if i < N - 1 else " &"
        f.write("    %.17e_dp%s\n" % (val, comma))
    f.write("  ]\n")
    f.write("end module big_array_mod\n")

import os
size_mb = os.path.getsize(outfile) / (1024 * 1024)
print(f"Wrote {outfile}: {N} elements, {size_mb:.1f} MB")
