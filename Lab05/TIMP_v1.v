// irun TESTBED.v -define RTL -debug -f file_list.f -notimingchecks -incdir /usr/synthesis/dw/sim_ver
module TMIP(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid_2,
    image,
	img_size,
    template, 
    action,
	
// output signals
    out_valid,
    out_x,
    out_y,
    out_img_pos,
    out_value
);

input        clk, rst_n, in_valid, in_valid_2;
input [15:0] image, template;
input [4:0]  img_size;
input [2:0]  action;

output reg        out_valid;
output reg [3:0]  out_x, out_y; 
output reg [7:0]  out_img_pos;
output reg signed[39:0] out_value;

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
parameter IDLE     = 3'b000;
parameter LOAD_IMG = 3'b001;
parameter LOAD_ACT = 3'b010;
parameter STANDBY  = 3'b011;
parameter CAL      = 3'b101;
parameter OUT      = 3'b111;
integer i,j;

//---------------------------------------------------------------------
//   WIRE AND REGISTER DECLARATION
//---------------------------------------------------------------------
reg [2:0] current_state, next_state;

reg outflag, calflag;

reg [1:0] img_size_reg; // 'b00 for 4; 'b01 for 8; 'b10 for 16
reg [15:0] template_reg[0:8];
reg [2:0] action_reg[0:15];
reg [2:0] cur_action;
reg [3:0] row_counter_a, col_counter_a, row_counter_b, col_counter_b;
reg [2:0] flip_count;
reg [7:0] load_counter, terminate_counter;
//---------------------------------------------------------------------
//   MEMORY DECLARATION
//---------------------------------------------------------------------
reg MEM_wen;
reg [7:0] MEM_addr, addr_a, addr_b;
reg [39:0] MEM_in;
wire signed[39:0] MEM_out;
RAISH MEM( .Q(MEM_out), .CLK(clk), .CEN(1'b0), .WEN(MEM_wen), .A(MEM_addr), .D(MEM_in), .OEN(1'b0));

reg MEM_T_wen;
reg [3:0] MEM_T_addr;
reg [39:0] MEM_T_in;
wire signed[39:0] MEM_T_out;
RAISH_T MEM_T( .Q(MEM_T_out), .CLK(clk), .CEN(1'b0), .WEN(MEM_T_wen), .A(MEM_T_addr), .D(MEM_T_in), .OEN(1'b0));

// cross function
wire signed[39:0] ans;
reg signed[39:0] buffer[0:8];
// cross use TPU
assign ans = ((buffer[0]*template_reg[0]) + (buffer[1]*template_reg[1]) + (buffer[2]*template_reg[2])) +
			 ((buffer[3]*template_reg[3]) + (buffer[4]*template_reg[4]) + (buffer[5]*template_reg[5])) +
			 ((buffer[6]*template_reg[6]) + (buffer[7]*template_reg[7]) + (buffer[8]*template_reg[8]));

wire signed [39:0] zoom_1, zoom_2, zoom_3;
assign zoom_1 = buffer[0]/3;
assign zoom_2 = ((buffer[0]*2)/3) + 20;
assign zoom_3 = {buffer[0][39],buffer[0][39:1]};

wire signed [39:0] brightness;
assign brightness = (MEM_out/2) + 50;

wire signed[39:0] max_1, max_2, max_3;
assign max_1 = (buffer[0] > buffer[1])? buffer[0]: buffer[1];
assign max_2 = (buffer[2] > MEM_out)? buffer[2]: MEM_out;
assign max_3 = (max_1 > max_2)? max_1: max_2;
//---------------------------------------------------------------------
//   MEMORY CONTROL
//---------------------------------------------------------------------

always @(*) begin
	if(img_size_reg == 'b00)begin
		if(action_reg[0] == 'd6)begin
			addr_a = {2'b0, row_counter_a[2:0], col_counter_a[2:0]};
			addr_b = {2'b0, row_counter_b[2:0], col_counter_b[2:0]};
		end
		else begin
			addr_a = {4'b0, row_counter_a[1:0], col_counter_a[1:0]};
			addr_b = {4'b0, row_counter_b[1:0], col_counter_b[1:0]};
		end
	end
	else if(img_size_reg == 'b01)begin
		if(action_reg[0] == 'd6)begin
			addr_a = {row_counter_a, col_counter_a};
			addr_b = {row_counter_b, col_counter_b};
		end
		else begin
			addr_a = {2'b0, row_counter_a[2:0], col_counter_a[2:0]};
			addr_b = {2'b0, row_counter_b[2:0], col_counter_b[2:0]};
		end
	end
	else begin
		addr_a = {row_counter_a, col_counter_a};
		addr_b = {row_counter_b, col_counter_b};
	end
end

// mem_addr
always @(*) begin
	if(in_valid) MEM_addr = load_counter;
	else if(current_state == CAL)begin
		// For flip function
		// For cross function
		if(action_reg[0] == 3'd0)begin
			MEM_addr = addr_a;
		end
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			case (flip_count)
			0:  MEM_addr = addr_a;
			1:  MEM_addr = addr_b;
			2:  MEM_addr = addr_b;
			3:  MEM_addr = addr_a;
			default : MEM_addr = 'd0;
			endcase
		end
		// For MAX pooling function
		else if(action_reg[0] == 3'd1)begin
			if(flip_count == 'd4) MEM_addr = load_counter;
			else MEM_addr = addr_a;
		end
		// For xoom in function
		else if(action_reg[0] == 3'd6)begin
			if(flip_count == 'd0) MEM_addr = terminate_counter - load_counter;
			else MEM_addr = addr_a;
		end
		// For brightness function
		else if(action_reg[0] == 3'd7)begin
			MEM_addr = addr_a;
		end
		else MEM_addr = 'd0;
	end 
	else if(outflag)begin
		MEM_addr = load_counter;
	end
	else MEM_addr = 'd0;
end

// mem_in
always @(*) begin
	if(in_valid) begin
		MEM_in = {{24{image[15]}}, image};
	end
	else if(current_state == CAL)begin
		if(action_reg[0] == 'd0)begin
			MEM_in = ans;
		end
		else if(action_reg[0] == 3'd1)begin
			if(flip_count == 'd4) MEM_in = max_3;
			else MEM_in = 'd0;
		end
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			if(flip_count == 'd2) 
				MEM_in = buffer[0];
			else if(flip_count == 'd3) 
				MEM_in = buffer[1];
			else
				MEM_in = 'd0;
		end
		else if(action_reg[0] == 'd6)begin
			case (flip_count)
				1: MEM_in = MEM_out;
				2: MEM_in = zoom_2;
				3: MEM_in = zoom_1;
				4: MEM_in = zoom_3; 
				default: MEM_in = 'd0;
			endcase
		end
		else if(action_reg[0] == 'd7)begin
			if(flip_count == 'd1) MEM_in = brightness;
			else MEM_in = 'd0;
		end
		else begin
			MEM_in = 'd0;
		end 
	end
	else begin
		MEM_in = 'd0;
	end
end

// mem_wen
always @(*) begin
	if(in_valid)begin
		MEM_wen = 'd0;
	end
	else if(current_state == CAL)begin
		if(action_reg[0] == 'd0)begin
			if((img_size_reg == 'b00 && load_counter[1:0] == 2'b11) || 
			   (img_size_reg == 'b01 && load_counter[2:0] == 3'b111) ||
			   (img_size_reg == 'b10 && load_counter[3:0] == 4'b1111)) begin
				if(flip_count == 'd0) MEM_wen = 'd0;
				else MEM_wen = 'd1;   
			end
			else if((img_size_reg == 'b00 && load_counter[0] == 1'b0) || 
			        (img_size_reg == 'b01 && load_counter[1:0] == 1'b0) ||
			        (img_size_reg == 'b10 && load_counter[2:0] == 1'b0)) begin
			   if(flip_count == 'd5) MEM_wen = 'd0;
			   else MEM_wen = 'd1;   
			end
			else if(flip_count == 'd3) MEM_wen = 'd0;
			else MEM_wen = 'd1;
		end
		else if(action_reg[0] == 'd1)begin
			if(flip_count == 'd4) MEM_wen = 'd0;
			else MEM_wen = 'd1;
		end
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			if(flip_count < 'd2) 
				MEM_wen = 'b1;
			else 
				MEM_wen = 'b0;
		end
		else if(action_reg[0] == 3'd6)begin
			if(flip_count == 'd0) MEM_wen = 'b1;
			else MEM_wen = 'b0;
		end
		else if(action_reg[0] == 'd7)begin
			if(flip_count == 'd0) MEM_wen = 'b0;
			else MEM_wen = 'd1;
		end
		else begin
			MEM_wen = 'd1;
		end
	end
	else if(outflag)begin
		MEM_wen = 'b1;
	end
	else begin
		MEM_wen = 'd1;
	end
end

// // mem_T_addr
// always @(*) begin
// 	if(current_state == CAL)begin
// 		// For flip function
// 		if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
// 			case (flip_count)
// 			0:  MEM_addr = addr_a;
// 			1:  MEM_addr = addr_b;
// 			2:  MEM_addr = addr_b;
// 			3:  MEM_addr = addr_a;
// 			default : MEM_addr = 'd0;
// 			endcase
// 		end
// 		else if(action_reg[0] == 3'd1)begin
// 			if(flip_count == 'd4) MEM_addr = load_counter;
// 			else MEM_addr = addr_a;
// 		end
// 		else if(action_reg[0] == 3'd6)begin
// 			if(flip_count == 'd0) MEM_addr = terminate_counter - load_counter;
// 			else MEM_addr = addr_a;
// 		end
// 		else if(action_reg[0] == 3'd7)begin
// 			MEM_addr = addr_a;
// 		end
// 		else if(action_reg[0] == 3'd0)begin
// 			MEM_addr = addr_a;
// 			if()
// 		end
// 		else MEM_addr = 'd0;
// 	end 
// 	else if(outflag)begin
// 		MEM_addr = load_counter;
// 	end
// 	else MEM_addr = 'd0;
// end

// buffer
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for(i=0; i<9; i=i+1)begin
			buffer[i] <= 'd0;
		end
	end
	else if(current_state == CAL)begin
		if(action_reg[0] == 3'd0)begin
			case (flip_count)
			0: begin
				if(col_counter_a == 'd0)begin
					for(i=0; i<9; i=i+1)
						buffer[i] <= 'd0;
				end
			end
			1: begin
				if(col_counter_a == 'd1) begin
					if()
				end 
				else begin
					buffer[5] <= MEM_out;
				end 
			end 
			2: begin
				if(col_counter_a == 'd0)begin
					buffer[5] <= MEM_out;
				end
				else begin
					buffer[8] <= MEM_out;
				end
			end
			3: begin
				if(1)begin
					buffer[7] <= MEM_out;
				end
				else begin // shift
					buffer[0] <= buffer[1];
					buffer[3] <= buffer[4];
					buffer[6] <= buffer[7];
					buffer[1] <= buffer[2];
					buffer[4] <= buffer[5];
					buffer[7] <= buffer[8];
				end	
			end
			4: begin
				if(1)begin
					buffer[8] <= MEM_out;
				end
			end
			5: begin
				// shift
				buffer[0] <= buffer[1];
				buffer[3] <= buffer[4];
				buffer[6] <= buffer[7];
				buffer[1] <= buffer[2];
				buffer[4] <= buffer[5];
				buffer[7] <= buffer[8];
			end
			endcase
		end
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			if(flip_count == 'd1) buffer[0] <= MEM_out;
			else if (flip_count == 'd2) buffer[1] <= MEM_out;
		end
		else if(action_reg[0] == 3'd1)begin
			case (flip_count)
				1: buffer[0] <= MEM_out;
				2: buffer[1] <= MEM_out;
				3: buffer[2] <= MEM_out;
			endcase
		end
		else if(action_reg[0] == 3'd6)begin
			if(flip_count == 'd1) buffer[0] <= MEM_out;
		end
	end
end

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

// addr_a addr_b
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
		row_counter_a <= 'd0;
		col_counter_a <= 'd0;
		row_counter_b <= 'd0;
		col_counter_b <= 'd0;
	end 
	else if(current_state == STANDBY)begin
		case (action_reg[0])
		3'd0: begin
			row_counter_a <= 'd0;
			col_counter_a <= 'd0;
		end
		3'd1: begin
			row_counter_a <= 'd0;
			col_counter_a <= 'd0;
			// row_counter_b <= 'd0;
			// col_counter_b <= 'd0;
		end
		3'd2: begin
			row_counter_a <= 'd0;
			col_counter_a <= 'd0;
			row_counter_b <= 'd0;
			col_counter_b <= 'd15;
		end 
		3'd3: begin
			col_counter_a <= 'd0;
			row_counter_a <= 'd0;
			col_counter_b <= 'd0;
			row_counter_b <= 'd15;
		end
		3'd4: begin
			col_counter_a <= 'd0;
			row_counter_a <= 'd14;
			col_counter_b <= 'd1;
			row_counter_b <= 'd15;
		end
		3'd5: begin
			col_counter_a <= 'd0;
			row_counter_a <= 'd1;
			col_counter_b <= 'd1;
			row_counter_b <= 'd0;
		end
		3'd6: begin
			col_counter_a <= 'd14;
			row_counter_a <= 'd14;
			// col_counter_b <= 'd15;
			// row_counter_b <= 'd15;
		end
		3'd7: begin
			if(img_size_reg == 'd0)begin
				col_counter_a <= 'd0;
				row_counter_a <= 'd0;
			end
			else if(img_size_reg == 'd1)begin
				col_counter_a <= 'd2;
				row_counter_a <= 'd2;
			end
			else begin
				col_counter_a <= 'd4;
				row_counter_a <= 'd4;
			end
		end
	endcase
	end
	else if(current_state == CAL)begin
		case (action_reg[0])
		3'd0: begin
			case (flip_count)
			0:begin
				if(col_counter_a == 'd0)begin
					col_counter_a <= col_counter_a + 1;
					row_counter_a <= row_counter_a;
				end
				else if((img_size_reg == 'b00 && load_counter[1:0] == 2'b11) || 
					    (img_size_reg == 'b01 && load_counter[2:0] == 3'b111) ||
					    (img_size_reg == 'b10 && load_counter[3:0] == 4'b1111))begin
					col_counter_a <= 'd0;
					row_counter_a <= row_counter_a;		
				end
				else begin
					col_counter_a <= col_counter_a;
					row_counter_a <= row_counter_a + 1;
				end
			end
			1:begin
				if(col_counter_a == 'd0)begin
					col_counter_a <= col_counter_a - 1;
					row_counter_a <= row_counter_a + 1;
				end
			end
			2:begin
				if(col_counter_a == 'd0)begin
					col_counter_a <= col_counter_a + 1;
					row_counter_a <= row_counter_a;
				end
			end
			3:begin
				col_counter_a <= col_counter_a + 1;
				row_counter_a <= row_counter_a - 1;
			end
			endcase
		end
		3'd1:begin
			case (flip_count)
				0:begin
					col_counter_a <= col_counter_a;
					row_counter_a <= row_counter_a + 1;
				end
				1:begin
					col_counter_a <= col_counter_a + 1;
					row_counter_a <= row_counter_a - 1;
				end
				2: begin
					col_counter_a <= col_counter_a;
					row_counter_a <= row_counter_a + 1;
				end
				4: begin
					if((img_size_reg == 'b01 && col_counter_a[2:0] == 'b111) || 
					   (img_size_reg == 'b10 && col_counter_a[3:0] == 'b1111) )begin
						col_counter_a <= 'd0;
						row_counter_a <= row_counter_a + 1;
					end 
					else begin
						col_counter_a <= col_counter_a + 1; 
						row_counter_a <= row_counter_a - 1;
					end
				end 
			endcase
		end
		3'd2:begin
			if(flip_count=='d3)begin
				if((img_size_reg == 'b00 && col_counter_a[1:0] + 1 == col_counter_b[1:0]) || 
					(img_size_reg == 'b01 && col_counter_a[2:0] + 1 == col_counter_b[2:0]) ||
					(img_size_reg == 'b10 && col_counter_a[3:0] + 1 == col_counter_b[3:0]))begin
						row_counter_a <= row_counter_a + 1;
						row_counter_b <= row_counter_b + 1;
						col_counter_a <= 'd0;
						col_counter_b <= 'd15;
					end
				else begin
					row_counter_a <= row_counter_a;
					row_counter_b <= row_counter_b;
					col_counter_a <= col_counter_a + 1;
					col_counter_b <= col_counter_b - 1;
				end		
			end
		end 
		3'd3: begin
			if(flip_count=='d3)begin
				if((img_size_reg == 'b00 && row_counter_a[1:0] + 1 == row_counter_b[1:0]) || 
					(img_size_reg == 'b01 && row_counter_a[2:0] + 1 == row_counter_b[2:0]) ||
					(img_size_reg == 'b10 && row_counter_a[3:0] + 1 == row_counter_b[3:0]))begin
						col_counter_a <= col_counter_a + 1;
						col_counter_b <= col_counter_b + 1;
						row_counter_a <= 'd0;
						row_counter_b <= 'd15;
					end
				else begin
					col_counter_a <= col_counter_a;
					col_counter_b <= col_counter_b;
					row_counter_a <= row_counter_a + 1;
					row_counter_b <= row_counter_b - 1;
				end		
				
			end
		end 
		3'd4: begin
			if(flip_count=='d3)begin
				if((img_size_reg == 'b00 && row_counter_a[1:0] == 'd0) || 
					(img_size_reg == 'b01 && row_counter_a[2:0] == 'd0) ||
					(img_size_reg == 'b10 && row_counter_a[3:0] == 'd0))begin
						col_counter_a <= col_counter_a + 1;
						col_counter_b <= col_counter_a + 2;
						row_counter_a <= row_counter_b - 2;
						row_counter_b <= row_counter_b - 1;
				end
				else begin
					col_counter_a <= col_counter_a;
					col_counter_b <= col_counter_b + 1;
					row_counter_a <= row_counter_a - 1;
					row_counter_b <= row_counter_b;
				end		
				
			end
		end
		3'd5: begin
			if(flip_count=='d3)begin
				if((img_size_reg == 'b00 && row_counter_a[1:0] == 'd3) || 
					(img_size_reg == 'b01 && row_counter_a[2:0] == 'd7) ||
					(img_size_reg == 'b10 && row_counter_a[3:0] == 'd15))begin
						col_counter_a <= col_counter_a + 1;
						col_counter_b <= row_counter_b + 2;
						row_counter_a <= col_counter_a + 2;
						row_counter_b <= row_counter_b + 1;
				end
				else begin
					col_counter_a <= col_counter_a;
					col_counter_b <= col_counter_b + 1;
					row_counter_a <= row_counter_a + 1;
					row_counter_b <= row_counter_b;
				end		
				
			end
		end
		3'd6: begin
			case (flip_count)
				1:begin
					col_counter_a <= col_counter_a;
					row_counter_a <= row_counter_a + 1;
				end
				2:begin
					col_counter_a <= col_counter_a + 1;
					row_counter_a <= row_counter_a - 1;
				end
				3: begin
					col_counter_a <= col_counter_a;
					row_counter_a <= row_counter_a + 1;
				end
				4: begin
					if((img_size_reg == 'b01 && col_counter_a[3:0] == 'b0001) || 
					   (img_size_reg == 'b00 && col_counter_a[2:0] == 'b001) )begin
						col_counter_a <= 'd14;
						row_counter_a <= row_counter_a - 'd3;
					end 
					else begin
						col_counter_a <= col_counter_a - 'd3; 
						row_counter_a <= row_counter_a - 'd1;
					end
				end 
			endcase
		end
		3'd7: begin
			if(flip_count == 'd1) begin
				if(img_size_reg == 'b00 &&  col_counter_a[1:0] == 'd3)begin
					col_counter_a <= 'd0;
					row_counter_a <= row_counter_a + 'd1;
				end
				else if(img_size_reg == 'b01 && col_counter_a[2:0] == 'd5)begin
					col_counter_a <= 'd2;
					row_counter_a <= row_counter_a + 'd1;
				end
				else if(img_size_reg == 'b10 && col_counter_a[3:0] == 'd11)begin
					col_counter_a <= 'd4;
					row_counter_a <= row_counter_a + 'd1;
				end
				else begin
					col_counter_a <= col_counter_a + 'd1;
					row_counter_a <= row_counter_a;
				end
			end
		end
		endcase
	end
	else begin
		row_counter_a <= 'd0;
		col_counter_a <= 'd0;
		row_counter_b <= 'd0;
		col_counter_b <= 'd0;
	end
end


// load counter
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) load_counter <= 'd0;
	else if(in_valid || in_valid_2)begin
		load_counter <= load_counter + 'd1;
	end 
	else if(current_state == CAL)begin
		if(next_state == STANDBY) load_counter <= 'd0;
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5) begin
			if(flip_count == 'd3)begin
				load_counter <= load_counter + 'd1;
			end
		end
		else if(action_reg[0] == 3'd1 || action_reg[0] == 3'd6)begin
			if(flip_count == 'd4)begin
				load_counter <= load_counter + 'd1;
			end
		end
		else if(action_reg[0] == 3'd7)begin
			if(flip_count == 'd1)begin
				load_counter <= load_counter + 'd1;
			end
		end
		else load_counter <= load_counter;
	end
	else if(outflag)begin
		load_counter <= load_counter + 'd1;
	end 
	else load_counter <= 'd0;
end

// flip count
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) flip_count <= 'd0;
	else if(current_state == CAL)begin
		if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			flip_count <= (flip_count == 'd3)? 0: flip_count + 1;
		end
		else if(action_reg[0] == 3'd1 || action_reg[0] == 'd6)begin
			flip_count <= (flip_count == 'd4)? 0: flip_count + 1;
		end
		else if(action_reg[0] == 3'd7)begin
			flip_count <= (flip_count == 'd1)? 0: flip_count + 1;
		end
	end
	else flip_count <= 'd0;
end

// outflag
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) outflag <= 0;
	else if(current_state == CAL && action_reg[0] == 'd0) outflag <= 1;
	else if(current_state == OUT)begin
		if(load_counter == terminate_counter) outflag <= 0;
	end
	else outflag <= outflag;
end

// calflag
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) calflag <= 0;
	else if(current_state == CAL || current_state == STANDBY)begin
		if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)
			calflag <= (load_counter == terminate_counter && flip_count == 'd3)? 1: calflag;
		else if(action_reg[0] == 3'd1)begin
			if(img_size_reg == 'd0) calflag <= 1;
			else calflag <= (load_counter == terminate_counter && flip_count == 'd4)? 1: calflag;
		end
		else if(action_reg[0] == 3'd6)begin
			if(img_size_reg == 'd2) calflag <= 1;
			else calflag <= (load_counter == terminate_counter && flip_count == 'd4)? 1: calflag;
		end	
		else if(action_reg[0] == 3'd7)begin
			calflag <= (load_counter == terminate_counter && flip_count == 'd1)? 1: calflag;
		end	
	end
	else if(current_state == IDLE) calflag <= 0;
	else calflag <= calflag;
end

// template
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for(i=0; i<9; i=i+1) template_reg[i] <= 0;
	end
	else if(in_valid && load_counter < 'd9) begin
		template_reg[load_counter] <= template; 
	end
end

// img_size_reg
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) img_size_reg <= 'd0;
	else if(current_state == IDLE && in_valid)begin
		if(img_size == 'd4) img_size_reg <= 'd0;
		else if(img_size == 'd8) img_size_reg <= 'd1;
		else if(img_size == 'd16) img_size_reg <= 'd2;
	end
	else if(calflag)begin
		if(action_reg[0] == 'd1) begin
			case (img_size_reg)
				0: img_size_reg <= 'd0;
				1: img_size_reg <= 'd0;
				2: img_size_reg <= 'd1;
			endcase
		end
		else if(action_reg[0] == 'd6) begin
			case (img_size_reg)
				0: img_size_reg <= 'd1;
				1: img_size_reg <= 'd2;
				2: img_size_reg <= 'd2;
			endcase
		end
		else if(action_reg[0] == 'd7) begin
			case (img_size_reg)
				0: img_size_reg <= 'd0;
				1: img_size_reg <= 'd0;
				2: img_size_reg <= 'd1;
			endcase
		end
	end
	else img_size_reg <= img_size_reg;
end

// action_reg
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for(i=0; i<16; i=i+1) action_reg[i] <= 'd0;
	end
	else if(in_valid_2) begin
		action_reg[load_counter] <= action;
	end
	else if(calflag)begin
		for(i=0; i<15; i=i+1) action_reg[i] <= action_reg[i+1];
	end
end

// terminate_counter
always @(*) begin
	if(current_state == OUT)begin
		case (img_size_reg)
			0: terminate_counter = 'd15;
			1: terminate_counter = 'd63; 
			default: terminate_counter = 'd255;
		endcase
	end
	else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3)begin
		case (img_size_reg)
			0: terminate_counter = 'd7;
			1: terminate_counter = 'd31; 
			default: terminate_counter = 'd127;
		endcase
	end
	else if(action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
		case (img_size_reg)
			0: terminate_counter = 'd5;
			1: terminate_counter = 'd27; 
			default: terminate_counter = 'd119;
		endcase
	end
	else if(action_reg[0] == 3'd1)begin
		case (img_size_reg)
			0: terminate_counter = 'd0;
			1: terminate_counter = 'd15;
			default: terminate_counter = 'd63;
		endcase
	end
	else if(action_reg[0] == 3'd6)begin
		case (img_size_reg)
			0: terminate_counter = 'd15;
			1: terminate_counter = 'd63;
			default: terminate_counter = 'd0;
		endcase
	end
	else if(action_reg[0] == 3'd7)begin
		case (img_size_reg)
			0: terminate_counter = 'd15;
			1: terminate_counter = 'd15;
			default: terminate_counter = 'd63;
		endcase
	end
	else terminate_counter = 'd0;
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
            IDLE     : next_state = (in_valid)? LOAD_IMG: IDLE;
			LOAD_IMG : next_state = (in_valid_2)? LOAD_ACT: LOAD_IMG;
			LOAD_ACT : next_state = (!in_valid_2)? STANDBY: LOAD_ACT;
			STANDBY  : next_state = (outflag)? OUT: CAL;
			// CAL      : next_state = (outflag)? MATCH: CAL; 
			CAL      : next_state = (calflag)? STANDBY: CAL; 
			// MATCH    : next_state = (outflag)? OUT: MATCH
			OUT      : next_state = (!outflag)? IDLE: OUT;
			default: next_state = IDLE;
        endcase
    end
end

// Output Logic
// Output Assignment
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid   <= 'd0 ;
		out_x       <= 'd0 ;
		out_y       <= 'd0 ;
		out_img_pos <= 'd0 ;
		out_value   <= 'd0 ;
	end
	else if(current_state == OUT) begin 
		out_valid   <= 'd1 ;
		out_x       <= 'd0 ;
		out_y       <= 'd0 ;
		out_img_pos <= 'd0 ;
		out_value   <= MEM_out ;
	end 
	else begin
		out_valid   <= 'd0;
		out_x       <= 'd0;
		out_y       <= 'd0;
		out_img_pos <= 'd0;
		out_value   <= 'd0;
	end
end
endmodule
