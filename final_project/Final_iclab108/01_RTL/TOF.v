//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2022 SPRING
//   Final Proejct              : TOF  
//   Author                     : Che-Yu, Lin
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
parameter WAIT_0 = 3'd2; // mode 0 wait for rvalid
parameter LOAD_0 = 3'd3;
parameter CAL_0  = 3'd4;
parameter WAIT_1 = 3'd5; // mode 1 wait for start
parameter LOAD_1 = 3'd6;
reg [2:0] current_state, next_state;

//================================================================
//  reg wire declaration
//================================================================
integer i,j;

reg [1:0] type_reg;
reg [4:0] frame_reg;

reg [6:0] in_number_1, in_number_2;
reg initial_flag;

wire [63:0] hist_cal;
reg  [63:0] hist;
reg  [3:0]  hist_cap;

reg  [3:0]  buffer_0, buffer_1, buffer_2, buffer_3, buffer_4;
reg  [6:0]  buffer_sum;
reg  [6:0]  max_cur;
reg  [7:0]  distance;

wire [3:0]     cur_mem_out [0:15];

wire [3:0]  horizontal_sum [0:11];
wire [3:0]    vertical_sum [0:11];

reg  [3:0]   buffer_temp_0 [0:2];
reg  [3:0]   buffer_temp_1 [0:2];
reg  [3:0]   buffer_temp_2 [0:2];
reg  [3:0]   buffer_temp_3 [0:2];
reg  [3:0]   buffer_temp_4 [0:2];
reg  [6:0] buffer_temp_sum [0:2];
reg  [6:0]    max_temp_cur [0:2];
reg  [7:0]   distance_temp [0:2];

wire [7:0]      distance_diff[0:2];
wire [7:0] distance_temp_diff[0:2];
reg  [7:0]         distance_modify;

reg [3:0] hist_counter;
reg [7:0] counter;

reg fin_flag;
wire counter_255_flag;
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
reg         MEM_switch;      
// SRAM_1
reg          MEM_wen_1;
reg  [6:0]  MEM_addr_1;
reg  [63:0]   MEM_in_1;
wire [63:0]  MEM_out_1;

RA1SH_64_128 SRAM_1(.Q(MEM_out_1), .CLK(clk), .CEN(1'b0), .WEN(MEM_wen_1), .A(MEM_addr_1), .D(MEM_in_1), .OEN(1'b0));

always @(*)begin
    MEM_addr_1 = in_number_1;
end
always @(*) begin
    if(rvalid_m_inf || next_state == LOAD_1) MEM_wen_1 = (MEM_switch==0)? 0: 1;
	else MEM_wen_1 = 1;
end
always @(*) begin
	if(rvalid_m_inf) MEM_in_1 = { rdata_m_inf[123:120], rdata_m_inf[115:112], rdata_m_inf[107:104], rdata_m_inf[ 99: 96], 
                                  rdata_m_inf[ 91: 88], rdata_m_inf[ 83: 80], rdata_m_inf[ 75: 72], rdata_m_inf[ 67: 64],
                                  rdata_m_inf[ 59: 56], rdata_m_inf[ 51: 48], rdata_m_inf[ 43: 40], rdata_m_inf[ 35: 32],
                                  rdata_m_inf[ 27: 24], rdata_m_inf[ 19: 16], rdata_m_inf[ 11:  8], rdata_m_inf[  3:  0]};
    else if(next_state == LOAD_1) MEM_in_1 = hist_cal; 
	else MEM_in_1 = 'd0;
end

// SRAM_2
reg          MEM_wen_2;
reg  [6:0]  MEM_addr_2;
reg  [63:0]   MEM_in_2;
wire [63:0]  MEM_out_2;

RA1SH_64_128 SRAM_2(.Q(MEM_out_2), .CLK(clk), .CEN(1'b0), .WEN(MEM_wen_2), .A(MEM_addr_2), .D(MEM_in_2), .OEN(1'b0) );

always @(*)begin
    MEM_addr_2 = in_number_2;
end
always @(*) begin
    if(rvalid_m_inf) MEM_wen_2 = (MEM_switch==1)? 0: 1;
    else if(next_state == LOAD_1) MEM_wen_2 = (MEM_switch==1)? 0: 1;
	else MEM_wen_2 = 1;
end
always @(*) begin
	if(rvalid_m_inf) MEM_in_2 = {rdata_m_inf[123:120], rdata_m_inf[115:112], rdata_m_inf[107:104], rdata_m_inf[ 99: 96], 
                                 rdata_m_inf[ 91: 88], rdata_m_inf[ 83: 80], rdata_m_inf[ 75: 72], rdata_m_inf[ 67: 64],
                                 rdata_m_inf[ 59: 56], rdata_m_inf[ 51: 48], rdata_m_inf[ 43: 40], rdata_m_inf[ 35: 32],
                                 rdata_m_inf[ 27: 24], rdata_m_inf[ 19: 16], rdata_m_inf[ 11:  8], rdata_m_inf[  3:  0]};
    else if(next_state == LOAD_1) MEM_in_2 = hist_cal;
	else MEM_in_2 = 'd0;
end

// Switch
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) MEM_switch <= 0;
    else if(rvalid_m_inf || next_state == LOAD_1) MEM_switch <= ~MEM_switch;
    else MEM_switch <= 0;
end

always @(*) begin
    if(!MEM_switch) hist = (!initial_flag)? 0: MEM_out_1;
    else hist = (!initial_flag)? 0: MEM_out_2;
end

//================================================================
//  wire assign
//================================================================
assign hist_cal =  {hist[63:60] + stop[15], hist[59:56] + stop[14], hist[55:52] + stop[13], hist[51:48] + stop[12], 
                    hist[47:44] + stop[11], hist[43:40] + stop[10], hist[39:36] + stop[ 9], hist[35:32] + stop[ 8], 
                    hist[31:28] + stop[ 7], hist[27:24] + stop[ 6], hist[23:20] + stop[ 5], hist[19:16] + stop[ 4], 
                    hist[15:12] + stop[ 3], hist[11: 8] + stop[ 2], hist[ 7: 4] + stop[ 1], hist[ 3: 0] + stop[ 0]};

assign cur_mem_out[ 0] = (!counter[0])? MEM_out_1[ 3: 0] : MEM_out_2[ 3: 0];
assign cur_mem_out[ 1] = (!counter[0])? MEM_out_1[ 7: 4] : MEM_out_2[ 7: 4];
assign cur_mem_out[ 2] = (!counter[0])? MEM_out_1[11: 8] : MEM_out_2[11: 8];
assign cur_mem_out[ 3] = (!counter[0])? MEM_out_1[15:12] : MEM_out_2[15:12];
assign cur_mem_out[ 4] = (!counter[0])? MEM_out_1[19:16] : MEM_out_2[19:16];
assign cur_mem_out[ 5] = (!counter[0])? MEM_out_1[23:20] : MEM_out_2[23:20];
assign cur_mem_out[ 6] = (!counter[0])? MEM_out_1[27:24] : MEM_out_2[27:24];
assign cur_mem_out[ 7] = (!counter[0])? MEM_out_1[31:28] : MEM_out_2[31:28];
assign cur_mem_out[ 8] = (!counter[0])? MEM_out_1[35:32] : MEM_out_2[35:32];
assign cur_mem_out[ 9] = (!counter[0])? MEM_out_1[39:36] : MEM_out_2[39:36];
assign cur_mem_out[10] = (!counter[0])? MEM_out_1[43:40] : MEM_out_2[43:40];
assign cur_mem_out[11] = (!counter[0])? MEM_out_1[47:44] : MEM_out_2[47:44];
assign cur_mem_out[12] = (!counter[0])? MEM_out_1[51:48] : MEM_out_2[51:48];
assign cur_mem_out[13] = (!counter[0])? MEM_out_1[55:52] : MEM_out_2[55:52];
assign cur_mem_out[14] = (!counter[0])? MEM_out_1[59:56] : MEM_out_2[59:56];
assign cur_mem_out[15] = (!counter[0])? MEM_out_1[63:60] : MEM_out_2[63:60];

assign horizontal_sum[ 0] = cur_mem_out[ 0] + cur_mem_out[ 1];
assign horizontal_sum[ 1] = cur_mem_out[ 1] + cur_mem_out[ 2];
assign horizontal_sum[ 2] = cur_mem_out[ 2] + cur_mem_out[ 3];
assign horizontal_sum[ 3] = cur_mem_out[ 4] + cur_mem_out[ 5];
assign horizontal_sum[ 4] = cur_mem_out[ 5] + cur_mem_out[ 6];
assign horizontal_sum[ 5] = cur_mem_out[ 6] + cur_mem_out[ 7];
assign horizontal_sum[ 6] = cur_mem_out[ 8] + cur_mem_out[ 9];
assign horizontal_sum[ 7] = cur_mem_out[ 9] + cur_mem_out[10];
assign horizontal_sum[ 8] = cur_mem_out[11] + cur_mem_out[12];
assign horizontal_sum[ 9] = cur_mem_out[12] + cur_mem_out[13];
assign horizontal_sum[10] = cur_mem_out[13] + cur_mem_out[14];
assign horizontal_sum[11] = cur_mem_out[14] + cur_mem_out[15];

assign vertical_sum[ 0] = cur_mem_out[ 0] + cur_mem_out[ 4];
assign vertical_sum[ 1] = cur_mem_out[ 1] + cur_mem_out[ 5];
assign vertical_sum[ 2] = cur_mem_out[ 2] + cur_mem_out[ 6];
assign vertical_sum[ 3] = cur_mem_out[ 3] + cur_mem_out[ 7];
assign vertical_sum[ 4] = cur_mem_out[ 4] + cur_mem_out[ 8];
assign vertical_sum[ 5] = cur_mem_out[ 5] + cur_mem_out[ 9];
assign vertical_sum[ 6] = cur_mem_out[ 6] + cur_mem_out[10];
assign vertical_sum[ 7] = cur_mem_out[ 7] + cur_mem_out[11];
assign vertical_sum[ 8] = cur_mem_out[ 8] + cur_mem_out[12];
assign vertical_sum[ 9] = cur_mem_out[ 9] + cur_mem_out[13];
assign vertical_sum[10] = cur_mem_out[10] + cur_mem_out[14];
assign vertical_sum[11] = cur_mem_out[11] + cur_mem_out[15];

assign distance_diff[0] = (distance > distance_temp[0])? distance - distance_temp[0] : distance_temp[0] - distance;
assign distance_diff[1] = (distance > distance_temp[1])? distance - distance_temp[1] : distance_temp[1] - distance;
assign distance_diff[2] = (distance > distance_temp[2])? distance - distance_temp[2] : distance_temp[2] - distance;

assign distance_temp_diff[0] = (distance_temp[0] > distance_temp[1])? distance_temp[0] - distance_temp[1] : distance_temp[1] - distance_temp[0];
assign distance_temp_diff[1] = (distance_temp[1] > distance_temp[2])? distance_temp[1] - distance_temp[2] : distance_temp[2] - distance_temp[1];
assign distance_temp_diff[2] = (distance_temp[2] > distance_temp[0])? distance_temp[2] - distance_temp[0] : distance_temp[0] - distance_temp[2];

assign counter_255_flag = (counter == 255)? 1: 0;
//================================================================
//  Design
//================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        type_reg   <= 0;
        frame_reg  <= 0;
    end
    else if(next_state == MODE)begin
        type_reg   <= inputtype;
        frame_reg  <= frame_id;
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) initial_flag <= 0;
	else if(current_state == LOAD_1 && next_state == WAIT_1) initial_flag <= 1;
    else if(current_state == IDLE) initial_flag <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) fin_flag <= 0;
    else if(hist_counter == 15 && counter_255_flag) fin_flag <= 1;
    else fin_flag <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) in_number_1 <= 0;
    else if(rvalid_m_inf)          in_number_1 <= ( MEM_switch)? in_number_1 + 1: in_number_1;
    else if(next_state == LOAD_1)  in_number_1 <= (!MEM_switch)? in_number_1 + 1: in_number_1;
    else if(current_state == CAL_0)begin
        if(type_reg == 0) in_number_1 <= (counter[4:0] == 5'd30)? in_number_1 + 1: in_number_1;
        else in_number_1 <= (!counter[0])? in_number_1 + 1 : in_number_1;
    end 
	else in_number_1 <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) in_number_2 <= 0;
    else in_number_2 <= in_number_1;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) counter <= 0;
    else if(current_state == CAL_0) counter <= (counter_255_flag)? 0: counter + 1;
	else counter <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) hist_counter <= 0;
    else if(current_state == CAL_0) hist_counter <= (counter_255_flag)? hist_counter + 1: hist_counter;
	else hist_counter <= 0;
end
//================================================================
//  Slide Windows
//================================================================
always @(*) begin
    if(type_reg[1] == 0)begin
        buffer_sum = buffer_0  + buffer_2  + buffer_4;
    end
    else begin
        // buffer_sum = buffer_0 + buffer_1 + buffer_2 + buffer_3 + buffer_4;
        // buffer_sum = buffer_1 + buffer_2 + buffer_3;
        buffer_sum = buffer_0 + buffer_1 + buffer_2 + buffer_3 + buffer_4 ;
    end
end

always @(*) begin
    for(i = 0; i < 3; i = i + 1)begin
        buffer_temp_sum[i] = buffer_temp_0[i] + buffer_temp_1[i] + buffer_temp_2[i] + buffer_temp_3[i] + buffer_temp_4[i];
    end
end

always @(*) begin
    if (type_reg == 0) begin
        case (counter[4:0])
            0:  hist_cap = MEM_out_1[ 3: 0];
            1:  hist_cap = MEM_out_1[ 7: 4];
            2:  hist_cap = MEM_out_1[11: 8];
            3:  hist_cap = MEM_out_1[15:12];
            4:  hist_cap = MEM_out_1[19:16];
            5:  hist_cap = MEM_out_1[23:20];
            6:  hist_cap = MEM_out_1[27:24];
            7:  hist_cap = MEM_out_1[31:28];
            8:  hist_cap = MEM_out_1[35:32];
            9:  hist_cap = MEM_out_1[39:36];
            10: hist_cap = MEM_out_1[43:40];
            11: hist_cap = MEM_out_1[47:44];
            12: hist_cap = MEM_out_1[51:48];
            13: hist_cap = MEM_out_1[55:52];
            14: hist_cap = MEM_out_1[59:56];
            15: hist_cap = MEM_out_1[63:60];
            16: hist_cap = MEM_out_2[ 3: 0];
            17: hist_cap = MEM_out_2[ 7: 4];
            18: hist_cap = MEM_out_2[11: 8];
            19: hist_cap = MEM_out_2[15:12];
            20: hist_cap = MEM_out_2[19:16];
            21: hist_cap = MEM_out_2[23:20];
            22: hist_cap = MEM_out_2[27:24];
            23: hist_cap = MEM_out_2[31:28];
            24: hist_cap = MEM_out_2[35:32];
            25: hist_cap = MEM_out_2[39:36];
            26: hist_cap = MEM_out_2[43:40];
            27: hist_cap = MEM_out_2[47:44];
            28: hist_cap = MEM_out_2[51:48];
            29: hist_cap = MEM_out_2[55:52];
            30: hist_cap = MEM_out_2[59:56];
            31: hist_cap = MEM_out_2[63:60];   
        endcase
    end
    else begin
        case (hist_counter)
            0:  hist_cap = cur_mem_out[ 0];
            1:  hist_cap = cur_mem_out[ 1];
            2:  hist_cap = cur_mem_out[ 2];
            3:  hist_cap = cur_mem_out[ 3];
            4:  hist_cap = cur_mem_out[ 4];
            5:  hist_cap = cur_mem_out[ 5];
            6:  hist_cap = cur_mem_out[ 6];
            7:  hist_cap = cur_mem_out[ 7];
            8:  hist_cap = cur_mem_out[ 8];
            9:  hist_cap = cur_mem_out[ 9];
            10: hist_cap = cur_mem_out[10];
            11: hist_cap = cur_mem_out[11];
            12: hist_cap = cur_mem_out[12];
            13: hist_cap = cur_mem_out[13];
            14: hist_cap = cur_mem_out[14];
            15: hist_cap = cur_mem_out[15]; 
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buffer_0 <= 0;
    end
    else if (current_state == CAL_0) begin
        if(type_reg == 2'b00) 
            buffer_0 <= hist_cap;
        else if(type_reg == 2'b01)begin
            case (hist_counter)
                0:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 0] + cur_mem_out[ 1] + cur_mem_out[ 4] + cur_mem_out[ 5]);
                1:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 0] + cur_mem_out[ 1] + cur_mem_out[ 4] + cur_mem_out[ 5]);
                2:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 2] + cur_mem_out[ 3] + cur_mem_out[ 6] + cur_mem_out[ 7]);
                3:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 2] + cur_mem_out[ 3] + cur_mem_out[ 6] + cur_mem_out[ 7]);
                4:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 0] + cur_mem_out[ 1] + cur_mem_out[ 4] + cur_mem_out[ 5]);
                5:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 0] + cur_mem_out[ 1] + cur_mem_out[ 4] + cur_mem_out[ 5]);
                6:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 2] + cur_mem_out[ 3] + cur_mem_out[ 6] + cur_mem_out[ 7]);
                7:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 2] + cur_mem_out[ 3] + cur_mem_out[ 6] + cur_mem_out[ 7]);
                8:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 8] + cur_mem_out[ 9] + cur_mem_out[12] + cur_mem_out[13]);
                9:  buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 8] + cur_mem_out[ 9] + cur_mem_out[12] + cur_mem_out[13]);
                10: buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[10] + cur_mem_out[11] + cur_mem_out[14] + cur_mem_out[15]);
                11: buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[10] + cur_mem_out[11] + cur_mem_out[14] + cur_mem_out[15]);
                12: buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 8] + cur_mem_out[ 9] + cur_mem_out[12] + cur_mem_out[13]);
                13: buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[ 8] + cur_mem_out[ 9] + cur_mem_out[12] + cur_mem_out[13]);
                14: buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[10] + cur_mem_out[11] + cur_mem_out[14] + cur_mem_out[15]);
                15: buffer_0 <= (counter_255_flag)? 0 : (cur_mem_out[10] + cur_mem_out[11] + cur_mem_out[14] + cur_mem_out[15]);
            endcase 
        end
        else begin
            case (hist_counter)
                0 : begin
                    if(vertical_sum[0] > horizontal_sum[0]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[0];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[0];
                end 
                1 : begin
                    if(vertical_sum[1] > horizontal_sum[1]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[1];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[1];
                end
                2 : begin
                    if(vertical_sum[2] > horizontal_sum[2]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[2];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[2];
                end
                3 : begin
                    if(vertical_sum[3] > horizontal_sum[2]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[3];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[2];
                end
                4 : begin
                    if(vertical_sum[4] > horizontal_sum[3]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[4];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[3];
                end
                5: begin
                    if(vertical_sum[5] > horizontal_sum[4]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[5];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[4];
                end
                6: begin
                    if(vertical_sum[6] > horizontal_sum[5]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[6];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[5];
                end
                7: begin
                    if(vertical_sum[7] > horizontal_sum[5]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[7];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[5];
                end
                8: begin
                    if(vertical_sum[8] > horizontal_sum[6]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[8];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[6];
                end
                9: begin
                    if(vertical_sum[9] > horizontal_sum[7]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[9];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[7];
                end
                10:begin
                    if(vertical_sum[10] > horizontal_sum[8]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[10];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[8];
                end
                11:begin
                    if(vertical_sum[11] > horizontal_sum[8]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[11];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[8];
                end
                12:begin
                    if(vertical_sum[8] > horizontal_sum[9]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[8];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[9];
                end
                13:begin
                    if(vertical_sum[9] > horizontal_sum[10]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[9];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[10];
                end
                14:begin
                    if(vertical_sum[10] > horizontal_sum[11]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[10];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[11];
                end
                15:begin
                    if(vertical_sum[11] > horizontal_sum[11]) buffer_0 <= (counter_255_flag)? 0 : vertical_sum[11];
                    else buffer_0 <= (counter_255_flag)? 0 : horizontal_sum[11];
                end
            endcase 
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 3; i = i + 1)begin
            buffer_temp_0[i] <= 0; 
        end
    end
    else if (current_state == CAL_0)begin
        case (hist_counter)
            0 : begin
                if(vertical_sum[1] > horizontal_sum[1]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[1];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[1];
                if(vertical_sum[4] > horizontal_sum[3])
                     buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[4];
                else
                     buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[3];
                if(vertical_sum[5] > horizontal_sum[4]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[5];
                else
                     buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[4];
            end 
            1 : begin
                if(vertical_sum[2] > horizontal_sum[2]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[2];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[2];
                if(vertical_sum[5] > horizontal_sum[4]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[5];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[4];
                if(vertical_sum[0] > horizontal_sum[0]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[0];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[0];
            end
            2 : begin
                if(vertical_sum[3] > horizontal_sum[2]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[3];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[2];
                if(vertical_sum[6] > horizontal_sum[5]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[6];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[5];
                if(vertical_sum[1] > horizontal_sum[1]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[1];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[1];
            end
            3 : begin
                if(vertical_sum[2] > horizontal_sum[2]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[2];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[2];
                if(vertical_sum[6] > horizontal_sum[5]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[6];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[5];
                if(vertical_sum[7] > horizontal_sum[5]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[7];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[5];
            end
            4 : begin
                if(vertical_sum[5] > horizontal_sum[4]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[5];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[4];
                if(vertical_sum[8] > horizontal_sum[6]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[8];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[6];
                if(vertical_sum[0] > horizontal_sum[0]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[0];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[0];
            end
            5: begin
                if(vertical_sum[6] > horizontal_sum[5]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[6];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[5];
                if(vertical_sum[9] > horizontal_sum[7]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[9];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[7];
                if(vertical_sum[1] > horizontal_sum[1]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[1];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[1];
            end
            6: begin
                if(vertical_sum[7] > horizontal_sum[5]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[7];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[5];
                if(vertical_sum[10] > horizontal_sum[8]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[8];
                if(vertical_sum[2] > horizontal_sum[2]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[2];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[2];
            end
            7: begin
                if(vertical_sum[6] > horizontal_sum[5]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[6];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[5];
                if(vertical_sum[10] > horizontal_sum[8]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[8];
                if(vertical_sum[3] > horizontal_sum[2]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[3];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[2];
            end
            8: begin
                if(vertical_sum[9] > horizontal_sum[7]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[9];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[7];
                if(vertical_sum[8] > horizontal_sum[9]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[8];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[9];
                if(vertical_sum[4] > horizontal_sum[3]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[4];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[3];
            end
            9: begin
                if(vertical_sum[10] > horizontal_sum[8]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                if(vertical_sum[9] > horizontal_sum[10]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[9];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[10];
                if(vertical_sum[5] > horizontal_sum[4]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[5];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[4];
            end
            10:begin
                if(vertical_sum[11] > horizontal_sum[8]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[11];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                if(vertical_sum[10] > horizontal_sum[11]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[11];
                if(vertical_sum[6] > horizontal_sum[5]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[6];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[5];
            end
            11:begin
                if(vertical_sum[10] > horizontal_sum[8]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                if(vertical_sum[7] > horizontal_sum[5]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[7];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[5];
                if(vertical_sum[11] > horizontal_sum[11]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[11];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
            end
            12:begin
                if(vertical_sum[8] > horizontal_sum[6]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[8];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[6];
                if(vertical_sum[9] > horizontal_sum[7]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[9];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[7];
                if(vertical_sum[9] > horizontal_sum[10]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[9];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[10];
            end
            13:begin
                if(vertical_sum[9] > horizontal_sum[7]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[9];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[7];
                if(vertical_sum[8] > horizontal_sum[9]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[8];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[9];
                if(vertical_sum[10] > horizontal_sum[11]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
            end
            14:begin
                if(vertical_sum[10] > horizontal_sum[8]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                if(vertical_sum[9] > horizontal_sum[10])    
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[9];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[10];
                if(vertical_sum[11] > horizontal_sum[11]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[11];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
            end
            15:begin
                if(vertical_sum[10] > horizontal_sum[8]) 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                if(vertical_sum[11] > horizontal_sum[8]) 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[11];
                else 
                    buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[8];
                if(vertical_sum[10] > horizontal_sum[11]) 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[10];
                else 
                    buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
            end
                // 0 : begin
                //     if(vertical_sum[1] > horizontal_sum[1]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[1];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[1];
                //     if(vertical_sum[4] > horizontal_sum[3])
                //          buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[4];
                //     else
                //          buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[3];
                //     if(vertical_sum[5] > horizontal_sum[4]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[5];
                //     else
                //          buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[4];
                // end 
                // 1 : begin
                //     if(vertical_sum[2] > horizontal_sum[2]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[2];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[2];
                //     if(vertical_sum[5] > horizontal_sum[4]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[5];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[4];
                //     if(vertical_sum[6] > horizontal_sum[5]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[6];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[5];
                // end
                // 2 : begin
                //     if(vertical_sum[3] > horizontal_sum[2]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[3];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[2];
                //     if(vertical_sum[6] > horizontal_sum[5]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[6];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[5];
                //     if(vertical_sum[7] > horizontal_sum[5]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[7];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[5];
                // end
                // 3 : begin
                //     if(vertical_sum[2] > horizontal_sum[2]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[2];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[2];
                //     if(vertical_sum[6] > horizontal_sum[5]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[6];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[5];
                //     if(vertical_sum[7] > horizontal_sum[5]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[7];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[5];
                // end
                // 4 : begin
                //     if(vertical_sum[5] > horizontal_sum[4]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[5];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[4];
                //     if(vertical_sum[8] > horizontal_sum[6]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[8];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[6];
                //     if(vertical_sum[9] > horizontal_sum[7]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[9];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[7];
                // end
                // 5: begin
                //     if(vertical_sum[6] > horizontal_sum[5]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[6];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[5];
                //     if(vertical_sum[9] > horizontal_sum[7]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[9];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[7];
                //     if(vertical_sum[10] > horizontal_sum[8]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[8];
                // end
                // 6: begin
                //     if(vertical_sum[7] > horizontal_sum[5]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[7];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[5];
                //     if(vertical_sum[10] > horizontal_sum[8]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[11] > horizontal_sum[8]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[11];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[8];
                // end
                // 7: begin
                //     if(vertical_sum[6] > horizontal_sum[5]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[6];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[5];
                //     if(vertical_sum[10] > horizontal_sum[8]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[11] > horizontal_sum[8]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[11];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[8];
                // end
                // 8: begin
                //     if(vertical_sum[9] > horizontal_sum[7]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[9];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[7];
                //     if(vertical_sum[8] > horizontal_sum[9]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[8];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[9];
                //     if(vertical_sum[9] > horizontal_sum[10]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[9];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[10];
                // end
                // 9: begin
                //     if(vertical_sum[10] > horizontal_sum[8]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[9] > horizontal_sum[10]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[9];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[10];
                //     if(vertical_sum[10] > horizontal_sum[11]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
                // end
                // 10:begin
                //     if(vertical_sum[11] > horizontal_sum[8]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[11];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[10] > horizontal_sum[11]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[11];
                //     if(vertical_sum[11] > horizontal_sum[11]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[11];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
                // end
                // 11:begin
                //     if(vertical_sum[10] > horizontal_sum[8]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[10] > horizontal_sum[11]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[11];
                //     if(vertical_sum[11] > horizontal_sum[11]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[11];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
                // end
                // 12:begin
                //     if(vertical_sum[8] > horizontal_sum[6]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[8];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[6];
                //     if(vertical_sum[9] > horizontal_sum[7]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[9];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[7];
                //     if(vertical_sum[9] > horizontal_sum[10]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[9];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[10];
                // end
                // 13:begin
                //     if(vertical_sum[9] > horizontal_sum[7]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[9];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[7];
                //     if(vertical_sum[10] > horizontal_sum[8]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[10] > horizontal_sum[11]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
                // end
                // 14:begin
                //     if(vertical_sum[10] > horizontal_sum[8]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[11] > horizontal_sum[8])    
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[11];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[11] > horizontal_sum[11]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[11];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
                // end
                // 15:begin
                //     if(vertical_sum[10] > horizontal_sum[8]) 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[0] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[11] > horizontal_sum[8]) 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : vertical_sum[11];
                //     else 
                //         buffer_temp_0[1] <= (counter_255_flag)? 0 : horizontal_sum[8];
                //     if(vertical_sum[10] > horizontal_sum[11]) 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : vertical_sum[10];
                //     else 
                //         buffer_temp_0[2] <= (counter_255_flag)? 0 : horizontal_sum[11];
                // end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buffer_1 <= 0;
        buffer_2 <= 0;
        buffer_3 <= 0;
        buffer_4 <= 0; 
    end
    else if (current_state == CAL_0) begin
        buffer_1 <= (counter_255_flag)? 0 : buffer_0;
        buffer_2 <= (counter_255_flag)? 0 : buffer_1;
        buffer_3 <= (counter_255_flag)? 0 : buffer_2;
        buffer_4 <= (counter_255_flag)? 0 : buffer_3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 3; i = i + 1)begin
            buffer_temp_1[i] <= 0;
            buffer_temp_2[i] <= 0;
            buffer_temp_3[i] <= 0;
            buffer_temp_4[i] <= 0;  
        end
    end
    else if (current_state == CAL_0) begin
        for(i = 0; i < 3; i = i + 1)begin
            buffer_temp_1[i] <= (counter_255_flag)? 0 : buffer_temp_0[i];
            buffer_temp_2[i] <= (counter_255_flag)? 0 : buffer_temp_1[i];
            buffer_temp_3[i] <= (counter_255_flag)? 0 : buffer_temp_2[i];
            buffer_temp_4[i] <= (counter_255_flag)? 0 : buffer_temp_3[i]; 
        end    
    end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) max_cur <= 0;
    else if(counter == 0) max_cur <= 0;
    else if(current_state == CAL_0)begin
        max_cur <= (buffer_sum >= max_cur)? buffer_sum: max_cur;
        // if(hist_counter[0]) max_cur <= (buffer_sum >= max_cur)? buffer_sum: max_cur;
        // else max_cur <= (buffer_sum >= max_cur)? buffer_sum: max_cur;
    end
    end 

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) distance <= 0;
    else if(counter == 0) distance <= 0;
    else if(current_state == CAL_0)begin
        distance <= (buffer_sum >= max_cur)? counter: distance;
        // if(hist_counter[0]) distance <= (buffer_sum >= max_cur)? counter: distance;
        // else distance <= (buffer_sum >= max_cur)? counter: distance;
    end 
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        for(i = 0; i < 3; i = i + 1)begin
            max_temp_cur[i] <= 0;
        end
    end 
    else if(counter == 0) begin
        for(i = 0; i < 3; i = i + 1)begin
            max_temp_cur[i] <= 0;
        end
    end 
    else if(current_state == CAL_0)begin
        for(i = 0; i < 3; i = i + 1)begin
            max_temp_cur[i] <= (buffer_temp_sum[i] >= max_temp_cur[i])? buffer_temp_sum[i]: max_temp_cur[i];
        end
    end
end 

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
        for(i = 0; i < 3; i = i + 1)begin
            distance_temp[i] <= 0;
        end
    end 
    else if(counter == 0) begin
        for(i = 0; i < 3; i = i + 1)begin
            distance_temp[i] <= 0;
        end
    end
    else if(current_state == CAL_0)begin
        for(i = 0; i < 3; i = i + 1)begin
            distance_temp[i] <= (buffer_temp_sum[i] >= max_temp_cur[i])? counter: distance_temp[i];
        end
    end 
end

always @(*) begin
    // if(distance_diff[0] > 25 && distance_diff[1] > 25) distance_modify = distance_temp[0];
    // else if(distance_diff[1] > 25 && distance_diff[2] > 25) distance_modify = distance_temp[1];
    // else if(distance_diff[2] > 25 && distance_diff[0] > 25) distance_modify = distance_temp[2];
    // else distance_modify = distance;
    if(distance_temp_diff[0] < 10 && distance_diff[0] > 20) distance_modify = distance_temp[0];
    else if(distance_temp_diff[1] < 10 && distance_diff[1] > 20) distance_modify = distance_temp[1];
    else if(distance_temp_diff[2] < 10 && distance_diff[2] > 20) distance_modify = distance_temp[2];
    else distance_modify = distance;
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
            case (type_reg)
                2'b00: next_state = WAIT_0; 
                2'b01: next_state = WAIT_1;
                2'b10: next_state = WAIT_1;
                2'b11: next_state = WAIT_1;  
            endcase
        end
        WAIT_0 : next_state = (rvalid_m_inf)? LOAD_0: WAIT_0;
        LOAD_0 : next_state = (!rvalid_m_inf)? CAL_0: LOAD_0;
        CAL_0  : next_state = (fin_flag)? IDLE: CAL_0;
        WAIT_1 : next_state = (start)? LOAD_1: WAIT_1;
        LOAD_1 : next_state = (!in_valid)? CAL_0: ((!start)? WAIT_1: LOAD_1);
        default: next_state = IDLE;
        endcase
    end
end
// Out
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) busy <= 0;
    else if(current_state == CAL_0 || current_state == LOAD_0 || current_state == WAIT_0) busy <= 1;
    else busy <= 0;
end

//================================================================
//  AXI4 control
//================================================================
always @(posedge clk or negedge rst_n)begin
	if(!rst_n) rd_valid <= 0;
	else if(current_state == MODE && type_reg == 0) rd_valid <= 1;
    else rd_valid <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) wr_valid <= 0;
	else if(current_state == LOAD_0 && next_state == CAL_0 ) wr_valid <= 1;
    else if(current_state == LOAD_1 && next_state == CAL_0 ) wr_valid <= 1;
    else wr_valid <= 0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n) wr_ready <= 0;
	else if(current_state == CAL_0)begin
        if(counter[3:0] == 15) wr_ready <= 1;
        else wr_ready <= 0;
        // else if(counter == 0)  wr_ready = 1;
        // else wr_ready = (MEM_switch==0)? 1: 0;
    end 
    else wr_ready <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wr_data <= 0;
    else if(current_state == CAL_0)begin
        if(type_reg[1]==0)begin
            if(counter_255_flag) 
                wr_data[127:120] <= (distance <= 4)? 1 : distance - 4;
            else
                wr_data[127:120] <= {4'd0, hist_cap};
        end
        else begin
            if(counter_255_flag) 
                wr_data[127:120] <= (distance_modify <= 4)? 1 : distance_modify - 4;//distance_modify
            else
                wr_data[127:120] <= {4'd0, hist_cap};
        end
        // wr_data[127:120] <= (counter_255_flag)? (distance - 4): {4'd0, hist_cap};
        wr_data[119:112] <= wr_data[127:120];
        wr_data[111:104] <= wr_data[119:112];
        wr_data[103: 96] <= wr_data[111:104];
        wr_data[ 95: 88] <= wr_data[103: 96];
        wr_data[ 87: 80] <= wr_data[ 95: 88];
        wr_data[ 79: 72] <= wr_data[ 87: 80];
        wr_data[ 71: 64] <= wr_data[ 79: 72];
        wr_data[ 63: 56] <= wr_data[ 71: 64];
        wr_data[ 55: 48] <= wr_data[ 63: 56];
        wr_data[ 47: 40] <= wr_data[ 55: 48];
        wr_data[ 39: 32] <= wr_data[ 47: 40];
        wr_data[ 31: 24] <= wr_data[ 39: 32];
        wr_data[ 23: 16] <= wr_data[ 31: 24];
        wr_data[ 15:  8] <= wr_data[ 23: 16];
        wr_data[  7:  0] <= wr_data[ 15:  8]; 
    end
end

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

//  address (10000~2ffff) 32'h
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) araddr_m_inf <= 0;
    else if(rd_valid) araddr_m_inf <= {12'd0, 8'h10 + rd_addr, 12'b0000_0000_0000};
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                   arvalid_m_inf <= 0;
    else if(rd_valid)            arvalid_m_inf <= 1;
    else if(arready_m_inf)       arvalid_m_inf <= 0;
end
// assign rready_m_inf = 1;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                   rready_m_inf <= 0;
    else if(arready_m_inf)       rready_m_inf <= 1;
    else if(rlast_m_inf)         rready_m_inf <= 0;
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

//  address (10000~2ffff) 32'h
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) awaddr_m_inf <= 0;
    else if(wr_valid) awaddr_m_inf <= {12'd0, 8'h10 + wr_addr,12'b0000_0000_0000};
    // else awaddr_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) awvalid_m_inf <= 0;
    else if(wr_valid) awvalid_m_inf <= 1;
    else if(awready_m_inf) awvalid_m_inf <= 0;
    // else awvalid_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wvalid_m_inf <= 0;
    else if(wr_ready) wvalid_m_inf <= 1;
    else if(wready_m_inf) wvalid_m_inf <= 0; 
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wdata_m_inf <= 0;
    // else if(next_state == WRITE) wdata_m_inf <= 32'h2fff3;
    else if(wr_ready) wdata_m_inf <= wr_data;
    else if(wready_m_inf) wdata_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wlast_m_inf <= 0;
    else if(wr_last) wlast_m_inf <= 1;
    else wlast_m_inf <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) bready_m_inf <= 0;
    else if(awready_m_inf) bready_m_inf <= 1;
    else if(bvalid_m_inf) bready_m_inf <= 0;
end
endmodule