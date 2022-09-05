//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_TOP.v
//   Module Name : RSA_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "RSA_IP.v"
//synopsys translate_on

module RSA_TOP (
    // Input signals
    clk, rst_n, in_valid,
    in_p, in_q, in_e, in_c,
    // Output signals
    out_valid, out_m
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [3:0] in_p, in_q;
input [7:0] in_e, in_c;
output reg out_valid;
output reg [7:0] out_m;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter IDLE = 2'b00;
parameter LOAD = 2'b01;
parameter CAL  = 2'b11;
parameter OUT  = 2'b10;

integer i;
//================================================================
// Wire & Reg Declaration
//================================================================
reg [1:0] current_state, next_state;
wire [7:0] out_n, out_d;
reg [3:0] in_q_reg;
reg [3:0] in_p_reg;
reg [7:0] in_e_reg;


reg ld_flag;
wire out_flag;
reg [7:0] private_key;
reg [15:0] res;
reg [15:0] base;
reg [7:0] exp;
reg [7:0] mod;
reg [7:0] message [0:7];
reg [2:0] counter;
//================================================================
// DESIGN
//================================================================
RSA_IP #(4) I_RSA_IP ( .IN_P(in_p_reg), .IN_Q(in_q_reg), .IN_E(in_e_reg), .OUT_N(out_n), .OUT_D(out_d) );

assign out_flag = (counter == 'd7 && ld_flag)?1:0;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) res <= 'd1;
	else if(ld_flag) res <= 'd1;
	else if(exp[0] == 1'b1) res <= (res * base) % mod;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) exp <= 8'b0;
	else if(in_valid) exp <= 8'b0;
	else if(ld_flag) exp <= private_key;
	else exp <= exp >> 1;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) base <= 'd0;
	//else if(current_state == CAL)begin
	else if(ld_flag) begin
		case(counter)
		0: base <= message[1];
		1: base <= message[2];
		2: base <= message[3];
		3: base <= message[4];
		4: base <= message[5];
		5: base <= message[6];
		6: base <= message[7];
		7: base <= message[0];
		endcase
	end 
	else base <= (base * base) % mod;
end

always @(*)begin
	if(!rst_n) ld_flag = 0;
	else if(exp == 8'b0) ld_flag = 1;
	else ld_flag = 0;
end

always @(posedge clk) begin
	if(in_valid && counter == 0)begin
		in_q_reg <= in_q;
		in_p_reg <= in_p;
		in_e_reg <= in_e;	
	end			
end

always @(posedge clk) begin
	if(in_valid && counter == 1)
		mod <= out_n;			
end

always @(posedge clk) begin
	if(in_valid && counter == 1)
		private_key <= out_d;			
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) counter <= 0;
	else if(in_valid)
		counter <= (counter==7)?counter: counter + 1;			
	else if(current_state[0] && ld_flag)
		counter <= counter + 1;
	else if(current_state == OUT)
		counter <= counter + 1;
	else if(current_state == IDLE)
		counter <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(i=0; i<8; i=i+1) message[i] <= 'd0;
	end 
	else if(in_valid) begin
		message[counter] <= in_c;
	end
	else if(current_state==CAL && ld_flag)begin
		message[counter] <= res;
	end
end
//================================================================
// Finite State Machine
//================================================================
// Current State
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else        current_state <= next_state;
end 

// Next State
always @(*) begin
    if (!rst_n) next_state = IDLE;
    else begin
        case (current_state)
        IDLE : next_state = (in_valid)? LOAD: IDLE;
        LOAD : next_state = (!in_valid)? CAL: LOAD;
        CAL  : next_state = (out_flag)? OUT: CAL;
		OUT  : next_state = (counter == 'd7)? IDLE: OUT;
        default: next_state = IDLE;
        endcase
    end
end

// Output Assignment
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid   <= 'd0 ;
        out_m <= 'd0;
	end
	else if(current_state == OUT) begin 
		out_valid   <= 'd1 ;
        out_m <= message[counter];
	end 
	else begin
		out_valid   <= 'd0 ;
        out_m <= 'd0;
	end
end
endmodule


