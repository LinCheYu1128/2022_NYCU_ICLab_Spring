    module pokemon(input clk, INF.pokemon_inf inf);
    import usertype::*;

    //================================================================
    // logic 
    //================================================================

        /*modport pokemon_inf(
            input  rst_n,
                D, id_valid, act_valid, item_valid, type_valid, amnt_valid,
                C_out_valid, C_data_r,
            output out_valid, err_msg,  complete, out_info, 
                C_addr, C_data_w, C_in_valid, C_r_wb
        );*/

    State current_state, next_state;

    Player_Info player_info, defender_info; 
    Player_id player_id, defender_id;
    Action player_act;
    Item player_item;
    PKM_Type player_pkm_type;

    ATK temp_atk;
    logic bracer_effect;

    PKM_Item buy_pkm_item_flag;
    Money player_money;

    logic def_info_request;
    logic plr_info_request;
    logic info_switch;
    logic bridge_busy;

    logic stall;
    //================================================================
    // AXI 
    //================================================================
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		bridge_busy <= 0;
        else if(inf.C_in_valid) bridge_busy <= 1;
        else if(inf.C_out_valid) bridge_busy <= 0;
    end

    always_comb begin
        if(info_switch == 0)begin
            inf.C_addr = player_id;
        end
        else if(info_switch == 1)begin
            inf.C_addr = defender_id;
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		inf.C_r_wb <= 0 ;
        else if (current_state == IDLE) inf.C_r_wb <= 1;
        else if (current_state == EXE)inf.C_r_wb <= 0 ;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		inf.C_in_valid <= 0 ;
        else if(!bridge_busy && !inf.C_in_valid)begin
            if(def_info_request || plr_info_request) inf.C_in_valid <= 1;
            else inf.C_in_valid <= 0;
        end
        else inf.C_in_valid <= 0;
    end

    always_comb begin
        if(info_switch == 0)begin
            inf.C_data_w[ 7: 4]                         = player_info.bag_info.berry_num    ; 
            inf.C_data_w[ 3: 0]                         = player_info.bag_info.medicine_num ; 
            inf.C_data_w[15:12]                         = player_info.bag_info.candy_num    ; 
            inf.C_data_w[11: 8]                         = player_info.bag_info.bracer_num   ; 
            inf.C_data_w[23:22]                         = player_info.bag_info.stone        ; 
            {inf.C_data_w[21:16], inf.C_data_w[31:24]}  = player_info.bag_info.money        ; 
            inf.C_data_w[39:36]                         = player_info.pkm_info.stage        ;
            inf.C_data_w[35:32]                         = player_info.pkm_info.pkm_type     ; 
            inf.C_data_w[47:40]                         = player_info.pkm_info.hp           ; 
            inf.C_data_w[55:48]                         = player_info.pkm_info.atk          ; 
            inf.C_data_w[63:56]                         = player_info.pkm_info.exp          ;
        end
        else if(info_switch == 1)begin
            inf.C_data_w[ 7: 4]                         = defender_info.bag_info.berry_num    ; 
            inf.C_data_w[ 3: 0]                         = defender_info.bag_info.medicine_num ; 
            inf.C_data_w[15:12]                         = defender_info.bag_info.candy_num    ; 
            inf.C_data_w[11: 8]                         = defender_info.bag_info.bracer_num   ; 
            inf.C_data_w[23:22]                         = defender_info.bag_info.stone        ; 
            {inf.C_data_w[21:16], inf.C_data_w[31:24]}  = defender_info.bag_info.money        ; 
            inf.C_data_w[39:36]                         = defender_info.pkm_info.stage        ;
            inf.C_data_w[35:32]                         = defender_info.pkm_info.pkm_type     ; 
            inf.C_data_w[47:40]                         = defender_info.pkm_info.hp           ; 
            inf.C_data_w[55:48]                         = defender_info.pkm_info.atk          ; 
            inf.C_data_w[63:56]                         = defender_info.pkm_info.exp          ;
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		plr_info_request <= 0 ;
        else if(inf.id_valid && current_state == IDLE) plr_info_request <= 1;
        else if((player_act == Attack || player_act == Use_item) && current_state == EVO) plr_info_request <= 1;
        else if(current_state == EXE && player_act != Check) plr_info_request <= 1;
        else if(info_switch == 0 && inf.C_out_valid) plr_info_request <= 0;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		def_info_request <= 0 ;
        else if(inf.id_valid && current_state == GET_ACT) def_info_request <= 1;
        else if(player_act == Attack && current_state == EVO) def_info_request <= 1;
        else if(info_switch == 1 && inf.C_out_valid) def_info_request <= 0;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		info_switch <= 0 ;
        else if(plr_info_request) info_switch <= 0;
        else if(def_info_request) info_switch <= 1;
    end

    //================================================================
    // Design
    //================================================================

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		stall <= 0;
        else if(current_state == CHECK_ERR) stall <= 1;
        else  stall <= 0;
    end

    always_comb begin
        if(bracer_effect)begin
            case (player_info.pkm_info.pkm_type)
            Grass	: begin
                if(player_info.pkm_info.stage == Lowest) 
                    temp_atk = 95;
                else if(player_info.pkm_info.stage == Middle) 
                    temp_atk = 126;
                else 
                    temp_atk = 155;
            end 
            Fire	:begin
                if(player_info.pkm_info.stage == Lowest) 
                    temp_atk = 96;
                else if(player_info.pkm_info.stage == Middle) 
                    temp_atk = 128;
                else 
                    temp_atk = 159;
            end 
            Water	:begin
                if(player_info.pkm_info.stage == Lowest) 
                    temp_atk = 92;
                else if(player_info.pkm_info.stage == Middle) 
                    temp_atk = 121;
                else 
                    temp_atk = 145;
            end 
            Electric:begin
                if(player_info.pkm_info.stage == Lowest) 
                    temp_atk = 97;
                else if(player_info.pkm_info.stage == Middle) 
                    temp_atk = 129;
                else 
                    temp_atk = 156;
            end
            Normal	: begin
                temp_atk = 94;
            end 
            default : begin
                temp_atk = 0;
            end 
            endcase  
        end
        else begin
            case (player_info.pkm_info.pkm_type)
            Grass	: begin
                if(player_info.pkm_info.stage == Lowest) 
                    temp_atk = 63;
                else if(player_info.pkm_info.stage == Middle) 
                    temp_atk = 94;
                else 
                    temp_atk = 123;
            end 
            Fire	:begin
                if(player_info.pkm_info.stage == Lowest) 
                    temp_atk = 64;
                else if(player_info.pkm_info.stage == Middle) 
                    temp_atk = 96;
                else 
                    temp_atk = 127;
            end 
            Water	:begin
                if(player_info.pkm_info.stage == Lowest) 
                    temp_atk = 60;
                else if(player_info.pkm_info.stage == Middle) 
                    temp_atk = 89;
                else 
                    temp_atk = 113;
            end 
            Electric:begin
                if(player_info.pkm_info.stage == Lowest) 
                    temp_atk = 65;
                else if(player_info.pkm_info.stage == Middle) 
                    temp_atk = 97;
                else 
                    temp_atk = 124;
            end
            Normal	: begin
                temp_atk = 62;
            end  
            default : begin
                temp_atk = 0;
            end 
            endcase  
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)	 bracer_effect <= 0;
        else if(current_state == EXE && player_act == Use_item && player_item == Bracer) bracer_effect <= 1;
        else if(current_state == EVO)begin
            if(player_act == Attack) bracer_effect <= 0;
            else begin
                case (player_info.pkm_info.pkm_type)
                Grass	: begin
                    if(player_info.pkm_info.stage == Lowest && player_info.pkm_info.exp == 32) bracer_effect <= 0;    
                    else if(player_info.pkm_info.stage == Middle && player_info.pkm_info.exp == 63) bracer_effect <= 0; 
                end 
                Fire	:begin
                    if(player_info.pkm_info.stage == Lowest && player_info.pkm_info.exp == 30) bracer_effect <= 0;    
                    else if(player_info.pkm_info.stage == Middle && player_info.pkm_info.exp == 59) bracer_effect <= 0; 
                end 
                Water	:begin
                    if(player_info.pkm_info.stage == Lowest && player_info.pkm_info.exp == 28) bracer_effect <= 0;     
                    else if(player_info.pkm_info.stage == Middle && player_info.pkm_info.exp == 55) bracer_effect <= 0; 
                end 
                Electric:begin
                    if(player_info.pkm_info.stage == Lowest && player_info.pkm_info.exp == 26) bracer_effect <= 0;     
                    else if(player_info.pkm_info.stage == Middle && player_info.pkm_info.exp == 51) bracer_effect <= 0; 
                end 
                Normal: begin
                    if(player_info.pkm_info.exp == 29 && player_act == Use_item && (player_item == Water_stone || player_item == Fire_stone || player_item == Thunder_stone))
                        bracer_effect <= 0;
                end
                endcase
            end
        end
        else if(current_state == CHNG_ID) bracer_effect <= 0;
        else if(player_act == Sell && buy_pkm_item_flag == pkm && current_state == EXE) bracer_effect <= 0;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)	 buy_pkm_item_flag <= pkm ;
        else if(inf.item_valid) buy_pkm_item_flag <= item;
        else if(inf.type_valid) buy_pkm_item_flag <= pkm;
    end

    //================================================================
    // Input 
    //================================================================

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		player_info <= 0 ;
        else if (inf.C_out_valid && inf.C_r_wb && !info_switch)begin
            player_info.bag_info.berry_num    <= inf.C_data_r[ 7: 4] ;
            player_info.bag_info.medicine_num <= inf.C_data_r[ 3: 0] ;
            player_info.bag_info.candy_num    <= inf.C_data_r[15:12] ;
            player_info.bag_info.bracer_num   <= inf.C_data_r[11: 8] ;
            player_info.bag_info.stone        <= inf.C_data_r[23:22] ;
            player_info.bag_info.money        <= {inf.C_data_r[21:16], inf.C_data_r[31:24]} ;
            player_info.pkm_info.stage        <= inf.C_data_r[39:36];
            player_info.pkm_info.pkm_type     <= inf.C_data_r[35:32] ;
            player_info.pkm_info.hp           <= inf.C_data_r[47:40] ;
            player_info.pkm_info.atk          <= inf.C_data_r[55:48] ;
            player_info.pkm_info.exp          <= inf.C_data_r[63:56] ;
        end   
        else if (current_state == EXE)begin
            case (player_act)
            Buy: begin
                if(buy_pkm_item_flag == item)begin
                    case (player_item)
                    Berry:begin
                        player_info.bag_info.money     <= player_info.bag_info.money - 16;
                        player_info.bag_info.berry_num <= player_info.bag_info.berry_num + 1;
                    end 
                    Medicine: begin
                        player_info.bag_info.money        <= player_info.bag_info.money - 128;
                        player_info.bag_info.medicine_num <= player_info.bag_info.medicine_num + 1;
                    end
                    Candy: begin
                        player_info.bag_info.money     <= player_info.bag_info.money - 300;
                        player_info.bag_info.candy_num <= player_info.bag_info.candy_num + 1;
                    end
                    Bracer: begin
                        player_info.bag_info.money      <= player_info.bag_info.money - 64;
                        player_info.bag_info.bracer_num <= player_info.bag_info.bracer_num + 1;
                    end
                    Water_stone: begin
                        player_info.bag_info.money <= player_info.bag_info.money - 800;
                        player_info.bag_info.stone <= W_stone;
                    end
                    Fire_stone: begin
                        player_info.bag_info.money <= player_info.bag_info.money - 800;
                        player_info.bag_info.stone <= F_stone;
                    end
                    Thunder_stone: begin
                        player_info.bag_info.money <= player_info.bag_info.money - 800;
                        player_info.bag_info.stone <= T_stone;
                    end
                    endcase
                end
                else begin
                    case (player_pkm_type)
                    Grass: begin
                        player_info.bag_info.money    <= player_info.bag_info.money - 100;
                        player_info.pkm_info.stage    <= Lowest;
                        player_info.pkm_info.pkm_type <= Grass;
                        player_info.pkm_info.hp       <= 128;
                        player_info.pkm_info.atk      <= 63;
                        player_info.pkm_info.exp      <= 0;
                    end	
                    Fire:begin
                        player_info.bag_info.money    <= player_info.bag_info.money - 90;
                        player_info.pkm_info.stage    <= Lowest;
                        player_info.pkm_info.pkm_type <= Fire;
                        player_info.pkm_info.hp       <= 119;
                        player_info.pkm_info.atk      <= 64;
                        player_info.pkm_info.exp      <= 0;
                    end		
                    Water:begin
                        player_info.bag_info.money    <= player_info.bag_info.money - 110;
                        player_info.pkm_info.stage    <= Lowest;
                        player_info.pkm_info.pkm_type <= Water;
                        player_info.pkm_info.hp       <= 125;
                        player_info.pkm_info.atk      <= 60;
                        player_info.pkm_info.exp      <= 0;
                    end		
                    Electric:begin
                        player_info.bag_info.money    <= player_info.bag_info.money - 120;
                        player_info.pkm_info.stage    <= Lowest;
                        player_info.pkm_info.pkm_type <= Electric;
                        player_info.pkm_info.hp       <= 122;
                        player_info.pkm_info.atk      <= 65;
                        player_info.pkm_info.exp      <= 0;
                    end	
                    Normal:begin
                        player_info.bag_info.money    <= player_info.bag_info.money - 130;
                        player_info.pkm_info.stage    <= Lowest;
                        player_info.pkm_info.pkm_type <= Normal;
                        player_info.pkm_info.hp       <= 124;
                        player_info.pkm_info.atk      <= 62;
                        player_info.pkm_info.exp      <= 0;
                    end	
                    endcase
                end
            end
            Sell: begin
                if(buy_pkm_item_flag == item)begin
                    case (player_item)
                    Berry:begin
                        player_info.bag_info.money     <= player_info.bag_info.money + 12;
                        player_info.bag_info.berry_num <= player_info.bag_info.berry_num - 1;
                    end 
                    Medicine: begin
                        player_info.bag_info.money        <= player_info.bag_info.money + 96;
                        player_info.bag_info.medicine_num <= player_info.bag_info.medicine_num - 1;
                    end
                    Candy: begin
                        player_info.bag_info.money     <= player_info.bag_info.money + 225;
                        player_info.bag_info.candy_num <= player_info.bag_info.candy_num - 1;
                    end
                    Bracer: begin
                        player_info.bag_info.money      <= player_info.bag_info.money + 48;
                        player_info.bag_info.bracer_num <= player_info.bag_info.bracer_num - 1;
                    end
                    Water_stone: begin
                        player_info.bag_info.money <= player_info.bag_info.money + 600;
                        player_info.bag_info.stone <= No_stone;
                    end
                    Fire_stone: begin
                        player_info.bag_info.money <= player_info.bag_info.money + 600;
                        player_info.bag_info.stone <= No_stone;
                    end
                    Thunder_stone: begin
                        player_info.bag_info.money <= player_info.bag_info.money + 600;
                        player_info.bag_info.stone <= No_stone;
                    end
                    endcase
                end
                else begin
                    case (player_info.pkm_info.pkm_type)
                    Grass: begin
                        if(player_info.pkm_info.stage == Middle) begin
                            player_info.bag_info.money <= player_info.bag_info.money + 510;
                            player_info.pkm_info       <= 0;
                        end
                        else begin
                            player_info.bag_info.money <= player_info.bag_info.money + 1100;
                            player_info.pkm_info       <= 0;
                        end
                    end	
                    Fire:begin
                        if(player_info.pkm_info.stage == Middle) begin
                            player_info.bag_info.money <= player_info.bag_info.money + 450;
                            player_info.pkm_info       <= 0;
                        end
                        else begin
                            player_info.bag_info.money <= player_info.bag_info.money + 1000;
                            player_info.pkm_info       <= 0;
                        end
                    end		
                    Water:begin
                        if(player_info.pkm_info.stage == Middle) begin
                            player_info.bag_info.money <= player_info.bag_info.money + 500;
                            player_info.pkm_info       <= 0;
                        end
                        else begin
                            player_info.bag_info.money <= player_info.bag_info.money + 1200;
                            player_info.pkm_info       <= 0;
                        end
                    end		
                    Electric:begin
                        if(player_info.pkm_info.stage == Middle) begin
                            player_info.bag_info.money <= player_info.bag_info.money + 550;
                            player_info.pkm_info       <= 0;
                        end
                        else begin
                            player_info.bag_info.money <= player_info.bag_info.money + 1300;
                            player_info.pkm_info       <= 0;
                        end
                    end	
                    endcase
                end
            end
            Deposit: begin
                player_info.bag_info.money <= player_info.bag_info.money + player_money;
            end
            Use_item: begin
                case (player_item)
                Berry: begin
                    player_info.bag_info.berry_num <= player_info.bag_info.berry_num - 1;
                    case (player_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 128)? 128: player_info.pkm_info.hp + 32;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 192)? 192: player_info.pkm_info.hp + 32;
                        else 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 254)? 254: player_info.pkm_info.hp + 32;
                    end 
                    Fire	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 119)? 119: player_info.pkm_info.hp + 32;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 177)? 177: player_info.pkm_info.hp + 32;
                        else 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 225)? 225: player_info.pkm_info.hp + 32;
                    end 
                    Water	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 125)? 125: player_info.pkm_info.hp + 32;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 187)? 187: player_info.pkm_info.hp + 32;
                        else 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 245)? 245: player_info.pkm_info.hp + 32;
                    end 
                    Electric:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 122)? 122: player_info.pkm_info.hp + 32;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 182)? 182: player_info.pkm_info.hp + 32;
                        else 
                            player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 235)? 235: player_info.pkm_info.hp + 32;
                    end
                    Normal	: begin
                        player_info.pkm_info.hp <= (player_info.pkm_info.hp + 32 > 124)? 124: player_info.pkm_info.hp + 32;
                    end   
                    endcase
                end 
                Medicine: begin
                    player_info.bag_info.medicine_num <= player_info.bag_info.medicine_num - 1;
                    case (player_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.hp <= 128;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.hp <= 192;
                        else 
                            player_info.pkm_info.hp <= 254;
                    end 
                    Fire	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.hp <= 119;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.hp <= 177;
                        else 
                            player_info.pkm_info.hp <= 225;
                    end 
                    Water	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.hp <= 125;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.hp <= 187;
                        else 
                            player_info.pkm_info.hp <= 245;
                    end 
                    Electric:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.hp <= 122;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.hp <= 182;
                        else 
                            player_info.pkm_info.hp <= 235;
                    end
                    Normal	: begin
                        player_info.pkm_info.hp <= 124;
                    end 
                    endcase
                end  
                Candy: begin
                    player_info.bag_info.candy_num <= player_info.bag_info.candy_num - 1;
                    case (player_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 32)? 32: player_info.pkm_info.exp + 15;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 63)? 63: player_info.pkm_info.exp + 15;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Fire	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 30)? 30: player_info.pkm_info.exp + 15;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 59)? 59: player_info.pkm_info.exp + 15;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Water	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 28)? 28: player_info.pkm_info.exp + 15;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 55)? 55: player_info.pkm_info.exp + 15;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Electric:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 26)? 26: player_info.pkm_info.exp + 15;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 51)? 51: player_info.pkm_info.exp + 15;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end
                    Normal	: begin
                        player_info.pkm_info.exp <= (player_info.pkm_info.exp + 15 > 29)? 29: player_info.pkm_info.exp + 15;
                    end  
                    endcase    
                end
                Bracer: begin
                    player_info.bag_info.bracer_num <= player_info.bag_info.bracer_num - 1;
                end
                default: begin
                    player_info.bag_info.stone <= No_stone;
                end 
                endcase 
            end
            Attack: begin
                // cal exp
                if(defender_info.pkm_info.stage == Lowest)begin
                    case (player_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 32)? 32: player_info.pkm_info.exp + 16;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 63)? 63: player_info.pkm_info.exp + 16;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Fire	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 30)? 30: player_info.pkm_info.exp + 16;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 59)? 59: player_info.pkm_info.exp + 16;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Water	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 28)? 28: player_info.pkm_info.exp + 16;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 55)? 55: player_info.pkm_info.exp + 16;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Electric:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 26)? 26: player_info.pkm_info.exp + 16;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 51)? 51: player_info.pkm_info.exp + 16;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end
                    Normal	: begin
                        player_info.pkm_info.exp <= (player_info.pkm_info.exp + 16 > 29)? 29: player_info.pkm_info.exp + 16;
                    end 
                    endcase
                end
                else if(defender_info.pkm_info.stage == Middle)begin
                    case (player_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 32)? 32: player_info.pkm_info.exp + 24;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 63)? 63: player_info.pkm_info.exp + 24;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Fire	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 30)? 30: player_info.pkm_info.exp + 24;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 59)? 59: player_info.pkm_info.exp + 24;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Water	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 28)? 28: player_info.pkm_info.exp + 24;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 55)? 55: player_info.pkm_info.exp + 24;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Electric:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 26)? 26: player_info.pkm_info.exp + 24;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 51)? 51: player_info.pkm_info.exp + 24;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end
                    Normal	: begin
                        player_info.pkm_info.exp <= (player_info.pkm_info.exp + 24 > 29)? 29: player_info.pkm_info.exp + 24;
                    end 
                    endcase
                end
                else begin
                    case (player_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 32)? 32: player_info.pkm_info.exp + 32;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 63)? 63: player_info.pkm_info.exp + 32;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Fire	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 30)? 30: player_info.pkm_info.exp + 32;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 59)? 59: player_info.pkm_info.exp + 32;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Water	:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 28)? 28: player_info.pkm_info.exp + 32;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 55)? 55: player_info.pkm_info.exp + 32;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end 
                    Electric:begin
                        if(player_info.pkm_info.stage == Lowest) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 26)? 26: player_info.pkm_info.exp + 32;
                        else if(player_info.pkm_info.stage == Middle) 
                            player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 51)? 51: player_info.pkm_info.exp + 32;
                        else 
                            player_info.pkm_info.exp <= 0;
                    end
                    Normal	: begin
                        player_info.pkm_info.exp <= (player_info.pkm_info.exp + 32 > 29)? 29: player_info.pkm_info.exp + 32;
                    end 
                    endcase
                end
            end
            endcase
        end
        else if(current_state == EVO)begin
            case (player_info.pkm_info.pkm_type)
            Grass	: begin
                if(player_info.pkm_info.stage == Lowest && player_info.pkm_info.exp == 32)begin
                    player_info.pkm_info.stage <= Middle;
                    player_info.pkm_info.hp <= 192;
                    player_info.pkm_info.atk <= 94;
                    player_info.pkm_info.exp <= 0;
                end      
                else if(player_info.pkm_info.stage == Middle && player_info.pkm_info.exp == 63) begin
                    player_info.pkm_info.stage <= Highest;
                    player_info.pkm_info.hp <= 254;
                    player_info.pkm_info.atk <= 123;
                    player_info.pkm_info.exp <= 0;
                end
            end 
            Fire	:begin
                if(player_info.pkm_info.stage == Lowest && player_info.pkm_info.exp == 30)begin
                    player_info.pkm_info.stage <= Middle;
                    player_info.pkm_info.hp <= 177;
                    player_info.pkm_info.atk <= 96;
                    player_info.pkm_info.exp <= 0;
                end      
                else if(player_info.pkm_info.stage == Middle && player_info.pkm_info.exp == 59) begin
                    player_info.pkm_info.stage <= Highest;
                    player_info.pkm_info.hp <= 225;
                    player_info.pkm_info.atk <= 127;
                    player_info.pkm_info.exp <= 0;
                end
            end 
            Water	:begin
                if(player_info.pkm_info.stage == Lowest && player_info.pkm_info.exp == 28)begin
                    player_info.pkm_info.stage <= Middle;
                    player_info.pkm_info.hp <= 187;
                    player_info.pkm_info.atk <= 89;
                    player_info.pkm_info.exp <= 0;
                end      
                else if(player_info.pkm_info.stage == Middle && player_info.pkm_info.exp == 55) begin
                    player_info.pkm_info.stage <= Highest;
                    player_info.pkm_info.hp <= 245;
                    player_info.pkm_info.atk <= 113;
                    player_info.pkm_info.exp <= 0;
                end
            end 
            Electric:begin
                if(player_info.pkm_info.stage == Lowest && player_info.pkm_info.exp == 26)begin
                    player_info.pkm_info.stage <= Middle;
                    player_info.pkm_info.hp <= 182;
                    player_info.pkm_info.atk <= 97;
                    player_info.pkm_info.exp <= 0;
                end      
                else if(player_info.pkm_info.stage == Middle && player_info.pkm_info.exp == 51) begin
                    player_info.pkm_info.stage <= Highest;
                    player_info.pkm_info.hp <= 235;
                    player_info.pkm_info.atk <= 124;
                    player_info.pkm_info.exp <= 0;
                end
            end
            Normal: begin
                if(player_act == Use_item && player_info.pkm_info.exp == 29) begin
                    case (player_item)
                    Water_stone: begin
                        player_info.pkm_info.stage <= Highest;
                        player_info.pkm_info.pkm_type <= Water;
                        player_info.pkm_info.hp <= 245;
                        player_info.pkm_info.atk <= 113;
                        player_info.pkm_info.exp <= 0;
                    end
                    Fire_stone: begin
                        player_info.pkm_info.stage <= Highest;
                        player_info.pkm_info.pkm_type <= Fire;
                        player_info.pkm_info.hp <= 225;
                        player_info.pkm_info.atk <= 127;
                        player_info.pkm_info.exp <= 0;
                    end
                    Thunder_stone: begin
                        player_info.pkm_info.stage <= Highest;
                        player_info.pkm_info.pkm_type <= Electric;
                        player_info.pkm_info.hp <= 235;
                        player_info.pkm_info.atk <= 124;
                        player_info.pkm_info.exp <= 0;
                    end
                    endcase
                end
            end 
            endcase
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		defender_info <= 0 ;
        else if (inf.C_out_valid && inf.C_r_wb && info_switch)begin
            defender_info.bag_info.berry_num    <= inf.C_data_r[ 7: 4] ;
            defender_info.bag_info.medicine_num <= inf.C_data_r[ 3: 0] ;
            defender_info.bag_info.candy_num    <= inf.C_data_r[15:12] ;
            defender_info.bag_info.bracer_num   <= inf.C_data_r[11: 8] ;
            defender_info.bag_info.stone        <= inf.C_data_r[23:22] ;
            defender_info.bag_info.money        <= {inf.C_data_r[21:16], inf.C_data_r[31:24]} ;
            defender_info.pkm_info.stage        <= inf.C_data_r[39:36];
            defender_info.pkm_info.pkm_type     <= inf.C_data_r[35:32] ;
            defender_info.pkm_info.hp           <= inf.C_data_r[47:40] ;
            defender_info.pkm_info.atk          <= inf.C_data_r[55:48] ;
            defender_info.pkm_info.exp          <= inf.C_data_r[63:56] ;
        end
        else if (current_state == EXE)begin
            if(player_act == Attack)begin
                // cal hp
                case ({player_info.pkm_info.pkm_type, defender_info.pkm_info.pkm_type})
                // atk is grass
                {Grass, Grass}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk/2))?defender_info.pkm_info.hp - (temp_atk/2):0;
                end
                {Grass, Fire}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk/2))?defender_info.pkm_info.hp - (temp_atk/2):0;
                end
                {Grass, Water}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk*2))?defender_info.pkm_info.hp - (temp_atk*2):0;
                end
                {Grass, Electric}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                {Grass, Normal}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                // atk is fire
                {Fire, Grass}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk*2))?defender_info.pkm_info.hp - (temp_atk*2):0;
                end
                {Fire, Fire}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk/2))?defender_info.pkm_info.hp - (temp_atk/2):0;
                end
                {Fire, Water}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk/2))?defender_info.pkm_info.hp - (temp_atk/2):0;
                end
                {Fire, Electric}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                {Fire, Normal}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                // atk is water
                {Water, Grass}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk/2))?defender_info.pkm_info.hp - (temp_atk/2):0;
                end
                {Water, Fire}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk*2))?defender_info.pkm_info.hp - (temp_atk*2):0;
                end
                {Water, Water}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk/2))?defender_info.pkm_info.hp - (temp_atk/2):0;
                end
                {Water, Electric}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                {Water, Normal}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                // atk is electric
                {Electric, Grass}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk/2))?defender_info.pkm_info.hp - (temp_atk/2):0;
                end
                {Electric, Fire}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                {Electric, Water}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk*2))?defender_info.pkm_info.hp - (temp_atk*2):0;
                end
                {Electric, Electric}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk/2))?defender_info.pkm_info.hp - (temp_atk/2):0;
                end
                {Electric, Normal}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                // atk is normal
                {Normal, Grass}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                {Normal, Fire}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                {Normal, Water}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                {Normal, Electric}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                {Normal, Normal}: begin
                    defender_info.pkm_info.hp <= (defender_info.pkm_info.hp > (temp_atk))?defender_info.pkm_info.hp - (temp_atk):0;
                end
                endcase
                // calculate defender exp
                if(player_info.pkm_info.stage == Lowest)begin
                    case (defender_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 32)? 32: defender_info.pkm_info.exp + 8;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 63)? 63: defender_info.pkm_info.exp + 8;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Fire	:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 30)? 30: defender_info.pkm_info.exp + 8;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 59)? 59: defender_info.pkm_info.exp + 8;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Water	:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 28)? 28: defender_info.pkm_info.exp + 8;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 55)? 55: defender_info.pkm_info.exp + 8;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Electric:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 26)? 26: defender_info.pkm_info.exp + 8;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 51)? 51: defender_info.pkm_info.exp + 8;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end
                    Normal	: begin
                        defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 8 > 29)? 29: defender_info.pkm_info.exp + 8;
                    end 
                    endcase
                end
                else if(player_info.pkm_info.stage == Middle)begin
                    case (defender_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 32)? 32: defender_info.pkm_info.exp + 12;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 63)? 63: defender_info.pkm_info.exp + 12;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Fire	:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 30)? 30: defender_info.pkm_info.exp + 12;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 59)? 59: defender_info.pkm_info.exp + 12;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Water	:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 28)? 28: defender_info.pkm_info.exp + 12;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 55)? 55: defender_info.pkm_info.exp + 12;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Electric:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 26)? 26: defender_info.pkm_info.exp + 12;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 51)? 51: defender_info.pkm_info.exp + 12;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end
                    Normal	: begin
                        defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 12 > 29)? 29: defender_info.pkm_info.exp + 12;
                    end 
                    endcase
                end
                else begin
                    case (defender_info.pkm_info.pkm_type)
                    Grass	: begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 32)? 32: defender_info.pkm_info.exp + 16;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 63)? 63: defender_info.pkm_info.exp + 16;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Fire	:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 30)? 30: defender_info.pkm_info.exp + 16;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 59)? 59: defender_info.pkm_info.exp + 16;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Water	:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 28)? 28: defender_info.pkm_info.exp + 16;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 55)? 55: defender_info.pkm_info.exp + 16;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end 
                    Electric:begin
                        if(defender_info.pkm_info.stage == Lowest) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 26)? 26: defender_info.pkm_info.exp + 16;
                        else if(defender_info.pkm_info.stage == Middle) 
                            defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 51)? 51: defender_info.pkm_info.exp + 16;
                        else 
                            defender_info.pkm_info.exp <= 0;
                    end
                    Normal	: begin
                        defender_info.pkm_info.exp <= (defender_info.pkm_info.exp + 16 > 29)? 29: defender_info.pkm_info.exp + 16;
                    end 
                    endcase
                end
            end
        end
        else if(current_state == EVO)begin
            case (defender_info.pkm_info.pkm_type)
            Grass	: begin
                if(defender_info.pkm_info.stage == Lowest && defender_info.pkm_info.exp == 32)begin
                    defender_info.pkm_info.stage <= Middle;
                    defender_info.pkm_info.hp <= 192;
                    defender_info.pkm_info.atk <= 94;
                    defender_info.pkm_info.exp <= 0;
                end      
                else if(defender_info.pkm_info.stage == Middle && defender_info.pkm_info.exp == 63) begin
                    defender_info.pkm_info.stage <= Highest;
                    defender_info.pkm_info.hp <= 254;
                    defender_info.pkm_info.atk <= 123;
                    defender_info.pkm_info.exp <= 0;
                end
            end 
            Fire	:begin
                if(defender_info.pkm_info.stage == Lowest && defender_info.pkm_info.exp == 30)begin
                    defender_info.pkm_info.stage <= Middle;
                    defender_info.pkm_info.hp <= 177;
                    defender_info.pkm_info.atk <= 96;
                    defender_info.pkm_info.exp <= 0;
                end      
                else if(defender_info.pkm_info.stage == Middle && defender_info.pkm_info.exp == 59) begin
                    defender_info.pkm_info.stage <= Highest;
                    defender_info.pkm_info.hp <= 225;
                    defender_info.pkm_info.atk <= 127;
                    defender_info.pkm_info.exp <= 0;
                end
            end 
            Water	:begin
                if(defender_info.pkm_info.stage == Lowest && defender_info.pkm_info.exp == 28)begin
                    defender_info.pkm_info.stage <= Middle;
                    defender_info.pkm_info.hp <= 187;
                    defender_info.pkm_info.atk <= 89;
                    defender_info.pkm_info.exp <= 0;
                end      
                else if(defender_info.pkm_info.stage == Middle && defender_info.pkm_info.exp == 55) begin
                    defender_info.pkm_info.stage <= Highest;
                    defender_info.pkm_info.hp <= 245;
                    defender_info.pkm_info.atk <= 113;
                    defender_info.pkm_info.exp <= 0;
                end
            end 
            Electric:begin
                if(defender_info.pkm_info.stage == Lowest && defender_info.pkm_info.exp == 26)begin
                    defender_info.pkm_info.stage <= Middle;
                    defender_info.pkm_info.hp <= 182;
                    defender_info.pkm_info.atk <= 97;
                    defender_info.pkm_info.exp <= 0;
                end      
                else if(defender_info.pkm_info.stage == Middle && defender_info.pkm_info.exp == 51) begin
                    defender_info.pkm_info.stage <= Highest;
                    defender_info.pkm_info.hp <= 235;
                    defender_info.pkm_info.atk <= 124;
                    defender_info.pkm_info.exp <= 0;
                end
            end 
        endcase
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		player_id <= 0 ;
        else if (inf.id_valid && current_state == IDLE)   player_id <= inf.D.d_id[0] ;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		defender_id <= 0 ;
        else if (inf.id_valid && current_state == GET_ACT)   defender_id <= inf.D.d_id[0] ;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)	player_act <= No_action ;
        else if (inf.act_valid) player_act <= inf.D.d_act[0] ;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) player_item <= No_item ;
        else if (inf.item_valid) player_item <= inf.D.d_item[0] ;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) player_pkm_type <= No_type ;
        else if (inf.type_valid) player_pkm_type <= inf.D.d_type[0] ;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) player_money <= 0 ;
        else if (inf.amnt_valid) player_money <= inf.D.d_money ;
    end

    //================================================================
    // Finite State Machine 
    //================================================================
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n)		current_state <= IDLE ;
        else 				current_state <= next_state ;
    end

    always_comb begin
        if (!inf.rst_n)	next_state = IDLE;
        else begin
            case (current_state)
                IDLE: begin
                    if(inf.id_valid) next_state = CHNG_ID;
                    else if(inf.act_valid) next_state = GET_ACT;
                    else next_state = IDLE; 
                end 
                CHNG_ID: next_state = (inf.act_valid)?GET_ACT : CHNG_ID;
                GET_ACT: begin
                    if(player_act == Check) next_state = (plr_info_request)?WAIT:OUT;
                    else if (inf.item_valid || inf.type_valid || inf.amnt_valid || inf.id_valid) next_state = WAIT;
                    else next_state = GET_ACT;
                end
                WAIT: begin
                    if( !def_info_request && !plr_info_request ) next_state = CHECK_ERR;
                    else next_state = WAIT;
                end 
                CHECK_ERR:begin
                    if (inf.err_msg != No_Err && stall) next_state = OUT;
                    else if (stall) next_state = EXE;
                    else next_state = CHECK_ERR;
                end 
                EXE: begin
                    if(player_act == Attack || player_act == Use_item) next_state = EVO;
                    else next_state = WRITE_B;
                end 
                EVO: next_state = WRITE_B;
                WRITE_B: next_state = (!def_info_request && !plr_info_request)? OUT : WRITE_B;
                OUT: next_state = IDLE;
                default: next_state = IDLE;
            endcase
        end
    end

    //================================================================
    // Output Logic 
    //================================================================
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) inf.err_msg <= No_Err ;
        else if(current_state == IDLE) inf.err_msg <= No_Err ;
        else if(current_state == CHECK_ERR)begin
            case (player_act)
            Buy: begin
                if(buy_pkm_item_flag == item)begin
                    case (player_item)
                    Berry: begin
                        if(player_info.bag_info.money < 16) inf.err_msg <= Out_of_money;
                        else if(player_info.bag_info.berry_num == 15) inf.err_msg <= Bag_is_full;
                        else inf.err_msg <= No_Err;
                    end 
                    Medicine: begin
                        if(player_info.bag_info.money < 128) inf.err_msg <= Out_of_money;
                        else if(player_info.bag_info.medicine_num == 15) inf.err_msg <= Bag_is_full;
                        else inf.err_msg <= No_Err;
                    end 
                    Candy: begin
                        if(player_info.bag_info.money < 300) inf.err_msg <= Out_of_money;
                        else if(player_info.bag_info.candy_num == 15) inf.err_msg <= Bag_is_full;
                        else inf.err_msg <= No_Err;
                    end 
                    Bracer: begin
                        if(player_info.bag_info.money < 64) inf.err_msg <= Out_of_money;
                        else if(player_info.bag_info.bracer_num == 15) inf.err_msg <= Bag_is_full;
                        else inf.err_msg <= No_Err;
                    end 
                    default: begin
                        if(player_info.bag_info.money < 800) inf.err_msg <= Out_of_money;
                        else if(player_info.bag_info.stone != No_stone) inf.err_msg <= Bag_is_full;
                        else inf.err_msg <= No_Err;
                    end
                    endcase
                end
                else begin
                    case (player_pkm_type)
                    Grass: begin
                        if(player_info.bag_info.money < 100) inf.err_msg <= Out_of_money;
                        else if(player_info.pkm_info.pkm_type != No_type) inf.err_msg <= Already_Have_PKM;
                        else inf.err_msg <= No_Err;
                    end 
                    Fire: begin
                        if(player_info.bag_info.money < 90) inf.err_msg <= Out_of_money;
                        else if(player_info.pkm_info.pkm_type != No_type) inf.err_msg <= Already_Have_PKM;
                        else inf.err_msg <= No_Err;
                    end 
                    Water: begin
                        if(player_info.bag_info.money < 110) inf.err_msg <= Out_of_money;
                        else if(player_info.pkm_info.pkm_type != No_type) inf.err_msg <= Already_Have_PKM;
                        else inf.err_msg <= No_Err;
                    end 
                    Electric: begin
                        if(player_info.bag_info.money < 120) inf.err_msg <= Out_of_money;
                        else if(player_info.pkm_info.pkm_type != No_type) inf.err_msg <= Already_Have_PKM;
                        else inf.err_msg <= No_Err;
                    end 
                    Normal: begin
                        if(player_info.bag_info.money < 130) inf.err_msg <= Out_of_money;
                        else if(player_info.pkm_info.pkm_type != No_type) inf.err_msg <= Already_Have_PKM;
                        else inf.err_msg <= No_Err;
                    end  
                    endcase
                end
            end
            Sell: begin
                if(buy_pkm_item_flag == item)begin
                    case (player_item)
                    Berry: begin
                        if(player_info.bag_info.berry_num == 0) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end 
                    Medicine: begin
                        if(player_info.bag_info.medicine_num == 0) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end 
                    Candy: begin
                        if(player_info.bag_info.candy_num == 0) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end 
                    Bracer: begin
                        if(player_info.bag_info.bracer_num == 0) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end 
                    Water_stone : begin
                        if(player_info.bag_info.stone != W_stone) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end
                    Fire_stone : begin
                        if(player_info.bag_info.stone != F_stone) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end
                    Thunder_stone : begin
                        if(player_info.bag_info.stone != T_stone) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end
                    endcase
                end
                else begin
                    if(player_info.pkm_info.pkm_type == No_type) inf.err_msg <= Not_Having_PKM;
                    else if(player_info.pkm_info.stage == Lowest) inf.err_msg <= Has_Not_Grown;
                    else inf.err_msg <= No_Err;
                end
            end
            Deposit: inf.err_msg <= No_Err;
            Use_item: begin
                if (player_info.pkm_info.pkm_type == No_type) inf.err_msg <= Not_Having_PKM;
                else begin
                    case (player_item)
                    Berry: begin
                        if(player_info.bag_info.berry_num == 0) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end 
                    Medicine: begin
                        if(player_info.bag_info.medicine_num == 0) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end 
                    Candy: begin
                        if(player_info.bag_info.candy_num == 0) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end 
                    Bracer: begin
                        if(player_info.bag_info.bracer_num == 0) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end 
                    Water_stone : begin
                        if(player_info.bag_info.stone != W_stone) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end
                    Fire_stone : begin
                        if(player_info.bag_info.stone != F_stone) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end
                    Thunder_stone : begin
                        if(player_info.bag_info.stone != T_stone) inf.err_msg <= Not_Having_Item;
                        else inf.err_msg <= No_Err;
                    end
                    endcase
                end
            end
            Check: inf.err_msg <= No_Err;
            Attack: begin
                if(player_info.pkm_info.pkm_type == No_type || defender_info.pkm_info.pkm_type == No_type) inf.err_msg <= Not_Having_PKM;
                else if (player_info.pkm_info.hp == 0 || defender_info.pkm_info.hp == 0) inf.err_msg <= HP_is_Zero;
                else inf.err_msg <= No_Err;
            end 
            endcase
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) inf.complete <= 0 ;
        else if(inf.err_msg == No_Err) inf.complete <= 1;
        else inf.complete <= 0;
    end
    // always_comb begin
    //     if (!inf.rst_n) inf.complete = 0 ;
    //     else if(inf.err_msg == No_Err) inf.complete = 1;
    //     else inf.complete = 0;
    // end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) inf.out_valid <= 0 ;
        else if(current_state == OUT) inf.out_valid <= 1;
        else inf.out_valid <= 0;
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) inf.out_info <= 0 ;
        else if(current_state == OUT && inf.err_msg == No_Err) begin
            if(player_act == Attack) inf.out_info <= {player_info.pkm_info, defender_info.pkm_info};
            else begin
                inf.out_info[63:60] <= player_info.bag_info.berry_num    ; 
                inf.out_info[59:56] <= player_info.bag_info.medicine_num ; 
                inf.out_info[55:52] <= player_info.bag_info.candy_num    ; 
                inf.out_info[51:48] <= player_info.bag_info.bracer_num   ; 
                inf.out_info[47:46] <= player_info.bag_info.stone        ; 
                inf.out_info[45:32] <= player_info.bag_info.money        ; 
                inf.out_info[31:28] <= player_info.pkm_info.stage        ;
                inf.out_info[27:24] <= player_info.pkm_info.pkm_type     ; 
                inf.out_info[23:16] <= player_info.pkm_info.hp           ; 
                inf.out_info[15: 8] <= temp_atk; 
                inf.out_info[ 7: 0] <= player_info.pkm_info.exp          ;
            end   
        end
        else inf.out_info <= 0 ;
    end
    endmodule


