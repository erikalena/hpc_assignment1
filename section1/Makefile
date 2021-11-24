# Simple makefile to compile and clean all the c codes written
# for section 1 of assignment 1

CC=mpicc


all: ring.x sum3Dmatrix.x

.PHONY: all

#ring: ring.o 
#	$(CC) -o ring.x ring.c

#sum3Dmatrix: sum3Dmatrix.o
#	$(CC) -o sum3Dmatrix.x sum3Dmatrix.c
	
%.x: %.c
	$(CC) $< -o $@ 


.PHONY: clean

clean:
	rm *.x

