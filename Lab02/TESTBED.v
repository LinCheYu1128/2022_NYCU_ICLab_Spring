//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2022 ICLAB SPRING Course
//   Lab02       : Sequential Circuits
//   Author      : Heng-Yu Liu
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESTBED.v
//   Module Name : TESTBED
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`timescale 1ns/10ps

`include "PATTERN.v"
`ifdef RTL
    `include "WD.v"
`endif
`ifdef GATE
    `include "WD_SYN.v"
`endif
	  		  	
module TESTBED;

wire clk, rst_n, in_valid, out_valid;
wire [4:0]  keyboard, answer, result;
wire [3:0]  weight;
wire [2:0]  match_target;
wire [10:0] out_value;

initial begin
    `ifdef RTL
        $fsdbDumpfile("WD.fsdb");
        $fsdbDumpvars(0,"+mda");
        $fsdbDumpvars();
    `endif
    `ifdef GATE
        $sdf_annotate("WD_SYN.sdf", u_WD);
        $fsdbDumpfile("WD_SYN.fsdb");
        $fsdbDumpvars();
    `endif
end

WD u_WD(
    // Input signals
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .keyboard(keyboard),
    .answer(answer),
    .weight(weight),
    .match_target(match_target),
    // Output signals
    .out_valid(out_valid),
    .result(result),
    .out_value(out_value)
);
	
PATTERN u_PATTERN(
    // Output signals
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .keyboard(keyboard),
    .answer(answer),
    .weight(weight),
    .match_target(match_target),
    // Input signals
    .out_valid(out_valid),
    .result(result),
    .out_value(out_value)
);
  
endmodule
