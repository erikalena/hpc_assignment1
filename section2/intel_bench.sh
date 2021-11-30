#!/bin/bash
#PBS -l nodes=2:ppn=2
#PBS -l walltime=0:30:00
#PBS -q dssc

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load intel module
module load intel/20.4

# map by core 
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 ./IMB-MPI1_intel PingPong -msglog 30 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_core_ucx.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 30 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_core_tcp.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -genv I_MPI_OFI_PROVIDER shm ./IMB-MPI1_intel PingPong -msglog 30 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_core_shm.csv

# map by socket
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 ./IMB-MPI1_intel PingPong -msglog 30 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_socket_ucx.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -genv I_MPI_OFI_PROVIDER tcp  ./IMB-MPI1_intel PingPong -msglog 30 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_socket_tcp.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -genv I_MPI_OFI_PROVIDER shm  ./IMB-MPI1_intel PingPong -msglog 30 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_socket_shm.csv

# map by node
mpiexec -n 2 -ppn 1 ./IMB-MPI1_intel PingPong -msglog 30 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_node_ucx.csv
mpiexec -n 2 -ppn 1 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 30 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_node_tcp.csv

exit
