/* This program implements a stream of messages in
left and right directions */


#include <stdio.h>
#include <mpi.h>
#define niterations 10000

// initial tag for each processor to send messages
int ltag, rtag;
int rank, lsend, rsend,	lrecv, rrecv;

void update_var(MPI_Status rstatus, MPI_Status lstatus) {
	// At each iteration each processor adds its rank to the received message if it comes from left 
  // and substracts its rank to the received message if it comes from right 
	rsend = lrecv + rank;
	lsend = rrecv - rank;
	// updates tags so that they correspond to the received messages
	ltag = rstatus.MPI_TAG;
	rtag = lstatus.MPI_TAG;
}


int main(int argc, char* argv[]) {
  int size, reorder, true = 1;
  int root = 0;
  int left, right;
  
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  MPI_Request lrequest, rrequest;
  MPI_Status lstatus, rstatus; // status of msgs received from left and from right respectively
  MPI_Comm ring_comm;
  
  // create 1D periodic array 
  MPI_Cart_create(MPI_COMM_WORLD, 1, &size, &true, true, &ring_comm);
  MPI_Cart_shift(ring_comm, 0, 1, &left, &right);
	
	// count number of msg received
	int nmsg;
  
  //measuring time taken
  double init = 0.0, total_time = 0.0;
  
  // save results to file
  FILE *f;
	
	
	
	/**************** Non blocking implementation *************/
	
   	if (rank == root) {
				 f = fopen("res_ring.txt", "w");
				 fprintf(f,"Non blocking implementation: \n\n");
				 fclose(f);
		}
		
		// repeat same operations n times in order to collect a little bit of statistics
		for(int j = 0; j < niterations; j++) {
				
			// initialize variables related to msg passing 
			// what I should initially send and rank the tag I should initially expect
			lsend = rank, rsend = -rank;
			// initial tag for each processor to send messages
			ltag = 10*rank;
			rtag = 10*rank;
			
			
			// count msg received 
			nmsg = 0;
			
			MPI_Barrier(MPI_COMM_WORLD);
			init = MPI_Wtime();
			
			do { 
			
					// send to right and receive from left
					MPI_Isend(&rsend, 1, MPI_INT, right, rtag, ring_comm, &rrequest);
					MPI_Irecv(&lrecv, 1, MPI_INT, left, MPI_ANY_TAG, ring_comm, &rrequest);
					nmsg++;
					
					// send to left and receve from right 
					MPI_Isend(&lsend, 1, MPI_INT, left, ltag, ring_comm, &lrequest);
					MPI_Irecv(&rrecv, 1, MPI_INT, right, MPI_ANY_TAG, ring_comm, &lrequest);
					nmsg++;
					MPI_Wait(&rrequest, &lstatus);
					MPI_Wait(&lrequest, &rstatus);
					
					update_var(rstatus, lstatus);
				
			} while (ltag != 10*rank);
			
			MPI_Barrier(MPI_COMM_WORLD);
			total_time += MPI_Wtime() - init;
		}
		
		f = fopen("res_ring.txt", "a");
		fprintf(f,"I am process %d and I have received %d messages. My final messages have tag %d and %d and value %d, %d\n", rank, nmsg, ltag, rtag, lrecv, rrecv);
		fclose(f);
		
		MPI_Barrier(MPI_COMM_WORLD);
				
		if(rank == root) {
			f = fopen("res_ring.txt", "a");
			fprintf(f,"Global amount of time taken by non blocking implementation to run on %d processors is: %f\n\n", size, total_time/niterations);
			fclose(f);
		}
		
  MPI_Barrier(MPI_COMM_WORLD);

  	
  	/************************* Blocking implemention *********************/
  	
  
  if(rank == root) {
  		f = fopen("res_ring.txt", "a");
  		fprintf(f, "Blocking implementation: \n\n");
  		fclose(f);
  	}
  
  //measuring time taken
  init = 0.0, total_time = 0.0;

  // repeat same operations n times in order to collect a little bit of statistics
  for(int j = 0; j < niterations; j++) {
  		
  		// initialize variables related to msg passing 
  		// what I should initially send and rank the tag I should initially expect
		lsend = rank, rsend = -rank;
		// initial tag for each processor to send messages
	  ltag = 10*rank;
	  rtag = 10*rank;
    
		// count msg received 
		nmsg = 0;
		
		// synchronize processes 
		MPI_Barrier(MPI_COMM_WORLD);
		init = MPI_Wtime();

		do { 
				
			if (rank%2 == 0) { 
				// start sendind to left and receving from right 
				MPI_Send(&lsend, 1, MPI_INT, left, ltag, ring_comm);
				MPI_Recv(&rrecv, 1, MPI_INT, right, MPI_ANY_TAG, ring_comm, &rstatus);
				nmsg++;
		
				// now send to right and receive from left
				MPI_Send(&rsend, 1, MPI_INT, right, rtag, ring_comm);
				MPI_Recv(&lrecv, 1, MPI_INT, left, MPI_ANY_TAG, ring_comm, &lstatus);
				nmsg++;
				
				update_var(rstatus, lstatus);
			}
			else {
				//start receiving from right and sending to left 
				MPI_Recv(&rrecv, 1, MPI_INT, right, MPI_ANY_TAG, ring_comm, &rstatus);
				nmsg++;
				MPI_Send(&lsend, 1, MPI_INT, left, ltag, ring_comm);
	
				// then receive from left and send to right 
				MPI_Recv(&lrecv, 1, MPI_INT, left, MPI_ANY_TAG, ring_comm, &lstatus);
				nmsg++;
				MPI_Send(&rsend, 1, MPI_INT, right, rtag, ring_comm);
			
				update_var(rstatus, lstatus);
			}
			
		} while(ltag != rank*10);
		
		MPI_Barrier(MPI_COMM_WORLD);
		total_time += MPI_Wtime() - init;
  }
  
 	
  f = fopen("res_ring.txt", "a");
	fprintf(f,"I am process %d and I have received %d messages. My final messages have tag %d and %d and value %d, %d\n", rank, nmsg, ltag, rtag, lrecv, rrecv);
	fclose(f);
	
	MPI_Barrier(MPI_COMM_WORLD);
			
	if(rank == root) {
	  f = fopen("res_ring.txt", "a");
		fprintf(f, "Global amount of time taken by blocking implementation to run on %d processors is: %f\n", size, total_time/niterations); 
		fclose(f);
	}
	
  MPI_Finalize();
  return 0;
}




