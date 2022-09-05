#include <iostream>
#include <vector>
#include <random>
#include <fstream>
#include <stdlib.h>
#include <time.h> 
#include <iomanip>
#include <cmath>
using namespace std;

int main(){
    ofstream OutFile_input("input.txt");
    ofstream OutFile_output("output.txt");
    srand(time(NULL));
    vector< int> curr_id(5,0);
    vector< int> curr_T(5,0);
    vector< int> curr_A(5,0);
    for(int i = 1; i<4001;i++){
        if(i<5){
            int tmp_id = rand() % (255-0+1)+0;
            int tmp_T = rand() % (255-0+1)+0;
            int tmp_A = rand() % (255-0+1)+0;
            for(int j=0;j<5;j++){
                if(curr_id[j]==tmp_id){
                    j=0;
                    tmp_id = rand() % (255-0+1)+0;
                }
            }
            curr_id[i] =tmp_id;
            curr_T[i] =tmp_T;
            curr_A[i] = tmp_A;
            OutFile_input<<tmp_id<<" "<<tmp_A<<" "<<tmp_T<<" "<<tmp_A*tmp_T<<endl;
        }
        else{
            for(int j=0;j<4;j++){
                curr_id[j]  = curr_id[j+1];
                curr_T[j]   = curr_T[j+1];
                curr_A[j]   = curr_A[j+1];
            }
            int tmp_id = rand() % (255-0+1)+0;
            int tmp_T = rand() % (255-0+1)+0;
            int tmp_A = rand() % (255-0+1)+0;
            for(int j=0;j<4;j++){
                if(curr_id[j]==tmp_id){
                    j=0;
                    tmp_id = rand() % (255-0+1)+0;
                }
            }
            for(int j=0;j<4;j++){
                if(curr_id[j]==tmp_id){
                    j=0;
                    tmp_T = rand() % (255-0+1)+0;
                }
            }
            for(int j=0;j<4;j++){
                if(curr_id[j]==tmp_id){
                    j=0;
                    tmp_A = rand() % (255-0+1)+0;
                }
            }
            curr_id[4] =tmp_id;
            curr_T[4] = tmp_T;
            curr_A[4] = tmp_A;
            OutFile_input<<tmp_id<<" "<<tmp_A<<" "<<tmp_T<<" "<<tmp_A*tmp_T<<endl;
            int min_id = 0;
            int min_val = curr_T[0] * curr_A[0];
            for(int j=1;j<5;j++){
                int curr_val = curr_T[j] * curr_A[j];
                if(curr_val<=min_val){
                    min_val = curr_val;
                    min_id = j;
                }
            }
            OutFile_output<<curr_id[min_id]<<endl;
        }
    }

}