#include <cstdio>
#include <random>
#include <algorithm> 
#include <stdlib.h>
#include <iostream>
#include<cstdlib>
#include<time.h>

int gcd(int a, int b) ;
class BBS{
    public:
        // todo: check parameters are valid
        BBS(long p0, long q0){
            p = p0;
            q = q0;
            M = p0 * q0;
            // rand = seed;
        }
        BBS(long p0, long q0, long seed){
            p = p0;
            q = q0;
            M = p0 * q0;
            rand = seed;
        }
        int set_seed(long seed) {
            if (gcd(M, seed) != 1) {
                return 0;
            } else {
               rand = seed; 
               return 1;
            }
        }
        long get_rand() {
            long next_rand = rand * rand % M;
            rand = next_rand;
            return rand;
        }
    private:
        long p;
        long q;
        long M;
        long rand;
};

int main() {
    //assuming valid params now
    BBS bbs((long)11, (long)23);
    // srand(time(NULL));
    long seed = rand();
    while (bbs.set_seed(seed) != 1) {
        seed = rand();
    }
    printf("seed is %ld \n", seed);
    for (int i = 0; i < 10; i++) {
        printf("%ld \n", bbs.get_rand());
    }
}

int gcd(int a, int b) 
{ 
    // Everything divides 0  
    if (a == 0) 
       return b; 
    if (b == 0) 
       return a; 
    // base case 
    if (a == b) 
        return a; 
    // a is greater 
    if (a > b) 
        return gcd(a-b, b); 
    return gcd(a, b-a); 
}
