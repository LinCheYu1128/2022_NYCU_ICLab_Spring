//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2022 SPRING
//   Final Proejct              : TOF  
//   Author                     : Wen-Yue, Lin
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TOF.v
//   Module Name : TOF
//   Release version : V1.0 (Release Date: 2022-5)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module TOF(
    // CHIP IO
    clk,
    rst_n,
    in_valid,
    start,
    stop,
    inputtype,
    frame_id,
    busy,

    // AXI4 IO
    arid_m_inf,
    araddr_m_inf,
    arlen_m_inf,
    arsize_m_inf,
    arburst_m_inf,
    arvalid_m_inf,
    arready_m_inf,
    
    rid_m_inf,
    rdata_m_inf,
    rresp_m_inf,
    rlast_m_inf,
    rvalid_m_inf,
    rready_m_inf,

    awid_m_inf,
    awaddr_m_inf,
    awsize_m_inf,
    awburst_m_inf,
    awlen_m_inf,
    awvalid_m_inf,
    awready_m_inf,

    wdata_m_inf,
    wlast_m_inf,
    wvalid_m_inf,
    wready_m_inf,
    
    bid_m_inf,
    bresp_m_inf,
    bvalid_m_inf,
    bready_m_inf 
);
// ===============================================================
//                      Parameter Declaration 
// ===============================================================
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;    // DO NOT modify AXI4 Parameter


// ===============================================================
//                      Input / Output 
// ===============================================================

// << CHIP io port with system >>
input           clk, rst_n;
input           in_valid;
input           start;
input [15:0]    stop;     
input [1:0]     inputtype; 
input [4:0]     frame_id;
output reg      busy;       

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
    Your AXI-4 interface could be designed as a bridge in submodule,
    therefore I declared output of AXI as wire.  
    Ex: AXI4_interface AXI4_INF(...);
*/

// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)    axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output wire                  arvalid_m_inf;
input  wire                  arready_m_inf;
output wire [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)    axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output wire                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1)     axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output wire                  awvalid_m_inf;
input  wire                  awready_m_inf;
output wire [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)    axi write data channel 
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output wire                    wlast_m_inf;
// -------------------------
// (3)    axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------
//================================================================
//  Assign some fixed signal
//================================================================
assign arid_m_inf    = 0      ;
assign arsize_m_inf  = 3'b100 ;
assign arburst_m_inf = 2'b01  ;
assign arlen_m_inf   = 255;
assign awid_m_inf    = 0      ;
assign awsize_m_inf  = 3'b100 ;
assign awburst_m_inf = 2'b01  ;
assign awlen_m_inf   = 255;
//================================================================
//  FSM parameter
//================================================================
parameter IDLE   = 3'd0;
parameter MODE   = 3'd1;
parameter WAIT_0 = 3'd2; // mode 0 wait for start; mode 1 wait for rvalid
parameter LOAD_0 = 3'd3;
parameter CAL_0  = 3'd4;
parameter WAIT_1 = 3'd5; // mode 0 wait for start; mode 1 wait for rvalid
parameter LOAD_1 = 3'd6;
parameter CAL_1  = 3'd7;   
reg [2:0] current_state, next_state;

reg [5:0] in_number, in_number_2, in_number_3, in_number_4;
reg [3:0] hist_counter;
reg [6:0] counter;
reg initial_flag;
reg fin_flag;

wire [127:0]  hist_cal;
reg  [127:0]  hist;
reg [7:0] hist_cap[0:3];

reg [7:0] R1, R2, R3, R4, R5, R6, R7, R8, tmp_1, tmp_2, tmp_3, tmp_4;

reg signed [11:0] D1, D2, D3, D4;
reg signed [11:0] S1, S2, S3, S4, S5, S6, S7, S8;
reg signed [11:0] C1, C2, C3; 
reg [1:0] M1, M2, M3, M4;
reg signed [11:0] ACC1, ACC2, diff_acc;
reg signed [11:0] Max_nxt, Max_cur;
reg [7:0] Distance;
//================================================================
//  AXI4 declaration
//================================================================
reg         rd_valid;
// reg [11:0]  rd_addr ;
reg [127:0] rd_data ;

reg         wr_valid;
// reg [11:0]  wr_addr ;
reg [127:0] wr_data ;
reg wr_ready;
//================================================================
//  SRAM control
//================================================================
reg [1:0] MEM_switch;      
// SRAM_1
reg MEM_wen;
reg [5:0] MEM_addr;
reg [127:0] MEM_in;
wire [127:0] MEM_out;

RA1SH_128_64 SRAM_1(.Q(MEM_out), .CLK(clk), .CEN(1'b0), .WEN(MEM_wen), .A(MEM_addr), .D(MEM_in), .OEN(1'b0) );

always @(*)begin
    if(current_state == WAIT_0 || current_state == LOAD_0) MEM_addr = in_number;
    else if(current_state == CAL_0 || rvalid_m_inf) MEM_addr = in_number;
	else MEM_addr = 'd0;
end
always @(*) begin
	// if(rvalid_m_inf) MEM_wen = 0;
    // else if(next_state == WAIT_0) MEM_wen = 1;
    if(next_state == LOAD_0 || next_state == LOAD_1) MEM_wen = (MEM_switch==0)? 0: 1;
	else MEM_wen = 1;
end
always @(*) begin
	if(rvalid_m_inf) MEM_in = rdata_m_inf;
    else if(next_state == LOAD_0) begin
        if(!initial_flag)MEM_in = {7'd0, stop[15], 7'd0, stop[14], 7'd0, stop[13], 7'd0, stop[12], 
                                                          7'd0, stop[11], 7'd0, stop[10], 7'd0, stop[ 9], 7'd0, stop[ 8], 
                                                          7'd0, stop[ 7], 7'd0, stop[ 6], 7'd0, stop[ 5], 7'd0, stop[ 4], 
                                                          7'd0, stop[ 3], 7'd0, stop[ 2], 7'd0, stop[ 1], 7'd0, stop[ 0]};
        else MEM_in = hist_cal;
    end 
	else MEM_in = 'd0;
end

// SRAM_2
reg MEM_wen_2;
reg [5:0] MEM_addr_2;
reg [127:0] MEM_in_2;
wire [127:0] MEM_out_2;

RA1SH_128_64 SRAM_2(.Q(MEM_out_2), .CLK(clk), .CEN(1'b0), .WEN(MEM_wen_2), .A(MEM_addr_2), .D(MEM_in_2), .OEN(1'b0) );

always @(*)begin
    if(current_state == WAIT_0 || current_state == LOAD_0) MEM_addr_2 = in_number_2;
    else if(current_state == CAL_0 || rvalid_m_inf) MEM_addr_2 = in_number;
	else MEM_addr_2 = 'd0;
end
always @(*) begin
    // if(rvalid_m_inf) MEM_wen_2 = 0;
	// if(current_state == WAIT_0) MEM_wen_2 = 1;
    if(next_state == LOAD_0 || next_state == LOAD_1) MEM_wen_2 = (MEM_switch==1)? 0: 1;
	else MEM_wen_2 = 'd1;
end
always @(*) begin
    if(rvalid_m_inf) MEM_in_2 = rdata_m_inf;
    else if(next_state == LOAD_0) begin
	    if(!initial_flag) MEM_in_2 = {7'd0, stop[15], 7'd0, stop[14], 7'd0, stop[13], 7'd0, stop[12], 
                                                       7'd0, stop[11], 7'd0, stop[10], 7'd0, stop[ 9], 7'd0, stop[ 8], 
                                                       7'd0, stop[ 7], 7'd0, stop[ 6], 7'd0, stop[ 5], 7'd0, stop[ 4], 
                                                       7'd0, stop[ 3], 7'd0, stop[ 2], 7'd0, stop[ 1], 7'd0, stop[ 0]};
        else MEM_in_2 = hist_cal;
    end
	else MEM_in_2 = 'd0;
end

// SRAM_3
reg MEM_wen_3;
reg [5:0] MEM_addr_3;
reg [127:0] MEM_in_3;
wire [127:0] MEM_out_3;

RA1SH_128_64 SRAM_3(.Q(MEM_out_3), .CLK(clk), .CEN(1'b0), .WEN(MEM_wen_3), .A(MEM_addr_3), .D(MEM_in_3), .OEN(1'b0) );

always @(*)begin
    if(current_state == WAIT_0 || current_state == LOAD_0) MEM_addr_3 = in_number_3;
    else if(current_state == CAL_0|| rvalid_m_inf) MEM_addr_3 = in_number;
	else MEM_addr_3 = 'd0;
end
always @(*) begin
    // if(rvalid_m_inf) MEM_wen_3 = 0;
	// if(current_state == WAIT_0) MEM_wen_3 = 1;
    if(next_state == LOAD_0 || next_state == LOAD_1) MEM_wen_3 = (MEM_switch==2)? 0: 1;
	else MEM_wen_3 = 'd1;
end
always @(*) begin
    if(rvalid_m_inf) MEM_in_3 = rdata_m_inf;
    else if(next_state == LOAD_0) begin
	    if(!initial_flag) MEM_in_3 = {7'd0, stop[15], 7'd0, stop[14], 7'd0, stop[13], 7'd0, stop[12], 
                                                       7'd0, stop[11], 7'd0, stop[10], 7'd0, stop[ 9], 7'd0, stop[ 8], 
                                                       7'd0, stop[ 7], 7'd0, stop[ 6], 7'd0, stop[ 5], 7'd0, stop[ 4], 
                                                       7'd0, stop[ 3], 7'd0, stop[ 2], 7'd0, stop[ 1], 7'd0, stop[ 0]};
        else MEM_in_3 = hist_cal;
    end
	else MEM_in_3 = 'd0;
end

// SRAM_4
reg MEM_wen_4;
reg [5:0] MEM_addr_4;
reg [127:0] MEM_in_4;
wire [127:0] MEM_out_4;

RA1SH_128_64 SRAM_4(.Q(MEM_out_4), .CLK(clk), .CEN(1'b0), .WEN(MEM_wen_4), .A(MEM_addr_4), .D(MEM_in_4), .OEN(1'b0) );

always @(*)begin
    if(current_state == WAIT_0 || current_state == LOAD_0) MEM_addr_4 = (in_number_4 == 63)? 0:in_number_4;
    else if(current_state == CAL_0 || rvalid_m_inf) MEM_addr_4 = in_number;
	else MEM_addr_4 = 'd0;
end
always @(*) begin
    // if(rvalid_m_inf) MEM_wen_4 = 0;
	// if(current_state == WAIT_0) MEM_wen_4 = 1;
    if(next_state == LOAD_0 )begin
        MEM_wen_4 = (MEM_switch==3 && in_number_4 != 63 )? 0: 1;
    end 
    else if(next_state == LOAD_1)begin
         MEM_wen_4 = (MEM_switch==3)? 0: 1;
    end
	else MEM_wen_4 = 'd1;
end
always @(*) begin
    if(rvalid_m_inf) MEM_in_4 = rdata_m_inf;
    else if(next_state == LOAD_0) begin
        if(!initial_flag) MEM_in_4 = {7'd0, stop[15], 7'd0, stop[14], 7'd0, stop[13], 7'd0, stop[12], 
                                            7'd0, stop[11], 7'd0, stop[10], 7'd0, stop[ 9], 7'd0, stop[ 8], 
                                            7'd0, stop[ 7], 7'd0, stop[ 6], 7'd0, stop[ 5], 7'd0, stop[ 4], 
                                            7'd0, stop[ 3], 7'd0, stop[ 2], 7'd0, stop[ 1], 7'd0, stop[ 0]};
        else MEM_in_4 = hist_cal;
    end
	else MEM_in_4 = 'd0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) MEM_switch <= 0;
	else if(next_state == LOAD_0 || next_state == LOAD_1) MEM_switch <= MEM_switch + 1;
    else if(current_state == CAL_0)begin
        // if(counter == 70) MEM_switch <= 0;
        // else MEM_switch <= MEM_switch + 1;
        MEM_switch <= MEM_switch + 1;
    end 
    else MEM_switch <= 0;
end

always @(*) begin
    case (MEM_switch)
        0: hist = MEM_out;
        1: hist = MEM_out_2;
        2: hist = MEM_out_3;
        default: hist = MEM_out_4;
    endcase
end

//================================================================
//  wire assign
//================================================================
// assign hist = (!MEM_switch)? MEM_out: MEM_out_2;
assign hist_cal =  {hist[127:120] + stop[15], hist[119:112] + stop[14], hist[111:104] + stop[13], hist[103: 96] + stop[12], 
                    hist[ 95: 88] + stop[11], hist[ 87: 80] + stop[10], hist[ 79: 72] + stop[ 9], hist[ 71: 64] + stop[ 8], 
                    hist[ 63: 56] + stop[ 7], hist[ 55: 48] + stop[ 6], hist[ 47: 40] + stop[ 5], hist[ 39: 32] + stop[ 4], 
                    hist[ 31: 24] + stop[ 3], hist[ 23: 16] + stop[ 2], hist[ 15:  8] + stop[ 1], hist[  7:  0] + stop[ 0]};

//================================================================
//  Design
//================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mode_reg   <= 0;
        window_reg <= 0;
        frame_reg  <= 0;
    end
    else if(next_state == MODE)begin
        mode_reg   <= 1;
        window_reg <= 3;
        frame_reg  <= frame_id;
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) initial_flag <= 0;
	else if(current_state == LOAD_0 && next_state == WAIT_0) initial_flag <= 1;
    else if(current_state == IDLE) initial_flag <= 0;
end
            // 0:3   4:7   8:11  12:15
            // 16:19 20:23 24:27 28:31
            // 32:35 36:39 40:43 44:47
            // 48:51 52:55 56:59 60:63
always @(*) begin
    if(mode_reg == 0)begin
        case (hist_counter)
            0: begin
                hist_cap[0] = MEM_out  [7:0];
                hist_cap[1] = MEM_out_2[7:0];
                hist_cap[2] = MEM_out_3[7:0];
                hist_cap[3] = MEM_out_4[7:0];
            end 
            1: begin
                hist_cap[0] = MEM_out  [15:8];
                hist_cap[1] = MEM_out_2[15:8];
                hist_cap[2] = MEM_out_3[15:8];
                hist_cap[3] = MEM_out_4[15:8];
            end 
            2: begin
                hist_cap[0] = MEM_out  [23:16];
                hist_cap[1] = MEM_out_2[23:16];
                hist_cap[2] = MEM_out_3[23:16];
                hist_cap[3] = MEM_out_4[23:16];
            end 
            3: begin
                hist_cap[0] = MEM_out  [31:24];
                hist_cap[1] = MEM_out_2[31:24];
                hist_cap[2] = MEM_out_3[31:24];
                hist_cap[3] = MEM_out_4[31:24];
            end 
            4: begin
                hist_cap[0] = MEM_out  [39:32];
                hist_cap[1] = MEM_out_2[39:32];
                hist_cap[2] = MEM_out_3[39:32];
                hist_cap[3] = MEM_out_4[39:32];
            end 
            5: begin
                hist_cap[0] = MEM_out  [47:40];
                hist_cap[1] = MEM_out_2[47:40];
                hist_cap[2] = MEM_out_3[47:40];
                hist_cap[3] = MEM_out_4[47:40];
            end 
            6: begin
                hist_cap[0] = MEM_out  [55:48];
                hist_cap[1] = MEM_out_2[55:48];
                hist_cap[2] = MEM_out_3[55:48];
                hist_cap[3] = MEM_out_4[55:48];
            end 
            7: begin
                hist_cap[0] = MEM_out  [63:56];
                hist_cap[1] = MEM_out_2[63:56];
                hist_cap[2] = MEM_out_3[63:56];
                hist_cap[3] = MEM_out_4[63:56];
            end 
            8: begin
                hist_cap[0] = MEM_out  [71:64];
                hist_cap[1] = MEM_out_2[71:64];
                hist_cap[2] = MEM_out_3[71:64];
                hist_cap[3] = MEM_out_4[71:64];
            end 
            9: begin
                hist_cap[0] = MEM_out  [79:72];
                hist_cap[1] = MEM_out_2[79:72];
                hist_cap[2] = MEM_out_3[79:72];
                hist_cap[3] = MEM_out_4[79:72];
            end 
            10: begin
                hist_cap[0] = MEM_out  [87:80];
                hist_cap[1] = MEM_out_2[87:80];
                hist_cap[2] = MEM_out_3[87:80];
                hist_cap[3] = MEM_out_4[87:80];
            end 
            11: begin
                hist_cap[0] = MEM_out  [95:88];
                hist_cap[1] = MEM_out_2[95:88];
                hist_cap[2] = MEM_out_3[95:88];
                hist_cap[3] = MEM_out_4[95:88];
            end 
            12: begin
                hist_cap[0] = MEM_out  [103:96];
                hist_cap[1] = MEM_out_2[103:96];
                hist_cap[2] = MEM_out_3[103:96];
                hist_cap[3] = MEM_out_4[103:96];
            end 
            13: begin
                hist_cap[0] = MEM_out  [111:104];
                hist_cap[1] = MEM_out_2[111:104];
                hist_cap[2] = MEM_out_3[111:104];
                hist_cap[3] = MEM_out_4[111:104];
            end 
            14: begin
                hist_cap[0] = MEM_out  [119:112];
                hist_cap[1] = MEM_out_2[119:112];
                hist_cap[2] = MEM_out_3[119:112];
                hist_cap[3] = MEM_out_4[119:112];
            end 
            // 15: begin
            //     hist_cap[0] = MEM_out  [7:0];
            //     hist_cap[1] = MEM_out_2[7:0];
            //     hist_cap[2] = MEM_out_3[7:0];
            //     hist_cap[3] = MEM_out_4[7:0];
            // end 
            default: begin
                hist_cap[0] = MEM_out  [127:120];
                hist_cap[1] = MEM_out_2[127:120];
                hist_cap[2] = MEM_out_3[127:120];
                hist_cap[3] = MEM_out_4[127:120];
            end 
        endcase
    end
    else begin
        case (counter[3:0])
            0:begin
                hist_cap[0] = MEM_out[  7:  0];
                hist_cap[1] = MEM_out[ 15:  8];
                hist_cap[2] = MEM_out[ 23: 16];
                hist_cap[3] = MEM_out[ 31: 24];
            end 
            1:begin
                hist_cap[0] = MEM_out[ 39: 32];
                hist_cap[1] = MEM_out[ 47: 40];
                hist_cap[2] = MEM_out[ 55: 48];
                hist_cap[3] = MEM_out[ 63: 56];
            end
            2:begin
                hist_cap[0] = MEM_out[ 71: 64];
                hist_cap[1] = MEM_out[ 79: 72];
                hist_cap[2] = MEM_out[ 87: 80];
                hist_cap[3] = MEM_out[ 95: 88];
            end
            3:begin
                hist_cap[0] = MEM_out[103: 96];
                hist_cap[1] = MEM_out[111:104];
                hist_cap[2] = MEM_out[119:112];
                hist_cap[3] = MEM_out[127:120];
            end
            4:begin
                hist_cap[0] = MEM_out_2[  7:  0];
                hist_cap[1] = MEM_out_2[ 15:  8];
                hist_cap[2] = MEM_out_2[ 23: 16];
                hist_cap[3] = MEM_out_2[ 31: 24];
            end 
            5:begin
                hist_cap[0] = MEM_out_2[ 39: 32];
                hist_cap[1] = MEM_out_2[ 47: 40];
                hist_cap[2] = MEM_out_2[ 55: 48];
                hist_cap[3] = MEM_out_2[ 63: 56];
            end
            6:begin
                hist_cap[0] = MEM_out_2[ 71: 64];
                hist_cap[1] = MEM_out_2[ 79: 72];
                hist_cap[2] = MEM_out_2[ 87: 80];
                hist_cap[3] = MEM_out_2[ 95: 88];
            end
            7:begin
                hist_cap[0] = MEM_out_2[103: 96];
                hist_cap[1] = MEM_out_2[111:104];
                hist_cap[2] = MEM_out_2[119:112];
                hist_cap[3] = MEM_out_2[127:120];
            end
            8:begin
                hist_cap[0] = MEM_out_3[  7:  0];
                hist_cap[1] = MEM_out_3[ 15:  8];
                hist_cap[2] = MEM_out_3[ 23: 16];
                hist_cap[3] = MEM_out_3[ 31: 24];
            end 
            9:begin
                hist_cap[0] = MEM_out_3[ 39: 32];
                hist_cap[1] = MEM_out_3[ 47: 40];
                hist_cap[2] = MEM_out_3[ 55: 48];
                hist_cap[3] = MEM_out_3[ 63: 56];
            end
            10:begin
                hist_cap[0] = MEM_out_3[ 71: 64];
                hist_cap[1] = MEM_out_3[ 79: 72];
                hist_cap[2] = MEM_out_3[ 87: 80];
                hist_cap[3] = MEM_out_3[ 95: 88];
            end
            11:begin
                hist_cap[0] = MEM_out_3[103: 96];
                hist_cap[1] = MEM_out_3[111:104];
                hist_cap[2] = MEM_out_3[119:112];
                hist_cap[3] = MEM_out_3[127:120];
            end
            12:begin
                hist_cap[0] = MEM_out_4[  7:  0];
                hist_cap[1] = MEM_out_4[ 15:  8];
                hist_cap[2] = MEM_out_4[ 23: 16];
                hist_cap[3] = MEM_out_4[ 31: 24];
            end 
            13:begin
                hist_cap[0] = MEM_out_4[ 39: 32];
                hist_cap[1] = MEM_out_4[ 47: 40];
                hist_cap[2] = MEM_out_4[ 55: 48];
                hist_cap[3] = MEM_out_4[ 63: 56];
            end
            14:begin
                hist_cap[0] = MEM_out_4[ 71: 64];
                hist_cap[1] = MEM_out_4[ 79: 72];
                hist_cap[2] = MEM_out_4[ 87: 80];
                hist_cap[3] = MEM_out_4[ 95: 88];
            end
            // 15:begin
            //     hist_cap[0] = MEM_out_4[103: 96];
            //     hist_cap[1] = MEM_out_4[111:104];
            //     hist_cap[2] = MEM_out_4[119:112];
            //     hist_cap[3] = MEM_out_4[127:120];
            // end
            default: begin
                hist_cap[0] = MEM_out_4[103: 96];
                hist_cap[1] = MEM_out_4[111:104];
                hist_cap[2] = MEM_out_4[119:112];
                hist_cap[3] = MEM_out_4[127:120];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) hist_counter <= 0;
    else if(counter == 71) hist_counter <= hist_counter + 1;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) in_number <= 0;
    else if(next_state == LOAD_1) in_number <= (MEM_switch == 3)? in_number + 1: in_number;
    else if(next_state == LOAD_0) in_number <= (MEM_switch == 0)? in_number + 1: in_number;
    else if(next_state == CAL_0) begin
        if(mode_reg == 0)begin
            if(counter > 63) in_number <= (counter == 71)? in_number + 1: 0;
            else in_number <= in_number + 1;
        end
        else begin
            if(counter > 63) in_number <= in_number;
            else if(counter[3:0]==14) in_number <= in_number + 1;
        end
    end 
	else in_number <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) counter <= 0;
    else if(current_state == CAL_0) counter <= (counter == 71)? 0: counter + 1;
	else counter <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) in_number_2 <= 0;
    else in_number_2 <= in_number;
	// else if(start) in_number_2 <= in_number;
    // else if(current_state == CAL_0) in_number_2 <= in_number;
	// else in_number_2 <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) in_number_3 <= 0;
    else in_number_3 <= in_number_2;
	// else if(start) in_number_3 <= in_number_2;
    // else if(current_state == CAL_0) in_number
	// else in_number_3 <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) in_number_4 <= 0;
	else in_number_4 <= in_number_3;
    // else if(current_state == CAL_0) in_number
	// else in_number_4 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) fin_flag <= 0;
    else if(hist_counter == 15 && counter == 71) fin_flag <= 1;
    else fin_flag <= 0;
end

//================================================================
//  Pipeline
//================================================================

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        R1 <= 0;
        R2 <= 0;
        R3 <= 0;
        R4 <= 0;
        R5 <= 0;
        R6 <= 0;
        R7 <= 0;
        R8 <= 0;
    end
	else if(current_state == CAL_0 && counter <= 63)begin
        case (window_reg)
            0: begin
                if(counter == 0)begin
                    R1 <= 0;
                    R2 <= hist_cap[0];
                    R3 <= hist_cap[1];
                    R4 <= hist_cap[2];
                    R5 <= hist_cap[0];
                    R6 <= hist_cap[1];
                    R7 <= hist_cap[2];
                    R8 <= hist_cap[3];
                end
                else begin
                    R1 <= R8;
                    R2 <= hist_cap[0];
                    R3 <= hist_cap[1];
                    R4 <= hist_cap[2];
                    R5 <= hist_cap[0];
                    R6 <= hist_cap[1];
                    R7 <= hist_cap[2];
                    R8 <= (counter == 63)? 0: hist_cap[3];
                end
            end
            1: begin
                if(counter == 0)begin
                    R1 <= 0;
                    R2 <= 0;
                    R3 <= hist_cap[0];
                    R4 <= hist_cap[1];
                    R5 <= hist_cap[0];
                    R6 <= hist_cap[1];
                    R7 <= hist_cap[2];
                    R8 <= hist_cap[3];
                end
                else begin
                    R1 <= R7;
                    R2 <= R8;
                    R3 <= hist_cap[0];
                    R4 <= hist_cap[1];
                    R5 <= hist_cap[0];
                    R6 <= hist_cap[1];
                    R7 <= hist_cap[2];
                    R8 <= (counter == 63)? 0: hist_cap[3]; 
                end
            end 
            2: begin
                if(counter == 0)begin
                    R1 <= 0;
                    R2 <= 0;
                    R3 <= 0;
                    R4 <= 0;
                    R5 <= hist_cap[0];
                    R6 <= hist_cap[1];
                    R7 <= hist_cap[2];
                    R8 <= hist_cap[3];
                end
                else begin
                    R1 <= R5;
                    R2 <= R6;
                    R3 <= R7;
                    R4 <= R8;
                    R5 <= hist_cap[0];
                    R6 <= hist_cap[1];
                    R7 <= hist_cap[2];
                    R8 <= (counter == 63)? 0: hist_cap[3];
                end
            end
            3: begin
                if(counter == 0 || counter == 1)begin
                    R1 <= 0;
                    R2 <= 0;
                    R3 <= 0;
                    R4 <= 0;
                    R5 <= hist_cap[0];
                    R6 <= hist_cap[1];
                    R7 <= hist_cap[2];
                    R8 <= hist_cap[3];
                end
                else begin
                    R1 <= tmp_1;
                    R2 <= tmp_2;
                    R3 <= tmp_3;
                    R4 <= tmp_4;
                    R5 <= hist_cap[0];
                    R6 <= hist_cap[1];
                    R7 <= hist_cap[2];
                    R8 <= (counter == 63)? 0: hist_cap[3];
                end
            end
        endcase
    end
    else begin
        R1 <= 0;
        R2 <= 0;
        R3 <= 0;
        R4 <= 0;
        R5 <= 0;
        R6 <= 0;
        R7 <= 0;
        R8 <= 0;
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        tmp_1 <= 0;
        tmp_2 <= 0;
        tmp_3 <= 0;
        tmp_4 <= 0;
    end
    else begin
        tmp_1 <= R5;
        tmp_2 <= R6;
        tmp_3 <= R7;
        tmp_4 <= R8;
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        D1 <= 0;
        D2 <= 0;
        D3 <= 0;
        D4 <= 0;
    end
	else begin
        D1 <= R5 - R1;
        D2 <= R6 - R2;
        D3 <= R7 - R3;
        D4 <= R8 - R4;
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        S1 <= 0;
        S2 <= 0;
        S3 <= 0;
        S4 <= 0;
    end 
    else begin
        S1 <= D1;
        S2 <= D1 + D2;
        S3 <= D3;
        S4 <= D3 + D4;
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        S5 <= 0;
        S6 <= 0;
        S7 <= 0;
        S8 <= 0;
    end 
    else begin
        S5 <= S1;
        S6 <= S2;
        S7 <= S2 + S3;
        S8 <= S2 + S4;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        C2 <= 0;
        M2 <= 0;
    end
    else begin
        if (S7 >= S8) begin
            C2 <= S7;
            M2 <= 2;
        end
        else begin
            C2 <= S8;
            M2 <= 3;           
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        C1 <= 0;
        M1 <= 0;
    end
    else begin
        if(S5 >= S6)begin
            C1 <= S5;
            M1 <= 0;
        end 
        else begin
            C1 <= S6;
            M1 <= 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ACC1 <= 0;
        ACC2 <= 0;
    end
    else begin
        ACC1 <= S8;
        ACC2 <= ACC1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        C3 <= 0;
        M3 <= 0;
    end
    else begin
        if(C1 >= C2)begin
            C3 <= C1;
            M3 <= M1;
        end 
        else begin
            C3 <= C2;
            M3 <= M2;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        diff_acc <= 0;
        Max_nxt <= 0;
        M4 <= 0;
    end
    else if(counter == 0)begin
        diff_acc <= 0;
        Max_nxt <= 0;
        M4 <= 0;
    end
    else begin
        diff_acc <= diff_acc + ACC2;
        Max_nxt <= diff_acc + C3;
        M4 <= M3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        Max_cur <= 0;
        Distance <= 0;
    end
    else if(counter == 0)begin
        Max_cur <= 0;
        Distance <= 0;
    end
    else begin
        if(Max_cur >= Max_nxt)begin
            Max_cur <= Max_cur;
            Distance <= Distance;
        end
        else begin
            Max_cur <= Max_nxt;
            case (window_reg)
                0: Distance <= (counter-7)*4 + M4 + 1;
                1: Distance <= (counter-7)*4 + M4;
                2: Distance <= (counter-7)*4 + M4 - 2;
                3: Distance <= (counter-7)*4 + M4 - 6;
            endcase
            
        end
    end
end

//================================================================
//  FSM
//================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     current_state <= IDLE ;
    else            current_state <= next_state ;
end
// Next State
always @(*) begin
    if (!rst_n) next_state = IDLE;
    else begin
        case (current_state)
        IDLE : next_state = (in_valid)? MODE: IDLE;
        MODE : begin
            if(mode_reg == 1) next_state = WAIT_1;
            else next_state = WAIT_0;
        end
        WAIT_0 : next_state = (start)? LOAD_0: WAIT_0;
        LOAD_0 : begin
            if(in_valid) next_state = (!start)? WAIT_0:LOAD_0 ;
            else next_state = CAL_0;
        end 
        CAL_0  : next_state = (fin_flag)? IDLE: CAL_0;
        WAIT_1 : next_state = (rvalid_m_inf)? LOAD_1: WAIT_1;
        LOAD_1 : next_state = (!rvalid_m_inf)? CAL_0: LOAD_1; 
        CAL_1  : next_state = CAL_1;
        default: next_state = IDLE;
        endcase
    end
end
// Out
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) busy <= 0;
    else if(current_state == WAIT_1 || current_state == LOAD_1 || current_state == CAL_0) busy <= 1;
    else busy <= 0;
end

//================================================================
//  AXI4 control
//================================================================
// always @(posedge clk or negedge rst_n)begin
// 	if(!rst_n) rd_addr <= 0;
// 	else if(current_state == LOAD_1 && next_state == WAIT_1) rd_addr <= rd_addr + 1;
// end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) rd_valid <= 0;
	else if(current_state == MODE && next_state == WAIT_1) rd_valid <= 1;
    else rd_valid <= 0;
end

// always @(posedge clk or negedge rst_n)begin
// 	if(!rst_n) wr_addr <= 0;
// 	else if(next_state == CAL_0) wr_addr <= 0;
// end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) wr_valid <= 0;
	else if(next_state == CAL_0) wr_valid <= 1;
    else wr_valid <= 0;
end

// always @(posedge clk or negedge rst_n)begin
always @(*)begin
	// if(!rst_n) wr_ready <= 0;
	if(current_state == CAL_0)begin
        if(counter>63)begin
            // if(counter == 71) 
             wr_ready = 0;
        end
        // else if(counter == 0)  wr_ready = 1;
        else wr_ready = (MEM_switch==0)? 1: 0;
    end 
    else wr_ready = 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wr_data <= 0;
    else if(current_state == CAL_0)begin
        if(counter<64)begin
            case (MEM_switch)
                0: wr_data[ 31:  0] <= {hist_cap[3], hist_cap[2], hist_cap[1], hist_cap[0]}; 
                1: wr_data[ 63: 32] <= {hist_cap[3], hist_cap[2], hist_cap[1], hist_cap[0]}; 
                2: wr_data[ 95: 64] <= {hist_cap[3], hist_cap[2], hist_cap[1], hist_cap[0]}; 
                3: begin
                    if(counter == 63) wr_data[127: 96] <= {7'h00, hist_cap[2], hist_cap[1], hist_cap[0]}; 
                    else wr_data[127: 96] <= {hist_cap[3], hist_cap[2], hist_cap[1], hist_cap[0]};
                end 
            endcase
        end
        else begin
            wr_data[127: 120] <= (Distance==0)?1:Distance;
        end
    end
end

// always @(*)begin
// 	// if(!rst_n) wr_data <= 0;
// 	if(current_state == CAL_0) wr_data = input_hist;
//     else wr_data = 0;
// end

//================================================================
//  AXI4 interface
//================================================================

AXI4_READ AXI4_INF_R(
    .clk(clk),
    .rst_n(rst_n),
// AXI4 IO
// axi read address channel 
    .araddr_m_inf(araddr_m_inf),
    .arvalid_m_inf(arvalid_m_inf),
    .arready_m_inf(arready_m_inf),
// axi read data channel     
    .rdata_m_inf(rdata_m_inf),
    .rlast_m_inf(rlast_m_inf),
    .rvalid_m_inf(rvalid_m_inf),
    .rready_m_inf(rready_m_inf),
// other
    .rd_valid(rd_valid),
    .rd_addr(frame_reg)
    // .rd_data(rd_data)
);

AXI4_WRITE AXI4_INF_W(
    .clk(clk),
    .rst_n(rst_n),
// AXI4 IO
// axi write address channel 
    .awaddr_m_inf(awaddr_m_inf),
    .awvalid_m_inf(awvalid_m_inf),
    .awready_m_inf(awready_m_inf),
// axi write data channel 
    .wdata_m_inf(wdata_m_inf),
    .wlast_m_inf(wlast_m_inf),
    .wvalid_m_inf(wvalid_m_inf),
    .wready_m_inf(wready_m_inf),
// axi write response channel 
    // .bresp_m_inf(bresp_m_inf),
    .bvalid_m_inf(bvalid_m_inf),
    .bready_m_inf(bready_m_inf), 
// other
    .wr_valid(wr_valid),
    .wr_addr(frame_reg), // 5 bit
    .wr_data(wr_data),
    .wr_ready(wr_ready),
    .wr_last(fin_flag)
);
endmodule


//################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//  AXI4_READ module
//
// For mode 1:
//     1. read histogram only
//     2. check rvalid_m_inf signal
//     3. than data will input from pattern
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//################################################################

module AXI4_READ(
    // CHIP IO
    clk,
    rst_n,
// AXI4 IO
// axi read address channel 
    araddr_m_inf,
    arvalid_m_inf,
    arready_m_inf,
// axi read data channel     
    rdata_m_inf,
    rlast_m_inf,
    rvalid_m_inf,
    rready_m_inf,
// other
    rd_valid,
    rd_addr
    // rd_data
);

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 128;
// global signals 
input   clk, rst_n;
// axi read address channel 
output reg                   arvalid_m_inf;
input  wire                  arready_m_inf;
output reg  [ADDR_WIDTH-1:0]  araddr_m_inf;
// axi read data channel 
input  wire [DATA_WIDTH-1:0]  rdata_m_inf;
input  wire                   rlast_m_inf;
input  wire                  rvalid_m_inf;
output reg                   rready_m_inf;
// other
input wire [4:0] rd_addr;
input wire rd_valid;
// output
parameter IDLE  = 3'd0 ;
parameter VALID = 3'd1 ;
parameter WAIT  = 3'd2 ;
parameter GET   = 3'd3 ;


reg  [2:0] current_state, next_state;
//  address (10000~2ffff) 32'h
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) araddr_m_inf <= 0;
    else if(next_state == VALID) araddr_m_inf <= {12'd0, 8'h10 + rd_addr,12'b0000_0000_0000};
    else araddr_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) arvalid_m_inf <= 0;
    else if(next_state == VALID) arvalid_m_inf <= 1;
    else arvalid_m_inf <= 0;
end
// assign rready_m_inf = 1;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) rready_m_inf <= 0;
    else if(next_state == WAIT || next_state == GET) rready_m_inf <= 1;
    else rready_m_inf <= 0;
end
//================================================================
//  FSM
//================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     current_state <= IDLE ;
    else            current_state <= next_state ;
end
// Next State
always @(*) begin
    if (!rst_n) next_state = IDLE;
    else begin
        case (current_state)
        IDLE : next_state = (rd_valid)?VALID: IDLE;
        VALID: next_state = (arready_m_inf)? WAIT: VALID;
        WAIT : next_state = (rvalid_m_inf)? GET: WAIT;
        GET  : begin
            if(!rvalid_m_inf) next_state = IDLE;
            else next_state = GET;
        end
        default: next_state = IDLE;
        endcase
    end
end
endmodule

//################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//  AXI4_WRITE module
//  
// For mode 0: 
//     1. wirte histogram and distance
// For mode 1:
//     1. wirte distance only
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//################################################################

module AXI4_WRITE(
    // CHIP IO
    clk,
    rst_n,
// AXI4 IO
// axi write address channel 
    awaddr_m_inf,
    awvalid_m_inf,
    awready_m_inf,
// axi write data channel 
    wdata_m_inf,
    wlast_m_inf,
    wvalid_m_inf,
    wready_m_inf,
// axi write response channel 
    // bresp_m_inf,
    bvalid_m_inf,
    bready_m_inf, 
// other
    wr_valid,
    wr_addr, 
    wr_data,
    wr_ready,
    wr_last
);

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 128;
// global signals 
input   clk, rst_n;
// axi read address channel 
output reg                   awvalid_m_inf;
input  wire                  awready_m_inf;
output reg  [ADDR_WIDTH-1:0]  awaddr_m_inf;
// axi read data channel 
output reg  [DATA_WIDTH-1:0]   wdata_m_inf;
output reg                     wlast_m_inf;
output reg                    wvalid_m_inf;
input  wire                   wready_m_inf;
// axi write response channel 
// input  wire                    bresp_m_inf;
input  wire                   bvalid_m_inf;
output reg                    bready_m_inf;
// other
input wire        wr_valid;
input wire [4:0]  wr_addr;
input wire [127:0] wr_data;
input wire        wr_ready;
input wire         wr_last;

parameter IDLE  = 3'd0 ;
parameter VALID = 3'd1 ;
// parameter WAIT  = 3'd2 ;
parameter WRITE = 3'd3 ;

reg  [2:0] current_state, next_state;

//  address (10000~2ffff) 32'h
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) awaddr_m_inf <= 0;
    else if(next_state == VALID) awaddr_m_inf <= {12'd0, 8'h10 + wr_addr,12'b0000_0000_0000};
    else awaddr_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) awvalid_m_inf <= 0;
    else if(next_state == VALID) awvalid_m_inf <= 1;
    else awvalid_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wvalid_m_inf <= 0;
    else if(next_state == WRITE)begin
        // if(wready_m_inf) wvalid_m_inf <= 0;
        // else wvalid_m_inf <= 1;
        if(wr_ready) wvalid_m_inf <= 1;
        else if(wready_m_inf) wvalid_m_inf <= 0;
        else wvalid_m_inf <= wvalid_m_inf;
    end 
    else wvalid_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wdata_m_inf <= 0;
    // else if(next_state == WRITE) wdata_m_inf <= 32'h2fff3;
    else if(next_state == WRITE) wdata_m_inf <= (wr_ready)? wr_data: wdata_m_inf;
    else wdata_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wlast_m_inf <= 0;
    else if(next_state == WRITE) wlast_m_inf <= (wr_last)? 1: 0;
    else wlast_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) bready_m_inf <= 0;
    else if(next_state == WRITE) bready_m_inf <= 1;
    else bready_m_inf <= 0;
end
//================================================================
//  FSM
//================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     current_state <= IDLE ;
    else            current_state <= next_state ;
end
// Next State
always @(*) begin
    if (!rst_n) next_state = IDLE;
    else begin
        case (current_state)
        IDLE  : next_state = (wr_valid)?VALID: IDLE;
        VALID : next_state = (awready_m_inf)? WRITE: VALID;
        // WAIT  : next_state = (wr_ready)? WRITE: WAIT;
        WRITE : begin
            if(bvalid_m_inf) next_state = IDLE;
            else next_state = WRITE;
        end
        default: next_state = IDLE;
        endcase
    end
end
endmodule