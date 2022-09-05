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
    
    int PATCOUNT =  1000;
    srand(time(NULL));
    for(int i=0;i< PATCOUNT; i++){
        // declare initial variable
        vector< vector< int> > curr_img(8,vector<int>(8,0));
        vector<int > curr_op_vec(15,0);
        int x = 3;
        int y = 3;
        int curr_op = 0;
        int op_times = 15;
        // assign random value -63~63  //7bit with one signed bit // cant be -64
        for(int j=0;j<8;j++){
            for(int k = 0; k<8;k++){
                curr_img[j][k] = rand()%127-63;
            }
        }

        // random img and op
        // for(int j=0;j<8;j++){
        //     for(int k = 0; k<8;k++){
        //         cout<<setw(3)<<curr_img[j][k]<<" ";
        //     }
        //     cout<<endl;
        // }
        for(int j=0;j<15;j++){
            curr_op_vec[j] = rand()%9;
        }

        // write input file
        for(int j=0;j<15;j++){
            OutFile_input<<setw(2)<<curr_op_vec[j]<<" ";
        }
        OutFile_input<<endl;
        for(int y=0;y<8;y++){
            for(int x=0;x<8;x++){
                OutFile_input<<setw(3)<<curr_img[y][x]<<" ";
            }
            OutFile_input<<endl;
        }
        OutFile_input<<endl<<endl;

        // start op
        for(int op_count = 0 ; op_count<15; op_count++){
            curr_op = curr_op_vec[op_count];
            
            // cout<<"curr_op "<<curr_op<<endl;
            // cout<<"curr_pt "<<y<<" "<<x<<endl;
            int tmp_sum;
            int tmp_val;
            int tmp_val1;
            int tmp_val2;
            
            switch (curr_op)
            {
                case 0: // midpoint
                    int w[4];
                    w[0] = curr_img[y][x];
                    w[1] = curr_img[y][x+1];
                    w[2] = curr_img[y+1][x];
                    w[3] = curr_img[y+1][x+1];
                    for(int a=0;a<4;a++){
                        for(int b=a;b<4;b++){
                            if(w[a]>w[b]){
                                int tmp = w[a];
                                w[a] = w[b];
                                w[b] = tmp;
                            } 
                        }
                    }
                    tmp_val = (w[1]+w[2])/2;
                    curr_img[y][x] = tmp_val;
                    curr_img[y][x+1] = tmp_val;
                    curr_img[y+1][x] = tmp_val;
                    curr_img[y+1][x+1] = tmp_val;
                    break;
                case 1: // average
                    tmp_sum = curr_img[y][x]+curr_img[y][x+1]+curr_img[y+1][x]+curr_img[y+1][x+1];
                    curr_img[y][x] = tmp_sum/4;
                    curr_img[y][x+1] = tmp_sum/4;
                    curr_img[y+1][x] = tmp_sum/4;
                    curr_img[y+1][x+1] = tmp_sum/4;
                    break;
                case 2: // counter clock rotate
                    tmp_val = curr_img[y][x];
                    curr_img[y][x] = curr_img[y][x+1];
                    curr_img[y][x+1] = curr_img[y+1][x+1];
                    curr_img[y+1][x+1] = curr_img[y+1][x];
                    curr_img[y+1][x] = tmp_val;
                    break;
                case 3: // clock rotate
                    tmp_val = curr_img[y][x];
                    curr_img[y][x] = curr_img[y+1][x];
                    curr_img[y+1][x] = curr_img[y+1][x+1];
                    curr_img[y+1][x+1] = curr_img[y][x+1];
                    curr_img[y][x+1] = tmp_val;
                    break;
                case 4: // flip * -1
                    // tmp_val1 = curr_img[y][x];
                    // tmp_val2 = curr_img[y+1][x];
                    curr_img[y][x]     = curr_img[y][x]    *-1;
                    curr_img[y+1][x]   = curr_img[y+1][x]  *-1;
                    curr_img[y][x+1]   = curr_img[y][x+1]  *-1;
                    curr_img[y+1][x+1] = curr_img[y+1][x+1]*-1;
                    break;
                case 5: //up
                    if(y==0) continue;
                    else y--;
                    break;
                case 6: //left
                    if(x==0) continue;
                    else x--;
                    break;
                case 7: //down
                    if(y==6) continue;
                    else y++;
                    break;
                case 8: //right
                    if(x==6) continue;
                    else x++;
                    break;
            }

            // for(int j=0;j<8;j++){
            //     for(int k = 0; k<8;k++){
            //         cout<<setw(3)<<curr_img[j][k]<<" ";
            //     }
            //     cout<<endl;
            // }
        }
        // cout << y <<" "<< x << endl;
        if(x>=4 || y>=4){
            for(int y=0;y<8;y+=2){
                for(int x=0;x<8;x+=2){
                    OutFile_output<<setw(3)<<curr_img[y][x]<<" ";
                }
                OutFile_output<<endl;
            }
        }
        else{
            y++;x++;
            for(int y_=0;y_<4;y_++){
                for(int x_=0;x_<4;x_++){
                    OutFile_output<<setw(3)<<curr_img[y][x]<<" ";
                    x++;
                }
                y++;
                x=x-4;
                OutFile_output<<endl;
            }
        }
        OutFile_output<<endl<<endl;
    }
}