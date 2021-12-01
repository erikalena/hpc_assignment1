#!/bin/bash
#PBS -l nodes=1:ppn=8
#PBS -l walltime=0:30:00
#PBS -q dssc

# move to mpi benchmark dir
cd $PBS_O_WORKDIR

# load openmpi module
module load openmpi-4.1.1+gnu-9.3.0

# compile
mpif77 -ffixed-line-length-none Jacobi_MPI_vectormode.F -o jacoby3D.x

printf '%s\t%s\t%s\t%s\t%s\t%s\n' 'map' 'n_procs' 'maxtime' 'maxtime' 'jacobimin' 'jacobimax' >> results.csv

# run the code
i=1
#for i in {1..3}
#do 
	((n=4*i))
	printf 'core\t%d\t' $n >> results.csv
	mpirun --mca btl ^openib -np ${n} --map-by core ./jacoby3D.x < input.1200 | tail -n 1 | cut -c 46- | cut --complement -c 84-122 >> results.csv
	
	#mpirun --mca btl ^openib -np $n -map-by core ./jacoby3D.x < input.1200 | tail -n 1 | cut -c 46- | cut --complement -c 84-122

#done

exit
