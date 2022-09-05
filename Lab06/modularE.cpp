//#include<bits/stdc++.h>
#include <iostream>
#include <vector>
#include <random>
#include <fstream>
#include <stdlib.h>
#include <time.h> 
#include <iomanip>
#include <cmath>
#include <windows.h>
using namespace std;

int modular(int base, int exp, int mod) {
   int res = 1;
   cout << "res = "<< res << ", base = "<<base<<", exp = "<<exp << endl;
   while (exp > 0) {
        if (exp % 2 == 1)res= (res * base) % mod;
        exp = exp >> 1;
        base = (base * base) % mod;
        cout << "res = "<< res << ", base = "<<base<<", exp = "<<exp << endl;
   }
   return res;
}
int main(){
    int e = 17;
    int b = 27;
    int m = 33;
    int c=1;
    // for(int i=0;i<e;i++){
    //     int tmp1 = c%m;
    //     int tmp2 = b%m;
    //     int tmp3 = (tmp1*tmp2) % m;
    //     c=tmp3;
    //     cout<<tmp3<<endl;
    // }
    cout << endl;
    cout<< modular(b, e , m)<<endl;

}