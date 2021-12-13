#!/bin/bash

#PBS -l nodes=2:ppn=24
#PBS -l walltime=00:30:00
#PBS -q dssc

cd $PBS_O_WORKDIR
#load openmpi module
module load openmpi-4.1.1+gnu-9.3.0


# establish the maximum number of processor on which you want to test the code
N=48
#store time taken by first and second implementation 
time_first=[]
time_second=[]

printf '%s,%s,%s\n' 'n_procs' 'time_nonblocking' 'time_blocking' >> results.csv

for i in  $( seq 2 $N )
do
   mpirun --mca btl ^openib -np $i ./ring.x
	 
   str=$(cat res_ring.txt | grep time | cut -f2 -d ':')  

   time_first[i]=$(echo ${str} | cut -d ' ' -f1) 
   time_second[i]=$(echo ${str} | cut -f2 -d ' ') 
   printf '%d,%s,%s\n' ${i} ${time_first[i]} ${time_second[i]} >> results.csv 
done

exit





