#!/bin/bash

#load openmpi module
#module load openmpi-4.1.1+gnu-9.3.0


# establish the maximum number of processor on which you want to test the code
N=4
#store time taken by first and second implementation 
time_first=[]
time_second=[]

printf '%s\t%s\t%s\n' 'n_procs' 'time_first' 'time_second' >> results.csv

for i in  $( seq 0 $N )
do
   str=$(mpirun -np $i -oversubscribe ./ring.x | grep time | cut -f2 -d ':')  

   time_first[i]=$(echo ${str} | cut -d ' ' -f1) 
   time_second[i]=$(echo ${str} | cut -f2 -d ' ') 
   printf '%d\t%s\t%s\n' ${i} ${time_first[i]} ${time_second[i]} >> results.csv 
done






