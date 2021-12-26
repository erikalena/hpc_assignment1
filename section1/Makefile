# Simple makefile to compile and clean the c programs 
# written for section 1 of assignment 1

CC=mpicc


all: ring/ring.x matrix/sum3Dmatrix.x

.PHONY: all

#ring: ring.o 
#	$(CC) -o ring/ring.x ring/ring.c

#sum3Dmatrix: sum3Dmatrix.o
#	$(CC) -o matrix/sum3Dmatrix.x matrix/sum3Dmatrix.c
	
%.x: %.c
	$(CC) $< -o $@ 


.PHONY: clean

clean:
	rm ring/*.x matrix/*.x

