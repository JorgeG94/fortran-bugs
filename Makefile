FC ?= gfortran

# gfortran needs this for the large array constructor
GFORTRAN_FLAGS = -fmax-array-constructor=1600000

FCFLAGS ?= $(if $(findstring gfortran,$(FC)),$(GFORTRAN_FLAGS),)

# Default: reshape variant (nvfortran bug)
SRC ?= big_array_reshape.F90

.PHONY: all clean test test-flat test-reshape generate

all: test_boys

generate:
	python3 generate_mre.py

big_array.o: $(SRC)
	$(FC) $(FCFLAGS) -c $< -o $@

test_boys.o: test_boys.F90 big_array.o
	$(FC) $(FCFLAGS) -c $< -o $@

test_boys: test_boys.o big_array.o
	$(FC) $(FCFLAGS) $^ -o $@

test: test_boys
	./test_boys

# Convenience targets
test-reshape:
	$(MAKE) clean
	$(MAKE) test SRC=big_array_reshape.F90

test-flat:
	$(MAKE) clean
	$(MAKE) test SRC=big_array_flat.F90

clean:
	rm -f *.o *.mod test_boys
