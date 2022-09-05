`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
			 parameter ASIZE = 4)(
	//Input Port
	rst_n,
	clk1,
    clk2,
	in_valid,
	in_account,
	in_A,
	in_T,

    //Output Port
	ready,
    out_valid,
	out_account
); 
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
    input 				rst_n, clk1, clk2, in_valid;
    input [DSIZE - 1:0] in_account, in_A, in_T;

    output reg				 out_valid;
    output reg               ready;
    output reg [DSIZE - 1:0] out_account;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
    reg [DSIZE - 1: 0]     ACCOUNT_ff[0: 4];
    reg [DSIZE * 2 - 1: 0] performance_ff[0: 4];
    reg [DSIZE - 1: 0]     out_account_ready;
    reg                    out_valid_ready;
    wire                   winc;
    reg                    rinc_delay;
    
    wire [DSIZE - 1: 0]     AFIFO_account_out, AFIFO_area_out, AFIFO_latency_out;
    wire [DSIZE - 1: 0]     AFIFO_account_in,  AFIFO_area_in,  AFIFO_latency_in;
    wire [DSIZE * 2 - 1: 0] temp_performance;
    wire [2: 0]             best_account;
    wire                    rinc;
    wire                    rempty1, rempty2, rempty3, wfull1, wfull2, wfull3;
    reg [2: 0] counter;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
    AFIFO AFIFO_account(
        .rclk(clk2),
        .rinc(rinc),
        .rempty(rempty1),

        .wclk(clk1),
        .winc(winc),
        .wfull(wfull1),

        .rst_n(rst_n),

        .rdata(AFIFO_account_out),
        .wdata(AFIFO_account_in)
        );
    AFIFO AFIFO_latency(
        .rclk(clk2),
        .rinc(rinc),
        .rempty(rempty2),

        .wclk(clk1),
        .winc(winc),
        .wfull(wfull2),

        .rst_n(rst_n),

        .rdata(AFIFO_latency_out),
        .wdata(AFIFO_latency_in)
        );
    AFIFO AFIFO_area(
        .rclk(clk2),
        .rinc(rinc),
        .rempty(rempty3),

        .wclk(clk1),
        .winc(winc),
        .wfull(wfull3),

        .rst_n(rst_n),

        .rdata(AFIFO_area_out),
        .wdata(AFIFO_area_in)
        );

    assign AFIFO_account_in = in_account;
    assign AFIFO_area_in    = in_A;
    assign AFIFO_latency_in = in_T;

    assign rinc = ~rempty1;

    assign winc = in_valid;

    always @(posedge clk2 or negedge rst_n) begin
        if (~rst_n)     counter <= 0;
        else begin
            if (counter < 5 && rinc)
                counter <= counter + 1;
        end
    end

    always @(posedge clk2 or negedge rst_n) begin
        if (~rst_n) begin
            ACCOUNT_ff[0] <= 0;  ACCOUNT_ff[1] <= 0;  ACCOUNT_ff[2] <= 0;  ACCOUNT_ff[3] <= 0;  ACCOUNT_ff[4] <= 0;
        end
        else begin
            if (rinc) begin
                ACCOUNT_ff[0] <= AFIFO_account_out;
                ACCOUNT_ff[1] <= ACCOUNT_ff[0];  ACCOUNT_ff[2] <= ACCOUNT_ff[1];  ACCOUNT_ff[3] <= ACCOUNT_ff[2];  ACCOUNT_ff[4] <= ACCOUNT_ff[3];
            end
        end
    end

    assign temp_performance = AFIFO_area_out * AFIFO_latency_out;
    always @(posedge clk2 or negedge rst_n) begin
        if (~rst_n) begin
            performance_ff[0] <= 0;  performance_ff[1] <= 0;  performance_ff[2] <= 0;  performance_ff[3] <= 0;  performance_ff[4] <= 0;
        end
        else begin
            if (rinc) begin
                performance_ff[0] <= temp_performance;
                performance_ff[1] <= performance_ff[0];  performance_ff[2] <= performance_ff[1];  performance_ff[3] <= performance_ff[2];  performance_ff[4] <= performance_ff[3];
            end
        end
    end

    SMALLEST #(.DSIZE(DSIZE)) S0 (.A(performance_ff[0]), .B(performance_ff[1]), .C(performance_ff[2]),
                                  .D(performance_ff[3]), .E(performance_ff[4]), .smallest(best_account));

    //---------------------------------------------------------------------
    always @(posedge clk2 or negedge rst_n) begin
        if (~rst_n) begin
            out_valid_ready <= 0;
            out_account_ready <= 0;
        end
        else begin
            out_valid_ready <= rinc_delay & (counter == 5);
            out_account_ready <= ACCOUNT_ff[best_account];
        end
    end

    always @(posedge clk2 or negedge rst_n) begin
        if (~rst_n) begin
            out_valid <= 0;
            out_account <= 0;
        end
        else begin
            out_valid <= out_valid_ready;
            out_account <= out_valid_ready? out_account_ready: 0;
        end
    end
    //---------------------------------------------------------------------
    always @(*) begin
        if (~rst_n)
            ready = 0;
        else
            ready = ~wfull1;
    end
    
    always @(posedge clk2 or negedge rst_n)
        if (~rst_n)
            rinc_delay <= 0;
        else
            rinc_delay <= rinc;

endmodule

module SMALLEST #(parameter DSIZE = 8)(A, B, C, D, E, smallest);
    input [DSIZE * 2 - 1: 0] A, B, C, D, E;
    output [2: 0] smallest;

    wire [DSIZE * 2 + 2: 0] tempA, tempB, tempC, tempD, tempE;
    wire [DSIZE * 2 + 2: 0] L1, L2, L3, L4;

    assign tempA = {3'd0, A};   assign tempB = {3'd1, B};
    assign tempC = {3'd2, C};   assign tempD = {3'd3, D};   assign tempE = {3'd4, E};

    COMP #(.DSIZE(DSIZE)) C0(.A(tempA), .B(tempB), .smaller(L1));
    COMP #(.DSIZE(DSIZE)) C1(.A(tempC), .B(tempD), .smaller(L2));
    COMP #(.DSIZE(DSIZE)) C2(.A(L1),    .B(L2),    .smaller(L3));
    COMP #(.DSIZE(DSIZE)) C3(.A(L3),    .B(tempE), .smaller(L4));

    assign smallest = L4[DSIZE * 2 + 2: DSIZE * 2];
endmodule

module COMP #(parameter DSIZE = 8)(A, B, smaller);
    input [DSIZE * 2 + 2: 0] A, B;
    output [DSIZE * 2 + 2: 0] smaller;

    assign smaller = (A[DSIZE * 2 - 1: 0] <= B[DSIZE * 2 - 1: 0])? A: B;
endmodule