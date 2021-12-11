#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int *find_divisors(int n_procs, int* n) {
	int (*d) = malloc(sizeof(int[1]));
	for (int i = 2; i <= n_procs/2; i++) {
		if(n_procs%i == 0) {
			d[*n] = i;
			(*n)++;
		}
	}
	
	return d;
}


int main() {
	int n_procs = 8;
	
  int n = 0;
  int *d = find_divisors(n_procs, &n);

  int div[n] ;
  for (int i = 0 ; i < n ; i++) {
  		printf("%d ", d[i]);
  		div[i] = d[i];
  }
  printf("%d\n", n);
  free(d) ;

  //int div[] = {2,3,4,6,8,12};
  //int n = sizeof(div)/sizeof(*div);
  
  
  int (*conf)[3] = malloc(sizeof(int[1][3]));
  int a[3] = {n_procs,1,1};
  memcpy(conf[0],a,sizeof(a));	
	
  int z = 1; 
  for(int i = 0; i < n/2; i++) {
    for(int j = i; j < n; j++) {
      if (div[i]*div[j] == n_procs) {
        int a[3] = {div[i],div[j], 1};
        memcpy(conf[z++],a,sizeof(a));	
      }
      else {
        for(int x = j; x < n - 1; x++) {
          if(div[i]*div[j]*div[x] == n_procs) {
        			int a[3] = {div[i],div[j], div[x]};
        			memcpy(conf[z++],a,sizeof(a));	
        		}
        }
      }
    }
  }
  for(int i =0; i < z; i++) {
  		printf("%dx%dx%d\n", conf[i][0], conf[i][1], conf[i][2]);
  	}
  free(conf);
  
  return 0;
}
