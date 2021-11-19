/* The following code implements a simple 3d matrix-matrix addition in parallel using a 
1D,2D and 3D distribution of data using virtual topology 

Matrix dimensions are accepted as input and
information has to be splitted on 24 cores (thin node) 

Communication between processes must be carried out only through collective operations*/

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <time.h>

#define niterations 100

int main(int argc, char* argv[]) {

  int size, rank, true = 1;
  int root = 0, dim[3];

  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
	
	
  if(rank == root) {
  		 
  		 int done;
  	   do {
		   	 done = 1;
	       printf("Insert 3D dimensions for random numbers matrix M (format 2 3 4, to obtain a 2x3x4 matrix)\n");
		     scanf("%d %d %d", &dim[0], &dim[1], &dim[2]);
		     printf(" %dx%dx%d\n", dim[0],dim[1],dim[2]);
		     for(int i = 0 ; i < 3; i++) {
		     		if ( dim[i] < 0 || dim[i] > 5000) 
		     			 printf("Negative number was typed in or maximum size was exceeded\n");
		     }
		
		} while(!done);
  
  
		printf("Generating matrix M of size %dx%dx%d\n", dim[0],dim[1],dim[2]);
	
	  int M[100][100][100];
		int i, j, k;
		
		srand(time(NULL));
		printf("%d\n", rand());
	
	  for(i = 0; i < dim[0]; i++)
			for(j = 0; j < dim[1]; j++)
		    for(k = 0; k < dim[2]; k++)
		        M[i][j][k] = rand()%50;
		        
		for(k = 0; k < dim[2]; k++) {
			printf("z-axis = %d\n", k);
			for(j = 0; j < dim[1]; j++) {
		    for(i = 0; i < dim[0]; i++){
		        printf("%d\t", M[i][j][k]);
		    }
		    printf("\n");
		  }
		} 
	}
	
	int d_dims[3] = {24, 1, 1};
  // determine "good" sizes of mesh, save them in dims and use them later to create cart
  MPI_Dims_create(size, 3, d_dims);

  // Make both dimensions periodic
  int periods[3] = {true, true, true};

  // Let MPI assign arbitrary ranks if it seems it necessary
  int reorder = true;

  // Create a communicator given the 2D torus topology.
  MPI_Comm new_communicator;
  MPI_Cart_create(MPI_COMM_WORLD, 3, d_dims, periods, reorder, &new_communicator);

  // My rank in the new communicator
  int my_rank;
  MPI_Comm_rank(new_communicator, &my_rank);
	
	printf("I'm process %d, my new rank is %d\n", rank, my_rank);

	MPI_Finalize();
	return 0;
		    
}
		
		
		

  


