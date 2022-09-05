//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_TOP.v
//   Module Name : RSA_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "RSA_IP.v"
//synopsys translate_on

module RSA_TOP (
    // Input signals
    clk, rst_n, in_valid,
    in_p, in_q, in_e, in_c,
    // Output signals
    out_valid, out_m
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
    input clk, rst_n, in_valid;
    input [3: 0] in_p, in_q;
    input [7: 0] in_e, in_c;
    output reg out_valid;
    output reg [7: 0] out_m;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
    parameter IDLE = 3'd0,
              INPUT = 3'd1,
              OUTPUT = 3'd2;
    integer i;

//================================================================
// Wire & Reg Declaration
//================================================================
    reg [1: 0] CS, NS;
    reg [3: 0] in_p_ff, in_q_ff;
    reg [7: 0] in_e_ff, in_c_ff;
    reg [3: 0] counter;
    reg first_one;
    wire [7: 0] parameter_n, parameter_d;
    wire [14: 0] result [0: 6];
    wire [14: 0] base   [0: 6];
    reg  [7: 0] result_ff [0: 6];
    reg  [7: 0] base_ff   [0: 6];
//================================================================
// DESIGN
//================================================================
    RSA_IP #(.WIDTH(4)) IP(.IN_P(in_p_ff), .IN_Q(in_q_ff), .IN_E(in_e_ff), .OUT_N(parameter_n), .OUT_D(parameter_d));
//================================================================
    always @(posedge clk or negedge rst_n)
        if (~rst_n) CS <= IDLE;
        else        CS <= NS;

    always @(*) begin
        NS = IDLE;
        case(CS)
            IDLE:         NS = (in_valid)? INPUT: IDLE;
            INPUT:        NS = (in_valid)? INPUT: OUTPUT;
            OUTPUT:       NS = (counter < 8)? OUTPUT: IDLE;
        endcase
    end
//================================================================
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            counter <= 4'b0;
        else if (NS == OUTPUT)
            counter <= counter + 1;
        else
            counter <= 0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            in_p_ff <= 4'b0;  in_q_ff <= 4'b0;  in_e_ff <= 4'b0;  first_one <= 1'b0;
        end
        else if (NS == INPUT) begin
            if (~first_one) begin
                in_p_ff <= in_p;  in_q_ff <= in_q;  in_e_ff <= in_e;  first_one <= 1'b1;
            end
            in_c_ff <= in_c;
        end
        else if (NS == IDLE) begin
            first_one <= 1'b0;
        end
    end

//================================================================
    assign base[0]     = (parameter_d)
                         ? (in_c_ff * in_c_ff) % parameter_n
                         : (in_c_ff) % parameter_n;
    assign result[0]   = (parameter_d & parameter_d[0])
                        ? (in_c_ff) % parameter_n
                        : 1;
//================================================================
    assign base[1]     = (parameter_d[6: 1])
                        ? (base_ff[0] * base_ff[0]) % parameter_n
                        : base_ff[0];
    assign result[1]   = (parameter_d[6: 1] & parameter_d[1])
                        ? (result_ff[0] * base_ff[0]) % parameter_n
                        : result_ff[0];
//================================================================
    assign base[2]     = (parameter_d[6: 2])
                        ? (base_ff[1] * base_ff[1]) % parameter_n
                        : base_ff[1];
    assign result[2]   = (parameter_d[6: 2] & parameter_d[2])
                        ? (result_ff[1] * base_ff[1]) % parameter_n
                        : result_ff[1];
//================================================================
    assign base[3]     = (parameter_d[6: 3])
                        ? (base_ff[2] * base_ff[2]) % parameter_n
                        : base_ff[2];
    assign result[3]   = (parameter_d[6: 3] & parameter_d[3])
                        ? (result_ff[2] * base_ff[2]) % parameter_n
                        : result_ff[2];
//================================================================
    assign base[4]     = (parameter_d[6: 4])
                        ? (base_ff[3] * base_ff[3]) % parameter_n
                        : base_ff[3];
    assign result[4]   = (parameter_d[6: 4] & parameter_d[4])
                        ? (result_ff[3] * base_ff[3]) % parameter_n
                        : result_ff[3];
//================================================================
    assign base[5]     = (parameter_d[6: 5])
                        ? (base_ff[4] * base_ff[4]) % parameter_n
                        : base_ff[4];
    assign result[5]   = (parameter_d[6: 5] & parameter_d[5])
                        ? (result_ff[4] * base_ff[4]) % parameter_n
                        : result_ff[4];
//================================================================
    assign base[6]     = (parameter_d[6])
                        ? (base_ff[5] * base_ff[5]) % parameter_n
                        : base_ff[5];
    assign result[6]   = (parameter_d[6])
                        ? (result_ff[5] * base_ff[5]) % parameter_n
                        : result_ff[5];
//================================================================
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            for (i = 0; i != 7; i = i + 1)
                result_ff[i] <= 8'b0;
        else
            for (i = 0; i != 7; i = i + 1)
                result_ff[i] <= result[i];
    end
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            for (i = 0; i != 7; i = i + 1)
                base_ff[i] <= 8'b0;
        else
            for (i = 0; i != 7; i = i + 1)
                base_ff[i] <= base[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            out_valid <= 1'b0;  out_m <= 8'b0;
        end
        else if (NS == OUTPUT) begin
            out_valid <= 1'b1;  out_m <= result_ff[6];
        end
        else begin
            out_valid <= 1'b0;  out_m <= 8'b0;
        end
    end

endmodule