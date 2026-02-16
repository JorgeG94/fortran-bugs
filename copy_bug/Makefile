# Compiler and flags
FC      = nvfortran
FFLAGS  = -mp=gpu -stdpar=gpu -gpu=mem:separate -Minfo=all -Ktrap=fp

# Targets
all: bork nobork

bork: copy.F90
	$(FC) $(FFLAGS) -DBORK copy.F90 -o bork

nobork: copy.F90
	$(FC) $(FFLAGS) -DNOBORK copy.F90 -o nobork

clean:
	rm -f bork nobork *.o *.mod

