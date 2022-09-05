// synopsys translate_off 
`include "GATED_OR.v"
// synopsys translate_on
module IDC(
	// Input signals
	clk,
	rst_n,
	cg_en,
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
input		cg_en;
input signed [6:0] in_data;
input [3:0] op;

output reg 		  out_valid;//
output reg  signed [6:0] out_data;

parameter Midpoint=0;
parameter Average =1;
parameter CCW     =2;
parameter CW      =3;
parameter Flip    =4;
parameter Up      =5;
parameter Left    =6;
parameter Down    =7;
parameter Right   =8;

parameter IDLE   =0; 
parameter INPUT  =1;
parameter OUTPUT =2;
parameter FAIL   =3;


integer i;
genvar c,d;

reg signed[6:0]image[0:63];
reg [6:0]input_cnt;

reg [3:0]out_cnt;
reg [5:0]current_pos;
reg [3:0]op_list[0:14]; 
reg [3:0]current_op_idx;

reg [5:0]out_addr;
reg signed[6:0]result_a,result_b,result_c,result_d;

wire mode;
wire gated_clk[0:63];
wire [3:0]current_op;
wire done;
wire signed[6:0]num_a,num_b,num_c,num_d;




wire clk_cs;

reg [1:0]current_state;
reg [1:0]next_state;


//FSM
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)current_state<=IDLE;
	else      current_state<=next_state;
end

always@*begin
	next_state=current_state;
	case(current_state)
		IDLE:  if(in_valid)   next_state=INPUT;
		INPUT: if(current_op_idx==15 && input_cnt==64)  next_state=OUTPUT;
		OUTPUT:if(out_cnt==15)next_state=IDLE;
	endcase
end

//the four numbers that pointer point to
assign current_op = (current_op_idx==15?0:op_list[current_op_idx]);
assign num_a = image[current_pos  ];
assign num_b = image[current_pos+1];
assign num_c = image[current_pos+8];
assign num_d = image[current_pos+9];





wire input_sleep_n[0:63]; //the sleep signal will become 1 after input the nth input data
wire sleep_n[0:63];       //when the date will not be modify,the sleep signal is 1
generate
	for (c = 0; c < 64; c = c + 1) begin: GATED_0
		assign input_sleep_n[c] = !(input_cnt==c);
		GATED_OR GATED_(.CLOCK(clk),.SLEEP_CTRL(sleep_n[c] && input_sleep_n[c] && cg_en),.RST_N(rst_n),.CLOCK_GATED(gated_clk[c]));
	end
endgenerate



wire cond1 = (current_op_idx<15 && done && current_op<5 ); //indicate whether the operation been process has finish
assign done = (input_cnt>current_pos+9 || current_op > 4 && input_cnt!=0 ); //indicate whether all operation have been done 


wire [5:0]cmp0 = current_pos;
wire [5:0]cmp1 = current_pos+1;
wire [5:0]cmp2 = current_pos+8;
wire [5:0]cmp3 = current_pos+9;

//count the input progress
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		input_cnt<=0;
	end
	else
	begin
		if(current_state==OUTPUT)input_cnt<=0;
		else if(in_valid && input_cnt<64)input_cnt<=input_cnt+1;
	end
end



assign sleep_n[0]  = !((current_pos==0)&&done&&current_op_idx!=15 );
assign sleep_n[56] = !((current_pos==48)&&done&&current_op_idx!=15);
assign sleep_n[7]  = !((current_pos==6)&&done&&current_op_idx!=15 );
assign sleep_n[63] = !((current_pos==54)&&done&&current_op_idx!=15);


//update the image register
always @(posedge gated_clk[0] or negedge rst_n) begin
	if(!rst_n)
		image[0] <= 0;
	else begin
		if(input_cnt==0&& in_valid)
			image[0]<=in_data;
		else if(cond1)
			if     (cmp0==0) 
				image[0] <= result_a;
	end
end
always @(posedge gated_clk[56] or negedge rst_n) begin
	if(!rst_n)
		image[56] <= 0;
	else begin
		if(input_cnt==56&& in_valid)
			image[56]<=in_data;
		else if(cond1)
			if     (cmp2==56) 
				image[56] <= result_c;
	end
end
always @(posedge gated_clk[7] or negedge rst_n) begin
	if(!rst_n)
		image[7] <= 0;
	else begin
		if(input_cnt==7&& in_valid)
			image[7]<=in_data;
		else if(cond1)
			if     (cmp1==7) 
				image[7] <= result_b;
	end
end
always @(posedge gated_clk[63] or negedge rst_n) begin
	if(!rst_n)
		image[63] <= 0;
	else begin
		if(input_cnt==63&& in_valid)
			image[63]<=in_data;
		else if(cond1)
			if     (cmp3==63) 
				image[63] <= result_d;
	end
end

generate
    for (c = 1; c <= 6; c = c + 1) begin: img0
		assign sleep_n[c] = !(((cmp0==c)||(cmp1==c))&&done&&current_op_idx!=15);
        always @(posedge gated_clk[c] or negedge rst_n) begin
			if(!rst_n)
				image[c] <= 0;
			else begin
				if(input_cnt==c&& in_valid)
					image[c]<=in_data;
				else if(cond1)
					if     (cmp0==c) 
						image[c] <= result_a;
					else if(cmp1==c)
						image[c] <= result_b;
			end
        end
    end
endgenerate

generate
    for (c = 8; c <= 48; c = c + 8) begin: img1
		assign sleep_n[c] = !(((cmp0==c)||(cmp2==c))&&done&&current_op_idx!=15);
        always @(posedge gated_clk[c] or negedge rst_n) begin
			if(!rst_n)
				image[c] <= 0;
			else begin
				if(input_cnt==c&& in_valid)
					image[c]<=in_data;
				else if(cond1)
					if     (cmp0==c) 
						image[c] <= result_a;
					else if(cmp2==c)
						image[c] <= result_c;
			end
        end
    end
endgenerate

generate
    for (c = 57; c <= 62; c = c + 1) begin: img2
		assign sleep_n[c] = !(((cmp2==c)||(cmp3==c))&&done&&current_op_idx!=15);
        always @(posedge gated_clk[c] or negedge rst_n) begin
			if(!rst_n)
				image[c] <= 0;
			else begin
				if(input_cnt==c&& in_valid)
					image[c]<=in_data;
				else if(cond1)
					if     (cmp2==c) 
						image[c] <= result_c;
					else if(cmp3==c)
						image[c] <= result_d;
			end
        end
    end
endgenerate

generate
    for (c = 15; c <= 55; c = c + 8) begin: img3
		assign sleep_n[c] = !(((cmp1==c)||(cmp3==c))&&done&&current_op_idx!=15);	
        always @(posedge gated_clk[c] or negedge rst_n) begin
			if(!rst_n)
				image[c] <= 0;
			else begin
				if(input_cnt==c&& in_valid)
					image[c]<=in_data;
				else if(cond1)
					if(cmp1==c)
						image[c] <= result_b;
					else if(cmp3==c)
						image[c] <= result_d;
			end
        end
    end
endgenerate

generate
	for(d=1;d<7;d=d+1)begin
		for (c = 1; c < 7; c = c + 1) begin: img4
			assign sleep_n[c+8*d] = !(((cmp0==c+8*d)||(cmp1==c+8*d)||(cmp2==c+8*d)||(cmp3==c+8*d))&&done&&current_op_idx!=15);
			always @(posedge gated_clk[c+8*d] or negedge rst_n) begin
				if(!rst_n)
					image[c+8*d] <= 0;
				else begin
					if(input_cnt==c+8*d && in_valid)
						image[c+8*d]<=in_data;
					else if(cond1)begin
						if     (cmp0==c+8*d)
							image[c+8*d] <= result_a;
						else if(cmp1==c+8*d)
							image[c+8*d] <= result_b;
						else if(cmp2==c+8*d)
							image[c+8*d] <= result_c;
						else if(cmp3==c+8*d)
							image[c+8*d] <= result_d;
					end
				end
			end
		end
	end
endgenerate


//update the current pointer
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		current_pos<=0;
	end
	else
	begin
		if(current_state==IDLE)
			current_pos<=27;
		else if(done)
			case(current_op)
				Left: if((current_pos%8)!=0)current_pos<=current_pos-1;
				Right:if((current_pos%8)!=6)current_pos<=current_pos+1;
				Up:   if(current_pos    >=7)current_pos<=current_pos-8;
				Down: if(current_pos   <=46)current_pos<=current_pos+8;
			endcase
	end
end

wire signed[6:0]big0,big1;
wire signed[6:0]small0,small1;
wire signed[6:0]mid0,mid1;

assign big0   = (num_a>num_b?num_a:num_b);
assign big1   = (num_c>num_d?num_c:num_d);
assign small0 = (num_a<num_b?num_a:num_b);
assign small1 = (num_c<num_d?num_c:num_d);
assign mid0   = (big0  <big1  ?big0  :big1  );
assign mid1   = (small0<small1?small1:small0);

//the result of operation
always @(*) begin
	if(done)
		case(current_op)
			Midpoint:begin
				result_a = (mid0+mid1)/2;
				result_b = result_a;
				result_c = result_a;
				result_d = result_a;
			end
			Average :begin
				result_a = (num_a+num_b+num_c+num_d)/4;
				result_b = result_a;
				result_c = result_a;
				result_d = result_a;
			end
			CCW     :begin
				result_a = num_b;
				result_b = num_d;
				result_c = num_a;
				result_d = num_c;
			end
			CW      :begin
				result_a = num_c;
				result_b = num_a;
				result_c = num_d;
				result_d = num_b;		
			end
			default    :begin
				result_a = ~num_a + 1;
				result_b = ~num_b + 1;
				result_c = ~num_c + 1;
				result_d = ~num_d + 1;		
			end
		endcase
	else
	begin
		result_a = 0;
		result_b = 0;
		result_c = 0;
		result_d = 0;	
	end
end


//store the inputed operation
generate
	for(c=0;c<15;c=c+1)begin
		always @(posedge gated_clk[c] or negedge rst_n) begin
			if(!rst_n)
				op_list[c]<=0;
			else if((input_cnt==c) && (in_valid==1))
				op_list[c]<=op;
		end
	end
endgenerate



//the index of operation list
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		current_op_idx<=0;
	end
	else
	begin
		if(current_state==IDLE)
			current_op_idx<=0;
		else if(done && current_op_idx!=15)
			current_op_idx<=current_op_idx+1;
	end
end


//count the progress of output
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)out_cnt<=0;
	else out_cnt<=out_cnt+(current_state==OUTPUT);
end

//if mode ==0 ,it mean zoom out,otherwise, it is zoom in
assign mode=(current_pos<=3&&current_pos>=0||current_pos<=11&&current_pos>=8||current_pos<=19&&current_pos>=16||current_pos<=27&&current_pos>=24);


//calculate addr of output
always@*begin
	if(mode==0)begin
		case(out_cnt)
			0 :out_addr=0;
			1 :out_addr=2;
			2 :out_addr=4;
			3 :out_addr=6;
			4 :out_addr=16;
			5 :out_addr=18;
			6 :out_addr=20;
			7 :out_addr=22;
			8 :out_addr=32;
			9 :out_addr=34;
			10:out_addr=36;
			11:out_addr=38;
			13:out_addr=50;
			12:out_addr=48;
			14:out_addr=52;
			15:out_addr=54;
		endcase			
	end
	else
	begin
		if(out_cnt<4)	   out_addr=current_pos+out_cnt+9 ;
		else if(out_cnt<8) out_addr=current_pos+out_cnt+13;
		else if(out_cnt<12)out_addr=current_pos+out_cnt+17;
		else 			   out_addr=current_pos+out_cnt+21;
	end
end

//update the output data with out_addr

always @(*) begin
	out_valid=(current_state==OUTPUT);
	if(current_state==OUTPUT)out_data=image[out_addr];
	else out_data=0;
end

endmodule // IDC