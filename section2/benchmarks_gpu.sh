#!/bin/bash
#PBS -l nodes=2:ppn=48
#PBS -l walltime=0:30:00
#PBS -q dssc_gpu

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load openmpi module
module load openmpi-4.1.1+gnu-9.3.0

# map by core 
mpirun -np 2 --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > core_ucx_gpu.csv
mpirun -np 2 -mca pml ob1 --mca btl self,tcp --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > core_tcp_gpu.csv
mpirun -np 2 -mca pml ob1 --mca btl self,vader --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > core_vader_gpu.csv

# map by socket
mpirun -np 2 --map-by socket --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > socket_ucx_gpu.csv 
mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by socket --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > socket_tcp_gpu.csv
mpirun -np 2 -mca pml ob1 --mca btl self,vader  --map-by socket --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > socket_vader_gpu.csv


# map by node
mpirun -np 2 --map-by node --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > node_ucx_gpu.csv
mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by node --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > node_tcp_gpu.csv


# unload openmpi module
module unload openmpi-4.1.1+gnu-9.3.0

# load intel module
module load intel/20.4

# map by core 
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_core_ucx_gpu.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_core_tcp_gpu.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -genv I_MPI_OFI_PROVIDER shm ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_core_shm_gpu.csv

# map by socket
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_socket_ucx_gpu.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -genv I_MPI_OFI_PROVIDER tcp  ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_socket_tcp_gpu.csv
mpiexec -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -genv I_MPI_OFI_PROVIDER shm  ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_socket_shm_gpu.csv

# map by node
mpiexec -n 2 -ppn 1 ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_node_ucx_gpu.csv
mpiexec -n 2 -ppn 1 -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > intel_node_tcp_gpu.csv


rm benchmarks_gpu.sh.*

exit
