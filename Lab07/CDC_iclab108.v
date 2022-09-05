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
input [DSIZE-1:0] 	in_account,in_A,in_T;

output reg				out_valid,ready;
output reg [DSIZE-1:0] 	out_account;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg rinc, winc;
wire rempty, wfull;
wire [DSIZE-1:0] rd_A, rd_T, rd_acc;
// wire [2*DSIZE-1:0] performance;
// assign performance = rd_A* rd_T;
reg out_flag;
reg [2:0] counter;
reg [2*DSIZE-1:0] performance [0:4];
reg [DSIZE-1:0] account[0:4];

wire [DSIZE-1:0] out_temp_1, out_temp_2, out_temp_3, out;
wire [2*DSIZE-1:0] perf_temp_1, perf_temp_2, perf_temp_3;
assign out_temp_1 = (performance[0] < performance[1])? account[0]: account[1];
assign perf_temp_1 = (performance[0] < performance[1])? performance[0]: performance[1];
assign out_temp_2 = (performance[2] < performance[3])? account[2]: account[3];
assign perf_temp_2 = (performance[2] < performance[3])? performance[2]: performance[3];
assign out_temp_3 = (perf_temp_1 < perf_temp_2)? out_temp_1: out_temp_2;
assign perf_temp_3 = (perf_temp_1 < perf_temp_2)? perf_temp_1: perf_temp_2;
assign out = (perf_temp_3 < performance[4])? out_temp_3: account[4];

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
integer i;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        for(i=0; i<5; i=i+1)begin
            performance[i] <= 0;
        end
    end
    else if(rinc)begin
        performance[4] <= rd_A* rd_T;
        performance[3] <= performance[4];
        performance[2] <= performance[3];
        performance[1] <= performance[2];
        performance[0] <= performance[1];
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        for(i=0; i<5; i=i+1)begin
            account[i] <= 0;
        end
    end
    else if(rinc)begin
        account[4] <= rd_acc;
        account[3] <= account[4];
        account[2] <= account[3];
        account[1] <= account[2];
        account[0] <= account[1];
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) 
        counter <= 0;
    else if(rinc) counter <= (counter == 4)? counter: counter + 1;
end

always @(*) begin
    if(!rempty) 
        rinc = 1;
    else 
        rinc = 0;
end

// Out
always @(*) begin
    if (!rst_n) ready = 0;
    else if(!wfull) ready = 1;
    else ready = 0;
end

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) 
        out_flag <= 0;
    else if(counter[2] && !rempty)
        out_flag <=  1;
    else 
        out_flag <= 0;
end

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) 
        out_valid <= 0;
    else if(out_flag)
        out_valid <= 1;
    else 
        out_valid <= 0;
end

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) 
        out_account <= 0;
    else if(out_flag)
        out_account <= out;
    else 
        out_account <= 0;
end

AFIFO u_AFIFO_1(
    .rclk(clk2),
    .rinc(rinc),
    .rempty(rempty),
	.wclk(clk1),
    .winc(in_valid),
    .wfull(wfull),
    .rst_n(rst_n),
    .rdata(rd_A),
    .wdata(in_A)
    );

AFIFO u_AFIFO_2(
    .rclk(clk2),
    .rinc(rinc),
    .rempty(),
	.wclk(clk1),
    .winc(in_valid),
    .wfull(),
    .rst_n(rst_n),
    .rdata(rd_T),
    .wdata(in_T)
    );

AFIFO u_AFIFO_acc(
    .rclk(clk2),
    .rinc(rinc),
    .rempty(),
	.wclk(clk1),
    .winc(in_valid),
    .wfull(),
    .rst_n(rst_n),
    .rdata(rd_acc),
    .wdata(in_account)
    );

endmodule