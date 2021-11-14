#!/bin/bash
#PBS -l nodes=2:ppn=24
#PBS -l walltime=0:30:00
#PBS -q dssc

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load openmpi module
module load openmpi-4.1.1+gnu-9.3.0

# map by core 
mpirun -np 2 --report-bindings ./IMB-MPI1 PingPong 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > core_ucx.csv
mpirun -mca pml ob1 --mca btl self,tcp --report-bindings -np 2 --map-by core ./IMB-MPI1 PingPong 2>/dev/null | grep -v ^# | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > core_tcp.csv  
mpirun -np 2 -mca pml ob1 --mca btl self,vader --report-bindings ./IMB-MPI1 PingPong 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > core_vader.csv

# map by socket
mpirun -np 2 --map-by socket --report-bindings ./IMB-MPI1 PingPong 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > socket_ucx.csv 
mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by socket --report-bindings ./IMB-MPI1 PingPong 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > socket_tcp.csv
mpirun -np 2 -mca pml ob1 --mca btl self,vader  --map-by socket --report-bindings ./IMB-MPI1 PingPong 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > socket_vader.csv


# map by node
mpirun -np 2 --map-by node --report-bindings ./IMB-MPI1 PingPong 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > node_ucx.csv
mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by node --report-bindings ./IMB-MPI1 PingPong 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > node_tcp.csv

rm benchmarks.sh.*

exit
