`ifdef RTL
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 2.1
	`define CYCLE_TIME_clk2 15
`endif
`ifdef GATE
	`timescale 1ns/1ps
	// `define CYCLE_TIME_clk1 2.1
	// `define CYCLE_TIME_clk2 18
	// `define CYCLE_TIME_clk1 16
	// `define CYCLE_TIME_clk2 15
	`define CYCLE_TIME_clk1 15
	`define CYCLE_TIME_clk2 15
`endif
/*
To do:
1. check 3996 data
2. same performance need to ouput last one(maybe check cpp ?)
3. update random delay
*/

module PATTERN #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Output Port
	rst_n,
	clk1,
    clk2,
	in_valid,
	in_account,
	in_A,
	in_T,

    //Input Port
	ready,
    out_valid,
	out_account
); 
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg				rst_n, clk1, clk2, in_valid;
output reg [DSIZE-1:0] 	in_account,in_A,in_T;

input 				ready, out_valid;
input [DSIZE-1:0] 	out_account;

//================================================================
// parameters & integer
//================================================================
real CYCLE1 = `CYCLE_TIME_clk1;
real CYCLE2 = `CYCLE_TIME_clk2;
integer input_file,output_file;
integer gap;
integer a,b,c,d;
integer i,j,k;
integer input_count;
integer output_count;
integer cycle_count;
integer fail;
reg [7:0]golden[0:3995];
reg [7:0]account_reg [0:3999];
reg [7:0]T_reg [0:3999];
reg [7:0]A_reg [0:3999];
reg [15:0] mult_reg [0:3999];
//================================================================
// clock
//================================================================
initial clk1 = 0;
initial clk2 = 0;
always #(CYCLE1/2.0) clk1 = ~clk1;
always #(CYCLE2/2.0) clk2 = ~clk2;
//================================================================
// initial
//================================================================

always@(negedge clk2 or negedge rst_n)begin
	if(!rst_n)
		output_count<=0;
	else if(out_valid)
		output_count<=output_count+1;
end

always@(negedge clk2)begin
	if(!rst_n) cycle_count = 0;
	else cycle_count = cycle_count + 1;
	if(out_valid==1 && golden[output_count]!=out_account)begin
		fail=1;
		// if you almost done you can open this to check where is wrong
		
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                   Current Output Num = %2d							 					                   ",output_count);
		$display ("                                                  Correct Answer = %2d, Your Answer = %2d		 					                       ",golden[output_count],out_account);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$finish ;
		
	end
	else if(out_valid==1 && golden[output_count]==out_account)begin
		$display("PASS PATTERN NO.%4d", output_count);
	end
	
end

always@(*)begin
	if(cycle_count>100000)begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                   Exceed limit cycle							 					                       ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$finish ;
	end
		
end

initial begin
	input_file  = $fopen("../00_TESTBED/input.txt","r");
  	output_file = $fopen("../00_TESTBED/output.txt","r");
	rst_n = 1;
	in_valid = 'b0;
	in_account = 'bx;
	in_A = 'bx;
	in_T = 'bx;
	input_count = 0;
	//output_count = 1;
	fail = 0;
	cycle_count = 1;
	force clk1 = 0;
	force clk2 = 0;
	reset_task;
	load_input_task;
	load_output_task;
	@(negedge clk1);
	stream_task;
	wait_all_output;
	//repeat(5) @(negedge clk1);
	//if(output_count!=3996) fail=1;
	if(fail==1)begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                   Your Answer Is Wrong							 					                       ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$finish ;
	end
	else begin
		YOU_PASS_task;
	end
end 
//================================================================
// task
//================================================================
task reset_task ; begin
	#(10); rst_n = 0;
	#(30);
	if((out_valid !== 0) || (out_account !== 0) || (ready!==0)) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		#(100);
	    $finish ;
	end
	#(10); rst_n = 1 ;
	#(3.0); release clk1; release clk2;
end endtask

task load_input_task ; begin
	for(i=0;i<4000;i=i+1)begin
		a = $fscanf(input_file,"%d",account_reg[i]);
		a = $fscanf(input_file,"%d",T_reg[i]);
		a = $fscanf(input_file,"%d",A_reg[i]);
		a = $fscanf(input_file,"%d",mult_reg[i]);
	end
	
end endtask

task load_output_task ; begin
	for(i=0;i<3996;i=i+1)begin
		a = $fscanf(output_file,"%d", golden[i]);
	end
end endtask

integer total_gap;

task stream_task ; begin
	total_gap = 0;
	while(input_count!=4000)begin
		if(ready)begin
			// if(gap!=0)begin
			// 	in_valid = 1'b0;
			// 	in_account = 'bx;
			// 	in_A = 'bx;
			// 	in_T = 'bx;
			// 	repeat(gap)begin
			// 	@(negedge clk1);
			// 	cycle_count = cycle_count+1;
			// 	total_gap = total_gap+1;
			// 	end
			// end
			if(total_gap<550) begin
				gap = $urandom_range(0,150);
				total_gap = total_gap + gap;
				in_valid = 1'b0;
				in_account = 'bx;
				in_A = 'bx;
				in_T = 'bx;
				repeat(gap) @(negedge clk1);
			end
			// if(gap!=0)begin
			// 	in_valid = 1'b0;
			// 	in_account = 'bx;
			// 	in_A = 'bx;
			// 	in_T = 'bx;
			// 	repeat(gap) @(negedge clk1);
			// end

			gap = 0;
			in_valid = 1'b1;
			in_account = account_reg[input_count];
			in_A = A_reg[input_count];
			in_T = T_reg[input_count];
			// $display (" %d", input_count);
			// $display (" %d", A_reg[input_count]);
		end 
		else begin
			// if(total_gap==500)begin
			// 	gap = 0;
			// end
			// else begin
			// 	gap = $urandom_range(0,150);
			// 	while(total_gap+gap>500)begin
			// 		gap = $urandom_range(0,150);
			// 	end
			// end
			in_valid = 'b0;
			in_account = 'bx;
			in_A = 'bx;
			in_T = 'bx;
		end
		
		@(negedge clk1);
		// cycle_count = cycle_count+1;
		if(ready)begin
			input_count = input_count+1;
		end 
	
	end
	in_valid = 'b0;
	in_account = 'bx;
	in_A = 'bx;
	in_T = 'bx;
end endtask

task wait_all_output; begin
	while(output_count!=3996)begin
		@(negedge clk2);
		// cycle_count = cycle_count +1;
	end
end endtask

task YOU_PASS_task; begin
	
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						             ");
	$display ("                                           You have passed all patterns!          						             ");
	$display ("                                           Your execution cycles = %5d cycles   						                 ", cycle_count);
	$display ("                                           Your clock period = %.1f ns        					                     ", `CYCLE_TIME_clk1);
	$display ("                                           Your total latency = %.1f ns         						                 ", cycle_count*`CYCLE_TIME_clk1);
	$display ("                                           Your Performance Score = %.1f ns         						             ", cycle_count*`CYCLE_TIME_clk1*`CYCLE_TIME_clk1);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask

endmodule 