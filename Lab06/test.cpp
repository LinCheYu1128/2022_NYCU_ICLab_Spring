#include <iostream>
#include<bits/stdc++.h>
#include <tuple>        // std::tuple, std::make_tuple, std::tie
#include <random>
#include <numeric>
using namespace std;
 
// Recursive function to demonstrate the extended Euclidean algorithm.
// It returns multiple values using tuple in C++.
int gcd(int a, int b)
{
    if (a == 0)
        return b;
    return gcd(b % a, a);
}
tuple< int, int> extended_gcd(int a, int b)
{
    cout <<"a " <<a <<", b " <<b<< endl;
    if (b == 1) {
        return make_tuple(0, 1);
    }
 
    int gcd, x, y;
    
    // unpack tuple returned by function into variables
    tie(x, y) = extended_gcd(b, a % b);
    cout <<"x " <<x <<", y " <<y<< endl;
    return make_tuple(y, (x - (a/b) * y));
}
int modular(int base, int exp, int mod) {
   int res = 1;
   while (exp > 0) {
        if (exp % 2 == 1)
            res= (res * base) % mod;
        exp = exp >> 1;
        base = (base * base) % mod;
   }
   return res;
}
int main()
{   
    ofstream OutFile("input1.txt");
    srand((unsigned)time(0));
    int prime[6] = {2, 3, 5, 7, 11, 13};

    for(int pat=0; pat < 1; pat++){
        int IN_P = 11;//prime[rand()%6];
        int IN_Q = 13;//prime[rand()%6];
        while(IN_P==IN_Q || (IN_P*IN_Q==6)){
            IN_Q = prime[rand()%6];
        }
        cout << IN_P << " "<<IN_Q<<endl;
        OutFile << IN_P << " "<<IN_Q<<endl;
        int a = (IN_P-1)*(IN_Q-1);
        int b = 67;//(rand()%(a-2))+2;
        while(gcd(a,b)!=1){
            b = (rand()%(a-2))+2;
        }
        int N = IN_P*IN_Q;
        cout << "phi = "<< a << " e = "<< b << endl;

        OutFile << b << endl;

        tuple<int, int> t = extended_gcd(a, b);

        int x = get<0>(t);
        int y = get<1>(t);
        // cout << "x = " << x << " y = " << y << endl;
        if(y<0) y = y + a;
        // cout << "The GCD is " << gcd << endl;
        cout << "N = "<< N <<", d = " << y <<  endl;
        int c[8];
        int m[8];
        for(int i=0; i<8; i++){
            c[i] = rand()%N;
            m[i] = modular(c[i], y , N);
            OutFile << c[i] << " ";
        }
        OutFile << endl;
        for(int i=0; i<8; i++){
            OutFile << m[i] << " ";
            // cout<<"c = "<< c[i] <<" m = " << m[i]<< endl;
        }
        OutFile << endl<< endl;
    }
    

    return 0;
}
