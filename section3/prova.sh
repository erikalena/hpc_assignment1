#!/bin/bash

input()
{
input='input_file'
i=1
while IFS= read -r line
do  
  if [ "$line" == "$x" ]
  then
    sed -n "$((i+1))p;$((i+2))p;$((i+3))p" < "$input" > tmp_file
    break
  fi
  echo "$line"
  ((i++))
done < "$input"
}


x=24
input

x=48
input
