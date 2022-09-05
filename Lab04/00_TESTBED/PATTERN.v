`ifdef RTL
	`timescale 1ns/1fs
	`include "NN.v"  
	`define CYCLE_TIME 50.0 //50
`endif
`ifdef GATE
	`timescale 1ns/1fs
	`include "NN_SYN.v"
	`define CYCLE_TIME 50.0 //50
`endif

module PATTERN(
	// Output signals
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
	// Input signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;


parameter inst_arch = 2;
parameter input_dim = 8;
parameter first_layer_dim = 3;
parameter second_layer_dim = 3;
parameter output_dim = 1;
parameter PATNUM = 100;
parameter EPOCH = 25;
parameter REPAET = 2;
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg clk, rst_n, in_valid_i, in_valid_k, in_valid_o;
output reg [inst_sig_width+inst_exp_width:0] Kernel1, Kernel2, Kernel3;
output reg [inst_sig_width+inst_exp_width:0] Image1, Image2 ,Image3;
output reg [1:0] Opt;
input	out_valid;
input	[inst_sig_width+inst_exp_width:0] out;

//================================================================
// parameters & integer
//================================================================
integer in_read,out_read;
integer patcount;
integer a;
integer i;
integer gap;
integer curr_cycle, cycles, total_cycles;
integer SEED = 123;
parameter OUTPUT_CYCLE = 64;
reg [12:0]total_cycle;
reg [1:0] inOpt;
reg [inst_sig_width+inst_exp_width:0] inImage1[0:15];
reg [inst_sig_width+inst_exp_width:0] inImage2[0:15];
reg [inst_sig_width+inst_exp_width:0] inImage3[0:15];

reg [inst_sig_width+inst_exp_width:0] inKernal1[0:35];
reg [inst_sig_width+inst_exp_width:0] inKernal2[0:35];
reg [inst_sig_width+inst_exp_width:0] inKernal3[0:35];

reg [inst_sig_width+inst_exp_width:0] out_Answer[0:63];

//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

//================================================================
// PATTERN
//================================================================

// always@(negedge clk or posedge rst_n)begin
// 	if(!rst_n)
// 		total_cycle<=0;
// 	else 
// 		total_cycle<=total_cycle+1;
// end

// always@(*)begin
// 	if(total_cycle == 1000)begin
// 		$display("Exceed maximun cycle!!!");
// 		$display("Please Check Your design");
// 		$finish;
// 	end
// end

initial begin
	in_read = $fopen("../00_TESTBED/input.txt", "r");
	out_read = $fopen("../00_TESTBED/output.txt", "r");
	rst_n = 1'b1;
	in_valid_i = 'b0;
	in_valid_k = 'b0;
	in_valid_o = 'b0;
	Kernel1 = 'bx;
	Kernel2 = 'bx;
	Kernel3 = 'bx;
	Image1 = 'bx;
	Image2 = 'bx;
	Image3 = 'bx;
	Opt = 'bx;
	curr_cycle = 0;
	force clk = 0;
	reset_task;
	// a = $fscanf(in_read, "%d", PATNUM);
	for(patcount = 0;patcount<500; patcount = patcount+1)begin
		curr_cycle = 0;
		load_input;
		load_output;
		input_task;
		wait_outvalid_task;
		check_answer;
	end
	YOU_PASS_task;
end

task load_output;begin
	for(i=0;i<64;i=i+1)begin
		a = $fscanf(out_read, "%b\n", out_Answer[i]);
	end
end endtask

task load_input; begin

	a = $fscanf(in_read, "%d\n", inOpt);
	for(i=0; i<16; i=i+1)begin
		a = $fscanf(in_read, "%b\n", inImage1[i]);
	end
	for(i=0; i<16; i=i+1)begin
		a = $fscanf(in_read, "%b\n", inImage2[i]);
	end
	for(i=0; i<16; i=i+1)begin
		a = $fscanf(in_read, "%b\n", inImage3[i]);
	end
	for(i=0; i<36; i=i+1)begin
		a = $fscanf(in_read, "%b\n", inKernal1[i]);
	end
	for(i=0; i<36; i=i+1)begin
		a = $fscanf(in_read, "%b\n", inKernal2[i]);
	end
	for(i=0; i<36; i=i+1)begin
		a = $fscanf(in_read, "%b\n", inKernal3[i]);
	end
end endtask

task input_task; begin
	$display ("start Pattern No.%1d",patcount);
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);
	
	// input Opt
	in_valid_o = 1'b1;
	Opt = inOpt;
	@(negedge clk);
	in_valid_o = 1'b0;
	Opt = 'dx;
	repeat(2) @(negedge clk);
	
	// input Image
	in_valid_i = 1'b1;
	for(i=0;i<16;i=i+1)begin
		Image1 = inImage1[i];
		Image2 = inImage2[i];
		Image3 = inImage3[i];
		@(negedge clk);
	end
	in_valid_i = 1'b0;
	Image1 = 'dx;
	Image2 = 'dx;
	Image3 = 'dx;
	repeat(2) @(negedge clk);
	
	// input Kernel
	in_valid_k = 1'b1;
	for(i=0;i<36;i=i+1)begin
		Kernel1 = inKernal1[i];
		Kernel2 = inKernal2[i];
		Kernel3 = inKernal3[i];
		@(negedge clk);
	end
	in_valid_k = 1'b0;
	Kernel1 = 'dx;
	Kernel2 = 'dx;
	Kernel3 = 'dx;
	repeat(2) @(negedge clk);
	
end endtask

task wait_outvalid_task ; begin
	cycles = 0 ;
	while( out_valid!==1 ) begin
		cycles = cycles + 1 ;
		if (out!==0) begin
			reset_fail;
            // Spec. 4
            // The out should be reset after your out_valid is pulled down. 
            // $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            // $display ("                                                                SPEC 4 FAIL!                                                                ");
            // $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            // repeat(5)  @(negedge clk);
            // $finish;
		end
		if (cycles==300) begin
			
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



parameter faithful_round = 0;
wire [31:0]tmp_out;
wire ALessB;
wire ALargeB;
wire AEqualB;
wire unordered_inst;
wire [31:0] z0_inst,z1_inst;
wire[31:0] inst_b;
assign inst_b = 32'b00111101101110000101000111101100; //0.09

wire [31:0]pos_tmp_out;
assign pos_tmp_out = {1'b0,tmp_out[30:0]};
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S0 ( .a(out), .b(out_Answer[curr_cycle]), .rnd(3'b000), .z(tmp_out), .status(status_inst) );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)U1 ( .a(pos_tmp_out), .b(inst_b), .zctr(1'b0), .aeqb(AEqualB),.altb(ALessB), .agtb(ALargeB), .unordered(unordered_inst),.z0(z0_inst), .z1(z1_inst), .status0(status0_inst),.status1(status1_inst) );

task check_answer; begin
	curr_cycle = 0;
	while(out_valid==0)begin
		@(negedge clk);
	end
	
	while(out_valid)begin
		if(ALargeB)begin
		//if(out[31:11]!=out_Answer[curr_cycle][31:11])begin
			$display ("----------------------------------------------------------------------------------------------------------------------");
			$display ("                                                  Your Answer is Wrong!             						             ");
			$display ("                                                  Your Answer is : %32b       	             ",out);
			$display ("                                               Correct Answer is : %32b           			             ",out_Answer[curr_cycle]);
			$display ("----------------------------------------------------------------------------------------------------------------------");
			$finish;
		end
		curr_cycle = curr_cycle+1;	
		@(negedge clk);
		
	end
end endtask

task reset_task ;  begin
	#(20); rst_n = 0;
	#(20);
	if((out_valid!==0) || (out!==0))begin
		reset_fail;
	end
	#(20);rst_n = 1;
	#(6); release clk;
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