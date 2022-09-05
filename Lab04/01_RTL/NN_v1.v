//++++++++++++++ Include DesignWare++++++++++++++++++
// synopsys translate_off

// synopsys translate_on
//+++++++++++++++++++++++++++++++++++++++++++++++++
// evince /RAID2/EDA/synopsys/synthesis/2020.09/dw/doc/manuals/dwbb_userguide.pdf &

module NN(
	// Input signals
	clk,
	rst_n,
	in_valid_i,
	in_valid_k,
	in_valid_o,
	Image1,
	Image2,
	Image3,
	Kernel1,
	Kernel2,
	Kernel3,
	Opt,
	// Output signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;
parameter inst_arch = 2;


parameter IDLE = 2'b00;
parameter LOAD = 2'b01;
parameter CAL  = 2'b11;
integer i,j;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_i, in_valid_k, in_valid_o;
input [inst_sig_width+inst_exp_width:0] Image1, Image2, Image3;
input [inst_sig_width+inst_exp_width:0] Kernel1, Kernel2, Kernel3;
input [1:0] Opt;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REGISTER DECLARATION
//---------------------------------------------------------------------
reg [2:0] current_state, next_state;

reg [1:0] inOpt;

reg [inst_sig_width+inst_exp_width:0] inImage1 [0:35];
reg [inst_sig_width+inst_exp_width:0] inImage2 [0:35];
reg [inst_sig_width+inst_exp_width:0] inImage3 [0:35];

reg [inst_sig_width+inst_exp_width:0] inKernel1[0:35];
reg [inst_sig_width+inst_exp_width:0] inKernel2[0:35];
reg [inst_sig_width+inst_exp_width:0] inKernel3[0:35];

reg [inst_sig_width+inst_exp_width:0] Output[0:63];

reg [inst_sig_width+inst_exp_width:0] mult_temp_save[0:47];

reg [5:0] laod_counter;
reg [5:0] mult_counter;
reg [1:0] kernel_counter;
reg [5:0] out_counter;
reg out_flag;

// Use for designware
wire [inst_sig_width+inst_exp_width:0] one, z_one, zero;
assign one   = 32'b00111111100000000000000000000000;
assign z_one = 32'b00111101110011001100110011001101;
assign zero  = 32'b00000000000000000000000000000000;

reg [inst_sig_width+inst_exp_width:0] mult_a[0:8];
reg [inst_sig_width+inst_exp_width:0] mult_b[0:8];
reg [inst_sig_width+inst_exp_width:0] sum_a, sum_b, sum_c;
reg [inst_sig_width+inst_exp_width:0] acti_in;

wire [inst_sig_width+inst_exp_width:0] mult_out[0:8];
wire [inst_sig_width+inst_exp_width:0] sum_out[0:2];
wire [inst_sig_width+inst_exp_width:0] sum_out_out;
wire [inst_sig_width+inst_exp_width:0] exp_x, exp_nx;
wire [inst_sig_width+inst_exp_width:0] add_exp_nx, exp_x_sub_exp_nx;
wire [inst_sig_width+inst_exp_width:0] divide;
wire [inst_sig_width+inst_exp_width:0] ReLU_out;
//---------------------------------------------------------------------
//   IP
//---------------------------------------------------------------------
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M0 (.a(mult_a[0]), .b(mult_b[0]), .rnd(3'b000), .z(mult_out[0]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M1 (.a(mult_a[1]), .b(mult_b[1]), .rnd(3'b000), .z(mult_out[1]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M2 (.a(mult_a[2]), .b(mult_b[2]), .rnd(3'b000), .z(mult_out[2]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M3 (.a(mult_a[3]), .b(mult_b[3]), .rnd(3'b000), .z(mult_out[3]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M4 (.a(mult_a[4]), .b(mult_b[4]), .rnd(3'b000), .z(mult_out[4]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M5 (.a(mult_a[5]), .b(mult_b[5]), .rnd(3'b000), .z(mult_out[5]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M6 (.a(mult_a[6]), .b(mult_b[6]), .rnd(3'b000), .z(mult_out[6]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M7 (.a(mult_a[7]), .b(mult_b[7]), .rnd(3'b000), .z(mult_out[7]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M8 (.a(mult_a[8]), .b(mult_b[8]), .rnd(3'b000), .z(mult_out[8]));
DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S1 (.a(mult_out[0]), .b(mult_out[1]), .c(mult_out[2]), .d(mult_out[3]), .z(sum_out[0]), .rnd(3'b000));
DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S2 (.a( sum_out[0]), .b(mult_out[4]), .c(mult_out[5]), .d(mult_out[6]), .z(sum_out[1]), .rnd(3'b000));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S3 (.a( sum_out[1]), .b(mult_out[7]), .c(mult_out[8]), .z(sum_out[2]), .rnd(3'b000));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S4 (.a(sum_a), .b(sum_b), .c(sum_c), .z(sum_out_out), .rnd(3'b000));

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) EXPPX(.a(acti_in), .z(exp_x));
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) EXPNX(.a({~acti_in[31], acti_in[30:0]}), .z(exp_nx));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD(.a(((inOpt==2'b10)? one: exp_x)), .b(exp_nx), .rnd(3'b000), .z(add_exp_nx));
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) SUB(.a(exp_x), .b(exp_nx), .rnd(3'b000), .z(exp_x_sub_exp_nx));
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) DIV(.a(((inOpt==2'b10)? one: exp_x_sub_exp_nx)), .b(add_exp_nx), .z(divide), .rnd(3'b000));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ReLU (.a(acti_in), .b(z_one), .rnd(3'b000), .z(ReLU_out));
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

// Opt
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		inOpt <= 'd0;
	end	
	else if(in_valid_o)begin
		inOpt <= Opt; 
	end
		
end

// inImage
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		for(i=0; i<36; i=i+1)begin
			inImage1[i] <= 'b0;
			inImage2[i] <= 'b0;
			inImage3[i] <= 'b0;
		end
	end
	else if(in_valid_i)begin
		case (laod_counter)
			0: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[0] <= Image1;
					inImage2[0] <= Image2;
					inImage3[0] <= Image3;
					inImage1[1] <= Image1;
					inImage2[1] <= Image2;
					inImage3[1] <= Image3;
					inImage1[6] <= Image1;
					inImage2[6] <= Image2;
					inImage3[6] <= Image3;
				end
				inImage1[7] <= Image1; 
				inImage2[7] <= Image2; 
				inImage3[7] <= Image3; 
			end 
			1: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[2] <= Image1;
					inImage2[2] <= Image2;
					inImage3[2] <= Image3;
				end
				inImage1[8] <= Image1;
				inImage2[8] <= Image2;
				inImage3[8] <= Image3;
			end
			2: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[3] <= Image1;
					inImage2[3] <= Image2;
					inImage3[3] <= Image3;
				end
				inImage1[9] <= Image1;
				inImage2[9] <= Image2;
				inImage3[9] <= Image3;
			end
			3: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[4]  <= Image1;
					inImage2[4]  <= Image2;
					inImage3[4]  <= Image3;
					inImage1[5]  <= Image1;
					inImage2[5]  <= Image2;
					inImage3[5]  <= Image3;
					inImage1[11] <= Image1;
					inImage2[11] <= Image2;
					inImage3[11] <= Image3;
				end
				inImage1[10] <= Image1; 
				inImage2[10] <= Image2; 
				inImage3[10] <= Image3; 
			end 
			4: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[12] <= Image1;
					inImage2[12] <= Image2;
					inImage3[12] <= Image3;
				end
				inImage1[13] <= Image1;
				inImage2[13] <= Image2;
				inImage3[13] <= Image3;
			end
			5: begin
				inImage1[14] <= Image1;
				inImage2[14] <= Image2;
				inImage3[14] <= Image3;
			end
			6: begin
				inImage1[15] <= Image1;
				inImage2[15] <= Image2;
				inImage3[15] <= Image3;
			end
			7: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[17] <= Image1;
					inImage2[17] <= Image2;
					inImage3[17] <= Image3;
				end
				inImage1[16] <= Image1;
				inImage2[16] <= Image2;
				inImage3[16] <= Image3;
			end
			8: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[18] <= Image1;
					inImage2[18] <= Image2;
					inImage3[18] <= Image3;
				end
				inImage1[19] <= Image1;
				inImage2[19] <= Image2;
				inImage3[19] <= Image3;
			end
			9: begin
				inImage1[20] <= Image1;
				inImage2[20] <= Image2;
				inImage3[20] <= Image3;
			end
			10: begin
				inImage1[21] <= Image1;
				inImage2[21] <= Image2;
				inImage3[21] <= Image3;
			end
			11: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[23] <= Image1;
					inImage2[23] <= Image2;
					inImage3[23] <= Image3;
				end
				inImage1[22] <= Image1;
				inImage2[22] <= Image2;
				inImage3[22] <= Image3;
			end
			12: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[24] <= Image1;
					inImage2[24] <= Image2;
					inImage3[24] <= Image3;
					inImage1[30] <= Image1;
					inImage2[30] <= Image2;
					inImage3[30] <= Image3;
					inImage1[31] <= Image1;
					inImage2[31] <= Image2;
					inImage3[31] <= Image3;
				end
				inImage1[25] <= Image1;
				inImage2[25] <= Image2;
				inImage3[25] <= Image3;
			end
			13: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[32] <= Image1;
					inImage2[32] <= Image2;
					inImage3[32] <= Image3;
				end
				inImage1[26] <= Image1;
				inImage2[26] <= Image2;
				inImage3[26] <= Image3;
			end
			14: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[33] <= Image1;
					inImage2[33] <= Image2;
					inImage3[33] <= Image3;
				end
				inImage1[27] <= Image1;
				inImage2[27] <= Image2;
				inImage3[27] <= Image3;
			end
			15: begin
				if(inOpt[1] == 1'b0)begin
					inImage1[29] <= Image1;
					inImage2[29] <= Image2;
					inImage3[29] <= Image3;
					inImage1[34] <= Image1;
					inImage2[34] <= Image2;
					inImage3[34] <= Image3;
					inImage1[35] <= Image1;
					inImage2[35] <= Image2;
					inImage3[35] <= Image3;
				end
				inImage1[28] <= Image1;
				inImage2[28] <= Image2;
				inImage3[28] <= Image3;
			end		
		endcase
	end
	else if(in_valid_o)begin
		for(i=0; i<36; i=i+1)begin
			inImage1[i] <= 'b0;
			inImage2[i] <= 'b0;
			inImage3[i] <= 'b0;
		end
	end
end

// inKernel
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		for(i=0; i<36; i=i+1)begin
			inKernel1[i] <= 'b0;
			inKernel2[i] <= 'b0;
			inKernel3[i] <= 'b0;
		end
	end
	else if(in_valid_k)begin
		inKernel1[laod_counter] <= Kernel1; 
		inKernel2[laod_counter] <= Kernel2; 
		inKernel3[laod_counter] <= Kernel3; 
	end
end

// load counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) laod_counter <= 'd0;
	else if(in_valid_i || in_valid_k) laod_counter <= laod_counter + 'd1;
	else laod_counter <= 'd0;
end

// mult counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) mult_counter <= 'd0;
	else if(current_state == CAL && mult_counter < 'd48) mult_counter <= mult_counter + 'd1;
	else mult_counter <= 'd0;
end

// kernel counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) kernel_counter <= 'd0;
	else if(current_state == CAL) begin
		if( mult_counter == 'd48) kernel_counter <= kernel_counter + 'd1;
	end
	else kernel_counter <= 'd0;
end

// out counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) out_counter <= 'd0;
	else if(out_flag) begin
		out_counter <= out_counter + 'd1;
	end
	else out_counter <= 'd0;
end

// out flag
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) out_flag <= 'd0;
	else if(kernel_counter == 'd3 && mult_counter == 'd48) out_flag <= 'd1;
	else if(out_counter == 'd63) out_flag <= 'd0;
	else out_flag <= out_flag;
end

// mult_a
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mult_a[0] <= 'd0;
		mult_a[1] <= 'd0;
		mult_a[2] <= 'd0;
		mult_a[3] <= 'd0;
		mult_a[4] <= 'd0;
		mult_a[5] <= 'd0;
		mult_a[6] <= 'd0;
		mult_a[7] <= 'd0;
		mult_a[8] <= 'd0;
	end
	else if(current_state == CAL)begin
		case (mult_counter)
			0:begin
				mult_a[0] <= inImage1[ 0];
				mult_a[1] <= inImage1[ 1];
				mult_a[2] <= inImage1[ 2];
				mult_a[3] <= inImage1[ 6];
				mult_a[4] <= inImage1[ 7];
				mult_a[5] <= inImage1[ 8];
				mult_a[6] <= inImage1[12];
				mult_a[7] <= inImage1[13];
				mult_a[8] <= inImage1[14];
			end 
			1: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[ 3];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[ 9];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[15];
			end
			2: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[ 4];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[10];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[16];
			end
			3: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[ 5];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[11];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[17];
			end
			4:begin
				mult_a[0] <= inImage1[ 6];
				mult_a[1] <= inImage1[ 7];
				mult_a[2] <= inImage1[ 8];
				mult_a[3] <= inImage1[12];
				mult_a[4] <= inImage1[13];
				mult_a[5] <= inImage1[14];
				mult_a[6] <= inImage1[18];
				mult_a[7] <= inImage1[19];
				mult_a[8] <= inImage1[20];
			end
			5:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[ 9];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[15];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[21];
			end
			6:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[10];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[16];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[22];
			end
			7:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[11];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[17];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[23];
			end
			8:begin
				mult_a[0] <= inImage1[12];
				mult_a[1] <= inImage1[13];
				mult_a[2] <= inImage1[14];
				mult_a[3] <= inImage1[18];
				mult_a[4] <= inImage1[19];
				mult_a[5] <= inImage1[20];
				mult_a[6] <= inImage1[24];
				mult_a[7] <= inImage1[25];
				mult_a[8] <= inImage1[26];
			end
			9:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[15];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[21];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[27];
			end
			10:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[16];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[22];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[28];
			end
			11:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[17];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[23];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[29];
			end
			12:begin
				mult_a[0] <= inImage1[18];
				mult_a[1] <= inImage1[19];
				mult_a[2] <= inImage1[20];
				mult_a[3] <= inImage1[24];
				mult_a[4] <= inImage1[25];
				mult_a[5] <= inImage1[26];
				mult_a[6] <= inImage1[30];
				mult_a[7] <= inImage1[31];
				mult_a[8] <= inImage1[32];
			end
			13:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[21];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[27];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[33];
			end
			14:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[22];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[28];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[34];
			end
			15:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage1[23];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage1[29];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage1[35];
			end 
			16:begin
				mult_a[0] <= inImage2[ 0];
				mult_a[1] <= inImage2[ 1];
				mult_a[2] <= inImage2[ 2];
				mult_a[3] <= inImage2[ 6];
				mult_a[4] <= inImage2[ 7];
				mult_a[5] <= inImage2[ 8];
				mult_a[6] <= inImage2[12];
				mult_a[7] <= inImage2[13];
				mult_a[8] <= inImage2[14];
			end 
			17: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[ 3];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[ 9];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[15];
			end
			18: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[ 4];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[10];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[16];
			end
			19: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[ 5];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[11];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[17];
			end
			20:begin
				mult_a[0] <= inImage2[ 6];
				mult_a[1] <= inImage2[ 7];
				mult_a[2] <= inImage2[ 8];
				mult_a[3] <= inImage2[12];
				mult_a[4] <= inImage2[13];
				mult_a[5] <= inImage2[14];
				mult_a[6] <= inImage2[18];
				mult_a[7] <= inImage2[19];
				mult_a[8] <= inImage2[20];
			end
			21:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[ 9];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[15];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[21];
			end
			22:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[10];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[16];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[22];
			end
			23:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[11];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[17];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[23];
			end
			24:begin
				mult_a[0] <= inImage2[12];
				mult_a[1] <= inImage2[13];
				mult_a[2] <= inImage2[14];
				mult_a[3] <= inImage2[18];
				mult_a[4] <= inImage2[19];
				mult_a[5] <= inImage2[20];
				mult_a[6] <= inImage2[24];
				mult_a[7] <= inImage2[25];
				mult_a[8] <= inImage2[26];
			end
			25:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[15];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[21];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[27];
			end
			26:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[16];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[22];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[28];
			end
			27:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[17];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[23];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[29];
			end
			28:begin
				mult_a[0] <= inImage2[18];
				mult_a[1] <= inImage2[19];
				mult_a[2] <= inImage2[20];
				mult_a[3] <= inImage2[24];
				mult_a[4] <= inImage2[25];
				mult_a[5] <= inImage2[26];
				mult_a[6] <= inImage2[30];
				mult_a[7] <= inImage2[31];
				mult_a[8] <= inImage2[32];
			end
			29:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[21];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[27];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[33];
			end
			30:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[22];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[28];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[34];
			end
			31:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage2[23];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage2[29];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage2[35];
			end 
			32:begin
				mult_a[0] <= inImage3[ 0];
				mult_a[1] <= inImage3[ 1];
				mult_a[2] <= inImage3[ 2];
				mult_a[3] <= inImage3[ 6];
				mult_a[4] <= inImage3[ 7];
				mult_a[5] <= inImage3[ 8];
				mult_a[6] <= inImage3[12];
				mult_a[7] <= inImage3[13];
				mult_a[8] <= inImage3[14];
			end 
			33: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[ 3];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[ 9];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[15];
			end
			34: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[ 4];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[10];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[16];
			end
			35: begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[ 5];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[11];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[17];
			end
			36:begin
				mult_a[0] <= inImage3[ 6];
				mult_a[1] <= inImage3[ 7];
				mult_a[2] <= inImage3[ 8];
				mult_a[3] <= inImage3[12];
				mult_a[4] <= inImage3[13];
				mult_a[5] <= inImage3[14];
				mult_a[6] <= inImage3[18];
				mult_a[7] <= inImage3[19];
				mult_a[8] <= inImage3[20];
			end
			37:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[ 9];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[15];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[21];
			end
			38:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[10];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[16];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[22];
			end
			39:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[11];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[17];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[23];
			end
			40:begin
				mult_a[0] <= inImage3[12];
				mult_a[1] <= inImage3[13];
				mult_a[2] <= inImage3[14];
				mult_a[3] <= inImage3[18];
				mult_a[4] <= inImage3[19];
				mult_a[5] <= inImage3[20];
				mult_a[6] <= inImage3[24];
				mult_a[7] <= inImage3[25];
				mult_a[8] <= inImage3[26];
			end
			41:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[15];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[21];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[27];
			end
			42:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[16];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[22];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[28];
			end
			43:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[17];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[23];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[29];
			end
			44:begin
				mult_a[0] <= inImage3[18];
				mult_a[1] <= inImage3[19];
				mult_a[2] <= inImage3[20];
				mult_a[3] <= inImage3[24];
				mult_a[4] <= inImage3[25];
				mult_a[5] <= inImage3[26];
				mult_a[6] <= inImage3[30];
				mult_a[7] <= inImage3[31];
				mult_a[8] <= inImage3[32];
			end
			45:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[21];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[27];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[33];
			end
			46:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[22];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[28];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[34];
			end
			47:begin
				mult_a[0] <= mult_a[1];
				mult_a[1] <= mult_a[2];
				mult_a[2] <= inImage3[23];
				mult_a[3] <= mult_a[4];
				mult_a[4] <= mult_a[5];
				mult_a[5] <= inImage3[29];
				mult_a[6] <= mult_a[7];
				mult_a[7] <= mult_a[8];
				mult_a[8] <= inImage3[35];
			end 
		endcase
	end
end

// mult_b
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mult_b[0] <= 'd0;
		mult_b[1] <= 'd0;
		mult_b[2] <= 'd0;
		mult_b[3] <= 'd0;
		mult_b[4] <= 'd0;
		mult_b[5] <= 'd0;
		mult_b[6] <= 'd0;
		mult_b[7] <= 'd0;
		mult_b[8] <= 'd0;
	end
	else if(current_state == CAL)begin
		if(mult_counter < 'd16 && kernel_counter == 'd0)begin
			mult_b[0] <= inKernel1[0];
			mult_b[1] <= inKernel1[1];
			mult_b[2] <= inKernel1[2];
			mult_b[3] <= inKernel1[3];
			mult_b[4] <= inKernel1[4];
			mult_b[5] <= inKernel1[5];
			mult_b[6] <= inKernel1[6];
			mult_b[7] <= inKernel1[7];
			mult_b[8] <= inKernel1[8];
		end
		else if(mult_counter < 'd32 && kernel_counter == 'd0)begin
			mult_b[0] <= inKernel2[0];
			mult_b[1] <= inKernel2[1];
			mult_b[2] <= inKernel2[2];
			mult_b[3] <= inKernel2[3];
			mult_b[4] <= inKernel2[4];
			mult_b[5] <= inKernel2[5];
			mult_b[6] <= inKernel2[6];
			mult_b[7] <= inKernel2[7];
			mult_b[8] <= inKernel2[8];
		end
		else if(mult_counter < 'd48 && kernel_counter == 'd0)begin
			mult_b[0] <= inKernel3[0];
			mult_b[1] <= inKernel3[1];
			mult_b[2] <= inKernel3[2];
			mult_b[3] <= inKernel3[3];
			mult_b[4] <= inKernel3[4];
			mult_b[5] <= inKernel3[5];
			mult_b[6] <= inKernel3[6];
			mult_b[7] <= inKernel3[7];
			mult_b[8] <= inKernel3[8];
		end
		else if(mult_counter < 'd16 && kernel_counter == 'd1)begin
			mult_b[0] <= inKernel1[ 9];
			mult_b[1] <= inKernel1[10];
			mult_b[2] <= inKernel1[11];
			mult_b[3] <= inKernel1[12];
			mult_b[4] <= inKernel1[13];
			mult_b[5] <= inKernel1[14];
			mult_b[6] <= inKernel1[15];
			mult_b[7] <= inKernel1[16];
			mult_b[8] <= inKernel1[17];
		end
		else if(mult_counter < 'd32 && kernel_counter == 'd1)begin
			mult_b[0] <= inKernel2[ 9];
			mult_b[1] <= inKernel2[10];
			mult_b[2] <= inKernel2[11];
			mult_b[3] <= inKernel2[12];
			mult_b[4] <= inKernel2[13];
			mult_b[5] <= inKernel2[14];
			mult_b[6] <= inKernel2[15];
			mult_b[7] <= inKernel2[16];
			mult_b[8] <= inKernel2[17];
		end
		else if(mult_counter < 'd48 && kernel_counter == 'd1)begin
			mult_b[0] <= inKernel3[ 9];
			mult_b[1] <= inKernel3[10];
			mult_b[2] <= inKernel3[11];
			mult_b[3] <= inKernel3[12];
			mult_b[4] <= inKernel3[13];
			mult_b[5] <= inKernel3[14];
			mult_b[6] <= inKernel3[15];
			mult_b[7] <= inKernel3[16];
			mult_b[8] <= inKernel3[17];
		end
		else if(mult_counter < 'd16 && kernel_counter == 'd2)begin
			mult_b[0] <= inKernel1[18];
			mult_b[1] <= inKernel1[19];
			mult_b[2] <= inKernel1[20];
			mult_b[3] <= inKernel1[21];
			mult_b[4] <= inKernel1[22];
			mult_b[5] <= inKernel1[23];
			mult_b[6] <= inKernel1[24];
			mult_b[7] <= inKernel1[25];
			mult_b[8] <= inKernel1[26];
		end
		else if(mult_counter < 'd32 && kernel_counter == 'd2)begin
			mult_b[0] <= inKernel2[18];
			mult_b[1] <= inKernel2[19];
			mult_b[2] <= inKernel2[20];
			mult_b[3] <= inKernel2[21];
			mult_b[4] <= inKernel2[22];
			mult_b[5] <= inKernel2[23];
			mult_b[6] <= inKernel2[24];
			mult_b[7] <= inKernel2[25];
			mult_b[8] <= inKernel2[26];
		end
		else if(mult_counter < 'd48 && kernel_counter == 'd2)begin
			mult_b[0] <= inKernel3[18];
			mult_b[1] <= inKernel3[19];
			mult_b[2] <= inKernel3[20];
			mult_b[3] <= inKernel3[21];
			mult_b[4] <= inKernel3[22];
			mult_b[5] <= inKernel3[23];
			mult_b[6] <= inKernel3[24];
			mult_b[7] <= inKernel3[25];
			mult_b[8] <= inKernel3[26];
		end
		else if(mult_counter < 'd16 && kernel_counter == 'd3)begin
			mult_b[0] <= inKernel1[27];
			mult_b[1] <= inKernel1[28];
			mult_b[2] <= inKernel1[29];
			mult_b[3] <= inKernel1[30];
			mult_b[4] <= inKernel1[31];
			mult_b[5] <= inKernel1[32];
			mult_b[6] <= inKernel1[33];
			mult_b[7] <= inKernel1[34];
			mult_b[8] <= inKernel1[35];
		end
		else if(mult_counter < 'd32 && kernel_counter == 'd3)begin
			mult_b[0] <= inKernel2[27];
			mult_b[1] <= inKernel2[28];
			mult_b[2] <= inKernel2[29];
			mult_b[3] <= inKernel2[30];
			mult_b[4] <= inKernel2[31];
			mult_b[5] <= inKernel2[32];
			mult_b[6] <= inKernel2[33];
			mult_b[7] <= inKernel2[34];
			mult_b[8] <= inKernel2[35];
		end
		else if(mult_counter < 'd48 && kernel_counter == 'd3)begin
			mult_b[0] <= inKernel3[27];
			mult_b[1] <= inKernel3[28];
			mult_b[2] <= inKernel3[29];
			mult_b[3] <= inKernel3[30];
			mult_b[4] <= inKernel3[31];
			mult_b[5] <= inKernel3[32];
			mult_b[6] <= inKernel3[33];
			mult_b[7] <= inKernel3[34];
			mult_b[8] <= inKernel3[35];
		end
	end
end

// mult_temp_save
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<48; i=i+1)begin
			mult_temp_save[i] <= 'b0;
		end
	end
	else if(current_state == CAL && mult_counter > 'd0 )begin
		mult_temp_save[mult_counter - 'd1] <= sum_out[2];
	end
end

// sum a b c
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		sum_a <= 'd0;
		sum_b <= 'd0;
		sum_c <= 'd0;
	end 
	else if(current_state == CAL && !in_valid_k && mult_counter < 'd16) begin
		sum_a <= mult_temp_save[mult_counter];
		sum_b <= mult_temp_save[mult_counter + 'd16];
		sum_c <= mult_temp_save[mult_counter + 'd32];
	end
	else begin
		sum_a <= 'd0;
		sum_b <= 'd0;
		sum_c <= 'd0;
	end
end

// Output reg
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<64; i=i+1) begin
			Output[i] <= 'd0;
		end
	end 
	else if(mult_counter > 'd1 && mult_counter < 'd18 && !in_valid_k) begin
		if(inOpt == 2'b00)begin
			case (kernel_counter)
				'd0: begin
					if(acti_in[31]) Output[mult_counter + 'd46] <= 32'b0;
					else Output[mult_counter + 'd46] <= acti_in;
				end 
				'd1: begin
					if(acti_in[31]) Output[mult_counter - 'd2] <= 32'b0;
					else Output[mult_counter - 'd2] <= acti_in;
				end
				'd2:begin
					if(acti_in[31]) Output[mult_counter + 'd14] <= 32'b0;
					else Output[mult_counter + 'd14] <= acti_in;
				end 
				'd3: begin
					if(acti_in[31]) Output[mult_counter + 'd30] <= 32'b0;
					else Output[mult_counter + 'd30] <= acti_in;
				end
			endcase
		end
		else if(inOpt == 2'b01)begin
			case (kernel_counter)
				'd0: begin
					if(acti_in[31]) Output[mult_counter + 'd46] <= ReLU_out;
					else Output[mult_counter + 'd46] <= acti_in;
				end 
				'd1: begin
					if(acti_in[31]) Output[mult_counter - 'd2] <= ReLU_out;
					else Output[mult_counter - 'd2] <= acti_in;
				end
				'd2:begin
					if(acti_in[31]) Output[mult_counter + 'd14] <= ReLU_out;
					else Output[mult_counter + 'd14] <= acti_in;
				end 
				'd3: begin
					if(acti_in[31]) Output[mult_counter + 'd30] <= ReLU_out;
					else Output[mult_counter + 'd30] <= acti_in;
				end
			endcase
		end
		else if(inOpt == 2'b10)begin
			case (kernel_counter)
				'd0: begin
					Output[mult_counter + 'd46] <= divide;
				end 
				'd1: begin
					Output[mult_counter - 'd2] <= divide;
				end
				'd2:begin
					Output[mult_counter + 'd14] <= divide;
				end 
				'd3: begin
					Output[mult_counter + 'd30] <= divide;
				end
			endcase
		end
		else if(inOpt == 2'b11)begin
			case (kernel_counter)
				'd0: begin
					Output[mult_counter + 'd46] <= divide;
				end 
				'd1: begin
					Output[mult_counter - 'd2] <= divide;
				end
				'd2:begin
					Output[mult_counter + 'd14] <= divide;
				end 
				'd3: begin
					Output[mult_counter + 'd30] <= divide;
				end
			endcase
		end
	end
end

// Activation input
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		acti_in <= 'd0;
	end 
	else if(mult_counter > 'd0 && mult_counter < 'd17 && !in_valid_k) begin
		acti_in <= sum_out_out;
	end
end
//---------------------------------------------------------------------
//   Finite State Machine
//---------------------------------------------------------------------
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
            IDLE  : next_state = (!in_valid_o)? IDLE : LOAD;
			LOAD  : next_state = (laod_counter == 'd8 && in_valid_k)? CAL:LOAD;
			CAL   : next_state = (out_counter == 'd63)? IDLE:CAL;
			default: next_state = IDLE;
        endcase
    end
end

// Output Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out <= 32'b0;
	else if(out_flag) begin
		case (out_counter)
			0 : out <= Output[ 0];
			1 : out <= Output[16];
			2 : out <= Output[ 1];
			3 : out <= Output[17];
			4 : out <= Output[ 2];
			5 : out <= Output[18];
			6 : out <= Output[ 3];
			7 : out <= Output[19]; 
			8 : out <= Output[32];
			9 : out <= Output[48];
			10: out <= Output[33];
			11: out <= Output[49];
			12: out <= Output[34];
			13: out <= Output[50];
			14: out <= Output[35];
			15: out <= Output[51];
			16: out <= Output[ 4];
			17: out <= Output[20];
			18: out <= Output[ 5];
			19: out <= Output[21];
			20: out <= Output[ 6];
			21: out <= Output[22];
			22: out <= Output[ 7];
			23: out <= Output[23];  
			24: out <= Output[36];
			25: out <= Output[52];
			26: out <= Output[37];
			27: out <= Output[53];
			28: out <= Output[38];
			29: out <= Output[54];
			30: out <= Output[39];
			31: out <= Output[55];
			32: out <= Output[ 8];
			33: out <= Output[24];
			34: out <= Output[ 9];
			35: out <= Output[25];
			36: out <= Output[10];
			37: out <= Output[26];
			38: out <= Output[11];
			39: out <= Output[27];
			40: out <= Output[40];
			41: out <= Output[56];
			42: out <= Output[41];
			43: out <= Output[57];
			44: out <= Output[42];
			45: out <= Output[58];
			46: out <= Output[43];
			47: out <= Output[59];
			48: out <= Output[12];
			49: out <= Output[28];
			50: out <= Output[13];
			51: out <= Output[29];
			52: out <= Output[14];
			53: out <= Output[30];
			54: out <= Output[15];
			55: out <= Output[31];
			56: out <= Output[44];
			57: out <= Output[60];
			58: out <= Output[45];
			59: out <= Output[61];
			60: out <= Output[46];
			61: out <= Output[62];
			62: out <= Output[47];
			63: out <= Output[63];
		endcase
	end
	else out <= 32'b0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_valid <= 'd0;
	else if(out_flag) out_valid <= 'd1;
	else out_valid <= 'd0; 
end

endmodule