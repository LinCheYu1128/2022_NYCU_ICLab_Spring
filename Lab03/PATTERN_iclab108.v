`ifdef RTL
    `define CYCLE_TIME 15.0
`endif
`ifdef GATE
    `define CYCLE_TIME 15.0
`endif

module PATTERN(
    // Output signals
	clk,
    rst_n,
	in_valid1,
	in_valid2,
	in,
	in_data,
    // Input signals
    out_valid1,
	out_valid2,
    out,
	out_data
);

output reg clk, rst_n, in_valid1, in_valid2;
output reg [1:0] in;
output reg [8:0] in_data;
input out_valid1, out_valid2;
input [2:0] out;
input [8:0] out_data;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
integer input_file;
integer total_cycles, cycles;
integer PATNUM = 500;
integer patcount;
integer a, b, c, d, e, f, g;
integer i, j;
integer gap;
integer hostage_num, hostage_counter;
integer seed;
integer trap_counter;
integer golden_step;

// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [1:0] maze[0:18][0:18];
reg signed [8:0] passward[0:3];
reg signed [8:0] golden_result[0:3];
reg signed [8:0] temp;
reg [3:0] tempA;
reg [3:0] tempB;
reg sign_temp;
reg signed [8:0] max, min;
reg [3:0] XS3_1;
reg [3:0] XS3_2;
reg [9:0] hostage_pos [0:3];
reg signed [8:0]out_reg;
// ===============================================================
// Clock
// ===============================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

// ===============================================================
// Initial
// ===============================================================
initial begin
	rst_n     = 1'b1;
	in        = 2'bx;
	in_valid1 = 1'b0;
	in_valid2 = 1'b0;
	total_cycles = 0;
	force clk = 0;
	reset_task;

	input_file = $fopen("../00_TESTBED/input.txt","r");
	@(negedge clk);
	seed = 1;
	// a = $fscanf(input_file, "%d", PATNUM);
	for (patcount = 0; patcount < PATNUM; patcount = patcount + 1) begin
		input_data;
		calculate_result;
		wait_out_valid;
		check_ans;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end 

// ===============================================================
// TASK
// ===============================================================
task reset_task ; begin
	#(10); rst_n = 0;
	#(10);
	if((out_valid1 !== 0) || (out_valid2 !== 0) || (out !== 0) || (out_data !== 0)) begin
		$display ("********************************************************************************************************************************************");
		$display ("*                                                                       SPEC 3 IS FAIL!                                                    *");
		$display ("*                                                 Output signal should be 0 after initial RESET at %8t                                     *",$time);
		$display ("********************************************************************************************************************************************");
		#(100);
	    $finish ;
	end
	#(10); rst_n = 1 ;
	#(3.0); release clk;
end endtask

task input_data; begin
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);
	for(j = 0; j < 19; j=j+1)begin
        for(i = 0; i < 19; i=i+1)begin
            maze[j][i] = 0;
		end
    end
	hostage_num = 0;
	in_valid1 = 1'b1;
	for(j = 1; j < 18; j=j+1)begin
        for(i = 1; i < 18; i=i+1)begin
			if(out_valid1 == 1 || out_valid2 == 1) begin
				$display ("********************************************************************************************************************************************");
				$display ("*                                                                    SPEC 5 IS FAIL!                                                       *");
				$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
				$display ("*                                        out_valid1 or out_valid2 should not be high when in_valid1 is high                                *");
				$display ("********************************************************************************************************************************************");
				repeat(2)@(negedge clk);
				$finish;
			end
			a = $fscanf(input_file, "%d", in);
			maze[j][i] = in;
			if(maze[j][i] == 3) begin
				hostage_pos[hostage_num] = {i[4:0],j[4:0]};
				hostage_num = hostage_num + 1;
			end 
			@(negedge clk);
        end
    end
	in_valid1 = 1'b0;
	in = 'dx;
end endtask

task calculate_result; begin
	// for(j = 0; j < 19; j=j+1)begin
    //     // for(i = 0; i < 19; i=i+1)begin
	// 		$display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",
	// 		maze[j][0],maze[j][1],maze[j][2],maze[j][3],maze[j][4],maze[j][5],maze[j][6],maze[j][7],maze[j][8],maze[j][9],
	// 		maze[j][10],maze[j][11],maze[j][12],maze[j][13],maze[j][14],maze[j][15],maze[j][16],maze[j][17],maze[j][18]);
    //     // end
    // end
	passward[0] = 'dx;
	passward[1] = 'dx;
	passward[2] = 'dx;
	passward[3] = 'dx;
	golden_result[0] = 'dx;
	golden_result[1] = 'dx;
	golden_result[2] = 'dx;
	golden_result[3] = 'dx;
	// $display("number of hostage = %01d", hostage_num);
	if(hostage_num >= 1)begin
		
		for(i = 0; i < hostage_num; i = i + 1)begin
			if(hostage_num %2 == 0)begin
				tempA = $random(seed)%'d10 + 'b011;
				tempB = $random(seed)%'d10 + 'b011;
				sign_temp = $random(seed)%'d2;
				passward[i] = {sign_temp,tempA,tempB};
			end
			else passward[i] = $random(seed)%'d511;
			golden_result[i] = passward[i];
			// $display("passward = %d", passward[i]);
			// $display("passward = %b", passward[i]);
		end
		// passward[0] = -188;
		// passward[1] = -56;
		// passward[2] = 151;
		// passward[3] = 58;
		// golden_result[0] = -188;
		// golden_result[1] = -56;
		// golden_result[2] = 151;
		// golden_result[3] = 58;
		if(hostage_num > 1)begin
			for(i = 0; i < hostage_num; i = i + 1)begin
				for(j = i+1; j < hostage_num; j = j + 1)begin
					if(golden_result[i] < golden_result[j])begin
						temp = golden_result[i];
						golden_result[i] = golden_result[j];
						golden_result[j] = temp;
					end
				end
			end
		end
		
		// for(i = 0; i < hostage_num; i = i + 1)begin
		// 	$display("sorted passward = %d", golden_result[i]);
		// end
	end

	if(hostage_num == 2 || hostage_num == 4)begin
		for(i = 0; i < hostage_num; i = i + 1)begin
			XS3_1 = golden_result[i][7:4];
			XS3_2 = golden_result[i][3:0];
			XS3_1 = XS3_1 - 4'b0011;
			XS3_2 = XS3_2 - 4'b0011;
			temp = (golden_result[i][8]) ? -(XS3_1*10+XS3_2):(XS3_1*10+XS3_2);
			golden_result[i] = temp;
			// $display("XS-3 passward = %d", golden_result[i]);
		end
	end
	if(hostage_num > 1)begin
		min = golden_result[0];
		max = golden_result[0];
		for(i = 1; i < hostage_num; i = i + 1)begin
			if(golden_result[i] < min) min = golden_result[i];
			if(golden_result[i] > max) max = golden_result[i];
		end
		// $display("min = %d", min);
		// $display("max = %d", max);
		temp = (min + max)/2;
		// $display("half = %d", temp);
		for(i = 0; i < hostage_num; i = i + 1)begin
			golden_result[i] = golden_result[i] - temp;
			// $display("sub passward = %d", golden_result[i]);
		end
	end

	if(hostage_num > 2)begin
		// $display("cum passward = %d", golden_result[0]);
		for(i = 1; i < hostage_num; i = i + 1)begin
			golden_result[i] = (golden_result[i-1]*2 + golden_result[i])/3;
			// $display("cum passward = %d", golden_result[i]);
		end
	end
end endtask

task wait_out_valid; begin
	cycles = 0;
	i = 1;
	j = 1;
	hostage_counter = 0;
	while(out_valid1 === 0)begin
		cycles = cycles + 1;
		if(cycles == 3000) begin
			$display ("********************************************************************************************************************************************");
			$display ("*                                                                    SPEC 6 IS FAIL!                                                       *");
			$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
			$display ("*                                                    The execution latency are over  3000 cycles                                           *");
			$display ("********************************************************************************************************************************************");
			repeat(2)@(negedge clk);
			$finish;
		end
		if(out_valid2 == 1)begin
			if(maze[j][i] == 2'd2 && trap_counter == 1 && out !== 3'd4) begin
				$display ("********************************************************************************************************************************************");
				$display ("*                                                                    SPEC 7 IS FAIL!                                                       *");
				$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
				$display ("*                                                             Out should be correct.(trap)                                                 *");
				$display ("********************************************************************************************************************************************");
				repeat(2)@(negedge clk);
				$finish;
			end
			else if(out == 3'd0) begin //right
				i = i + 1;
				j = j;
			end
			else if(out == 3'd1) begin // Down
				i = i;
				j = j + 1;
			end
			else if (out == 3'd2) begin // Left
				i = i - 1;
				j = j;
			end
			else if (out == 3'd3) begin // up
				i = i;
				j = j - 1;
			end
			else if (out == 3'd4)begin  // stall //
				i = i;
				j = j;
			end
			else begin
				$display ("********************************************************************************************************************************************");
				$display ("*                                                                    SPEC 7 IS FAIL!                                                       *");
				$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
				$display ("*                                                             Out should be correct.(out should be 0~4)                                    *");
				$display ("********************************************************************************************************************************************");
				repeat(2)@(negedge clk);
				$finish;
			end
			if(maze[j][i] == 2'd0)begin
				$display ("********************************************************************************************************************************************");
				$display ("*                                                                    SPEC 7 IS FAIL!                                                       *");
				$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
				$display ("*                                                             Out should be correct.(wall)                                                 *");
				$display ("********************************************************************************************************************************************");
				repeat(2)@(negedge clk);
				$finish;
			end
			else if(maze[j][i] == 2'd2)begin
				trap_counter = trap_counter + 1;
			end
			else if(maze[j][i] == 2'd3) begin
				trap_counter = 0;
				gap = $urandom_range(2,4);
				repeat(gap) @(negedge clk);
				in_valid2 = 1;
				if(out_valid2 == 0) begin
					if( {i[4:0],j[4:0]} != hostage_pos[0] && 
					    {i[4:0],j[4:0]} != hostage_pos[1] &&
					    {i[4:0],j[4:0]} != hostage_pos[2] &&
					    {i[4:0],j[4:0]} != hostage_pos[3] ) begin
							$display ("********************************************************************************************************************************************");
							$display ("*                                                                    SPEC 8 IS FAIL!                                                       *");
							$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
							$display ("*                                                   pull down the out_valid2 should be in hostage pos                                      *");
							$display ("********************************************************************************************************************************************");
							repeat(2)@(negedge clk);
							$finish;	
						end
				end  
				if(out_valid2 == 1 || out_valid1 == 1) begin
					$display ("********************************************************************************************************************************************");
					$display ("*                                                                    SPEC 5 IS FAIL!                                                       *");
					$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
					$display ("*                                        out_valid1 or out_valid2 should not be high when in_valid2 is high                                *");
					$display ("********************************************************************************************************************************************");
					repeat(2)@(negedge clk);
					$finish;
				end
				in_data = passward[hostage_counter];
				// $display("hostage %1d, passward = %d", hostage_counter ,passward[hostage_counter]);
				hostage_counter = hostage_counter + 1;
			end
			else begin
				trap_counter = 0;
			end
		end
		else if (out_valid2==0 && out != 0) begin
			$display ("********************************************************************************************************************************************");
			$display ("*                                                                    SPEC 4 IS FAIL!                                                       *");
			$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
			$display ("*                                                 out should be reset after out_valid2 is pull down                                        *");
			$display ("********************************************************************************************************************************************");
			repeat(2)@(negedge clk);
			$finish;
		end
	@(negedge clk);
	in_valid2 = 0;
	in_data = 'dx;
	end
	if(i!=17 || j!=17)begin
		$display ("********************************************************************************************************************************************");
		$display ("*                                                                    SPEC 8 IS FAIL!                                                       *");
		$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
		$display ("*                                                        pull down the out_valid2 should be in exit                                        *");
		$display ("********************************************************************************************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end
	total_cycles = total_cycles + cycles;
	
end endtask

task check_ans; begin
	// for(i = 0; i < hostage_num; i = i + 1)begin
	// 	$display("golden_result = %d", golden_result[i]);
	// end
	// if(hostage_num == 0) $display("golden_result = %d", 9'd0);
	golden_step = 0;
	while (out_valid1 === 1) begin
		if(out_valid2 == 1) begin
			$display ("********************************************************************************************************************************************");
			$display ("*                                                                    SPEC 5 IS FAIL!                                                       *");
			$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
			$display ("*                                            out_valid1 and out_valid2 should not be high at the same time                                 *");
			$display ("********************************************************************************************************************************************");
			repeat(2)@(negedge clk);
			$finish;
		end
		if((hostage_num > 0 && golden_step+1 > hostage_num) || (golden_step == 1 && hostage_num == 0))begin
			$display ("********************************************************************************************************************************************");
			$display ("*                                                                    SPEC 9 IS FAIL!                                                       *");
			$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
			$display ("*                                                        out_valid1 should maintain %d clock cycles                                        *", hostage_num);
			$display ("********************************************************************************************************************************************");
			repeat(2)@(negedge clk);
			$finish;
		end
		if((hostage_num > 0 && out_data !== golden_result[golden_step]) || (hostage_num == 0 && out_data !== 9'b0))begin
			out_reg = out_data;
			$display ("********************************************************************************************************************************************");
			$display ("*                                                                   SPEC 10 IS FAIL!                                                       *");
			$display ("*                                                                  Pattern NO.%03d                                                         *", patcount);
			$display ("*                                                             Your output -> result: %d                                                    *", out_reg);
			$display ("*                                                           Golden output -> result: %01d, step: %01d                                          *", (hostage_num == 0)?'d0:golden_result[golden_step], golden_step+1);
			$display ("********************************************************************************************************************************************");
			@(negedge clk);
			$finish;
		end
		golden_step = golden_step + 1;
		@(negedge clk);
	end
	if((hostage_num > 0 && golden_step != hostage_num) || (golden_step != 1 && hostage_num == 0))begin
		$display ("********************************************************************************************************************************************");
		$display ("*                                                                    SPEC 9 IS FAIL!                                                       *");
		$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
		$display ("*                                                        out_valid1 should maintain %d clock cycles                                        *", hostage_num);
		$display ("********************************************************************************************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end
	if(out_valid1==0)begin
		if(out_data!==0)begin
			$display ("********************************************************************************************************************************************");
			$display ("*                                                                    SPEC 11 IS FAIL!                                                      *");
			$display ("*                                                                  Pattern NO.%03d                                                          *", patcount);
			$display ("*                                                   out_data should be reset after out_valid1 is pull down                                 *");
			$display ("********************************************************************************************************************************************");
			repeat(2)@(negedge clk);
			$finish;
		end
	end
end endtask
task YOU_PASS_task; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						             ");
	$display ("                                           You have passed all patterns!          						             ");
	$display ("                                           Your execution cycles = %5d cycles   						                 ", total_cycles);
	$display ("                                           Your clock period = %.1f ns        					                     ", `CYCLE_TIME);
	$display ("                                           Your total latency = %.1f ns         						                 ", total_cycles*`CYCLE_TIME);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask
endmodule