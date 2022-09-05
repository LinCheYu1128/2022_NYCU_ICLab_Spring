//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

covergroup Spec1 @(negedge clk iff inf.out_valid);
   	coverpoint inf.out_info[31:28] {
   		bins PKM_stage[] = {No_stage, Lowest, Middle, Highest};
		option.at_least = 20;
   	}
	coverpoint inf.out_info[27:24] {
   		bins PKM_type[] = {No_type, Grass, Fire, Water, Electric, Normal};
		option.at_least = 20;
   	}
endgroup: Spec1

covergroup Spec2 @(posedge clk iff inf.id_valid);
   	coverpoint inf.D.d_id[0] {
		option.auto_bin_max = 256;
   		option.at_least = 1;
   	}
endgroup: Spec2

covergroup Spec3 @(posedge clk iff inf.act_valid);
   	coverpoint inf.D.d_act[0] {
		bins action_transition[] = (Buy, Sell, Deposit, Check, Use_item, Attack => Buy, Sell, Deposit, Check, Use_item, Attack);
   		option.at_least = 10;
   	}
endgroup: Spec3

covergroup Spec4 @(negedge clk iff inf.out_valid);
   	coverpoint inf.complete {
		bins zero = {0};
		bins one  = {1};
   		option.at_least = 200;
   	}
endgroup: Spec4

covergroup Spec5 @(negedge clk iff inf.out_valid);
   	coverpoint inf.err_msg {
		bins err[] = {Already_Have_PKM, Out_of_money, Bag_is_full, Not_Having_PKM, Has_Not_Grown, Not_Having_Item, HP_is_Zero};
   		option.at_least = 20;	
   	}
endgroup: Spec5

//declare the cover group 
Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();


logic [3:0] now_action, count_valids;
// INPUT  @(posedge clk)
// OUTPUT @(negedge clk)
always_ff@(posedge clk or negedge inf.rst_n)begin
	if (!inf.rst_n)                                now_action <= No_action;
	else begin
		if (inf.out_valid)                         now_action <= No_action;
		else if (inf.act_valid) begin
			if      (inf.D.d_act[0])               now_action <= inf.D.d_act[0];
			else                                   now_action <= No_action;
		end
		else                                       now_action <= now_action;
	end 
end

//SPEC1
always @(negedge inf.rst_n) begin
	#1;
	assert_spec1 : assert (
		(inf.out_valid    === 0) &&
		(inf.err_msg      === 0) &&
		(inf.complete     === 0) &&
		(inf.out_info     === 0) &&
		(inf.C_addr       === 0) &&
		(inf.C_data_w     === 0) &&
		(inf.C_in_valid   === 0) &&
		(inf.C_r_wb       === 0) &&
		(inf.C_out_valid  === 0) &&
		(inf.C_data_r     === 0) &&
		(inf.AR_VALID     === 0) &&
		(inf.AR_ADDR      === 0) &&
		(inf.R_READY      === 0) &&
		(inf.AW_VALID     === 0) &&
		(inf.AW_ADDR      === 0) &&
		(inf.W_VALID      === 0) &&
		(inf.W_DATA       === 0) &&
		(inf.B_READY      === 0)
	)
	else begin $display("Assertion 1 is violated"); $fatal; end
end


//SPEC2
assert_spec2 : assert property ( @(negedge clk) (   inf.complete  && inf.out_valid ) |-> (!inf.err_msg) )
else begin $display("Assertion 2 is violated"); $fatal; end


//SPEC3
assert_spec3 : assert property ( @(negedge clk) ( (!inf.complete) && inf.out_valid ) |-> (!inf.out_info) )
else begin $display("Assertion 3 is violated"); $fatal; end


//SPEC4
// Use negedge because the now_action is changed at posedge
assert_spec4_one_cyele : assert property ( @(negedge clk) (count_valids) |=> (!count_valids))
else begin $display("Assertion 4 is violated"); $fatal; end
assert_spec4_id_act    : assert property ( @(negedge clk) (now_action === No_action && inf.id_valid)  |-> (##[2:6] inf.act_valid ))
else begin $display("Assertion 4 is violated"); $fatal; end
assert_spec4_Buy_Sell  : assert property ( @(negedge clk) ((now_action === Buy || now_action === Sell) && inf.act_valid) |-> (##[2:6] (inf.item_valid || inf.type_valid)))
else begin $display("Assertion 4 is violated"); $fatal; end
assert_spec4_Deposit   : assert property ( @(negedge clk) (now_action === Deposit   && inf.act_valid) |-> (##[2:6] inf.amnt_valid))
else begin $display("Assertion 4 is violated"); $fatal; end 
assert_spec4_Use_item  : assert property ( @(negedge clk) (now_action === Use_item  && inf.act_valid) |-> (##[2:6] inf.item_valid))
else begin $display("Assertion 4 is violated"); $fatal; end 
assert_spec4_Attack    : assert property ( @(negedge clk) (now_action === Attack    && inf.act_valid) |-> (##[2:6] inf.id_valid  ))
else begin $display("Assertion 4 is violated"); $fatal; end 


//SPEC5
always_comb begin
	count_valids = inf.id_valid + inf.act_valid + inf.item_valid + inf.type_valid + inf.amnt_valid;
end
assert_spec5 : assert property ( @(posedge clk) ( count_valids <= 1 ))
else begin $display("Assertion 5 is violated"); $fatal; end


//SPEC6
assert_spec6 : assert property ( @(negedge clk) ( inf.out_valid) |=> (!inf.out_valid) )
else begin $display("Assertion 6 is violated"); $fatal; end


//SPEC7
assert_spec7_one_cyele : assert property ( @(posedge clk) (inf.out_valid) |=> (count_valids === 0) )
else begin $display("Assertion 7 is violated"); $fatal; end
assert_spec7_210       : assert property ( @(posedge clk) (inf.out_valid) |-> ( ##[2:10] (inf.id_valid || inf.act_valid) ))
else begin $display("Assertion 7 is violated"); $fatal; end


//SPEC8
assert_spec8_Buy_Sell : assert property ( @(negedge clk)  ((now_action === Buy || now_action === Sell) && (inf.item_valid || inf.type_valid)) |-> ( ##[1:1200] inf.out_valid) )
else begin $display("Assertion 8 is violated"); $fatal; end
assert_spec8_Deposit  : assert property ( @(negedge clk)  (now_action === Deposit  && inf.amnt_valid) |-> ( ##[1:1200] inf.out_valid) )
else begin $display("Assertion 8 is violated"); $fatal; end
assert_spec8_Use_item : assert property ( @(negedge clk)  (now_action === Use_item && inf.item_valid) |-> ( ##[1:1200] inf.out_valid) )
else begin $display("Assertion 8 is violated"); $fatal; end
assert_spec8_Check    : assert property ( @(negedge clk)  (now_action === Check    && inf.act_valid ) |-> ( ##[1:1200] inf.out_valid) )
else begin $display("Assertion 8 is violated"); $fatal; end
assert_spec8_Attack   : assert property ( @(negedge clk)  (now_action === Attack   && inf.id_valid  ) |-> ( ##[1:1200] inf.out_valid) )
else begin $display("Assertion 8 is violated"); $fatal; end

endmodule