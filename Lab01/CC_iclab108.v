module CC(
	in_n0,
	in_n1, 
	in_n2, 
	in_n3, 
    in_n4, 
	in_n5, 
	opt,
    equ,
	out_n
);
input [3:0]in_n0;
input [3:0]in_n1;
input [3:0]in_n2;
input [3:0]in_n3;
input [3:0]in_n4;
input [3:0]in_n5;
input [2:0] opt;
input equ;
output [9:0] out_n;
//==================================================================
// reg & wire
//==================================================================
reg signed [9:0] out_n;

reg signed [4:0] number [0:5];
reg signed [4:0] temp;
integer i, j;

always @(*) begin
    if(opt[0])begin // signed value (-8 ~ 7)
		number[0] = {in_n0[3], in_n0};
		number[1] = {in_n1[3], in_n1};
		number[2] = {in_n2[3], in_n2};
		number[3] = {in_n3[3], in_n3};
		number[4] = {in_n4[3], in_n4};
		number[5] = {in_n5[3], in_n5};		
	end
	else begin      // unsigned value 0 ~ 15
		number[0] = {1'b0, in_n0};
		number[1] = {1'b0, in_n1};
		number[2] = {1'b0, in_n2};
		number[3] = {1'b0, in_n3};
		number[4] = {1'b0, in_n4};
		number[5] = {1'b0, in_n5};
	end
    // sort
    // for(i=0; i<5; i=i+1)begin
    //     for(j=i+1; j<6; j=j+1)begin
	// 		compA = number[i];
    //         compB = number[j];
    //         if(compA > compB)begin
    //             number[i] = compB;
    //             number[j] = compA;
    //         end
    //     end
    // end
    if(number[0] > number[1]) begin
        temp = number[0];
        number[0] = number[1];
        number[1] = temp;
    end
    if(number[1] > number[2]) begin
        temp = number[1];
        number[1] = number[2];
        number[2] = temp;
    end
    if(number[0] > number[1]) begin
        temp = number[0];
        number[0] = number[1];
        number[1] = temp;
    end

    if(number[3] > number[4]) begin
        temp = number[3];
        number[3] = number[4];
        number[4] = temp;
    end
    if(number[4] > number[5]) begin
        temp = number[4];
        number[4] = number[5];
        number[5] = temp;
    end
    if(number[3] > number[4]) begin
        temp = number[3];
        number[3] = number[4];
        number[4] = temp;
    end

    if(number[0] > number[3]) begin
        temp = number[0];
        number[0] = number[3];
        number[3] = temp;
    end
    if(number[1] > number[4]) begin
        temp = number[1];
        number[1] = number[4];
        number[4] = temp;
    end
    if(number[2] > number[5]) begin
        temp = number[2];
        number[2] = number[5];
        number[5] = temp;
    end

    if(number[1] > number[3]) begin
        temp = number[1];
        number[1] = number[3];
        number[3] = temp;
    end
    if(number[2] > number[4]) begin
        temp = number[2];
        number[2] = number[4];
        number[4] = temp;
    end

    if(number[2] > number[3]) begin
        temp = number[2];
        number[2] = number[3];
        number[3] = temp;
    end

    if(opt[1])begin
        temp = number[0];
        number[0] = number[5];
        number[5] = temp;
        temp = number[1];
        number[1] = number[4];
        number[4] = temp;
        temp = number[2];
        number[2] = number[3];
        number[3] = temp;
    end
    // cumulate
    // $display("CC n[0]=%d n[1]=%d n[2]=%d n[3]=%d n[4]=%d n[5]=%d",number[0],number[1],number[2],number[3],number[4],number[5]);
    if(opt[2])begin
        number[1] = (number[0]*2 + number[1])/3;
        number[2] = (number[1]*2 + number[2])/3;
        number[3] = (number[2]*2 + number[3])/3;
        number[4] = (number[3]*2 + number[4])/3;
        number[5] = (number[4]*2 + number[5])/3;
    end
    else begin
        number[1] = number[1] + ~number[0] + 1;
        // number[2] = number[2] + ~number[0] + 1;
        number[3] = number[3] + ~number[0] + 1;
        number[4] = number[4] + ~number[0] + 1;
        number[5] = number[5] + ~number[0] + 1;
        number[0] = 0;
    end
    number[2] = number[1] - number[0];
    // $display("CC n[0]=%d n[1]=%d n[2]=%d n[3]=%d n[4]=%d n[5]=%d",number[0],number[1],number[2],number[3],number[4],number[5]);
end

always @(*) begin
	if(!equ)begin
		out_n = ((number[3] + number[4]*4)*number[5])/3;
	end
	else begin
		// out_n = number[5]* number[1] - number[5]*number[0];
        out_n = number[5]*number[2];
		if(out_n[9])begin
			out_n = ~out_n + 1;
		end 
	end

end

endmodule
