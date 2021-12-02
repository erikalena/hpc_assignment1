/* example of sctter routine use */

#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>
#include <time.h>
#include <math.h>

#define niterations 1000


void print_matrix(int z, int x, int y, double matrix[z][x][y]) {

	for(int k = 0; k < z; k++) {
     	for(int i = 0; i < x; i++) {
      		for(int j = 0; j < y; j++) {
         printf("%f\t", matrix[k][i][j]);
        }
         printf("\n");
      }
      printf("\n");
  	}
}



int main(int argc, char* argv[]) {
    
  int rank, size, ierr, true = 1;
  int root = 0;
  
  ierr = MPI_Init(NULL, NULL);
  ierr = MPI_Comm_size(MPI_COMM_WORLD, &size);
  ierr = MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	
	int x, y, z;
	z = atoi(argv[1]); x = atoi(argv[2]); y = atoi(argv[3]);
	int m_dim[3] = {z,x,y};
	
	// brodcast matrices dimensions
	MPI_Bcast(m_dim, 3, MPI_INT, root, MPI_COMM_WORLD);
	

	
	MPI_Barrier(MPI_COMM_WORLD);
	
	// matrices initialization
	int	roundz = ((z + size - 1)/size)*size; 
	double M[roundz][x][y], N[roundz][x][y];
	
	
	if(rank == root) {
		
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
	  
	  // print M and N
	  /*
	  printf("Matrix M is: \n");
	  print_matrix(z,x,y,M);
	  printf("Matrix N is: \n");
	  print_matrix(z,x,y,N);
		*/
	}
	
	int dims[][3] = {{size,0,0}, {4,2,0},{2,2,2}};
	int trials = sizeof(dims)/12;
	
	// test performances for each of the given topologies
	for(int k = 0; k < trials; k++) {

		int periods[3] = {true, true, true};
	
		// create communicator 
		MPI_Dims_create(size, 3, dims[k]);

		// Let MPI assign arbitrary ranks if it seems it necessary
		int reorder = true;

		// Create a communicator given the previous information
		MPI_Comm new_communicator;
		MPI_Cart_create(MPI_COMM_WORLD, 3, dims[k], periods, reorder, &new_communicator);
		

		// submatrices dimensions for each process	
		int pz = roundz/size;
		double M_1[pz][x][y], N_1[pz][x][y], S[z][x][y];
		int nsnd = pz*x*y;
		
				
		//measuring time taken
		double init = 0.0, total_time = 0.0;
		
		for (int h = 0; h < niterations; h++) {
		
					
			MPI_Barrier(new_communicator);		
			init = MPI_Wtime();
							
			MPI_Scatter(M, nsnd, MPI_DOUBLE_PRECISION, M_1, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);
			MPI_Scatter(N, nsnd, MPI_DOUBLE_PRECISION, N_1, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);

			
			for(int k = 0; k < pz; k++) 
			 	for(int i = 0; i < x; i++) 
						for(int j = 0; j < y; j++) 
							M_1[k][i][j]+= N_1[k][i][j];
		 
			
			MPI_Gather(M_1, nsnd, MPI_DOUBLE_PRECISION, S, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);
			
			MPI_Barrier(new_communicator);
			total_time += MPI_Wtime() - init;
				 	
	 	}
 	
	 	MPI_Barrier(new_communicator);
	 		
	 	if(rank == root) {
	 		//print the sum of the two matrices
			//fprintf(fptr, "The sum of the two matrices is: \n");
			//print_matrix(z,x,y,S,fptr);
			
			int dimsRetrieved[3], periodsRetrieved[3], my_coords[3];
			MPI_Cart_get(new_communicator, 3, dimsRetrieved, periodsRetrieved, my_coords);

			  FILE *fptr;
				fptr = fopen("3D_matrix.csv","a+");
				
				//print matrix dimensions
			fprintf(fptr,"%dx%dx%d\t", z,x,y);
			
			//print topology
			for(int t = 0; t < 3; t++) {
				fprintf(fptr,"%d", dimsRetrieved[t]);
				if(t < 2) fprintf(fptr,"x");
			}
			
			//print time taken
			fprintf(fptr,"\t\t%f\n", total_time/niterations);

		} 
	}
	 
	
	ierr = MPI_Finalize();
}
