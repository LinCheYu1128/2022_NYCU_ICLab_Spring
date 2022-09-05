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

parameter IDLE = 3'b000;
parameter LOAD = 3'b001;
parameter SORT = 3'b011;
parameter COMB = 3'b010;
parameter PERM = 3'b110;
parameter OUT  = 3'b100;
// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [2:0] current_state, next_state;

reg [4:0] Keyboard[0:7];
reg [4:0] Answer[0:4];
reg [3:0] Weight[0:4];
reg [2:0] MatchTarget[0:1];
reg [4:0] Guess[0:4];
reg [2:0] p0, p1, p2, p3, p4;
reg [4:0] Temp_Result[0:4];
reg [10:0]Temp_Out_Value;
reg [10:0]CC_Temp_Out_Value;

reg [2:0] counter;
reg [4:0] counter_comb;
reg [2:0] counter_perm1; //(0-1*0-2) => 0-5
reg [1:0] counter_perm2; //0-3
reg [2:0] counter_perm3; //0-4
reg out_trigger;

wire perm_trigger;

wire [2:0] match_out[0:1];
wire [10:0] sum;
wire [11:0] CC_sum;
// ===============================================================
// DESIGN
// ===============================================================

Match match(.in0(Guess[0]), .in1(Guess[1]), .in2(Guess[2]), .in3(Guess[3]), .in4(Guess[4]),
    .ans0(Answer[0]), .ans1(Answer[1]), .ans2(Answer[2]), .ans3(Answer[3]), .ans4(Answer[4]),
    // Output signals
    .outA(match_out[0]), .outB(match_out[1]));

assign  perm_trigger = (counter_perm1 == 3'd5 && counter_perm2 == 2'd3 && counter_perm3 == 3'd4)? 1:0; 

assign sum = (((Weight[0]*Guess[0]) + (Weight[1]*Guess[1])) +
              ((Weight[2]*Guess[2]) + (Weight[3]*Guess[3]))) +
               (Weight[4]*Guess[4]) ;

assign CC_sum = (((5'd16*Guess[0]) + (5'd8 *Guess[1])) +
                 ((5'd4 *Guess[2]) + (5'd2 *Guess[3]))) +
                  (5'd1 *Guess[4]) ;

// ===============================================================
// INITIAL DATA
// ===============================================================
always @(posedge clk) begin
    if(in_valid) begin
        case (counter)
            0: Keyboard[0] <= keyboard;
            1: Keyboard[1] <= keyboard;
            2: Keyboard[2] <= keyboard;
            3: Keyboard[3] <= keyboard;
            4: Keyboard[4] <= keyboard;
            5: Keyboard[5] <= keyboard;
            6: Keyboard[6] <= keyboard;
            default: Keyboard[7] <= keyboard;
        endcase
    end
    else if(current_state == SORT) begin
        case (counter)
            0: begin
                if(Answer[0] == Keyboard[1]) begin
                    Keyboard[1] <= Keyboard[0];
                    Keyboard[0] <= Keyboard[1];
                end
                else if(Answer[0] == Keyboard[2]) begin
                    Keyboard[2] <= Keyboard[0];
                    Keyboard[0] <= Keyboard[2];
                end
                else if(Answer[0] == Keyboard[3]) begin
                    Keyboard[3] <= Keyboard[0];
                    Keyboard[0] <= Keyboard[3];
                end
                else if(Answer[0] == Keyboard[4]) begin
                    Keyboard[4] <= Keyboard[0];
                    Keyboard[0] <= Keyboard[4];
                end
                else if(Answer[0] == Keyboard[5]) begin
                    Keyboard[5] <= Keyboard[0];
                    Keyboard[0] <= Keyboard[5];
                end
                else if(Answer[0] == Keyboard[6]) begin
                    Keyboard[6] <= Keyboard[0];
                    Keyboard[0] <= Keyboard[6];
                end
                else if(Answer[0] == Keyboard[7]) begin
                    Keyboard[7] <= Keyboard[0];
                    Keyboard[0] <= Keyboard[7];
                end
                else Keyboard[0] <= Keyboard[0];
            end
            1:begin
                if(Answer[1] == Keyboard[2]) begin
                    Keyboard[2] <= Keyboard[1];
                    Keyboard[1] <= Keyboard[2];
                end
                else if(Answer[1] == Keyboard[3]) begin
                    Keyboard[3] <= Keyboard[1];
                    Keyboard[1] <= Keyboard[3];
                end
                else if(Answer[1] == Keyboard[4]) begin
                    Keyboard[4] <= Keyboard[1];
                    Keyboard[1] <= Keyboard[4];
                end
                else if(Answer[1] == Keyboard[5]) begin
                    Keyboard[5] <= Keyboard[1];
                    Keyboard[1] <= Keyboard[5];
                end
                else if(Answer[1] == Keyboard[6]) begin
                    Keyboard[6] <= Keyboard[1];
                    Keyboard[1] <= Keyboard[6];
                end
                else if(Answer[1] == Keyboard[7]) begin
                    Keyboard[7] <= Keyboard[1];
                    Keyboard[1] <= Keyboard[7];
                end
                else Keyboard[1] <= Keyboard[1];
            end
            2:begin
                if(Answer[2] == Keyboard[3]) begin
                    Keyboard[3] <= Keyboard[2];
                    Keyboard[2] <= Keyboard[3];
                end
                else if(Answer[2] == Keyboard[4]) begin
                    Keyboard[4] <= Keyboard[2];
                    Keyboard[2] <= Keyboard[4];
                end
                else if(Answer[2] == Keyboard[5]) begin
                    Keyboard[5] <= Keyboard[2];
                    Keyboard[2] <= Keyboard[5];
                end
                else if(Answer[2] == Keyboard[6]) begin
                    Keyboard[6] <= Keyboard[2];
                    Keyboard[2] <= Keyboard[6];
                end
                else if(Answer[2] == Keyboard[7]) begin
                    Keyboard[7] <= Keyboard[2];
                    Keyboard[2] <= Keyboard[7];
                end
                else Keyboard[2] <= Keyboard[2];
            end
            3:begin
                if(Answer[3] == Keyboard[4]) begin
                    Keyboard[4] <= Keyboard[3];
                    Keyboard[3] <= Keyboard[4];
                end
                else if(Answer[3] == Keyboard[5]) begin
                    Keyboard[5] <= Keyboard[3];
                    Keyboard[3] <= Keyboard[5];
                end
                else if(Answer[3] == Keyboard[6]) begin
                    Keyboard[6] <= Keyboard[3];
                    Keyboard[3] <= Keyboard[6];
                end
                else if(Answer[3] == Keyboard[7]) begin
                    Keyboard[7] <= Keyboard[3];
                    Keyboard[3] <= Keyboard[7];
                end
                else Keyboard[3] <= Keyboard[3];
            end
            4:begin
                if(Answer[4] == Keyboard[5]) begin
                    Keyboard[5] <= Keyboard[4];
                    Keyboard[4] <= Keyboard[5];
                end  
                else if(Answer[4] == Keyboard[6]) begin
                    Keyboard[6] <= Keyboard[4];
                    Keyboard[4] <= Keyboard[6];
                end  
                else if(Answer[4] == Keyboard[7]) begin
                    Keyboard[7] <= Keyboard[4];
                    Keyboard[4] <= Keyboard[7];
                end  
                else Keyboard[4] <= Keyboard[4];
            end
            5: begin
                if(Keyboard[6] > Keyboard[5] && Keyboard[6] > Keyboard[7]) begin
                    Keyboard[6] <= Keyboard[5];
                    Keyboard[5] <= Keyboard[6];
                end
                else if(Keyboard[7] > Keyboard[5] && Keyboard[7] > Keyboard[6]) begin
                    Keyboard[7] <= Keyboard[5];
                    Keyboard[5] <= Keyboard[7];
                end
                else begin
                    Keyboard[5] <= Keyboard[5];
                end
            end
            default:begin
                if(Keyboard[7] > Keyboard[6])begin
                    Keyboard[7] <= Keyboard[6];
                    Keyboard[6] <= Keyboard[7];
                end
                else Keyboard[6] <= Keyboard[6];
            end
        endcase
    end
    else begin
        Keyboard[0] <= Keyboard[0];
        Keyboard[1] <= Keyboard[1];
        Keyboard[2] <= Keyboard[2];
        Keyboard[3] <= Keyboard[3];
        Keyboard[4] <= Keyboard[4];
        Keyboard[5] <= Keyboard[5];
        Keyboard[6] <= Keyboard[6];
    end
end

always @(posedge clk) begin
    if(in_valid) begin
        case (counter)
            0: Answer[0] <= answer;
            1: Answer[1] <= answer;
            2: Answer[2] <= answer;
            3: Answer[3] <= answer;
            4: Answer[4] <= answer;
            default: Answer[4] <= Answer[4];
        endcase
    end
    else begin
        Answer[0] <= Answer[0];
        Answer[1] <= Answer[1];
        Answer[2] <= Answer[2];
        Answer[3] <= Answer[3];
        Answer[4] <= Answer[4];
    end
end

always @(posedge clk) begin
    if(in_valid) begin
        case (counter)
            0: Weight[0] <= weight;
            1: Weight[1] <= weight;
            2: Weight[2] <= weight;
            3: Weight[3] <= weight;
            4: Weight[4] <= weight;
            default: Weight[4] <= Weight[4];
        endcase
    end
    else begin
        Weight[0] <= Weight[0];
        Weight[1] <= Weight[1];
        Weight[2] <= Weight[2];
        Weight[3] <= Weight[3];
        Weight[4] <= Weight[4];
    end
end

always @(posedge clk) begin
    if(in_valid) begin
        case (counter)
            0: MatchTarget[0] <= match_target;
            1: MatchTarget[1] <= match_target;
            default: MatchTarget[1] <= MatchTarget[1];
        endcase
    end
    else begin
        MatchTarget[0] <= MatchTarget[0];
        MatchTarget[1] <= MatchTarget[1];
    end
end

// ===============================================================
// COUNTER
// ===============================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter <= 0;
    else if(in_valid) counter <= counter + 1;
    // else if(counter == 3'd7) counter <= 0;
    else if(current_state == SORT) counter <= counter + 1;
    else if(current_state == OUT) counter <= counter + 1;
    else counter <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_comb <= 0;
    else if(current_state == IDLE) counter_comb <= 0;
    else if(current_state == COMB) counter_comb <= counter_comb + 1;
    else counter_comb <= counter_comb;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_perm1 <= 0;
    else if(current_state == PERM) counter_perm1 <= (counter_perm1 == 3'd5)? 3'd0 : counter_perm1 + 1;
    else counter_perm1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_perm2 <= 0;
    else if(current_state == PERM) counter_perm2 <= (counter_perm1 == 3'd5)?counter_perm2 + 1 : counter_perm2;
    else counter_perm2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_perm3 <= 0;
    else if(current_state == PERM) counter_perm3 <= (counter_perm2 == 2'd3 && counter_perm1 == 3'd5)? counter_perm3 + 1 : counter_perm3 ;
    else counter_perm3 <= 0;
end

// ===============================================================
// COMPARE
// ===============================================================
always @(posedge clk) begin
    if(current_state == LOAD)begin
        Temp_Out_Value <= 0;
        CC_Temp_Out_Value <= 0;
        Temp_Result[0] <= 0;
        Temp_Result[1] <= 0;
        Temp_Result[2] <= 0;
        Temp_Result[3] <= 0;
        Temp_Result[4] <= 0;
    end 
    else if(current_state == PERM) begin
        if ({MatchTarget[0],MatchTarget[1]}=={match_out[0],match_out[1]}) begin
            if(Temp_Out_Value < sum)begin
                Temp_Out_Value <= sum;
                CC_Temp_Out_Value <= CC_sum;
                Temp_Result[0] <= Guess[0];
                Temp_Result[1] <= Guess[1];
                Temp_Result[2] <= Guess[2];
                Temp_Result[3] <= Guess[3];
                Temp_Result[4] <= Guess[4];
            end 
            else if(Temp_Out_Value == sum)begin
                if(CC_Temp_Out_Value < CC_sum)begin
                    Temp_Out_Value <= sum;
                    CC_Temp_Out_Value <= CC_sum;
                    Temp_Result[0] <= Guess[0];
                    Temp_Result[1] <= Guess[1];
                    Temp_Result[2] <= Guess[2];
                    Temp_Result[3] <= Guess[3];
                    Temp_Result[4] <= Guess[4];
                end
                else if(CC_Temp_Out_Value == CC_sum)begin
                    if({Temp_Result[0], Temp_Result[1], Temp_Result[2], Temp_Result[3], Temp_Result[4]} > 
                       {Guess[0], Guess[1], Guess[2], Guess[3], Guess[4]})begin
                        Temp_Out_Value <= sum;
                        CC_Temp_Out_Value <= CC_sum;
                        Temp_Result[0] <= Guess[0];
                        Temp_Result[1] <= Guess[1];
                        Temp_Result[2] <= Guess[2];
                        Temp_Result[3] <= Guess[3];
                        Temp_Result[4] <= Guess[4];
                    end
                end
                
            end 
        end
        
    end 
    else begin
        Temp_Result[0] <= Temp_Result[0];
        Temp_Result[1] <= Temp_Result[1];
        Temp_Result[2] <= Temp_Result[2];
        Temp_Result[3] <= Temp_Result[3];
        Temp_Result[4] <= Temp_Result[4];
        Temp_Out_Value <= Temp_Out_Value;
        CC_Temp_Out_Value <= CC_Temp_Out_Value;
    end
end

// ===============================================================
// ASSIGN POSITION
// ===============================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) {p0, p1, p2, p3, p4} <= 15'd0;
    else if(current_state == COMB) begin
        case (MatchTarget[0]+MatchTarget[1])
            2: begin
                case (counter_comb)
                    0:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd1, 3'd5, 3'd6, 3'd7};
                    1:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd2, 3'd5, 3'd6, 3'd7};
                    2:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd3, 3'd5, 3'd6, 3'd7};
                    3:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd4, 3'd5, 3'd6, 3'd7};
                    4:       {p0, p1, p2, p3, p4} <= {3'd1, 3'd2, 3'd5, 3'd6, 3'd7};
                    5:       {p0, p1, p2, p3, p4} <= {3'd1, 3'd3, 3'd5, 3'd6, 3'd7};
                    6:       {p0, p1, p2, p3, p4} <= {3'd1, 3'd4, 3'd5, 3'd6, 3'd7};
                    7:       {p0, p1, p2, p3, p4} <= {3'd2, 3'd3, 3'd5, 3'd6, 3'd7};
                    8:       {p0, p1, p2, p3, p4} <= {3'd2, 3'd4, 3'd5, 3'd6, 3'd7};
                    default: {p0, p1, p2, p3, p4} <= {3'd3, 3'd4, 3'd5, 3'd6, 3'd7};
                endcase
            end
            3: begin
                case (counter_comb)
                    0:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd1, 3'd2, 3'd5, 3'd6};
                    1:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd1, 3'd3, 3'd5, 3'd6};
                    2:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd1, 3'd4, 3'd5, 3'd6};
                    3:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd2, 3'd3, 3'd5, 3'd6};
                    4:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd2, 3'd4, 3'd5, 3'd6};
                    5:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd3, 3'd4, 3'd5, 3'd6};
                    6:       {p0, p1, p2, p3, p4} <= {3'd1, 3'd2, 3'd3, 3'd5, 3'd6};
                    7:       {p0, p1, p2, p3, p4} <= {3'd1, 3'd2, 3'd4, 3'd5, 3'd6};
                    8:       {p0, p1, p2, p3, p4} <= {3'd1, 3'd3, 3'd4, 3'd5, 3'd6};
                    default: {p0, p1, p2, p3, p4} <= {3'd2, 3'd3, 3'd4, 3'd5, 3'd6};
                endcase
            end
            4: begin
                case (counter_comb)
                    0:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd1, 3'd2, 3'd3, 3'd5};
                    1:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd1, 3'd2, 3'd4, 3'd5};
                    2:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd1, 3'd3, 3'd4, 3'd5};
                    3:       {p0, p1, p2, p3, p4} <= {3'd0, 3'd2, 3'd3, 3'd4, 3'd5};
                    default: {p0, p1, p2, p3, p4} <= {3'd1, 3'd2, 3'd3, 3'd4, 3'd5};
                endcase
            end
            5: begin
                {p0, p1, p2, p3, p4} <= {3'd0, 3'd1, 3'd2, 3'd3, 3'd4};
            end
            // default: 
        endcase
    end
    else if(current_state == PERM)begin
        if(counter_perm2 == 2'd3 && counter_perm1 == 3'd5)      {p0, p1, p2, p3, p4} <= {p4, p1, p2, p3, p0};
        else if(counter_perm1 == 3'd5 && counter_perm2 == 2'd2) {p0, p1, p2, p3, p4} <= {p0, p3, p2, p1, p4};
        else if(counter_perm1 == 3'd5)                          {p0, p1, p2, p3, p4} <= {p0, p2, p1, p3, p4};
        else if(counter_perm1[0] == 1'b0)                       {p0, p1, p2, p3, p4} <= {p0, p1, p2, p4, p3};
        else                                                    {p0, p1, p2, p3, p4} <= {p0, p1, p4, p3, p2};//if(counter_perm1[0] == 1'b1)
    end
    else {p0, p1, p2, p3, p4} <= {p0, p1, p2, p3, p4} ;
end

// ===============================================================
// ASSIGN GUESS
// ===============================================================
always @(*) begin
    case (p0)
        0: Guess[0] = Keyboard[0];
        1: Guess[0] = Keyboard[1];
        2: Guess[0] = Keyboard[2];
        3: Guess[0] = Keyboard[3];
        4: Guess[0] = Keyboard[4];
        5: Guess[0] = Keyboard[5];
        6: Guess[0] = Keyboard[6];
        default:  Guess[0] = Keyboard[7];
    endcase
end

always @(*) begin
    case (p1)
        0: Guess[1] = Keyboard[0];
        1: Guess[1] = Keyboard[1];
        2: Guess[1] = Keyboard[2];
        3: Guess[1] = Keyboard[3];
        4: Guess[1] = Keyboard[4];
        5: Guess[1] = Keyboard[5];
        6: Guess[1] = Keyboard[6];
        default:  Guess[1] = Keyboard[7];
    endcase
end

always @(*) begin
    case (p2)
        0: Guess[2] = Keyboard[0];
        1: Guess[2] = Keyboard[1];
        2: Guess[2] = Keyboard[2];
        3: Guess[2] = Keyboard[3];
        4: Guess[2] = Keyboard[4];
        5: Guess[2] = Keyboard[5];
        6: Guess[2] = Keyboard[6];
        default:  Guess[2] = Keyboard[7];
    endcase
end

always @(*) begin
    case (p3)
        0: Guess[3] = Keyboard[0];
        1: Guess[3] = Keyboard[1];
        2: Guess[3] = Keyboard[2];
        3: Guess[3] = Keyboard[3];
        4: Guess[3] = Keyboard[4];
        5: Guess[3] = Keyboard[5];
        6: Guess[3] = Keyboard[6];
        default:  Guess[3] = Keyboard[7];
    endcase
end

always @(*) begin
    case (p4)
        0: Guess[4] = Keyboard[0];
        1: Guess[4] = Keyboard[1];
        2: Guess[4] = Keyboard[2];
        3: Guess[4] = Keyboard[3];
        4: Guess[4] = Keyboard[4];
        5: Guess[4] = Keyboard[5];
        6: Guess[4] = Keyboard[6];
        default:  Guess[4] = Keyboard[7];
    endcase
end

always @(*) begin
    case (MatchTarget[0]+MatchTarget[1])
        2: out_trigger = (counter_comb == 5'd10 && perm_trigger)? 1:0;
        3: out_trigger = (counter_comb == 5'd10 && perm_trigger)? 1:0;
        4: out_trigger = (counter_comb == 5'd5 && perm_trigger)? 1:0; 
        default: out_trigger = (counter_comb == 5'd1 && perm_trigger)? 1:0;
    endcase
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
            IDLE: next_state = (!in_valid)? IDLE : LOAD;
            LOAD: next_state = (in_valid)? LOAD : SORT; 
            SORT: next_state = (counter==6)? COMB : SORT;
            COMB: next_state = PERM;
            PERM: begin
                if(out_trigger) next_state = OUT;
                else if(perm_trigger) next_state = COMB;
                else next_state = PERM;
            end
            OUT : next_state = (counter != 4)? OUT : IDLE;
            default : next_state = current_state; 
        endcase
    end
end

// Output Logic

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_value <= 11'd0;
    else if(current_state == OUT) out_value <= Temp_Out_Value;
    else out_value <= 11'd0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) result <= 5'b0;
    else if(current_state == OUT) begin
        case (counter)
            0: result <= Temp_Result[0];
            1: result <= Temp_Result[1];
            2: result <= Temp_Result[2];
            3: result <= Temp_Result[3];
            default: result <= Temp_Result[4];
        endcase
    end
    else result <= 5'b0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     out_valid <= 0 ;
    else if (current_state == OUT)   out_valid <= 1 ;
    else        out_valid <= 0 ;
end



endmodule

module Match(
    // Input signals
    in0, in1, in2, in3, in4,
    ans0, ans1, ans2, ans3, ans4,
    // Output signals
    outA, outB 
);

input [4:0] in0, in1, in2, in3, in4, ans0, ans1, ans2, ans3, ans4;
output reg[2:0] outA, outB;

always @(*) begin
    outA = 0;
    if(in0 == ans0) outA = outA + 1;
    if(in1 == ans1) outA = outA + 1;
    if(in2 == ans2) outA = outA + 1;
    if(in3 == ans3) outA = outA + 1;
    if(in4 == ans4) outA = outA + 1;
end

always @(*) begin
    outB = 0;
    if(in0 == ans1 || in0 == ans2 || in0 == ans3 || in0 == ans4) outB = outB + 1;
    if(in1 == ans0 || in1 == ans2 || in1 == ans3 || in1 == ans4) outB = outB + 1;
    if(in2 == ans0 || in2 == ans1 || in2 == ans3 || in2 == ans4) outB = outB + 1;
    if(in3 == ans0 || in3 == ans1 || in3 == ans2 || in3 == ans4) outB = outB + 1;
    if(in4 == ans0 || in4 == ans1 || in4 == ans2 || in4 == ans3) outB = outB + 1;
end

endmodule