//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      (C) Copyright NYCU SI2 Lab      
//            All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2022 ICLAB SPRING Course
//   Lab05		: SRAM, Template Matching with Image Processing
//   Author     : Yu-Wei Lu
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESTBED.v
//   Module Name : TESTBED
//   Release version : v2.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
	`include "TMIP.v"
	`define CYCLE_TIME 12.0
`endif
`ifdef GATE
	`timescale 1ns/10ps
	`include "TMIP_SYN.v"
	`define CYCLE_TIME 8.0
`endif

module PATTERN(
// output signals
    clk,
    rst_n,
    in_valid,
	in_valid_2,
    image,
    img_size,
    template, 
    action,
// input signals
    out_valid,
    out_x,
    out_y,
    out_img_pos,
    out_value
);
output reg        clk, rst_n, in_valid, in_valid_2;
output reg signed [15:0] image, template;
output reg [4:0]  img_size;
output reg [2:0]  action;

input         out_valid;
input [3:0]   out_x, out_y; 
input [7:0]   out_img_pos;
input signed[39:0]  out_value;
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
integer patcount;
parameter PATNUM = 300;

integer in_read,out_read;
integer i,j,a,gap;

integer instr_number, outflag, out_img_pos_num;
reg signed[15:0] image_reg[0:255];
reg signed[15:0] template_reg[0:8];
reg [4:0] img_size_reg;
reg [2:0] instr[0:15];

reg [4:0] out_img_size_reg;
reg [3:0] out_x_reg, out_y_reg;
reg [7:0] out_img_pos_reg[0:8];
reg signed [39:0] out_image_reg[0:255];

integer counter;
integer curr_cycle, cycles, total_cycles;
//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

initial begin
    in_read = $fopen("../00_TESTBED/input.txt", "r");
	out_read = $fopen("../00_TESTBED/output.txt", "r");
    rst_n = 1'b1;
    in_valid = 'b0;
    in_valid_2 = 'b0;
    image = 'bx;
    img_size = 'bx;
    template = 'bx;
    action = 'bx;

    curr_cycle = 0;
	force clk = 0;
    reset_task;
    for(patcount = 0;patcount<PATNUM; patcount = patcount+1)begin
		curr_cycle = 0;
		load_input;
		load_output;
		input_task;
		wait_outvalid_task;
		check_answer;
	end
	repeat(5) @(negedge clk);
    YOU_PASS_task;
end

task load_output;begin
	// load out img size
	a = $fscanf(out_read, "%d\n", out_img_size_reg);

	// load x y
	a = $fscanf(out_read, "%d\n", out_y_reg);
	a = $fscanf(out_read, "%d\n", out_x_reg);

	// load out_img_pos_reg
	a = $fscanf(out_read, "%d\n", out_img_pos_num);
	for(i=0; i<out_img_pos_num; i=i+1)begin
		a = $fscanf(out_read, "%d\n", out_img_pos_reg[i]);
	end
	
	// load image
	for(i=0; i<256; i=i+1)begin
			out_image_reg[i] = 0;
	end
	if(out_img_size_reg == 4)begin
		for(i=0; i<16; i=i+1)begin
			a = $fscanf(out_read, "%d\n", out_image_reg[i]);
		end
	end
	else if(out_img_size_reg == 8)begin
		for(i=0; i<64; i=i+1)begin
			a = $fscanf(out_read, "%d\n", out_image_reg[i]);
		end
	end
	else if(out_img_size_reg == 16)begin
		for(i=0; i<256; i=i+1)begin
			a = $fscanf(out_read, "%d\n", out_image_reg[i]);
		end
	end
end endtask

task load_input; begin
	// load img size
	a = $fscanf(in_read, "%d\n", img_size_reg);
	
	// load tempplate
	for(i=0; i<9; i=i+1)begin
		a = $fscanf(in_read, "%d\n", template_reg[i]);
	end

	// load series action
	instr_number = 0;
	outflag = 0;
	for (i=0; i<16; i=i+1) begin
		instr[i] = 0;
	end
	while (outflag==0) begin
		a = $fscanf(in_read, "%d\n", instr[instr_number]);
		if(instr[instr_number] == 0) outflag = 1;
		instr_number = instr_number + 1;
	end

	// for test one action
	// instr_number = 1;
	// a = $fscanf(in_read, "%d\n", instr[0]);

	// load image
	for(i=0; i<256; i=i+1)begin
			image_reg[i] = 0;
	end
	if(img_size_reg == 4)begin
		for(i=0; i<16; i=i+1)begin
			a = $fscanf(in_read, "%d\n", image_reg[i]);
		end
	end
	else if(img_size_reg == 8)begin
		for(i=0; i<64; i=i+1)begin
			a = $fscanf(in_read, "%d\n", image_reg[i]);
		end
	end
	else if(img_size_reg == 16)begin
		for(i=0; i<256; i=i+1)begin
			a = $fscanf(in_read, "%d\n", image_reg[i]);
		end
	end
	
end endtask

task input_task; begin
	$display ("start Pattern No.%1d",patcount);
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);
	
	in_valid = 1'b1;
	
	counter = 0;
	// input Image
	if(img_size_reg == 4)begin
		for(i=0; i<16; i=i+1)begin
			image = image_reg[i];
			if(counter < 9) template = template_reg[counter];
			else template = 'dx;
			if(counter == 0) img_size = img_size_reg;
			else img_size = 'dx;
			counter = counter + 1;
			@(negedge clk);
		end
	end
	else if(img_size_reg == 8)begin
		for(i=0; i<64; i=i+1)begin
			image = image_reg[i];
			if(counter < 9) template = template_reg[counter];
			else template = 'dx;
			if(counter == 0) img_size = img_size_reg;
			else img_size = 'dx;
			counter = counter + 1;
			@(negedge clk);
		end
	end
	else if(img_size_reg == 16)begin
		for(i=0; i<256; i=i+1)begin
			image = image_reg[i];
			if(counter < 9) template = template_reg[counter];
			else template = 'dx;
			if(counter == 0) img_size = img_size_reg;
			else img_size = 'dx;
			counter = counter + 1;
			@(negedge clk);
		end
	end
	in_valid = 'b0;
	image = 'dx;
	img_size = 'dx;
    template = 'dx;
	@(negedge clk);
	in_valid_2 = 'b1;
	for(i=0; i<instr_number; i=i+1)begin
		action = instr[i];
		@(negedge clk);
	end
	in_valid_2 = 'b0;
	action = 'dx;
end endtask

task wait_outvalid_task ; begin
	cycles = 0 ;
	while( out_valid!==1 ) begin
		cycles = cycles + 1 ;
		if ((out_valid!==0) || (out_x!==0) || (out_y!==0) || (out_img_pos!==0) || (out_value!==0)) begin
			reset_fail;
		end
		if (cycles==10000) begin
			
            // Spec. 6
            // The  execution  latency  is  limited  in  300  cycles.  
            // The  latency  is  the  clock  cycles  between  the falling edge of the last in_valid_d and the rising edge of the first out_valid. 
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                            Exceed maximun cycle!!!                                                         ");
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(5)  @(negedge clk);
            $finish;
		end
		@(negedge clk);
	end
	total_cycles = total_cycles + cycles ;
end endtask

task reset_task ;  begin
	#(20); rst_n = 0;
	#(20);
	if((out_valid!==0) || (out_x!==0) || (out_y!==0) || (out_img_pos!==0) || (out_value!==0))begin
		reset_fail;
	end
	#(20);rst_n = 1;
	#(6); release clk;
end endtask

task check_answer; begin
	curr_cycle = 0;
	while(out_valid==0)begin
		@(negedge clk);
	end
	counter = 0;
	while(out_valid)begin
		if((counter==256 && out_img_size_reg == 16)||(counter==64 && out_img_size_reg == 8)||(counter==16 && out_img_size_reg == 4))begin
			$display ("----------------------------------------------------------------------------------------------------------------------");
			$display ("                                                Your out_valid cycles are too long!             						 ");
			$display ("----------------------------------------------------------------------------------------------------------------------");
			repeat(1)  @(negedge clk);
			$finish;
		end
		if(out_img_pos !== out_img_pos_reg[counter] && counter < out_img_pos_num)begin
			$display ("----------------------------------------------------------------------------------------------------------------------");
			$display ("                                                Your out_img_pos is Wrong!             						             ");
			$display ("                                                  Your Answer is : %d       	                                     ",out_img_pos);
			$display ("                                               Correct Answer is : %d           			                         ", out_img_pos_reg[counter]);
			$display ("----------------------------------------------------------------------------------------------------------------------");
			repeat(1)  @(negedge clk);
			$finish;
		end
		else if(out_img_pos !== 0 && counter > out_img_pos_num)begin
			$display ("----------------------------------------------------------------------------------------------------------------------");
			$display ("                                                Your out_img_pos should be 0!             						     ");
			$display ("----------------------------------------------------------------------------------------------------------------------");
			repeat(1)  @(negedge clk);
			$finish;
		end
		if(out_value !== out_image_reg[counter])begin
			$display ("----------------------------------------------------------------------------------------------------------------------");
			$display ("                                                Your out_value is Wrong!             						             ");
			$display ("                                                  Your Answer is : %d       	                                     ",out_value);
			$display ("                                               Correct Answer is : %d           			                         ", out_image_reg[counter]);
			$display ("----------------------------------------------------------------------------------------------------------------------");
			repeat(1)  @(negedge clk);
			$finish;
		end
		if(out_x !== out_x_reg || out_y !== out_y_reg)begin
			$display ("----------------------------------------------------------------------------------------------------------------------");
			$display ("                                                Your out_x or out_y is Wrong!             						             ");
			$display ("                                                  Your Answer is : %d %d       	                                     ",out_x,out_y);
			$display ("                                               Correct Answer is : %d %d          			                         ", out_x_reg,out_y_reg);
			$display ("----------------------------------------------------------------------------------------------------------------------");
			repeat(1)  @(negedge clk);
			$finish;
		end
		counter = counter + 1;
		curr_cycle = curr_cycle+1;	
		@(negedge clk);
	end
	if((counter<=255 && out_img_size_reg == 16)||(counter<=63 && out_img_size_reg == 8)||(counter<=15 && out_img_size_reg == 4))begin
		$display ("----------------------------------------------------------------------------------------------------------------------");
		$display ("                                        Your out_valid cycles are less than requirement!    						     ");
		$display ("----------------------------------------------------------------------------------------------------------------------");
		repeat(1)  @(negedge clk);
		$finish;
	end
end endtask

task reset_fail ; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Oops! Reset is Wrong                						             ");
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask

task YOU_PASS_task; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						             ");
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask
endmodule