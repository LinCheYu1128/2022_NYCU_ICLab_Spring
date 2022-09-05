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

covergroup Spec1 @(negedge clk && inf.out_valid);
	STAGE_COV : coverpoint inf.out_info[31:28] {
		option.at_least = 20 ;
		bins b1 = {No_stage} ;
		bins b2 = {Lowest  } ;
		bins b3 = {Middle  } ;
		bins b4 = {Highest } ;
	}
	TYPE_COV : coverpoint inf.out_info[27:24] {
		option.at_least = 20 ;
		bins b1 = {No_type } ;
		bins b2 = {Grass   } ;
		bins b3 = {Fire    } ;
		bins b4 = {Water   } ;
		bins b5 = {Electric} ;
		bins b6 = {Normal  } ;
	}
endgroup

covergroup Spec2 @(posedge clk && inf.id_valid);
	coverpoint inf.D.d_id[0] {
		option.at_least = 1 ;
		option.auto_bin_max = 256 ;
	}
endgroup

covergroup Spec3 @(posedge clk && inf.act_valid);
   	coverpoint inf.D.d_act[0] {
   		option.at_least = 10 ;
   		bins b[] = (Buy, Sell, Deposit, Use_item, Check, Attack => Buy, Sell, Deposit, Use_item, Check, Attack) ;
   	}
endgroup

covergroup Spec4 @(negedge clk && inf.out_valid);
   	coverpoint inf.complete {
   		option.at_least = 200 ;
   		bins b[] = {[0:1]} ;
   	}
endgroup

covergroup Spec5 @(negedge clk && inf.out_valid);
	coverpoint inf.err_msg {
		option.at_least = 20 ;
		bins b1 = {Already_Have_PKM} ;
		bins b2 = {Out_of_money    } ;
		bins b3 = {Bag_is_full     } ;
		bins b4 = {Not_Having_PKM  } ;
		bins b5 = {Has_Not_Grown   } ;
		bins b6 = {Not_Having_Item } ;
		bins b7 = {HP_is_Zero      } ;
	}
endgroup	
   
//declare other cover group



//declare the cover group 
Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();

//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write the required assertions below
//  assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0 [*2])
//  else
//  begin
//  	$display("Assertion X is violated");
//  	$fatal; 
//  end

//write other assertions
Action act ;
always_ff @(posedge clk or negedge inf.rst_n)  begin
	if (!inf.rst_n)		act <= No_action;
	else if(inf.out_valid)      act <= No_action;
	else if (inf.act_valid==1)  act <= inf.D.d_act[0] ;
end
// 1. All outputs signals (including pokemon.sv and bridge.sv) should be zero after reset
always @(negedge inf.rst_n) begin
	#1;
	assert_1 : assert (	(inf.out_valid===0)&&(inf.err_msg==No_Err)&&(inf.complete===0)&&(inf.out_info===0)&&
						(inf.C_addr===0)&&(inf.C_data_w===0)&&(inf.C_in_valid===0)&&(inf.C_r_wb===0)&&
						(inf.C_out_valid===0)&& (inf.C_data_r===0)&& 
		            	(inf.AR_VALID===0)&&(inf.AR_ADDR===0)&&(inf.R_READY===0)&&(inf.AW_VALID===0)&&(inf.AW_ADDR===0)&&(inf.W_VALID===0)&&(inf.W_DATA===0)&&(inf.B_READY===0))
	else begin
		$display("Assertion 1 is violated");
		$fatal; 
	end
end
// 2. If action is completed, err_msg should be 4'b0.
assert_2 : assert property ( @(negedge clk) (inf.complete===1 && inf.out_valid === 1) |-> (inf.err_msg===No_Err) )
else
begin
	$display("Assertion 2 is violated");
	$fatal; 
end
// 3. If action is not completed, out_info should be 64'b0.
assert_3 : assert property ( @(negedge clk) (inf.complete===0 && inf.out_valid === 1) |-> (inf.out_info===64'd0) )
else
begin
	$display("Assertion 3 is violated");
	$fatal; 
end
// 4. The gap between each input valid is at least 1 cycle and at most 5 cycles
// Check chage player
assert_4_1 :assert property ( @(negedge clk)  (inf.id_valid===1 && act==No_action)  |=> ##[1:5] ( inf.act_valid===1) )  
else begin
 	$display("Assertion 4 is violated");
 	$fatal; 
end
assert_4_2 :assert property ( @(negedge clk)  (inf.act_valid===1 && inf.D.d_act[0]!==Check)  |=> ##[1:5] (inf.id_valid===1 || inf.item_valid===1 || inf.type_valid===1 || inf.amnt_valid===1) )  
else begin
 	$display("Assertion 4 is violated");
 	$fatal; 
end
// 5. All input valid signals won’t overlap with each other.
logic no_one;
assign no_one = !( inf.id_valid || inf.act_valid || inf.item_valid || inf.type_valid || inf.amnt_valid ) ;
assert_5 :assert property ( @(posedge clk)   $onehot({ inf.id_valid, inf.act_valid, inf.item_valid, inf.type_valid, inf.amnt_valid, no_one}) )  
else
begin
 	$display("Assertion 5 is violated");
 	$fatal; 
end
// 6. Out_valid can only be high for exactly one cycle.
assert_6 : assert property ( @(posedge clk)  (inf.out_valid===1) |=> (inf.out_valid===0) )
else
begin
 	$display("Assertion 6 is violated");
 	$fatal; 
end
// 7. Next operation will be valid 2-10 cycles after out_valid fall.
assert_7_1 :assert property ( @(posedge clk) (inf.out_valid===1)  |-> ##[2:10] ( inf.id_valid===1 || inf.act_valid===1) )  
else begin
 	$display("Assertion 7 is violated");
 	$fatal; 
end
assert_7_2 :assert property ( @(posedge clk) (inf.out_valid===1)  |=> ( inf.id_valid===0 && inf.act_valid===0) )  
else begin
 	$display("Assertion 7 is violated");
 	$fatal; 
end
// 8. Latency should be less than 1200 cycles for each operation.
assert_8_1 :assert property ( @(posedge clk) ((act==Buy||act==Sell||act==Use_item) && (inf.item_valid===1||inf.type_valid===1)) |-> ##[1:1200] ( inf.out_valid===1) )  
else begin
 	$display("Assertion 8 is violated");
 	$fatal; 
end
assert_8_2 :assert property ( @(posedge clk) ((act==Deposit) && (inf.amnt_valid===1)) |-> ##[1:1200] ( inf.out_valid===1) )  
else begin
 	$display("Assertion 8 is violated");
 	$fatal; 
end
assert_8_3 :assert property ( @(posedge clk) ((inf.D.d_act[0]===Check) && (inf.act_valid===1)) |-> ##[1:1200] ( inf.out_valid===1) )  
else begin
 	$display("Assertion 8 is violated");
 	$fatal; 
end
assert_8_4 :assert property ( @(posedge clk) ((act==Attack) && (inf.id_valid===1)) |-> ##[1:1200] ( inf.out_valid===1) )  
else begin
 	$display("Assertion 8 is violated");
 	$fatal; 
end
endmodule