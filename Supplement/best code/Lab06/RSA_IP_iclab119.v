//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_IP.v
//   Module Name : RSA_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module RSA_IP #(parameter WIDTH = 3) (
    // Input signals
    IN_P, IN_Q, IN_E,
    // Output signals
    OUT_N, OUT_D
);

// ===============================================================
// Declaration
// ===============================================================
    input  [WIDTH - 1: 0]   IN_P, IN_Q;
    input  [WIDTH * 2 - 1: 0] IN_E;
    output [WIDTH * 2 - 1: 0] OUT_N, OUT_D;

// ===============================================================
// Soft IP DESIGN
// ===============================================================
    localparam N_LEVEL = WIDTH * 2;
    reg signed [WIDTH * 2 - 1: 0] tempD;

    genvar level_idx, node_idx, level_idx2;
    generate 
        for (level_idx = 1 ; level_idx <= N_LEVEL; level_idx = level_idx + 1) begin: gen_level
            if (level_idx == 1) begin: if_lv_1
                wire [WIDTH - 1: 0] p_minus_1, q_minus_1, p, q;
                wire [WIDTH * 2 - 1: 0] e;
                assign p = IN_P;
                assign q = IN_Q;
                assign e = IN_E;
                assign p_minus_1 = p - 'b1;
                assign q_minus_1 = q - 'b1;
            end
            else if (level_idx == 2) begin: if_lv_2
                wire [WIDTH * 2 - 1: 0] phi;
                wire [WIDTH * 2 - 1: 0] pq;
                assign pq = gen_level[1].if_lv_1.p * gen_level[1].if_lv_1.q;
                assign phi = gen_level[1].if_lv_1.p_minus_1 * gen_level[1].if_lv_1.q_minus_1;
            end
            else if (level_idx == 3) begin: if_lv_3
                wire [WIDTH + 1: 0] r, q;
                assign q = gen_level[2].if_lv_2.phi / gen_level[1].if_lv_1.e;
                assign r = gen_level[2].if_lv_2.phi - q * gen_level[1].if_lv_1.e;

                wire signed [WIDTH + 2: 0] t;
                assign t = -q;
            end
            else if (level_idx == 4) begin: if_lv_4
                wire [WIDTH + 1: 0] r, q;
                assign q = gen_level[1].if_lv_1.e / gen_level[3].if_lv_3.r;
                assign r = gen_level[1].if_lv_1.e - q * gen_level[3].if_lv_3.r;

                wire signed [WIDTH + 2: 0] t;
                assign t = 1 - gen_level[3].if_lv_3.t * q;
            end
            else if (level_idx == 5) begin: if_lv_5
                wire [WIDTH + 1: 0] r, q;
                assign q = gen_level[3].if_lv_3.r / gen_level[4].if_lv_4.r;
                assign r = gen_level[3].if_lv_3.r - q * gen_level[4].if_lv_4.r;

                wire signed [WIDTH + 2: 0] t;
                assign t = gen_level[3].if_lv_3.t - gen_level[4].if_lv_4.t * q;
            end
            else if (level_idx == 6) begin: if_lv_6
                wire [WIDTH + 1: 0] r, q;
                assign q = gen_level[4].if_lv_4.r / gen_level[5].if_lv_5.r;
                assign r = gen_level[4].if_lv_4.r - q * gen_level[5].if_lv_5.r;

                wire signed [WIDTH + 2: 0] t;
                assign t = gen_level[4].if_lv_4.t - gen_level[5].if_lv_5.t * q;
            end
            else if (level_idx == 7) begin: if_lv_7
                wire [WIDTH + 1: 0] r, q;
                assign q = gen_level[5].if_lv_5.r / gen_level[6].if_lv_6.r;
                assign r = gen_level[5].if_lv_5.r - q * gen_level[6].if_lv_6.r;

                wire signed [WIDTH + 2: 0] t;
                assign t = gen_level[5].if_lv_5.t - gen_level[6].if_lv_6.t * q;
            end
            else if (level_idx == 8) begin: if_lv_8
                wire [WIDTH + 1: 0] r, q;
                assign q = gen_level[6].if_lv_6.r / gen_level[7].if_lv_7.r;
                assign r = gen_level[6].if_lv_6.r - q * gen_level[7].if_lv_7.r;

                wire signed [WIDTH + 2: 0] t;
                assign t = gen_level[6].if_lv_6.t - gen_level[7].if_lv_7.t * q;
            end
        end
    endgenerate

    generate
        for (level_idx2 = WIDTH; level_idx2 != WIDTH + 1; level_idx2 = level_idx2 + 1) begin
            if (level_idx2 == 3) begin
                always @(*) begin
                    if (gen_level[3].if_lv_3.r == 1)
                        tempD = gen_level[3].if_lv_3.t;
                    else if (gen_level[4].if_lv_4.r == 1)
                        tempD = gen_level[4].if_lv_4.t;
                    else if (gen_level[5].if_lv_5.r == 1)
                        tempD = gen_level[5].if_lv_5.t;
                    else
                        tempD = 0;
                end
            end
            else if (level_idx2 == 4) begin
                always @(*) begin
                    if (gen_level[3].if_lv_3.r == 1)
                        tempD = gen_level[3].if_lv_3.t;
                    else if (gen_level[4].if_lv_4.r == 1)
                        tempD = gen_level[4].if_lv_4.t;
                    else if (gen_level[5].if_lv_5.r == 1)
                        tempD = gen_level[5].if_lv_5.t;
                    else if (gen_level[6].if_lv_6.r == 1)
                        tempD = gen_level[6].if_lv_6.t;
                    else if (gen_level[7].if_lv_7.r == 1)
                        tempD = gen_level[7].if_lv_7.t;
                    else if (gen_level[8].if_lv_8.r == 1)
                        tempD = gen_level[8].if_lv_8.t;
                    else
                        tempD = 0;
                end
            end
        end
    endgenerate

    assign OUT_N = gen_level[2].if_lv_2.pq;
    assign OUT_D = (tempD[WIDTH * 2 - 2])? tempD + gen_level[2].if_lv_2.phi: tempD;

endmodule