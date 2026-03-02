FC       = nvfortran
ACCFLAGS = -acc=gpu -gpu=mem:separate
OMPFLAGS = -mp=gpu -gpu=mem:separate
ACC_SRC  = mre_final.F90
OMP_SRC  = mre_openmp.F90

all: mre_O1 mre_O3 mre_omp_O1 mre_omp_O3

mre_O1: $(ACC_SRC)
	$(FC) -O1 $(ACCFLAGS) $< -o $@

mre_O3: $(ACC_SRC)
	$(FC) -O3 $(ACCFLAGS) $< -o $@

mre_omp_O1: $(OMP_SRC)
	$(FC) -O1 $(OMPFLAGS) $< -o $@

mre_omp_O3: $(OMP_SRC)
	$(FC) -O3 $(OMPFLAGS) $< -o $@

test: all
	@echo "=== OpenACC -O1 (should PASS) ==="
	@./mre_O1
	@echo ""
	@echo "=== OpenACC -O3 (should CRASH) ==="
	@./mre_O3 || true
	@echo ""
	@echo "=== OpenMP -O1 (should PASS) ==="
	@./mre_omp_O1
	@echo ""
	@echo "=== OpenMP -O3 (should PASS) ==="
	@./mre_omp_O3

clean:
	rm -f mre_O1 mre_O3 mre_omp_O1 mre_omp_O3 *.mod

.PHONY: all test clean
