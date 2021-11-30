#!/bin/bash
#PBS -l nodes=2:ppn=24
#PBS -l walltime=0:30:00
#PBS -q dssc

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load openmpi module
module load intel/20.4

mpiexec.hydra -n 2 -iface ib0 ./IMB-MPI1_intel PingPong

exit