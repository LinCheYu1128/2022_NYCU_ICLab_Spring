//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL_TOP
    `define CYCLE_TIME 60.0
`endif

`ifdef GATE_TOP
    `define CYCLE_TIME 60.0
`endif

module PATTERN (
    // Output signals
    clk, rst_n, in_valid,
    in_p, in_q, in_e, in_c,
    // Input signals
    out_valid, out_m
);

// Parameter
parameter IP_WIDTH = 4;
// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg clk, rst_n, in_valid;
output reg [3:0] in_p, in_q;
output reg [7:0] in_e, in_c;
input out_valid;
input [7:0] out_m;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
real CYCLE = `CYCLE_TIME;

parameter PATNUM = 100;
integer patcount;
integer in_read,out_read;
integer i,j,a,gap;
integer counter;
integer curr_cycle, cycles, total_cycles;
//================================================================
// Wire & Reg Declaration
//================================================================
reg [3:0] in_p_reg, in_q_reg;
reg [7:0] in_e_reg; 
reg [7:0] in_c_reg [0:7];
reg [7:0] out_m_reg [0:7];
//================================================================
// Clock
//================================================================
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//================================================================
// Initial
//================================================================
initial begin
    in_read = $fopen("../00_TESTBED/input.txt", "r");
    rst_n = 1'b1;
    in_valid = 'b0;
    in_c = 'bx;
    in_e = 'bx;
    in_p = 'bx;
    in_q = 'bx;

    curr_cycle = 0;
	force clk = 0;
    reset_task;
    for(patcount = 0;patcount<PATNUM; patcount = patcount+1)begin
		curr_cycle = 0;
        load_input;
        input_task;
        @(negedge clk);
        $finish;
    end
end

//================================================================
// TASK
//================================================================
task load_input; begin
	a = $fscanf(in_read, "%d\n %d\n", in_p_reg, in_q_reg);
    a = $fscanf(in_read, "%d\n", in_e_reg);
    for(i=0; i<8; i=i+1)begin
        a = $fscanf(in_read, "%d\n", in_c_reg[i]);
    end
    for(i=0; i<8; i=i+1)begin
        a = $fscanf(in_read, "%d\n", out_m_reg[i]);
    end
end endtask

task input_task; begin
	$display ("start Pattern No.%1d",patcount);
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);
	
	in_valid = 1'b1;
	
	for(i=0; i<8; i=i+1)begin
        if(i==0)begin
            in_e = in_e_reg;
            in_p = in_p_reg;
            in_q = in_q_reg;
        end
        else begin
            in_e = 'dx;
            in_p = 'dx;
            in_q = 'dx;
        end
        in_c = in_c_reg[i];
        @(negedge clk);
    end
    in_valid = 'b0;
    in_c = 'dx;
end endtask

task reset_task ;  begin
	#(20); rst_n = 0;
	#(20);
	if((out_valid!==0) || (out_m!==0))begin
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