input x1, x2, x3, x4;
reg a, b, c;
assign a = b + c;

always @(*)begin
    if(...)begin
        b = x1;
        c = x2;
    end 
    else begin
        b = x3;
        c = x4;
    end
end

module HD(
	code_word1,
	code_word2,
	out_n
);
input  [6:0]code_word1, code_word2;
output reg signed[5:0] out_n;

reg temp1;
reg temp2;
reg temp3;
reg temp4;
reg temp5;
reg temp6;
reg code_word1_errorbit;
reg code_word2_errorbit;
reg signed [3:0]c1;
reg signed [3:0]c2;

always @(*) begin
	temp1 = code_word1[6] ^ code_word1[3] ^ code_word1[2] ^ code_word1[1];
	temp2 = code_word1[5] ^ code_word1[3] ^ code_word1[2] ^ code_word1[0];
	temp3 = code_word1[4] ^ code_word1[3] ^ code_word1[1] ^ code_word1[0];
	temp4 = code_word2[6] ^ code_word2[3] ^ code_word2[2] ^ code_word2[1];
	temp5 = code_word2[5] ^ code_word2[3] ^ code_word2[2] ^ code_word2[0];
	temp6 = code_word2[4] ^ code_word2[3] ^ code_word2[1] ^ code_word2[0];
end

always @(*) begin
	case ({temp1,temp2,temp3})
		3'b101: begin
			c1 = {code_word1[3:2],~code_word1[1],code_word1[0]};
			code_word1_errorbit = code_word1[1];
		end
		3'b110: begin
			c1 = {code_word1[3],~code_word1[2],code_word1[1:0]};
			code_word1_errorbit = code_word1[2];
		end
		3'b011: begin
			c1 = {code_word1[3:1],~code_word1[0]};
			code_word1_errorbit = code_word1[0];
		end
		3'b100: begin
			c1 = {code_word1[3:0]};
			code_word1_errorbit = code_word1[6];
		end
		3'b010: begin
			c1 = {code_word1[3:0]};
			code_word1_errorbit = code_word1[5];
		end
		3'b001: begin
			c1 = {code_word1[3:0]};
			code_word1_errorbit = code_word1[4];
		end
		default: begin
			c1 = {~code_word1[3],code_word1[2:0]};
			code_word1_errorbit = code_word1[3];
		end
	endcase
end

always @(*) begin
	case ({temp4,temp5,temp6})
		3'b101: begin
			c2 = {code_word2[3:2],~code_word2[1],code_word2[0]};
			code_word2_errorbit = code_word2[1];
		end
		3'b110: begin
			c2 = {code_word2[3],~code_word2[2],code_word2[1:0]};
			code_word2_errorbit = code_word2[2];
		end
		3'b011: begin
			c2 = {code_word2[3:1],~code_word2[0]};
			code_word2_errorbit = code_word2[0];
		end
		3'b100: begin
			c2 = {code_word2[3:0]};
			code_word2_errorbit = code_word2[6];
		end
		3'b010: begin
			c2 = {code_word2[3:0]};
			code_word2_errorbit = code_word2[5];
		end
		3'b001: begin
			c2 = {code_word2[3:0]};
			code_word2_errorbit = code_word2[4];
		end
		default: begin
			c2 = {~code_word2[3],code_word2[2:0]};
			code_word2_errorbit = code_word2[3];
		end
	endcase
end

always @(*) begin
	case ({code_word1_errorbit,code_word2_errorbit})
		2'b00: begin
			out_n = 2*c1 + c2 ;
		end
		2'b01: begin
			out_n = 2*c1 - c2 ;
		end
		2'b10: begin
			out_n = c1 - 2*c2 ;
		end
		default: begin
			out_n = c1 + 2*c2 ;
		end
	endcase	
end
endmodule
