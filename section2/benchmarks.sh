#!/bin/bash
#PBS -l nodes=2:ppn=24
#PBS -l walltime=1:00:00
#PBS -q dssc

# move to mpi benchmark dir
cd $HOME/mpi_bench/mpi_benchmarks/src_c

# load openmpi module
module load openmpi-4.1.1+gnu-9.3.0

# map by core 
mpirun -np 2 --report-bindings ./IMB-MP1 PingPong 2>/dev/null

# map by socket
mpirun -np 2 --map-by socket --report-bindings ./IMB-MPI1 PingPong 2>/dev/null


# map by node
mpirun -np 2 --map-by node --report-bindings ./IMB-MPI1 PingPong 2>/dev/null


exit
