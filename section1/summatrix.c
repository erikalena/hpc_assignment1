/* example of sctter routine use */

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <time.h>
#include <math.h>

#define niterations 100


void print_matrix(int z, int x, int y, double matrix[z][x][y], FILE* f) {

	for(int k = 0; k < z; k++) {
     	for(int i = 0; i < x; i++) {
      		for(int j = 0; j < y; j++) {
         fprintf(f,"%f\t", matrix[k][i][j]);
        }
         fprintf(f, "\n");
      }
      printf("\n");
  	}
}

int main(int argc, char* argv[]) {
    
  int rank, size, ierr, true = 1;
  int root = 0, dim[3];
  ierr = MPI_Init(NULL, NULL);
  ierr = MPI_Comm_size(MPI_COMM_WORLD, &size);
  ierr = MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	int x, y, z;

  if(rank == root) {
  		 
  		 int done;
  	   do {
		   	 done = 1;
	       printf("Insert 3D dimensions for random numbers matrix M (ie. 2 3 4)\n");
		     scanf("%d %d %d", &dim[0], &dim[1], &dim[2]);
		     printf("%dx%dx%d\n", dim[0],dim[1],dim[2]);
		     for(int i = 0 ; i < 3; i++) {
		     		if(dim[i] < 0) 
		     			 printf("Negative or invalid number was typed in\n");
		     }
		
		} while(!done);
		
	}
	
	// brodcast matrices dimensions
	MPI_Bcast(dim, 3, MPI_INT, root, MPI_COMM_WORLD);
	
	z = dim[0]; x = dim[1]; y = dim[2];
	
	MPI_Barrier(MPI_COMM_WORLD);
	
	// matrices initialization
	int	roundz = ((z + size - 1)/size)*size; 
	double M[roundz][x][y], N[roundz][x][y];
	
	FILE *fptr;
  fptr = fopen("output.txt","a");
	
	if(rank == root) {
		printf("Generating matrix M of size %dx%dx%d\n", z, y, x);
		
		srand(time(NULL));
		
		for(int k = 0; k < roundz; k++) {
			for(int i = 0; i < x; i++) {
      		for(int j = 0; j < y; j++) { 
       		if(k < z) {
       			M[k][i][j] = rand()%100;
       			N[k][i][j] = rand()%100;
       		}
    				else {
    					M[k][i][j] = 0;
    					N[k][i][j] = 0;
    				}
    			}
    		}
    	}
    

    //pretty print M and N
    fprintf(fptr, "Matrix M is: \n");
    print_matrix(z,x,y,M,fptr);
    fprintf(fptr, "Matrix N is: \n");
    print_matrix(z,x,y,N,fptr);

	}
	
	/**** communicator ****/
	int d_dims[3] = {size,0,0};
	//int d_dims[3] = {sqrt(size), sqrt(size), 0};
	// determine "good" sizes of mesh, save them in dims and use them later to create cart
	MPI_Dims_create(size, 3, d_dims);

	// Make both dimensions periodic
	int periods[3] = {true, true, true};

	// Let MPI assign arbitrary ranks if it seems it necessary
	int reorder = true;

	// Create a communicator given the 2D torus topology.
	MPI_Comm new_communicator;
	MPI_Cart_create(MPI_COMM_WORLD, 3, d_dims, periods, reorder, &new_communicator);
	 /****************/
	
	int pz = roundz/size;
	double M_1[pz][x][y], N_1[pz][x][y];
	int nsnd = pz*x*y;
	
	MPI_Barrier(new_communicator);
			
	//measuring time taken
	double init = 0.0, total_time = 0.0;
	
	for (int h = 0; h < niterations; h++) {
			
		init = MPI_Wtime();
			  		
		MPI_Scatter(M, nsnd, MPI_DOUBLE_PRECISION, M_1, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);
		MPI_Scatter(N, nsnd, MPI_DOUBLE_PRECISION, N_1, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);

		
		for(int k = 0; k < pz; k++) 
		 	for(int i = 0; i < x; i++) 
		  		for(int j = 0; j < y; j++) 
		  			M_1[k][i][j]+= N_1[k][i][j];
	 
		
		MPI_Gather(M_1, nsnd, MPI_DOUBLE_PRECISION, M, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);
		
		MPI_Barrier(new_communicator);
		total_time += MPI_Wtime() - init;
			 
		
 	}
 	
 	if(rank == root) {
			 fprintf(fptr,"Time taken: %f\n", total_time/niterations);
			 
		printf("now matrix M is: \n");
	   print_matrix(z,x,y,M);
		 fclose(fptr);

	}
 	
  ierr = MPI_Finalize();
}
