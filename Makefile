FC ?= gfortran

# gfortran needs this for the large array constructor
GFORTRAN_FLAGS = -fmax-array-constructor=1600000

FCFLAGS ?= $(if $(findstring gfortran,$(FC)),$(GFORTRAN_FLAGS),)

.PHONY: all clean test

all: test_boys

big_array.o: big_array.F90
	$(FC) $(FCFLAGS) -c $< -o $@

test_boys.o: test_boys.F90 big_array.o
	$(FC) $(FCFLAGS) -c $< -o $@

test_boys: test_boys.o big_array.o
	$(FC) $(FCFLAGS) $^ -o $@

test: test_boys
	./test_boys

clean:
	rm -f *.o *.mod test_boys
