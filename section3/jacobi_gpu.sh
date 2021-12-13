#!/bin/bash
#PBS -l nodes=1:ppn=48
#PBS -l walltime=1:00:00
#PBS -q dssc_gpu

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load openmpi module
module load openmpi-4.1.1+gnu-9.3.0

# compile
mpif77 -ffixed-line-length-none Jacobi_MPI_vectormode.F -o jacoby3D.x

printf '%s,%s,%s,%s,%s,%s,%s\n' 'map' 'n_procs' 'maxtime' 'maxtime' 'jacobimin' 'jacobimax' 'mlups' >> results_gpu.csv

# run the code on one single core to estimate serial time
printf 'core,1%s\n' `mpirun --mca btl ^openib -np 1 ./jacobi3D.x < input.1200 | tail -n 1 | cut -c 46- | cut --complement -c 84-122 |  sed 's/ \{1,\}/,/g'` >> results_gpu.csv

# run the code on 4/8/12 processes within the same node pinning MPI processes within same socket and across two sockets
for i in {1..3}
do 
	((n=4*i))
	printf 'core,%d%s\n' $n `mpirun --mca btl ^openib -np ${n} --map-by core ./jacobi3D.x < input.1200 | tail -n 1 | cut -c 46- | cut --complement -c 84-122 |  sed 's/ \{1,\}/,/g'` >> results_gpu.csv
done


for i in {1..3}
do 
	((n=4*i))
	printf 'socket,%d%s\n' $n `mpirun --mca btl ^openib -np ${n} --map-by socket ./jacobi3D.x < input.1200 | tail -n 1 | cut -c 46- | cut --complement -c 84-122 | sed 's/ \{1,\}/,/g'` >> results_gpu.csv
done

# run the code on 12/24/36/48 processors still on one node
for i in {1..4}
do 
	((n=12*i))
	printf 'socket,%d%s\n' $n `mpirun --mca btl ^openib -np ${n} ./jacobi3D.x < input.1200 | tail -n 1 | cut -c 46- | cut --complement -c 84-122 | sed 's/ \{1,\}/,/g'` >> results_gpu.csv
done



rm jacobi_gpu.sh.*
rm task.*

exit
