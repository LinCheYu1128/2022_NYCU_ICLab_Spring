//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_IP.v
//   Module Name : RSA_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module RSA_IP #(parameter WIDTH = 3) (
    // Input signals
    IN_P, IN_Q, IN_E,
    // Output signals
    OUT_N, OUT_D
);

// ===============================================================
// Declaration
// ===============================================================
input  [WIDTH-1:0]   IN_P, IN_Q;
input  [WIDTH*2-1:0] IN_E;
output [WIDTH*2-1:0] OUT_N;
output signed[WIDTH*2-1:0] OUT_D;
// ===============================================================
// Soft IP DESIGN
// ===============================================================

wire signed[WIDTH*2-1:0]   x[0:WIDTH*2-2];
wire signed[WIDTH*2-1:0]   y[0:WIDTH*2-2];
wire [WIDTH*2-1:0]   a[0:WIDTH*2-2];
wire [WIDTH*2-1:0]   b[0:WIDTH*2-2];

wire [WIDTH*2-1:0] phi;
assign phi = (IN_P-1)* (IN_Q-1);
assign OUT_N = IN_P* IN_Q;

wire [WIDTH*2-1:0] tmp_result[0:WIDTH*2-1];

genvar i;
generate
assign OUT_D = (y[0][WIDTH*2-1])? y[0] + phi: y[0] ;

for ( i=0; i<WIDTH*2-1; i=i+1) begin: loop_l
        
    if(i==0)begin
        assign a[i] = IN_E;
        assign b[i] = phi % IN_E;
        assign x[i] = y[1];
        assign y[i] = x[1] - (phi/IN_E)*y[1];
    end
    else begin
        assign a[i] = b[i-1];
        assign b[i] = a[i-1] % b[i-1];
        assign x[i] = (b[i-1]==1)? 'd0 : y[i+1];
        assign y[i] = (b[i-1]==1)? 'd1 : x[i+1] - (a[i-1]/b[i-1])*y[i+1];
    end    
end
endgenerate
endmodule
//         always @(*) begin
//             if(i == 0)begin
//                
//             end
//             else if(b[i-1]==0)begin
//                 a[i] = 1;
//                 b[i] = 0;
//                 x[i] = 1;
//                 y[i] = 0;
//             end
//             else begin
//                 a[i] = b[i-1];
//                 b[i] = a[i-1]%b[i-1];
//                 x[i] = y[i+1];
//                 y[i] = x[i+1] - (a[i-1]/b[i-1])*y[i+1];
//             end 
            
//         end

/* v1
genvar i;
generate

wire signed[WIDTH*2-1:0]   x[0:WIDTH*2-1];
wire signed[WIDTH*2-1:0]   y[0:WIDTH*2-1];
wire [WIDTH*2-1:0]   a[0:WIDTH*2-1];
wire [WIDTH*2-1:0]   b[0:WIDTH*2-1];

wire [WIDTH*2-1:0] phi;
assign phi = (IN_P-1)* (IN_Q-1);

assign OUT_N = IN_P* IN_Q;
assign OUT_D = (y[0][WIDTH*2-1])? y[0] + phi: y[0] ;

for ( i=0; i<WIDTH*2; i=i+1) begin: loop_l
    if(i==0)begin
        assign a[i] = IN_E;
        assign b[i] = phi % IN_E;
        assign x[i] = y[1];
        assign y[i] = x[1] - (phi/IN_E)*y[1];
    end
    else begin
        assign a[i] = b[i-1];
        assign b[i] = a[i-1] % b[i-1];
        assign x[i] = (b[i-1]==0)? 'd1 : y[i+1];
        assign y[i] = (b[i-1]==0)? 'd0 : x[i+1] - (a[i-1]/b[i-1])*y[i+1];
    end    
end
endgenerate
endmodule

*/