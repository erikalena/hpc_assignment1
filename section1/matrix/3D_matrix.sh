#!/bin/bash

#PBS -l nodes=1:ppn=24
#PBS -l walltime=01:00:00
#PBS -q dssc

cd $PBS_O_WORKDIR

#load openmpi module
module load openmpi-4.1.1+gnu-9.3.0


# number of cores on a thin node
n=24


printf '%s,%s,%s,%s,\n' 'Matrix' 'Topology' 'Time taken' 'Comp time' >> 3D_matrix.csv


mpirun -np $n --mca btl ^openib ./sum3Dmatrix.x 2400 100 100
mpirun -np $n --mca btl ^openib ./sum3Dmatrix.x 1200 200 100
mpirun -np $n --mca btl ^openib ./sum3Dmatrix.x 800 300 100







