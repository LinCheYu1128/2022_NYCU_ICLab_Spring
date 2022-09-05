module ESCAPE(
    //Input Port
    clk,
    rst_n,
    in_valid1,
    in_valid2,
    in,
    in_data,
    //Output Port
    out_valid1,
    out_valid2,
    out,
    out_data
);

//==================INPUT OUTPUT==================//
    input clk, rst_n, in_valid1, in_valid2;
    input [1:0] in;
    input [8:0] in_data;    
    output reg	out_valid1, out_valid2;
    output reg [2:0] out;
    output reg [8:0] out_data;
//================================================//    

// ======Parameters & Integer Declaration=========//
    parameter IDLE   = 3'b000;
    parameter LOAD   = 3'b001;
    parameter OUTDIR = 3'b011;
    parameter SORT   = 3'b010;
    parameter OUTPWD = 3'b110;
    integer i,j;
// ==============================================//

//==================Register==================//
reg [2:0] current_state, next_state;
reg [2:0] maze[0:18][0:18]; // 0:Wall 1:Path 2:Trap 3:HostagePath 4:HostagePathWithTrap 5:WentBefore
reg [4:0] x,y;
reg [5:0] wait_counter;
reg [1:0] pos_st[1:17][1:17]; // 0:Main_road 1:Dead_road 2:Hostage_road 3:Hostage_road_with_trap
reg [1:0] wall_counter;
reg [1:0] hostage_counter;
reg [9:0] hostage [0:3];
reg signed [8:0] passward [0:3];
reg signed [8:0] sort_pwd [0:3];
reg signed [8:0] out_pwd [0:3];
reg signed [8:0] cum_pwd [1:3];

reg signed [8:0] tempA, temp;
reg signed [8:0] max, min;
reg [2:0] dir;
reg [2:0] hostage_num;
reg [2:0] counter;
reg in_stall;
reg get_pwd;
reg sort_fin;
reg dead_road_flag;

wire is_hostage;
wire fin_trigger;

//============================================//  
assign fin_trigger = ( x =='d17 && y == 'd17 && (maze[16][17] == 'd5 || maze[16][17] == 'd0) && (maze[17][16] == 'd5 || maze[17][16]== 'd0)  && x)? 1: 0;
assign is_hostage = ({x,y} == hostage[0] || {x,y} == hostage[1] || {x,y} == hostage[2] || {x,y} == hostage[3])? 1: 0;
//==================Design==================//
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         is_hostage <= 0;
//     end
//     else if ({x,y} == hostage[0] || {x,y} == hostage[1] || {x,y} == hostage[2] || {x,y} == hostage[3]) is_hostage <= 1;
//     else is_hostage <= 0;
// end
always @(posedge clk or negedge rst_n) begin // CAL ANS
    if(!rst_n) begin
        out_pwd[0] <= 'd0;
        out_pwd[1] <= 'd0;
        out_pwd[2] <= 'd0;
        out_pwd[3] <= 'd0;
    end
    // SORT
    else if(current_state == SORT)begin
        case (counter)
            0: begin
                out_pwd[0] <= sort_pwd[0] ;
                out_pwd[1] <= sort_pwd[1] ;
                out_pwd[2] <= sort_pwd[2] ;
                out_pwd[3] <= sort_pwd[3] ;
            end
            1:begin
                if(hostage_num == 2 || hostage_num == 4 )begin
                    out_pwd[0] <= (out_pwd[0][8])? ~((out_pwd[0][7:4]-4'b0011)*'d10 + (out_pwd[0][3:0]-4'b0011))+1:((out_pwd[0][7:4]-4'b0011)*'d10 + (out_pwd[0][3:0]-4'b0011));
                    out_pwd[1] <= (out_pwd[1][8])? ~((out_pwd[1][7:4]-4'b0011)*'d10 + (out_pwd[1][3:0]-4'b0011))+1:((out_pwd[1][7:4]-4'b0011)*'d10 + (out_pwd[1][3:0]-4'b0011));
                    out_pwd[2] <= (out_pwd[2][8])? ~((out_pwd[2][7:4]-4'b0011)*'d10 + (out_pwd[2][3:0]-4'b0011))+1:((out_pwd[2][7:4]-4'b0011)*'d10 + (out_pwd[2][3:0]-4'b0011));
                    out_pwd[3] <= (out_pwd[3][8])? ~((out_pwd[3][7:4]-4'b0011)*'d10 + (out_pwd[3][3:0]-4'b0011))+1:((out_pwd[3][7:4]-4'b0011)*'d10 + (out_pwd[3][3:0]-4'b0011));
                end    
            end  
            2:begin
                out_pwd[0] <= out_pwd[0] - tempA;
                out_pwd[1] <= out_pwd[1] - tempA;
                out_pwd[2] <= out_pwd[2] - tempA;
                out_pwd[3] <= out_pwd[3] - tempA;
            end
            3:begin
                out_pwd[1] <= cum_pwd[1];
                out_pwd[2] <= cum_pwd[2];
                out_pwd[3] <= cum_pwd[3];
            end
        endcase
    end
end

always @(*) begin // CUM 
    cum_pwd[1] = (out_pwd[0]*2 + out_pwd[1])/3; 
    cum_pwd[2] = (cum_pwd[1]*2 + out_pwd[2])/3;
    cum_pwd[3] = (cum_pwd[2]*2 + out_pwd[3])/3; 
end

always @(*) begin // SUB SUBTRACT
    if(out_pwd[1] < out_pwd[0]) begin 
        min = out_pwd[1];
        max = out_pwd[0];
    end
    else begin 
        min = out_pwd[0];
        max = out_pwd[1]; 
    end
    if(hostage_num>2)begin
        if(out_pwd[2] < min) min = out_pwd[2];
        if(out_pwd[2] > max) max = out_pwd[2];
    end
    if(hostage_num>3)begin
        if(out_pwd[3] < min) min = out_pwd[3];
        if(out_pwd[3] > max) max = out_pwd[3];
    end
    tempA = (min + max)/2;
end

always @(*) begin // SORT
    sort_pwd[0] = passward[0];
    sort_pwd[1] = passward[1];
    sort_pwd[2] = passward[2];
    sort_pwd[3] = passward[3];

    if(hostage_num > 1) begin
        if(sort_pwd[0] < sort_pwd[1])begin
            temp = sort_pwd[0];
            sort_pwd[0] = sort_pwd[1];
            sort_pwd[1] = temp;
        end
    end
    if(hostage_num > 2) begin
        if(sort_pwd[1] < sort_pwd[2])begin
            temp = sort_pwd[1];
            sort_pwd[1] = sort_pwd[2];
            sort_pwd[2] = temp;
        end
        if(sort_pwd[0] < sort_pwd[1])begin
            temp = sort_pwd[0];
            sort_pwd[0] = sort_pwd[1];
            sort_pwd[1] = temp;
        end  
    end
    if(hostage_num == 4) begin
        if(sort_pwd[2] < sort_pwd[3])begin
            temp = sort_pwd[2];
            sort_pwd[2] = sort_pwd[3];
            sort_pwd[3] = temp;
        end
        if(sort_pwd[1] < sort_pwd[2])begin
            temp = sort_pwd[1];
            sort_pwd[1] = sort_pwd[2];
            sort_pwd[2] = temp;
        end
        if(sort_pwd[0] < sort_pwd[1])begin
            temp = sort_pwd[0];
            sort_pwd[0] = sort_pwd[1];
            sort_pwd[1] = temp;
        end
    end 
end

always @(*) begin
    dead_road_flag = 'd0;
    for(j = 1; j < 18; j = j + 1)begin
        for(i = 1; i < 18; i = i + 1)begin
            dead_road_flag = (pos_st[j][i] || dead_road_flag);
        end
    end
end

always@(*)begin          // check dead_road
    for(j = 1; j < 18; j = j + 1)begin
        for(i = 1; i < 18; i = i + 1)begin
            wall_counter = 'd0;
            hostage_counter = 'd0;
            if(maze[j-1][i] == 'd0) wall_counter = wall_counter + 'd1;
            if(maze[j+1][i] == 'd0) wall_counter = wall_counter + 'd1;
            if(maze[j][i-1] == 'd0) wall_counter = wall_counter + 'd1;
            if(maze[j][i+1] == 'd0) wall_counter = wall_counter + 'd1;

            if(maze[j-1][i] == 'd3 || maze[j-1][i] == 'd4) hostage_counter = hostage_counter + 'd1;
            if(maze[j+1][i] == 'd3 || maze[j+1][i] == 'd4) hostage_counter = hostage_counter + 'd1;
            if(maze[j][i-1] == 'd3 || maze[j][i-1] == 'd4) hostage_counter = hostage_counter + 'd1;
            if(maze[j][i+1] == 'd3 || maze[j][i+1] == 'd4) hostage_counter = hostage_counter + 'd1;
            
            if((hostage_counter == 'd1 && wall_counter == 'd2) || 
               (hostage_counter == 'd2 && wall_counter == 'd1) || 
               (hostage_counter == 'd3 && wall_counter == 'd0)) begin
                if(maze[j][i] == 'd1) pos_st[j][i] = 'd2;
                else if(maze[j][i] == 'd2) pos_st[j][i] = 'd3;
                else pos_st[j][i] = 'd0;
            end
            else if(wall_counter == 'd3 && maze[j][i] != 'd3 && maze[j][i] != 'd7 && maze[j][i] != 'd0) pos_st[j][i] = 'd1;
            else pos_st[j][i] = 'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        hostage[0] <= 'd0;        
        hostage[1] <= 'd0;
        hostage[2] <= 'd0;
        hostage[3] <= 'd0;
    end
    else if(in_valid1) begin
        if(in == 'd3)
            hostage[hostage_num] <= {x,y};
    end
    else if(current_state == IDLE)begin
        hostage[0] <= 'd0;        
        hostage[1] <= 'd0;
        hostage[2] <= 'd0;
        hostage[3] <= 'd0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        passward[0] <= 'd0;
        passward[1] <= 'd0;
        passward[2] <= 'd0;
        passward[3] <= 'd0;
    end
    else if(current_state == IDLE)begin
        passward[0] <= 'd0;
        passward[1] <= 'd0;
        passward[2] <= 'd0;
        passward[3] <= 'd0;
    end
    else if(in_valid2) begin
        case (counter)
            0: passward[0] <= in_data;
            1: passward[1] <= in_data;
            2: passward[2] <= in_data;
            3: passward[3] <= in_data;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin // counter
    if(!rst_n) counter <= 'd0;
    else if(current_state == OUTDIR) begin
        if(counter==hostage_num) counter <= 'd0;
        else counter <= (in_valid2)? counter + 'd1 : counter;
        // counter <= (in_valid2)? counter + 'd1 : counter;
    end
    else if(current_state == SORT) begin
        counter <= (sort_fin)? 'd0: counter + 1;
    end
    else if(current_state == OUTPWD) counter <= counter + 'd1;
    else counter <= 'd0;
end

always @(posedge clk or negedge rst_n) begin // sort finish
    if(!rst_n) sort_fin <= 'd0;
    else if(current_state == SORT)begin
        if(hostage_num < 2) sort_fin <= 'd1;
        else if(hostage_num > 2) sort_fin <= (counter == 'd2)? 'd1 :'d0;
        else sort_fin <= (counter == 'd1)? 'd1 :'d0;
    end
    else sort_fin <= 'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) get_pwd <= 'd0;
    else if(in_valid2) get_pwd <= 'd1;
    else get_pwd <= 'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) in_stall <= 'd0;
    else if(dir == 'd4) in_stall <= 'd1;
    else in_stall <= 'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) wait_counter <= 'd0;
    else if(in_valid1) wait_counter <= 'd0;
    else if(current_state == LOAD) wait_counter <= wait_counter + 'd1;
    else wait_counter <= 'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) hostage_num <= 'd0;
    else if(current_state == IDLE) hostage_num <= 'd0;
    else if(in_valid1) hostage_num <= (in == 'd3)?hostage_num + 'd1: hostage_num;
    else hostage_num <= hostage_num;
end

always @(*) begin // direction
    if(is_hostage && !get_pwd) dir = 3'd4;
    else if((maze[y][x] == 'd4 || maze[y][x] == 'd2 || maze[y][x] == 'd7) && !in_stall) dir = 3'd4; //stall
    else if(maze[y + 'd1][x] == 'd3 || maze[y + 'd1][x] == 'd4) dir = 3'd1; //down
    else if(maze[y][x - 'd1] == 'd3 || maze[y][x - 'd1] == 'd4) dir = 3'd2; //left
    else if(maze[y][x + 'd1] == 'd3 || maze[y][x + 'd1] == 'd4) dir = 3'd0; //right
    else if(maze[y - 'd1][x] == 'd3 || maze[y - 'd1][x] == 'd4) dir = 3'd3; //up
    else if(maze[y + 'd1][x] == 'd1 || maze[y + 'd1][x] == 'd2) dir = 3'd1; //down
    else if(maze[y][x - 'd1] == 'd1 || maze[y][x - 'd1] == 'd2) dir = 3'd2; //left
    else if(maze[y][x + 'd1] == 'd1 || maze[y][x + 'd1] == 'd2) dir = 3'd0; //right
    else if(maze[y - 'd1][x] == 'd1 || maze[y - 'd1][x] == 'd2) dir = 3'd3; //up
    else if(maze[y + 'd1][x] == 'd6 || maze[y + 'd1][x] == 'd7) dir = 3'd1; 
    else if(maze[y][x - 'd1] == 'd6 || maze[y][x - 'd1] == 'd7) dir = 3'd2; 
    else if(maze[y][x + 'd1] == 'd6 || maze[y][x + 'd1] == 'd7) dir = 3'd0; 
    else if(maze[y - 'd1][x] == 'd6 || maze[y - 'd1][x] == 'd7) dir = 3'd3;  
    else dir = 3'd4; 
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) x <= 1;
    else if(in_valid1) x <= (x < 'd17)? x + 1 : 1;
    else if (current_state == OUTDIR) begin
        case (dir)
            'd0 : begin
                x <= x + 'd1; // right
            end
            'd1 : begin 
                x <= x; // down
            end
            'd2 : begin
                x <= x - 'd1; // left
            end
            'd3 : begin
                x <= x; // up
            end
            'd4 : begin
                x <= x; // stall
            end
	    endcase
    end
    else if (!dead_road_flag) x <= 1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) y <= 1;
    else if(in_valid1) begin
        if(y > 'd16) y <= y;
        else y <= (x == 'd17)? y + 1 : y;
    end 
    else if(current_state == OUTDIR) begin
        case (dir)
	        'd0 : begin
		        y <= y;
	        end
	        'd1 : begin
                y <= y + 'd1;
	        end
	        'd2 : begin
                y <= y;
            end
	        'd3 : begin
                y <= y - 'd1;
            end
            'd4 : begin
                y <= y;
            end 
	    endcase
    end
    else if (!dead_road_flag) y <= 1;
end

always @(posedge clk) begin
    case (current_state)
        IDLE:begin
            for(i = 0; i < 19; i = i + 1)begin
                maze[i][0] <= 'd0;
                maze[i][18] <= 'd0;
            end
            for(i = 2; i < 18; i = i + 1) maze[0][i] <= 'd0;
            for(i = 1; i < 17; i = i + 1) maze[18][i] <= 'd0;
            maze[0][1] <= 'd1;
            maze[18][17] <= 'd1;
            for(i = 1; i < 18; i = i + 1)begin
                for(j = 1; j < 18; j = j + 1)begin
                    maze[j][i] <= 'd7;
                end
            end
        end 
        LOAD:begin
            for(j = 1; j < 18; j = j + 1)begin
                for(i = 1; i < 18; i = i + 1)begin
                    // if(x == 'd17 && y == 'd17) maze[17][17] <= 'd1;
                    if(in_valid1 && x == i && y == j)begin
                        maze[j][i] <= in;
                    end
                    else if(pos_st[j][i] == 'd1) maze[j][i] <= 'd0;
                    else if(pos_st[j][i] == 'd2) maze[j][i] <= 'd3;
                    else if(pos_st[j][i] == 'd3) maze[j][i] <= 'd4;
                    else maze[j][i] <= maze[j][i];
                end
            end
        end
        OUTDIR:begin
            maze[0][1] <= 'd0;
            if(maze[y][x] == 'd3) maze[y][x] <= 'd6;
            else if(maze[y][x] == 'd4) maze[y][x] <= 'd7;
            else if(maze[y - 'd1][x] == 'd3 || maze[y + 'd1][x] == 'd3 || maze[y][x - 'd1] == 'd3 || maze[y][x + 'd1] == 'd3 || 
                    maze[y - 'd1][x] == 'd4 || maze[y + 'd1][x] == 'd4 || maze[y][x - 'd1] == 'd4 || maze[y][x + 'd1] == 'd4 ) maze[y][x] <= maze[y][x];
            else maze[y][x] <= 'd5;
        end 
    endcase    
end

//==========================================//  

// =============Finite State Machine=========//
// Current State
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else        current_state <= next_state;
end

// Next State
always @(*) begin
    if (!rst_n) next_state = IDLE;
    else begin
        case (current_state)
            IDLE  : next_state = (!in_valid1)? IDLE : LOAD;
            LOAD  : next_state = (!in_valid1 && !dead_road_flag)? OUTDIR : LOAD;//wait_counter == 'd50
            OUTDIR: next_state = (fin_trigger)? SORT: OUTDIR;
            SORT  : next_state = (sort_fin)? OUTPWD:SORT ;
            OUTPWD: begin
                if(hostage_num == 0) next_state = (counter == 1)? IDLE: OUTPWD;
                else next_state = (counter == hostage_num)? IDLE: OUTPWD;
            end 
            default : next_state = current_state; 
        endcase
    end
end

// Output Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out <= 3'd0;
    else if(current_state == OUTDIR && !fin_trigger)begin
    //     // out <= (is_hostage && !get_pwd)? 3'd0: dir;
    //     // if(is_hostage && !get_pwd)  out <= 3'd0;
    //     // else if((maze[y][x] == 'd4 || maze[y][x] == 'd2 || maze[y][x] == 'd7) && !in_stall)  out <= 3'd4; //stall
    //     // else if(maze[y + 'd1][x] == 'd3 || maze[y + 'd1][x] == 'd4) out <= 3'd1; //down
    //     // else if(maze[y][x - 'd1] == 'd3 || maze[y][x - 'd1] == 'd4) out <= 3'd2; //left
    //     // else if(maze[y][x + 'd1] == 'd3 || maze[y][x + 'd1] == 'd4) out <= 3'd0; //right
    //     // else if(maze[y - 'd1][x] == 'd3 || maze[y - 'd1][x] == 'd4) out <= 3'd3; //up
    //     // else if(maze[y + 'd1][x] == 'd1 || maze[y + 'd1][x] == 'd2) out <= 3'd1; //down
    //     // else if(maze[y][x - 'd1] == 'd1 || maze[y][x - 'd1] == 'd2) out <= 3'd2; //left
    //     // else if(maze[y][x + 'd1] == 'd1 || maze[y][x + 'd1] == 'd2) out <= 3'd0; //right
    //     // else if(maze[y - 'd1][x] == 'd1 || maze[y - 'd1][x] == 'd2) out <= 3'd3; //up
    //     // else if(maze[y + 'd1][x] == 'd6 || maze[y + 'd1][x] == 'd7) out <= 3'd1; 
    //     // else if(maze[y][x - 'd1] == 'd6 || maze[y][x - 'd1] == 'd7) out <= 3'd2; 
    //     // else if(maze[y][x + 'd1] == 'd6 || maze[y][x + 'd1] == 'd7) out <= 3'd0; 
    //     // else if(maze[y - 'd1][x] == 'd6 || maze[y - 'd1][x] == 'd7) out <= 3'd3;  
    //     // else out <= 3'd0;
        case (dir)
            3'd0: out <= 3'd0;
            3'd1: out <= 3'd1;
            3'd2: out <= 3'd2;
            3'd3: out <= 3'd3;
            3'd4: out <= (is_hostage && !get_pwd)? 3'd0: 3'd4; 
        endcase
        // out <= 3'd4;
    end
    else out <= 3'd0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_data <= 9'd0;
    else if(current_state == OUTPWD && counter < hostage_num)begin
        case (counter)
            0: out_data <= out_pwd[0];
            1: out_data <= out_pwd[1];
            2: out_data <= out_pwd[2];
            3: out_data <= out_pwd[3];
        endcase
    end
    else out_data <= 9'd0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     out_valid2 <= 'd0;
    else if(current_state == OUTDIR)begin
        if(is_hostage && !get_pwd) out_valid2 <= 'd0;
        else if (fin_trigger) out_valid2 <= 'd0;
        else out_valid2 <= 'd1;
    end
    else out_valid2 <= 'd0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     out_valid1 <= 'd0;
    else if(current_state == OUTPWD) begin
        if(hostage_num == 0 && counter < 1) out_valid1 <= 'd1;
        else if (counter < hostage_num ) out_valid1 <= 'd1;
        else out_valid1 <= 'd0;
    end
    else out_valid1 <= 'd0;
end
// ==========================================//
endmodule
