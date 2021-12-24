#!/bin/bash
#PBS -l nodes=2:ppn=24
#PBS -l walltime=0:30:00
#PBS -q dssc

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load openmpi module
module load openmpi-4.1.1+gnu-9.3.0

# map by core 
#printf '%s\n' '# mpirun -np 2 --report-bindings ./IMB-MPI1 PingPong -off_cache -1  -msglog 28' > csv/nocache_core_ucx.csv
#mpirun -np 2 --report-bindings ./IMB-MPI1 PingPong -off_cache -1  -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >> csv/nocache_core_ucx.csv
# tcp 
#printf '%s\n' '# mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by core --report-bindings ./IMB-MPI1 PingPong -off_cache -1 -msglog 28' > csv/nocache_core_tcp.csv
#mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by core --report-bindings ./IMB-MPI1 PingPong -off_cache -1 -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >> csv/nocache_core_tcp.csv

# map by socket
printf '%s\n' '# mpirun -np 2 --map-by socket --report-bindings ./IMB-MPI1 PingPong -off_cache -1 -msglog 28' > csv/nocache_socket_ucx.csv
mpirun -np 2 --map-by socket --report-bindings ./IMB-MPI1 PingPong -off_cache -1 -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' ' |sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >> csv/nocache_socket_ucx.csv 
#tcp
printf '%s\n' '# mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by socket --report-bindings ./IMB-MPI1 PingPong -off_cache -1 -msglog 28' > csv/nocache_socket_tcp.csv
mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by socket --report-bindings ./IMB-MPI1 PingPong -off_cache -1 -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' | tr -s ' ' | sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' >> csv/nocache_socket_tcp.csv 
