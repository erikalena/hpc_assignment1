#!/bin/bash
#PBS -l nodes=1:ppn=24
#PBS -l walltime=0:30:00
#PBS -q dssc

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load openmpi module
module load openmpi-4.1.1+gnu-9.3.0

# map by core 
#mpirun -np 2  --map-by core --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/core_ucx.csv
#mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by core --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/core_tcp.csv
#mpirun -np 2 -mca pml ob1 --mca btl self,vader  --map-by core --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/core_vader.csv

# map by socket
#mpirun -np 2 --map-by socket --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/socket_ucx.csv 
#mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by socket --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/socket_tcp.csv
#mpirun -np 2 -mca pml ob1 --mca btl self,vader  --map-by socket --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/socket_vader.csv


# map by node
#mpirun -np 2 --map-by node --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/node_ucx.csv
#mpirun -np 2 -mca pml ob1 --mca btl self,tcp  --map-by node --report-bindings ./IMB-MPI1 PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/node_tcp.csv


# unload openmpi module
module unload openmpi-4.1.1+gnu-9.3.0

# load intel module
module load intel/20.4

# map by core 
#mpirun -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/intel_core_ucx.csv
mpirun -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -env I_MPI_FABRICS ofi -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/intel_core_tcp.csv
mpirun -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,2 -env I_MPI_FABRICS shm -genv I_MPI_OFI_PROVIDER shm ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/intel_core_shm.csv

# map by socket
#mpirun -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/intel_socket_ucx.csv
mpirun -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -env I_MPI_FABRICS ofi -genv I_MPI_OFI_PROVIDER tcp  ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/intel_socket_tcp.csv
mpirun -n 2 -genv I_MPI_PIN_PROCESSOR_LIST=0,1 -env I_MPI_FABRICS shm -genv I_MPI_OFI_PROVIDER shm  ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/intel_socket_shm.csv

# map by node
#mpirun -n 2 -ppn 1 ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/intel_node_ucx.csv
#mpirun -n 2 -ppn 1 -env I_MPI_FABRICS ofi -genv I_MPI_OFI_PROVIDER tcp ./IMB-MPI1_intel PingPong -msglog 28 2>/dev/null | grep -v ^# | grep -v -e '^$' |  tr -s ' '| sed 's/^[ \t]+*//g' | sed 's/[ \t]+*/,/g' > csv/intel_node_tcp.csv


rm benchmarks.sh.*

exit
