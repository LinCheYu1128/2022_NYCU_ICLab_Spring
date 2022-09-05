module ESCAPE(
  //Input Port
  clk,
  rst_n,
  in_valid1,
  in_valid2,
  in,
  in_data,
  //Output Port
  out_valid1,
  out_valid2,
  out,
  out_data
);
// ===============================================================
// INPUT OUTPUT
// ===============================================================
input clk, rst_n, in_valid1, in_valid2;
input [1:0] in;
input [8:0] in_data;    
output reg	out_valid1, out_valid2;
output reg [2:0] out;
output reg [8:0] out_data;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
parameter IDLE   = 3'd0;
parameter READ   = 3'd1;
parameter RESET  = 3'd2;
parameter START  = 3'd3;
parameter GETPAS = 3'd4;
parameter OUTPUT = 3'd5;  

integer i,j;
// ===============================================================
// Wire & Reg Declaration
// ===============================================================
//input register
reg [1:0] map_in [0:224];
reg [8:0] map_in_cnt;
reg [1:0] map [0:18][0:18];
reg signed [8:0] in_data_reg [0:3]; 
//reg [33:0] map_in [0:16];
//wire [33:0] map_out [0:16];
wire signed [9:0] in_data_sign; 
assign in_data_sign = {in_data[8],in_data};

//state machine
reg [2:0] current_state,next_state;
wire fin_maze;

//map info 
//reg [7:0] map2 [0:16][0:16];//128?
reg [2:0] H_num;//# of hostage 
reg [4:0] X_cnt, Y_cnt;//coordinate
//reg [4:0] X_cnt1, Y_cnt1;//coordinate
reg [1:0] Turn;//recordding previous step direction  0:Right 1:Down 2:Left 3:UP
reg [2:0] H_cnt; //count # of hostage 
reg       Stall,Find_h;
reg [2:0] in_data_cnt; //count # of password

//out register
//reg [1:0] out_reg [0:288];
wire signed [8:0] sort_out_data_reg0 [0:3];
wire signed [8:0] sort_out_data_reg1 [0:1];
wire signed [8:0] sort_out_data_reg2 [0:3];
reg signed [8:0] ex3_out_data_reg [0:3];
/*wire signed [8:0] ex3_out_sort_data_reg0 [0:3];
wire signed [8:0] ex3_out_sort_data_reg1 [0:1];
wire signed [8:0] ex3_out_sort_data_reg2 [0:3];*/
reg signed [8:0] sub_out_data_reg [0:3];
//reg signed [8:0] cum_out_data_reg [0:3];
reg signed [8:0] out_data_reg [0:3];
reg signed [8:0] max,min;
wire signed [8:0] mean;
reg signed [4:0] Y [0:3];
reg signed [7:0] X [0:3];
wire signed [8:0] tmp [0:3];
// ===============================================================
// Assign
// ===============================================================
assign fin_maze = (X_cnt == 5'd17) && (Y_cnt == 5'd17) && (H_cnt == 3'd0);

// ===============================================================
// Handle Input
// ===============================================================
//in_data_reg
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for(i=0; i < 4 ; i=i+1)in_data_reg[i] <= 9'd0;
  end
  else if (in_valid2) begin
    for(i=0; i < 4 ; i=i+1) begin
      if(i == in_data_cnt) in_data_reg[i] <= /*in_data*/in_data_sign;
      else                 in_data_reg[i] <= in_data_reg[i];
    end
  end      
  else begin 
    for(i=0; i < 4 ; i=i+1) begin
      if(i<H_num) in_data_reg[i]<= in_data_reg[i];
      else in_data_reg[i] <= -9'd256;
    end
  end            
end

always @(posedge clk or negedge rst_n) begin
  if      (!rst_n)                  in_data_cnt <= 3'd0;
  else if (in_valid2)               in_data_cnt <= in_data_cnt + 1'd1;
  else if (current_state == RESET)  in_data_cnt <= 3'd0;
  else if (current_state == OUTPUT) in_data_cnt <= in_data_cnt + 1'd1;
  else                              in_data_cnt <= in_data_cnt;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) for(i=0; i < 225 ; i=i+1)        map_in[i] <= 2'd0;
  else if (in_valid1) begin
     if (~Y_cnt[0] || (Y_cnt[0] && ~X_cnt[0])) map_in[map_in_cnt] <= in;
     else for(i=0; i < 225 ; i=i+1)            map_in[i] <= map_in[i];
  end
  else    for(i=0; i < 225 ; i=i+1)            map_in[i] <= map_in[i];
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)                                 map_in_cnt <= 9'd0;
  else if (in_valid1) begin
    if (~Y_cnt[0] || (Y_cnt[0] && ~X_cnt[0])) map_in_cnt <= map_in_cnt + 1;
    else                                      map_in_cnt <= map_in_cnt;
  end
  else                                        map_in_cnt <= 9'd0;
end

always @(*) begin
  if (!rst_n) begin
    for(i=0; i < 19 ; i=i+1) begin
      for(j=0; j < 19; j=j+1) 
        map[i][j] = 2'd0;
    end  
  end  
  else begin
    for(i=1; i < 18 ; i=i+1) map[1][i] = map_in[i-1];
    map[2][1] = map_in[17];
    map[2][3] = map_in[18];
    map[2][5] = map_in[19];
    map[2][7] = map_in[20];
    map[2][9] = map_in[21];
    map[2][11] = map_in[22];
    map[2][13] = map_in[23];
    map[2][15] = map_in[24];
    map[2][17] = map_in[25];
    map[3][1]  = map_in[26];
    map[3][2]  = map_in[27];
    map[3][3]  = map_in[28];
    map[3][4]  = map_in[29];
    map[3][5]  = map_in[30];
    map[3][6]  = map_in[31];
    map[3][7]  = map_in[32];
    map[3][8]  = map_in[33];
    map[3][9]  = map_in[34];
    map[3][10] = map_in[35];
    map[3][11] = map_in[36];
    map[3][12] = map_in[37];
    map[3][13] = map_in[38];
    map[3][14] = map_in[39];
    map[3][15] = map_in[40];
    map[3][16] = map_in[41];
    map[3][17] = map_in[42];
    map[4][1]  = map_in[43];
    map[4][3]  = map_in[44];
    map[4][5]  = map_in[45];
    map[4][7]  = map_in[46];
    map[4][9]  = map_in[47];
    map[4][11] = map_in[48];
    map[4][13] = map_in[49];
    map[4][15] = map_in[50];
    map[4][17] = map_in[51];
    map[5][1]  = map_in[52];
    map[5][2]  = map_in[53];
    map[5][3]  = map_in[54];
    map[5][4]  = map_in[55];
    map[5][5]  = map_in[56];
    map[5][6]  = map_in[57];
    map[5][7]  = map_in[58];
    map[5][8]  = map_in[59];
    map[5][9]  = map_in[60];
    map[5][10] = map_in[61];
    map[5][11] = map_in[62];
    map[5][12] = map_in[63];
    map[5][13] = map_in[64];
    map[5][14] = map_in[65];
    map[5][15] = map_in[66];
    map[5][16] = map_in[67];
    map[5][17] = map_in[68];
    map[6][1]  = map_in[69];
    map[6][3]  = map_in[70];
    map[6][5]  = map_in[71];
    map[6][7]  = map_in[72];
    map[6][9]  = map_in[73];
    map[6][11] = map_in[74];
    map[6][13] = map_in[75];
    map[6][15] = map_in[76];
    map[6][17] = map_in[77];
    map[7][1]  = map_in[78];
    map[7][2]  = map_in[79];
    map[7][3]  = map_in[80];
    map[7][4]  = map_in[81];
    map[7][5]  = map_in[82];
    map[7][6]  = map_in[83];
    map[7][7]  = map_in[84];
    map[7][8]  = map_in[85];
    map[7][9]  = map_in[86];
    map[7][10] = map_in[87];
    map[7][11] = map_in[88];
    map[7][12] = map_in[89];
    map[7][13] = map_in[90];
    map[7][14] = map_in[91];
    map[7][15] = map_in[92];
    map[7][16] = map_in[93];
    map[7][17] = map_in[94];
    map[8][1]  = map_in[95];
    map[8][3]  = map_in[96];
    map[8][5]  = map_in[97];
    map[8][7]  = map_in[98];
    map[8][9]  = map_in[99];
    map[8][11] = map_in[100];
    map[8][13] = map_in[101];
    map[8][15] = map_in[102];
    map[8][17] = map_in[103];
    map[9][1]  = map_in[104];
    map[9][2]  = map_in[105];
    map[9][3]  = map_in[106];
    map[9][4]  = map_in[107];
    map[9][5]  = map_in[108];
    map[9][6]  = map_in[109];
    map[9][7]  = map_in[110];
    map[9][8]  = map_in[111];
    map[9][9]  = map_in[112];
    map[9][10] = map_in[113];
    map[9][11] = map_in[114];
    map[9][12] = map_in[115];
    map[9][13] = map_in[116];
    map[9][14] = map_in[117];
    map[9][15] = map_in[118];
    map[9][16] = map_in[119];
    map[9][17] = map_in[120];
    map[10][1] = map_in[121];
    map[10][3] = map_in[122];
    map[10][5] = map_in[123];
    map[10][7] = map_in[124];
    map[10][9] = map_in[125];
    map[10][11] = map_in[126];
    map[10][13] = map_in[127];
    map[10][15] = map_in[128];
    map[10][17] = map_in[129];
    map[11][1] = map_in[130];
    map[11][2] = map_in[131];
    map[11][3] = map_in[132];
    map[11][4] = map_in[133];
    map[11][5] = map_in[134];
    map[11][6] = map_in[135];
    map[11][7] = map_in[136];
    map[11][8] = map_in[137];
    map[11][9] = map_in[138];
    map[11][10] = map_in[139];
    map[11][11] = map_in[140];
    map[11][12] = map_in[141];
    map[11][13] = map_in[142];
    map[11][14] = map_in[143];
    map[11][15] = map_in[144];
    map[11][16] = map_in[145];
    map[11][17] = map_in[146];
    map[12][1] = map_in[147];
    map[12][3] = map_in[148];
    map[12][5] = map_in[149];
    map[12][7] = map_in[150];
    map[12][9] = map_in[151];
    map[12][11] = map_in[152];
    map[12][13] = map_in[153];
    map[12][15] = map_in[154];
    map[12][17] = map_in[155];
    map[13][1] = map_in[156];
    map[13][2] = map_in[157];
    map[13][3] = map_in[158];
    map[13][4] = map_in[159];
    map[13][5] = map_in[160];
    map[13][6] = map_in[161];
    map[13][7] = map_in[162];
    map[13][8] = map_in[163];
    map[13][9] = map_in[164];
    map[13][10] = map_in[165];
    map[13][11] = map_in[166];
    map[13][12] = map_in[167];
    map[13][13] = map_in[168];
    map[13][14] = map_in[169];
    map[13][15] = map_in[170];
    map[13][16] = map_in[171];
    map[13][17] = map_in[172];
    map[14][1] = map_in[173];
    map[14][3] = map_in[174];
    map[14][5] = map_in[175];
    map[14][7] = map_in[176];
    map[14][9] = map_in[177];
    map[14][11] = map_in[178];
    map[14][13] = map_in[179];
    map[14][15] = map_in[180];
    map[14][17] = map_in[181];
    map[15][1] = map_in[182];
    map[15][2] = map_in[183];
    map[15][3] = map_in[184];
    map[15][4] = map_in[185];
    map[15][5] = map_in[186];
    map[15][6] = map_in[187];
    map[15][7] = map_in[188];
    map[15][8] = map_in[189];
    map[15][9] = map_in[190];
    map[15][10] = map_in[191];
    map[15][11] = map_in[192];
    map[15][12] = map_in[193];
    map[15][13] = map_in[194];
    map[15][14] = map_in[195];
    map[15][15] = map_in[196];
    map[15][16] = map_in[197];
    map[15][17] = map_in[198];
    map[16][1] = map_in[199];
    map[16][3] = map_in[200];
    map[16][5] = map_in[201];
    map[16][7] = map_in[202];
    map[16][9] = map_in[203];
    map[16][11] = map_in[204];
    map[16][13] = map_in[205];
    map[16][15] = map_in[206];
    map[16][17] = map_in[207];
    for(i=1; i < 18 ; i=i+1) map[17][i] = map_in[i+207];
    for(i=2; i < 17; i=i+2) begin
      for(j=2; j < 17; j=j+2) map[i][j] = 2'd0;
    end
    for(i=0; i < 19 ; i=i+1) map[i][18] = 2'd0;
    for(i=0; i < 19 ; i=i+1) map[18][i] = 2'd0;
    for(i=0; i < 19 ; i=i+1) map[i][0] = 2'd0;
    for(i=0; i < 19 ; i=i+1) map[0][i] = 2'd0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) H_num <= 3'd0;
  else if (current_state == READ && (map_in[map_in_cnt-1]== 2'd3))   H_num <= H_num + 1'd1;
  else if (current_state == IDLE)                                    H_num <= 3'd0;
  else                                                               H_num <= H_num;                             
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)                     H_cnt <= 3'd0;
  else if (current_state == READ) H_cnt <= H_num;
  else if (Find_h)                H_cnt <= H_cnt - 1'd1;
  else                            H_cnt <= H_cnt;
end

// ===============================================================
// Counter
// ===============================================================
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    X_cnt <= 9'd0;
    Y_cnt <= 9'd0;
  end
  else if (/*current_state == READ && next_state == READ*/in_valid1) begin
    if(X_cnt == 9'd16) begin
      X_cnt <= 9'd0;
      Y_cnt <= Y_cnt + 1;
    end
    else begin
      X_cnt <= X_cnt + 1;
      Y_cnt <= Y_cnt;
    end
  end
  else if (current_state == START) begin  
    if(~Stall && ~Find_h && ~fin_maze) begin
      //0:Right 1:Down 2:Left 3:UP
      case (Turn)
        2'd0: begin //face Right
          if(map[Y_cnt+1][X_cnt] != 2'd0) begin //Down == turn right
            X_cnt <= X_cnt;
            Y_cnt <= Y_cnt + 1'b1;
          end
          else if (map[Y_cnt][X_cnt+1] != 2'd0) begin //Right == go straight
            X_cnt <= X_cnt + 1'b1;
            Y_cnt <= Y_cnt;
          end
          else if (map[Y_cnt-1][X_cnt] != 2'd0) begin //UP  == turn Left
            X_cnt <= X_cnt;
            Y_cnt <= Y_cnt - 1'b1;
          end
          else/* if (map[Y_cnt][X_cnt-1] != 2'd0) */begin //Left  == turn back
            X_cnt <= X_cnt - 1'b1;
            Y_cnt <= Y_cnt;
          end
        end
        2'd1: begin //face Down
          if (map[Y_cnt][X_cnt-1] != 2'd0) begin //Left  == turn Right
            X_cnt <= X_cnt - 1'b1;
            Y_cnt <= Y_cnt;
          end
          else if(map[Y_cnt+1][X_cnt] != 2'd0) begin //Down == go straight
            X_cnt <= X_cnt;
            Y_cnt <= Y_cnt + 1'b1; 
          end
          else if (map[Y_cnt][X_cnt+1] != 2'd0) begin //Right ==  turn Left
            X_cnt <= X_cnt + 1'b1;
            Y_cnt <= Y_cnt;
          end
          else/* if (map[Y_cnt-1][X_cnt] != 2'd0) */begin //UP == turn back
            X_cnt <= X_cnt;
            Y_cnt <= Y_cnt - 1'b1;
          end
        end
        2'd2: begin //face Left
          if (map[Y_cnt-1][X_cnt] != 2'd0) begin //UP == turn Right
            X_cnt <= X_cnt;
            Y_cnt <= Y_cnt - 1'b1;
          end
          else if (map[Y_cnt][X_cnt-1] != 2'd0) begin //Left  ==  go straight
            X_cnt <= X_cnt - 1'b1;
            Y_cnt <= Y_cnt; 
          end
          else if(map[Y_cnt+1][X_cnt] != 2'd0) begin //Down == turn Left 
            X_cnt <= X_cnt;
            Y_cnt <= Y_cnt + 1'b1;
          end
          else/* if (map[Y_cnt][X_cnt+1] != 2'd0) */begin //Right == turn back
            X_cnt <= X_cnt + 1'b1;
            Y_cnt <= Y_cnt;
          end
        end
        2'd3: begin
          if (map[Y_cnt][X_cnt+1] != 2'd0) begin //Right == turn Right 
            X_cnt <= X_cnt + 1'b1;
            Y_cnt <= Y_cnt;
          end
          else if (map[Y_cnt-1][X_cnt] != 2'd0) begin //UP == go straight
            X_cnt <= X_cnt;
            Y_cnt <= Y_cnt - 1'b1;
          end
          else if (map[Y_cnt][X_cnt-1] != 2'd0) begin //Left  == turn Left 
            X_cnt <= X_cnt - 1'b1;
            Y_cnt <= Y_cnt;
          end
          else/* if(map[Y_cnt+1][X_cnt] != 2'd0) */begin //Down ==  turn back
            X_cnt <= X_cnt;
            Y_cnt <= Y_cnt + 1'b1;
          end
        end
      endcase
    end
    else begin //restore to not stall condition
      X_cnt  <= X_cnt;
      Y_cnt  <= Y_cnt;
    end
  end
  else if (current_state == GETPAS) begin
    X_cnt  <= X_cnt;
    Y_cnt  <= Y_cnt;
  end
  else if (current_state == RESET) begin
    X_cnt  <= 9'd1;
    Y_cnt  <= 9'd1;
  end
  else begin
    X_cnt <= 9'd0;
    Y_cnt <= 9'd0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) Turn  <= 2'd0;
  else if (current_state == START) begin  
    if(~Stall && ~Find_h && ~fin_maze) begin//0:Right 1:Down 2:Left 3:UP
      case (Turn)
        2'd0: begin //face Right
          if      (map[Y_cnt+1][X_cnt] != 2'd0) Turn  <= 2'b1; //face turn Down //Down == turn right
          else if (map[Y_cnt][X_cnt+1] != 2'd0) Turn  <= 2'd0; //face turn Right //Right == go straight
          else if (map[Y_cnt-1][X_cnt] != 2'd0) Turn  <= 2'd3; //face turn UP //UP  == turn Left
          else                                  Turn  <= 2'd2; //face turn Left  //Left  == turn back
        end
        2'd1: begin //face Down
          if      (map[Y_cnt][X_cnt-1] != 2'd0) Turn  <= 2'd2; //face turn Left  //Left  == turn Right
          else if (map[Y_cnt+1][X_cnt] != 2'd0) Turn  <= 2'b1; //face turn Down  //Down == go straight
          else if (map[Y_cnt][X_cnt+1] != 2'd0) Turn  <= 2'd0; //face turn Right  //Right ==  turn Left
          else                                  Turn  <= 2'd3; //face turn UP  //UP == turn back
        end
        2'd2: begin //face Left
          if      (map[Y_cnt-1][X_cnt] != 2'd0) Turn  <= 2'd3; //face turn UP  //UP == turn Right
          else if (map[Y_cnt][X_cnt-1] != 2'd0) Turn  <= 2'd2; //face turn Left  //Left  ==  go straight
          else if (map[Y_cnt+1][X_cnt] != 2'd0) Turn  <= 2'b1; //face turn Down  //Down == turn Left 
          else                                  Turn  <= 2'd0; //face turn Right  //Right == turn back
        end
        2'd3: begin
          if      (map[Y_cnt][X_cnt+1] != 2'd0) Turn  <= 2'd0; //face turn Right  //Right == turn Right 
          else if (map[Y_cnt-1][X_cnt] != 2'd0) Turn  <= 2'd3;//face turn UP  //UP == go straight
          else if (map[Y_cnt][X_cnt-1] != 2'd0) Turn  <= 2'd2; //face turn Left  //Left  == turn Left 
          else                                  Turn  <= 2'b1;//face turn Down  //Down ==  turn back
        end
      endcase
    end
    else  Turn  <= Turn;
  end
  else if (current_state == GETPAS) Turn <= Turn;
  else  Turn  <= 2'd0;
end
// ===============================================================
// Wall follower algorithm
// ===============================================================
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    Find_h <= 1'd0;
    Stall  <= 1'd0;
  end  
  else if (current_state == START) begin  
    if(~Stall && ~Find_h) begin
      //0:Right 1:Down 2:Left 3:UP
      case (Turn)
        2'd0: begin //face Right
          if (map[Y_cnt+1][X_cnt] != 2'd0) begin //Down == turn right
            if(map[Y_cnt+1][X_cnt] == 2'd2 ) Stall <= 1'b1;
            else                             Stall <= 1'b0;
            if(map[Y_cnt+1][X_cnt] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
          else if (map[Y_cnt][X_cnt+1] != 2'd0) begin //Right == go straight
            if(map[Y_cnt][X_cnt+1] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt][X_cnt+1] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
          else if (map[Y_cnt-1][X_cnt] != 2'd0) begin //UP  == turn Left
            if(map[Y_cnt-1][X_cnt] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt-1][X_cnt] == 2'd3  && (H_cnt!=0)) Find_h <= 1'b1;
            else                                           Find_h <= 1'b0;
          end
          else/* if (map[Y_cnt][X_cnt-1] != 2'd0) */begin //Left  == turn back
            if(map[Y_cnt][X_cnt-1] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt][X_cnt-1] == 2'd3  && (H_cnt!=0)) Find_h <= 1'b1;
            else                                           Find_h <= 1'b0;
          end
        end
        2'd1: begin //face Down
          if (map[Y_cnt][X_cnt-1] != 2'd0) begin //Left  == turn Right
            if(map[Y_cnt][X_cnt-1] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt][X_cnt-1] == 2'd3  && (H_cnt!=0)) Find_h <= 1'b1;
            else                                           Find_h <= 1'b0;
          end
          else if(map[Y_cnt+1][X_cnt] != 2'd0) begin //Down == go straight
            if(map[Y_cnt+1][X_cnt] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt+1][X_cnt] == 2'd3  && (H_cnt!=0)) Find_h <= 1'b1;
            else                                           Find_h <= 1'b0;
          end
          else if (map[Y_cnt][X_cnt+1] != 2'd0) begin //Right ==  turn Lef
            if(map[Y_cnt][X_cnt+1] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt][X_cnt+1] == 2'd3  && (H_cnt!=0)) Find_h <= 1'b1;
            else                            Find_h <= 1'b0;
          end
          else/* if (map[Y_cnt-1][X_cnt] != 2'd0) */begin //UP == turn back
            if(map[Y_cnt-1][X_cnt] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt-1][X_cnt] == 2'd3  && (H_cnt!=0)) Find_h <= 1'b1;
            else                                           Find_h <= 1'b0;
          end
        end
        2'd2: begin //face Left
          if (map[Y_cnt-1][X_cnt] != 2'd0) begin //UP == turn Right
            if(map[Y_cnt-1][X_cnt] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt-1][X_cnt] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
          else if (map[Y_cnt][X_cnt-1] != 2'd0) begin //Left  ==  go straight 
            if(map[Y_cnt][X_cnt-1] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt][X_cnt-1] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
          else if(map[Y_cnt+1][X_cnt] != 2'd0) begin //Down == turn Left 
            if(map[Y_cnt+1][X_cnt] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt+1][X_cnt] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
          else/* if (map[Y_cnt][X_cnt+1] != 2'd0) */begin //Right == turn back
            if(map[Y_cnt][X_cnt+1] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt][X_cnt+1] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
        end
        2'd3: begin
          if (map[Y_cnt][X_cnt+1] != 2'd0) begin //Right == turn Right 
            if(map[Y_cnt][X_cnt+1] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt][X_cnt+1] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
          else if (map[Y_cnt-1][X_cnt] != 2'd0) begin //UP == go straight
            if(map[Y_cnt-1][X_cnt] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt-1][X_cnt] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
          else if (map[Y_cnt][X_cnt-1] != 2'd0) begin //Left  == turn Left 
            if(map[Y_cnt][X_cnt-1] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt][X_cnt-1] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
          else/* if(map[Y_cnt+1][X_cnt] != 2'd0) */begin //Down ==  turn back
            if(map[Y_cnt+1][X_cnt] == 2'd2) Stall <= 1'b1;
            else                            Stall <= 1'b0;
            if(map[Y_cnt+1][X_cnt] == 2'd3 && (H_cnt!=0)) Find_h <= 1'b1;
            else                                          Find_h <= 1'b0;
          end
        end
      endcase
    end
    else begin //stall finish
      Stall <= 1'b0;
      Find_h <= 1'b0;
    end
  end 
  else begin
    Find_h <= 1'b0;
    Stall  <= 1'b0;
  end
end
// ===============================================================
// Handle out_data
// ===============================================================
//sort
comp2 C0(.a(in_data_reg[0]), .b(in_data_reg[1]), .smaller(sort_out_data_reg0[1]), .big(sort_out_data_reg0[0]));
comp2 C1(.a(in_data_reg[2]), .b(in_data_reg[3]), .smaller(sort_out_data_reg0[3]), .big(sort_out_data_reg0[2]));
comp2 C2(.a(sort_out_data_reg0[0]), .b(sort_out_data_reg0[2]), .smaller(sort_out_data_reg1[0]), .big(sort_out_data_reg2[0]));
comp2 C3(.a(sort_out_data_reg0[1]), .b(sort_out_data_reg0[3]), .smaller(sort_out_data_reg2[3]), .big(sort_out_data_reg1[1]));
comp2 C4(.a(sort_out_data_reg1[0]), .b(sort_out_data_reg1[1]), .smaller(sort_out_data_reg2[2]), .big(sort_out_data_reg2[1]));
//ex-3
/*
comp2 C5(.a(ex3_out_data_reg[0]), .b(ex3_out_data_reg[1]), .smaller(ex3_out_sort_data_reg0[1]), .big(ex3_out_sort_data_reg0[0]));
comp2 C6(.a(ex3_out_data_reg[2]), .b(ex3_out_data_reg[3]), .smaller(ex3_out_sort_data_reg0[3]), .big(ex3_out_sort_data_reg0[2]));
comp2 C7(.a(ex3_out_sort_data_reg0[0]), .b(ex3_out_sort_data_reg0[2]), .smaller(ex3_out_sort_data_reg1[0]), .big(ex3_out_sort_data_reg2[0]));
comp2 C8(.a(ex3_out_sort_data_reg0[1]), .b(ex3_out_sort_data_reg0[3]), .smaller(ex3_out_sort_data_reg2[3]), .big(ex3_out_sort_data_reg1[1]));
comp2 C9(.a(ex3_out_sort_data_reg1[0]), .b(ex3_out_sort_data_reg1[1]), .smaller(ex3_out_sort_data_reg2[2]), .big(ex3_out_sort_data_reg2[1]));
*/
always @(*) begin
  if(!rst_n) for(i=0; i < 4; i=i+1) Y[i] = 5'd0;
  else begin
    for(i=0; i < 4; i=i+1) begin
       case (sort_out_data_reg2[i][3:0])  
        4'b0011: Y[i]=5'b00000;  
        4'b0100: Y[i]=5'b00001; 
        4'b0101: Y[i]=5'b00010;   
        4'b0110: Y[i]=5'b00011; 
        4'b0111: Y[i]=5'b00100;  
        4'b1000: Y[i]=5'b00101; 
        4'b1001: Y[i]=5'b00110;
        4'b1010: Y[i]=5'b00111;
        4'b1011: Y[i]=5'b01000;  
        4'b1100: Y[i]=5'b01001;   
        default: Y[i]=5'b00000;      
      endcase 
    end
  end
end

always @(*) begin
  if(!rst_n) for(i=0; i < 4; i=i+1) X[i] = 8'd0;
  else begin
    for(i=0; i < 4; i=i+1) begin
      case (sort_out_data_reg2[i][7:4])  
        4'b0011: X[i]=8'd0;  
        4'b0100: X[i]=8'd10; 
        4'b0101: X[i]=8'd20;   
        4'b0110: X[i]=8'd30;
        4'b0111: X[i]=8'd40;  
        4'b1000: X[i]=8'd50; 
        4'b1001: X[i]=8'd60;
        4'b1010: X[i]=8'd70;
        4'b1011: X[i]=8'd80;  
        4'b1100: X[i]=8'd90;  
        default: X[i]='d0;      
      endcase
    end
  end
end

always @(*) begin
  if(!rst_n) begin
    for(i=0; i < 4; i=i+1) begin
      ex3_out_data_reg[i] = 9'd0;
    end
  end
  else if(~H_num[0]) begin
    for(i=0; i < 4; i=i+1) begin
      if(sort_out_data_reg2[i][8]) ex3_out_data_reg[i] = -1*(X[i]+Y[i]);
      else                         ex3_out_data_reg[i] = (X[i]+Y[i]);   
    end
  end
  else begin
    for(i=0; i < 4; i=i+1) begin
      ex3_out_data_reg[i] = sort_out_data_reg2[i];
    end
  end
end

//sub mean
/*
always @(*) begin
  if(!rst_n) mean = 9'd0;
  else begin
    case (H_num)
      3'd2:    mean = (ex3_out_sort_data_reg2[0] + ex3_out_sort_data_reg2[1])/2;
      3'd3:    mean = (ex3_out_sort_data_reg2[0] + ex3_out_sort_data_reg2[2])/2;
      3'd4:    mean = (ex3_out_sort_data_reg2[0] + ex3_out_sort_data_reg2[3])/2;
      default: mean = 9'd0;
    endcase
  end
end*/

always @(*) begin
  if(!rst_n) max = 9'd0;
  else begin
    case (H_num)
      3'd2: max = ex3_out_data_reg[0];
      3'd3: begin
        if     (ex3_out_data_reg[0] >= ex3_out_data_reg[2] && ex3_out_data_reg[0] >= ex3_out_data_reg[1]) max = ex3_out_data_reg[0];
        else if(ex3_out_data_reg[1] >= ex3_out_data_reg[0] && ex3_out_data_reg[1] >= ex3_out_data_reg[2]) max = ex3_out_data_reg[1];
        else                                                                                            max = ex3_out_data_reg[2];
      end   
      3'd4: begin
        if     (ex3_out_data_reg[0] >= ex3_out_data_reg[2] && ex3_out_data_reg[0] >= ex3_out_data_reg[1] && ex3_out_data_reg[0] >= ex3_out_data_reg[3]) max = ex3_out_data_reg[0];
        else if(ex3_out_data_reg[1] >= ex3_out_data_reg[0] && ex3_out_data_reg[1] >= ex3_out_data_reg[2] && ex3_out_data_reg[1] >= ex3_out_data_reg[3]) max = ex3_out_data_reg[1];
        else if(ex3_out_data_reg[2] >= ex3_out_data_reg[0] && ex3_out_data_reg[2] >= ex3_out_data_reg[1] && ex3_out_data_reg[2] >= ex3_out_data_reg[3]) max = ex3_out_data_reg[2];
        else                                                                                                                                         max = ex3_out_data_reg[3];
      end   
      default: max = 9'd0;
    endcase
  end
end
always @(*) begin
  if(!rst_n) min = 9'd0;
  else begin
    case (H_num)
      3'd2: min = ex3_out_data_reg[1];
      3'd3: begin
        if     (ex3_out_data_reg[0] <= ex3_out_data_reg[2] && ex3_out_data_reg[0] <= ex3_out_data_reg[1]) min = ex3_out_data_reg[0];
        else if(ex3_out_data_reg[1] <= ex3_out_data_reg[0] && ex3_out_data_reg[1] <= ex3_out_data_reg[2]) min = ex3_out_data_reg[1];
        else                                                                                              min = ex3_out_data_reg[2];
      end   
      3'd4: begin
        if     (ex3_out_data_reg[0] <= ex3_out_data_reg[2] && ex3_out_data_reg[0] <= ex3_out_data_reg[1] && ex3_out_data_reg[0] <= ex3_out_data_reg[3]) min = ex3_out_data_reg[0];
        else if(ex3_out_data_reg[1] <= ex3_out_data_reg[0] && ex3_out_data_reg[1] <= ex3_out_data_reg[2] && ex3_out_data_reg[1] <= ex3_out_data_reg[3]) min = ex3_out_data_reg[1];
        else if(ex3_out_data_reg[2] <= ex3_out_data_reg[0] && ex3_out_data_reg[2] <= ex3_out_data_reg[1] && ex3_out_data_reg[2] <= ex3_out_data_reg[3]) min = ex3_out_data_reg[2];
        else                                                                                                                                            min = ex3_out_data_reg[3];
      end   
      default: min = 9'd0;
    endcase
  end
end
assign mean = (max + min)/2;

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) for(i=0; i < 4; i=i+1) sub_out_data_reg[i] <= 9'd0;
  else       for(i=0; i < 4; i=i+1) sub_out_data_reg[i] <= ex3_out_data_reg[i] - mean;
end

//moving average
always @(*) begin
  if(!rst_n) for(i=0; i < 4; i=i+1) out_data_reg[i] = 9'd0;
  else begin
    out_data_reg[0] = sub_out_data_reg[0];
    out_data_reg[1] = (out_data_reg[0]*2+sub_out_data_reg[1])/3;
    out_data_reg[2] = (out_data_reg[1]*2+sub_out_data_reg[2])/3;
    out_data_reg[3] = (out_data_reg[2]*2+sub_out_data_reg[3])/3;
  end
end
// ===============================================================
// Finite State Machine
// ===============================================================
// Current State
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else        current_state <= next_state;
end

// Next State
always @(*) begin
  if (!rst_n) next_state = IDLE;
  else begin
    case (current_state)
      IDLE: begin
        if (in_valid1) next_state = READ;
        else           next_state = current_state;
      end
      READ: begin
        if (!in_valid1/*X_cnt==5'd17 && Y_cnt==5'd17*/) next_state = RESET;
        else            next_state = current_state;
      end
      RESET: begin
        if( fin_maze) next_state = OUTPUT;
        else          next_state = START;
      end
      START: begin
        if (Find_h)        next_state = GETPAS; //find hostage
        else if (fin_maze) next_state = RESET; //find exit
        else               next_state = current_state;
      end
      GETPAS: begin//find hostage so get password
        if (in_valid2) next_state = START;
        else           next_state = current_state;
      end
      OUTPUT: begin
        if (H_num == 0)                  next_state = IDLE;
        else if (in_data_cnt == H_num-1) next_state = IDLE;
        else                             next_state = current_state;
      end
      default: next_state = current_state;
    endcase
  end
end
// ===============================================================
// Output Logic
// ===============================================================
/*
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) out_data   <= 9'd0;                   
  else begin
    if (current_state == OUTPUT) begin
      case(H_num)
        3'd0:    out_data <= 9'd0;
        3'd1:    out_data <= in_data_reg[0];
        3'd2:    out_data <= sub_out_data_reg[in_data_cnt];
        3'd3:    out_data <= out_data_reg[in_data_cnt];
        3'd4:    out_data <= out_data_reg[in_data_cnt];
        default: out_data <= 9'd0;
      endcase
    end
    else out_data   <= 9'd0;                
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)                    out_valid1 <= 1'b0;
  else begin
    if (current_state == OUTPUT) out_valid1 <= 1'b1;
    else                         out_valid1 <= 1'b0;                    
  end
end
*/
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    out_data   <= 9'd0; 
    out_valid1 <= 1'b0;
  end                   
  else begin
    if (current_state == OUTPUT) begin
      case(H_num)
        3'd0:   begin
          out_data <= 9'd0;
          out_valid1 <= 1'b1;
        end 
        3'd1: begin
          out_data <= in_data_reg[0];
          out_valid1 <= 1'b1;
        end    
        3'd2:begin
          out_data <= sub_out_data_reg[in_data_cnt];
          out_valid1 <= 1'b1;
        end        
        3'd3:begin
          out_data <= out_data_reg[in_data_cnt];
          out_valid1 <= 1'b1;
        end         
        3'd4: begin
          out_data <= out_data_reg[in_data_cnt];
          out_valid1 <= 1'b1;
        end        
        default: begin
          out_data <= 9'd0;
          out_valid1 <= 1'b0;
        end     
      endcase
    end
    else begin
       out_data <= 9'd0;
       out_valid1 <= 1'b0;
    end                 
  end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) out <= 2'd0;        
  else if (current_state == START) begin 
    if(~Stall && ~Find_h && ~fin_maze) begin
      case (Turn) //0:Right 1:Down 2:Left 3:UP
        2'd0: begin //face Right
          if      (map[Y_cnt+1][X_cnt] != 2'd0) out <= 3'd1; //Down == turn right      
          else if (map[Y_cnt][X_cnt+1] != 2'd0) out <= 3'd0; //Right == go straight
          else if (map[Y_cnt-1][X_cnt] != 2'd0) out <= 3'd3; //UP  == turn Left
          else                                  out <= 3'd2; //Left  == turn back
        end
        2'd1: begin //face Down
          if      (map[Y_cnt][X_cnt-1] != 2'd0) out <= 3'd2; //Left  == turn Right
          else if (map[Y_cnt+1][X_cnt] != 2'd0) out <= 3'd1; //Down == go straight
          else if (map[Y_cnt][X_cnt+1] != 2'd0) out <= 3'd0; //Right ==  turn Lef
          else                                  out <= 3'd3; //UP == turn back
        end
        2'd2: begin //face Left
          if      (map[Y_cnt-1][X_cnt] != 2'd0) out <= 3'd3; //UP == turn Right   
          else if (map[Y_cnt][X_cnt-1] != 2'd0) out <= 3'd2; //Left  ==  go straight 
          else if (map[Y_cnt+1][X_cnt] != 2'd0) out <= 3'd1; //Down == turn Left 
          else                                                         out <= 3'd0; //Right == turn back
        end
        2'd3: begin //UP Left
          if      (map[Y_cnt][X_cnt+1] != 2'd0) out <= 3'd0; //Right == turn Right 
          else if (map[Y_cnt-1][X_cnt] != 2'd0) out <= 3'd3; //UP == go straight
          else if (map[Y_cnt][X_cnt-1] != 2'd0) out <= 3'd2; //Left  == turn Left 
          else                                                         out <= 3'd1; //Down ==  turn back
        end
      endcase
    end
    else if (Find_h || fin_maze) out <= 3'd0;
    else                         out <= 3'd4;//stall==1  reset stall
  end
  else                           out <= 3'd0;                        
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) out_valid2 <= 1'b0;
  else if (current_state == START) begin  
    if(~Stall && ~Find_h && ~fin_maze) out_valid2 <= 1'b1; 
    else if (Find_h || fin_maze)       out_valid2 <= 1'b0;
    else out_valid2 <= 1'b1;//stall==1  reset stall
  end
  else   out_valid2 <= 1'b0;        
end

endmodule


module comp2(
 	a, 
	b,
	smaller,
	big
);
input  signed [8:0] a,b;
output signed [8:0] smaller,big;
assign {big,smaller} = (a>b) ? {a,b} : {b,a};

endmodule
