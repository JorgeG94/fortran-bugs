FC ?= gfortran

GFORTRAN_FLAGS = -fmax-array-constructor=1600000
FCFLAGS ?= $(if $(findstring gfortran,$(FC)),$(GFORTRAN_FLAGS),)

.PHONY: all clean test generate

all: test_flat

generate:
	python3 generate.py

big_array.o: big_array.F90
	$(FC) $(FCFLAGS) -c $< -o $@

test.o: test.F90 big_array.o
	$(FC) $(FCFLAGS) -c $< -o $@

test_flat: test.o big_array.o
	$(FC) $(FCFLAGS) $^ -o $@

test: test_flat
	./test_flat

clean:
	rm -f *.o *.mod test_flat
