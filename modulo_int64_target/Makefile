FC       = nvfortran
ACCFLAGS = -acc=gpu -gpu=mem:separate
OMPFLAGS = -mp=gpu -gpu=mem:separate

all: mre_omp mre_acc

mre_omp: mre_omp.F90
	$(FC) $(OMPFLAGS) $< -o $@

mre_acc: mre_acc.F90
	$(FC) $(ACCFLAGS) $< -o $@

test:
	@echo "=== OpenMP target: modulo(int64) (should FAIL to compile) ==="
	-$(FC) $(OMPFLAGS) mre_omp.F90 -o mre_omp
	@echo ""
	@echo "=== OpenACC compute: modulo(int64) (should FAIL to compile) ==="
	-$(FC) $(ACCFLAGS) mre_acc.F90 -o mre_acc

clean:
	rm -f mre_omp mre_acc *.mod

.PHONY: all test clean
