This section is splitted in two subfolders corresponding to the two parts 
to be developed: one for the ring exercise and the other for 3d matrix-matrix addition.

The code for both the subsections has been written in C and a simple Makefile
is provided to compile both the programs.

## Usage
```
make
```
Otherwise to manually compile each file:

```
mpicc ring/ring.c -o ring/ring.x
mpicc matrix/sum3Dmatrix.x -o matrix/sum3Dmatrix.c
```

To execute the code:

```
#specify the number of processors
mpirun --mca btl ^openib -np (nprocs) ./ring.x
mpirun -np (nprocs) --mca btl ^openib ./sum3Dmatrix.x 2400 100 100
```

To get rid of executables:

```
make clean
```
