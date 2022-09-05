`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_PKG.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
integer seed, total_cycles, cycles, operation_cycles, PATNUM, i, j, k;
integer now_action_num;

// Lab09 demo
integer id_select;         // true id select
integer action_constrain;  // which first action should choose
integer count_action;      // count_action === 0: first action
logic [3:0]action_array [41:0];

assign action_array[0 ] =  1;
assign action_array[1 ] =  1;
assign action_array[2 ] =  2;
assign action_array[3 ] =  1;
assign action_array[4 ] =  4;
assign action_array[5 ] =  1;
assign action_array[6 ] =  6;
assign action_array[7 ] =  1;
assign action_array[8 ] =  8;
assign action_array[9 ] =  1;
assign action_array[10] = 10;
assign action_array[11] =  1;
assign action_array[12] =  2;
assign action_array[13] =  2;
assign action_array[14] =  4;
assign action_array[15] =  2;
assign action_array[16] =  6;
assign action_array[17] =  2;
assign action_array[18] =  8;
assign action_array[19] =  2;
assign action_array[20] = 10;
assign action_array[21] =  2;
assign action_array[22] =  4;
assign action_array[23] =  4;
assign action_array[24] =  6;
assign action_array[25] =  4;
assign action_array[26] =  8;
assign action_array[27] =  4;
assign action_array[28] = 10;
assign action_array[29] =  4;
assign action_array[30] =  6;
assign action_array[31] =  6;
assign action_array[32] =  8;
assign action_array[33] =  6;
assign action_array[34] = 10;
assign action_array[35] =  6;
assign action_array[36] =  8;
assign action_array[37] =  8;
assign action_array[38] = 10;
assign action_array[39] =  8;
assign action_array[40] = 10;
assign action_array[41] = 10;

integer index;
//================================================================
// wire & registers 
//================================================================
// Random
logic [13:0] deposit_money;
logic  [7:0] user_id, defender_id;
logic  [3:0] now_action, now_item, now_type;

// Check ans
logic  [1:0] user_stone;
logic  [7:0] user_hp, user_atk, user_exp;
logic  [3:0] user_berry, user_medicine, user_candy, user_bracer, user_stage, user_type;
logic [13:0] user_money;
// Buy & Sell
logic [10:0] item_price; // max: 1300
// Use item
logic  [7:0] next_user_hp, next_user_atk, max_user_hp, max_user_exp, th_user_hp, th_user_exp;
logic  bracer_effect;
// Attack
logic  [7:0] defender_hp, defender_atk, defender_exp, user_bracer_atk;
logic  [8:0] user_select_atk;                                         // max: (127+32) double = 318
logic  [3:0] defender_stage, defender_type;
logic  halve, double;
logic  [5:0] user_get_exp, defender_get_exp;                          // max: 32 / 16
logic  [7:0] next_defender_hp, next_defender_atk, max_defender_exp;
// Golden
logic        golden_com;
logic [63:0] golden_out;
logic  [3:0] golden_err;
logic  [7:0] golden_DRAM[ ((65536+256*8)-1) : (65536+0)];

//======================================
//              RANDOM
//======================================
class random_gap;
	randc int gap;
	function new(int seed); this.srandom(seed); endfunction
	//constraint limit{ gap inside {[1:5]};}
	constraint limit{ gap inside {1};}
	//constraint limit{ if (now_action == Check) gap inside {0};
	//				  else                     gap inside {1};
	//}
endclass

class random_delay;
	randc int delay;
	function new(int seed); this.srandom(seed); endfunction
	//constraint limit{ delay inside {[2:10]};}
	constraint limit{ delay inside {2};}
endclass

class random_id;
	randc logic [7:0] id;
	function new(int seed); this.srandom(seed); endfunction
	constraint limit{ id inside {[0:255]} & !(id inside {user_id});}
endclass

class random_action;
	randc logic [3:0] action;
	function new(int seed); this.srandom(seed); endfunction
	constraint limit{ 	action inside {action_array[index]};
						//if (user_money > (14'd16383 - 'd2000)) action inside {1, 6, 8, 10};
						//else if (count_action)                 action inside {1, 2, 4, 6, 8, 10};
						//else                                   action inside {action_constrain};
					}
endclass

class random_action_num;
	randc int action_num;
	function new(int seed); this.srandom(seed); endfunction
	//constraint limit{ action_num inside {[1:100]};}
	constraint limit{ action_num inside {2};}
endclass

// Buy or Sell or Use_item
class random_PKM_or_item;
	rand logic PKM_or_item;
	function new(int seed); this.srandom(seed); endfunction
	constraint limit{ 
		if (now_action == 1) PKM_or_item dist {0 := 65, 1 := 35};
		else                 PKM_or_item inside {[0:1]};
	//{ PKM_or_item dist {0 := 40, 1 := 60};}
	}
endclass

class random_PKM_type;
	randc logic[3:0] PKM_type;
	function new(int seed); this.srandom(seed); endfunction
	constraint limit{ PKM_type inside {1, 2, 4, 5, 8};}
endclass

class random_item_type;
	randc logic[3:0] item_type;
	function new(int seed); this.srandom(seed); endfunction
	//constraint limit{ item_type inside {8, 9, 12};}
	//constraint limit{ item_type inside {[1:2], 4, [9:10], 12};}
	constraint limit{ item_type inside {[1:2], 4, [8:10], 12};}
endclass

// Deposit
class random_amount_money;
	randc logic[13:0] amount_money;
	function new(int seed); this.srandom(seed); endfunction
	constraint limit{ amount_money inside {[1:14'b11111111111111 - user_money - 1]};} 
endclass

// Attack
class random_attack_id;
	randc logic [7:0] attack_id;
	function new(int seed); this.srandom(seed); endfunction
	constraint limit{ !(attack_id inside {user_id});}
endclass

// NEW CLASS
random_id            rand_id           = new(seed);
random_action_num    rand_action_num   = new(seed);
random_action        rand_action       = new(seed);

// Buy or Sell or Use_item
random_PKM_or_item   rand_PKM_or_item  = new(seed);
random_PKM_type      rand_PKM_type     = new(seed);
random_item_type     rand_item_type    = new(seed);

// Deposit
random_amount_money rand_amount_money  = new(seed);
// Attack
random_attack_id    rand_attack_id     = new(seed);

// Timing
random_gap   rand_gap   = new(seed);
random_delay rand_delay = new(seed);

//======================================
//              TASKS
//======================================

initial begin
	seed = 20000;
	PATNUM = 210;
	total_cycles = 0;

	id_select = 0;
	action_constrain = 0;
	
	reset_task;
	$readmemh(DRAM_p_r, golden_DRAM);

	for (k = 0 ; k < PATNUM ; k = k + 1) begin
		cycles = 0;	
		input_task;
		//$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %5d Num_action: %3d \033[m", k , cycles, now_action_num);
		total_cycles = total_cycles + cycles;
	end
	$finish;
end

task reset_task; begin
	inf.rst_n       = 1'b1; 
	inf.id_valid    = 1'bx;
	inf.act_valid   = 1'bx;
	inf.item_valid  = 1'bx;
	inf.type_valid  = 1'bx;
	inf.amnt_valid  = 1'bx;
	inf.D           =  'dx;

    #(15) inf.rst_n = 1'b0;
    #(15) inf.rst_n = 1'b1;
	inf.rst_n       = 1'b1; 
	inf.id_valid    = 1'b0;
	inf.act_valid   = 1'b0;
	inf.item_valid  = 1'b0;
	inf.type_valid  = 1'b0;
	inf.amnt_valid  = 1'b0;
	inf.D           =  'dx;

	user_id = 0;
	index = 0;
	now_action = 0;
	@(negedge clk);
end endtask

task get_user_dram_data; begin
	user_berry    =  golden_DRAM[65536 + (user_id) *8 + 0][7:4];
	user_medicine =  golden_DRAM[65536 + (user_id) *8 + 0][3:0];
	user_candy    =  golden_DRAM[65536 + (user_id) *8 + 1][7:4];
	user_bracer   =  golden_DRAM[65536 + (user_id) *8 + 1][3:0];
	user_stone    =  golden_DRAM[65536 + (user_id) *8 + 2][7:6];
	user_money    = {golden_DRAM[65536 + (user_id) *8 + 2][5:0], golden_DRAM[65536 + (user_id) *8 + 3]};
	user_stage    =  golden_DRAM[65536 + (user_id) *8 + 4][7:4];
	user_type     =  golden_DRAM[65536 + (user_id) *8 + 4][3:0];
	user_hp       =  golden_DRAM[65536 + (user_id) *8 + 5];
	user_atk      =  golden_DRAM[65536 + (user_id) *8 + 6];
	user_exp      =  golden_DRAM[65536 + (user_id) *8 + 7];
end endtask

task store_user_dram_data; begin
	 golden_DRAM[65536 + (user_id) *8 + 0][7:4]                                          = user_berry   ;
	 golden_DRAM[65536 + (user_id) *8 + 0][3:0]                                          = user_medicine;
	 golden_DRAM[65536 + (user_id) *8 + 1][7:4]                                          = user_candy   ;
	 golden_DRAM[65536 + (user_id) *8 + 1][3:0]                                          = user_bracer  ;
	 golden_DRAM[65536 + (user_id) *8 + 2][7:6]                                          = user_stone   ;
	{golden_DRAM[65536 + (user_id) *8 + 2][5:0], golden_DRAM[65536 + (user_id) *8 + 3]}  = user_money   ;
	 golden_DRAM[65536 + (user_id) *8 + 4][7:4]                                          = user_stage   ;
	 golden_DRAM[65536 + (user_id) *8 + 4][3:0]                                          = user_type    ;
	 golden_DRAM[65536 + (user_id) *8 + 5]                                               = user_hp      ;
	 golden_DRAM[65536 + (user_id) *8 + 6]                                               = user_atk     ;
	 golden_DRAM[65536 + (user_id) *8 + 7]                                               = user_exp     ;
end endtask

task input_task; begin
	random_input_task;
	inf.id_valid    = 1'b1;
	inf.D           = {8'b0, user_id};
	bracer_effect   = 0;

	get_user_dram_data;

	@(negedge clk);
	inf.id_valid    = 1'b0;
	inf.D           =  'dx;
	random_gap_task;

	for (j = 0; j < now_action_num; j = j + 1) begin

		random_action_task;
		
		while(!inf.out_valid) begin
			@(negedge clk);
			cycles = cycles + 1;
			operation_cycles = operation_cycles + 1;
		end
		
		check_ans;
		random_delay_task;
	end

	store_user_dram_data;

end endtask

task random_input_task; begin
	rand_id.randomize();
	count_action = 0;
	if      (action_constrain === 0)  action_constrain = 1 ;
	else if (action_constrain === 1)  action_constrain = 2 ;
	else if (action_constrain === 2)  action_constrain = 4 ;
	else if (action_constrain === 4)  action_constrain = 6 ;
	else if (action_constrain === 6)  action_constrain = 8 ;
	else if (action_constrain === 8)  action_constrain = 10;
	else if (action_constrain === 10) action_constrain = 1;
	//$display("initial action: %d", action_constrain);

	rand_action_num.randomize();

	//user_id = rand_id.id;
	user_id = id_select; id_select = id_select + 1;
	
	now_action_num = rand_action_num.action_num;
	//$display("ID: %d, Action number: %d", user_id, rand_action_num.action_num);
end endtask

task random_action_task; begin
	// Action input
	rand_action.randomize();
	now_action = rand_action.action;
	//$display("%d Action: %d", index, now_action);
	
	count_action = count_action + 1;
	if (index == 41) index = 0;
	else             index = index + 1;

	inf.act_valid   = 1'b1;
	inf.D           = {12'b0, now_action};
	@(negedge clk);
	inf.act_valid   = 1'b0;
	inf.D           =  'dx;
	
	
	// Another input
	if (rand_action.action === 1 | rand_action.action === 2 | rand_action.action === 6) begin
		random_gap_task;
		
		rand_PKM_or_item.randomize();

		if (rand_action.action === 1 | rand_action.action === 2) begin
			if (rand_PKM_or_item.PKM_or_item === 0) begin
				rand_PKM_type.randomize();
				now_type        = rand_PKM_type.PKM_type;
				inf.type_valid  = 1'b1;
				if (rand_action.action === 1) inf.D = {12'b0, now_type};
				else                          inf.D = {16'd0};             // When sell pokemon , D should be 16’d0 when type_valid is high
			end
			else begin
				rand_item_type.randomize();
				now_item        = rand_item_type.item_type;
				inf.item_valid  = 1'b1;
				inf.D           = {12'b0, now_item};
			end
		end
		else begin
			rand_item_type.randomize();
			now_item        = rand_item_type.item_type;
			inf.item_valid  = 1'b1;
			inf.D           = {12'b0, now_item};
		end

		// display
		// if (rand_action.action === 1) begin
		// 	$display("Buy");
		// 	if (rand_PKM_or_item.PKM_or_item === 0) $display("PKM : %d", now_type);
		// 	else                                    $display("Item: %d", now_item);
		// end
		// else if (rand_action.action === 2) begin
		// 	$display("Sell");
		// 	if (rand_PKM_or_item.PKM_or_item === 0) $display("PKM : %d", now_type);
		// 	else                                    $display("Item: %d", now_item);
		// end
		// else begin
		// 	$display("Use item");
		// 	$display("Item: %d", now_item);
		// end
	end
	else if (rand_action.action === 4) begin
		random_gap_task;

		rand_amount_money.randomize();
		deposit_money   = rand_amount_money.amount_money;
		inf.amnt_valid  = 1'b1;
		inf.D           = {2'b0, deposit_money};
		//$display("Deposit, Money: %d", deposit_money);
	end
	else if (rand_action.action === 10) begin
		random_gap_task;

		rand_attack_id.randomize();
		
		//defender_id     = rand_attack_id.attack_id;
		defender_id     = id_select; id_select = id_select + 1;
		
		inf.id_valid    = 1'b1;
		inf.D           = {8'b0, defender_id};
		//$display("Attack, ID: %d", defender_id);
	end

	@(negedge clk);
	inf.rst_n       = 1'b1; 
	inf.id_valid    = 1'b0;
	inf.act_valid   = 1'b0;
	inf.item_valid  = 1'b0;
	inf.type_valid  = 1'b0;
	inf.amnt_valid  = 1'b0;
	inf.D           =  'dx;

	if (now_action == 8) operation_cycles = 1;
	else if (now_action == 1 | now_action == 2 | now_action == 4 | now_action == 6  | now_action == 10) operation_cycles = 0;         
	
end endtask

task random_gap_task; begin
	rand_gap.randomize();
	//$display("gap: %d", rand_gap.gap);
	for( i = 0 ; i < rand_gap.gap ; i = i + 1 ) begin
		@(negedge clk);
		inf.id_valid    = 1'b0;
		inf.act_valid   = 1'b0;
		inf.item_valid  = 1'b0;
		inf.type_valid  = 1'b0;
		inf.amnt_valid  = 1'b0;
		inf.D           =  'dx;
	end	
end endtask

task random_delay_task; begin
	rand_delay.randomize();
	//$display("delay: %d", rand_delay.delay);
	for( i = 0 ; i < rand_delay.delay ; i = i + 1 ) begin
		@(negedge clk);
		inf.id_valid    = 1'b0;
		inf.act_valid   = 1'b0;
		inf.item_valid  = 1'b0;
		inf.type_valid  = 1'b0;
		inf.amnt_valid  = 1'b0;
		inf.D           =  'dx;
	end	
end endtask

task check_ans; begin
	//$display("checking answer");
	
	golden_err = 0;
	if      (now_action === 0)  check_ans_No_action;
	else if (now_action === 1)  check_ans_Buy;
	else if (now_action === 2)  check_ans_Sell;
	else if (now_action === 4)  check_ans_Deposit;
	else if (now_action === 6)  check_ans_Use_item;
	else if (now_action === 8)  check_ans_Check;
	else if (now_action === 10) check_ans_Attack;

	// golden_out
	if (now_action === 10) begin
		if (golden_err === 0) begin
			golden_out [31:0] = {defender_stage, defender_type, defender_hp, defender_atk, defender_exp};
			golden_out[63:32] = {user_stage, user_type, user_hp, user_atk, user_exp};
		end
		else begin
			golden_out = 0;
		end
	end
	else begin
		if (golden_err === 0) begin
			if (bracer_effect & user_type !== 'd0)  golden_out [31:0] = {user_stage, user_type, user_hp, user_atk + 6'd32, user_exp};  // no overflow and no PKM
			else                                    golden_out [31:0] = {user_stage, user_type, user_hp, user_atk        , user_exp};
			golden_out[63:32] = {user_berry, user_medicine, user_candy, user_bracer, user_stone, user_money};
		end
		else begin
			golden_out = 0;
		end
	end

	// golden_complete
	if (golden_err === 0) golden_com = 1;
	else                  golden_com = 0;

	// check answer
	//if (inf.complete === golden_com) begin
	//	if      (inf.complete === 1 & inf.out_info !== golden_out) begin
	//		$display("Wrong Answer");
	//		$finish;
	//	end
	//	else if (inf.complete === 0 & inf.err_msg  !== golden_err) begin
	//		$display("Wrong Answer");
	//		$finish;
	//	end
	//end
	//else begin
	//	$display("Wrong Answer");
	//	$finish;
	//end


	if (inf.out_info !== golden_out | inf.err_msg !== golden_err | inf.complete !== golden_com) begin
		$display("Wrong Answer");
		$finish;
	end

end endtask

task check_ans_No_action; begin
	//$display("checking answer - No action");
end endtask

task check_ans_Buy; begin
	//$display("checking answer - Buy");

	// Select item/PKM price
	if (rand_PKM_or_item.PKM_or_item === 0) begin
		case (now_type)
			4'b0001: item_price = 'd100;
			4'b0010: item_price = 'd90 ;
			4'b0100: item_price = 'd110;
			4'b1000: item_price = 'd120;
			4'b0101: item_price = 'd130;
			default: item_price = 'd16 ;
		endcase
	end
	else begin
		case (now_item)
			4'b0001: item_price = 'd16 ;
			4'b0010: item_price = 'd128;
			4'b0100: item_price = 'd300;
			4'b1000: item_price = 'd64 ;
			4'b1001: item_price = 'd800;
			4'b1010: item_price = 'd800;
			4'b1100: item_price = 'd800;
			default: item_price = 'd16 ;
		endcase
	end

	if      (user_money < item_price)                                          begin golden_err = 4'b0010; end     // Out of money
	else if (rand_PKM_or_item.PKM_or_item === 0 & user_type  !== 4'b0000)      begin golden_err = 4'b0001; end     // Already have a Pokemon
	else if (rand_PKM_or_item.PKM_or_item === 1 & user_stone !== 4'b0000 & (now_item === 4'b1001 | now_item === 4'b1010 | now_item === 4'b1100) ) 
	                                                                           begin golden_err = 4'b0100; end     // Bag is full (stone)
	else if (rand_PKM_or_item.PKM_or_item === 1 & ((user_berry === 'd15 & now_item === 4'b0001) | (user_medicine === 'd15 & now_item === 4'b0010) | (user_candy === 'd15 & now_item === 4'b0100) | (user_bracer === 'd15 & now_item === 4'b1000) ) ) 
	                                                                           begin golden_err = 4'b0100; end     // Bag is full (item)
	else begin                                                                                                     // Normal
		if (rand_PKM_or_item.PKM_or_item === 0) begin // Buy PKM
			case (now_type)
				4'b0001: begin user_type = 4'b0001; user_hp = 'd128; user_atk = 'd63; end
				4'b0010: begin user_type = 4'b0010; user_hp = 'd119; user_atk = 'd64; end
				4'b0100: begin user_type = 4'b0100; user_hp = 'd125; user_atk = 'd60; end
				4'b1000: begin user_type = 4'b1000; user_hp = 'd122; user_atk = 'd65; end
				4'b0101: begin user_type = 4'b0101; user_hp = 'd124; user_atk = 'd62; end
				default: begin user_type = 4'b0001; user_hp = 'd128; user_atk = 'd63; end
			endcase
			user_stage = 4'b0001;
			user_exp   = 'd0;
		end
		else begin                                    // Buy Item
			case (now_item)
				4'b0001: begin user_berry    = user_berry    + 1; end
				4'b0010: begin user_medicine = user_medicine + 1; end
				4'b0100: begin user_candy    = user_candy    + 1; end
				4'b1000: begin user_bracer   = user_bracer   + 1; end
				4'b1001: begin user_stone    = 'b01;              end
				4'b1010: begin user_stone    = 'b10;              end
				4'b1100: begin user_stone    = 'b11;              end
				default: begin user_berry    = user_berry    + 1; end
			endcase
		end
		user_money = user_money - item_price;
		golden_err = 4'b0000;
	end

end endtask

task check_ans_Sell; begin
	//$display("checking answer - Sell");

	// Select item/PKM price
	if (rand_PKM_or_item.PKM_or_item === 0) begin
		case (user_type)
			4'b0001: item_price = (user_stage === 4'b0010) ? 'd510 : (user_stage === 4'b0100) ? 'd1100 : 'd0;
			4'b0010: item_price = (user_stage === 4'b0010) ? 'd450 : (user_stage === 4'b0100) ? 'd1000 : 'd0;
			4'b0100: item_price = (user_stage === 4'b0010) ? 'd500 : (user_stage === 4'b0100) ? 'd1200 : 'd0;
			4'b1000: item_price = (user_stage === 4'b0010) ? 'd550 : (user_stage === 4'b0100) ? 'd1300 : 'd0;
			default: item_price = (user_stage === 4'b0010) ? 'd510 : (user_stage === 4'b0100) ? 'd1100 : 'd0;
		endcase
	end
	else begin
		case (now_item)
			4'b0001: item_price = 'd12 ;
			4'b0010: item_price = 'd96 ;
			4'b0100: item_price = 'd225;
			4'b1000: item_price = 'd48 ;
			4'b1001: item_price = 'd600;
			4'b1010: item_price = 'd600;
			4'b1100: item_price = 'd600;
			default: item_price = 'd12 ;
		endcase
	end

	if (rand_PKM_or_item.PKM_or_item === 0 & user_type  === 4'b0000)           begin golden_err = 4'b0110; end     // Do not have a Pokemon
	else if (rand_PKM_or_item.PKM_or_item === 1 & ((user_berry === 'd0 & now_item === 4'b0001) | (user_medicine === 'd0 & now_item === 4'b0010) | (user_candy === 'd0 & now_item === 4'b0100) | (user_bracer === 'd0 & now_item === 4'b1000) | ((user_stone === 'd0 | user_stone === 'd1) & (now_item === 4'd10 | now_item === 4'd12) ) | ((user_stone === 'd0 | user_stone === 'd2) & (now_item === 4'd9 | now_item === 4'd12) ) | ((user_stone === 'd0 | user_stone === 'd3) & (now_item === 4'd9 | now_item === 4'd10) ) ) )
																			   begin golden_err = 4'b1010; end     // Do not have item
	else if (rand_PKM_or_item.PKM_or_item === 0 & user_stage === 4'b0001)      begin golden_err = 4'b1000; end     // Pokemon is in the lowest stage
	else begin                                                                                                     // Normal
		if (rand_PKM_or_item.PKM_or_item === 0) begin // Sell PKM
			user_stage = 4'b0000; user_type = 4'b0000; user_hp = 'd0; user_atk = 'd0; user_exp = 'd0;
			bracer_effect = 0;
		end
		else begin                                    // Sell Item
			case (now_item)
				4'b0001: begin user_berry    = user_berry    - 1; end
				4'b0010: begin user_medicine = user_medicine - 1; end
				4'b0100: begin user_candy    = user_candy    - 1; end
				4'b1000: begin user_bracer   = user_bracer   - 1; end
				4'b1001: begin user_stone    = 'b00;              end
				4'b1010: begin user_stone    = 'b00;              end
				4'b1100: begin user_stone    = 'b00;              end
				default: begin user_berry    = user_berry    - 1; end
			endcase
		end
		user_money = user_money + item_price;
		golden_err = 4'b0000;
	end
end endtask

task get_user_max; begin
	case(user_stage)
		4'b0001: begin
			case(user_type)
				4'd1:    begin next_user_hp = 'd192 ; next_user_atk = 'd94; max_user_hp = 'd128; max_user_exp = 'd32; th_user_hp = 'd96; th_user_exp = 'd17; end
				4'd2:    begin next_user_hp = 'd177 ; next_user_atk = 'd96; max_user_hp = 'd119; max_user_exp = 'd30; th_user_hp = 'd87; th_user_exp = 'd15; end
				4'd4:    begin next_user_hp = 'd187 ; next_user_atk = 'd89; max_user_hp = 'd125; max_user_exp = 'd28; th_user_hp = 'd93; th_user_exp = 'd13; end
				4'd8:    begin next_user_hp = 'd182 ; next_user_atk = 'd97; max_user_hp = 'd122; max_user_exp = 'd26; th_user_hp = 'd90; th_user_exp = 'd11; end
				4'd5:    begin                                              max_user_hp = 'd124; max_user_exp = 'd29; th_user_hp = 'd92; th_user_exp = 'd14; end
				default: begin next_user_hp = 'd192 ; next_user_atk = 'd94; max_user_hp = 'd128; max_user_exp = 'd32; th_user_hp = 'd96; th_user_exp = 'd17; end
			endcase
		end
		4'b0010: begin
			case(user_type)
				4'd1:    begin next_user_hp = 'd254 ; next_user_atk = 'd123; max_user_hp = 'd192; max_user_exp = 'd63; th_user_hp = 'd160; th_user_exp = 'd48; end
				4'd2:    begin next_user_hp = 'd225 ; next_user_atk = 'd127; max_user_hp = 'd177; max_user_exp = 'd59; th_user_hp = 'd145; th_user_exp = 'd44; end
				4'd4:    begin next_user_hp = 'd245 ; next_user_atk = 'd113; max_user_hp = 'd187; max_user_exp = 'd55; th_user_hp = 'd155; th_user_exp = 'd40; end
				4'd8:    begin next_user_hp = 'd235 ; next_user_atk = 'd124; max_user_hp = 'd182; max_user_exp = 'd51; th_user_hp = 'd150; th_user_exp = 'd36; end
				default: begin next_user_hp = 'd254 ; next_user_atk = 'd123; max_user_hp = 'd192; max_user_exp = 'd63; th_user_hp = 'd160; th_user_exp = 'd48; end
			endcase
		end
		4'b0100: begin
			case(user_type)
				4'd1:    begin next_user_hp = 'd254 ; next_user_atk = 'd123; max_user_hp = 'd254; max_user_exp = 'd123; th_user_hp = 'd222; th_user_exp = 'd108; end
				4'd2:    begin next_user_hp = 'd225 ; next_user_atk = 'd127; max_user_hp = 'd225; max_user_exp = 'd127; th_user_hp = 'd193; th_user_exp = 'd112; end
				4'd4:    begin next_user_hp = 'd245 ; next_user_atk = 'd113; max_user_hp = 'd245; max_user_exp = 'd113; th_user_hp = 'd213; th_user_exp = 'd98 ; end
				4'd8:    begin next_user_hp = 'd235 ; next_user_atk = 'd124; max_user_hp = 'd235; max_user_exp = 'd124; th_user_hp = 'd203; th_user_exp = 'd109; end
				default: begin next_user_hp = 'd254 ; next_user_atk = 'd123; max_user_hp = 'd254; max_user_exp = 'd123; th_user_hp = 'd222; th_user_exp = 'd108; end
			endcase
		end
		default: begin
			case(user_type)
				4'd1:    begin next_user_hp = 'd192 ; next_user_atk = 'd94; max_user_hp = 'd128; max_user_exp = 'd32; th_user_hp = 'd96; th_user_exp = 'd17; end
				4'd2:    begin next_user_hp = 'd177 ; next_user_atk = 'd96; max_user_hp = 'd119; max_user_exp = 'd30; th_user_hp = 'd87; th_user_exp = 'd15; end
				4'd4:    begin next_user_hp = 'd187 ; next_user_atk = 'd89; max_user_hp = 'd125; max_user_exp = 'd28; th_user_hp = 'd93; th_user_exp = 'd13; end
				4'd8:    begin next_user_hp = 'd182 ; next_user_atk = 'd97; max_user_hp = 'd122; max_user_exp = 'd26; th_user_hp = 'd90; th_user_exp = 'd11; end
				4'd5:    begin                                              max_user_hp = 'd124; max_user_exp = 'd29; th_user_hp = 'd92; th_user_exp = 'd14; end
				default: begin next_user_hp = 'd192 ; next_user_atk = 'd94; max_user_hp = 'd128; max_user_exp = 'd32; th_user_hp = 'd96; th_user_exp = 'd17; end
			endcase
		end
	endcase
end endtask

task check_ans_Use_item; begin
	//$display("checking answer - Use_item");

	if (user_type  === 4'b0000)                                                begin golden_err = 4'b0110; end     // Do not have a Pokemon
	else if ((user_berry === 'd0 & now_item === 4'b0001) | (user_medicine === 'd0 & now_item === 4'b0010) | (user_candy === 'd0 & now_item === 4'b0100) | (user_bracer === 'd0 & now_item === 4'b1000) | (user_stone !== 'd1 & now_item === 4'b1001) | (user_stone !== 'd2 & now_item === 4'b1010) | (user_stone !== 'd3 & now_item === 4'b1100) )
																			   begin golden_err = 4'b1010; end     // Do not have item
	else begin 
		get_user_max;                                                                                              // Normal
		case (now_item)
			4'b0001: begin user_hp = (user_hp >= th_user_hp) ? max_user_hp : user_hp + 'd32; user_berry    = user_berry    - 1; end // Berry   : Current HP + 'd32
			4'b0010: begin user_hp = max_user_hp;                                            user_medicine = user_medicine - 1; end // Medicine: Recover full HP
			4'b0100: begin                                                                                                          // Candy   : Exp + 'd15
				if (user_type !== 5) begin
					if (user_exp >= th_user_exp & user_stage !== No_stage & user_stage !== Highest) begin
						case(user_stage)
							4'b0001: begin user_stage = 4'b0010; bracer_effect = 0; end
							4'b0010: begin user_stage = 4'b0100; bracer_effect = 0; end
							default: user_stage = user_stage;
						endcase
						user_exp = 'd0;
						user_hp  = next_user_hp;
						user_atk = next_user_atk;
					end
					else begin
						if (user_stage === 4'b0100) user_exp = 0;
						else                        user_exp = user_exp + 'd15;
					end
				end
				else begin
					user_exp = (user_exp < 'd14) ? user_exp + 'd15: 'd29; 
				end
				user_candy = user_candy - 1;
			end
			4'b1000: begin                       // Bracer: Atk + 'd32
				bracer_effect = 1;
				user_bracer   = user_bracer - 1;
			end
			4'b1001: begin 
				if (user_type === 4'd5 & user_exp === max_user_exp & user_stage === Lowest) begin
					user_stage = 4'b0100;
					user_type  = 4'd4;
					user_hp    =  'd245;
					user_atk   =  'd113;
					user_exp   =  'd0;
					bracer_effect = 0;
				end
				user_stone = 'b00;
			end
			4'b1010: begin 
				if (user_type === 4'd5 & user_exp === max_user_exp & user_stage === Lowest) begin
					user_stage = 4'b0100;
					user_type  = 4'd2;
					user_hp    =  'd225;
					user_atk   =  'd127;
					user_exp   =  'd0;
					bracer_effect = 0;
				end
				user_stone = 'b00;
			end
			4'b1100: begin 
				if (user_type === 4'd5 & user_exp === max_user_exp & user_stage === Lowest) begin
					user_stage = 4'b0100;
					user_type  = 4'd8;
					user_hp    =  'd235;
					user_atk   =  'd124;
					user_exp   =  'd0;
					bracer_effect = 0;
				end
				user_stone = 'b00;
			end
		endcase

		golden_err = 4'b0000;
	end

end endtask

task check_ans_Deposit; begin
	//$display("checking answer - Deposit");
	user_money = user_money + deposit_money;
	golden_err = 4'b0000;
end endtask

task check_ans_Check; begin
	//$display("checking answer - Check");
	golden_err = 4'b0000;
end endtask

task get_defender_dram_data; begin
	defender_stage    =  golden_DRAM[65536 + (defender_id) *8 + 4][7:4];
	defender_type     =  golden_DRAM[65536 + (defender_id) *8 + 4][3:0];
	defender_hp       =  golden_DRAM[65536 + (defender_id) *8 + 5];
	defender_atk      =  golden_DRAM[65536 + (defender_id) *8 + 6];
	defender_exp      =  golden_DRAM[65536 + (defender_id) *8 + 7];
end endtask

task store_defender_dram_data; begin
	 golden_DRAM[65536 + (defender_id) *8 + 4][7:4]                                          = defender_stage   ;
	 golden_DRAM[65536 + (defender_id) *8 + 4][3:0]                                          = defender_type    ;
	 golden_DRAM[65536 + (defender_id) *8 + 5]                                               = defender_hp      ;
	 golden_DRAM[65536 + (defender_id) *8 + 6]                                               = defender_atk     ;
	 golden_DRAM[65536 + (defender_id) *8 + 7]                                               = defender_exp     ;
end endtask

task attack_effect; begin
	halve  = 0;
	double = 0;

	case(user_type)
		4'd1: begin                   // Grass
			halve  = (defender_type === 1 | defender_type === 2) ? 1 : 0;
			double = (defender_type === 4                     ) ? 1 : 0;
		end
		4'd2: begin                   // Fire
			halve  = (defender_type === 2 | defender_type === 4) ? 1 : 0;
			double = (defender_type === 1                     ) ? 1 : 0;
		end
        4'd4: begin                   // Water
			halve  = (defender_type === 1 | defender_type === 4) ? 1 : 0;
			double = (defender_type === 2                     ) ? 1 : 0;
		end	
		4'd8: begin                   // Electric
			halve  = (defender_type === 1 | defender_type === 8) ? 1 : 0;
			double = (defender_type === 4                     ) ? 1 : 0;
		end
		4'd5: begin                   // Normal
			halve  = 0;
			double = 0;
		end	
		default: begin halve  = 0; double = 0; end	
	endcase
end endtask

task get_exp; begin
	case(user_stage)
		4'b0001: defender_get_exp = 'd8 ;
		4'b0010: defender_get_exp = 'd12;
		4'b0100: defender_get_exp = 'd16;
		default: defender_get_exp = 'd8 ;
	endcase

	case(defender_stage)
		4'b0001: user_get_exp = 'd16;
		4'b0010: user_get_exp = 'd24;
		4'b0100: user_get_exp = 'd32;
		default: user_get_exp = 'd16;
	endcase
end endtask

task get_defender_max; begin
	case(defender_stage)
		4'b0001: begin
			case(defender_type)
				4'd1:    begin next_defender_hp = 'd192 ; next_defender_atk = 'd94; max_defender_exp = 'd32; end
				4'd2:    begin next_defender_hp = 'd177 ; next_defender_atk = 'd96; max_defender_exp = 'd30; end
				4'd4:    begin next_defender_hp = 'd187 ; next_defender_atk = 'd89; max_defender_exp = 'd28; end
				4'd8:    begin next_defender_hp = 'd182 ; next_defender_atk = 'd97; max_defender_exp = 'd26; end
				4'd5:    begin                                                      max_defender_exp = 'd29; end
				default: begin next_defender_hp = 'd192 ; next_defender_atk = 'd94; max_defender_exp = 'd32; end
			endcase
		end
		4'b0010: begin
			case(defender_type)
				4'd1:    begin next_defender_hp = 'd254 ; next_defender_atk = 'd123; max_defender_exp = 'd63; end
				4'd2:    begin next_defender_hp = 'd225 ; next_defender_atk = 'd127; max_defender_exp = 'd59; end
				4'd4:    begin next_defender_hp = 'd245 ; next_defender_atk = 'd113; max_defender_exp = 'd55; end
				4'd8:    begin next_defender_hp = 'd235 ; next_defender_atk = 'd124; max_defender_exp = 'd51; end
				default: begin next_defender_hp = 'd254 ; next_defender_atk = 'd123; max_defender_exp = 'd63; end
			endcase
		end
		4'b0100: begin
			case(defender_type)
				4'd1:    begin next_defender_hp = 'd254 ; next_defender_atk = 'd123; max_defender_exp = 'd63; end
				4'd2:    begin next_defender_hp = 'd225 ; next_defender_atk = 'd127; max_defender_exp = 'd59; end
				4'd4:    begin next_defender_hp = 'd245 ; next_defender_atk = 'd113; max_defender_exp = 'd55; end
				4'd8:    begin next_defender_hp = 'd235 ; next_defender_atk = 'd124; max_defender_exp = 'd51; end
				default: begin next_defender_hp = 'd254 ; next_defender_atk = 'd123; max_defender_exp = 'd63; end
			endcase
		end
		default: begin
			case(defender_type)
				4'd1:    begin next_defender_hp = 'd192 ; next_defender_atk = 'd94; max_defender_exp = 'd32; end
				4'd2:    begin next_defender_hp = 'd177 ; next_defender_atk = 'd96; max_defender_exp = 'd30; end
				4'd4:    begin next_defender_hp = 'd187 ; next_defender_atk = 'd89; max_defender_exp = 'd28; end
				4'd8:    begin next_defender_hp = 'd182 ; next_defender_atk = 'd97; max_defender_exp = 'd26; end
				4'd5:    begin                                                      max_defender_exp = 'd29; end
				default: begin next_defender_hp = 'd192 ; next_defender_atk = 'd94; max_defender_exp = 'd32; end
			endcase
		end
	endcase
end endtask

task check_ans_Attack; begin
	//$display("checking answer - Attack");

	get_defender_dram_data;
	attack_effect;
	

	if (defender_type === 0 | user_type  === 0) begin golden_err = 4'b0110; end     // Do not have a Pokemon
	else if (defender_hp === 0 | user_hp === 0) begin golden_err = 4'b1101; end     // HP is zero
	else begin                                                                      // Normal
		// calculate HP
		user_bracer_atk = (bracer_effect) ? user_atk + 'd32 : user_atk;
		user_select_atk = (halve) ? (user_bracer_atk >> 1) : (double) ? (user_bracer_atk << 1) : user_bracer_atk;
		defender_hp = (defender_hp > user_select_atk) ? (defender_hp - user_select_atk) : 0;
		// calculate EXP
		get_exp;
		// user evolve
		get_user_max;
		if (user_type !== 5) begin
			if (user_exp + user_get_exp >= max_user_exp & user_stage !== No_stage & user_stage !== Highest) begin
				case(user_stage)
					4'b0001: begin user_stage = 4'b0010; bracer_effect = 0; end
					4'b0010: begin user_stage = 4'b0100; bracer_effect = 0; end
					default: user_stage = user_stage;
				endcase
				user_exp = 'd0;
				user_hp  = next_user_hp;
				user_atk = next_user_atk;
			end
			else begin
				if (user_stage === 4'b0100) user_exp = 0;
				else                        user_exp = user_exp + user_get_exp;
			end
		end
		else begin
			user_exp = (user_exp + user_get_exp < 'd29) ? user_exp + user_get_exp : 'd29; 
		end
		// defender evolve
		get_defender_max;
		if (defender_type !== 5) begin
			if (defender_exp + defender_get_exp >= max_defender_exp & defender_stage !== No_stage & defender_stage !== Highest) begin
				case(defender_stage)
					4'b0001: begin defender_stage = 4'b0010; end
					4'b0010: begin defender_stage = 4'b0100; end
					default: defender_stage = defender_stage;
				endcase
				defender_exp = 'd0;
				defender_hp  = next_defender_hp;
				defender_atk = next_defender_atk;
			end
			else begin
				if (defender_stage === 4'b0100) defender_exp = 0;
				else                            defender_exp = defender_exp + defender_get_exp;
			end
		end
		else begin
			defender_exp = (defender_exp + defender_get_exp < 'd29) ? defender_exp + defender_get_exp : 'd29; 
		end

		bracer_effect = 0;
	end

	store_defender_dram_data;

end endtask

endprogram

