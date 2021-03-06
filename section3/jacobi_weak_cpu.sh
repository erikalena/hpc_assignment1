#!/bin/bash
#PBS -l nodes=2:ppn=24
#PBS -l walltime=1:00:00
#PBS -q dssc

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load openmpi module
module load openmpi-4.1.1+gnu-9.3.0

# compile
mpif77 -ffixed-line-length-none Jacobi_MPI_vectormode.F -o jacoby3D.x


input()
{
input='input_file'
i=1
while IFS= read -r line
do  
  if [ "$line" == "$n" ]
  then
    sed -n "$((i+1))p;$((i+2))p;$((i+3))p" < "$input" > input.x
    break
  fi
  ((i++))
done < "$input"
}

printf '%s,%s,%s,%s,%s,%s,%s\n' 'map' 'n_procs' 'mintime' 'maxtime' 'jacobimin' 'jacobimax' 'mlups' >> results_weak.csv

# run the code on one single core to estimate serial time
n=1
input
printf 'core,1%s\n' `mpirun --mca btl ^openib -np 1 ./jacobi3D.x < input.x | tail -n 1 | cut -c 46- | cut --complement -c 84-122 |  sed 's/ \{1,\}/,/g'` >> results_weak.csv

# run the code on 4/8/12 processes within the same node pinning MPI processes within same socket and across two sockets
for i in {1..3}
do 
	((n=4*i))
	#change input file in order to assign 1200^3 to each process
	input 
	printf 'core,%d%s\n' $n `mpirun --mca btl ^openib -np ${n} --map-by core ./jacobi3D.x < input.x | tail -n 1 | cut -c 46- | cut --complement -c 84-122 |  sed 's/ \{1,\}/,/g'` >> results_weak.csv
done


for i in {1..3}
do 
	((n=4*i))
	#change input file
	input
	
	printf 'socket,%d%s\n' $n `mpirun --mca btl ^openib -np ${n} --map-by socket ./jacobi3D.x < input.x | tail -n 1 | cut -c 46- | cut --complement -c 84-122 | sed 's/ \{1,\}/,/g'` >> results_weak.csv
done

# run the code on 12/24/36/48 processors using two nodes
for i in {1..4}
do 
	((n=12*i))
	#change input file
	input
	
	printf 'node,%d%s\n' $n `mpirun --mca btl ^openib -np ${n} --map-by node ./jacobi3D.x < input.x | tail -n 1 | cut -c 46- | cut --complement -c 84-122 | sed 's/ \{1,\}/,/g'` >> results_weak.csv
done



rm jacobi2.sh.*
rm task.*

exit
