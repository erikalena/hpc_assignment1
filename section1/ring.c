/* This program implements a stream of messages in
left and right directions */


#include <stdio.h>
#include <mpi.h>
#define niterations 1000

int main(int argc, char* argv[]) {
  int rank, size, reorder, true = 1;
  int root = 0;
  int left, right;
  
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  
  MPI_Status status;
  MPI_Comm ring_comm;
  /* create 1D periodic array */
  MPI_Cart_create(MPI_COMM_WORLD, 1, &size, &true, true, &ring_comm);
  MPI_Cart_shift(ring_comm, 0, 1, &left, &right);

  int tag = 10*rank;
  int lsend = rank, rsend = -rank;
  int lrecv, rrecv;
  int right_rank = (rank+1)%size;
  int left_rank = rank-1;

  // count msg received
  int nmsg = 0;
  
  //measuring time taken
  double init = 0.0, total_time = 0.0;
  
  
  // repeat same operations n times in order to collect a little bit of statistics
  for(int j = 0; j < niterations; j++) {
  
		// number of iterations must be equal to size in order for each process to receive
		// back the initial messages
		for(int i = 0; i < size; i++) { 
				// synchronize processes 
		  MPI_Barrier(MPI_COMM_WORLD);
				init = MPI_Wtime();
				
			if (rank == root) {
				left_rank = size-1;
				/* root starts sendind to its left and receving from right */
				MPI_Send(&lsend, 1, MPI_INT, left, tag, ring_comm);
				MPI_Recv(&rrecv, 1, MPI_INT, right, right_rank*10, ring_comm, &status);
				nmsg++;
				lsend = rrecv;
				/* now send to right and receive from left*/
				MPI_Send(&rsend, 1, MPI_INT, right, tag, ring_comm);
				MPI_Recv(&lrecv, 1, MPI_INT, left, left_rank*10, ring_comm, &status);
				nmsg++;
				rsend = lrecv;
			}
			else {
				/* start receiving from right and sending to left */
				MPI_Recv(&rrecv, 1, MPI_INT, right, right_rank*10, ring_comm, &status);
				nmsg++;
				MPI_Send(&lsend, 1, MPI_INT, left, tag, ring_comm);
				lsend = rrecv;
				/* then receive from left and send to right */
				MPI_Recv(&lrecv, 1, MPI_INT, left, left_rank*10, ring_comm, &status);
				nmsg++;
				MPI_Send(&rsend, 1, MPI_INT, right, tag, ring_comm);
				rsend = lrecv;
			}
			
			MPI_Barrier(MPI_COMM_WORLD);
			total_time += MPI_Wtime() - init;
		}
  }
  
  printf("I am process %d and I have received %d messages. My final messages have tag %d and value %d, %d\n", rank, nmsg, tag, lrecv, rrecv);
	
	MPI_Barrier(MPI_COMM_WORLD);
	
	if(rank == root)
		printf("Global amount of time taken to run on %d processors is: %f\n", size, total_time/niterations);
	
  MPI_Finalize();
  return 0;
}




