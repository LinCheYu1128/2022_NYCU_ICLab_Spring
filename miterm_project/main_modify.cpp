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
    // input output file
    ofstream OutFile_input("input.txt");
    ofstream OutFile_output("output.txt");
    ofstream OutFile_input2("dram.dat");
    for(int count =0;count<32;count++){
        vector< vector< int> > frame(16,vector<int>(256,0));
        int range_max = 255;
        int range_min = 0;
        for(int i=0;i<16;i++){
            for(int j=0;j<255;j++){
                frame[i][j] = (int) rand() % (range_max - range_min+1)+range_min; 
            }   
        }

        vector< int> dist(16,0);
        int curr_mode = (int) rand() % (3-0+1)+0;
        for(int i=0;i<16;i++){
            
            //int curr_mode = 0;
            if(curr_mode==0){
                int tmp_max = 0;
                for(int j=0;j<255;j++){
                    if(frame[i][j]>tmp_max) {
                            tmp_max = frame[i][j];
                            dist[i] = j;
                    }
                }
            }
            else if(curr_mode==1){
                int tmp_max = 0;
                for(int j=0;j<254;j++){
                    int curr_val = frame[i][j]+frame[i][j+1];
                    if(curr_val>tmp_max) {
                            tmp_max = curr_val;
                            dist[i] = j;
                    }
                }
            }
            else if(curr_mode==2){
                int tmp_max = 0;
                for(int j=0;j<252;j++){
                    int curr_val = frame[i][j]+frame[i][j+1]+frame[i][j+2]+frame[i][j+3];
                    if(curr_val>tmp_max) {
                            tmp_max = curr_val;
                            dist[i] = j;
                    }
                }
            }
            else{
                int tmp_max = 0;
                for(int j=0;j<248;j++){
                    int curr_val = frame[i][j]+frame[i][j+1]+frame[i][j+2]+frame[i][j+3]+
                                    frame[i][j+4]+frame[i][j+5]+frame[i][j+6]+frame[i][j+7];
                    if(curr_val>tmp_max) {
                            tmp_max = curr_val;
                            dist[i] = j;
                    }
                }
            }
        }

        // write input
        OutFile_input<<curr_mode<<endl;
        // for(int i=0;i<16;i++){
        //     for(int j=0;j<255;j++){
        //         OutFile_input<<hex<<setw(2)<<setfill('0')<<frame[i][j]<<" ";
        //     } 
        //     OutFile_input<<endl;
        // }
        // OutFile_input<<endl;

        // write dram
        for(int i=0;i<16;i++){
            for(int j=0;j<256;j++){
                if(j%4==0){
                    OutFile_input2<<"@"<<(count/16)+1<<hex<<(count%16)<<hex<<i<<hex<<setw(2)<<setfill('0')<<j<<endl;
                }
                OutFile_input2<<hex<<setw(2)<<setfill('0')<<frame[i][j]<<" ";
                if(j%4==3){
                    OutFile_input2<<endl;
                }
            }

        }

        // write output
        for(int i=0;i<16;i++){
            OutFile_output<<setw(3)<<dist[i]<<" ";
        }
        OutFile_output<<endl;
    }
    

    return 0;
}
