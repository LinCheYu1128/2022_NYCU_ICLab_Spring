`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_PKG.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter SEED = 67 ;

int patcount, i, j, k, cycles, total_cycles;
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM[ ((65536+256*8)-1) : (65536+0)];

Player_Info golden_info, defender_info; 
Player_id golden_id, defender_id;
Action golden_act;
Item golden_item;
PKM_Type golden_type;
Error_Msg golden_err;
PKM_Item buy_pkm_item_flag;
Money golden_money;
logic golden_complete;

logic goldem_bracer_effect;

class rand_gap;	
	rand int gap;
	function new (int seed);
		this.srandom(seed);		
	endfunction 
	constraint limit { gap inside {[1:5]}; }
endclass

class rand_delay;	
	rand int delay;
	function new (int seed);
		this.srandom(seed);		
	endfunction 
	constraint limit { delay inside {[1:9]}; }
endclass

class rand_id;	
	rand Player_id player_id;
	function new (int seed);
		this.srandom(seed);		
	endfunction 
	constraint limit { player_id inside {[0:255]}; }
endclass

class rand_act;	
	rand Action act;
	function new (int seed);
		this.srandom(seed);		
	endfunction 
	constraint limit { act inside {Buy, Sell, Deposit, Use_item, Check, Attack}; }
endclass

class rand_item;	
	rand Item item;
	function new (int seed);
		this.srandom(seed);		
	endfunction 
	constraint limit { item inside {Berry, Medicine, Candy, Bracer, Water_stone, Fire_stone, Thunder_stone}; }
endclass

class rand_item_or_pkm;	
	rand PKM_Item item_or_pkm;
	function new (int seed);
		this.srandom(seed);		
	endfunction 
	constraint limit { item_or_pkm inside {item, pkm}; }
endclass

class rand_type;	
	rand Item pkm_type;
	function new (int seed);
		this.srandom(seed);		
	endfunction 
	constraint limit { pkm_type inside {Grass, Fire, Water, Electric, Normal}; }
endclass

rand_gap r_gap = new(SEED);
rand_delay r_delay = new(SEED);
rand_id r_id = new(SEED);
rand_act r_act = new(SEED);
rand_item r_item = new(SEED);
rand_type r_type = new(SEED);
rand_item_or_pkm r_choose = new(SEED);

initial  $readmemh(DRAM_p_r, golden_DRAM);

initial begin
    inf.rst_n = 1'b1 ;
	inf.id_valid = 1'b0 ;
	inf.act_valid = 1'b0 ;
    inf.item_valid = 1'b0 ;
	inf.type_valid = 1'b0 ;
	inf.amnt_valid = 1'b0 ;
	inf.D = 'bx;
    force clk = 0 ;
    reset_task;
    
    @(negedge clk);
    patcount = 0;
    // golden_id = 50;
    golden_item = Berry;

    for(j=0; j<256; j=j+1)begin

        // r_id.randomize();
        golden_id = j;//r_id.player_id;
        give_id_task;
        goldem_bracer_effect = 0;
        rand_gap_task;
        // $display("Change Player id : %d", golden_id);
        if(golden_id==0)begin
            get_info_task;
            golden_act = Buy; 
            give_action_task;
            rand_gap_task;
            buy_pkm_item_flag = item;
            golden_item = Bracer;
            give_item_task;
            cal_ans_task;
            wait_outvalid_task;
            // patcount = patcount + 1;
            write_back_task;
            rand_delay_task;
        end
        for(i=0; i < 3; i=i+1)begin
            if     ( patcount % 36 ==  0) golden_act = Buy;
            else if( patcount % 36 ==  1) golden_act = Buy;
            else if( patcount % 36 ==  2) golden_act = Sell;
            else if( patcount % 36 ==  3) golden_act = Buy;
            else if( patcount % 36 ==  4) golden_act = Deposit;
            else if( patcount % 36 ==  5) golden_act = Buy;
            else if( patcount % 36 ==  6) golden_act = Use_item;
            else if( patcount % 36 ==  7) golden_act = Buy;
            else if( patcount % 36 ==  8) golden_act = Check;
            else if( patcount % 36 ==  9) golden_act = Buy;
            else if( patcount % 36 == 10) golden_act = Attack;
            else if( patcount % 36 == 11) golden_act = Sell;
            else if( patcount % 36 == 12) golden_act = Sell;
            else if( patcount % 36 == 13) golden_act = Deposit;
            else if( patcount % 36 == 14) golden_act = Sell;
            else if( patcount % 36 == 15) golden_act = Use_item;
            else if( patcount % 36 == 16) golden_act = Sell;
            else if( patcount % 36 == 17) golden_act = Check;
            else if( patcount % 36 == 18) golden_act = Sell;
            else if( patcount % 36 == 19) golden_act = Attack;
            else if( patcount % 36 == 20) golden_act = Deposit;
            else if( patcount % 36 == 21) golden_act = Deposit;
            else if( patcount % 36 == 22) golden_act = Use_item;
            else if( patcount % 36 == 23) golden_act = Deposit;
            else if( patcount % 36 == 24) golden_act = Check;
            else if( patcount % 36 == 25) golden_act = Deposit;
            else if( patcount % 36 == 26) golden_act = Attack;
            else if( patcount % 36 == 27) golden_act = Use_item;
            else if( patcount % 36 == 28) golden_act = Use_item;
            else if( patcount % 36 == 29) golden_act = Check;
            else if( patcount % 36 == 30) golden_act = Use_item;
            else if( patcount % 36 == 31) golden_act = Attack;
            else if( patcount % 36 == 32) golden_act = Check;
            else if( patcount % 36 == 33) golden_act = Check;
            else if( patcount % 36 == 34) golden_act = Attack;
            else if( patcount % 36 == 35) golden_act = Attack;
            // else if( patcount % 40 == 36) golden_act = Buy;
            // else if( patcount % 40 == 37) golden_act = Use_item;
            // else if( patcount % 40 == 38) golden_act = Use_item;
            // else if( patcount % 40 == 39) golden_act = Attack;

            get_info_task;
            // r_act.randomize();
            // golden_act = r_act.act;
            give_action_task;
            if(golden_act != Check) rand_gap_task;
            case (golden_act)
                Buy:begin
                    // $display("Buy");
                    r_choose.randomize();
                    if(patcount%36 > 1) buy_pkm_item_flag = pkm;
                    else buy_pkm_item_flag = item;
                    // buy_pkm_item_flag = r_choose.item_or_pkm;
                    if(buy_pkm_item_flag == item)begin
                        // if(golden_item == Berry) golden_item = Medicine;
                        // else if(golden_item == Medicine) golden_item = Candy;
                        // else if(golden_item == Candy) golden_item = Bracer;
                        // else if(golden_item == Bracer) golden_item = Water_stone;
                        // else if(golden_item == Water_stone) golden_item = Fire_stone;
                        // else if(golden_item == Fire_stone) golden_item = Thunder_stone;
                        // else if(golden_item == Thunder_stone) golden_item = Berry;
                        r_item.randomize();
                        golden_item = r_item.item;
                        give_item_task;
                    end 
                    else begin
                        r_type.randomize();
                        golden_type = r_type.pkm_type;
                        give_type_task;
                    end  
                end
                Sell:begin
                    // $display("Sell");
                    r_choose.randomize();
                    buy_pkm_item_flag = r_choose.item_or_pkm;
                    if(buy_pkm_item_flag == item)begin
                        // r_item.randomize();
                        // golden_item = r_item.item;
                        if(golden_item == Berry) golden_item = Medicine;
                        else if(golden_item == Medicine) golden_item = Candy;
                        else if(golden_item == Candy) golden_item = Bracer;
                        else if(golden_item == Bracer) golden_item = Water_stone;
                        else if(golden_item == Water_stone) golden_item = Fire_stone;
                        else if(golden_item == Fire_stone) golden_item = Thunder_stone;
                        else if(golden_item == Thunder_stone) golden_item = Berry;
                        give_item_task;
                    end
                    else begin
                        give_sell_pkm_task;
                    end   
                end
                Deposit:begin
                    // $display("Deposit");
                    give_deposit_task;
                end
                Use_item:begin
                    // $display("Use_item");
                    if(patcount%36 == 30) golden_item = Bracer;
                    else if(patcount%40 == 28) golden_item = Candy;
                    else begin
                        // r_item.randomize();
                        // golden_item = r_item.item;
                        if(golden_item == Berry) golden_item = Medicine;
                        else if(golden_item == Medicine) golden_item = Candy;
                        else if(golden_item == Candy) golden_item = Bracer;
                        else if(golden_item == Bracer) golden_item = Water_stone;
                        else if(golden_item == Water_stone) golden_item = Fire_stone;
                        else if(golden_item == Fire_stone) golden_item = Thunder_stone;
                        else if(golden_item == Thunder_stone) golden_item = Berry;
                    end 
                    give_item_task;
                end
                Check:begin
                    // $display("Check");
                end
                Attack:begin
                    do begin
                        if(patcount % 36 == 31)begin
                            do begin
                                r_id.randomize();
                                defender_id = r_id.player_id;
                                get_def_info_task;
                            end while (defender_info.pkm_info.pkm_type==No_type);
                        end
                        else begin
                            r_id.randomize();
                            defender_id = r_id.player_id;
                            get_def_info_task;
                        end
                    end while (defender_id == golden_id) ;
                    // $display("Attack ; defender_id = %d", defender_id);
                    
                    give_def_id_task;
                end
            endcase

            cal_ans_task;
            wait_outvalid_task;
            // $display("Pass Action %4d", patcount);
            patcount = patcount + 1;
            write_back_task;
            rand_delay_task;
        end
    end
    // ================================
    // test bracer effect when sell pkm
    // ================================
    golden_act = Use_item; 
    give_action_task;
    rand_gap_task;
    buy_pkm_item_flag = item;
    golden_item = Bracer;
    give_item_task;
    cal_ans_task;
    wait_outvalid_task;
    patcount = patcount + 1;
    write_back_task;
    rand_delay_task;

    golden_act = Sell; 
    give_action_task;
    rand_gap_task;
    buy_pkm_item_flag = pkm;
    give_sell_pkm_task;
    cal_ans_task;
    wait_outvalid_task;
    patcount = patcount + 1;
    write_back_task;
    rand_delay_task;

    golden_act = Buy; 
    give_action_task;
    rand_gap_task;
    buy_pkm_item_flag = pkm;
    golden_type = Grass;
    give_type_task;
    cal_ans_task;
    wait_outvalid_task;
    patcount = patcount + 1;
    write_back_task;
    // ================================
    // repeat(10)@(negedge clk);
    // pass_task;
    $finish;
end

//================================================================
// get output task
//================================================================
task wait_outvalid_task; begin
	cycles = 0 ;
	while (inf.out_valid!==1) begin
		cycles = cycles + 1 ;
		// if (cycles==1200) begin
        //     $display("Wrong Answer");
        //     // $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        //     // $display ("                                             The execution latency is limited in 1200 cycles.                                               ");
        //     // $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        //     // #(100);
        //     $finish;
		// end
		@(negedge clk);
	end
	total_cycles = total_cycles + cycles ;
    cycles = 0;
    // while (inf.out_valid===1) begin
        // cycles = cycles + 1 ;
        // if (cycles > 1) begin
			// $display ("--------------------------------------------------");
			// $display ("          Outvalid is more than 1 cycles          ");
			// $display ("--------------------------------------------------");
	        // #(100);
			// $finish;
		// end
        // else begin
    if(golden_act == Attack)begin
        if(inf.complete === golden_complete)begin
            if(golden_complete)begin
                if((inf.err_msg!==golden_err) || (inf.out_info!=={golden_info.pkm_info, defender_info.pkm_info}))begin
                    $display("Wrong Answer");
                    // $display("-----------------------------------------------------------");
                    // $display("                         outinfo  wrong                   ");
                    // $display("    Golden complete : %6d    your complete : %6d ", golden_complete, inf.complete);
                    // $display("    Golden err_msg  : %6d    your err_msg  : %6d ", golden_err, inf.err_msg);
                    // $display("    Golden info     : %16h  your info     : %16h   ", {golden_info.pkm_info, defender_info.pkm_info}, inf.out_info);
                    // $display("-----------------------------------------------------------");
                    // #(100);
                    $finish;
                end
            end
            else begin
                if((inf.err_msg!==golden_err) || (inf.out_info!==0))begin
                    $display("Wrong Answer");
                    // $display("-----------------------------------------------------------");
                    // $display("              wrong (err or info should be 0)              ");
                    // $display("    Golden complete : %6d    your complete : %6d ", golden_complete, inf.complete);
                    // $display("    Golden err_msg  : %6d    your err_msg  : %6d ", golden_err, inf.err_msg);
                    // $display("    Golden info     : %16h  your info     : %16h   ", 0, inf.out_info);
                    // $display("-----------------------------------------------------------");
                    // #(100);
                    $finish;
                end
            end
        end
        else begin
            $display("Wrong Answer");
            // $display("-----------------------------------------------------------");
            // $display("                  Complete is wrong                        ");
            // $display("-----------------------------------------------------------");
            // #(100);
            $finish;
        end
    end
    else begin
        if(inf.complete === golden_complete)begin
            if(golden_complete)begin
                if((inf.err_msg !== golden_err) || (inf.out_info !== golden_info))begin
                    $display("Wrong Answer");
                    // $display("-----------------------------------------------------------");
                    // $display("                         outinfo  wrong                   ");
                    // $display("    Golden complete : %6d    your complete : %6d ", golden_complete, inf.complete);
                    // $display("    Golden err_msg  : %6d    your err_msg  : %6d ", golden_err, inf.err_msg);
                    // $display("    Golden info     : %16h  your info     : %16h   ", golden_info, inf.out_info);
                    // $display("-----------------------------------------------------------");
                    // #(100);
                    $finish;
                end
            end
            else begin
                if((inf.err_msg !== golden_err) || (inf.out_info !== 0))begin
                    $display("Wrong Answer");
                    // $display("-----------------------------------------------------------");
                    // $display("              wrong (err or info should be 0)              ");
                    // $display("    Golden complete : %6d    your complete : %6d ", golden_complete, inf.complete);
                    // $display("    Golden err_msg  : %6d    your err_msg  : %6d ", golden_err, inf.err_msg);
                    // $display("    Golden info     : %16h  your info     : %16h   ", 0, inf.out_info);
                    // $display("-----------------------------------------------------------");
                    // #(100);
                    $finish;
                end
            end
        end
        else begin
            $display("Wrong Answer");
            // $display("-----------------------------------------------------------");
            // $display("                  Complete is wrong                        ");
            // $display("-----------------------------------------------------------");
            // #(100);
            $finish;
        end
    end
    // end
    @(negedge clk);
    // end
end endtask

task get_def_info_task; begin
    // bag
	defender_info.bag_info.berry_num    = golden_DRAM[65536+defender_id*8 + 0][7:4] ;
    defender_info.bag_info.medicine_num = golden_DRAM[65536+defender_id*8 + 0][3:0] ;
    defender_info.bag_info.candy_num    = golden_DRAM[65536+defender_id*8 + 1][7:4] ;
    defender_info.bag_info.bracer_num   = golden_DRAM[65536+defender_id*8 + 1][3:0] ;
    defender_info.bag_info.stone        = golden_DRAM[65536+defender_id*8 + 2][7:6] ;
    defender_info.bag_info.money        = {golden_DRAM[65536+defender_id*8 + 2][5:0], golden_DRAM[65536+defender_id*8 + 3]} ;
    // pkm
    defender_info.pkm_info.stage    = golden_DRAM[65536+defender_id*8 + 4][7:4] ;
    defender_info.pkm_info.pkm_type = golden_DRAM[65536+defender_id*8 + 4][3:0] ;
    defender_info.pkm_info.hp       = golden_DRAM[65536+defender_id*8 + 5];
    defender_info.pkm_info.atk      = golden_DRAM[65536+defender_id*8 + 6];
    defender_info.pkm_info.exp      = golden_DRAM[65536+defender_id*8 + 7];
end endtask

task get_info_task; begin
    // bag
	golden_info.bag_info.berry_num    = golden_DRAM[65536+golden_id*8 + 0][7:4] ;
    golden_info.bag_info.medicine_num = golden_DRAM[65536+golden_id*8 + 0][3:0] ;
    golden_info.bag_info.candy_num    = golden_DRAM[65536+golden_id*8 + 1][7:4] ;
    golden_info.bag_info.bracer_num   = golden_DRAM[65536+golden_id*8 + 1][3:0] ;
    golden_info.bag_info.stone        = golden_DRAM[65536+golden_id*8 + 2][7:6] ;
    golden_info.bag_info.money        = {golden_DRAM[65536+golden_id*8 + 2][5:0], golden_DRAM[65536+golden_id*8 + 3]} ;
    // pkm
    golden_info.pkm_info.stage    = golden_DRAM[65536+golden_id*8 + 4][7:4] ;
    golden_info.pkm_info.pkm_type = golden_DRAM[65536+golden_id*8 + 4][3:0] ;
    golden_info.pkm_info.hp       = golden_DRAM[65536+golden_id*8 + 5];
    golden_info.pkm_info.atk      = golden_DRAM[65536+golden_id*8 + 6];
    golden_info.pkm_info.exp      = golden_DRAM[65536+golden_id*8 + 7];

    bracer_effect_task;
end endtask

task bracer_effect_task; begin
    // calculate bracer effect
    if(goldem_bracer_effect)begin
        case (golden_info.pkm_info.pkm_type)
        Grass	: begin
            if(golden_info.pkm_info.stage == Lowest) 
                golden_info.pkm_info.atk = 95;
            else if(golden_info.pkm_info.stage == Middle) 
                golden_info.pkm_info.atk = 126;
            else 
                golden_info.pkm_info.atk = 155;
        end 
        Fire	:begin
            if(golden_info.pkm_info.stage == Lowest) 
                golden_info.pkm_info.atk = 96;
            else if(golden_info.pkm_info.stage == Middle) 
                golden_info.pkm_info.atk = 128;
            else 
                golden_info.pkm_info.atk = 159;
        end 
        Water	:begin
            if(golden_info.pkm_info.stage == Lowest) 
                golden_info.pkm_info.atk = 92;
            else if(golden_info.pkm_info.stage == Middle) 
                golden_info.pkm_info.atk = 121;
            else 
                golden_info.pkm_info.atk = 145;
        end 
        Electric:begin
            if(golden_info.pkm_info.stage == Lowest) 
                golden_info.pkm_info.atk = 97;
            else if(golden_info.pkm_info.stage == Middle) 
                golden_info.pkm_info.atk = 129;
            else 
                golden_info.pkm_info.atk = 156;
        end
        Normal	: begin
            golden_info.pkm_info.atk = 94;
        end  
        endcase  
    end
    else begin
        case (golden_info.pkm_info.pkm_type)
        Grass	: begin
            if(golden_info.pkm_info.stage == Lowest) 
               golden_info.pkm_info.atk = 63;
            else if(golden_info.pkm_info.stage == Middle) 
               golden_info.pkm_info.atk = 94;
            else 
               golden_info.pkm_info.atk = 123;
        end 
        Fire	:begin
            if(golden_info.pkm_info.stage == Lowest) 
               golden_info.pkm_info.atk = 64;
            else if(golden_info.pkm_info.stage == Middle) 
               golden_info.pkm_info.atk = 96;
            else 
               golden_info.pkm_info.atk = 127;
        end 
        Water	:begin
            if(golden_info.pkm_info.stage == Lowest) 
               golden_info.pkm_info.atk = 60;
            else if(golden_info.pkm_info.stage == Middle) 
               golden_info.pkm_info.atk = 89;
            else 
               golden_info.pkm_info.atk = 113;
        end 
        Electric:begin
            if(golden_info.pkm_info.stage == Lowest) 
               golden_info.pkm_info.atk = 65;
            else if(golden_info.pkm_info.stage == Middle) 
               golden_info.pkm_info.atk = 97;
            else 
               golden_info.pkm_info.atk = 124;
        end
        Normal	: begin
           golden_info.pkm_info.atk = 62;
        end  
        endcase  
    end
end endtask

task write_back_task; begin
    case (golden_info.pkm_info.pkm_type)
        Grass	: begin
            if(golden_info.pkm_info.stage == Lowest) 
               golden_info.pkm_info.atk = 63;
            else if(golden_info.pkm_info.stage == Middle) 
               golden_info.pkm_info.atk = 94;
            else 
               golden_info.pkm_info.atk = 123;
        end 
        Fire	:begin
            if(golden_info.pkm_info.stage == Lowest) 
               golden_info.pkm_info.atk = 64;
            else if(golden_info.pkm_info.stage == Middle) 
               golden_info.pkm_info.atk = 96;
            else 
               golden_info.pkm_info.atk = 127;
        end 
        Water	:begin
            if(golden_info.pkm_info.stage == Lowest) 
               golden_info.pkm_info.atk = 60;
            else if(golden_info.pkm_info.stage == Middle) 
               golden_info.pkm_info.atk = 89;
            else 
               golden_info.pkm_info.atk = 113;
        end 
        Electric:begin
            if(golden_info.pkm_info.stage == Lowest) 
               golden_info.pkm_info.atk = 65;
            else if(golden_info.pkm_info.stage == Middle) 
               golden_info.pkm_info.atk = 97;
            else 
               golden_info.pkm_info.atk = 124;
        end
        Normal	: begin
           golden_info.pkm_info.atk = 62;
        end  
    endcase
    // bag
	golden_DRAM[65536+golden_id*8 + 0][7:4]                                       = golden_info.bag_info.berry_num    ; 
    golden_DRAM[65536+golden_id*8 + 0][3:0]                                       = golden_info.bag_info.medicine_num ; 
    golden_DRAM[65536+golden_id*8 + 1][7:4]                                       = golden_info.bag_info.candy_num    ; 
    golden_DRAM[65536+golden_id*8 + 1][3:0]                                       = golden_info.bag_info.bracer_num   ; 
    golden_DRAM[65536+golden_id*8 + 2][7:6]                                       = golden_info.bag_info.stone        ; 
    {golden_DRAM[65536+golden_id*8 + 2][5:0],golden_DRAM[65536+golden_id*8 + 3]}  = golden_info.bag_info.money        ; 
    // pkm
    golden_DRAM[65536+golden_id*8 + 4][7:4]                                       = golden_info.pkm_info.stage        ; 
    golden_DRAM[65536+golden_id*8 + 4][3:0]                                       = golden_info.pkm_info.pkm_type     ; 
    golden_DRAM[65536+golden_id*8 + 5]                                            = golden_info.pkm_info.hp           ; 
    golden_DRAM[65536+golden_id*8 + 6]                                            = golden_info.pkm_info.atk          ; 
    golden_DRAM[65536+golden_id*8 + 7]                                            = golden_info.pkm_info.exp          ; 
    if(golden_act == Attack)begin
        // bag
        golden_DRAM[65536+defender_id*8 + 0][7:4]                                        = defender_info.bag_info.berry_num    ; 
        golden_DRAM[65536+defender_id*8 + 0][3:0]                                        = defender_info.bag_info.medicine_num ; 
        golden_DRAM[65536+defender_id*8 + 1][7:4]                                        = defender_info.bag_info.candy_num    ; 
        golden_DRAM[65536+defender_id*8 + 1][3:0]                                        = defender_info.bag_info.bracer_num   ; 
        golden_DRAM[65536+defender_id*8 + 2][7:6]                                        = defender_info.bag_info.stone        ; 
        {golden_DRAM[65536+defender_id*8 + 2][5:0],golden_DRAM[65536+defender_id*8 + 3]} = defender_info.bag_info.money        ; 
        // pkm
        golden_DRAM[65536+defender_id*8 + 4][7:4]                                        = defender_info.pkm_info.stage        ; 
        golden_DRAM[65536+defender_id*8 + 4][3:0]                                        = defender_info.pkm_info.pkm_type     ; 
        golden_DRAM[65536+defender_id*8 + 5]                                             = defender_info.pkm_info.hp           ; 
        golden_DRAM[65536+defender_id*8 + 6]                                             = defender_info.pkm_info.atk          ; 
        golden_DRAM[65536+defender_id*8 + 7]                                             = defender_info.pkm_info.exp          ; 
    end
    
end endtask

task cal_ans_task; begin
    case (golden_act)
    Buy:begin
        if(buy_pkm_item_flag == item)begin
            case (golden_item)
            Berry : begin
                if(golden_info.bag_info.money < 16) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.bag_info.berry_num == 15) begin
                    golden_complete = 0;
                    golden_err = Bag_is_full;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 16;
                    golden_info.bag_info.berry_num = golden_info.bag_info.berry_num + 1;
                end
            end	     
            Medicine: begin
                if(golden_info.bag_info.money < 128) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.bag_info.medicine_num == 15) begin
                    golden_complete = 0;
                    golden_err = Bag_is_full;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 128;
                    golden_info.bag_info.medicine_num = golden_info.bag_info.medicine_num + 1;
                end
            end  
            Candy: begin
                if(golden_info.bag_info.money < 300) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.bag_info.candy_num == 15) begin
                    golden_complete = 0;
                    golden_err = Bag_is_full;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 300;
                    golden_info.bag_info.candy_num = golden_info.bag_info.candy_num + 1;
                end
            end  	
            Bracer: begin
                if(golden_info.bag_info.money < 64) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.bag_info.bracer_num == 15) begin
                    golden_complete = 0;
                    golden_err = Bag_is_full;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 64;
                    golden_info.bag_info.bracer_num = golden_info.bag_info.bracer_num + 1;
                end
            end  	     
            Water_stone	: begin
                if(golden_info.bag_info.money < 800) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.bag_info.stone != No_stone) begin
                    golden_complete = 0;
                    golden_err = Bag_is_full;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 800;
                    golden_info.bag_info.stone = W_stone;
                end
            end  
            Fire_stone	: begin
                if(golden_info.bag_info.money < 800) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.bag_info.stone != No_stone) begin
                    golden_complete = 0;
                    golden_err = Bag_is_full;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 800;
                    golden_info.bag_info.stone = F_stone;
                end
            end  
            Thunder_stone : begin
                if(golden_info.bag_info.money < 800) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.bag_info.stone != No_stone) begin
                    golden_complete = 0;
                    golden_err = Bag_is_full;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 800;
                    golden_info.bag_info.stone = T_stone;
                end
            end  
            endcase
        end
        else begin
            case (golden_type)
            Grass: begin
                if(golden_info.bag_info.money < 100) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.pkm_info != 0) begin
                    golden_complete = 0;
                    golden_err = Already_Have_PKM;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 100;
                    golden_info.pkm_info.stage = Lowest;
                    golden_info.pkm_info.pkm_type = Grass;
                    golden_info.pkm_info.hp = 128;
                    golden_info.pkm_info.atk = 63;
                    golden_info.pkm_info.exp = 0;
                end
            end	
            Fire:begin
                if(golden_info.bag_info.money < 90) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.pkm_info != 0) begin
                    golden_complete = 0;
                    golden_err = Already_Have_PKM;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 90;
                    golden_info.pkm_info.stage = Lowest;
                    golden_info.pkm_info.pkm_type = Fire;
                    golden_info.pkm_info.hp = 119;
                    golden_info.pkm_info.atk = 64;
                    golden_info.pkm_info.exp = 0;
                end
            end		
            Water:begin
                if(golden_info.bag_info.money < 110) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.pkm_info != 0) begin
                    golden_complete = 0;
                    golden_err = Already_Have_PKM;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 110;
                    golden_info.pkm_info.stage = Lowest;
                    golden_info.pkm_info.pkm_type = Water;
                    golden_info.pkm_info.hp = 125;
                    golden_info.pkm_info.atk = 60;
                    golden_info.pkm_info.exp = 0;
                end
            end		
            Electric:begin
                if(golden_info.bag_info.money < 120) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.pkm_info != 0) begin
                    golden_complete = 0;
                    golden_err = Already_Have_PKM;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 120;
                    golden_info.pkm_info.stage = Lowest;
                    golden_info.pkm_info.pkm_type = Electric;
                    golden_info.pkm_info.hp = 122;
                    golden_info.pkm_info.atk = 65;
                    golden_info.pkm_info.exp = 0;
                end
            end	
            Normal:begin
                if(golden_info.bag_info.money < 130) begin
                    golden_complete = 0;
                    golden_err = Out_of_money;
                end
                else if(golden_info.pkm_info != 0) begin
                    golden_complete = 0;
                    golden_err = Already_Have_PKM;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money - 130;
                    golden_info.pkm_info.stage = Lowest;
                    golden_info.pkm_info.pkm_type = Normal;
                    golden_info.pkm_info.hp = 124;
                    golden_info.pkm_info.atk = 62;
                    golden_info.pkm_info.exp = 0;
                end
            end	
            endcase
        end
    end
    Sell:begin
        if(buy_pkm_item_flag == item)begin
            case (golden_item)
            Berry : begin
                if(golden_info.bag_info.berry_num == 0) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money + 12;
                    golden_info.bag_info.berry_num = golden_info.bag_info.berry_num - 1;
                end
            end	     
            Medicine: begin
                if(golden_info.bag_info.medicine_num == 0) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money + 96;
                    golden_info.bag_info.medicine_num = golden_info.bag_info.medicine_num - 1;
                end
            end  
            Candy: begin
                if(golden_info.bag_info.candy_num == 0) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money + 225;
                    golden_info.bag_info.candy_num = golden_info.bag_info.candy_num - 1;
                end
            end  	
            Bracer: begin
                if(golden_info.bag_info.bracer_num == 0) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money + 48;
                    golden_info.bag_info.bracer_num = golden_info.bag_info.bracer_num - 1;
                end
            end  	     
            Water_stone	: begin
                if(golden_info.bag_info.stone != W_stone) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money + 600;
                    golden_info.bag_info.stone = No_stone;
                end
            end  
            Fire_stone	: begin
                if(golden_info.bag_info.stone != F_stone) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money + 600;
                    golden_info.bag_info.stone = No_stone;
                end
            end 
            Thunder_stone : begin
                if(golden_info.bag_info.stone != T_stone) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.money = golden_info.bag_info.money + 600;
                    golden_info.bag_info.stone = No_stone;
                end
            end  
            endcase
        end
        else begin
            if(golden_info.pkm_info == 0)begin
                golden_complete = 0;
                golden_err = Not_Having_PKM;
            end
            else if(golden_info.pkm_info.stage == Lowest)begin
                golden_complete = 0;
                golden_err = Has_Not_Grown;
            end
            else begin
                goldem_bracer_effect = 0;
                golden_complete = 1;
                golden_err = No_Err;
                case (golden_info.pkm_info.pkm_type)
                Grass:begin
                    if(golden_info.pkm_info.stage == Middle)
                        golden_info.bag_info.money = golden_info.bag_info.money + 510;
                    else
                        golden_info.bag_info.money = golden_info.bag_info.money + 1100;
                end
                Fire:begin
                    if(golden_info.pkm_info.stage == Middle)
                        golden_info.bag_info.money = golden_info.bag_info.money + 450;
                    else
                        golden_info.bag_info.money = golden_info.bag_info.money + 1000;
                end
                Water:begin
                    if(golden_info.pkm_info.stage == Middle)
                        golden_info.bag_info.money = golden_info.bag_info.money + 500;
                    else
                        golden_info.bag_info.money = golden_info.bag_info.money + 1200;
                end
                Electric: begin
                    if(golden_info.pkm_info.stage == Middle)
                        golden_info.bag_info.money = golden_info.bag_info.money + 550;
                    else
                        golden_info.bag_info.money = golden_info.bag_info.money + 1300;
                end
                endcase
                golden_info.pkm_info = 0;
            end
        end
    end
    Deposit:begin
        golden_complete = 1;
        golden_err = No_Err;
        golden_info.bag_info.money = golden_info.bag_info.money + golden_money;
    end
    Use_item:begin
        if(golden_info.pkm_info == 0)begin
            golden_complete = 0;
            golden_err = Not_Having_PKM;
        end
        else begin
            case (golden_item)
            Berry : begin
                if(golden_info.bag_info.berry_num == 0) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.berry_num = golden_info.bag_info.berry_num - 1;
                    case (golden_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 128)? 128: golden_info.pkm_info.hp + 32;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 192)? 192: golden_info.pkm_info.hp + 32;
                        else 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 254)? 254: golden_info.pkm_info.hp + 32;
                    end 
                    Fire	:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 119)? 119: golden_info.pkm_info.hp + 32;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 177)? 177: golden_info.pkm_info.hp + 32;
                        else 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 225)? 225: golden_info.pkm_info.hp + 32;
                    end 
                    Water	:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 125)? 125: golden_info.pkm_info.hp + 32;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 187)? 187: golden_info.pkm_info.hp + 32;
                        else 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 245)? 245: golden_info.pkm_info.hp + 32;
                    end 
                    Electric:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 122)? 122: golden_info.pkm_info.hp + 32;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 182)? 182: golden_info.pkm_info.hp + 32;
                        else 
                            golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 235)? 235: golden_info.pkm_info.hp + 32;
                    end
                    Normal	: begin
                        golden_info.pkm_info.hp = (golden_info.pkm_info.hp + 32 > 124)? 124: golden_info.pkm_info.hp + 32;
                    end  
                    endcase
                end
            end	     
            Medicine: begin
                if(golden_info.bag_info.medicine_num == 0) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.medicine_num = golden_info.bag_info.medicine_num - 1;
                    case (golden_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.hp = 128;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.hp = 192;
                        else 
                            golden_info.pkm_info.hp = 254;
                    end 
                    Fire	:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.hp = 119;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.hp = 177;
                        else 
                            golden_info.pkm_info.hp = 225;
                    end 
                    Water	:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.hp = 125;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.hp = 187;
                        else 
                            golden_info.pkm_info.hp = 245;
                    end 
                    Electric:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.hp = 122;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.hp = 182;
                        else 
                            golden_info.pkm_info.hp = 235;
                    end
                    Normal	: begin
                        golden_info.pkm_info.hp = 124;
                    end  
                    endcase
                end
            end  
            Candy: begin
                if(golden_info.bag_info.candy_num == 0) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.candy_num = golden_info.bag_info.candy_num - 1;
                    case (golden_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 32)? 32: golden_info.pkm_info.exp + 15;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 63)? 63: golden_info.pkm_info.exp + 15;
                        else 
                            golden_info.pkm_info.exp = 0;
                    end 
                    Fire	:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 30)? 30: golden_info.pkm_info.exp + 15;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 59)? 59: golden_info.pkm_info.exp + 15;
                        else 
                            golden_info.pkm_info.exp = 0;
                    end 
                    Water	:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 28)? 28: golden_info.pkm_info.exp + 15;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 55)? 55: golden_info.pkm_info.exp + 15;
                        else 
                            golden_info.pkm_info.exp = 0;
                    end 
                    Electric:begin
                        if(golden_info.pkm_info.stage == Lowest) 
                            golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 26)? 26: golden_info.pkm_info.exp + 15;
                        else if(golden_info.pkm_info.stage == Middle) 
                            golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 51)? 51: golden_info.pkm_info.exp + 15;
                        else 
                            golden_info.pkm_info.exp = 0;
                    end
                    Normal	: begin
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 15 > 29)? 29: golden_info.pkm_info.exp + 15;
                    end  
                    endcase    
                end
            end  	
            Bracer: begin
                if(golden_info.bag_info.bracer_num == 0) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.bracer_num = golden_info.bag_info.bracer_num - 1;
                    goldem_bracer_effect = 1;
                end
            end  	     
            Water_stone	: begin
                if(golden_info.bag_info.stone != W_stone) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.stone = No_stone;
                    if(golden_info.pkm_info.pkm_type == Normal && golden_info.pkm_info.exp == 29)begin
                        golden_info.pkm_info.stage = Highest;
                        golden_info.pkm_info.pkm_type = Water;
                        golden_info.pkm_info.hp = 245;
                        golden_info.pkm_info.atk = 113;
                        golden_info.pkm_info.exp = 0;
                        goldem_bracer_effect = 0;
                    end
                end
            end  
            Fire_stone	: begin
                if(golden_info.bag_info.stone != F_stone) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.stone = No_stone;
                    if(golden_info.pkm_info.pkm_type == Normal && golden_info.pkm_info.exp == 29)begin
                        golden_info.pkm_info.stage = Highest;
                        golden_info.pkm_info.pkm_type = Fire;
                        golden_info.pkm_info.hp = 225;
                        golden_info.pkm_info.atk = 127;
                        golden_info.pkm_info.exp = 0;
                        goldem_bracer_effect = 0;
                    end
                end
            end 
            Thunder_stone : begin
                if(golden_info.bag_info.stone != T_stone) begin
                    golden_complete = 0;
                    golden_err = Not_Having_Item;
                end
                else begin
                    golden_complete = 1;
                    golden_err = No_Err;
                    golden_info.bag_info.stone = No_stone;
                    if(golden_info.pkm_info.pkm_type == Normal && golden_info.pkm_info.exp == 29)begin
                        golden_info.pkm_info.stage = Highest;
                        golden_info.pkm_info.pkm_type = Electric;
                        golden_info.pkm_info.hp = 235;
                        golden_info.pkm_info.atk = 124;
                        golden_info.pkm_info.exp = 0;
                        goldem_bracer_effect = 0;
                    end
                end
            end  
            endcase
        end
    end
    Check:begin
        golden_complete = 1;
        golden_err = No_Err;
    end
    Attack:begin
        if(golden_info.pkm_info == 0 || defender_info.pkm_info == 0)begin
            golden_complete = 0;
            golden_err = Not_Having_PKM;
        end
        else if(golden_info.pkm_info.hp == 0 || defender_info.pkm_info.hp == 0)begin
            golden_complete = 0;
            golden_err = HP_is_Zero;
        end
        else begin
            golden_complete = 1;
            golden_err = No_Err;
            goldem_bracer_effect = 0;
            case ({golden_info.pkm_info.pkm_type, defender_info.pkm_info.pkm_type})
            // atk is grass
            {Grass, Grass}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk/2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk/2):0;
            end
            {Grass, Fire}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk/2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk/2):0;
            end
            {Grass, Water}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk*2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk*2):0;
            end
            {Grass, Electric}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            {Grass, Normal}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            // atk is fire
            {Fire, Grass}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk*2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk*2):0;
            end
            {Fire, Fire}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk/2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk/2):0;
            end
            {Fire, Water}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk/2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk/2):0;
            end
            {Fire, Electric}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            {Fire, Normal}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            // atk is water
            {Water, Grass}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk/2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk/2):0;
            end
            {Water, Fire}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk*2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk*2):0;
            end
            {Water, Water}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk/2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk/2):0;
            end
            {Water, Electric}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            {Water, Normal}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            // atk is electric
            {Electric, Grass}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk/2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk/2):0;
            end
            {Electric, Fire}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            {Electric, Water}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk*2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk*2):0;
            end
            {Electric, Electric}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk/2))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk/2):0;
            end
            {Electric, Normal}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            // atk is normal
            {Normal, Grass}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            {Normal, Fire}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            {Normal, Water}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            {Normal, Electric}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            {Normal, Normal}: begin
                defender_info.pkm_info.hp = (defender_info.pkm_info.hp > (golden_info.pkm_info.atk))?defender_info.pkm_info.hp - (golden_info.pkm_info.atk):0;
            end
            endcase
            // calculate attacker exp
            if(defender_info.pkm_info.stage == Lowest)begin
                case (golden_info.pkm_info.pkm_type)
                Grass	: begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 32)? 32: golden_info.pkm_info.exp + 16;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 63)? 63: golden_info.pkm_info.exp + 16;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Fire	:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 30)? 30: golden_info.pkm_info.exp + 16;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 59)? 59: golden_info.pkm_info.exp + 16;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Water	:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 28)? 28: golden_info.pkm_info.exp + 16;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 55)? 55: golden_info.pkm_info.exp + 16;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Electric:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 26)? 26: golden_info.pkm_info.exp + 16;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 51)? 51: golden_info.pkm_info.exp + 16;
                    else 
                        golden_info.pkm_info.exp = 0;
                end
                Normal	: begin
                    golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 16 > 29)? 29: golden_info.pkm_info.exp + 16;
                end 
                endcase
            end
            else if(defender_info.pkm_info.stage == Middle)begin
                case (golden_info.pkm_info.pkm_type)
                Grass	: begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 32)? 32: golden_info.pkm_info.exp + 24;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 63)? 63: golden_info.pkm_info.exp + 24;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Fire	:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 30)? 30: golden_info.pkm_info.exp + 24;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 59)? 59: golden_info.pkm_info.exp + 24;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Water	:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 28)? 28: golden_info.pkm_info.exp + 24;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 55)? 55: golden_info.pkm_info.exp + 24;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Electric:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 26)? 26: golden_info.pkm_info.exp + 24;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 51)? 51: golden_info.pkm_info.exp + 24;
                    else 
                        golden_info.pkm_info.exp = 0;
                end
                Normal	: begin
                    golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 24 > 29)? 29: golden_info.pkm_info.exp + 24;
                end 
                endcase
            end
            else begin
                case (golden_info.pkm_info.pkm_type)
                Grass	: begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 32)? 32: golden_info.pkm_info.exp + 32;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 63)? 63: golden_info.pkm_info.exp + 32;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Fire	:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 30)? 30: golden_info.pkm_info.exp + 32;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 59)? 59: golden_info.pkm_info.exp + 32;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Water	:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 28)? 28: golden_info.pkm_info.exp + 32;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 55)? 55: golden_info.pkm_info.exp + 32;
                    else 
                        golden_info.pkm_info.exp = 0;
                end 
                Electric:begin
                    if(golden_info.pkm_info.stage == Lowest) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 26)? 26: golden_info.pkm_info.exp + 32;
                    else if(golden_info.pkm_info.stage == Middle) 
                        golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 51)? 51: golden_info.pkm_info.exp + 32;
                    else 
                        golden_info.pkm_info.exp = 0;
                end
                Normal	: begin
                    golden_info.pkm_info.exp = (golden_info.pkm_info.exp + 32 > 29)? 29: golden_info.pkm_info.exp + 32;
                end 
                endcase
            end
            // calculate defender exp
            if(golden_info.pkm_info.stage == Lowest)begin
                case (defender_info.pkm_info.pkm_type)
                Grass	: begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 32)? 32: defender_info.pkm_info.exp + 8;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 63)? 63: defender_info.pkm_info.exp + 8;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Fire	:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 30)? 30: defender_info.pkm_info.exp + 8;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 59)? 59: defender_info.pkm_info.exp + 8;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Water	:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 28)? 28: defender_info.pkm_info.exp + 8;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 55)? 55: defender_info.pkm_info.exp + 8;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Electric:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 26)? 26: defender_info.pkm_info.exp + 8;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 51)? 51: defender_info.pkm_info.exp + 8;
                    else 
                        defender_info.pkm_info.exp = 0;
                end
                Normal	: begin
                    defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 8 > 29)? 29: defender_info.pkm_info.exp + 8;
                end 
                endcase
            end
            else if(golden_info.pkm_info.stage == Middle)begin
                case (defender_info.pkm_info.pkm_type)
                Grass	: begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 32)? 32: defender_info.pkm_info.exp + 12;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 63)? 63: defender_info.pkm_info.exp + 12;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Fire	:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 30)? 30: defender_info.pkm_info.exp + 12;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 59)? 59: defender_info.pkm_info.exp + 12;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Water	:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 28)? 28: defender_info.pkm_info.exp + 12;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 55)? 55: defender_info.pkm_info.exp + 12;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Electric:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 26)? 26: defender_info.pkm_info.exp + 12;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 51)? 51: defender_info.pkm_info.exp + 12;
                    else 
                        defender_info.pkm_info.exp = 0;
                end
                Normal	: begin
                    defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 12 > 29)? 29: defender_info.pkm_info.exp + 12;
                end 
                endcase
            end
            else begin
                case (defender_info.pkm_info.pkm_type)
                Grass	: begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 32)? 32: defender_info.pkm_info.exp + 16;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 63)? 63: defender_info.pkm_info.exp + 16;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Fire	:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 30)? 30: defender_info.pkm_info.exp + 16;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 59)? 59: defender_info.pkm_info.exp + 16;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Water	:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 28)? 28: defender_info.pkm_info.exp + 16;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 55)? 55: defender_info.pkm_info.exp + 16;
                    else 
                        defender_info.pkm_info.exp = 0;
                end 
                Electric:begin
                    if(defender_info.pkm_info.stage == Lowest) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 26)? 26: defender_info.pkm_info.exp + 16;
                    else if(defender_info.pkm_info.stage == Middle) 
                        defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 51)? 51: defender_info.pkm_info.exp + 16;
                    else 
                        defender_info.pkm_info.exp = 0;
                end
                Normal	: begin
                    defender_info.pkm_info.exp = (defender_info.pkm_info.exp + 16 > 29)? 29: defender_info.pkm_info.exp + 16;
                end 
                endcase
            end
        end
        
    end
    endcase
    // auto evolution
    case (golden_info.pkm_info.pkm_type)
        Grass	: begin
            if(golden_info.pkm_info.stage == Lowest && golden_info.pkm_info.exp == 32)begin
                golden_info.pkm_info.stage = Middle;
                golden_info.pkm_info.hp = 192;
                golden_info.pkm_info.atk = 94;
                golden_info.pkm_info.exp = 0;
                goldem_bracer_effect = 0;
            end      
            else if(golden_info.pkm_info.stage == Middle && golden_info.pkm_info.exp == 63) begin
                golden_info.pkm_info.stage = Highest;
                golden_info.pkm_info.hp = 254;
                golden_info.pkm_info.atk = 123;
                golden_info.pkm_info.exp = 0;
                goldem_bracer_effect = 0;
            end
        end 
        Fire	:begin
            if(golden_info.pkm_info.stage == Lowest && golden_info.pkm_info.exp == 30)begin
                golden_info.pkm_info.stage = Middle;
                golden_info.pkm_info.hp = 177;
                golden_info.pkm_info.atk = 96;
                golden_info.pkm_info.exp = 0;
                goldem_bracer_effect = 0;
            end      
            else if(golden_info.pkm_info.stage == Middle && golden_info.pkm_info.exp == 59) begin
                golden_info.pkm_info.stage = Highest;
                golden_info.pkm_info.hp = 225;
                golden_info.pkm_info.atk = 127;
                golden_info.pkm_info.exp = 0;
                goldem_bracer_effect = 0;
            end
        end 
        Water	:begin
            if(golden_info.pkm_info.stage == Lowest && golden_info.pkm_info.exp == 28)begin
                golden_info.pkm_info.stage = Middle;
                golden_info.pkm_info.hp = 187;
                golden_info.pkm_info.atk = 89;
                golden_info.pkm_info.exp = 0;
                goldem_bracer_effect = 0;
            end      
            else if(golden_info.pkm_info.stage == Middle && golden_info.pkm_info.exp == 55) begin
                golden_info.pkm_info.stage = Highest;
                golden_info.pkm_info.hp = 245;
                golden_info.pkm_info.atk = 113;
                golden_info.pkm_info.exp = 0;
                goldem_bracer_effect = 0;
            end
        end 
        Electric:begin
            if(golden_info.pkm_info.stage == Lowest && golden_info.pkm_info.exp == 26)begin
                golden_info.pkm_info.stage = Middle;
                golden_info.pkm_info.hp = 182;
                golden_info.pkm_info.atk = 97;
                golden_info.pkm_info.exp = 0;
                goldem_bracer_effect = 0;
            end      
            else if(golden_info.pkm_info.stage == Middle && golden_info.pkm_info.exp == 51) begin
                golden_info.pkm_info.stage = Highest;
                golden_info.pkm_info.hp = 235;
                golden_info.pkm_info.atk = 124;
                golden_info.pkm_info.exp = 0;
                goldem_bracer_effect = 0;
            end
        end 
    endcase
    // auto evolution
    case (defender_info.pkm_info.pkm_type)
        Grass	: begin
            if(defender_info.pkm_info.stage == Lowest && defender_info.pkm_info.exp == 32)begin
                defender_info.pkm_info.stage = Middle;
                defender_info.pkm_info.hp = 192;
                defender_info.pkm_info.atk = 94;
                defender_info.pkm_info.exp = 0;
            end      
            else if(defender_info.pkm_info.stage == Middle && defender_info.pkm_info.exp == 63) begin
                defender_info.pkm_info.stage = Highest;
                defender_info.pkm_info.hp = 254;
                defender_info.pkm_info.atk = 123;
                defender_info.pkm_info.exp = 0;
            end
        end 
        Fire	:begin
            if(defender_info.pkm_info.stage == Lowest && defender_info.pkm_info.exp == 30)begin
                defender_info.pkm_info.stage = Middle;
                defender_info.pkm_info.hp = 177;
                defender_info.pkm_info.atk = 96;
                defender_info.pkm_info.exp = 0;
            end      
            else if(defender_info.pkm_info.stage == Middle && defender_info.pkm_info.exp == 59) begin
                defender_info.pkm_info.stage = Highest;
                defender_info.pkm_info.hp = 225;
                defender_info.pkm_info.atk = 127;
                defender_info.pkm_info.exp = 0;
            end
        end 
        Water	:begin
            if(defender_info.pkm_info.stage == Lowest && defender_info.pkm_info.exp == 28)begin
                defender_info.pkm_info.stage = Middle;
                defender_info.pkm_info.hp = 187;
                defender_info.pkm_info.atk = 89;
                defender_info.pkm_info.exp = 0;
            end      
            else if(defender_info.pkm_info.stage == Middle && defender_info.pkm_info.exp == 55) begin
                defender_info.pkm_info.stage = Highest;
                defender_info.pkm_info.hp = 245;
                defender_info.pkm_info.atk = 113;
                defender_info.pkm_info.exp = 0;
            end
        end 
        Electric:begin
            if(defender_info.pkm_info.stage == Lowest && defender_info.pkm_info.exp == 26)begin
                defender_info.pkm_info.stage = Middle;
                defender_info.pkm_info.hp = 182;
                defender_info.pkm_info.atk = 97;
                defender_info.pkm_info.exp = 0;
            end      
            else if(defender_info.pkm_info.stage == Middle && defender_info.pkm_info.exp == 51) begin
                defender_info.pkm_info.stage = Highest;
                defender_info.pkm_info.hp = 235;
                defender_info.pkm_info.atk = 124;
                defender_info.pkm_info.exp = 0;
            end
        end 
    endcase

    bracer_effect_task;

end endtask 

//================================================================
// input task
//================================================================
task give_def_id_task; begin
    // rand_gap_task;
	inf.id_valid = 1'b1 ;
	inf.D = { 8'd0 , defender_id } ;
	@(negedge clk);
	inf.id_valid = 1'b0 ;
	inf.D = 'bx ;
end endtask

task give_id_task; begin
    // rand_gap_task;
	inf.id_valid = 1'b1 ;
	inf.D = { 8'd0 , golden_id } ;
	@(negedge clk);
	inf.id_valid = 1'b0 ;
	inf.D = 'bx ;
end endtask

task give_action_task; begin
    // rand_gap_task;
	inf.act_valid = 1'b1 ;
	inf.D = { 12'd0 , golden_act } ;
	@(negedge clk);
	inf.act_valid = 1'b0 ;
	inf.D = 'bx ;
end endtask

task give_item_task; begin
    // rand_gap_task;
	inf.item_valid = 1'b1 ;
	inf.D = { 12'd0 , golden_item } ;
	@(negedge clk);
	inf.item_valid = 1'b0 ;
	inf.D = 'bx ;
end endtask

task give_type_task; begin
    // rand_gap_task;
	inf.type_valid = 1'b1 ;
	inf.D = { 12'd0 , golden_type } ;
	@(negedge clk);
	inf.type_valid = 1'b0 ;
	inf.D = 'bx ;
end endtask

task give_sell_pkm_task; begin
    // rand_gap_task;
	inf.type_valid = 1'b1 ;
	inf.D = 16'd0;
	@(negedge clk);
	inf.type_valid = 1'b0 ;
	inf.D = 'bx ;
end endtask

task give_deposit_task; begin
    // rand_gap_task;
	inf.amnt_valid = 1'b1 ;
    golden_money = 'd100;
	inf.D = { 2'd0 , 14'd100 } ;
	@(negedge clk);
	inf.amnt_valid = 1'b0 ;
	inf.D = 'bx ;
end endtask

//================================================================
// random task
//================================================================
task rand_gap_task; begin
    r_gap.randomize();
    // $display("gap = %01d", r_gap.gap);
    repeat(r_gap.gap) @(negedge clk);
    // repeat(1) @(negedge clk);
end endtask

task rand_delay_task; begin
    r_delay.randomize();
    // $display("gap = %01d", r_gap.gap);
    repeat(r_delay.delay) @(negedge clk);
    // repeat(1) @(negedge clk);
end endtask

//================================================================
// PASS FAIL task
//================================================================
task reset_task ; begin
	#(20);	inf.rst_n = 0 ;
	#(20);
	// if (inf.out_valid!==0 || inf.err_msg!==0 || inf.complete!==0 || inf.out_info!==0) begin
    //     // $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
    //     // $display ("                                                                RESET FAIL!                                                                 ");
    //     // $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
    //     // #(100);
    //     $finish;
	// end
	#(10);	inf.rst_n = 1 ;
    #(6);   release clk;
end endtask

task pass_task;
    $display("                                                             \033[33m`-                                                                            ");        
    $display("                                                             /NN.                                                                           ");        
    $display("                                                            sMMM+                                                                           ");        
    $display(" .``                                                       sMMMMy                                                                           ");        
    $display(" oNNmhs+:-`                                               oMMMMMh                                                                           ");        
    $display("  /mMMMMMNNd/:-`                                         :+smMMMh                                                                           ");        
    $display("   .sNMMMMMN::://:-`                                    .o--:sNMy                                                                           ");        
    $display("     -yNMMMM:----::/:-.                                 o:----/mo                                                                           ");        
    $display("       -yNMMo--------://:.                             -+------+/                                                                           ");        
    $display("         .omd/::--------://:`                          o-------o.                                                                           ");        
    $display("           `/+o+//::-------:+:`                       .+-------y                                                                            ");        
    $display("              .:+++//::------:+/.---------.`          +:------/+                                                                            ");        
    $display("                 `-/+++/::----:/:::::::::::://:-.     o------:s.          \033[37m:::::----.           -::::.          `-:////:-`     `.:////:-.    \033[33m");        
    $display("                    `.:///+/------------------:::/:- `o-----:/o          \033[37m.NNNNNNNNNNds-       -NNNNNd`       -smNMMMMMMNy   .smNNMMMMMNh    \033[33m");        
    $display("                         :+:----------------------::/:s-----/s.          \033[37m.MMMMo++sdMMMN-     `mMMmMMMs      -NMMMh+///oys  `mMMMdo///oyy    \033[33m");        
    $display("                        :/---------------------------:++:--/++           \033[37m.MMMM.   `mMMMy     yMMM:dMMM/     +MMMM:      `  :MMMM+`     `    \033[33m");        
    $display("                       :/---///:-----------------------::-/+o`           \033[37m.MMMM.   -NMMMo    +MMMs -NMMm.    .mMMMNdo:.     `dMMMNds/-`      \033[33m");        
    $display("                      -+--/dNs-o/------------------------:+o`            \033[37m.MMMMyyyhNMMNy`   -NMMm`  sMMMh     .odNMMMMNd+`   `+dNMMMMNdo.    \033[33m");        
    $display("                     .o---yMMdsdo------------------------:s`             \033[37m.MMMMNmmmdho-    `dMMMdooosMMMM+      `./sdNMMMd.    `.:ohNMMMm-   \033[33m");        
    $display("                    -yo:--/hmmds:----------------//:------o              \033[37m.MMMM:...`       sMMMMMMMMMMMMMN-  ``     `:MMMM+ ``      -NMMMs   \033[33m");        
    $display("                   /yssy----:::-------o+-------/h/-hy:---:+              \033[37m.MMMM.          /MMMN:------hMMMd` +dy+:::/yMMMN- :my+:::/sMMMM/   \033[33m");        
    $display("                  :ysssh:------//////++/-------sMdyNMo---o.              \033[37m.MMMM.         .mMMMs       .NMMMs /NMMMMMMMMmh:  -NMMMMMMMMNh/    \033[33m");        
    $display("                  ossssh:-------ddddmmmds/:----:hmNNh:---o               \033[37m`::::`         .::::`        -:::: `-:/++++/-.     .:/++++/-.      \033[33m");        
    $display("                  /yssyo--------dhhyyhhdmmhy+:---://----+-                                                                                  ");        
    $display("                  `yss+---------hoo++oosydms----------::s    `.....-.                                                                       ");        
    $display("                   :+-----------y+++++++oho--------:+sssy.://:::://+o.                                                                      ");        
    $display("                    //----------y++++++os/--------+yssssy/:--------:/s-                                                                     ");        
    $display("             `..:::::s+//:::----+s+++ooo:--------+yssssy:-----------++                                                                      ");        
    $display("           `://::------::///+/:--+soo+:----------ssssys/---------:o+s.``                                                                    ");        
    $display("          .+:----------------/++/:---------------:sys+----------:o/////////::::-...`                                                        ");        
    $display("          o---------------------oo::----------::/+//---------::o+--------------:/ohdhyo/-.``                                                ");        
    $display("          o---------------------/s+////:----:://:---------::/+h/------------------:oNMMMMNmhs+:.`                                           ");        
    $display("          -+:::::--------------:s+-:::-----------------:://++:s--::------------::://sMMMMMMMMMMNds/`                                        ");        
    $display("           .+++/////////////+++s/:------------------:://+++- :+--////::------/ydmNNMMMMMMMMMMMMMMmo`                                        ");        
    $display("             ./+oo+++oooo++/:---------------------:///++/-   o--:///////::----sNMMMMMMMMMMMMMMMmo.                                          ");        
    $display("                o::::::--------------------------:/+++:`    .o--////////////:--+mMMMMMMMMMMMMmo`                                            ");        
    $display("               :+--------------------------------/so.       +:-:////+++++///++//+mMMMMMMMMMmo`                                              ");        
    $display("              .s----------------------------------+: ````` `s--////o:.-:/+syddmNMMMMMMMMMmo`                                                ");        
    $display("              o:----------------------------------s. :s+/////--//+o-       `-:+shmNNMMMNs.                                                  ");        
    $display("             //-----------------------------------s` .s///:---:/+o.               `-/+o.                                                    ");        
    $display("            .o------------------------------------o.  y///+//:/+o`                                                                          ");        
    $display("            o-------------------------------------:/  o+//s//+++`                                                                           ");        
    $display("           //--------------------------------------s+/o+//s`                                                                                ");        
    $display("          -+---------------------------------------:y++///s                                                                                 ");        
    $display("          o-----------------------------------------oo/+++o                                                                                 ");        
    $display("         `s-----------------------------------------:s   ``                                                                                 ");        
    $display("          o-:::::------------------:::::-------------o.                                                                                     ");        
    $display("          .+//////////::::::://///////////////:::----o`                                                                                     ");        
    $display("          `:soo+///////////+++oooooo+/////////////:-//                                                                                      ");        
    $display("       -/os/--:++/+ooo:::---..:://+ooooo++///////++so-`                                                                                     ");        
    $display("      syyooo+o++//::-                 ``-::/yoooo+/:::+s/.                                                                                  ");        
    $display("       `..``                                `-::::///:++sys:                                                                                ");        
    $display("                                                    `.:::/o+  \033[37m                                                                              ");	
    $display("********************************************************************");
    $display("                        \033[0;38;5;219mCongratulations!\033[m      ");
    $display("                 \033[0;38;5;219mYou have passed all patterns!\033[m");
    $display("                 \033[0;38;5;219mTotal cycle : %d\033[m", total_cycles);
    $display("********************************************************************");
    $finish;
endtask

task fail_task; 
    $display("\033[33m	                                                         .:                                                                                         ");      
    $display("                                                   .:                                                                                                 ");
    $display("                                                  --`                                                                                                 ");
    $display("                                                `--`                                                                                                  ");
    $display("                 `-.                            -..        .-//-                                                                                      ");
    $display("                  `.:.`                        -.-     `:+yhddddo.                                                                                    ");
    $display("                    `-:-`             `       .-.`   -ohdddddddddh:                                                                                   ");
    $display("                      `---`       `.://:-.    :`- `:ydddddhhsshdddh-                       \033[31m.yhhhhhhhhhs       /yyyyy`       .yhhy`   +yhyo           \033[33m");
    $display("                        `--.     ./////:-::` `-.--yddddhs+//::/hdddy`                      \033[31m-MMMMNNNNNNh      -NMMMMMs       .MMMM.   sMMMh           \033[33m");
    $display("                          .-..   ////:-..-// :.:oddddho:----:::+dddd+                      \033[31m-MMMM-......     `dMMmhMMM/      .MMMM.   sMMMh           \033[33m");
    $display("                           `-.-` ///::::/::/:/`odddho:-------:::sdddh`                     \033[31m-MMMM.           sMMM/.NMMN.     .MMMM.   sMMMh           \033[33m");
    $display("             `:/+++//:--.``  .--..+----::://o:`osss/-.--------::/dddd/             ..`     \033[31m-MMMMysssss.    /MMMh  oMMMh     .MMMM.   sMMMh           \033[33m");
    $display("             oddddddddddhhhyo///.-/:-::--//+o-`:``````...------::dddds          `.-.`      \033[31m-MMMMMMMMMM-   .NMMN-``.mMMM+    .MMMM.   sMMMh           \033[33m");
    $display("            .ddddhhhhhddddddddddo.//::--:///+/`.````````..``...-:ddddh       `.-.`         \033[31m-MMMM:.....`  `hMMMMmmmmNMMMN-   .MMMM.   sMMMh           \033[33m");
    $display("            /dddd//::///+syhhdy+:-`-/--/////+o```````.-.......``./yddd`   `.--.`           \033[31m-MMMM.        oMMMmhhhhhhdMMMd`  .MMMM.   sMMMh```````    \033[33m");
    $display("            /dddd:/------:://-.`````-/+////+o:`````..``     `.-.``./ym.`..--`              \033[31m-MMMM.       :NMMM:      .NMMMs  .MMMM.   sMMMNmmmmmms    \033[33m");
    $display("            :dddd//--------.`````````.:/+++/.`````.` `.-      `-:.``.o:---`                \033[31m.dddd`       yddds        /dddh. .dddd`   +ddddddddddo    \033[33m");
    $display("            .ddddo/-----..`........`````..```````..  .-o`       `:.`.--/-      ``````````` \033[31m ````        ````          ````   ````     ``````````     \033[33m");
    $display("             ydddh/:---..--.````.`.-.````````````-   `yd:        `:.`...:` `................`                                                         ");
    $display("             :dddds:--..:.     `.:  .-``````````.:    +ys         :-````.:...```````````````..`                                                       ");
    $display("              sdddds:.`/`      ``s.  `-`````````-/.   .sy`      .:.``````-`````..-.-:-.````..`-                                                       ");
    $display("              `ydddd-`.:       `sh+   /:``````````..`` +y`   `.--````````-..---..``.+::-.-``--:                                                       ");
    $display("               .yddh``-.        oys`  /.``````````````.-:.`.-..`..```````/--.`      /:::-:..--`                                                       ");
    $display("                .sdo``:`        .sy. .:``````````````````````````.:```...+.``       -::::-`.`                                                         ");
    $display(" ````.........```.++``-:`        :y:.-``````````````....``.......-.```..::::----.```  ``                                                              ");
    $display("`...````..`....----:.``...````  ``::.``````.-:/+oosssyyy:`.yyh-..`````.:` ````...-----..`                                                             ");
    $display("                 `.+.``````........````.:+syhdddddddddddhoyddh.``````--              `..--.`                                                          ");
    $display("            ``.....--```````.```````.../ddddddhhyyyyyyyhhhddds````.--`             ````   ``                                                          ");
    $display("         `.-..``````-.`````.-.`.../ss/.oddhhyssssooooooossyyd:``.-:.         `-//::/++/:::.`                                                          ");
    $display("       `..```````...-::`````.-....+hddhhhyssoo+++//////++osss.-:-.           /++++o++//s+++/                                                          ");
    $display("     `-.```````-:-....-/-``````````:hddhsso++/////////////+oo+:`             +++::/o:::s+::o            \033[31m     `-/++++:-`                              \033[33m");
    $display("    `:````````./`  `.----:..````````.oysso+///////////////++:::.             :++//+++/+++/+-            \033[31m   :ymMMMMMMMMms-                            \033[33m");
    $display("    :.`-`..```./.`----.`  .----..`````-oo+////////////////o:-.`-.            `+++++++++++/.             \033[31m `yMMMNho++odMMMNo                           \033[33m");
    $display("    ..`:..-.`.-:-::.`        `..-:::::--/+++////////////++:-.```-`            +++++++++o:               \033[31m hMMMm-      /MMMMo  .ssss`/yh+.syyyyyyyyss. \033[33m");
    $display("     `.-::-:..-:-.`                 ```.+::/++//++++++++:..``````:`          -++++++++oo                \033[31m:MMMM:        yMMMN  -MMMMdMNNs-mNNNNNMMMMd` \033[33m");
    $display("        `   `--`                        /``...-::///::-.`````````.: `......` ++++++++oy-                \033[31m+MMMM`        +MMMN` -MMMMh:--. ````:mMMNs`  \033[33m");
    $display("           --`                          /`````````````````````````/-.``````.::-::::::/+                 \033[31m:MMMM:        yMMMm  -MMMM`       `oNMMd:    \033[33m");
    $display("          .`                            :```````````````````````--.`````````..````.``/-                 \033[31m dMMMm:`    `+MMMN/  -MMMN       :dMMNs`     \033[33m");
    $display("                                        :``````````````````````-.``.....````.```-::-.+                  \033[31m `yNMMMdsooymMMMm/   -MMMN     `sMMMMy/////` \033[33m");
    $display("                                        :.````````````````````````-:::-::.`````-:::::+::-.`             \033[31m   -smNMMMMMNNd+`    -NNNN     hNNNNNNNNNNN- \033[33m");
    $display("                                `......../```````````````````````-:/:   `--.```.://.o++++++/.           \033[31m      .:///:-`       `----     ------------` \033[33m");
    $display("                              `:.``````````````````````````````.-:-`      `/````..`+sssso++++:                                                        ");
    $display("                              :`````.---...`````````````````.--:-`         :-````./ysoooss++++.                                                       ");
    $display("                              -.````-:/.`.--:--....````...--:/-`            /-..-+oo+++++o++++.                                                       ");
    $display("             `:++/:.`          -.```.::      `.--:::::://:::::.              -:/o++++++++s++++                                                        ");
    $display("           `-+++++++++////:::/-.:.```.:-.`              :::::-.-`               -+++++++o++++.                                                        ");
    $display("           /++osoooo+++++++++:`````````.-::.             .::::.`-.`              `/oooo+++++.                                                         ");
    $display("           ++oysssosyssssooo/.........---:::               -:::.``.....`     `.:/+++++++++:                                                           ");
    $display("           -+syoooyssssssyo/::/+++++/+::::-`                 -::.``````....../++++++++++:`                                                            ");
    $display("             .:///-....---.-..-.----..`                        `.--.``````````++++++/:.                                                               ");
    $display("                                                                   `........-:+/:-.`                                                            \033[37m      ");
endtask

endprogram

