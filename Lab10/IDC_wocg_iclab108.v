module IDC(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_data,
	op,
	// Output signals
	out_valid,
	out_data
);


// INPUT AND OUTPUT DECLARATION  
input		clk;
input		rst_n;
input		in_valid;
input signed [6:0] in_data;
input [3:0] op;

output reg 		  out_valid;//
output reg  signed [6:0] out_data;

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
reg [3:0] current_state, next_state;
parameter IDLE    = 4'd0;
parameter LOAD    = 4'd1;
parameter GET_IMG = 4'd2;
parameter MID     = 4'd3;
parameter AVG     = 4'd4;
parameter ROT     = 4'd5;
parameter FLIP    = 4'd6;
parameter SHIFT   = 4'd7;
parameter GET_ANS = 4'd8;
parameter WB      = 4'd9;
parameter OUT     = 4'd10;
integer k, l;
genvar i, j;
//---------------------------------------------------------------------
//   WIRE AND REGISTER DECLARATION
//---------------------------------------------------------------------
reg [3:0] operation_reg[0:14];
reg signed [6:0] image_reg[0:7][0:7];
reg signed [6:0] img_region[0:3];
reg [2:0] x_counter, y_counter;
reg [3:0] counter;
reg reg_en [0:7][0:7];

wire signed [6:0] img_rot[0:3], img_mid, img_avg, img_flip[0:3];
reg [6:0] ttout_data;

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

Midpoint Midpoint_m( .clk(clk), .rst_n(rst_n), .in_0(img_region[0]), .in_1(img_region[1]), .in_2(img_region[2]), .in_3(img_region[3]), 
					 .out_0(img_mid));

Average Average_m( .clk(clk), .rst_n(rst_n), .in_0(img_region[0]), .in_1(img_region[1]), .in_2(img_region[2]), .in_3(img_region[3]), 
					 .out_0(img_avg));

Rotate Rotate_m( .clk(clk), .rst_n(rst_n), .in_0(img_region[0]), .in_1(img_region[1]), .in_2(img_region[2]), .in_3(img_region[3]), .mode(operation_reg[0][0]), 
					 .out_0(img_rot[0]), .out_1(img_rot[1]), .out_2(img_rot[2]), .out_3(img_rot[3]));

Flip Flip_m( .clk(clk), .rst_n(rst_n), .in_0(img_region[0]), .in_1(img_region[1]), .in_2(img_region[2]), .in_3(img_region[3]), 
					 .out_0(img_flip[0]), .out_1(img_flip[1]), .out_2(img_flip[2]), .out_3(img_flip[3]));

// reg enable
    /* always @(*) begin
		// if(!rst_n)begin
		// 	for(k = 0; k < 8; k = k + 1)begin
		// 		for(l = 0; l < 8; l = l + 1)begin
		// 			reg_en[k][l] <= 0;
		// 		end
		// 	end
		// end
		// else begin
			for(k = 0; k < 8; k = k + 1)begin
				for(l = 0; l < 8; l = l + 1)begin
					if((x_counter   == l && y_counter   == k) || 
					   (x_counter+1 == l && y_counter   == k) ||
					   (x_counter   == l && y_counter+1 == k) ||
					   (x_counter+1 == l && y_counter+1 == k) ) begin
						   reg_en[k][l] = 1;
						end
					else reg_en[k][l] = 0;
				end
			end
		// end
	end*/

// image data
generate
for(i = 0; i < 8; i = i + 1)begin
	for(j = 0; j < 8; j = j + 1)begin
		if(i == 7 && j == 7)begin
			always @(posedge clk or negedge rst_n) begin
				if (!rst_n) image_reg[i][j] <= 0;
				else if(next_state == LOAD) image_reg[i][j] <= in_data;
				else if(current_state == WB)begin
					if(x_counter == j && y_counter == i)begin
						image_reg[i][j] <= img_region[0];
					end
					else if(x_counter+1 == j && y_counter == i)begin
						image_reg[i][j] <= img_region[1];
					end
					else if(x_counter == j && y_counter+1 == i)begin
						image_reg[i][j] <= img_region[2];
					end
					else if(x_counter+1 == j && y_counter+1 == i)begin
						image_reg[i][j] <= img_region[3];
					end
				end
				else if(current_state == IDLE) image_reg[i][j] <= 0;
			end
		end else begin
			always @(posedge clk or negedge rst_n) begin
				if (!rst_n) image_reg[i][j] <= 0;
				else if(next_state == LOAD) image_reg[i][j] <= image_reg[i + (j == 7)][(j + 1) % 8];
				else if(current_state == WB)begin
					if(x_counter == j && y_counter == i)begin
						image_reg[i][j] <= img_region[0];
					end
					else if(x_counter+1 == j && y_counter == i)begin
						image_reg[i][j] <= img_region[1];
					end
					else if(x_counter == j && y_counter+1 == i)begin
						image_reg[i][j] <= img_region[2];
					end
					else if(x_counter+1 == j && y_counter+1 == i)begin
						image_reg[i][j] <= img_region[3];
					end
				end
				else if(current_state == IDLE) image_reg[i][j] <= 0;
			end
		end
	end
end
endgenerate

// operation data
generate
for(i = 0; i < 15; i = i + 1)begin
	if(i==14)begin
		always @(posedge clk or negedge rst_n) begin
			if (!rst_n)       operation_reg[i] <= 0;
			else if(next_state == LOAD) operation_reg[i] <= (counter<15)? op: operation_reg[i];
			else if(current_state == SHIFT || current_state == GET_ANS) operation_reg[i] <= 0;
			else if(current_state == IDLE) operation_reg[i] <= 0;
		end
	end else begin
		always @(posedge clk or negedge rst_n) begin
			if (!rst_n) operation_reg[i] <= 0;
			else if(next_state == LOAD) operation_reg[i] <= (counter<15)? operation_reg[i+1]: operation_reg[i];
			else if(current_state == SHIFT || current_state == GET_ANS) operation_reg[i] <= operation_reg[i+1];
			else if(current_state == IDLE) operation_reg[i] <= 0;
		end
	end
end
endgenerate

// image region
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		img_region[0] <= 0;
		img_region[1] <= 0;
		img_region[2] <= 0;
		img_region[3] <= 0;
	end
	else begin
		if(current_state == GET_IMG)begin
			img_region[0] <= image_reg[y_counter  ][x_counter  ];
			img_region[1] <= image_reg[y_counter  ][x_counter+1];
			img_region[2] <= image_reg[y_counter+1][x_counter  ];
			img_region[3] <= image_reg[y_counter+1][x_counter+1];
		end
		else if(current_state == GET_ANS)begin
			case (operation_reg[0])
				0:begin
					img_region[0] <= img_mid;
					img_region[1] <= img_mid;
					img_region[2] <= img_mid;
					img_region[3] <= img_mid;
				end 
				1:begin
					img_region[0] <= img_avg;
					img_region[1] <= img_avg;
					img_region[2] <= img_avg;
					img_region[3] <= img_avg;
				end
				2:begin
					img_region[0] <= img_rot[0];
					img_region[1] <= img_rot[1];
					img_region[2] <= img_rot[2];
					img_region[3] <= img_rot[3];
				end
				3:begin
					img_region[0] <= img_rot[0];
					img_region[1] <= img_rot[1];
					img_region[2] <= img_rot[2];
					img_region[3] <= img_rot[3];
				end
				4:begin
					img_region[0] <= img_flip[0];
					img_region[1] <= img_flip[1];
					img_region[2] <= img_flip[2];
					img_region[3] <= img_flip[3];
				end
			endcase
		end
	end
end

// counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		counter <= 0;
	end
	else if(in_valid)begin
		counter <= (counter==15)? counter: counter + 1;
	end
	else begin
		case (current_state)
			IDLE    : counter <= 0;
			SHIFT   : counter <= counter - 1;
			GET_ANS : counter <= counter - 1;
			OUT     : counter <= counter + 1;
		endcase
	end
end

// position controll
always @(posedge clk) begin
	if(current_state == IDLE)begin
		x_counter <= 3;
		y_counter <= 3;
	end
	else if(current_state == SHIFT)begin
		case (operation_reg[0])
			5:begin
				x_counter <= x_counter;
				y_counter <= (y_counter == 0)? 0: y_counter - 1;
			end
			6:begin
				x_counter <= (x_counter == 0)? 0: x_counter - 1;
				y_counter <= y_counter;
			end
			7:begin
				x_counter <= x_counter;
				y_counter <= (y_counter == 6)? 6: y_counter + 1;
			end
			8: begin
				x_counter <= (x_counter == 6)? 6: x_counter + 1;
				y_counter <= y_counter;
			end
			default: begin
				x_counter <= x_counter;
				y_counter <= y_counter;
			end
		endcase
	end
end

//---------------------------------------------------------------------
//   FINITE STATE MACHINE
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
            IDLE : next_state = (in_valid)? LOAD: IDLE;
			LOAD : begin
				if(!in_valid)begin
					if(operation_reg[0]>4) next_state = SHIFT;
					else next_state = GET_IMG;
				end 
				else next_state = LOAD;
			end 
			GET_IMG: begin
				case(operation_reg[0])
				0: next_state = MID;
				1: next_state = AVG;
				2: next_state = ROT;
				3: next_state = ROT;
				4: next_state = FLIP;
				default: next_state = SHIFT;
				endcase
			end 
			MID    : next_state = GET_ANS;//(mid_wait == 3)? GET_ANS: MID;
			// CAL    : next_state = GET_ANS;
			AVG    : next_state = GET_ANS; 
			ROT    : next_state = GET_ANS;
			FLIP   : next_state = GET_ANS; 
			SHIFT  : next_state = (operation_reg[1]>4)? SHIFT: ((counter==1)? OUT: GET_IMG);
			GET_ANS: begin
				if(operation_reg[1]>4 || counter == 1) next_state = WB;
				else begin
					case(operation_reg[1])
					0: next_state = MID;
					1: next_state = AVG;
					2: next_state = ROT;
					3: next_state = ROT;
					default: next_state = FLIP;
					endcase
				end
			end
			WB     : next_state = (counter == 0)? OUT: SHIFT;
			OUT    : next_state = (counter == 15)? IDLE: OUT;
			default: next_state = IDLE;
        endcase
    end
end

// Output Logic
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) ttout_data    <= 'd0 ;
	else if(current_state == OUT)begin
		if(x_counter>=4 || y_counter>=4)begin
			case (counter)
				0 : ttout_data <= image_reg[0][0];
				1 : ttout_data <= image_reg[0][2];
				2 : ttout_data <= image_reg[0][4];
				3 : ttout_data <= image_reg[0][6];
				4 : ttout_data <= image_reg[2][0];
				5 : ttout_data <= image_reg[2][2];
				6 : ttout_data <= image_reg[2][4];
				7 : ttout_data <= image_reg[2][6];
				8 : ttout_data <= image_reg[4][0];
				9 : ttout_data <= image_reg[4][2];
				10: ttout_data <= image_reg[4][4];
				11: ttout_data <= image_reg[4][6];
				12: ttout_data <= image_reg[6][0];
				13: ttout_data <= image_reg[6][2];
				14: ttout_data <= image_reg[6][4];
				15: ttout_data <= image_reg[6][6];
			endcase
		end
		else begin
			case (counter)
				0 : ttout_data <= image_reg[y_counter+1][x_counter+1];
				1 : ttout_data <= image_reg[y_counter+1][x_counter+2];
				2 : ttout_data <= image_reg[y_counter+1][x_counter+3];
				3 : ttout_data <= image_reg[y_counter+1][x_counter+4];
				4 : ttout_data <= image_reg[y_counter+2][x_counter+1];
				5 : ttout_data <= image_reg[y_counter+2][x_counter+2];
				6 : ttout_data <= image_reg[y_counter+2][x_counter+3];
				7 : ttout_data <= image_reg[y_counter+2][x_counter+4];
				8 : ttout_data <= image_reg[y_counter+3][x_counter+1];
				9 : ttout_data <= image_reg[y_counter+3][x_counter+2];
				10: ttout_data <= image_reg[y_counter+3][x_counter+3];
				11: ttout_data <= image_reg[y_counter+3][x_counter+4];
				12: ttout_data <= image_reg[y_counter+4][x_counter+1];
				13: ttout_data <= image_reg[y_counter+4][x_counter+2];
				14: ttout_data <= image_reg[y_counter+4][x_counter+3];
				15: ttout_data <= image_reg[y_counter+4][x_counter+4];
			endcase
		end
	end
	// else ttout_data <= 'd0 ;
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) out_valid <= 'd0 ;
	else if(current_state == OUT) out_valid <= 'd1;
	else out_valid <= 'd0 ;
end

always @(*)begin
	if(out_valid) out_data = ttout_data;
	else out_data = 0;
end

endmodule // IDC

module Flip(
	clk, 
	rst_n, 
	in_0, in_1, in_2, in_3,
	out_0, out_1, out_2, out_3
	);
	input clk, rst_n;
	input signed [6:0] in_0, in_1, in_2, in_3;
	output reg signed[6:0] out_0, out_1, out_2, out_3;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			out_0 <= 0;
			out_1 <= 0;
			out_2 <= 0;
			out_3 <= 0;
		end 
		else begin 
			out_0 <= ~in_0 + 1;
			out_1 <= ~in_1 + 1;
			out_2 <= ~in_2 + 1;
			out_3 <= ~in_3 + 1;
		end 
	end
endmodule

module Rotate(
	clk, 
	rst_n, 
	in_0, in_1, in_2, in_3,
	mode,  // mode 0 for couterclockwise; mode 1 for clockwise
	out_0, out_1, out_2, out_3
	);
	input clk, rst_n;
	input mode;
	input signed [6:0] in_0, in_1, in_2, in_3;
	output reg signed[6:0] out_0, out_1, out_2, out_3;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			out_0 <= 0;
			out_1 <= 0;
			out_2 <= 0;
			out_3 <= 0;
		end 
		else begin 
			out_0 <= (mode)? in_2: in_1;
			out_1 <= (mode)? in_0: in_3;
			out_2 <= (mode)? in_3: in_0;
			out_3 <= (mode)? in_1: in_2;
		end 
	end
endmodule

module Average(
	clk, 
	rst_n, 
	in_0, in_1, in_2, in_3,  
	out_0//, out_1, out_2, out_3
	);
	input clk, rst_n;
	input signed [6:0] in_0, in_1, in_2, in_3;
	output reg signed[6:0] out_0;//, out_1, out_2, out_3;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			out_0 <= 0;
			// out_1 <= 0;
			// out_2 <= 0;
			// out_3 <= 0;
		end 
		else begin 
			out_0 <= (in_0 + in_1 + in_2 + in_3)/4;
			// out_1 <= (in_0 + in_1 + in_2 + in_3)/4;
			// out_2 <= (in_0 + in_1 + in_2 + in_3)/4;
			// out_3 <= (in_0 + in_1 + in_2 + in_3)/4;
		end 
	end
endmodule

module Midpoint(
	clk, 
	rst_n, 
	in_0, in_1, in_2, in_3,  
	out_0//, out_1, out_2, out_3
	);
	input clk, rst_n;
	input signed [6:0] in_0, in_1, in_2, in_3;
	output reg signed[6:0] out_0;//, out_1, out_2, out_3;

	wire signed [6:0] a[0:3], b[0:3];
	assign a[0] = (in_0 > in_1)? in_1: in_0;
	assign a[1] = (in_0 > in_1)? in_0: in_1;
	assign a[2] = (in_2 > in_3)? in_3: in_2;
	assign a[3] = (in_2 > in_3)? in_2: in_3;

	assign b[0] = (a[0] > a[2])? a[2]: a[0];
	assign b[1] = (a[0] > a[2])? a[0]: a[2];
	assign b[2] = (a[1] > a[3])? a[3]: a[1];
	assign b[3] = (a[1] > a[3])? a[1]: a[3];

	// always @(posedge clk or negedge rst_n) begin
	// 	if (!rst_n)begin
	// 		a[0] <= 0;
	// 		a[1] <= 0;
	// 		a[2] <= 0;
	// 		a[3] <= 0;
	// 	end 
	// 	else begin 
	// 		a[0] <= (in_0 > in_1)? in_1: in_0;
	// 		a[1] <= (in_0 > in_1)? in_0: in_1;
	// 		a[2] <= (in_2 > in_3)? in_3: in_2;
	// 		a[3] <= (in_2 > in_3)? in_2: in_3;
	// 	end 
	// end

	// always @(posedge clk or negedge rst_n) begin
	// 	if (!rst_n)begin
	// 		b[0] <= 0;
	// 		b[1] <= 0;
	// 		b[2] <= 0;
	// 		b[3] <= 0;
	// 	end 
	// 	else begin 
	// 		b[0] <= (a[0] > a[2])? a[2]: a[0];
	// 		b[1] <= (a[0] > a[2])? a[0]: a[2];
	// 		b[2] <= (a[1] > a[3])? a[3]: a[1];
	// 		b[3] <= (a[1] > a[3])? a[1]: a[3];
	// 	end 
	// end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			out_0 <= 0;
			// out_1 <= 0;
			// out_2 <= 0;
			// out_3 <= 0;
		end 
		else begin 
			out_0 <= (b[1] + b[2])/2;
			// out_1 <= (b[1] + b[2])/2;
			// out_2 <= (b[1] + b[2])/2;
			// out_3 <= (b[1] + b[2])/2;
		end 
	end

endmodule 