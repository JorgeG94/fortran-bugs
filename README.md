# Large array constructors 


Simply compile `$FC -c big_array.F90` 

With nvhpc/26.1 it segfaults halfway through. 

ifx dies with maximum token size of 41k

gfortran compiles it wiht: `-fmax-array-constructor=1600000` 

flagn 21.1.3 compiled it no issues.
