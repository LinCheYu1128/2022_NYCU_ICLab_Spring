#include <iostream>
#include <vector>
#include <random>
#include <fstream>
#include <stdlib.h>
#include <time.h> 
#include <iomanip>
#include <cmath>
using namespace std;

//*********************************************
// global variable
int b_noise = 3;
vector<int> type01{3,0,3,0,3};
vector<int> type23{1,4,3,2,1};
ofstream OutFile_input("input.txt");
ofstream OutFile_output("output.txt");
ofstream OutFile_input2("dram.dat");
//*********************************************

void type1(int curr_frame_id){
    OutFile_input<<1<<" "<<curr_frame_id<<endl;
    //four region
    vector<int> dist_vec(4,0);
    for(int round=0;round<4;round++){
        // rand dist 0~250(original 1~251), max height 15
        int tmp_dist = rand()%(250-0+1)+0;
        dist_vec[round] = tmp_dist;
    }
    
    for(int hist = 0;hist<16;hist++){
        int curr_dist;
        OutFile_input<<hist<<endl;
        if(hist==0 || hist==1 || hist==4 || hist==5)            curr_dist = dist_vec[0];
        else if(hist==2 || hist==3 || hist==6 || hist==7)       curr_dist = dist_vec[1];
        else if(hist==8 || hist==9 || hist==12 || hist==13)     curr_dist = dist_vec[2];
        else if(hist==10 || hist==11 || hist==14 || hist==15)   curr_dist = dist_vec[3];
        vector<int> p_vec(256,b_noise);
        for(int i=0;i<5;i++){
            p_vec[curr_dist+i] += type01[i];
        }
        vector <int> bin_vec(256,0);
        vector< vector<int > > input_record;
        for(int i=0;i<255;i++){
            vector<int> tmp_input_record;
            for(int j=0;j<4;j++){
                int curr_p = rand()%10;
                //cout<<i<<" "<<p_vec[i]<<" "<<curr_p<<endl;
                if(curr_p<p_vec[i]) {
                    
                    bin_vec[i] +=1;
                    tmp_input_record.emplace_back(1);
                }
                else{
                    tmp_input_record.emplace_back(0);
                }
            }
            input_record.emplace_back(tmp_input_record);
        }
        for(int i=0;i<255;i++){
            OutFile_input<<i<<" ";
            for(int j=0;j<input_record[i].size();j++){
                OutFile_input<<input_record[i][j]<<" ";
            }
            OutFile_input<<endl;
        }
        OutFile_input<<endl;
        OutFile_output<<curr_dist<<" ";
    }
    OutFile_output<<endl;
    
    
}

void type2(int curr_frame_id){
    OutFile_input<<2<<" "<<curr_frame_id<<endl;
    // initial point and distance
    int start_loc = rand()%(15-0+1)+0;
    int start_dist = rand()%(235-0+1)+0;
    int start_x = start_loc%4;
    int start_y = start_loc/4;
    // according to convex fill other distance
    int count = 0;
    int table_dist = 0;
    int curr_dist = 0;
    vector<int> dist_vec(16,0);
    vector<int> check_vec(16,0);
    while(curr_dist<4){
        for(int i=0;i<16;i++){
            if(((abs(i/4-start_y)<=curr_dist && abs(i%4-start_x)==curr_dist) || (abs(i/4-start_y)==curr_dist && abs(i%4-start_x)<=curr_dist)) && check_vec[i]==0){
                dist_vec[i] = start_dist+ curr_dist*5;
                check_vec[i] = 1;
            }
        }
        curr_dist++;
    }
    cout<<"CURR LOC"<<start_loc<<endl;
    for(int y=0;y<4;y++){
        for(int x=0;x<4;x++){
            cout<<dist_vec[y*4+x]<<" ";
        }
        cout<<endl;
    }
    //apply probability according to dist
    
    for(int hist = 0;hist<16;hist++){
        OutFile_input<<hist<<endl;
        vector< vector<int > > input_record;
        vector<int> p_vec(256,b_noise);
        p_vec[255] = 0;
        for(int i=0;i<5;i++){
            p_vec[dist_vec[hist]+i] += type23[i];
        }
        vector <int> bin_vec(256,0);
        for(int i=0;i<255;i++){
            vector<int> tmp_input_record;
            for(int j=0;j<7;j++){
                int curr_p = rand()%10;
                if(curr_p<p_vec[i]) {
                    bin_vec[i] +=1;
                    tmp_input_record.emplace_back(1);
                }
                else{
                    tmp_input_record.emplace_back(0);
                }
            }
            input_record.emplace_back(tmp_input_record);
        }
        for(int i=0;i<255;i++){
            //cout<<i<<" ";
            OutFile_input<<i<<" ";
            for(int j=0;j<input_record[i].size();j++){
               // cout<<input_record[i][j]<<" ";
                OutFile_input<<input_record[i][j]<<" ";
            }
            //cout<<endl;
            OutFile_input<<endl;
        }
        OutFile_output<<dist_vec[hist]<<" ";
        OutFile_input<<endl;
    }
    OutFile_output<<endl;
}

void type3_1(int curr_frame_id){
     OutFile_input<<3<<" "<<curr_frame_id<<endl;
    // initial point and distance
    int start_loc = rand()%(15-0+1)+0;
    int start_dist = rand()%(250-15+1)+15;
    int start_x = start_loc%4;
    int start_y = start_loc/4;
    // according to convex fill other distance
    int count = 0;
    int table_dist = 0;
    int curr_dist = 0;
    vector<int> dist_vec(16,0);
    vector<int> check_vec(16,0);
    while(curr_dist<4){
        for(int i=0;i<16;i++){
            if(((abs(i/4-start_y)<=curr_dist && abs(i%4-start_x)==curr_dist) || (abs(i/4-start_y)==curr_dist && abs(i%4-start_x)<=curr_dist)) && check_vec[i]==0){
                dist_vec[i] = start_dist- curr_dist*5;
                check_vec[i] = 1;
            }
        }
        curr_dist++;
    }
    cout<<"CURR LOC"<<start_loc<<endl;
    for(int y=0;y<4;y++){
        for(int x=0;x<4;x++){
            cout<<dist_vec[y*4+x]<<" ";
        }
        cout<<endl;
    }
    //apply probability according to dist
    
    for(int hist = 0;hist<16;hist++){
        OutFile_input<<hist<<endl;
        vector< vector<int > > input_record;
        vector<int> p_vec(256,b_noise);
        p_vec[255] = 0;
        for(int i=0;i<5;i++){
            p_vec[dist_vec[hist]+i] += type23[i];
        }
        vector <int> bin_vec(256,0);
        for(int i=0;i<255;i++){
            vector<int> tmp_input_record;
            for(int j=0;j<7;j++){
                int curr_p = rand()%10;
                if(curr_p<p_vec[i]) {
                    bin_vec[i] +=1;
                    tmp_input_record.emplace_back(1);
                }
                else{
                    tmp_input_record.emplace_back(0);
                }
            }
            input_record.emplace_back(tmp_input_record);
        }
        for(int i=0;i<255;i++){
            //cout<<i<<" ";
            OutFile_input<<i<<" ";
            for(int j=0;j<input_record[i].size();j++){
               // cout<<input_record[i][j]<<" ";
                OutFile_input<<input_record[i][j]<<" ";
            }
            //cout<<endl;
            OutFile_input<<endl;
        }
        OutFile_output<<dist_vec[hist]<<" ";
        OutFile_input<<endl;
    }
    OutFile_output<<endl;
}


void type3_2(int curr_frame_id){
    OutFile_input<<3<<" "<<curr_frame_id<<endl;
    // initial point and distance
    int start_loc = rand()%(15-0+1)+0;
    int start_dist = rand()%(235-0+1)+0;
    int start_x = start_loc%4;
    int start_y = start_loc/4;
    // according to convex fill other distance
    int count = 0;
    int table_dist = 0;
    int curr_dist = 0;
    vector<int> dist_vec(16,0);
    vector<int> check_vec(16,0);
    while(curr_dist<4){
        for(int i=0;i<16;i++){
            if(((abs(i/4-start_y)<=curr_dist && abs(i%4-start_x)==curr_dist) || (abs(i/4-start_y)==curr_dist && abs(i%4-start_x)<=curr_dist)) && check_vec[i]==0){
                dist_vec[i] = start_dist+ curr_dist*5;
                check_vec[i] = 1;
            }
        }
        curr_dist++;
    }
    cout<<"CURR LOC"<<start_loc<<endl;
    for(int y=0;y<4;y++){
        for(int x=0;x<4;x++){
            cout<<dist_vec[y*4+x]<<" ";
        }
        cout<<endl;
    }
    //apply probability according to dist
    
    for(int hist = 0;hist<16;hist++){
        OutFile_input<<hist<<endl;
        vector< vector<int > > input_record;
        vector<int> p_vec(256,b_noise);
        p_vec[255] = 0;
        for(int i=0;i<5;i++){
            p_vec[dist_vec[hist]+i] += type23[i];
        }
        vector <int> bin_vec(256,0);
        for(int i=0;i<255;i++){
            vector<int> tmp_input_record;
            for(int j=0;j<7;j++){
                int curr_p = rand()%10;
                if(curr_p<p_vec[i]) {
                    bin_vec[i] +=1;
                    tmp_input_record.emplace_back(1);
                }
                else{
                    tmp_input_record.emplace_back(0);
                }
            }
            input_record.emplace_back(tmp_input_record);
        }
        for(int i=0;i<255;i++){
            //cout<<i<<" ";
            OutFile_input<<i<<" ";
            for(int j=0;j<input_record[i].size();j++){
               // cout<<input_record[i][j]<<" ";
                OutFile_input<<input_record[i][j]<<" ";
            }
            //cout<<endl;
            OutFile_input<<endl;
        }
        OutFile_output<<dist_vec[hist]<<" ";
        OutFile_input<<endl;
    }
    OutFile_output<<endl;
}

int main(){
    srand(time(NULL));
    // first 32 frames type 0 from dram
    for(int frames=0;frames<32;frames++){
        //16 hist in each case
        for(int hist=0;hist<16;hist++){
            // rand dist 0~250(original 1~251), max height 15
            int curr_dist = rand()%(250-0+1)+0;
            vector<int> p_vec(256,b_noise);
            p_vec[255] = 0;
            
            for(int i=0;i<5;i++){
                p_vec[curr_dist+i] = p_vec[curr_dist+i]+type01[i];
            }
            vector<int> bin_vec(256,0);
            for(int i=0;i<255;i++){
                for(int j=0;j<15;j++){
                    int curr_p = rand()%10;
                    if(curr_p<p_vec[i]) bin_vec[i] = bin_vec[i]+1;
                } 
            }
            
            for(int j=0;j<256;j++){
                if(j%4==0){
                    OutFile_input2<<"@"<<(frames/16)+1<<hex<<(frames%16)<<hex<<hist<<hex<<setw(2)<<setfill('0')<<j<<endl;
                }
                OutFile_input2<<hex<<setw(2)<<setfill('0')<<bin_vec[j]<<" ";
                if(j%4==3){
                    OutFile_input2<<endl;
                }
            }

            /*
            //test
            for(int i=0;i<256;i++){
                cout<<i<<" "<<bin_vec[i]<<" "<<p_vec[i]<<endl;
            }
            cout<<"curr_dist"<<curr_dist<<endl;
            */
            // write output
            OutFile_output<<curr_dist<<" ";
        }
        OutFile_output<<endl;
    }
    OutFile_output<<endl;
    // input start send data
    // type 0 will never occur
    int curr_frame_id;
    int times = 0;
    while(times<100){
        curr_frame_id = rand()%32;
        int curr_type = rand()%4;
        //curr_type = 1 ;
        if(curr_type==0){
            type1(curr_frame_id);
        }
        else if(curr_type==1){
            type2(curr_frame_id);
        }
        else if(curr_type==2){
            type3_1(curr_frame_id);
        }
        else{
            type3_2(curr_frame_id);
        }
        times++;
    }
    /*
    int curr_frame_id = 0;
    type1(curr_frame_id);
    type1(curr_frame_id);
    type1(curr_frame_id);
    type1(curr_frame_id);
    type2(curr_frame_id);
    type2(curr_frame_id);
    type2(curr_frame_id);
    type2(curr_frame_id);
    type3(curr_frame_id);
    type3(curr_frame_id);
    type3(curr_frame_id);
    type3(curr_frame_id);
    */
    return 0;
}
