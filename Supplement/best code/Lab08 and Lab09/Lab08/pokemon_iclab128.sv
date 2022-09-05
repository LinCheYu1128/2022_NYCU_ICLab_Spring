module pokemon(input clk, INF.pokemon_inf inf);
import usertype::*;

//================================================================
// logic 
//================================================================
Action     Cur_act ;
Error_Msg  Err_message ; 
PKM_Type   Pokemon_type;
Stage	   My_pok_stage ; 
Item	   Cur_item  ;
Stone      Cur_stone ; 
state	   Current_state , Next_state;

Bag_Info    MY_bag ; 
PKM_Info    MY_Pok ;
Bag_Info    Def_bag ; 
PKM_Info    Def_Pok ;
Player_Info Player ; 
Player_Info Defender ;

logic [13:0] My_money ;  
logic [7 :0] My_id , DEF_ID; 
logic [5 :0] EXP_gain_from_attack ;
logic [4 :0] EXP_gain_from_defend ; 
logic [13:0] need_or_sell_money ; 
logic [7 :0] Full_HP , Full_EXP , Full_HP_for_defend ,Full_EXP_for_defend , my_atk , original_atk , evolution_atk_for_my , evolution_atk_for_defend ;  
logic [1 :0] type_or_item_valid ;  // 2 : type valid , 1 : item_valid , 0 : None; 
bit write_back , new_player , has_def_player , Attack_flag , read_id  , read_def_id , is_writing_or_reading , count_def_number , wait_valid, bracer_used; 

//================================================================
// design 
//================================================================
assign EXP_gain_from_attack = (Def_Pok.stage == Lowest) ? 'd16 :
							  (Def_Pok.stage == Middle) ? 'd24 : 'd32 ; 

assign EXP_gain_from_defend = (MY_Pok.stage == Lowest) ? 'd8 :
							  (MY_Pok.stage == Middle) ? 'd12 : 'd16 ; 


always_comb begin
	if ( (MY_Pok.stage == Lowest && MY_Pok.atk > 70) || (MY_Pok.stage == Middle && MY_Pok.atk > 100) || (MY_Pok.stage == Highest && MY_Pok.atk > 130) )begin
		bracer_used = 1 ;
	end else begin
		bracer_used = 0 ;
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		wait_valid <= 'd0 ;
	end else if (inf.act_valid && inf.D.d_act != Check) begin  // wait action to be finished ( wait_valid=='d1 means wait next action)
		wait_valid <= 'd1 ; 
	end else if (inf.type_valid || inf.amnt_valid || inf.item_valid || inf.id_valid  )begin
		wait_valid <= 'd0 ;
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		Attack_flag <= 'd0 ;
	end else if (Current_state == ST_ATTACK) begin  // because the output in ATTACK is different from others 
		Attack_flag <= 'd1 ; 
	end else if (Current_state == ST_IN ) begin
		Attack_flag <= 'd0 ;
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		has_def_player <= 'd0;
	end else if (inf.id_valid && Current_state == ST_ATTACK) begin   // if we do attack, we need to get defender's info
		has_def_player <= 'd1; 
	end else if (  (inf.C_out_valid && !new_player) || inf.err_msg != No_Err  )begin    // after getting info  || if err_msg occured, we don't need to get the defender's info (No Pokemon)  
		has_def_player <= 'd0;
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		new_player <= 'd0;
	end else if (inf.id_valid && Current_state == ST_IN) begin   // change the player , and we need to write back the old player's info
		new_player <= 'd1; 
	end else if (inf.C_out_valid && write_back == 'd0) begin  // after writing back
		new_player <= 'd0;
	end
end

// to check the bridge is working or not 
always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		is_writing_or_reading <= 'd0;
	end else if (inf.C_out_valid) begin   
		is_writing_or_reading <= 'd0; 
	end else if (new_player) begin
		is_writing_or_reading <= 'd1; 
	end else if (has_def_player && inf.err_msg == No_Err)begin
		is_writing_or_reading <= 'd1; 
	end else if (write_back && inf.id_valid && Current_state == ST_IN) begin 
		is_writing_or_reading <= 'd1; 
	end
end

// write_back last player . 
always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		write_back <= 'd0;
	end else if (write_back && inf.C_out_valid == 'd1 && new_player ) begin  //  when write_back is done
		write_back <= 'd0; 
	end else if (inf.complete =='d1 && inf.out_valid == 'd1) begin   //  prepare to write_back 
		write_back <= 'd1; 
	end
end


// if no err_msg in attack state, we need to write back defender's info
always_ff@(posedge clk , negedge inf.rst_n)begin    
	if (!inf.rst_n)begin
		count_def_number <= 'd0;
	end else if ( inf.err_msg == 'd0 && inf.complete && Current_state == ST_ATTACK ) begin  //  to write_back  def's info
		count_def_number <= 'd1; 
	end else begin  //  prepare to write_back 
		count_def_number <= 'd0; 
	end
end

// the data for writing back must be the original atk ; 
assign original_atk = (bracer_used ) ?  MY_Pok.atk - 'd32  : MY_Pok.atk ; 
		
always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.C_addr     <= 'd0 ;
		inf.C_in_valid <= 'd0 ;
		inf.C_r_wb	   <= 'd0 ;
		inf.C_data_w   <= 'd0 ;
	end else if ( write_back && !is_writing_or_reading && inf.id_valid && Current_state == ST_IN) begin   // when change player, write data back
		inf.C_addr     <= My_id ;
		inf.C_in_valid <= 'd1 ;
		inf.C_r_wb     <= 'd0 ;
		inf.C_data_w   <= {  MY_Pok.exp, original_atk , MY_Pok.hp, MY_Pok.stage, MY_Pok.pkm_type, MY_bag.money[7:0], MY_bag.stone,MY_bag.money[13:8], MY_bag.candy_num, MY_bag.bracer_num, MY_bag.berry_num, MY_bag.medicine_num } ;
	end else if ( new_player  &&  !is_writing_or_reading) begin   // Then read " new " data from DRAM
		inf.C_addr     <= My_id ;
		inf.C_in_valid <= 'd1 ;
		inf.C_r_wb     <= 'd1 ;
		inf.C_data_w   <= 'd0;
	end else if (has_def_player && !is_writing_or_reading && inf.err_msg == No_Err) begin   //  Then read " defender's " info from DRAM
		inf.C_addr     <= DEF_ID ;
		inf.C_in_valid <= 'd1 ;
		inf.C_r_wb     <= 'd1 ;
		inf.C_data_w   <= 'd0;
    end else if (count_def_number )  begin            //    write defender's info    
		inf.C_addr     <= DEF_ID ;
		inf.C_in_valid <= 'd1 ;
		inf.C_r_wb     <= 'd0 ;
		inf.C_data_w   <= { Def_Pok.exp, Def_Pok.atk, Def_Pok.hp, Def_Pok.stage, Def_Pok.pkm_type, Def_bag };
	end else begin                   //    do nothing
		inf.C_addr     <= 'd0 ;
		inf.C_in_valid <= 'd0 ;
		inf.C_r_wb     <= 'd0 ;
		inf.C_data_w   <= 'd0 ;
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		type_or_item_valid <= 'd0 ;
	end else if (Current_state == ST_IN) begin
		type_or_item_valid <= 'd0 ; 
	end else if (inf.item_valid) begin
		type_or_item_valid <= 'd1 ;
	end else if (inf.type_valid) begin
		type_or_item_valid <= 'd2 ;
	end
end


//  the money we need in different situation. 
always_comb begin  
	if (type_or_item_valid=='d1 && Current_state == ST_BUY) begin
		if (Cur_item == Berry)
			need_or_sell_money <= 'd16;
		else if (Cur_item == Medicine)
			need_or_sell_money <= 'd128 ;
		else if (Cur_item == Candy)
			need_or_sell_money <= 'd300 ;
		else if (Cur_item == Bracer)
			need_or_sell_money <= 'd64  ; 
		else 		// if (inf.D.d_item == Water_stone || inf.D.d_item == Fire_stone || inf.D.d_item == Thunder_stone)
			need_or_sell_money <= 'd800 ;
	end else if (type_or_item_valid=='d1 && Current_state == ST_SELL) begin
		if (Cur_item == Berry)
			need_or_sell_money <= 'd12;
		else if (Cur_item == Medicine)
			need_or_sell_money <= 'd96 ;
		else if (Cur_item == Candy)
			need_or_sell_money <= 'd225 ;
		else if (Cur_item == Bracer)
			need_or_sell_money <= 'd48  ; 
		else 		//if (inf.D.d_item == Water_stone || inf.D.d_item == Fire_stone || inf.D.d_item == Thunder_stone)
			need_or_sell_money <= 'd600 ;	
	end else if (type_or_item_valid=='d2 && Current_state == ST_BUY ) begin
		if (Pokemon_type == Grass)
			need_or_sell_money <= 'd100 ;
		else if (Pokemon_type == Fire)
			need_or_sell_money <= 'd90 ;
		else if (Pokemon_type == Water) 
			need_or_sell_money <= 'd110 ;
		else if (Pokemon_type == Electric)
			need_or_sell_money <= 'd120 ;
		else  // if (Pokemon_type == Normal)
			need_or_sell_money <= 'd130 ;
	end else if (type_or_item_valid=='d2 && Current_state == ST_SELL ) begin
		if (MY_Pok.stage == 4'b0010) begin  // Middle_stage
			if (MY_Pok.pkm_type == Grass)
				need_or_sell_money <= 'd510 ;
			else if (MY_Pok.pkm_type == Fire)
				need_or_sell_money <= 'd450 ;
			else if (MY_Pok.pkm_type == Water) 
				need_or_sell_money <= 'd500;
			else  // if (inf.D.d_type == Electric)
				need_or_sell_money <= 'd550 ;
		end else begin		//if (MY_Pok[31:28] == 4'b0100)
			if (MY_Pok.pkm_type == Grass)
				need_or_sell_money <= 'd1100 ;
			else if (MY_Pok.pkm_type == Fire)
				need_or_sell_money <= 'd1000 ;
			else if (MY_Pok.pkm_type == Water) 
				need_or_sell_money <= 'd1200;
			else  // if (inf.D.d_type == Electric)
				need_or_sell_money <= 'd1300 ;
		end
	end else begin
		need_or_sell_money <= 'd0 ; 
	end
end


//  Pokemon's atk  if one attribute prevail another.  
always_comb begin    . 
	if (MY_Pok.pkm_type == Normal || Def_Pok.pkm_type == Normal || (Def_Pok.pkm_type == Electric && MY_Pok.pkm_type != Electric) || (MY_Pok.pkm_type == Electric && Def_Pok.pkm_type == Fire)  )begin
		my_atk = MY_Pok.atk ;
	end else if ( (MY_Pok.pkm_type == Fire && Def_Pok.pkm_type == Grass) || (MY_Pok.pkm_type == Water && Def_Pok.pkm_type == Fire) || ( (MY_Pok.pkm_type == Grass || MY_Pok.pkm_type == Electric ) && Def_Pok.pkm_type == Water) ) begin
		if (MY_Pok.atk > 'd127 )
			my_atk = 'd255 ; 
		else
			my_atk = MY_Pok.atk * 2 ;
	end else 
		my_atk =  MY_Pok.atk / 2 ;
end



always_comb begin
		// Highest stage  hp          // middle stage evolution hp                               // middle stage evolution hp   
	if ((MY_Pok.stage == Highest) || ((MY_Pok.stage == Middle) && Current_state == ST_ATTACK) || (Cur_item == Candy && Current_state == ST_USE_ITEM &&MY_Pok.stage == Middle )) begin
		if (MY_Pok.pkm_type == Grass) begin
			Full_HP  = 'd254;
		end else if (MY_Pok.pkm_type == Fire) begin
			Full_HP  = 'd225;
		end else if (MY_Pok.pkm_type == Water) begin
			Full_HP  = 'd245;
		end else begin	//  if (MY_Pok.pkm_type == Electric) begin
			Full_HP  = 'd235;
		end 
	end else if (MY_Pok.stage == Middle  || ((MY_Pok.stage == Lowest) && Current_state == ST_ATTACK) || (Cur_item == Candy && Current_state == ST_USE_ITEM &&MY_Pok.stage == Lowest )) begin
		if (MY_Pok.pkm_type == Grass) begin
			Full_HP  = 'd192;
		end else if (MY_Pok.pkm_type == Fire) begin
			Full_HP  = 'd177;
		end else if (MY_Pok.pkm_type == Water) begin
			Full_HP  = 'd187;
		end else begin	//  if (MY_Pok.pkm_type == Electric) begin
			Full_HP  = 'd182;
		end 
	end else begin  // (MY_Pok.stage == Lowest) begin
		if (MY_Pok.pkm_type == Grass) begin
			Full_HP  = 'd128;
		end else if (MY_Pok.pkm_type == Fire) begin
			Full_HP  = 'd119;
		end else if (MY_Pok.pkm_type == Water) begin
			Full_HP  = 'd125;
		end else if (MY_Pok.pkm_type == Electric) begin
			Full_HP  = 'd122;
		end else begin    //if (MY_Pok.pkm_type == Normal) begin 
			Full_HP  = 'd124;
		end 
	end 
end

always_comb begin
    if (MY_Pok.stage == Lowest) begin
		if (MY_Pok.pkm_type == Grass) begin
			Full_EXP = 'd32;
		end else if (MY_Pok.pkm_type == Fire) begin
			Full_EXP = 'd30;
		end else if (MY_Pok.pkm_type == Water) begin
			Full_EXP = 'd28;
		end else if (MY_Pok.pkm_type == Electric) begin
			Full_EXP = 'd26;
		end else begin    //if (MY_Pok.pkm_type == Normal) begin 
			Full_EXP = 'd29;
		end 
	end else begin //if (MY_Pok.stage == Middle) begin
		if (MY_Pok.pkm_type == Grass) begin
			Full_EXP = 'd63;
		end else if (MY_Pok.pkm_type == Fire) begin
			Full_EXP = 'd59;
		end else if (MY_Pok.pkm_type == Water) begin
			Full_EXP = 'd55;
		end else begin	//  if (MY_Pok.pkm_type == Electric) begin
			Full_EXP = 'd51;
		end 
	end
end

always_comb begin
	if (Def_Pok.stage == Lowest) begin    //   the hp after evolution
		if (Def_Pok.pkm_type == Grass) begin
			Full_HP_for_defend  = 'd192;
		end else if (Def_Pok.pkm_type == Fire) begin
			Full_HP_for_defend  = 'd177;
		end else if (Def_Pok.pkm_type == Water) begin
			Full_HP_for_defend  = 'd187;
		end else begin	//  if (Def_Pok.pkm_type == Electric) begin
			Full_HP_for_defend  = 'd182;
		end 
	end else begin
		if (Def_Pok.pkm_type == Grass) begin
			Full_HP_for_defend  = 'd254;
		end else if (Def_Pok.pkm_type == Fire) begin
			Full_HP_for_defend  = 'd225;
		end else if (Def_Pok.pkm_type == Water) begin
			Full_HP_for_defend  = 'd245;
		end else begin	//  if (Def_Pok.pkm_type == Electric) begin
			Full_HP_for_defend  = 'd235;
		end 
	end
end

always_comb begin
    if (Def_Pok.stage == Lowest) begin
		if (Def_Pok.pkm_type == Grass) begin
			Full_EXP_for_defend = 'd32;
		end else if (Def_Pok.pkm_type == Fire) begin
			Full_EXP_for_defend = 'd30;
		end else if (Def_Pok.pkm_type == Water) begin
			Full_EXP_for_defend = 'd28;
		end else if (Def_Pok.pkm_type == Electric) begin
			Full_EXP_for_defend = 'd26;
		end else begin    //if (Def_Pok.pkm_type == Normal) begin 
			Full_EXP_for_defend = 'd29;
		end 
	end else begin//if (Def_Pok.stage == Middle) begin
		if (Def_Pok.pkm_type == Grass) begin
			Full_EXP_for_defend = 'd63;
		end else if (Def_Pok.pkm_type == Fire) begin
			Full_EXP_for_defend = 'd59;
		end else if (Def_Pok.pkm_type == Water) begin
			Full_EXP_for_defend = 'd55;
		end else begin	//  if (MY_Pok.pkm_type == Electric) begin
			Full_EXP_for_defend = 'd51;
		end 
	end
end


always_comb begin
    if (MY_Pok.stage == Lowest) begin
		if (MY_Pok.pkm_type == Grass) begin
			evolution_atk_for_my = 'd94;
		end else if (MY_Pok.pkm_type == Fire) begin
			evolution_atk_for_my = 'd96;
		end else if (MY_Pok.pkm_type == Water) begin
			evolution_atk_for_my = 'd89;
		end else  begin  //  if (Def_Pok.pkm_type == Electric) begin
			evolution_atk_for_my = 'd97;
		end 
	end else  begin// if (Def_Pok.stage == Middle) begin
		if (MY_Pok.pkm_type == Grass) begin
			evolution_atk_for_my = 'd123;
		end else if (MY_Pok.pkm_type == Fire) begin
			evolution_atk_for_my = 'd127;
		end else if (MY_Pok.pkm_type == Water) begin
			evolution_atk_for_my = 'd113;
		end else begin	//  if (MY_Pok.pkm_type == Electric) begin
			evolution_atk_for_my = 'd124;
		end 
	end
end

always_comb begin
    if (Def_Pok.stage == Lowest) begin
		if (Def_Pok.pkm_type == Grass) begin
			evolution_atk_for_defend = 'd94;
		end else if (Def_Pok.pkm_type == Fire) begin
			evolution_atk_for_defend = 'd96;
		end else if (Def_Pok.pkm_type == Water) begin
			evolution_atk_for_defend = 'd89;
		end else  begin  //  if (Def_Pok.pkm_type == Electric) begin
			evolution_atk_for_defend = 'd97;
		end 
	end else  begin// if (Def_Pok.stage == Middle) begin
		if (Def_Pok.pkm_type == Grass) begin
			evolution_atk_for_defend = 'd123;
		end else if (Def_Pok.pkm_type == Fire) begin
			evolution_atk_for_defend = 'd127;
		end else if (Def_Pok.pkm_type == Water) begin
			evolution_atk_for_defend = 'd113;
		end else begin	//  if (MY_Pok.pkm_type == Electric) begin
			evolution_atk_for_defend = 'd124;
		end 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		DEF_ID <= 'd0;
	end else if (inf.id_valid && Current_state == ST_ATTACK ) begin
		DEF_ID <= inf.D.d_id ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		My_id <= 'd0;
	end else if (inf.id_valid && Current_state == ST_IN) begin
		My_id <= inf.D.d_id[0] ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		Pokemon_type <= No_type;
	end else if (inf.type_valid) begin
		Pokemon_type <= inf.D.d_type[0] ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		Cur_item <= No_item;
	end else if (inf.item_valid) begin
		Cur_item <= inf.D.d_item[0] ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		My_money <= 'd0;
	end else if (inf.amnt_valid) begin
		My_money <= inf.D.d_money ; 
	end
end



// ====== Communicate with bridge (OUTPUT)==========
always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		read_id <= 'd0 ;
	end else if (inf.id_valid && Current_state == ST_IN ) begin
		read_id <= 'd1 ;
	end else if (inf.C_out_valid)begin
		read_id <= 'd0 ;
	end
end

always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		read_def_id <= 'd0 ;
	end else if ( inf.act_valid ) begin
		if (inf.D.d_act == Attack)
			read_def_id <= 'd1 ;
	end else if (inf.C_out_valid && read_id=='d0 )begin   //   've read "new player's data " 
		read_def_id <= 'd0 ;
	end
end


// ====== Communicate with bridge (INPUT)==========
always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		MY_bag    		 <= 'd0 ; 
	end else if (inf.C_out_valid && new_player) begin             ///    out_valid is splited into three situation  1: read_info                 //  need a method to deal with
																								//    2: Write_back last_info
																								//	  3: defender's info
		MY_bag[31:28]    		 <= inf.C_data_r[7:4] ;
		MY_bag[27:24]     		 <= inf.C_data_r[3:0] ;
		MY_bag[23:20]     		 <= inf.C_data_r[15:12] ;
		MY_bag[19:16]     		 <= inf.C_data_r[11:8] ;
		MY_bag[15:14]  			 <= inf.C_data_r[23:22] ;
		MY_bag[13:0 ]  			 <= {inf.C_data_r[21:20], inf.C_data_r[19:16], inf.C_data_r[31:24]  };
	end else if (  Current_state == ST_BUY) begin
		if (inf.complete && inf.err_msg == No_Err ) begin
		
			MY_bag.money <= MY_bag.money - need_or_sell_money ; 
			
			if ( type_or_item_valid == 1)begin
				if (Cur_item == Berry)begin
					MY_bag[31:28]    <=  MY_bag[31:28] + 'd1 ;
				end else if (Cur_item == Medicine)begin
					MY_bag[27:24]    <=  MY_bag[27:24] + 'd1 ;
				end else if (Cur_item == Candy ) begin
					MY_bag[23:20]    <=  MY_bag[23:20] + 'd1 ;
				end else if (Cur_item == Bracer )begin
					MY_bag[19:16]    <=  MY_bag[19:16] + 'd1 ;
				end else if (Cur_item == Water_stone )begin
					MY_bag[15:14]    <=  'd1 ;
				end else if (Cur_item == Fire_stone )begin
					MY_bag[15:14]    <=  'd2 ;
				end else if (Cur_item == Thunder_stone )begin
					MY_bag[15:14]    <=  'd3 ;
				end 
			end 
		end
	end else if (  Current_state == ST_SELL) begin
		if (inf.complete && inf.err_msg == No_Err ) begin
		
			MY_bag.money <=  MY_bag.money + need_or_sell_money ; 
			
			if ( type_or_item_valid == 1) begin
				if (Cur_item == Berry) begin
					MY_bag[31:28]    <=  MY_bag[31:28] - 'd1 ;
				end else if (Cur_item == Medicine) begin
					MY_bag[27:24]    <=  MY_bag[27:24] - 'd1 ;
				end else if (Cur_item == Candy ) begin
					MY_bag[23:20]    <=  MY_bag[23:20] - 'd1 ;
				end else if (Cur_item == Bracer ) begin
					MY_bag[19:16]    <=  MY_bag[19:16] - 'd1 ;
				end else begin
					MY_bag[15:14]    <=  'd0 ;
				end
				// end else if (Cur_item == Water_stone )begin
					// MY_bag[15:14]    <=  'd1 ;
				// end else if (Cur_item == Fire_stone )begin
					// MY_bag[15:14]    <=  'd2 ;
				// end else if (Cur_item == Thunder_stone )begin
					// MY_bag[15:14]    <=  'd3 ;
				// end 
			end 
		end
	end else if (   Current_state == ST_DEPOSIT) begin
		if (inf.complete ) begin
				MY_bag[13: 0]    <= MY_bag[13: 0] +  My_money ;   
		end
	end else if (  Current_state == ST_USE_ITEM) begin
		if (inf.complete && inf.err_msg == No_Err) begin
			if (Cur_item == Berry)
				MY_bag[31:28]    <=  MY_bag[31:28] - 'd1 ;
			else if (Cur_item == Medicine)
				MY_bag[27:24]    <=  MY_bag[27:24] - 'd1 ;
			else if (Cur_item == Candy )
				MY_bag[23:20]    <=  MY_bag[23:20] - 'd1 ;
			else if (Cur_item == Bracer )
				MY_bag[19:16]    <=  MY_bag[19:16] - 'd1 ;
			else //   using one of stone 
				MY_bag[15:14]    <= 'd0 ;
		end	
	
	end
end

always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		MY_Pok    <= 'd0 ;
	end else if (inf.C_out_valid && new_player) begin   //  is_defender  or is_attacker
			MY_Pok[31:28]    		 <= inf.C_data_r[39:36] ;
			MY_Pok[27:24]    		 <= inf.C_data_r[35:32] ;
			MY_Pok[23:16]  			 <= inf.C_data_r[47:40] ;
			MY_Pok[15: 8]  			 <= inf.C_data_r[55:48] ;
			MY_Pok[7 : 0]  			 <= inf.C_data_r[63:56] ;
	end else if ( Current_state == ST_BUY) begin
		if (inf.complete == 'd1 && inf.err_msg =='d0 && type_or_item_valid =='d2 ) begin
			if (Pokemon_type == Grass)
				MY_Pok <=  {4'd1 , Pokemon_type , 8'd128 , 8'd63 , 8'd0 } ; 
			else if (Pokemon_type == Fire) 
				MY_Pok <=  {4'd1 , Pokemon_type , 8'd119 , 8'd64 , 8'd0 } ; 
			else if (Pokemon_type == Water)
				MY_Pok <=  {4'd1 , Pokemon_type , 8'd125 , 8'd60 , 8'd0 } ; 
			else if (Pokemon_type == Electric)
				MY_Pok <=  {4'd1 , Pokemon_type , 8'd122 , 8'd65 , 8'd0 } ; 
			else //if (Pokemon_type == Normal)
				MY_Pok <=  {4'd1 , Pokemon_type , 8'd124 , 8'd62 , 8'd0 } ; 
			// else 
		end 
	end else if ( Current_state == ST_SELL) begin
		if (inf.complete == 'd1 && inf.err_msg =='d0 && type_or_item_valid =='d2 )
			MY_Pok <= 'd0 ;
	end else if ( Current_state == ST_USE_ITEM) begin
		if (inf.complete == 'd1 && inf.err_msg =='d0 ) begin
			if (Cur_item == Berry) begin
				if (MY_Pok.hp + 'd32  > Full_HP)
					MY_Pok.hp <= Full_HP ;
				else 
					MY_Pok.hp <= MY_Pok.hp + 'd32 ;
			end else if (Cur_item == Medicine) begin
				MY_Pok.hp <= Full_HP ; 
			end else if (Cur_item == Candy) begin
				if (MY_Pok.exp + 'd15  >=  Full_EXP)
					if (MY_Pok.pkm_type == Normal)
						MY_Pok.exp <= 'd29 ;
					else begin
						MY_Pok.exp <= 'd0 ;
						if (MY_Pok.stage == Lowest)
							MY_Pok.stage <= Middle ;
						else
							MY_Pok.stage <= Highest ;
						MY_Pok.hp    <= Full_HP ; 
						MY_Pok.atk    <= evolution_atk_for_my ;
					end
				else begin
					if (MY_Pok.stage != Highest)
						MY_Pok.exp <= MY_Pok.exp + 'd15 ;
				end
			end else if (Cur_item == Bracer) begin
				if (!bracer_used)
					MY_Pok.atk <= MY_Pok.atk + 'd32 ; 
			end else if (MY_Pok.pkm_type == Normal && MY_Pok.exp == 'd29)begin
				MY_Pok.stage    <= Highest ;  
				MY_Pok.exp      <= 'd0 ;
				if (Cur_item == Water_stone) begin
					MY_Pok.pkm_type <= Water ;  
					MY_Pok.hp  		<= 'd245 ;
					MY_Pok.atk 		<= 'd113 ;
				end else if (Cur_item == Fire_stone) begin
					MY_Pok.pkm_type <= Fire ;  
					MY_Pok.hp  		<= 'd225 ;
					MY_Pok.atk 		<= 'd127 ;
				end else begin// if (Cur_item == Thunder_stone) begin
					MY_Pok.pkm_type <= Electric ;  
					MY_Pok.hp  		<= 'd235 ;
					MY_Pok.atk 		<= 'd124 ;
				end 
			end
			// end else if (Cur_item == Water_stone) begin
				
			// end else if (Cur_item == Fire_stone) begin
			
			// end else if (Cur_item == Thunder_stone) begin
			
			// end 
		end
	end else if ( Current_state == ST_ATTACK) begin
		if (inf.complete == 'd1 && inf.err_msg =='d0 ) begin
			if (bracer_used)
				MY_Pok.atk <= MY_Pok.atk -'d32 ;  
				
			if ( MY_Pok.exp + EXP_gain_from_attack >= Full_EXP )begin
				if (MY_Pok.pkm_type == Normal)begin
					
					MY_Pok.exp   <=  'd29 ;
				end else begin
					MY_Pok.exp   <=  'd0 ;
					MY_Pok.hp    <= Full_HP ; 
					MY_Pok.atk   <= evolution_atk_for_my ; 
					if (MY_Pok.stage == Lowest) begin
						MY_Pok.stage <=  Middle ;
					end else begin
						MY_Pok.stage <=  Highest ; 
					end
					
				end
			end else begin
				if (MY_Pok.stage != Highest)
					MY_Pok.exp <=  MY_Pok.exp + EXP_gain_from_attack ;
			end
		end
	
	end
end

always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		Def_Pok    		 <= 'd0 ;
	end else if (inf.C_out_valid) begin
			Def_Pok[31:28]    		 <= inf.C_data_r[39:36] ;
			Def_Pok[27:24]      	 <= inf.C_data_r[35:32] ;
			Def_Pok[23:16] 			 <= inf.C_data_r[47:40] ;
			Def_Pok[15: 8] 			 <= inf.C_data_r[55:48] ;
			Def_Pok[7 : 0] 			 <= inf.C_data_r[63:56] ;
			
	end else if (Current_state == ST_ATTACK && inf.complete && inf.err_msg == No_Err ) begin
		if ( Def_Pok.exp + EXP_gain_from_defend >= Full_EXP_for_defend )begin
			if (Def_Pok.pkm_type == Normal)begin
				Def_Pok.exp   <=  'd29 ;
				if (Def_Pok.hp < my_atk)
					Def_Pok.hp    <= 'd0 ;
				else
					Def_Pok.hp    <= Def_Pok.hp - my_atk ; 
			end else begin
				Def_Pok.exp   <=  'd0 ;
				Def_Pok.hp    <=  Full_HP_for_defend ; 
				Def_Pok.atk   <= evolution_atk_for_defend ; 
				if (Def_Pok.stage == Lowest) begin
					Def_Pok.stage <=  Middle ;
				end else begin
					Def_Pok.stage <=  Highest ; 
				end
			end
		end else begin
			if (Def_Pok.hp < my_atk)
				Def_Pok.hp    <= 'd0 ;
			else
				Def_Pok.hp    <= Def_Pok.hp - my_atk ;
				
			if (Def_Pok.stage != Highest)
				Def_Pok.exp <=  Def_Pok.exp + EXP_gain_from_defend ;
		end
	end
end

always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		Def_bag    		 <= 'd0 ;
	end else if (inf.C_out_valid) begin
		Def_bag    <= inf.C_data_r[31:0] ;
	end
end


// ======== OUTPUT =====================
always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.out_valid <= 'd0 ; 
		inf.out_info  <= 'd0 ; 
	end else if (Current_state == ST_OUTPUT) begin
		if (Attack_flag) begin
			if (inf.err_msg == No_Err) begin
				if (inf.C_out_valid)begin
					inf.out_valid <= 'd1 ; 
					inf.out_info <= {MY_Pok, Def_Pok } ; 
				end
			end else begin
				inf.out_info  <= 'd0 ;
				inf.out_valid <= 'd1 ; 
			end
		end else begin
			inf.out_valid <= 'd1 ; 
			if (inf.err_msg == No_Err) begin
				inf.out_info <= {MY_bag, MY_Pok } ; 
			end else 
				inf.out_info <= 'd0 ;
		end
	end else begin
		inf.out_valid <= 'd0 ; 
		inf.out_info  <= 'd0 ; 
	end

end

always_ff@ (posedge clk , negedge inf.rst_n)begin   // list all the situation of err_msg ; 
	if (!inf.rst_n)begin
		inf.err_msg <= No_Err; 
	end else if (Current_state == ST_BUY) begin
		if (new_player || wait_valid)begin
			inf.err_msg <= No_Err ; 
		end else if (MY_bag[13:0] < need_or_sell_money ) begin
			inf.err_msg <= Out_of_money ; 
		end else if ( (  type_or_item_valid == 'd2 )&& MY_Pok != 'd0) begin
			inf.err_msg <= Already_Have_PKM ;
		end else if ( (  type_or_item_valid == 'd1) && ( (Cur_item == Berry  && MY_bag[31:28] == 'd15 )||  (Cur_item == Medicine && MY_bag[27:24] == 'd15) || (Cur_item == Candy && MY_bag[23:20] == 'd15) || (Cur_item == Bracer && MY_bag[19:16] == 'd15) || ( (Cur_item == Water_stone || Cur_item == Fire_stone || Cur_item == Thunder_stone) && MY_bag[15:14] != 'd0)  ) ) begin
			inf.err_msg <= Bag_is_full ; 
		end else begin
			inf.err_msg <= No_Err ;
		end
	end else if (Current_state == ST_SELL) begin
		if (new_player || wait_valid )
			inf.err_msg <= No_Err ; 
		else if (  ( type_or_item_valid == 'd2 ) && MY_Pok == 'd0)
			inf.err_msg <= Not_Having_PKM ; 
		else if (  ( type_or_item_valid == 'd1 )  &&( (Cur_item == Berry  && MY_bag[31:28] == 'd0 )||  (Cur_item == Medicine && MY_bag[27:24] == 'd0) ||  (Cur_item == Candy && MY_bag[23:20] == 'd0) || (Cur_item == Bracer && MY_bag[19:16] == 'd0) || (Cur_item == Water_stone &&  MY_bag[15:14] != 'd1  ) || (Cur_item == Fire_stone && MY_bag[15:14] != 'd2 ) || (Cur_item  == Thunder_stone && MY_bag[15:14] != 'd3)   ) )
			inf.err_msg <= Not_Having_Item ; 
		else if (  ( type_or_item_valid == 'd2 ) && MY_Pok[31:28] == 4'b0001)
			inf.err_msg <= Has_Not_Grown ;
		else 
			inf.err_msg <= No_Err ; 
	end else if (Current_state == ST_USE_ITEM) begin
		if (new_player || wait_valid)
			inf.err_msg <= No_Err ;
		else if (   MY_Pok =='d0 ) // maybe can use type to define whether having pokemon or not 
			inf.err_msg <= Not_Having_PKM ;
		else if (  ( (Cur_item == Berry  && MY_bag[31:28] == 'd0 )||  (Cur_item == Medicine && MY_bag[27:24] == 'd0) || (Cur_item == Candy && MY_bag[23:20] == 'd0) || (Cur_item== Bracer && MY_bag[19:16] == 'd0) || (Cur_item == Water_stone &&  MY_bag[15:14] != 'd1  ) || (Cur_item == Fire_stone && MY_bag[15:14] != 'd2 ) || (Cur_item == Thunder_stone && MY_bag[15:14] != 'd3)   )  )
			inf.err_msg <= Not_Having_Item ; 
		else 
			inf.err_msg <= No_Err ;
	end else if (Current_state == ST_ATTACK) begin
		if (new_player || has_def_player  )
			inf.err_msg <= No_Err ;
		else if ( (Def_Pok == 'd0 && !wait_valid)   || MY_Pok == 'd0)
			inf.err_msg <= Not_Having_PKM ;
		else if ( ( (Def_Pok.hp == 'd0 || MY_Pok.hp == 'd0)   && !wait_valid))
			inf.err_msg <= HP_is_Zero ;
		// else 
			// inf.err_msg <= No_Err ;
	end else if (Current_state == ST_IN)begin
		inf.err_msg <= No_Err ; 
	end

end

always_ff@ (posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.complete <= 'd0 ; 
	end else if ( (inf.err_msg != No_Err )  || Current_state == ST_IN ||  new_player || has_def_player || wait_valid)begin    // complete action and go to the output state 
		inf.complete <= 'd0 ; 
	end else begin
		inf.complete <= 'd1 ; 
	end
end



//  ========   FSM  =====================
always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		Current_state <= ST_IN ; 
	end else begin
		Current_state <= Next_state ; 
	end
end

always_comb begin
	case(Current_state)
		ST_IN : begin
			if (inf.act_valid ) begin
				if (inf.D.d_act == Buy) begin
					Next_state = ST_BUY ;
				end else if (inf.D.d_act == Sell) begin
					Next_state = ST_SELL ;
				end else if (inf.D.d_act == Deposit) begin
					Next_state = ST_DEPOSIT ;
				end else if (inf.D.d_act == Check) begin
					Next_state = ST_CHECK ;
				end else if (inf.D.d_act == Use_item) begin
					Next_state = ST_USE_ITEM ;
				end else if (inf.D.d_act == Attack) begin
					Next_state = ST_ATTACK ;
				end else begin   // no_action   
					Next_state = ST_IN ;
				end
			end else begin
				Next_state = ST_IN ; 
			end
		end
		
		ST_BUY: begin
			if (inf.complete)begin
				Next_state = ST_OUTPUT ; 
			end else begin
				Next_state = ST_BUY ; 
			end
		end
		ST_SELL : begin
			if (inf.complete)begin
				Next_state = ST_OUTPUT ; 
			end else begin
				Next_state = ST_SELL ; 
			end
		end
		
		ST_DEPOSIT: begin
			if (inf.complete)begin
				Next_state = ST_OUTPUT ; 
			end else begin
				Next_state = ST_DEPOSIT ; 
			end
		end
		ST_CHECK : begin
			if (inf.complete)begin
				Next_state = ST_OUTPUT ; 
			end else begin
				Next_state = ST_CHECK ; 
			end
		end
		
		ST_USE_ITEM: begin
			if (inf.complete)begin
				Next_state = ST_OUTPUT ; 
			end else begin
				Next_state = ST_USE_ITEM ; 
			end
		end
		ST_ATTACK : begin
			if (inf.complete)begin
				Next_state = ST_OUTPUT ; 
			end else begin
				Next_state = ST_ATTACK ; 
			end
		end
		
		ST_OUTPUT: begin
			if (inf.C_out_valid || inf.complete == 'd0  || Attack_flag == 'd0 )  //   write_def  ||   err_msg  ||  not_attack 
				Next_state = ST_IN ; 
			else
				Next_state = ST_OUTPUT ; 
		end
	
	default : Next_state = ST_IN ; 
	endcase
end




endmodule