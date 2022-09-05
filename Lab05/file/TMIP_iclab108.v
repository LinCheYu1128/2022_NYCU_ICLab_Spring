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
parameter IDLE     = 3'b000;// 0
parameter LOAD_IMG = 3'b001;// 1
parameter LOAD_ACT = 3'b010;// 2
parameter STANDBY  = 3'b011;// 3
parameter CAL      = 3'b100;// 4
parameter OUT      = 3'b101;// 5
integer i,j;

//---------------------------------------------------------------------
//   WIRE AND REGISTER DECLARATION
//---------------------------------------------------------------------
reg [2:0] current_state, next_state;

reg outflag, calflag;

reg [1:0] img_size_reg; // 'b00 for 4; 'b01 for 8; 'b10 for 16
reg signed[15:0] template_reg[0:8];
reg [2:0] action_reg[0:15];
reg [3:0] row_counter_a, col_counter_a, row_counter_b, col_counter_b;
reg [2:0] flip_count;
reg [7:0] load_counter, terminate_counter;
reg [3:0] out_x_reg, out_y_reg; 
reg signed[39:0] match_reg;
//---------------------------------------------------------------------
//   MEMORY DECLARATION
//---------------------------------------------------------------------
reg MEM_wen;
reg [7:0] MEM_addr, addr_a, addr_b;
reg signed[39:0] MEM_in;
wire signed[39:0] MEM_out;
RAISH MEM( .Q(MEM_out), .CLK(clk), .CEN(1'b0), .WEN(MEM_wen), .A(MEM_addr), .D(MEM_in), .OEN(1'b0));

reg MEM_T_wen;
reg [7:0] MEM_T_addr;
reg [39:0] MEM_T_in;
wire signed[39:0] MEM_T_out;
RAISH MEM_T( .Q(MEM_T_out), .CLK(clk), .CEN(1'b0), .WEN(MEM_T_wen), .A(MEM_T_addr), .D(MEM_T_in), .OEN(1'b0));

//---------------------------------------------------------------------
//   CALCULATE DECLARATION
//---------------------------------------------------------------------
// cross function
wire signed[39:0] ans, ans_T;
reg signed [39:0] buffer[0:2];
reg signed [15:0] template_a, template_b;

assign ans = buffer[0]*template_a;
assign ans_T = buffer[1]*template_b;

wire signed [39:0] zoom_1, zoom_2, zoom_3;
assign zoom_1 = buffer[0]/3;
assign zoom_2 = ((buffer[0]*2)/3) + 20;
assign zoom_3 = {buffer[0][39],buffer[0][39:1]};

wire signed [39:0] brightness;
assign brightness = {MEM_out>>>1} + 50;

wire signed[39:0] max_1, max_2, max_3;
assign max_1 = (buffer[0] > buffer[1])? buffer[0]: buffer[1];
assign max_2 = (buffer[2] > MEM_out)? buffer[2]: MEM_out;
assign max_3 = (max_1 > max_2)? max_1: max_2;
//---------------------------------------------------------------------
//   MEMORY CONTROL
//---------------------------------------------------------------------

// addr_a addr_b
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
			if(flip_count=='d0)MEM_addr = addr_a;
			else MEM_addr = load_counter;
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
			MEM_in = buffer[2] + ans + ans_T + MEM_out*template_reg[4];
		end
		else if(action_reg[0] == 3'd1)begin
			MEM_in = max_3;
			// if(flip_count == 'd4) MEM_in = max_3;
			// else MEM_in = 'd0;
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
			MEM_in = brightness;
			// if(flip_count == 'd1) MEM_in = brightness;
			// else MEM_in = 'd0;
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
			if(flip_count == 'd5) MEM_wen = 'b0;
			else MEM_wen = 'b1;
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
			if(flip_count == 'd0) MEM_wen = 'b1;
			else MEM_wen = 'd0;
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
//---------------------------------------------------------------------
//   MEMORY_TEMP CONTROL
//---------------------------------------------------------------------

// mem_T_addr
always @(*) begin
	if(in_valid) MEM_T_addr = load_counter;
	else if(current_state == CAL)begin
		// For cross function
		if(action_reg[0] == 3'd0)begin
			MEM_T_addr = addr_b;
		end
		// For flip function
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			case (flip_count)
			0:  MEM_T_addr = addr_a;
			1:  MEM_T_addr = addr_b;
			2:  MEM_T_addr = addr_b;
			3:  MEM_T_addr = addr_a;
			default : MEM_T_addr = 'd0;
			endcase
		end
		// For MAX pooling function
		else if(action_reg[0] == 3'd1)begin
			if(flip_count == 'd4) MEM_T_addr = load_counter;
			else MEM_T_addr = addr_a;
		end
		// For xoom in function
		else if(action_reg[0] == 3'd6)begin
			if(flip_count == 'd0) MEM_T_addr = terminate_counter - load_counter;
			else MEM_T_addr = addr_a;
		end
		// For brightness function
		else if(action_reg[0] == 3'd7)begin
			if(flip_count=='d0)MEM_T_addr = addr_a;
			else MEM_T_addr = load_counter;
		end
		else MEM_T_addr = 'd0;
	end 
	else if(outflag)begin
		MEM_T_addr = load_counter;
	end
	else MEM_T_addr = 'd0;
end

// mem_T_in
always @(*) begin
	if(in_valid) begin
		MEM_T_in = {{24{image[15]}}, image};
	end
	else if(current_state == CAL)begin
		if(action_reg[0] == 3'd1)begin
			MEM_T_in = max_3;
			// if(flip_count == 'd4) MEM_T_in = max_3;
			// else MEM_T_in = 'd0;
		end
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			if(flip_count == 'd2) 
				MEM_T_in = buffer[0];
			else if(flip_count == 'd3) 
				MEM_T_in = buffer[1];
			else
				MEM_T_in = 'd0;
		end
		else if(action_reg[0] == 'd6)begin
			case (flip_count)
				1: MEM_T_in = MEM_out;
				2: MEM_T_in = zoom_2;
				3: MEM_T_in = zoom_1;
				4: MEM_T_in = zoom_3; 
				default: MEM_T_in = 'd0;
			endcase
		end
		else if(action_reg[0] == 'd7)begin
			MEM_T_in = brightness;
			// if(flip_count == 'd1) MEM_T_in = brightness;
			// else MEM_T_in = 'd0;
		end
		else begin
			MEM_T_in = 'd0;
		end 
	end
	else begin
		MEM_T_in = 'd0;
	end
end

// mem_T_wen
always @(*) begin
	if(in_valid)begin
		MEM_T_wen = 'd0;
	end
	else if(current_state == CAL)begin
		if(action_reg[0] == 'd1)begin
			if(flip_count == 'd4) MEM_T_wen = 'd0;
			else MEM_T_wen = 'd1;
		end
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			if(flip_count < 'd2) 
				MEM_T_wen = 'b1;
			else 
				MEM_T_wen = 'b0;
		end
		else if(action_reg[0] == 3'd6)begin
			if(flip_count == 'd0) MEM_T_wen = 'b1;
			else MEM_T_wen = 'b0;
		end
		else if(action_reg[0] == 'd7)begin
			if(flip_count == 'd0) MEM_T_wen = 'b1;
			else MEM_T_wen = 'd0;
		end
		else begin
			MEM_T_wen = 'd1;
		end
	end
	else if(outflag)begin
		MEM_T_wen = 'b1;
	end
	else begin
		MEM_T_wen = 'd1;
	end
end

// buffer
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for(i=0; i<3; i=i+1)begin
			buffer[i] <= 'd0;
		end
	end
	else if(current_state == CAL)begin
		if(action_reg[0] == 3'd0)begin
			case (flip_count)
				1:begin
					if(img_size_reg == 2'b00)begin
						if(load_counter[1:0] == 2'b00 || load_counter[3:2] == 2'b11)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:2] == 'b0 || load_counter[1:0] == 2'b00)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					else if(img_size_reg == 2'b01)begin
						if(load_counter[2:0] == 3'b000 || load_counter[5:3] == 3'b111)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:3] == 'b0 || load_counter[2:0] == 3'b000)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					else begin
						if(load_counter[3:0] == 4'b0000 || load_counter[7:4] == 4'b1111)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:4] == 'b0 || load_counter[3:0] == 4'b0000)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
				end 
				2:begin
					if(img_size_reg == 2'b00)begin
						if(load_counter[1:0] == 2'b11)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:2] == 'b0)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					else if(img_size_reg == 2'b01)begin
						if(load_counter[2:0] == 3'b111)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:3] == 'b0)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					else begin
						if(load_counter[3:0] == 4'b1111)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:4] == 'b0)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					buffer[2] <= ans + ans_T;
				end
				3:begin
					if(img_size_reg == 2'b00)begin
						if(load_counter[3:2] == 2'b11)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:2] == 'b0 || load_counter[1:0] == 2'b11)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					else if(img_size_reg == 2'b01)begin
						if(load_counter[5:3] == 3'b111)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:3] == 'b0 || load_counter[2:0] == 3'b111)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					else begin
						if(load_counter[7:4] == 4'b1111)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[7:4] == 'b0 || load_counter[3:0] == 4'b1111)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					buffer[2] <= buffer[2] + ans + ans_T;
				end
				4:begin
					if(img_size_reg == 2'b00)begin
						if(load_counter[3:2] == 2'b11 || load_counter[1:0] == 2'b11)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[1:0] == 2'b00)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					else if(img_size_reg == 2'b01)begin
						if(load_counter[5:3] == 3'b111 || load_counter[2:0] == 3'b111)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[2:0] == 3'b000)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					else begin
						if(load_counter[7:4] == 4'b1111 || load_counter[3:0] == 4'b1111)begin
							buffer[0] <= 0;
						end
						else buffer[0] <= MEM_out;
						if(load_counter[3:0] == 4'b000)begin
							buffer[1] <= 0;
						end
						else buffer[1] <= MEM_T_out;
					end
					buffer[2] <= buffer[2] + ans + ans_T;
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

// tempplate a b
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		template_a <= 0;
		template_b <= 0;
	end
	else begin
		case (flip_count)
		1:begin
			template_a <= template_reg[6];
			template_b <= template_reg[0];
		end 
		2:begin
			template_a <= template_reg[5];
			template_b <= template_reg[1];
		end
		3:begin
			template_a <= template_reg[7];
			template_b <= template_reg[2];
		end
		4:begin
			template_a <= template_reg[8];
			template_b <= template_reg[3];
		end
		endcase
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
			row_counter_b <= 'd0;
			col_counter_b <= 'd0;
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
				if(img_size_reg == 2'b0)begin
					col_counter_a <= {2'b0,load_counter[1:0]} + 'd1;
					row_counter_a <= {2'b0,load_counter[3:2]};
					col_counter_b <= {2'b0,load_counter[1:0]};
					row_counter_b <= {2'b0,load_counter[3:2]} - 'd1;
				end
				else if(img_size_reg == 2'b01)begin
					col_counter_a <= {1'b0,load_counter[2:0]} + 'd1;
					row_counter_a <= {1'b0,load_counter[5:3]};
					col_counter_b <= {1'b0,load_counter[2:0]};
					row_counter_b <= {1'b0,load_counter[5:3]} - 'd1;
				end
				else begin
					col_counter_a <= load_counter[3:0] + 'd1;
					row_counter_a <= load_counter[7:4];
					col_counter_b <= load_counter[3:0];
					row_counter_b <= load_counter[7:4] - 'd1;
				end
			end
			1:begin
				if(img_size_reg == 2'b00)begin
					col_counter_b <= {2'b0,load_counter[1:0]} + 'd1;
					row_counter_b <= {2'b0,load_counter[3:2]} - 'd1;
					col_counter_a <= {2'b0,load_counter[1:0]};
					row_counter_a <= {2'b0,load_counter[3:2]} + 'd1;
				end
				else if(img_size_reg == 2'b01)begin
					col_counter_b <= {1'b0,load_counter[2:0]} + 'd1;
					row_counter_b <= {1'b0,load_counter[5:3]} - 'd1;
					col_counter_a <= {1'b0,load_counter[2:0]};
					row_counter_a <= {1'b0,load_counter[5:3]} + 'd1;
				end
				else begin
					col_counter_b <= load_counter[3:0] + 'd1;
					row_counter_b <= load_counter[7:4] - 'd1;
					col_counter_a <= load_counter[3:0];
					row_counter_a <= load_counter[7:4] + 'd1;
				end
			end
			2:begin
				if(img_size_reg == 2'b00)begin
					col_counter_b <= {2'b0,load_counter[1:0]} - 'd1;
					row_counter_b <= {2'b0,load_counter[3:2]};
					col_counter_a <= {2'b0,load_counter[1:0]} + 'd1;
					row_counter_a <= {2'b0,load_counter[3:2]} + 'd1;
				end
				else if(img_size_reg == 2'b01)begin
					col_counter_b <= {1'b0,load_counter[2:0]} - 'd1;
					row_counter_b <= {1'b0,load_counter[5:3]};
					col_counter_a <= {1'b0,load_counter[2:0]} + 'd1;
					row_counter_a <= {1'b0,load_counter[5:3]} + 'd1;
				end
				else begin
					col_counter_b <= load_counter[3:0] - 'd1;
					row_counter_b <= load_counter[7:4];
					col_counter_a <= load_counter[3:0] + 'd1;
					row_counter_a <= load_counter[7:4] + 'd1;
				end
			end
			3:begin
				if(img_size_reg == 2'b00)begin
					col_counter_a <= {2'b0,load_counter[1:0]};
					row_counter_a <= {2'b0,load_counter[3:2]};
				end
				else if(img_size_reg == 2'b01)begin
					col_counter_a <= {1'b0,load_counter[2:0]};
					row_counter_a <= {1'b0,load_counter[5:3]};
				end
				else begin
					col_counter_a <= load_counter[3:0];
					row_counter_a <= load_counter[7:4];
				end
			end
			5:begin
				if(img_size_reg == 2'b00)begin
					col_counter_a <= {2'b0,load_counter[1:0]} - 'd1;
					row_counter_a <= {2'b0,load_counter[3:2]} + 'd1;
					col_counter_b <= {2'b0,load_counter[1:0]} - 'd1;
					row_counter_b <= {2'b0,load_counter[3:2]} - 'd1;
				end
				else if(img_size_reg == 2'b01)begin
					col_counter_a <= {1'b0,load_counter[2:0]} - 'd1;
					row_counter_a <= {1'b0,load_counter[5:3]} + 'd1;
					col_counter_b <= {1'b0,load_counter[2:0]} - 'd1;
					row_counter_b <= {1'b0,load_counter[5:3]} - 'd1;
				end
				else begin
					col_counter_a <= {load_counter[3:0]} - 'd1;
					row_counter_a <= {load_counter[7:4]} + 'd1;
					col_counter_b <= {load_counter[3:0]} - 'd1;
					row_counter_b <= {load_counter[7:4]} - 'd1;
				end
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
		else if(action_reg[0] == 3'd0)begin
			if(flip_count == 'd4)begin
				load_counter <= load_counter + 'd1;
			end
		end
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
		if(action_reg[0] == 3'd0)begin
			flip_count <= (flip_count == 'd5)? 0: flip_count + 1;
		end
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
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
		if(action_reg[0] == 3'd0)begin
			calflag <= (load_counter == terminate_counter && flip_count == 'd4)? 1: 0;
		end
		else if(action_reg[0] == 3'd2 || action_reg[0] == 3'd3 || action_reg[0] == 3'd4 || action_reg[0] == 3'd5)begin
			calflag <= (load_counter == terminate_counter && flip_count == 'd3)? 1: 0;
		end	
		else if(action_reg[0] == 3'd1)begin
			if(img_size_reg == 'd0) calflag <= 1;
			else calflag <= (load_counter == terminate_counter && flip_count == 'd4)? 1: 0;
		end
		else if(action_reg[0] == 3'd6)begin
			if(img_size_reg == 'd2) calflag <= 1;
			else calflag <= (load_counter == terminate_counter && flip_count == 'd4)? 1: 0;
		end	
		else if(action_reg[0] == 3'd7)begin
			calflag <= (load_counter == terminate_counter && flip_count == 'd1)? 1: 0;
		end	
	end
	else calflag <= 0;
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
	else if(calflag && current_state == CAL)begin
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
	else if(current_state == CAL && calflag)begin
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
	else if(action_reg[0] == 3'd0)begin
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


// pos
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		out_x_reg <= 0;
		out_y_reg <= 0;
		match_reg <= 0;
	end
	else if(action_reg[0] == 'd0)begin
		if(flip_count == 'd5)begin
			if(load_counter == 'd1 || match_reg < MEM_in)begin
				match_reg <= MEM_in;
				out_x_reg <= row_counter_a;
				out_y_reg <= col_counter_a;
			end 
		end
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
            IDLE     : next_state = (in_valid)? LOAD_IMG: IDLE;
			LOAD_IMG : next_state = (in_valid_2)? LOAD_ACT: LOAD_IMG;
			LOAD_ACT : next_state = (!in_valid_2)? STANDBY: LOAD_ACT;
			STANDBY  : next_state = (outflag)? OUT: CAL;
			CAL      : next_state = (calflag)? STANDBY: CAL; 
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
		out_value   <= 'd0 ;
	end
	else if(current_state == OUT) begin 
		out_valid   <= 'd1 ;
		out_x       <= out_x_reg ;
		out_y       <= out_y_reg ;
		out_value   <= MEM_out ;
	end 
	else begin
		out_valid   <= 'd0;
		out_x       <= 'd0;
		out_y       <= 'd0;
		out_value   <= 'd0;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_img_pos <= 'd0 ;
	end
	else if(current_state == OUT) begin 
		// case 1
		if(out_x_reg == 'd0 && out_y_reg == 'd0)begin
			case (load_counter)
			1:begin
				out_img_pos <= 'd0;
			end 
			2: begin
				out_img_pos <= 'd1;
			end
			3: begin
				if(img_size_reg == 'd0) out_img_pos <= 'd4;
				else if(img_size_reg == 'd1) out_img_pos <= 'd8;
				else out_img_pos <= 'd16;
			end
			4: begin
				if(img_size_reg == 'd0) out_img_pos <= 'd5;
				else if(img_size_reg == 'd1) out_img_pos <= 'd9;
				else out_img_pos <= 'd17;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		// case 3
		else if(out_x_reg == 'd0 && out_y_reg == 'd3 && img_size_reg == 'd0)begin
			// $display("tesr case 3");
			case (load_counter)
			1:begin
				out_img_pos <= 'd2;
			end 
			2: begin
				out_img_pos <= 'd3;
			end
			3: begin
				out_img_pos <= 'd6;
			end
			4: begin
				out_img_pos <= 'd7;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_x_reg == 'd0 && out_y_reg == 'd7 && img_size_reg == 'd1)begin
			case (load_counter)
			1:begin
				out_img_pos <= 'd6;
			end 
			2: begin
				out_img_pos <= 'd7;
			end
			3: begin
				out_img_pos <= 'd14;
			end
			4: begin
				out_img_pos <= 'd15;
			end
			default: out_img_pos <= 'd0;
			endcase	
		end
		else if(out_x_reg == 'd0 && out_y_reg == 'd15 && img_size_reg == 'd2)begin
			case (load_counter)
			1:begin
				out_img_pos <= 'd14;
			end 
			2: begin
				out_img_pos <= 'd15;
			end
			3: begin
				out_img_pos <= 'd30;
			end
			4: begin
				out_img_pos <= 'd31;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		// case 7
		else if(out_x_reg == 'd3 && out_y_reg == 'd0 && img_size_reg == 'd0)begin
			// $display("tesr case 7");
			case (load_counter)
			1:begin
				out_img_pos <= 'd8;
			end 
			2: begin
				out_img_pos <= 'd9;
			end
			3: begin
				out_img_pos <= 'd12;
			end
			4: begin
				out_img_pos <= 'd13;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_x_reg == 'd7 && out_y_reg == 'd0 && img_size_reg == 'd1)begin
			case (load_counter)
			1:begin
				out_img_pos <= 'd48;
			end 
			2: begin
				out_img_pos <= 'd49;
			end
			3: begin
				out_img_pos <= 'd56;
			end
			4: begin
				out_img_pos <= 'd57;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_x_reg == 'd15 && out_y_reg == 'd0 && img_size_reg == 'd2)begin
			case (load_counter)
			1:begin
				out_img_pos <= 'd224;
			end 
			2: begin
				out_img_pos <= 'd225;
			end
			3: begin
				out_img_pos <= 'd240;
			end
			4: begin
				out_img_pos <= 'd241;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		// case 9
		else if(out_x_reg == 'd3 && out_y_reg == 'd3 && img_size_reg == 'd0)begin
			// $display("tesr case 9");
			case (load_counter)
			1:begin
				out_img_pos <= 'd10;
			end 
			2: begin
				out_img_pos <= 'd11;
			end
			3: begin
				out_img_pos <= 'd14;
			end
			4: begin
				out_img_pos <= 'd15;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_x_reg == 'd7 && out_y_reg == 'd7 && img_size_reg == 'd1)begin
			case (load_counter)
			1:begin
				out_img_pos <= 'd54;
			end 
			2: begin
				out_img_pos <= 'd55;
			end
			3: begin
				out_img_pos <= 'd62;
			end
			4: begin
				out_img_pos <= 'd63;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_x_reg == 'd15 && out_y_reg == 'd15 && img_size_reg == 'd2)begin
			case (load_counter)
			1:begin
				out_img_pos <= 'd238;
			end 
			2: begin
				out_img_pos <= 'd239;
			end
			3: begin
				out_img_pos <= 'd254;
			end
			4: begin
				out_img_pos <= 'd255;
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		// case 2
		else if(out_x_reg == 'd0)begin
			// $display("tesr case 2");
			case (load_counter)
			1:begin
				out_img_pos <= {4'b0, out_y_reg - 1'b1};
			end 
			2: begin
				out_img_pos <= {4'b0, out_y_reg };
			end
			3: begin
				out_img_pos <= {4'b0, out_y_reg + 1'b1};
			end
			4: begin
				if(img_size_reg == 'd0) out_img_pos <= {6'd1, out_y_reg[1:0] - 1'b1};
				else if(img_size_reg == 'd1) out_img_pos <= {5'd1, out_y_reg[2:0] - 1'b1};
				else out_img_pos <= {4'd1, out_y_reg[3:0] - 1'b1};
			end
			5:begin
				if(img_size_reg == 'd0) out_img_pos <= {6'd1, out_y_reg[1:0]};
				else if(img_size_reg == 'd1) out_img_pos <= {5'd1, out_y_reg[2:0]};
				else out_img_pos <= {4'd1, out_y_reg[3:0]};
			end
			6:begin
				if(img_size_reg == 'd0) out_img_pos <= {6'd1, out_y_reg[1:0] + 1'b1};
				else if(img_size_reg == 'd1) out_img_pos <= {5'd1, out_y_reg[2:0] + 1'b1};
				else out_img_pos <= {4'd1, out_y_reg[3:0] + 1'b1};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		// case 4 
		else if(out_y_reg == 'd0 && img_size_reg == 'd0)begin
			// $display("tesr case 4");
			case (load_counter)
			1:begin
				out_img_pos <= {4'd0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0]};
			end 
			2: begin
				out_img_pos <= {4'd0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0] + 1'b1};
			end
			3: begin
				out_img_pos <= {4'd0, out_x_reg[1:0], out_y_reg[1:0]};
			end
			4: begin
				out_img_pos <= {4'd0, out_x_reg[1:0], out_y_reg[1:0] + 1'b1};
			end
			5:begin
				out_img_pos <= {4'd0, out_x_reg[1:0] + 1'b1, out_y_reg[1:0]};
			end
			6:begin
				out_img_pos <= {4'd0, out_x_reg[1:0] + 1'b1, out_y_reg[1:0] + 1'b1};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_y_reg == 'd0 && img_size_reg == 'd1)begin
			case (load_counter)
			1:begin
				out_img_pos <= {2'd0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0]};
			end 
			2: begin
				out_img_pos <= {2'd0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0] + 1'b1};
			end
			3: begin
				out_img_pos <= {2'd0, out_x_reg[2:0], out_y_reg[2:0]};
			end
			4: begin
				out_img_pos <= {2'd0, out_x_reg[2:0], out_y_reg[2:0] + 1'b1};
			end
			5:begin
				out_img_pos <= {2'd0, out_x_reg[2:0] + 1'b1, out_y_reg[2:0]};
			end
			6:begin
				out_img_pos <= {2'd0, out_x_reg[2:0] + 1'b1, out_y_reg[2:0] + 1'b1};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_y_reg == 'd0 && img_size_reg == 'd2)begin
			case (load_counter)
			1:begin
				 out_img_pos <= {out_x_reg - 1'b1, out_y_reg};
			end 
			2: begin
				out_img_pos <= {out_x_reg - 1'b1, out_y_reg + 1'b1};
			end
			3: begin
				out_img_pos <= {out_x_reg, out_y_reg};
			end
			4: begin
				out_img_pos <= {out_x_reg, out_y_reg + 1'b1};
			end
			5:begin
				out_img_pos <= {out_x_reg + 1'b1, out_y_reg};
			end
			6:begin
				out_img_pos <= {out_x_reg + 1'b1, out_y_reg + 1'b1};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		// case 6
		else if(out_y_reg == 'd3 && img_size_reg == 'd0)begin
			// $display("tesr case %d",{out_x_reg[1:0] - 1'b1,out_y_reg[1:0] - 1'b1});
			case (load_counter)
			1:begin
				out_img_pos <= {4'b0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0] - 1'b1};
			end 
			2: begin
				out_img_pos <= {4'b0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0]};
			end
			3: begin
				out_img_pos <= {4'b0, out_x_reg[1:0], out_y_reg[1:0] - 1'b1};
			end
			4: begin
				out_img_pos <= {4'b0, out_x_reg[1:0], out_y_reg[1:0]};
			end
			5:begin
				out_img_pos <= {4'b0, out_x_reg[1:0] + 1'b1, out_y_reg[1:0] - 1'b1};
			end
			6:begin
				out_img_pos <= {4'b0, out_x_reg[1:0] + 1'b1, out_y_reg[1:0]};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_y_reg == 'd7 && img_size_reg == 'd1)begin
			case (load_counter)
			1:begin
				out_img_pos <= {2'b0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0] - 1'b1};
			end 
			2: begin
				out_img_pos <= {2'b0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0]};
			end
			3: begin
				out_img_pos <= {2'b0, out_x_reg[2:0], out_y_reg[2:0] - 1'b1};
			end
			4: begin
				out_img_pos <= {2'b0, out_x_reg[2:0], out_y_reg[2:0]};
			end
			5:begin
				out_img_pos <= {2'b0, out_x_reg[2:0] + 1'b1, out_y_reg[2:0] - 1'b1};
			end
			6:begin
				out_img_pos <= {2'b0, out_x_reg[2:0] + 1'b1, out_y_reg[2:0]};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_y_reg == 'd15 && img_size_reg == 'd2)begin
			case (load_counter)
			1:begin
				out_img_pos <= {out_x_reg - 1'b1, out_y_reg - 1'b1};
			end 
			2: begin
				out_img_pos <= {out_x_reg - 1'b1, out_y_reg};
			end
			3: begin
				out_img_pos <= {out_x_reg, out_y_reg - 1'b1};
			end
			4: begin
				out_img_pos <= {out_x_reg, out_y_reg};
			end
			5:begin
				out_img_pos <= {out_x_reg + 1'b1, out_y_reg - 1'b1};
			end
			6:begin
				out_img_pos <= {out_x_reg + 1'b1, out_y_reg};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		// case 8
		else if(out_x_reg == 'd3 && img_size_reg == 'd0)begin
			// $display("tesr case 8");
			case (load_counter)
			1:begin
				out_img_pos <= {4'd0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0] - 1'b1};
			end 
			2: begin
				out_img_pos <= {4'd0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0]};
			end
			3: begin
				out_img_pos <= {4'd0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0] + 1'b1};
			end
			4: begin
				out_img_pos <= {4'd0, out_x_reg[1:0], out_y_reg[1:0] - 1'b1};
			end
			5:begin
				out_img_pos <= {4'd0, out_x_reg[1:0], out_y_reg[1:0]};
			end
			6:begin
				out_img_pos <= {4'd0, out_x_reg[1:0], out_y_reg[1:0] + 1'b1};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_x_reg == 'd7 && img_size_reg == 'd1)begin
			case (load_counter)
			1:begin
				out_img_pos <= {2'd0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0] - 1'b1};
			end 
			2: begin
				out_img_pos <= {2'd0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0]};
			end
			3: begin
				out_img_pos <= {2'd0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0] + 1'b1};
			end
			4: begin
				out_img_pos <= {2'd0, out_x_reg[2:0], out_y_reg[2:0] - 1'b1};
			end
			5:begin
				out_img_pos <= {2'd0, out_x_reg[2:0], out_y_reg[2:0]};
			end
			6:begin
				out_img_pos <= {2'd0, out_x_reg[2:0], out_y_reg[2:0] + 1'b1};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		else if(out_x_reg == 'd15 && img_size_reg == 'd2)begin
			case (load_counter)
			1:begin
				out_img_pos <= {out_x_reg - 1'b1, out_y_reg - 1'b1};
			end 
			2: begin
				out_img_pos <= {out_x_reg - 1'b1, out_y_reg};
			end
			3: begin
				out_img_pos <= {out_x_reg - 1'b1, out_y_reg + 1'b1};
			end
			4: begin
				out_img_pos <= {out_x_reg, out_y_reg - 1'b1};
			end
			5:begin
				out_img_pos <= {out_x_reg, out_y_reg};
			end
			6:begin
				out_img_pos <= {out_x_reg, out_y_reg + 1'b1};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
		// case 5
		else begin
			// $display("tesr case 5");
			case (load_counter)
			1:begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0] - 1'b1};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0] - 1'b1};
				else out_img_pos <= {out_x_reg - 1'b1, out_y_reg - 1'b1};
			end 
			2: begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0]};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0]};
				else out_img_pos <= {out_x_reg - 1'b1, out_y_reg};
			end
			3: begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0] - 1'b1, out_y_reg[1:0] + 1'b1};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0] - 1'b1, out_y_reg[2:0] + 1'b1};
				else out_img_pos <= {out_x_reg - 1'b1, out_y_reg + 1'b1};
			end
			4: begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0], out_y_reg[1:0] - 1'b1};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0], out_y_reg[2:0] - 1'b1};
				else out_img_pos <= {out_x_reg, out_y_reg - 1'b1};
			end
			5:begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0], out_y_reg[1:0]};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0], out_y_reg[2:0]};
				else out_img_pos <= {out_x_reg, out_y_reg};
			end
			6:begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0], out_y_reg[1:0] + 1'b1};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0], out_y_reg[2:0] + 1'b1};
				else out_img_pos <= {out_x_reg, out_y_reg + 1'b1};
			end
			7:begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0] + 1'b1, out_y_reg[1:0] - 1'b1};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0] + 1'b1, out_y_reg[2:0] - 1'b1};
				else out_img_pos <= {out_x_reg + 1'b1, out_y_reg - 1'b1};
			end
			8:begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0] + 1'b1, out_y_reg[1:0]};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0] + 1'b1, out_y_reg[2:0]};
				else out_img_pos <= {out_x_reg + 1'b1, out_y_reg};
			end
			9:begin
				if(img_size_reg == 'd0) out_img_pos <= {4'd0, out_x_reg[1:0] + 1'b1, out_y_reg[1:0] + 1'b1};
				else if(img_size_reg == 'd1) out_img_pos <= {2'd0, out_x_reg[2:0] + 1'b1, out_y_reg[2:0] + 1'b1};
				else out_img_pos <= {out_x_reg + 1'b1, out_y_reg + 1'b1};
			end
			default: out_img_pos <= 'd0;
			endcase
		end
	end 
	else begin
		out_img_pos <= 'd0;
	end
end
endmodule
