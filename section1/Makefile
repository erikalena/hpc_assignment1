# Simple makefile to compile and clean all the c codes written
# for section 1 of assignment 1

CC=mpicc
ODIR=obj


ring: ring.o 
		$(CC) -o ring.x ring.c

.PHONY: clean

clean:
	rm ring.x ring.o
