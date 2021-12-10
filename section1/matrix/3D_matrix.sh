#!/bin/bash

#load openmpi module
#module load openmpi-4.1.1+gnu-9.3.0


# number of cores on a thin node
n=24


printf '%s,%s,%s,\n' 'Matrix' 'Topology' 'Time taken' >> 3D_matrix.csv


mpirun -np 8 -oversubscribe ./sum3Dmatrix.x 40 20 20








