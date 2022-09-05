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

parameter IDLE    = 3'd0;
parameter INPUT   = 3'd1;
parameter ACT_DEF = 3'd2;
parameter ACT 	  = 3'd3;
parameter OUTPUT  = 3'd4;
parameter INPUT2 = 3'd5;

parameter CON   = 3'd0;
parameter MAXP  = 3'd1;
parameter HOR   = 3'd2;
parameter VER   = 3'd3;
parameter LEFT  = 3'd4;
parameter RIGHT = 3'd5;
parameter ZOOM  = 3'd6;
parameter SB    = 3'd7;

reg [2:0] current_state, next_state;
reg [15:0] temp_reg[0:8];
reg signed [15:0] img_reg;
reg [2:0] act_reg[0:15];
reg [4:0] img_size_reg;
reg [4:0] temp_index;//max=9
reg [2:0] current_act;
reg [4:0] current_act_num, num_act, f_t_i;//max=16
reg signed [4:0] start_i, start_j, i, j,start_i_reg, start_j_reg, i_reg, j_reg;
reg signed [1:0] i_step, j_step, i_step_reg, j_step_reg;
reg j_frist, j_frist_reg;
reg signed [39:0] D0;
reg [8:0] A0;
reg WEN0;
reg signed [15:0] result, result_reg;
reg [8:0] con_cnt;
reg [3:0] cnt;
reg signed [15:0] multi_in, add_in, adjust, shift_in, div_out_reg;
reg signed [16:0] mult_out_reg, div_in;//16 bits*2=17bits
reg signed [15:0] multi_in1, multi_in2;
reg signed [39:0] con_result_reg, add_in2;
reg signed [39:0] max_con_result_reg;
reg [7:0] max_index_reg;
reg zero_or_not_reg;
reg [7:0] img_pos;
reg [3:0] max_x, max_y;

wire xe0, xei, ye0, yei;
wire signed [39:0] con_result;
wire signed [15:0] div_out, add_out, shift_out;
wire signed [16:0] mult_out;//16bits*2
wire signed [39:0] Q0;
wire [3:0] index_img_size;
wire signed [4:0] i_max,j_max,i_max_pre, j_max_pre;
wire signed [3:0] shift_index;//2,4
wire zero_or_not;
RA1SH U_SRAM0(.Q(Q0),.CLK(clk),.CEN(1'b0),.WEN(WEN0),.A(A0),.D(D0),.OEN(1'b0));
//RA1SH U_SRAM1(.Q(Q1),.CLK(clk),.CEN(1'b0),.WEN(WEN1),.A(A1),.D(D1),.OEN(1'b0));

assign index_img_size = img_size_reg - 1;
always@(posedge	clk or negedge rst_n)	begin
	if(!rst_n) current_state	<=	IDLE;
	else current_state	 <=	next_state;
end
					
always@(*)	begin
next_state = current_state;
	case(current_state)
		IDLE:begin
			if(in_valid) next_state	= INPUT;
			else next_state	= current_state;
		end	
		INPUT:begin
			if(!in_valid) next_state = INPUT2;
			else next_state = current_state;
		end
		INPUT2:begin
			if(num_act>0) next_state = ACT_DEF;
			else next_state = current_state;
		end
		ACT_DEF:begin
			if(current_act_num<num_act)begin
				next_state = ACT;
				case(act_reg[current_act_num])
					MAXP:begin
						if(img_size_reg==4)		next_state = ACT_DEF;
					end
					ZOOM:begin
						if(img_size_reg==16)	next_state = ACT_DEF;
					end
				endcase
			end	else next_state = OUTPUT;
		end
		ACT:begin
			next_state = current_state;
			case(current_act)
				CON:begin
					if(con_cnt==img_size_reg*img_size_reg)	next_state = ACT_DEF;
					else next_state = current_state;
				end
				MAXP:begin
					if(i_reg==index_img_size-1 && j_reg==index_img_size-1 && cnt==3)	next_state = ACT_DEF;
					else next_state = current_state;
				end
				HOR:	next_state = ACT_DEF;
				VER:	next_state = ACT_DEF;
				LEFT:	next_state = ACT_DEF;
				RIGHT:	next_state = ACT_DEF;
				ZOOM:begin
					if(i_reg==0 && j_reg==0 && cnt==3)	next_state = ACT_DEF;
					else	next_state = current_state;
				end
				SB:begin
					if(i_reg==index_img_size-shift_index && j_reg==index_img_size-shift_index && cnt==0)	next_state = ACT_DEF;
					else	next_state = current_state;
				end
			endcase
		end
		OUTPUT:begin
			if(con_cnt==img_size_reg*img_size_reg)	next_state	=	IDLE;
			else next_state	= current_state;
		end
	endcase
end
////////////////INPUT/////////////////////
always@(posedge clk)begin
	if(next_state == IDLE)	img_reg <= 0;	
	else if(in_valid)	img_reg <= image;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	img_size_reg <= 0;	
	else if(next_state == IDLE)	img_size_reg <= 0;	
	else if(in_valid&&temp_index==0)	img_size_reg <= img_size;
	else if(current_state == ACT)begin
		case(current_act)
		MAXP:begin
			if(i_reg==index_img_size-1&&j_reg==index_img_size-1 && cnt==3)
				img_size_reg <= (img_size_reg>>1);
		end 
		ZOOM:begin
			if(i_reg==0 && j_reg==0 && cnt==3)
				img_size_reg <= img_size_reg*2;
		end 		
		SB:begin
			if(img_size_reg!=4 && i_reg==index_img_size-shift_index && j_reg==index_img_size-shift_index && cnt==0)
				img_size_reg <= img_size_reg>>1;
		end 
		endcase
	end
end

always@(posedge clk)begin
	if(next_state == IDLE)begin
		for(f_t_i=0; f_t_i<9 ;f_t_i=f_t_i+1)
			temp_reg[f_t_i] <= 0;	
	end else if(in_valid)	
		temp_reg[temp_index] <= template;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	temp_index <= 0;	
	else if(next_state == IDLE)	temp_index <= 0;	
	else if (in_valid && temp_index<9)	temp_index <= temp_index+1;
end
always@(posedge clk)begin
	if(next_state == IDLE)begin
		for(f_t_i=0; f_t_i<16;f_t_i=f_t_i+1)begin
			act_reg[f_t_i] <= 7;	
		end
	end else if(in_valid_2)	
		act_reg[num_act] <= action;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	num_act <= 0;	
	else if(next_state == IDLE)	num_act <= 0;	
	else if (in_valid_2)	num_act <= num_act+1;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	current_act_num<=0;
	else begin
		case(current_state)
			IDLE: current_act_num<=0;
			ACT_DEF: begin
				current_act_num <= current_act_num+1;
			end
		endcase
	end
end
////////////////INPUT/////////////////////

always@(posedge clk)begin
	if(next_state == IDLE)	current_act <= 7;	
	else if (current_state == ACT_DEF)	current_act <= act_reg[current_act_num];
end
///define SRAM0,SRAM1
always@(*)begin
	D0=0;
	A0={1'b0,i[3:0],j[3:0]};	
	WEN0=1;
	case(current_state)
		INPUT:begin
			D0 = img_reg;
			A0 = {1'b0,i_reg[3:0],j_reg[3:0]};
			WEN0 = 0;
		end
		ACT_DEF:begin
			D0=0;
			A0=(num_act==current_act_num)?{1'b1,con_cnt[7:0]}:{1'b0,i[3:0],j[3:0]};	
			WEN0=1;
		end
		ACT:begin
			case(current_act)
				CON:begin
					if(cnt==8)begin//write result
						D0 = con_result;
						A0 = (con_cnt<img_size_reg*2)?{1'b1,con_cnt[7:0]}:{1'b0,i[3:0],j[3:0]};
						WEN0 = 0;
					end else begin
						D0 = 0;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 1;
					end
				end
				MAXP:begin
					if(cnt==3)begin//write result
						D0 = result;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 0;
					end else begin
						D0 = 0;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 1;
					end
				end
				ZOOM:begin
					case(cnt)
					0:begin
						D0 = result;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 0;
					end
					1:begin
						D0 = div_out;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 0;
					end
					2:begin
						D0 = shift_out;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 0;
					end
					3:begin
						D0 = add_out;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 0;
					end
					4:begin
						D0 = 0;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 1;
					end
					endcase
				end
				SB:begin
					if(cnt==0)begin
						D0 = add_out;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 0;
					end else begin
						D0 = 0;
						A0 = {1'b0,i[3:0],j[3:0]};
						WEN0 = 1;
					end
				end
			endcase
		end
		OUTPUT:begin
			D0 = 0;
			A0 = (con_cnt<img_size_reg*2)?{1'b1,con_cnt[7:0]}:{1'b0,i[3:0],j[3:0]};
			WEN0 = 1;
		end
	endcase
end
//define property of index
always@(*)begin
	start_i = start_i_reg;
	start_j = start_j_reg;
	i_step = i_step_reg;
	j_step = j_step_reg;
	j_frist = j_frist_reg;
	case(current_state)
		IDLE:begin
			start_i = 0;
			start_j = 0;
			i_step = 1;
			j_step = 1;
			j_frist = 1;
		end
		ACT_DEF:begin
			if(current_act_num!=num_act)begin
				case(act_reg[current_act_num])
					HOR:begin
						if(j_frist)begin//first' , second
							start_i=start_i_reg;
							start_j=(start_j_reg == 0)?index_img_size:0;
							j_step={!j_step_reg[1],j_step_reg[0]};
							i_step=i_step_reg;
						end else begin
							start_i=(start_i_reg == 0)?index_img_size:0;
							start_j=start_j_reg;
							j_step=j_step_reg;
							i_step={!i_step_reg[1],i_step_reg[0]};
						end
					end
					VER:begin
						if(j_frist)begin
							start_i=(start_i_reg == 0)?index_img_size:0;
							start_j=start_j_reg;
							j_step=j_step_reg;
							i_step={!i_step_reg[1],i_step_reg[0]};
						end else begin
							start_i=start_i_reg;
							start_j=(start_j_reg == 0)?index_img_size:0;
							j_step={!j_step_reg[1],j_step_reg[0]};
							i_step=i_step_reg;
						end
					end
					LEFT:begin
						start_i=(start_i_reg == 0)?index_img_size:0;
						start_j=(start_j_reg == 0)?index_img_size:0;
						i_step={!i_step_reg[1],i_step_reg[0]};
						j_step={!j_step_reg[1],j_step_reg[0]};
						j_frist=!j_frist_reg;
					end
					RIGHT:begin
						start_i=start_i_reg;
						start_j=start_j_reg;
						i_step=i_step_reg;
						j_step=j_step_reg;
						j_frist=!j_frist_reg;
					end
				endcase
			end
		end
		ACT:begin
			case(current_act)
				MAXP:begin///modify last cycle
					if(i_reg==index_img_size-1 && j_reg==index_img_size-1 && cnt==3)begin
						start_i=(start_i_reg>>1);
						start_j=(start_j_reg>>1);
					end
				end
				ZOOM:begin///modify last cycle
					if(i_reg==0 && j_reg==0 && cnt==3)begin
						start_i=(start_i_reg==0)?0:(start_i_reg*2+1);
						start_j=(start_j_reg==0)?0:(start_j_reg*2+1);
					end
				end
				SB:begin///modify last cycle
					if(img_size_reg!=4 && i_reg==index_img_size-shift_index && j_reg==index_img_size-shift_index && cnt==0)begin
						start_i=(start_i_reg>>1);
						start_j=(start_j_reg>>1);
					end
				end
			endcase
		end
	endcase
	
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		start_i_reg <= 0;
		start_j_reg <= 0;
		i_step_reg <= 1;
		j_step_reg <= 1;
		j_frist_reg <= 1;
	end else begin
		start_i_reg <= start_i;
		start_j_reg <= start_j;
		i_step_reg <= i_step;
		j_step_reg <= j_step;
		j_frist_reg <= j_frist;
	end
	
end
assign i_max = (start_i_reg==0)?index_img_size:0;
assign j_max = (start_j_reg==0)?index_img_size:0;
assign i_max_pre = (start_i_reg==0)?(index_img_size-1):1;
assign j_max_pre = (start_j_reg==0)?(index_img_size-1):1;
////define index
assign shift_index = (img_size_reg==4)?0:((img_size_reg==8)?2:4);
always@(*)begin
	i=i_reg;
	case(current_state)
		IDLE: i=0;
		INPUT:begin
			if(j_reg==index_img_size)	i=i_reg+1;
			else i = i_reg;
		end
		ACT_DEF:begin
			i=start_i;
			if(current_act_num!=num_act)begin
				case(act_reg[current_act_num])
					CON:	i = (start_i_reg==0)?-1:img_size_reg;
					MAXP:	i = 0;
					ZOOM:	i = index_img_size;
					SB:		i = shift_index;
				endcase
			end
		end
		ACT:begin
			case(current_act)
				CON:begin
					if(j_frist)begin
						case(cnt)
							0:i=i_reg;
							1:i=i_reg;
							2:i=i_reg+i_step_reg;
							3:i=i_reg+i_step_reg;
							4:i=i_reg+i_step_reg;
							5:i=i_reg+2*i_step_reg;
							6:i=i_reg+2*i_step_reg;
							7:i=i_reg+2*i_step_reg;
							8:i=i_reg-i_step_reg;
							9:begin
								if(j_reg == j_max_pre)	i=i_reg+i_step_reg;
								else i=i_reg;
							end
						endcase
					end else begin
						case(cnt)
							0:i=i_reg+i_step_reg;
							1:i=i_reg+2*i_step_reg;
							2:i=i_reg;
							3:i=i_reg+i_step_reg;
							4:i=i_reg+2*i_step_reg;
							5:i=i_reg;
							6:i=i_reg+i_step_reg;
							7:i=i_reg+2*i_step_reg;
							8:i=i_reg+i_step_reg;
							9:begin
								if(i_reg == i_max_pre)	i=start_i_reg-i_step_reg;
								else i=i_reg+i_step_reg;
							end
						endcase
					end
				end
				MAXP:begin
					case(cnt)
						0:begin
							if(j_frist)	i=i_reg+1;
							else	i=i_reg;
						end
						1:begin
							if(j_frist)	i=i_reg;
							else	i=i_reg+1;
						end
						2:	i=i_reg+1;
						3:	i=(i_reg>>1);
						4:begin
							if(j_frist)begin
								if(j_reg == index_img_size-1)	i=i_reg+2;
								else i=i_reg;
							end else begin
								if(i_reg == index_img_size-1)	i=0;
								else i=i_reg+2;
							end
						end
					endcase
				end
				ZOOM:begin
					case(cnt)
						0:	i=(start_i_reg==0)?i_reg*2:(i_reg*2+1);
						1:	i=((start_i_reg==0)~^j_frist)?i_reg*2:(i_reg*2+1);
						2:	i=(start_i_reg==0)?(i_reg*2+1):i_reg*2;
						3:	i=((start_i_reg==0)~^j_frist)?(i_reg*2+1):i_reg*2;
						4:begin
							if(j_frist)begin
								if(j_reg == 0)	i=i_reg-1;
								else i=i_reg;
							end else begin
								if(i_reg == 0)	i=index_img_size;
								else i=i_reg-1;
							end
						end
					endcase
				end
				SB:begin
					if(cnt==0)	i=i_reg-shift_index;
					else begin
						if(j_reg == index_img_size-shift_index)
							i=i_reg+1;
						else i=i_reg;
					end
				end
			endcase	
		end
		OUTPUT:begin
			if(con_cnt>2*img_size_reg)begin
				if(j_frist)begin
					if(j_reg == j_max)	i=i_reg+i_step_reg;
					else i=i_reg;
				end else begin
					if(i_reg == i_max)	i=start_i_reg;
					else i=i_reg+i_step_reg;
				end
			end
		end
	endcase
end

always@(*)begin
	j = j_reg;
	case(current_state)
		IDLE: begin
			j = 0;
		end
		INPUT:begin
			if(j_reg<index_img_size)	j=j_reg+1;
			else j = 0;
		end
		ACT_DEF:begin 
			j = start_j;
			if(current_act_num!=num_act)begin
				case(act_reg[current_act_num])
					CON:	j = (start_j_reg==0)?-1:img_size_reg;
					MAXP:	j = 0;
					ZOOM:	j = index_img_size;
					SB:	j = shift_index;
				endcase
			end
		end
		ACT:begin
			case(current_act)
				CON:begin
					if(j_frist)begin
						case(cnt)
							0:j=j_reg+j_step_reg;
							1:j=j_reg+2*j_step_reg;
							2:j=j_reg;
							3:j=j_reg+j_step_reg;
							4:j=j_reg+2*j_step_reg;
							5:j=j_reg;
							6:j=j_reg+j_step_reg;
							7:j=j_reg+2*j_step_reg;
							8:j=j_reg+j_step_reg;
							9:begin
								if(j_reg == j_max_pre)	j=start_j_reg-j_step_reg;
								else j=j_reg+j_step_reg;
							end
						endcase
					end else begin
						case(cnt)
							0:j=j_reg;
							1:j=j_reg;
							2:j=j_reg+j_step_reg;
							3:j=j_reg+j_step_reg;
							4:j=j_reg+j_step_reg;
							5:j=j_reg+2*j_step_reg;
							6:j=j_reg+2*j_step_reg;
							7:j=j_reg+2*j_step_reg;
							8:j=j_reg-j_step_reg;
							9:begin
								if(i_reg == i_max_pre)	j=j_reg+j_step_reg;
								else j=j_reg;
							end
						endcase
					end
				end
				MAXP:begin
					case(cnt)
						0:begin
							if(j_frist)begin
								j=j_reg;
							end else begin
								j=j_reg+1;
							end
						end
						1:begin
							if(j_frist)	j=j_reg+1;
							else j=j_reg;
						end
						2:	j=j_reg+1;
						3:	j=(j_reg>>1);
						4:begin
							if(j_frist)begin
								if(j_reg == index_img_size-1)	j=0;
								else j=j_reg+2;
							end else begin
								if(i_reg == index_img_size-1)	j=j_reg+2;
								else j=j_reg;
							end
						end
					endcase
				end
				ZOOM:begin
					case(cnt)
						0:	j=(start_j_reg==0)?j_reg*2:(j_reg*2+1);
						1:	j=((start_j_reg==0)~^j_frist)?(j_reg*2+1):j_reg*2;//right
						2:	j=(start_j_reg==0)?(j_reg*2+1):j_reg*2;
						3:	j=((start_j_reg==0)~^j_frist)?j_reg*2:(j_reg*2+1);//bottom
						4:begin
							if(j_frist)begin
								if(j_reg == 0)	j=index_img_size;
								else j=j_reg-1;
							end else begin
								if(i_reg == 0)	j=j_reg-1;
								else j=j_reg;
							end
						end
					endcase 
				end
				SB:begin
					if(cnt==0)	j=j_reg-shift_index;
					else begin
						if(j_reg == index_img_size-shift_index)//16-4=12,8-2=6
							j = shift_index;
						else j = j_reg+1;
					end
				end
			endcase	
		end
		OUTPUT:begin
			if(con_cnt>2*img_size_reg)begin
				if(j_frist)begin
					if(j_reg == j_max)	j=start_j_reg;
					else j=j_reg+j_step_reg;
				end else begin
					if(i_reg == i_max)	j=j_reg+j_step_reg;
					else j=j_reg;
				end
			end
		end
	endcase
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		i_reg<=0;
		j_reg<=0;
	end else begin
		case(current_state)
			IDLE:begin
				i_reg<=0;
				j_reg<=0;
			end
			ACT:begin
				case(current_act)
					CON:begin
						if(cnt==9)begin
							i_reg<=i;
							j_reg<=j;
						end
					end
					MAXP:begin
						if(cnt==4)begin
							i_reg<=i;
							j_reg<=j;
						end
					end
					ZOOM:begin
						if(cnt==4)begin
							i_reg<=i;
							j_reg<=j;
						end
					end
					SB:begin
						if(cnt==1)begin
							i_reg<=i;
							j_reg<=j;
						end
					end
					default:begin
						i_reg<=i;
						j_reg<=j;
					end
				endcase
			end
			default:begin
				i_reg<=i;
				j_reg<=j;
			end
		endcase
	end
end

always@(posedge clk)begin
	//if(current_state==IDLE||current_state==ACT_DEF)	cnt<=0;
	if(current_state==ACT) begin
		case(current_act)
			CON:begin
				if(cnt<9)	cnt <= cnt+1;
				else cnt <= 0;	
			end
			MAXP:begin//0~4
				if(cnt<4)	cnt <= cnt+1;
				else cnt <= 0;
			end
			ZOOM:begin//0~4
				if(cnt<4)	cnt <= cnt+1;
				else cnt <= 0;
			end
			SB:begin
				if(cnt<1)	cnt <= cnt+1;
				else cnt <= 0;
			end
		endcase
	end else cnt<=0;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) con_cnt<=0;
	else begin
		case(current_state)
			ACT_DEF:begin
				if(num_act==current_act_num) con_cnt<=con_cnt+1;
			end
			ACT:begin
				if(cnt==8) con_cnt<=con_cnt+1;
				else if(con_cnt==img_size_reg*img_size_reg) con_cnt<=0;
			end
			OUTPUT:	con_cnt<=con_cnt+1;
			default:con_cnt<=0;
		endcase
	end
end
assign zero_or_not=(i<0)||(i==img_size_reg)||(j<0)||(j==img_size_reg);
assign div_out=div_in/3;//17bits
assign mult_out=multi_in*2;//17bits
assign add_out=add_in+adjust;//16bits
assign shift_out=(shift_in>>>1);//16bits
assign con_result=(multi_in1*multi_in2)+add_in2;


always@(*)begin
	result=result_reg;
	div_in=0;
	multi_in=0;
	add_in=0;
	shift_in=0;
	adjust=20;
	add_in2 = con_result_reg;
	multi_in1 = (zero_or_not_reg)?0:Q0;////
	multi_in2 = 0;
	case(current_act)
		CON:begin
			case(cnt)
				0:begin
					add_in2 = 0;
					multi_in2 = temp_reg[0];
				end
				1:begin
					multi_in2=temp_reg[1];
				end
				2:begin
					multi_in2=temp_reg[2];
				end
				3:begin
					multi_in2=temp_reg[3];
				end
				4:begin
					multi_in2=temp_reg[4];
				end
				5:begin
					multi_in2=temp_reg[5];
				end
				6:begin
					multi_in2=temp_reg[6];
				end
				7:begin
					multi_in2=temp_reg[7];
				end
				8:begin
					multi_in2=temp_reg[8];
				end				
			endcase
		end
		MAXP:begin//0~4
			if(cnt==0)
				result = Q0;
			else begin
				if(result<Q0)
					result = Q0;
			end
		end
		ZOOM:begin
			case(cnt)
				0:begin
					result=Q0;
				end
				1:begin
					div_in=result_reg;
					multi_in=result_reg;
				end
				2:begin
					div_in=mult_out_reg;
					shift_in=result_reg;
				end
				3:begin
					add_in=div_out_reg;
				end
			endcase
		end
		SB:begin
			adjust=50;
			if(cnt==0)begin
				shift_in = Q0;
				add_in = shift_out;
			end 
		end
	endcase
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		result_reg<=0;
		div_out_reg<=0;
		mult_out_reg<=0;
		zero_or_not_reg<=0;
	end else begin
		result_reg<=result;
		div_out_reg<=div_out;
		mult_out_reg<=mult_out;
		zero_or_not_reg<=zero_or_not;
	end 
end
always@(posedge clk) begin
	if(current_state == IDLE)begin
		max_con_result_reg <= {1'd1,39'd0};
		max_index_reg <= 0;
	end else if(cnt==8 && con_result> max_con_result_reg)begin
		max_con_result_reg<=con_result;
		max_index_reg<=con_cnt;
	end
end
always@(posedge clk)begin
	if(current_state==IDLE)begin
		con_result_reg<=0;
	end else if(current_act==CON)begin
		con_result_reg<=con_result;
	end
end

assign xe0=(max_x==0);
assign xei=(max_x==index_img_size);
assign ye0=(max_y==0);
assign yei=(max_y==index_img_size);
always@(*) begin
	case({xe0,xei,ye0,yei})
		4'b0000:begin
			case(con_cnt)
				1:img_pos = max_index_reg-img_size_reg-1;
				2:img_pos = max_index_reg-img_size_reg;
				3:img_pos = max_index_reg-img_size_reg+1;
				4:img_pos = max_index_reg-1;
				5:img_pos = max_index_reg;
				6:img_pos = max_index_reg+1;
				7:img_pos = max_index_reg+img_size_reg-1;
				8:img_pos = max_index_reg+img_size_reg;
				9:img_pos = max_index_reg+img_size_reg+1;
				default:img_pos = 0;
			endcase
		end
		4'b0001:begin
			case(con_cnt)
				1:img_pos = max_index_reg-img_size_reg-1;
				2:img_pos = max_index_reg-img_size_reg;
				3:img_pos = max_index_reg-1;
				4:img_pos = max_index_reg;
				5:img_pos = max_index_reg+img_size_reg-1;
				6:img_pos = max_index_reg+img_size_reg;
				default:img_pos = 0;
			endcase
		end
		4'b0010:begin
			case(con_cnt)
				1:img_pos = max_index_reg-img_size_reg;
				2:img_pos = max_index_reg-img_size_reg+1;
				3:img_pos = max_index_reg;
				4:img_pos = max_index_reg+1;
				5:img_pos = max_index_reg+img_size_reg;
				6:img_pos = max_index_reg+img_size_reg+1;
				default:img_pos = 0;
			endcase
		end
		4'b0100:begin
			case(con_cnt)
				1:img_pos = max_index_reg-img_size_reg-1;
				2:img_pos = max_index_reg-img_size_reg;
				3:img_pos = max_index_reg-img_size_reg+1;
				4:img_pos = max_index_reg-1;
				5:img_pos = max_index_reg;
				6:img_pos = max_index_reg+1;
				default:img_pos = 0;
			endcase
		end
		4'b1000:begin
			case(con_cnt)
				1:img_pos = max_index_reg-1;
				2:img_pos = max_index_reg;
				3:img_pos = max_index_reg+1;
				4:img_pos = max_index_reg+img_size_reg-1;
				5:img_pos = max_index_reg+img_size_reg;
				6:img_pos = max_index_reg+img_size_reg+1;
				default:img_pos = 0;
			endcase
		end
		4'b1010:begin
			case(con_cnt)
				1:img_pos = max_index_reg;
				2:img_pos = max_index_reg+1;
				3:img_pos = max_index_reg+img_size_reg;
				4:img_pos = max_index_reg+img_size_reg+1;
				default:img_pos = 0;
			endcase
		end
		4'b1001:begin
			case(con_cnt)
				1:img_pos = max_index_reg-1;
				2:img_pos = max_index_reg;
				3:img_pos = max_index_reg+img_size_reg-1;
				4:img_pos = max_index_reg+img_size_reg;
				default:img_pos = 0;
			endcase
		end
		4'b0110:begin
			case(con_cnt)
				1:img_pos = max_index_reg-img_size_reg;
				2:img_pos = max_index_reg-img_size_reg+1;
				3:img_pos = max_index_reg;
				4:img_pos = max_index_reg+1;
				default:img_pos = 0;
			endcase
		end
		4'b0101:begin
			case(con_cnt)
				1:img_pos = max_index_reg-img_size_reg-1;
				2:img_pos = max_index_reg-img_size_reg;
				3:img_pos = max_index_reg-1;
				4:img_pos = max_index_reg;
				default:img_pos = 0;
			endcase
		end
		default:img_pos = 0;
	endcase
end
always@(posedge clk)begin

end

always@(*)begin
	case(img_size_reg)
		4:begin
			max_x=max_index_reg[3:2];
			max_y=max_index_reg[1:0];
		end
		8:begin
			max_x=max_index_reg[5:3];
			max_y=max_index_reg[2:0];
		end
		default:begin//16
			max_x=max_index_reg[7:4];
			max_y=max_index_reg[3:0];
		end
	endcase
end
// Output Assignment
 always@(posedge clk or negedge rst_n) begin
 	if(!rst_n) begin
 		out_valid   <= 0;
 		out_x       <= 0;
 		out_y       <= 0;
 		out_img_pos <= 0;
 		out_value   <= 0;
 	end
 	else if(current_state == OUTPUT) begin 
 		out_valid   <= 1;
 		out_x       <= max_x;
 		out_y       <= max_y;
 		out_img_pos <= img_pos;
 		out_value   <= Q0;
 	end 
 	else begin
 		out_valid   <= 0;
 		out_x       <= 0;
 		out_y       <= 0;
 		out_img_pos <= 0;
 		out_value   <= 0;
 	end
 end

endmodule