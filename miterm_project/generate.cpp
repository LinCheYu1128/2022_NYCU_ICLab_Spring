#include <iostream>
#include <vector>
#include <random>
#include <fstream>
#include <stdlib.h>
#include <time.h> 
#include <iomanip>
#include <cmath>
using namespace std;

int main()
{   
    ifstream InFile("./dram.dat");
    ofstream OutFile("dram01.dat");
    srand((unsigned)time(0));

    char data_list[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 'a', 'b', 'c', 'd', 'e', 'f'};
    string line;
    int n;
    char hex_string[20];
    while (!InFile.eof()){
    // for(int j=0; j<12; j++){
        getline(InFile,line);
        // cout << line<< endl;
        OutFile << line << endl;
        getline(InFile,line);
        for(int i=0; i<4; i++){
            n = rand()%256;
            sprintf(hex_string, "%x", n); //convert number to hex
            // cout << hex_string<< " ";
            OutFile << hex_string << " ";
        }
        // cout << endl;
        OutFile << endl;
        // cout << line<< endl;
    }
    
    return 0;
}
