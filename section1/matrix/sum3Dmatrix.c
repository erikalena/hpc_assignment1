/* example of sctter routine use */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mpi.h>
#include <time.h>
#include <math.h>

#define niterations 1000


void print_matrix(int z, int x, int y, double matrix[z][x][y]) {

	for(int k = 0; k < z; k++) {
     	for(int i = 0; i < x; i++) {
      		for(int j = 0; j < y; j++) {
         printf("%f (%d,%d,%d) \t", matrix[k][i][j], k, i,j);
        }
         printf("\n");
      }
      printf("\n");
  	}
}

int *find_divisors(int procs, int* n) {
	int (*d) = malloc(sizeof(int[1]));
	for (int i = 2; i <= procs/2; i++) {
		if(procs%i == 0) {
			d[*n] = i;
			(*n)++;
		}
	}
	
	return d;
}


int main(int argc, char* argv[]) {
    
  int rank, size, ierr, true = 1;
  int root = 0;
  
  ierr = MPI_Init(NULL, NULL);
  ierr = MPI_Comm_size(MPI_COMM_WORLD, &size);
  ierr = MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	if (argc < 4) {
		if(rank == root) printf("Usage: mpirun -np (nprocs) sum3Dmatrix.x (dimz) (dimx) (dimy) \n");
	}
	else {
		int x, y, z;
		z = atoi(argv[1]); x = atoi(argv[2]); y = atoi(argv[3]);
		int m_dim[3] = {z,x,y};
		
		// brodcast matrices dimensions
		//MPI_Bcast(m_dim, 3, MPI_INT, root, MPI_COMM_WORLD);
		
		//MPI_Barrier(MPI_COMM_WORLD);
		
		// matrices initialization
		int	roundz = ((z + size - 1)/size)*size; 
		int	roundx = ((x + size - 1)/size)*size; 
		int	roundy = ((y + size - 1)/size)*size; 
		double M[roundz][roundx][roundy], N[roundz][roundx][roundy];
		
		
		if(rank == root) {
			srand(time(NULL));
			
			for(int k = 0; k < roundz; k++) {
				for(int i = 0; i < roundx; i++) {
			  		for(int j = 0; j < roundy; j++) { 
			   			if(k < z && i < x && j < y) {
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
			//printf("Matrix M is: \n");
			//print_matrix(roundz,roundx,roundy,M);
			//printf("Matrix N is: \n");
			//print_matrix(roundz,roundx,roundy,N);
			
		}
		
		// find topologies
		/*
		int n = 0;
		int *d = find_divisors(n_procs, &n);

		int div[n] ;
		for (int i = 0 ; i < n ; i++) {
				if(rank == root) 
				div[i] = d[i];
		}
		free(d);
		
		int (*dims)[3] = malloc(sizeof(int[1][3]));
		int a[3] = {n_procs,1,1};
		memcpy(dims[0],a,sizeof(a));	
		
		int r = 1; 
		for(int i = 0; i < n/2; i++) {
		  for(int j = i; j < n; j++) {
		    if (div[i]*div[j] == n_procs) {
		      int a[3] = {div[i],div[j], 1};
		      memcpy(dims[r++],a,sizeof(a));	
		    }
		    else {
		      for(int x = j; x < n - 1; x++) {
		        if(div[i]*div[j]*div[x] == n_procs) {
		      			int a[3] = {div[i],div[j], div[x]};
		      			memcpy(dims[r++],a,sizeof(a));	
		      		}
		      }
		    }
		  }
		} 
		if(rank == root) {
		for(int i =0; i < r; i++) {
				printf("%dx%dx%d\n", dims[i][0], dims[i][1], dims[i][2]);
		}
		} 
		
		MPI_Barrier(MPI_COMM_WORLD);		
		//free(dims);
		*/
		
		int dims[][3] = {{size,1,1}, {size/2,2,1},{size/3,3,1},{size/4,4,1},{size/4,2,2},{size/6,2,3}};
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
			int pz = roundz/dims[k][2], px = roundx/dims[k][0], py = roundy/dims[k][1];
			double M_1[pz][px][py], N_1[pz][px][py];
			int nsnd = pz*px*py;
			
					
			// measuring time taken
			double init = 0.0, total_time = 0.0;
			
			for (int h = 0; h < niterations; h++) {
			
						
				MPI_Barrier(new_communicator);		
				init = MPI_Wtime();
								
				MPI_Scatter(M, nsnd, MPI_DOUBLE_PRECISION, M_1, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);
				MPI_Scatter(N, nsnd, MPI_DOUBLE_PRECISION, N_1, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);

				
				for(int k = 0; k < pz; k++) 
				 	for(int i = 0; i < px; i++) 
							for(int j = 0; j < py; j++) 
								M_1[k][i][j] += N_1[k][i][j];
			 

			
				MPI_Gather(M_1, nsnd, MPI_DOUBLE_PRECISION, M, nsnd, MPI_DOUBLE_PRECISION, root, new_communicator);
				
				MPI_Barrier(new_communicator);
				total_time += MPI_Wtime() - init;
					 	
		 	}
	 	
		 	MPI_Barrier(new_communicator);
		 		
		 	if(rank == root) {
		 		//print the sum of the two matrices
				//printf("The sum of the two matrices is: \n");
				//print_matrix(roundz,roundx,roundy,M);
				
				int dimsRetrieved[3], periodsRetrieved[3], my_coords[3];
				MPI_Cart_get(new_communicator, 3, dimsRetrieved, periodsRetrieved, my_coords);

				FILE *fptr;
				fptr = fopen("3D_matrix.csv","a+");
				
				//print matrix dimensions
				fprintf(fptr,"%dx%dx%d,", z,x,y);
				
				//print topology
				for(int t = 0; t < 3; t++) {
					fprintf(fptr,"%d", dimsRetrieved[t]);
					if(t < 2) fprintf(fptr,"x");
			}
				
				//print time taken
				fprintf(fptr,",%f,\n", total_time/niterations);

			} 
		}
		 
	}
	
	ierr = MPI_Finalize();
}
