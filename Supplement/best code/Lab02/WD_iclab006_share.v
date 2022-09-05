//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : WD.v
//   Module Name : WD
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module WD(
    // Input signals
    clk,
    rst_n,
    in_valid,
    keyboard,
    answer,
    weight,
    match_target,
    // Output signals
    out_valid,
    result,
    out_value
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [4:0] keyboard, answer;
input [3:0] weight;
input [2:0] match_target;
output reg out_valid;
output reg [4:0]  result;
output reg [10:0] out_value;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
parameter IDLE    = 5'd0;
parameter INPUT   = 5'd1;

parameter REST_0    = 5'd2; 
parameter REST_1    = 5'd3; 
parameter REST_2    = 5'd4; 
parameter REST_3    = 5'd5; 

parameter two_2A0B  = 5'd6;
parameter two_1A1B  = 5'd7;
parameter two_0A2B  = 5'd8;

parameter three_3A0B =5'd9;
parameter three_2A1B =5'd10;
parameter three_1A2B =5'd11;
parameter three_0A3B =5'd12;

parameter four_4A0B  = 5'd13;
parameter four_3A1B  = 5'd14;
parameter four_2A2B  = 5'd15;
parameter four_1A3B  = 5'd16;
parameter four_0A4B  = 5'd17;

parameter five_5A0B= 5'd18;
parameter five_3A2B= 5'd19;
parameter five_2A3B= 5'd20;
parameter five_1A4B= 5'd21;
parameter five_0A5B= 5'd22;

parameter OUT     = 5'd31;
// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [4:0] in_keyboard [0:7];    
reg [4:0] in_ans [0:4];
reg [3:0] in_weight [0:4];
reg [2:0] in_tar [0:1];

reg [7:0] counter;
reg [2:0] out_counter;
reg [1:0] same_index;
wire [3:0] keyboard_index;

reg [4:0] not_ans [0:2];
reg [4:0] current_state, next_state;
reg out_valid_comb;
wire [10:0] out_value_comb;
integer i;
wire [1:0] num_of_not_AB;
reg same1,same2,same3,same4,same5;
wire same;
reg flag;
reg flag2;

reg [1:0] index1;
reg [2:0] index2, index3,index_1A4B;
wire [4:0] index_b;
wire [4:0] index_3A;
reg [2:0] a,b,c;
reg [2:0] a_3A, b_3A, c_3A;
reg [2:0] a_4B, b_4B, c_4B, d_4B;
wire [2:0] n1,n2,n3,n_big,n_medium,n_small;
wire [2:0] n_big_3A, n_small_3A;
reg [4:0] temp1_result[0:4]; 
reg [4:0] temp2_result[0:4];
wire [10:0] temp1_value,temp2_value;
wire [10:0] temp1_corner,temp2_corner; 
reg index_corner;
wire [2:0] index_0A3B_big, index_0A3B_small;
// ===============================================================
// Finite State Machine
// ===============================================================

// Current State
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end 
    else begin
        current_state <= next_state;
    end        
end

// Next State
always @(*) begin
    if (!rst_n) next_state = IDLE;  
    else begin
        case (current_state)
            IDLE: begin
                if(in_valid) next_state = INPUT;
                else         next_state = IDLE;
            end
            INPUT: begin
                if(in_valid) next_state = INPUT;
                else if (num_of_not_AB == 0) next_state = REST_0;
                else if (num_of_not_AB == 1) next_state = REST_1;
                else if (num_of_not_AB == 2) next_state = REST_2;
                else if (num_of_not_AB == 3) next_state = REST_3;
                else         next_state = INPUT;
            end
            REST_3: begin   
                if(flag == 1 && in_tar[0]==2) next_state = two_2A0B;
                else if(flag == 1 && in_tar[0]==1) next_state = two_1A1B;
                else if(flag == 1 && in_tar[0]==0) next_state = two_0A2B;
                else next_state = REST_3;
            end
            REST_1: begin  
                if(flag == 1 && in_tar[0]==4) next_state = four_4A0B;
                else if(flag == 1 && in_tar[0]==3) next_state = four_3A1B;
                else if(flag == 1 && in_tar[0]==2) next_state = four_2A2B;
                else if(flag == 1 && in_tar[0]==1) next_state = four_1A3B;
                else if(flag == 1 && in_tar[0]==0) next_state = five_1A4B;//original is four_0A4B
                else next_state = REST_1;
            end
            REST_2: begin   
                if(flag == 1 && in_tar[0]==3) next_state = three_3A0B;
                else if(flag == 1 && in_tar[0]==2) next_state = three_2A1B;
                else if(flag == 1 && in_tar[0]==1) next_state = three_1A2B;
                else if(flag == 1 && in_tar[0]==0) next_state = four_1A3B; //original is  three_0A3B
                else next_state = REST_2;
            end
            REST_0: begin 
                if(in_tar[0]==5) next_state = five_5A0B;
                else if(in_tar[0]==3) next_state = five_3A2B;
                else if(in_tar[0]==2) next_state = five_2A3B;
                else if(in_tar[0]==1) next_state = five_1A4B;
                else if(in_tar[0]==0) next_state = five_0A5B;
                else next_state = REST_0;
            end
            two_2A0B: begin 
                if(index2==5) next_state = OUT;
                else next_state = two_2A0B;
            end
            two_1A1B: begin 
                if(counter == 60) next_state = OUT;
                else next_state = two_1A1B;
            end
            two_0A2B: begin 
                if(counter == 130) next_state = OUT;
                else next_state = two_0A2B;
            end
            three_3A0B: begin 
                if(index3==5) next_state = OUT;
                else next_state = three_3A0B;
            end
            three_2A1B: begin 
                if(counter == 60) next_state = OUT;
                else next_state = three_2A1B;
            end
            three_1A2B: begin 
                if(counter == 210) next_state = OUT;
                else next_state = three_1A2B;
            end
            three_0A3B: begin 
                if(counter == 120) next_state = OUT;
                else next_state = three_0A3B;
            end
            four_4A0B: begin 
                if(counter == 5) next_state = OUT;
                else next_state = four_4A0B;
            end
            four_3A1B: begin 
                if(counter == 20) next_state = OUT;
                else next_state = four_3A1B;
            end
            four_2A2B: begin 
                if(counter == 90) next_state = OUT;
                else next_state = four_2A2B;
            end
            four_1A3B: begin 
                if(counter == 220 && in_tar[0]==1) next_state = OUT;
                else if(counter == 220 && in_tar[0]==0) next_state = three_0A3B;
                else next_state = four_1A3B;
            end
            four_0A4B: begin //from five_1A4B
                if(counter == 220) next_state = OUT;
                else next_state = four_0A4B;
            end
            five_5A0B: begin 
                next_state = OUT;
            end
            five_3A2B: begin 
                if(index3==5) next_state = OUT;
                else next_state = five_3A2B;
            end
            five_2A3B: begin 
                if(counter == 20) next_state = OUT;
                else next_state = five_2A3B;
            end
            five_1A4B: begin 
                if(counter == 45 && in_tar[0]==1) next_state = OUT;
                else if(counter == 45 && in_tar[0]==0) next_state = four_0A4B;
                else next_state = five_1A4B;
            end
            five_0A5B: begin 
                if(counter == 44) next_state = OUT;
                else next_state = five_0A5B;
            end
            OUT: begin
                if(out_counter == 4) next_state = IDLE;
                else next_state = OUT;
            end
            default: next_state = current_state;
        endcase
    end
end


//==========================================================================================================
//==========================================================================================================
//==========================================================================================================
  

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result    <= 0;
        out_value <= 0;
        out_valid <= 0;
        for(i=0;i<8;i=i+1) begin
            in_keyboard[i] <= 0;
        end
        for(i=0;i<5;i=i+1) begin
            temp2_result[i] <= 0; 
            in_ans[i] <= 0;
            in_weight[i] <= 0;
            temp1_result[i] <= 0;
            temp2_result[i] <= 0;
        end
        
        for(i=0;i<2;i=i+1) begin
            in_tar[i] <= 0;
        end
        for(i=0;i<3;i=i+1) begin
            not_ans[i] <= 0;
        end
        out_counter<=0;
        counter <= 0;
        same_index <= 0;
        index_1A4B<=0;
        same1<=0; same2<=0; same3<=0; same4<=0; same5<=0;
        flag<=0;
        flag2<=0;
        index1<=0; index2<=0; index3<=0;
    end 
    else begin
    case(current_state) 
        IDLE: begin
            out_valid <= 0;
            result    <= 0;
            flag <=0;
            flag2<=0;
            index_1A4B<=0;
            same1<=1; same2<=1; same3<=1; same4<=1; same5<=1;
            out_counter<=0;
            if(in_valid) begin 
                counter <= counter+1;  
                in_keyboard[7] <= keyboard;
                in_ans[counter] <= answer;
                in_weight[counter] <= weight;
                in_tar[counter] <= match_target;
            end
            else begin
                counter <= 0;
                
                out_value<=0;
                for (i = 0;i<5 ;i=i+1 ) begin
                    temp1_result[i]<=0;  
                    temp2_result[i]<=0;
                end
            end
        end
        INPUT: begin
            index1<=0;
            index2<=1;
            if(in_valid) begin
                same_index <= 0;
                counter <= counter+1;
                in_ans[counter] <= answer; 
                in_weight[counter] <= weight;
                in_tar[counter] <= match_target;

                in_keyboard[7] <= keyboard; 
                in_keyboard[6] <= in_keyboard[7];
                in_keyboard[5] <= in_keyboard[6];
                in_keyboard[4] <= in_keyboard[5];
                in_keyboard[3] <= in_keyboard[4];
                in_keyboard[2] <= in_keyboard[3];
                in_keyboard[1] <= in_keyboard[2];
                in_keyboard[0] <= in_keyboard[1];
            end
            else counter <= 7;
        end
        REST_0: begin
            counter <= 0;
        end
        REST_1: begin
            if(counter==0) counter<=0;
            else counter<=counter-1;
            same1 <= (in_ans[0] == in_keyboard[counter])? 1:0;
            same2 <= (in_ans[1] == in_keyboard[counter])? 1:0;
            same3 <= (in_ans[2] == in_keyboard[counter])? 1:0;
            same4 <= (in_ans[3] == in_keyboard[counter])? 1:0;
            same5 <= (in_ans[4] == in_keyboard[counter])? 1:0;
            if(same == 0) begin
                not_ans[same_index]<= in_keyboard[keyboard_index[2:0]];
                same_index <= same_index+1;
                flag <= 1;
                counter <= 0;
            end
            else flag <= 0;
            index1<=0;
            index2<=1;
            index3<=2;
        end
        REST_2: begin
            counter <= counter -1;
            same1 <= (in_ans[0] == in_keyboard[counter])? 1:0;
            same2 <= (in_ans[1] == in_keyboard[counter])? 1:0;
            same3 <= (in_ans[2] == in_keyboard[counter])? 1:0;
            same4 <= (in_ans[3] == in_keyboard[counter])? 1:0;
            same5 <= (in_ans[4] == in_keyboard[counter])? 1:0;
            if(same == 0) begin
                not_ans[same_index]<= in_keyboard[keyboard_index[2:0]];
                same_index <= same_index+1;
            end
            index1<=0;
            index2<=1;
            index3<=2;
            if(counter == 0) flag <= 1;
            else flag <= 0;
        end
        REST_3: begin
            counter <= counter -1;
            same1 <= (in_ans[0] == in_keyboard[counter])? 1:0;
            same2 <= (in_ans[1] == in_keyboard[counter])? 1:0;
            same3 <= (in_ans[2] == in_keyboard[counter])? 1:0;
            same4 <= (in_ans[3] == in_keyboard[counter])? 1:0;
            same5 <= (in_ans[4] == in_keyboard[counter])? 1:0;
            if(same == 0) begin
                not_ans[same_index]<= in_keyboard[keyboard_index[2:0]];
                same_index <= same_index+1;
            end
            index1<=0;
            index2<=1;
            if(counter == 0) flag <= 1;
            else flag <= 0;
        end
        two_2A0B: begin 
            counter<=0;
            if(index2==4) begin
                index2 <= index1+2;
                index1 <= index1+1;
            end
            else index2<=index2+1;

            temp2_result[index1] <= in_ans[index1];
            temp2_result[index2] <= in_ans[index2];
            temp2_result[n_big] <= not_ans[0];
            temp2_result[n_medium] <= not_ans[1];
            temp2_result[n_small] <= not_ans[2];
            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        two_1A1B: begin 
            counter<=counter+1;
            if(index2==4) begin //for 1A and 1B
                index2 <= index1+2;
                index1 <= index1+1;
                if(index1==3) index2<=1;
            end
            else index2<=index2+1;

            temp2_result[n_big] <= not_ans[0];
            temp2_result[n_medium] <= not_ans[1];
            temp2_result[n_small] <= not_ans[2];

            if(counter<30) begin
                temp2_result[index1] <= in_ans[index1]; //for 1A
                if     (counter<10) begin  temp2_result[index2] <= in_ans[a]; end
                else if(counter<20) begin  temp2_result[index2] <= in_ans[b]; end
                else if(counter<30) begin  temp2_result[index2] <= in_ans[c]; end
                else                begin  temp2_result[index1] <= 0; temp2_result[index2] <= 0; end
            end
            else if(counter<60) begin
                temp2_result[index2] <= in_ans[index2]; //for 1A
                if     (counter<40) begin  temp2_result[index1] <= in_ans[a]; end
                else if(counter<50) begin  temp2_result[index1] <= in_ans[b]; end
                else if(counter<60) begin  temp2_result[index1] <= in_ans[c]; end
                else                begin  temp2_result[index1] <= 0; temp2_result[index2] <= 0; end
            end
            else begin
                counter<=0;
                temp2_result[index1] <= 0; 
                temp2_result[index2] <= 0; 
            end

            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        two_0A2B: begin 
            counter<=counter+1;
            if(index2==4) begin //for 2B
                index2 <= index1+2;
                index1 <= index1+1;
                if(index1==3) index2<=1;
            end
            else index2<=index2+1;

            temp2_result[n_big]    <= not_ans[0];
            temp2_result[n_medium] <= not_ans[1];
            temp2_result[n_small]  <= not_ans[2];

            if     (counter<10)  begin temp2_result[index1] <= in_ans[a]; temp2_result[index2] <= in_ans[b]; end
            else if(counter<20)  begin temp2_result[index1] <= in_ans[a]; temp2_result[index2] <= in_ans[c]; end
            else if(counter<30)  begin temp2_result[index1] <= in_ans[b]; temp2_result[index2] <= in_ans[c]; end
            else if(counter<40)  begin temp2_result[index1] <= in_ans[b]; temp2_result[index2] <= in_ans[a]; end
            else if(counter<50)  begin temp2_result[index1] <= in_ans[c]; temp2_result[index2] <= in_ans[a]; end
            else if(counter<60)  begin temp2_result[index1] <= in_ans[c]; temp2_result[index2] <= in_ans[b]; end
            else if(counter<70)  begin temp2_result[index1] <= in_ans[index2]; temp2_result[index2] <= in_ans[index1]; end
            else if(counter<80)  begin temp2_result[index1] <= in_ans[a]; temp2_result[index2] <= in_ans[index1]; end
            else if(counter<90)  begin temp2_result[index1] <= in_ans[b]; temp2_result[index2] <= in_ans[index1]; end
            else if(counter<100) begin temp2_result[index1] <= in_ans[c]; temp2_result[index2] <= in_ans[index1]; end
            else if(counter<110) begin temp2_result[index1] <= in_ans[index2]; temp2_result[index2] <= in_ans[a]; end
            else if(counter<120) begin temp2_result[index1] <= in_ans[index2]; temp2_result[index2] <= in_ans[b]; end
            else if(counter<130) begin temp2_result[index1] <= in_ans[index2]; temp2_result[index2] <= in_ans[c]; end
            else begin
                counter<=0;
                temp2_result[index1] <= 0; 
                temp2_result[index2] <= 0; 
            end

            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        three_3A0B: begin 
            counter<=0;
            if(index3==4) begin
                index2 <= index2+1;
                index3 <= index2+2;
                if(index2==3) begin
                    index1 <= index1+1;
                    index2 <= index1+2;
                    index3 <= index1+3;
                end
            end
            else index3<=index3+1;

            temp2_result[index1] <= in_ans[index1];
            temp2_result[index2] <= in_ans[index2];
            temp2_result[index3] <= in_ans[index3];
            temp2_result[n_big_3A] <= not_ans[0];
            temp2_result[n_small_3A] <= not_ans[1];

            if(temp2_value>temp1_value  || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        three_2A1B: begin 
            counter<=counter+1;
            if(index2==4) begin //for 2A
                index2 <= index1+2;
                index1 <= index1+1;
                if(index1==3) index2<=1;
            end
            else index2<=index2+1;
            temp2_result[index1] <= in_ans[index1]; //for 2A
            temp2_result[index2] <= in_ans[index2]; //for 2A
            if(counter<10) begin  temp2_result[n_big] <= not_ans[0]; temp2_result[n_medium] <= in_ans[n_big]; temp2_result[n_small] <= not_ans[1];end
            else if(counter<20) begin temp2_result[n_big] <= not_ans[0];       temp2_result[n_medium] <= not_ans[1]; temp2_result[n_small] <= in_ans[n_big]; end
            else if(counter<30) begin temp2_result[n_big] <= in_ans[n_medium]; temp2_result[n_medium] <= not_ans[0]; temp2_result[n_small] <= not_ans[1]; end
            else if(counter<40) begin temp2_result[n_big] <= not_ans[0]; temp2_result[n_medium] <= not_ans[1]; temp2_result[n_small] <= in_ans[n_medium]; end
            else if(counter<50) begin temp2_result[n_big] <= not_ans[0]; temp2_result[n_medium] <= in_ans[n_small]; temp2_result[n_small] <= not_ans[1]; end
            else if(counter<60) begin temp2_result[n_big] <= in_ans[n_small]; temp2_result[n_medium] <= not_ans[0]; temp2_result[n_small] <= not_ans[1]; end
            else begin
                counter <=0;
                temp2_result[a] <= 0;
                temp2_result[b] <= 0;
                temp2_result[c] <= 0;
            end
            if(temp2_value>temp1_value  || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        three_1A2B: begin 
            counter<=counter+1;
            if(index3==4) begin
                index2 <= index2+1;
                index3 <= index2+2;
                if(index2==3) begin
                    index1 <= index1+1;
                    index2 <= index1+2;
                    index3 <= index1+3;
                end
                if(index1==2) begin
                    index1 <= 0;
                    index2 <= 1;
                    index3 <= 2;
                end
            end
            else index3<=index3+1;

            temp2_result[n_big_3A]  <= not_ans[0];
            temp2_result[n_small_3A]<= not_ans[1]; 

            if     (counter<10)  begin temp2_result[index1] <= in_ans[index1];   temp2_result[index2] <= in_ans[b_3A];    temp2_result[index3] <= in_ans[a_3A];   end
            else if(counter<20)  begin temp2_result[index1] <= in_ans[index1];   temp2_result[index2] <= in_ans[a_3A];    temp2_result[index3] <= in_ans[b_3A];   end
            else if(counter<30)  begin temp2_result[index1] <= in_ans[index1];   temp2_result[index2] <= in_ans[b_3A];    temp2_result[index3] <= in_ans[index2]; end
            else if(counter<40)  begin temp2_result[index1] <= in_ans[index1];   temp2_result[index2] <= in_ans[index3];  temp2_result[index3] <= in_ans[b_3A];   end
            else if(counter<50)  begin temp2_result[index1] <= in_ans[index1];   temp2_result[index2] <= in_ans[a_3A];    temp2_result[index3] <= in_ans[index2]; end
            else if(counter<60)  begin temp2_result[index1] <= in_ans[index1];   temp2_result[index2] <= in_ans[index3];  temp2_result[index3] <= in_ans[a_3A];   end
            else if(counter<70)  begin temp2_result[index1] <= in_ans[index1];   temp2_result[index2] <= in_ans[index3];  temp2_result[index3] <= in_ans[index2]; end

            else if(counter<80)  begin temp2_result[index1] <= in_ans[index3];   temp2_result[index2] <= in_ans[index2];  temp2_result[index3] <= in_ans[index1]; end
            else if(counter<90)  begin temp2_result[index1] <= in_ans[a_3A];     temp2_result[index2] <= in_ans[index2];  temp2_result[index3] <= in_ans[index1]; end
            else if(counter<100) begin temp2_result[index1] <= in_ans[b_3A];     temp2_result[index2] <= in_ans[index2];  temp2_result[index3] <= in_ans[index1]; end
            else if(counter<110) begin temp2_result[index1] <= in_ans[index3];   temp2_result[index2] <= in_ans[index2];  temp2_result[index3] <= in_ans[a_3A];   end
            else if(counter<120) begin temp2_result[index1] <= in_ans[index3];   temp2_result[index2] <= in_ans[index2];  temp2_result[index3] <= in_ans[b_3A];   end
            else if(counter<130) begin temp2_result[index1] <= in_ans[a_3A];     temp2_result[index2] <= in_ans[index2];  temp2_result[index3] <= in_ans[b_3A];   end
            else if(counter<140) begin temp2_result[index1] <= in_ans[b_3A];     temp2_result[index2] <= in_ans[index2];  temp2_result[index3] <= in_ans[a_3A];   end

            else if(counter<150) begin temp2_result[index1] <= in_ans[index2];   temp2_result[index2] <= in_ans[index1];  temp2_result[index3] <= in_ans[index3]; end
            else if(counter<160) begin temp2_result[index1] <= in_ans[a_3A];     temp2_result[index2] <= in_ans[index1];  temp2_result[index3] <= in_ans[index3]; end
            else if(counter<170) begin temp2_result[index1] <= in_ans[b_3A];     temp2_result[index2] <= in_ans[index1];  temp2_result[index3] <= in_ans[index3]; end
            else if(counter<180) begin temp2_result[index1] <= in_ans[index2];   temp2_result[index2] <= in_ans[a_3A];    temp2_result[index3] <= in_ans[index3]; end
            else if(counter<190) begin temp2_result[index1] <= in_ans[index2];   temp2_result[index2] <= in_ans[b_3A];    temp2_result[index3] <= in_ans[index3]; end
            else if(counter<200) begin temp2_result[index1] <= in_ans[a_3A];     temp2_result[index2] <= in_ans[b_3A];    temp2_result[index3] <= in_ans[index3]; end
            else if(counter<210) begin temp2_result[index1] <= in_ans[b_3A];     temp2_result[index2] <= in_ans[a_3A];    temp2_result[index3] <= in_ans[index3]; end
            else begin
                counter <=0;
                temp2_result[index1] <= 0;
                temp2_result[index2] <= 0;
                temp2_result[index3] <= 0;
            end

            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        three_0A3B: begin 
            counter<=counter+1;
            if(index2==4) begin //for 1A and 0A0B
                index2 <= index1+2;
                index1 <= index1+1;
                if(index1==3) index2<=1;
            end
            else index2<=index2+1;

            temp2_result[index_0A3B_big]   <= not_ans[0];
            temp2_result[index_0A3B_small] <= not_ans[1];
            
            if     (counter<10)  begin   temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[index2]; temp2_result[c] <= in_ans[index1]; end
            else if(counter<20)  begin   temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[index2]; temp2_result[c] <= in_ans[index1]; end
            else if(counter<30)  begin   temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[index1]; temp2_result[c] <= in_ans[index2]; end
            else if(counter<40)  begin   temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[index1]; temp2_result[c] <= in_ans[index2]; end
            else if(counter<50)  begin   temp2_result[a] <= in_ans[index2]; temp2_result[b] <= in_ans[index1]; temp2_result[c] <= in_ans[a];      end
            else if(counter<60)  begin   temp2_result[a] <= in_ans[index2]; temp2_result[b] <= in_ans[index1]; temp2_result[c] <= in_ans[b];      end
            else if(counter<70)  begin   temp2_result[a] <= in_ans[index1]; temp2_result[b] <= in_ans[index2]; temp2_result[c] <= in_ans[a];      end
            else if(counter<80)  begin   temp2_result[a] <= in_ans[index1]; temp2_result[b] <= in_ans[index2]; temp2_result[c] <= in_ans[b];      end
            else if(counter<90)  begin   temp2_result[a] <= in_ans[index2]; temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[index1]; end
            else if(counter<100) begin   temp2_result[a] <= in_ans[index2]; temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[index1]; end
            else if(counter<110) begin   temp2_result[a] <= in_ans[index1]; temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[index2]; end
            else if(counter<120) begin   temp2_result[a] <= in_ans[index1]; temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[index2]; end
            else begin 
                counter<=0;
                temp2_result[a] <= 0; 
                temp2_result[b] <= 0; 
                temp2_result[c] <= 0; 
            end
            
            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        four_4A0B: begin            
            counter<=counter+1; 
            if     (counter<1) begin temp2_result[0]<= not_ans[0]; temp2_result[1]<= in_ans[1]; temp2_result[2]<= in_ans[2]; temp2_result[3]<= in_ans[3]; temp2_result[4]<= in_ans[4]; end
            else if(counter<2) begin temp2_result[0]<= in_ans[0]; temp2_result[1]<= not_ans[0]; temp2_result[2]<= in_ans[2]; temp2_result[3]<= in_ans[3]; temp2_result[4]<= in_ans[4]; end
            else if(counter<3) begin temp2_result[0]<= in_ans[0]; temp2_result[1]<= in_ans[1]; temp2_result[2]<= not_ans[0]; temp2_result[3]<= in_ans[3]; temp2_result[4]<= in_ans[4]; end
            else if(counter<4) begin temp2_result[0]<= in_ans[0]; temp2_result[1]<= in_ans[1]; temp2_result[2]<= in_ans[2]; temp2_result[3]<= not_ans[0]; temp2_result[4]<= in_ans[4]; end
            else if(counter<5) begin
                temp2_result[0]<= in_ans[0];
                temp2_result[1]<= in_ans[1];
                temp2_result[2]<= in_ans[2];
                temp2_result[3]<= in_ans[3]; 
                temp2_result[4]<= not_ans[0]; end
            else begin
                counter <=0;
                temp2_result[0] <= 0;
                temp2_result[1] <= 0;
                temp2_result[2] <= 0;
                temp2_result[3] <= 0;
                temp2_result[4] <= 0;
            end

            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        four_3A1B: begin 
            counter<=counter+1;
            if(index3==4) begin
                index2 <= index2+1;
                index3 <= index2+2;
                if(index2==3) begin
                    index1 <= index1+1;
                    index2 <= index1+2;
                    index3 <= index1+3;
                end
                if(index1==2) begin
                    index1 <= 0;
                    index2 <= 1;
                    index3 <= 2;
                end
            end
            else index3<=index3+1;

            temp2_result[index1] <= in_ans[index1];
            temp2_result[index2] <= in_ans[index2];
            temp2_result[index3] <= in_ans[index3];

            if(counter<10)      begin temp2_result[a_3A] <= not_ans[0];   temp2_result[b_3A] <= in_ans[a_3A]; end
            else if(counter<20) begin temp2_result[a_3A] <= in_ans[b_3A]; temp2_result[b_3A] <= not_ans[0];
            end
            else begin
                counter <=0;
                temp2_result[a_3A] <= 0;
                temp2_result[b_3A] <= 0;
            end

            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        four_2A2B: begin 
            counter<=counter+1;
            if(index2==4) begin //for 2A
                index2 <= index1+2;
                index1 <= index1+1;
                if(index1==3) index2<=1;
            end
            else index2<=index2+1;
            temp2_result[index1] <= in_ans[index1]; //for 2A
            temp2_result[index2] <= in_ans[index2]; //for 2A
            if(counter<10)      begin temp2_result[a] <= not_ans[0]; temp2_result[b] <= in_ans[c];  temp2_result[c] <= in_ans[b]; end
            else if(counter<20) begin temp2_result[a] <= not_ans[0]; temp2_result[b] <= in_ans[c];  temp2_result[c] <= in_ans[a]; end
            else if(counter<30) begin temp2_result[a] <= not_ans[0]; temp2_result[b] <= in_ans[a];  temp2_result[c] <= in_ans[b]; end
            else if(counter<40) begin temp2_result[a] <= in_ans[c];  temp2_result[b] <= not_ans[0]; temp2_result[c] <= in_ans[b]; end
            else if(counter<50) begin temp2_result[a] <= in_ans[c];  temp2_result[b] <= not_ans[0]; temp2_result[c] <= in_ans[a]; end
            else if(counter<60) begin temp2_result[a] <= in_ans[b];  temp2_result[b] <= not_ans[0]; temp2_result[c] <= in_ans[a]; end
            else if(counter<70) begin temp2_result[a] <= in_ans[b];  temp2_result[b] <= in_ans[c];  temp2_result[c] <= not_ans[0]; end
            else if(counter<80) begin temp2_result[a] <= in_ans[c];  temp2_result[b] <= in_ans[a];  temp2_result[c] <= not_ans[0]; end
            else if(counter<90) begin temp2_result[a] <= in_ans[b];  temp2_result[b] <= in_ans[a];  temp2_result[c] <= not_ans[0]; end
            else begin counter <=0; temp2_result[a] <= 0; temp2_result[b] <= 0; temp2_result[c] <= 0; end

            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        four_1A3B: begin 
            counter<=counter+1;
            if(index2==4) begin //for 1A and 0A0B
                index2 <= index1+2;
                index1 <= index1+1;
                if(index1==3) index2<=1;
            end
            else index2<=index2+1;

            if(counter<110) begin
                if(num_of_not_AB==1) begin//for 1A3B
                    temp2_result[index1] <= in_ans[index1]; //for 1A
                    temp2_result[index2] <= not_ans[0]; //for 0A0B
                end
                else begin //for 0A3B
                    temp2_result[index_0A3B_big]   <= not_ans[0];
                    temp2_result[index_0A3B_small] <= not_ans[1];
                end
                if     (counter<10) begin   temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[a]; end
                else if(counter<20) begin   temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[b]; end
                else if(counter<30) begin   temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[index2]; end
                else if(counter<40) begin   temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[index2]; temp2_result[c] <= in_ans[b]; end
                else if(counter<50) begin   temp2_result[a] <= in_ans[index2]; temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[b]; end
                else if(counter<60) begin   temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[index2]; end
                else if(counter<70) begin   temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[index2]; temp2_result[c] <= in_ans[a]; end
                else if(counter<80) begin   temp2_result[a] <= in_ans[index2]; temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[a]; end
                else if(counter<90) begin   temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[index2]; end
                else if(counter<100) begin  temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[index2]; temp2_result[c] <= in_ans[a]; end
                else if(counter<110) begin  temp2_result[a] <= in_ans[index2]; temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[b]; end
                else begin temp2_result[a] <= 0; temp2_result[b] <= 0; temp2_result[c] <= 0; end
            end
            else if(counter<220) begin
                if(num_of_not_AB==1) begin//for 1A3B
                    temp2_result[index1] <= not_ans[0]; //for 0A0B
                    temp2_result[index2] <= in_ans[index2]; //for 1A
                end
                else begin //for 0A3B
                    temp2_result[index_0A3B_big]   <= not_ans[0]; //for 0A0B
                    temp2_result[index_0A3B_small] <= not_ans[1];
                end 
                if     (counter<120) begin  temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[a]; end
                else if(counter<130) begin  temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[b]; end
                else if(counter<140) begin  temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[index1]; end
                else if(counter<150) begin  temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[index1]; temp2_result[c] <= in_ans[b]; end
                else if(counter<160) begin  temp2_result[a] <= in_ans[index1]; temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[b]; end
                else if(counter<170) begin  temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[index1]; end
                else if(counter<180) begin  temp2_result[a] <= in_ans[c];      temp2_result[b] <= in_ans[index1]; temp2_result[c] <= in_ans[a]; end
                else if(counter<190) begin  temp2_result[a] <= in_ans[index1]; temp2_result[b] <= in_ans[c];      temp2_result[c] <= in_ans[a]; end
                else if(counter<200) begin  temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[index1]; end
                else if(counter<210) begin  temp2_result[a] <= in_ans[b];      temp2_result[b] <= in_ans[index1]; temp2_result[c] <= in_ans[a]; end
                else if(counter<220) begin  temp2_result[a] <= in_ans[index1]; temp2_result[b] <= in_ans[a];      temp2_result[c] <= in_ans[b]; end
                else begin
                    temp2_result[a] <= 0; temp2_result[b] <= 0; temp2_result[c] <= 0;
                end
            end
            else begin
                counter<=0;
                temp2_result[index1] <= 0; 
                temp2_result[index2] <= 0; 
                index1<=0;
                index2<=1;
            end

            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        four_0A4B: begin 
            counter<=counter+1;
            if(index_1A4B==4) index_1A4B <= 0;
            else index_1A4B <= index_1A4B+1;

            temp2_result[index_1A4B] <= not_ans[0]; //for 0A0B

            if(counter<5)        begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[c_4B]; end
            else if(counter<10)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[b_4B]; end
            else if(counter<15)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<20)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[c_4B]; end
            else if(counter<25)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<30)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<35)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<40)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<45)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<50)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<55)  begin temp2_result[a_4B] <= in_ans[index_1A4B]; temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<60)  begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<65)  begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<70)  begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<75)  begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<80)  begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<85)  begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<90)  begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<95)  begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<100) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<105) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<110) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[index_1A4B]; temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<115) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<120) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<125) begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<130) begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<135) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<140) begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<145) begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<150) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<155) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[c_4B];end
            else if(counter<160) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<165) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[index_1A4B]; temp2_result[d_4B] <= in_ans[a_4B];end
            else if(counter<170) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<175) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<180) begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<185) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<190) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<195) begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<200) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[d_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<205) begin temp2_result[a_4B] <= in_ans[d_4B];       temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<210) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[d_4B];       temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<215) begin temp2_result[a_4B] <= in_ans[c_4B];       temp2_result[b_4B] <= in_ans[a_4B];       temp2_result[c_4B] <= in_ans[b_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else if(counter<220) begin temp2_result[a_4B] <= in_ans[b_4B];       temp2_result[b_4B] <= in_ans[c_4B];       temp2_result[c_4B] <= in_ans[a_4B];       temp2_result[d_4B] <= in_ans[index_1A4B];end
            else begin
                counter <=0;
                // index1 <= 0;
                index_1A4B<=0;
                temp2_result[a_4B] <= 0;
                temp2_result[b_4B] <= 0;
                temp2_result[c_4B] <= 0;
                temp2_result[d_4B] <= 0;
            end


            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        five_5A0B: begin 
            counter<=0;
            for (i = 0; i<5 ; i=i+1) begin
                temp1_result[i] <= in_ans[i];
            end
        end
        five_3A2B: begin 
            counter<=0;
            if(index3==4) begin
                index2 <= index2+1;
                index3 <= index2+2;
                if(index2==3) begin
                    index1 <= index1+1;
                    index2 <= index1+2;
                    index3 <= index1+3;
                end
            end
            else index3<=index3+1;

            temp2_result[index1] <= in_ans[index1];
            temp2_result[index2] <= in_ans[index2];
            temp2_result[index3] <= in_ans[index3];
            temp2_result[a_3A] <= in_ans[b_3A];
            temp2_result[b_3A] <= in_ans[a_3A];

            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        five_2A3B: begin 
            counter<=counter+1;
            if(index2==4) begin //for 2A
                index2 <= index1+2;
                index1 <= index1+1;
                if(index1==3) index2<=1;
            end
            else index2<=index2+1;
            temp2_result[index1] <= in_ans[index1]; //for 2A
            temp2_result[index2] <= in_ans[index2]; //for 2A
            if(counter<10) begin 
                temp2_result[a] <= in_ans[c];
                temp2_result[b] <= in_ans[a];
                temp2_result[c] <= in_ans[b];
            end
            else if(counter<20) begin
                temp2_result[a] <= in_ans[b];
                temp2_result[b] <= in_ans[c];
                temp2_result[c] <= in_ans[a];
            end
            else begin
                counter <=0;
                temp2_result[a] <= 0;
                temp2_result[b] <= 0;
                temp2_result[c] <= 0;
            end
            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        five_1A4B: begin 
            counter<=counter+1;
            if(index_1A4B==4) index_1A4B <= 0;
            else          index_1A4B <= index_1A4B+1;

            if(num_of_not_AB==0) temp2_result[index_1A4B] <= in_ans[index_1A4B]; //for 1A
            else                 temp2_result[index_1A4B] <= not_ans[0];     //for four_0A4B

            if(counter<5) begin temp2_result[a_4B] <= in_ans[b_4B]; temp2_result[b_4B] <= in_ans[a_4B]; temp2_result[c_4B] <= in_ans[d_4B]; temp2_result[d_4B] <= in_ans[c_4B]; end
            else if(counter<10) begin temp2_result[a_4B] <= in_ans[d_4B]; temp2_result[b_4B] <= in_ans[a_4B]; temp2_result[c_4B] <= in_ans[b_4B]; temp2_result[d_4B] <= in_ans[c_4B]; end
            else if(counter<15) begin temp2_result[a_4B] <= in_ans[c_4B]; temp2_result[b_4B] <= in_ans[a_4B]; temp2_result[c_4B] <= in_ans[d_4B]; temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<20) begin temp2_result[a_4B] <= in_ans[b_4B]; temp2_result[b_4B] <= in_ans[d_4B]; temp2_result[c_4B] <= in_ans[a_4B]; temp2_result[d_4B] <= in_ans[c_4B]; end
            else if(counter<25) begin temp2_result[a_4B] <= in_ans[c_4B]; temp2_result[b_4B] <= in_ans[d_4B]; temp2_result[c_4B] <= in_ans[a_4B]; temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<30) begin temp2_result[a_4B] <= in_ans[d_4B]; temp2_result[b_4B] <= in_ans[c_4B]; temp2_result[c_4B] <= in_ans[a_4B]; temp2_result[d_4B] <= in_ans[b_4B];end
            else if(counter<35) begin temp2_result[a_4B] <= in_ans[b_4B]; temp2_result[b_4B] <= in_ans[c_4B]; temp2_result[c_4B] <= in_ans[d_4B]; temp2_result[d_4B] <= in_ans[a_4B];  end
            else if(counter<40) begin temp2_result[a_4B] <= in_ans[c_4B]; temp2_result[b_4B] <= in_ans[d_4B]; temp2_result[c_4B] <= in_ans[b_4B]; temp2_result[d_4B] <= in_ans[a_4B]; end
            else if(counter<45) begin temp2_result[a_4B] <= in_ans[d_4B]; temp2_result[b_4B] <= in_ans[c_4B]; temp2_result[c_4B] <= in_ans[b_4B]; temp2_result[d_4B] <= in_ans[a_4B]; end
            else begin
                counter <=0;
                // index1 <= 0;
                index_1A4B<=0;
                temp2_result[a_4B] <= 0;
                temp2_result[b_4B] <= 0;
                temp2_result[c_4B] <= 0;
                temp2_result[d_4B] <= 0;
            end
            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        five_0A5B: begin 
            counter<=counter+1;

            if(counter<1)       begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[3]; end
            else if(counter<2)  begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[2]; end
            else if(counter<3)  begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[3];end
            else if(counter<4)  begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[3]; end
            else if(counter<5)  begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[2];end
            else if(counter<6)  begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[3];end
            else if(counter<7)  begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[2];  end
            else if(counter<8)  begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[2]; end
            else if(counter<9)  begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[0]; end
            else if(counter<10) begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[0]; end
            else if(counter<11) begin temp2_result[0]<=in_ans[1]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[0];end
            else if(counter<12) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[3]; end
            else if(counter<13) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[3]; end
            else if(counter<14) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[1]; end
            else if(counter<15) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[3]; end
            else if(counter<16) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[1]; end
            else if(counter<17) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[3]; end
            else if(counter<18) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[1]; end
            else if(counter<19) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[1]; end
            else if(counter<20) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[0]; end
            else if(counter<21) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[0]; end
            else if(counter<22) begin temp2_result[0]<=in_ans[2]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[0]; end
            else if(counter<23) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[2]; end
            else if(counter<24) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[2]; end
            else if(counter<25) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[1]; end
            else if(counter<26) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[2]; end
            else if(counter<27) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[1]; end
            else if(counter<28) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[1]; end
            else if(counter<29) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[2]; end
            else if(counter<30) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[1]; end
            else if(counter<31) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[4]; temp2_result[4]<=in_ans[0]; end
            else if(counter<32) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[4];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[0]; end
            else if(counter<33) begin temp2_result[0]<=in_ans[3]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[4];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[0]; end
            else if(counter<34) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[3]; end
            else if(counter<35) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[2]; end
            else if(counter<36) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[0];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[1]; end
            else if(counter<37) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[3]; end
            else if(counter<38) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[2]; end
            else if(counter<39) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[0];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[1]; end
            else if(counter<40) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[3]; end
            else if(counter<41) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[2]; end
            else if(counter<42) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[0]; temp2_result[4]<=in_ans[1]; end
            else if(counter<43) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[3];  temp2_result[2]<=in_ans[1];  temp2_result[3]<=in_ans[2]; temp2_result[4]<=in_ans[0]; end
            else if(counter<44) begin temp2_result[0]<=in_ans[4]; temp2_result[1]<=in_ans[2];  temp2_result[2]<=in_ans[3];  temp2_result[3]<=in_ans[1]; temp2_result[4]<=in_ans[0]; end
            else begin
                counter <=0;
                // index1 <= 0;
                // index_1A4B<=0;
                temp2_result[0] <= 0;
                temp2_result[1] <= 0;
                temp2_result[2] <= 0;
                temp2_result[3] <= 0;
                temp2_result[4] <= 0;
            end


            if(temp2_value>temp1_value || ((temp2_value==temp1_value)&&(temp1_corner<temp2_corner)) || ((temp2_value==temp1_value)&&(temp1_corner==temp2_corner)&&(index_corner==1))) begin
                temp1_result[0]<= temp2_result[0];
                temp1_result[1]<= temp2_result[1];
                temp1_result[2]<= temp2_result[2];
                temp1_result[3]<= temp2_result[3];
                temp1_result[4]<= temp2_result[4];
            end
        end
        OUT: begin
            out_valid <= 1;
            out_counter <= out_counter + 1;
            result <= temp1_result[out_counter];
            out_value <= temp1_result[0]*in_weight[0]+temp1_result[1]*in_weight[1]+temp1_result[2]*in_weight[2]+temp1_result[3]*in_weight[3]+temp1_result[4]*in_weight[4];

        end
    endcase
    end
end
//=========================================================================================================
//=========================================================================================================
//=========================================================================================================
assign index_b[0]=(index1==0)? 0:1;
assign index_b[1]=(index1==1 || index2==1)? 0:1;
assign index_b[2]=(index1==2 || index2==2)? 0:1;
assign index_b[3]=(index1==3 || index2==3)? 0:1;
assign index_b[4]=(index2==4)? 0:1;

assign index_3A[0]=(index1==0)? 0:1;
assign index_3A[1]=(index1==1 || index2==1)? 0:1;
assign index_3A[2]=(index1==2 || index2==2 || index3==2)? 0:1;
assign index_3A[3]=(index1==3 || index2==3 || index3==3)? 0:1;
assign index_3A[4]=(index2==4 || index3==4)? 0:1;

assign index_0A3B_big   = (in_weight[index1]>in_weight[index2])? index1:index2;
assign index_0A3B_small = (in_weight[index1]>in_weight[index2])? index2:index1;

always @(*) begin   //for three rest
    if (index_b[4]==1) begin 
        a=4;
        if (index_b[3] == 1) begin
            b=3;
            if(index_b[2] == 1) c=2;
            else if(index_b[1] ==1) c=1;
            else c=0;
        end
        else if(index_b[2] == 1) begin
            b=2;
            if(index_b[1] == 1) c=1;
            else c=0;
        end
        else begin
            b=1;
            c=0;
        end
    end
    else if(index_b[3] == 1) begin 
        a=3;
        if(index_b[2] == 1) begin
            b=2;
            if(index_b[1] == 1) c=1;
            else c=0;
        end
        else begin
            b=1;
            c=0;
        end
    end
    else begin 
        a=2;
        b=1;
        c=0;
    end
end

always @(*) begin   //for three rest
    if (index_3A[4]==1) begin 
        a_3A=4;
        if (index_3A[3] == 1) begin
            b_3A=3;
        end
        else if(index_3A[2] == 1) 
            b_3A=2;
        else if(index_3A[1] == 1)
            b_3A=1;
        else b_3A = 0;
    end
    else if(index_3A[3] == 1) begin 
        a_3A=3;
        if(index_3A[2] == 1) b_3A=2;
        else if(index_3A[1] == 1) b_3A=1;
        else b_3A = 0;
    end
    else if(index_3A[2] == 1) begin
        a_3A = 2;
        if(index_3A[1] == 1) begin
            b_3A = 1;
        end
        else b_3A = 0;
    end
    else begin 
        a_3A=1;
        b_3A=0;
    end
end

always @(*) begin
    case(index_1A4B)
        0: begin
            a_4B = 1;
            b_4B = 2;
            c_4B = 3;
            d_4B = 4;
        end
        1: begin
            a_4B = 0;
            b_4B = 2;
            c_4B = 3;
            d_4B = 4;
        end
        2:begin
            a_4B = 0;
            b_4B = 1;
            c_4B = 3;
            d_4B = 4;
        end
        3:begin
            a_4B = 0;
            b_4B = 1;
            c_4B = 2;
            d_4B = 4;
        end
        default:begin   //4
            a_4B = 0;
            b_4B = 1;
            c_4B = 2;
            d_4B = 3;
        end
    endcase
end

assign n1 = (in_weight[a]>in_weight[b])? a:b;
assign n2 = (in_weight[a]>in_weight[b])? b:a;
assign n3 = (in_weight[n1]>in_weight[c])? c:n1;
assign n_big = (in_weight[n1]>in_weight[c])? n1:c;
assign n_medium = (in_weight[n2]>in_weight[n3])? n2:n3;
assign n_small  = (in_weight[n2]>in_weight[n3])? n3:n2;

assign n_big_3A = (in_weight[a_3A]>in_weight[b_3A])? a_3A:b_3A;
assign n_small_3A = (in_weight[a_3A]>in_weight[b_3A])? b_3A:a_3A;

assign keyboard_index = counter + 1;
assign num_of_not_AB = 5- in_tar[0] - in_tar[1];
assign same = same1||same2||same3||same4||same5;
assign temp2_value = temp2_result[0]*in_weight[0]+temp2_result[1]*in_weight[1]+temp2_result[2]*in_weight[2]+temp2_result[3]*in_weight[3]+temp2_result[4]*in_weight[4];
assign temp1_value = temp1_result[0]*in_weight[0]+temp1_result[1]*in_weight[1]+temp1_result[2]*in_weight[2]+temp1_result[3]*in_weight[3]+temp1_result[4]*in_weight[4];
assign temp1_corner = temp1_result[0]*16+temp1_result[1]*8+temp1_result[2]*4+temp1_result[3]*2+temp1_result[4];
assign temp2_corner = temp2_result[0]*16+temp2_result[1]*8+temp2_result[2]*4+temp2_result[3]*2+temp2_result[4];

always @(*) begin
    if(temp2_result[0]==temp1_result[0]) begin
        if(temp2_result[1]==temp1_result[1]) begin
            if(temp2_result[2]==temp1_result[2]) begin
                if(temp2_result[3]==temp1_result[3]) begin
                    if(temp2_result[4]<temp1_result[4]) index_corner = 1;
                    else index_corner = 0;
                end
                else if(temp2_result[3]<temp1_result[3]) index_corner = 1;
                else index_corner = 0;
            end
            else if(temp2_result[2]<temp1_result[2]) index_corner = 1;
            else index_corner = 0;
        end
        else if(temp2_result[1]<temp1_result[1]) index_corner = 1;
        else index_corner = 0;
    end
    else if(temp2_result[0]<temp1_result[0]) index_corner = 1;
    else index_corner = 0;
end

always @(*) begin
    out_valid_comb = 0;
    // out_value_comb = 0;
    case (current_state)
      
        OUT: begin
            out_valid_comb = 1'b1;
        end
    endcase
end

endmodule