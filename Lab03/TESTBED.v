`timescale 1ns/10ps

`include "PATTERN.v"
`ifdef RTL
    `include "ESCAPE.v"
`endif
`ifdef GATE
    `include "ESCAPE_SYN.v"
`endif

module TESTBED;

wire         clk, rst_n, in_valid1; 
wire         in_valid2;
wire [1:0]   in;
wire [8:0]   in_data;
wire         out_valid1,out_valid2;
wire [2:0]   out;
wire [8:0]   out_data;


initial begin
    `ifdef RTL
        $fsdbDumpfile("ESCAPE.fsdb");
        $fsdbDumpvars(0,"+mda");
    `endif
    `ifdef GATE
        $sdf_annotate("ESCAPE_SYN.sdf", u_ESCAPE);
        $fsdbDumpfile("ESCAPE_SYN.fsdb");
        $fsdbDumpvars(0,"+mda"); 
    `endif
end

ESCAPE u_ESCAPE(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid1(in_valid1),
    .in_valid2(in_valid2),    
    .in(in),
    .in_data(in_data),
    .out_valid1(out_valid1),
    .out_valid2(out_valid2),
    .out(out),
    .out_data(out_data)
    );
    
PATTERN u_PATTERN(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid1(in_valid1),
    .in_valid2(in_valid2),    
    .in(in),
    .in_data(in_data),
    .out_valid1(out_valid1),
    .out_valid2(out_valid2),
    .out(out),
    .out_data(out_data)
    );

endmodule
