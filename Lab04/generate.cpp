#include<bits/stdc++.h>
#include <vector>
#include <random>
#include <fstream>
using namespace std;

ofstream OutFile("input.txt");
ofstream OutFile1("output.txt");

void printBinary(int n, int i){
    // Prints the binary representation
    // of a number n up to i-bits.
    int k;
    for (k = i - 1; k >= 0; k--) {
        if ((n >> k) & 1)
            OutFile << "1";
        else
            OutFile << "0";
    }
}
 
void printBinary1(int n, int i){
    // Prints the binary representation
    // of a number n up to i-bits.
    int k;
    for (k = i - 1; k >= 0; k--) {
        if ((n >> k) & 1)
            OutFile1 << "1";
        else
            OutFile1 << "0";
    }
}
typedef union {
    float f;
    struct{
        // Order is important.
        // Here the members of the union data structure
        // use the same memory (32 bits).
        // The ordering is taken
        // from the LSB to the MSB.
        unsigned int mantissa : 23;
        unsigned int exponent : 8;
        unsigned int sign : 1;
 
    } raw;
} myfloat;
 
// Function to convert real value
// to IEEE floating point representation
void printIEEE(myfloat var){
    // Prints the IEEE 754 representation
    // of a float value (32 bits)
    OutFile << var.raw.sign ;//<< "_";
    printBinary(var.raw.exponent, 8);
    // OutFile << "_";
    printBinary(var.raw.mantissa, 23);
    OutFile << "\n";
}

void printIEEE1(myfloat var){
    // Prints the IEEE 754 representation
    // of a float value (32 bits)
    cout << fixed << setprecision(6) << var.f << endl;
    OutFile1 << var.raw.sign ;//<< "_";
    printBinary1(var.raw.exponent, 8);
    // OutFile1 << "_";
    printBinary1(var.raw.mantissa, 23);
    OutFile1 << "\n";
}

unsigned int convertToInt(vector<unsigned int> arr, int low, int high){
    unsigned int f = 0, i;
    for (i = high; i >= low; i--) {
        f = f + arr[i] * pow(2, high - i);
    }
    return f;
}

float convert(vector<unsigned int> arr){
    myfloat var;
    
    // Convert the least significant
    // mantissa part (23 bits)
    // to corresponding decimal integer
    unsigned int f = convertToInt(arr, 9, 31);
 
    // Assign integer representation of mantissa
    var.raw.mantissa = f;
 
    // Convert the exponent part (8 bits)
    // to a corresponding decimal integer
    f = convertToInt(arr, 1, 8);
 
    // Assign integer representation
    // of the exponent
    var.raw.exponent = f;
 
    // Assign sign bit
    var.raw.sign = arr[0];
    // cout << "The float value of the given"
    //        " IEEE-754 representation is : \n";
    // cout << fixed << setprecision(6) << var.f <<endl;
    // cout << var.f <<endl;
    return var.f;
}

constexpr int FLOAT_MIN = -5;
constexpr int FLOAT_MAX = 5;
// Driver Code
int main(){

    vector<unsigned int> ieee = { 0,
            0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0 };
    
    // cout << convert(ieee) << endl;

    srand((unsigned)time(0));
    for(int pat = 0; pat<100; pat++){
    int opt = rand()%4;

    OutFile << opt << endl;
    OutFile << endl;
    vector < vector<unsigned int>>Image1; Image1.resize(16, vector<unsigned int>(32,0));
    vector < vector<unsigned int>>Image2; Image2.resize(16, vector<unsigned int>(32,0));
    vector < vector<unsigned int>>Image3; Image3.resize(16, vector<unsigned int>(32,0));
    
    vector < float>dImage1; dImage1.resize(36,0);
    vector < float>dImage2; dImage2.resize(36,0);
    vector < float>dImage3; dImage3.resize(36,0);

    float temp;

    for(int i=0; i<16; i++){
        int x = i/4;
        dImage1[i+7+2*x] = FLOAT_MIN + (float)(rand()) / ((float)(RAND_MAX/(FLOAT_MAX - FLOAT_MIN)));
        myfloat var;
        var.f = dImage1[i+7+2*x];
        printIEEE(var);
        // cout << fixed << setprecision(6) << dImage1[i+7+2*x] << endl;
    }
    OutFile << endl;
    for(int i=0; i<16; i++){
        int x = i/4;
        dImage2[i+7+2*x] = FLOAT_MIN + (float)(rand()) / ((float)(RAND_MAX/(FLOAT_MAX - FLOAT_MIN)));
        myfloat var;
        var.f = dImage2[i+7+2*x];
        printIEEE(var);
    }
    OutFile << endl;
    for(int i=0; i<16; i++){
        int x = i/4;
        dImage3[i+7+2*x] = FLOAT_MIN + (float)(rand()) / ((float)(RAND_MAX/(FLOAT_MAX - FLOAT_MIN)));
        myfloat var;
        var.f = dImage3[i+7+2*x];
        printIEEE(var);
    }
    if(opt==0 || opt==1){
        for(int i=1; i<5; i++){
            dImage1[i]    = dImage1[i+6];
            dImage1[i+30] = dImage1[i+24];
            dImage2[i]    = dImage2[i+6];
            dImage2[i+30] = dImage2[i+24];
            dImage3[i]    = dImage3[i+6];
            dImage3[i+30] = dImage3[i+24];
        }
        for(int i=0; i<31; i=i+6){
            dImage1[i]   = dImage1[i+1];
            dImage1[i+5] = dImage1[i+4];
            dImage2[i]   = dImage2[i+1];
            dImage2[i+5] = dImage2[i+4];
            dImage3[i]   = dImage3[i+1];
            dImage3[i+5] = dImage3[i+4];
        }
    }
    // for(int i=0; i<36; i++){
    //     if(i%6==0) cout << endl;
    //     cout << setprecision(6) << dImage1[i] << " ";
    // }
    // cout << endl;

    vector < vector< vector<unsigned int>>>Kernal1; Kernal1.resize(4, vector< vector<unsigned int>>(9,vector<unsigned int>(32,0)));
    vector < vector< vector<unsigned int>>>Kernal2; Kernal2.resize(4, vector< vector<unsigned int>>(9,vector<unsigned int>(32,0)));
    vector < vector< vector<unsigned int>>>Kernal3; Kernal3.resize(4, vector< vector<unsigned int>>(9,vector<unsigned int>(32,0)));

    vector < vector< float>>dKernal1; dKernal1.resize(4, vector< float>(9,0));
    vector < vector< float>>dKernal2; dKernal2.resize(4, vector< float>(9,0));
    vector < vector< float>>dKernal3; dKernal3.resize(4, vector< float>(9,0));
    
    OutFile << endl;    
    for(int i=0; i<4; i++){
        for(int j=0; j<9; j++){
            // for(int k=0; k<32; k++){
            //     Kernal1[i][j][k] = rand()%2;
            //     OutFile << Kernal1[i][j][k];
            // }
            // OutFile << endl;
            dKernal1[i][j] = FLOAT_MIN + (float)(rand()) / ((float)(RAND_MAX/(FLOAT_MAX - FLOAT_MIN)));
            myfloat var;
            var.f = dKernal1[i][j];
            printIEEE(var);
        } 
        // OutFile << endl;
    }
    OutFile << endl;
    for(int i=0; i<4; i++){
        for(int j=0; j<9; j++){
            // for(int k=0; k<32; k++){
            //     Kernal2[i][j][k] = rand()%2;
            //     OutFile << Kernal2[i][j][k];
            // }
            // OutFile << endl;
            dKernal2[i][j] = FLOAT_MIN + (float)(rand()) / ((float)(RAND_MAX/(FLOAT_MAX - FLOAT_MIN)));
            myfloat var;
            var.f = dKernal2[i][j];
            printIEEE(var);
        } 
        // OutFile << endl;
    }
    OutFile << endl;
    for(int i=0; i<4; i++){
        for(int j=0; j<9; j++){
            // for(int k=0; k<32; k++){
            //     Kernal3[i][j][k] = rand()%2;
            //     OutFile << Kernal3[i][j][k];
            // }
            // OutFile << endl;
            dKernal3[i][j] = FLOAT_MIN + (float)(rand()) / ((float)(RAND_MAX/(FLOAT_MAX - FLOAT_MIN)));
            myfloat var;
            var.f = dKernal3[i][j];
            printIEEE(var);
        } 
        // OutFile << endl;
    }
    OutFile << endl;


    vector < float>dOutput1; dOutput1.resize(16,0);
    vector < float>dOutput2; dOutput2.resize(16,0);
    vector < float>dOutput3; dOutput3.resize(16,0);
    vector < float>dOutput4; dOutput4.resize(16,0);
    for(int i = 0; i<16; i++){
        int x = i/4;
        dOutput1[i] = dKernal1[0][0]*dImage1[ 0+i+2*x] + dKernal1[0][1]*dImage1[ 1+i+2*x] + dKernal1[0][2]*dImage1[ 2+i+2*x] +
                      dKernal1[0][3]*dImage1[ 6+i+2*x] + dKernal1[0][4]*dImage1[ 7+i+2*x] + dKernal1[0][5]*dImage1[ 8+i+2*x] +
                      dKernal1[0][6]*dImage1[12+i+2*x] + dKernal1[0][7]*dImage1[13+i+2*x] + dKernal1[0][8]*dImage1[14+i+2*x] ;
        dOutput1[i]+= dKernal2[0][0]*dImage2[ 0+i+2*x] + dKernal2[0][1]*dImage2[ 1+i+2*x] + dKernal2[0][2]*dImage2[ 2+i+2*x] +
                      dKernal2[0][3]*dImage2[ 6+i+2*x] + dKernal2[0][4]*dImage2[ 7+i+2*x] + dKernal2[0][5]*dImage2[ 8+i+2*x] +
                      dKernal2[0][6]*dImage2[12+i+2*x] + dKernal2[0][7]*dImage2[13+i+2*x] + dKernal2[0][8]*dImage2[14+i+2*x] ;
        dOutput1[i]+= dKernal3[0][0]*dImage3[ 0+i+2*x] + dKernal3[0][1]*dImage3[ 1+i+2*x] + dKernal3[0][2]*dImage3[ 2+i+2*x] +
                      dKernal3[0][3]*dImage3[ 6+i+2*x] + dKernal3[0][4]*dImage3[ 7+i+2*x] + dKernal3[0][5]*dImage3[ 8+i+2*x] +
                      dKernal3[0][6]*dImage3[12+i+2*x] + dKernal3[0][7]*dImage3[13+i+2*x] + dKernal3[0][8]*dImage3[14+i+2*x] ;
        
        dOutput2[i] = dKernal1[1][0]*dImage1[ 0+i+2*x] + dKernal1[1][1]*dImage1[ 1+i+2*x] + dKernal1[1][2]*dImage1[ 2+i+2*x] +
                      dKernal1[1][3]*dImage1[ 6+i+2*x] + dKernal1[1][4]*dImage1[ 7+i+2*x] + dKernal1[1][5]*dImage1[ 8+i+2*x] +
                      dKernal1[1][6]*dImage1[12+i+2*x] + dKernal1[1][7]*dImage1[13+i+2*x] + dKernal1[1][8]*dImage1[14+i+2*x] ;
        dOutput2[i]+= dKernal2[1][0]*dImage2[ 0+i+2*x] + dKernal2[1][1]*dImage2[ 1+i+2*x] + dKernal2[1][2]*dImage2[ 2+i+2*x] +
                      dKernal2[1][3]*dImage2[ 6+i+2*x] + dKernal2[1][4]*dImage2[ 7+i+2*x] + dKernal2[1][5]*dImage2[ 8+i+2*x] +
                      dKernal2[1][6]*dImage2[12+i+2*x] + dKernal2[1][7]*dImage2[13+i+2*x] + dKernal2[1][8]*dImage2[14+i+2*x] ;
        dOutput2[i]+= dKernal3[1][0]*dImage3[ 0+i+2*x] + dKernal3[1][1]*dImage3[ 1+i+2*x] + dKernal3[1][2]*dImage3[ 2+i+2*x] +
                      dKernal3[1][3]*dImage3[ 6+i+2*x] + dKernal3[1][4]*dImage3[ 7+i+2*x] + dKernal3[1][5]*dImage3[ 8+i+2*x] +
                      dKernal3[1][6]*dImage3[12+i+2*x] + dKernal3[1][7]*dImage3[13+i+2*x] + dKernal3[1][8]*dImage3[14+i+2*x] ;
        
        dOutput3[i] = dKernal1[2][0]*dImage1[ 0+i+2*x] + dKernal1[2][1]*dImage1[ 1+i+2*x] + dKernal1[2][2]*dImage1[ 2+i+2*x] +
                      dKernal1[2][3]*dImage1[ 6+i+2*x] + dKernal1[2][4]*dImage1[ 7+i+2*x] + dKernal1[2][5]*dImage1[ 8+i+2*x] +
                      dKernal1[2][6]*dImage1[12+i+2*x] + dKernal1[2][7]*dImage1[13+i+2*x] + dKernal1[2][8]*dImage1[14+i+2*x] ;
        dOutput3[i]+= dKernal2[2][0]*dImage2[ 0+i+2*x] + dKernal2[2][1]*dImage2[ 1+i+2*x] + dKernal2[2][2]*dImage2[ 2+i+2*x] +
                      dKernal2[2][3]*dImage2[ 6+i+2*x] + dKernal2[2][4]*dImage2[ 7+i+2*x] + dKernal2[2][5]*dImage2[ 8+i+2*x] +
                      dKernal2[2][6]*dImage2[12+i+2*x] + dKernal2[2][7]*dImage2[13+i+2*x] + dKernal2[2][8]*dImage2[14+i+2*x] ;
        dOutput3[i]+= dKernal3[2][0]*dImage3[ 0+i+2*x] + dKernal3[2][1]*dImage3[ 1+i+2*x] + dKernal3[2][2]*dImage3[ 2+i+2*x] +
                      dKernal3[2][3]*dImage3[ 6+i+2*x] + dKernal3[2][4]*dImage3[ 7+i+2*x] + dKernal3[2][5]*dImage3[ 8+i+2*x] +
                      dKernal3[2][6]*dImage3[12+i+2*x] + dKernal3[2][7]*dImage3[13+i+2*x] + dKernal3[2][8]*dImage3[14+i+2*x] ;
        
        dOutput4[i] = dKernal1[3][0]*dImage1[ 0+i+2*x] + dKernal1[3][1]*dImage1[ 1+i+2*x] + dKernal1[3][2]*dImage1[ 2+i+2*x] +
                      dKernal1[3][3]*dImage1[ 6+i+2*x] + dKernal1[3][4]*dImage1[ 7+i+2*x] + dKernal1[3][5]*dImage1[ 8+i+2*x] +
                      dKernal1[3][6]*dImage1[12+i+2*x] + dKernal1[3][7]*dImage1[13+i+2*x] + dKernal1[3][8]*dImage1[14+i+2*x] ;
        dOutput4[i]+= dKernal2[3][0]*dImage2[ 0+i+2*x] + dKernal2[3][1]*dImage2[ 1+i+2*x] + dKernal2[3][2]*dImage2[ 2+i+2*x] +
                      dKernal2[3][3]*dImage2[ 6+i+2*x] + dKernal2[3][4]*dImage2[ 7+i+2*x] + dKernal2[3][5]*dImage2[ 8+i+2*x] +
                      dKernal2[3][6]*dImage2[12+i+2*x] + dKernal2[3][7]*dImage2[13+i+2*x] + dKernal2[3][8]*dImage2[14+i+2*x] ;
        dOutput4[i]+= dKernal3[3][0]*dImage3[ 0+i+2*x] + dKernal3[3][1]*dImage3[ 1+i+2*x] + dKernal3[3][2]*dImage3[ 2+i+2*x] +
                      dKernal3[3][3]*dImage3[ 6+i+2*x] + dKernal3[3][4]*dImage3[ 7+i+2*x] + dKernal3[3][5]*dImage3[ 8+i+2*x] +
                      dKernal3[3][6]*dImage3[12+i+2*x] + dKernal3[3][7]*dImage3[13+i+2*x] + dKernal3[3][8]*dImage3[14+i+2*x] ;
    }

    if(opt==0){
        for(int i=0; i<16; i++){
            if(dOutput1[i]<0) dOutput1[i] = 0;
            if(dOutput2[i]<0) dOutput2[i] = 0;
            if(dOutput3[i]<0) dOutput3[i] = 0;
            if(dOutput4[i]<0) dOutput4[i] = 0;
        }
    }
    else if(opt==1){
        for(int i=0; i<16; i++){
            if(dOutput1[i]<0) dOutput1[i] = 0.1*dOutput1[i];
            if(dOutput2[i]<0) dOutput2[i] = 0.1*dOutput2[i];
            if(dOutput3[i]<0) dOutput3[i] = 0.1*dOutput3[i];
            if(dOutput4[i]<0) dOutput4[i] = 0.1*dOutput4[i];
        }
    }
    else if(opt==2){
        for(int i=0; i<16; i++){
            dOutput1[i] = 1/(1+exp(-dOutput1[i]));
            dOutput2[i] = 1/(1+exp(-dOutput2[i]));
            dOutput3[i] = 1/(1+exp(-dOutput3[i]));
            dOutput4[i] = 1/(1+exp(-dOutput4[i]));
        }
    }
    else if(opt==3){
        for(int i=0; i<16; i++){
            dOutput1[i] = (exp(dOutput1[i])-exp(-dOutput1[i]))/(exp(dOutput1[i])+exp(-dOutput1[i]));//tanh(dOutput1[i]);
            dOutput2[i] = (exp(dOutput2[i])-exp(-dOutput2[i]))/(exp(dOutput2[i])+exp(-dOutput2[i]));//tanh(dOutput2[i]);
            dOutput3[i] = (exp(dOutput3[i])-exp(-dOutput3[i]))/(exp(dOutput3[i])+exp(-dOutput3[i]));//tanh(dOutput3[i]);
            dOutput4[i] = (exp(dOutput4[i])-exp(-dOutput4[i]))/(exp(dOutput4[i])+exp(-dOutput4[i]));//tanh(dOutput4[i]);
        }
    }

    
    for(int i=0; i<4; i++){
        myfloat var;
        var.f = dOutput1[i];
        printIEEE1(var);
        // myfloat var;
        var.f = dOutput2[i];
        printIEEE1(var);
    }
    for(int i=0; i<4; i++){
        myfloat var;
        var.f = dOutput3[i];
        printIEEE1(var);
        // myfloat var;
        var.f = dOutput4[i];
        printIEEE1(var);
    }
    for(int i=4; i<8; i++){
        myfloat var;
        var.f = dOutput1[i];
        printIEEE1(var);
        // myfloat var;
        var.f = dOutput2[i];
        printIEEE1(var);
    }
    for(int i=4; i<8; i++){
        myfloat var;
        var.f = dOutput3[i];
        printIEEE1(var);
        // myfloat var;
        var.f = dOutput4[i];
        printIEEE1(var);
    }
    for(int i=8; i<12; i++){
        myfloat var;
        var.f = dOutput1[i];
        printIEEE1(var);
        // myfloat var;
        var.f = dOutput2[i];
        printIEEE1(var);
    }
    for(int i=8; i<12; i++){
        myfloat var;
        var.f = dOutput3[i];
        printIEEE1(var);
        // myfloat var;
        var.f = dOutput4[i];
        printIEEE1(var);
    }
    for(int i=12; i<16; i++){
        myfloat var;
        var.f = dOutput1[i];
        printIEEE1(var);
        // myfloat var;
        var.f = dOutput2[i];
        printIEEE1(var);
    }
    for(int i=12; i<16; i++){
        myfloat var;
        var.f = dOutput3[i];
        printIEEE1(var);
        // myfloat var;
        var.f = dOutput4[i];
        printIEEE1(var);
    }
    OutFile1 << endl;
    }
    return 0;
}
// `include "/usr/synthesis/dw/sim_ver/DW_fp_mult.v"
// `include "/usr/synthesis/dw/sim_ver/DW_fp_sum4.v"
// `include "/usr/synthesis/dw/sim_ver/DW_fp_sum3.v"
// `include "/usr/synthesis/dw/sim_ver/DW_fp_exp.v"
// `include "/usr/synthesis/dw/sim_ver/DW_fp_div.v"
// `include "/usr/synthesis/dw/sim_ver/DW_fp_sub.v"
// `include "/usr/synthesis/dw/sim_ver/DW_fp_add.v"
//This code is contributed by shubhamsingh10