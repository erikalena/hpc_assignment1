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
  int n_procs = 24;
  int* n;
  *n = 0;
 /* int *div = find_divisors(n_procs, n);
  for (int i = 0 ; i < *n ; i++) {
  		printf("%d ", div[i]);
  }*/
  int (*co)[3] = malloc(sizeof(int[1][3]));
  int a[3] = {24,1,1};
//	memcpy(conf[0],a,sizeof(a));	
	
 /* int z = 1; 
  for(int i = 0; i < *n/2; i++) {
    for(int j = i; j < *n; j++) {
      if (div[i]*div[j] == 24) {
        int a[3] = {div[i],div[j], 1};
        memcpy(conf[z],a,sizeof(a));	
     		z++;
      }
      else {
        for(int x = j; x < *n - 1; x++) {
          if(div[i]*div[j]*div[x] == 24) {
        			int a[3] = {div[i],div[j], div[x]};
        			memcpy(conf[z],a,sizeof(a));	
     				z++;
        		}
        }
      }
    }
  }
  for(int i =0; i < z; i++) {
  		printf("%dx%dx%d\n", conf[i][0], conf[i][1], conf[i][2]);
  	}*/
  free(co);
//  free(div);
return 0;

}
