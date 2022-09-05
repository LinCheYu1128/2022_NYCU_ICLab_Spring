module	CORDIC (
	input	wire				clk, rst_n, in_valid,
	input	wire	signed	[11:0]	in_x, in_y,
	output	reg		[11:0]	out_mag,
	output	reg		[20:0]	out_phase,
	output	reg					out_valid

	);

// input_x and input_y -> 1'b sign , 3'b int , 8'b fraction
// out_mag -> 4b int , 8'b fraction
// output -> 1'b int , 20'b fraction 
wire	[20:0]	cordic_angle [0:17];
wire    [14:0]	Constant;
wire    [20:0]	one, one_five, zero_five;

//cordic angle -> 1'b int, 20'b fraciton
assign   cordic_angle[ 0] = 21'h04_0000; //  45        deg
assign   cordic_angle[ 1] = 21'h02_5c81; //  26.565051 deg
assign   cordic_angle[ 2] = 21'h01_3f67; //  14.036243 deg
assign   cordic_angle[ 3] = 21'h00_a222; //   7.125016 deg
assign   cordic_angle[ 4] = 21'h00_5162; //   3.576334 deg
assign   cordic_angle[ 5] = 21'h00_28bb; //   1.789911 deg
assign   cordic_angle[ 6] = 21'h00_145f; //   0.895174 deg
assign   cordic_angle[ 7] = 21'h00_0a30; //   0.447614 deg
assign   cordic_angle[ 8] = 21'h00_0518; //   0.223811 deg
assign   cordic_angle[ 9] = 21'h00_028b; //   0.111906 deg
assign   cordic_angle[10] = 21'h00_0146; //   0.055953 deg
assign   cordic_angle[11] = 21'h00_00a3; //   0.027976 deg
assign   cordic_angle[12] = 21'h00_0051; //   0.013988 deg
assign   cordic_angle[13] = 21'h00_0029; //   0.006994 deg
assign   cordic_angle[14] = 21'h00_0014; //   0.003497 deg
assign   cordic_angle[15] = 21'h00_000a; //   0.001749 deg
assign   cordic_angle[16] = 21'h00_0005; //   0.000874 deg
assign   cordic_angle[17] = 21'h00_0003; //   0.000437 deg
   
//Constant-> 1'b int, 14'b fraction
assign  Constant = {1'b0,14'b10_0110_1101_1101}; // 1/K = 0.6072387695
//Constant-> 1'b int, 20'b fraction
assign one       = {1'b1,20'b0000_0000_0000_0000_0000}; // 1
assign one_five  = {1'b1,20'b1000_0000_0000_0000_0000};
assign zero_five = {1'b0,20'b1000_0000_0000_0000_0000};
// assign one = 21'h10_0000;

parameter IDLE = 3'b000;// 0
parameter LOAD = 3'b001;// 1
parameter CAL  = 3'b010;// 2
parameter OUT  = 3'b011;// 3
reg [2:0] current_state, next_state;

reg [9:0] in_number;
reg [9:0] counter;
reg [4:0] step;
reg outflag, wait_flag;

reg [20:0] z;
reg signed[21:0] x;
reg signed[21:0] y;
wire [27:0] mag;
// assign mag = (x[21:9]+x[8])*Constant;
assign mag = (x[18:6]+x[5])*Constant;
reg MEM_wen;
reg [9:0] MEM_addr;
reg [11:0] MEMx_in;
wire [11:0] MEMx_out;
reg [20:0] MEMy_in;
wire [20:0] MEMy_out;

//12bits * 1024 SRAM
RA1SH_12 MEM_12(
   .Q(MEMx_out),
   .CLK(clk),
   .CEN(1'b0),
   .WEN(MEM_wen),
   .A(MEM_addr),
   .D(MEMx_in),
   .OEN(1'b0)
);
//21bits * 1024 SRAM
RA1SH_21 MEM_21(
   .Q(MEMy_out),
   .CLK(clk),
   .CEN(1'b0),
   .WEN(MEM_wen),
   .A(MEM_addr),
   .D(MEMy_in),
   .OEN(1'b0)
);

// MEM
always @(*)begin
	if(in_valid) MEM_addr = in_number;
	else if(current_state == CAL) MEM_addr = counter;
	else if(outflag)begin
		MEM_addr = counter;
	end
	else MEM_addr = 'd0;
end
always @(*) begin
	if(in_valid) MEM_wen = 'd0;
	else if(step == 'd21) MEM_wen = 'd0;
	else if(outflag) MEM_wen = 'b1;
	else MEM_wen = 'd1;
end
always @(*) begin
	if(in_valid) MEMx_in = {in_x};
	else if(step == 'd21) MEMx_in = mag[25:14] + mag[13];
	else MEMx_in = 'd0;
end
always @(*) begin
	if(in_valid) MEMy_in = {9'b0,in_y};
	else if(step == 'd21) MEMy_in = z;
	else MEMy_in = 'd0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) step <= 0;
	else if(current_state == CAL)begin
		if(step == 'd21) step <= 0;
		else step <= step + 1;
	end
	else step <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) counter <= 0;
	else if(current_state == CAL && step == 'd21) counter <= (outflag)?0:counter + 1;
	else if(current_state == OUT) counter <= counter + 1;
	else if(current_state == IDLE) counter <= 0;
	
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) in_number <= 0;
	else if(in_valid) in_number <= in_number + 1;
	else if(current_state == IDLE) in_number <= 0;
end

// outflag
always @(*) begin
	if (!rst_n) outflag = 0;
	else if(current_state == CAL && counter == in_number-1 && step == 'd21) outflag = 1;
	else if(current_state == OUT)begin
		if(counter == in_number) outflag = 0;
		else outflag = 1;
	end
	else outflag = 0;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) wait_flag <= 0;
	else if(current_state == OUT) wait_flag <= 1;
	else wait_flag <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		x <= 0;
		y <= 0;
		z <= 0;
	end
	else if(current_state == CAL)begin
		case(step)
			0:begin
				x <= 0;
				y <= 0;
				z <= 0;
			end
			1:begin
				x <= {{4{MEMx_out[11]}}, MEMx_out, 6'b0};
				y <= {{4{MEMy_out[11]}}, MEMy_out[11:0], 6'b0};
				z <= 0;
			end
			2:begin
				if(x[21] && y[21])begin //III
					x <= -x;
					y <= -y;
					z <= one;
				end
				else if(x[21])begin // II
					x <= y;
					y <= -x;
					z <= zero_five;
				end
				else if(y[21])begin // IV
					x <= -y;
					y <= x;
					z <= one_five;
				end
				else begin
					x <= x;
					y <= y;
					z <= 0;
				end
			end
			3:begin
				if(y[21])begin
					x <= x - y;
					y <= y + x;
					z <= z - cordic_angle[0];
				end
				else begin
					x <= x + y;
					y <= y - x;
					z <= z + cordic_angle[0];
				end
			end
			21:begin
				x <= x;
				y <= y;
				z <= z;
			end
			default: begin
				if(y[21])begin
					x <= x - (y>>>(step-3));
					y <= y + (x>>>(step-3));
					z <= z - cordic_angle[step-3];
				end
				else begin
					x <= x + (y>>>(step-3));
					y <= y - (x>>>(step-3));
					z <= z + cordic_angle[step-3];
				end
			end
		endcase
	end 
	else begin
		x <= 0;
		y <= 0;
		z <= 0;
	end
end
// 
// 

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
        CAL  : next_state = (outflag)? OUT: CAL;
        OUT  : next_state = (outflag)? OUT: IDLE;
        default: next_state = IDLE;
        endcase
    end
end

// Output Assignment
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid   <= 'd0 ;
		out_mag     <= 'd0 ;
		out_phase   <= 'd0 ;
	end
	else if(current_state == OUT && wait_flag) begin 
		out_valid   <= 'd1 ;
		out_mag     <= MEMx_out ;
		out_phase   <= MEMy_out ;
		// $display("mag   = %b", MEMx_out);
		// $display("phase = %b", MEMy_out);
		// $display("");
	end 
	else begin
		out_valid   <= 'd0 ;
		out_mag     <= 'd0 ;
		out_phase   <= 'd0 ;
	end
end
endmodule
// 3:begin
// 				if(y[12])begin
// 					x <= x - (y>>>1);
// 					y <= y + (x>>>1);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>1);
// 					y <= y - (x>>>1);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			4:begin
// 				if(y[12])begin
// 					x <= x - (y>>>2);
// 					y <= y + (x>>>2);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>2);
// 					y <= y - (x>>>2);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			5:begin
// 				if(y[12])begin
// 					x <= x - (y>>>3);
// 					y <= y + (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>3);
// 					y <= y - (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			6:begin
// 				if(y[12])begin
// 					x <= x - (y>>>4);
// 					y <= y + (x>>>4);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>4);
// 					y <= y - (x>>>4);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			7:begin
// 				if(y[12])begin
// 					x <= x - (y>>>5);
// 					y <= y + (x>>>5);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>5);
// 					y <= y - (x>>>5);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			8:begin
// 				if(y[12])begin
// 					x <= x - (y>>>6);
// 					y <= y + (x>>>6);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>6);
// 					y <= y - (x>>>6);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			9:begin
// 				if(y[12])begin
// 					x <= x - (y>>>7);
// 					y <= y + (x>>>7);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>7);
// 					y <= y - (x>>>7);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			10:begin
// 				if(y[12])begin
// 					x <= x - (y>>>8);
// 					y <= y + (x>>>8);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>8);
// 					y <= y - (x>>>8);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			11:begin
// 				if(y[12])begin
// 					x <= x - (y>>>9);
// 					y <= y + (x>>>9);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>9);
// 					y <= y - (x>>>9);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			12:begin
// 				if(y[12])begin
// 					x <= x - (y>>>10);
// 					y <= y + (x>>>10);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>10);
// 					y <= y - (x>>>10);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			13:begin
// 				if(y[12])begin
// 					x <= x - (y>>>3);
// 					y <= y + (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>3);
// 					y <= y - (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			14:begin
// 				if(y[12])begin
// 					x <= x - (y>>>3);
// 					y <= y + (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>3);
// 					y <= y - (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			15:begin
// 				if(y[12])begin
// 					x <= x - (y>>>3);
// 					y <= y + (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>3);
// 					y <= y - (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
// 			16:begin
// 				if(y[12])begin
// 					x <= x - (y>>>3);
// 					y <= y + (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 				else begin
// 					x <= x + (y>>>3);
// 					y <= y - (x>>>3);
// 					z <= z - cordic_angle[ 1];
// 				end
// 			end
