`ifdef RTL
    `define CYCLE_TIME 20
`endif
`ifdef GATE
    `define CYCLE_TIME 4.5
`endif
`ifdef POST
    `define CYCLE_TIME 6.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"

module PATTERN #(parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32)(
    // CHIP IO 
    clk,    
    rst_n,    
    in_valid,    
    start,
    stop,
    inputtype,
    frame_id,    
    busy,

    // AXI4 IO
    awid_s_inf,
    awaddr_s_inf,
    awsize_s_inf,
    awburst_s_inf,
    awlen_s_inf,
    awvalid_s_inf,
    awready_s_inf,

    wdata_s_inf,
    wlast_s_inf,
    wvalid_s_inf,
    wready_s_inf,

    bid_s_inf,
    bresp_s_inf,
    bvalid_s_inf,
    bready_s_inf,

    arid_s_inf,
    araddr_s_inf,
    arlen_s_inf,
    arsize_s_inf,
    arburst_s_inf,
    arvalid_s_inf,

    arready_s_inf, 
    rid_s_inf,
    rdata_s_inf,
    rresp_s_inf,
    rlast_s_inf,
    rvalid_s_inf,
    rready_s_inf 
);

// ===============================================================
//                      Input / Output 
// ===============================================================

// << CHIP io port with system >>
output reg              clk, rst_n;
output reg              in_valid;
output reg              start;
output reg [15:0]       stop;     
output reg [1:0]        inputtype; 
output reg [4:0]        frame_id;
input                   busy;       

// << AXI Interface wire connecttion for pseudo DRAM read/write >>
// (1)     axi write address channel 
//         src master
input wire [ID_WIDTH-1:0]      awid_s_inf;
input wire [ADDR_WIDTH-1:0]  awaddr_s_inf;
input wire [2:0]             awsize_s_inf;
input wire [1:0]            awburst_s_inf;
input wire [7:0]              awlen_s_inf;
input wire                  awvalid_s_inf;
//         src slave
output wire                 awready_s_inf;
// -----------------------------

// (2)    axi write data channel 
//         src master
input wire [DATA_WIDTH-1:0]   wdata_s_inf;
input wire                    wlast_s_inf;
input wire                   wvalid_s_inf;
//         src slave
output wire                  wready_s_inf;

// (3)    axi write response channel 
//         src slave
output wire  [ID_WIDTH-1:0]     bid_s_inf;
output wire  [1:0]            bresp_s_inf;
output wire                  bvalid_s_inf;
//         src master 
input wire                   bready_s_inf;
// -----------------------------

// (4)    axi read address channel 
//         src master
input wire [ID_WIDTH-1:0]      arid_s_inf;
input wire [ADDR_WIDTH-1:0]  araddr_s_inf;
input wire [7:0]              arlen_s_inf;
input wire [2:0]             arsize_s_inf;
input wire [1:0]            arburst_s_inf;
input wire                  arvalid_s_inf;
//         src slave
output wire                 arready_s_inf;
// -----------------------------

// (5)    axi read data channel 
//         src slave
output wire [ID_WIDTH-1:0]      rid_s_inf;
output wire [DATA_WIDTH-1:0]  rdata_s_inf;
output wire [1:0]             rresp_s_inf;
output wire                   rlast_s_inf;
output wire                  rvalid_s_inf;
//         src master
input wire                   rready_s_inf;


// -------------------------//
//     DRAM Connection      //
//--------------------------//

pseudo_DRAM u_DRAM(
    .clk(clk),
    .rst_n(rst_n),

    .   awid_s_inf(   awid_s_inf),
    . awaddr_s_inf( awaddr_s_inf),
    . awsize_s_inf( awsize_s_inf),
    .awburst_s_inf(awburst_s_inf),
    .  awlen_s_inf(  awlen_s_inf),
    .awvalid_s_inf(awvalid_s_inf),
    .awready_s_inf(awready_s_inf),

    .  wdata_s_inf(  wdata_s_inf),
    .  wlast_s_inf(  wlast_s_inf),
    . wvalid_s_inf( wvalid_s_inf),
    . wready_s_inf( wready_s_inf),

    .    bid_s_inf(    bid_s_inf),
    .  bresp_s_inf(  bresp_s_inf),
    . bvalid_s_inf( bvalid_s_inf),
    . bready_s_inf( bready_s_inf),

    .   arid_s_inf(   arid_s_inf),
    . araddr_s_inf( araddr_s_inf),
    .  arlen_s_inf(  arlen_s_inf),
    . arsize_s_inf( arsize_s_inf),
    .arburst_s_inf(arburst_s_inf),
    .arvalid_s_inf(arvalid_s_inf),
    .arready_s_inf(arready_s_inf), 

    .    rid_s_inf(    rid_s_inf),
    .  rdata_s_inf(  rdata_s_inf),
    .  rresp_s_inf(  rresp_s_inf),
    .  rlast_s_inf(  rlast_s_inf),
    . rvalid_s_inf( rvalid_s_inf),
    . rready_s_inf( rready_s_inf) 
);

real CYCLE = `CYCLE_TIME;
always  #(`CYCLE_TIME/2.0)  clk = ~clk ;
initial clk = 0 ;

parameter FRAME = 32;
parameter MAX_CYCLE = 50_000;
parameter PATTERN_NUM = 100;
parameter TOTAL_PIXEL = 16;

integer framecount, patcount;
integer in_read, out_read;
integer i, j, l, a, gap;
integer curr_cycle, cycles, total_cycles;
integer addr;   
integer accuracy, correct_pixel; 
integer fail_count;
integer total_error_0, total_error_1, total_error_2, total_error_3;

reg [7:0] temp [0:15][0:254];
reg [7:0] distance [0:31][0:15];
reg [6:0] stop_reg [0:15][0:254];
reg [1:0] type_reg;
    // initialize DRAM: $readmemh("../00_TESTBED/dram.dat", u_DRAM.DRAM_r);
    // direct access DRAM: u_DRAM.DRAM_r[addr][7:0];

initial begin
    $readmemh("../00_TESTBED/dram.dat", u_DRAM.DRAM_r);
    in_read   = $fopen("../00_TESTBED/input.txt", "r");
    out_read  = $fopen("../00_TESTBED/output.txt", "r");
    rst_n     = 'b1;
    in_valid  = 'bx;
    start     = 'bx;
    stop      = 'bx;     
    inputtype = 'bx; 
    frame_id  = 'bx;
    force clk = 0 ;

    reset_task;
    total_cycles = 0;
    fail_count = 0;
    total_error_0 = 0;
    total_error_1 = 0;
    total_error_2 = 0;
    total_error_3 = 0;
    // start type 0
    load_output;
    type_reg = 0;
    for(framecount = 0; framecount < FRAME; framecount = framecount + 1)begin
        load_dram;
        input_task_0;
        wait_busy_task;
        check_answer;
    end
    // start other type
    for(patcount = 0; patcount < PATTERN_NUM; patcount = patcount + 1)begin
        load_input;
        input_task;
        wait_busy_task;
        check_answer;
    end
    YOU_PASS_task;
    repeat(5) @(negedge clk);
    $finish;
end

task load_input; begin
    a = $fscanf(in_read, "%d %d", type_reg, framecount);
    if(type_reg == 1)begin
        for(i=0; i<16; i=i+1)begin
            a = $fscanf(in_read, "%d", l);
            for(j=0; j<255; j=j+1)begin
                a = $fscanf(in_read, "%d %d %d %d %d", l, stop_reg[i][j][0], stop_reg[i][j][1], stop_reg[i][j][2], stop_reg[i][j][3]);
                temp[i][j] = stop_reg[i][j][0] +  stop_reg[i][j][1] + stop_reg[i][j][2] + stop_reg[i][j][3];
            end
        end
    end
    else begin
        for(i=0; i<16; i=i+1)begin
            a = $fscanf(in_read, "%d", l);
            for(j=0; j<255; j=j+1)begin
                a = $fscanf(in_read, "%d %d %d %d %d %d %d %d", l, stop_reg[i][j][0], stop_reg[i][j][1], stop_reg[i][j][2], stop_reg[i][j][3], stop_reg[i][j][4], stop_reg[i][j][5], stop_reg[i][j][6]);
                temp[i][j] = stop_reg[i][j][0] +  stop_reg[i][j][1] + stop_reg[i][j][2] + stop_reg[i][j][3] + stop_reg[i][j][4] + stop_reg[i][j][5] + stop_reg[i][j][6];
            end
        end
    end
    for(j=0; j<16; j=j+1)begin
        a = $fscanf(out_read, "%d", distance[framecount][j]);
        distance[framecount][j] = distance[framecount][j] + 1;
    end
end endtask

task load_output; begin
    for(i=0; i<32; i=i+1)begin
        for(j=0; j<16; j=j+1)begin
            a = $fscanf(out_read, "%d", distance[i][j]);
            distance[i][j] = distance[i][j] + 1;
        end
    end
end endtask

task load_dram; begin
   for(i=0; i<16; i=i+1)begin
        for(j=0; j<255; j=j+1)begin
            addr = { 12'h000, framecount[7:0]+8'h10, i[3:0], j[7:0]};
            temp[i][j] = u_DRAM.DRAM_r[addr][7:0];
        end
    end 
end endtask

task input_task; begin
	$display ("\033[1;34mPattern %3d Start Frame No.%1d, Type %d\033[1;0m", patcount, framecount, type_reg);
	gap = $urandom_range(3,10);
	repeat(gap) @(negedge clk);
	in_valid  = 1'b1;
    start     = 'b0;
    stop      = 'b0;
	inputtype = type_reg;
    frame_id  = framecount;
    
    @(negedge clk);
    inputtype = 'bx;
    frame_id  = 'bx;

    if(type_reg == 1)begin
        for(i=0; i < 4; i=i+1)begin
            start = 0;
            stop  = 0;
            repeat(gap-1) @(negedge clk);
            start = 1;
            for (j = 0; j<255; j=j+1) begin
                for(l = 0; l<16; l=l+1)begin
                    stop[l] = stop_reg[l][j][i];
                end
                @(negedge clk);
            end
        end
    end
    else begin
        for(i=0; i < 7; i=i+1)begin
            start = 0;
            stop  = 0;
            repeat(gap-1) @(negedge clk);
            start = 1;
            for (j = 0; j<255; j=j+1) begin
                for(l = 0; l<16; l=l+1)begin
                    stop[l] = stop_reg[l][j][i];
                end
                @(negedge clk);
            end
        end
    end

    in_valid  = 'b0;
    start     = 'bx;
    stop      = 'bx;
    inputtype = 'bx;
    frame_id  = 'bx;
end endtask

task input_task_0; begin
	$display ("\033[1;34mStart Frame No.%1d, Type %d\033[1;0m", framecount, type_reg);
	gap = $urandom_range(3,10);
	repeat(gap) @(negedge clk);
	in_valid = 1'b1;
    start     = 'b0;
    stop      = 'b0;
	inputtype = 0;
    frame_id  = framecount;
    
    @(negedge clk);
    in_valid  = 'b0;
    start     = 'bx;
    stop      = 'bx;
    inputtype = 'bx;
    frame_id  = 'bx;
end endtask

task check_answer; begin
    correct_pixel = 0;
    for(i=0; i<16; i=i+1)begin
        for(j=0; j<255; j=j+1)begin
            addr = { 12'h000, framecount[7:0]+8'h10, i[3:0], j[7:0]};
            if(temp[i][j] !== u_DRAM.DRAM_r[addr][7:0])begin
                $display ("=====================================================================================");
                $display ("                            Your histogram is Wrong!       				            ");
                $display ("                              Wrong answer at : %h       	                   ",addr);
			    $display ("                              Your Answer is : %h       	   ",u_DRAM.DRAM_r[addr][7:0]);
                $display ("                           Correct Answer is : %h                        ", temp[i][j]);
                $display ("=====================================================================================");
                repeat(1)  @(negedge clk);
                $finish;
            end 
        end
        addr = { 12'h000, framecount[7:0]+8'h10, i[3:0], 8'hFF};
        
        if(u_DRAM.DRAM_r[addr][7:0] === 0) error_task; 
        // if(u_DRAM.DRAM_r[addr][7:0] > 251 && type_reg[1] == 0) error_task;
        // if(u_DRAM.DRAM_r[addr][7:0] > 236 && type_reg[1] == 1) error_task;

        if((u_DRAM.DRAM_r[addr][7:0] <= distance[framecount][i] + 3)&&(u_DRAM.DRAM_r[addr][7:0] >= distance[framecount][i] - ((distance[framecount][i]>=3)?3:distance[framecount][i])))begin
            correct_pixel = correct_pixel + 1;
            // if(u_DRAM.DRAM_r[addr][7:0] <= distance[framecount][i])
            //     $display ("     \033[1;32mPASS! \033[1;0m Deviation : %d"   ,  distance[framecount][i] - u_DRAM.DRAM_r[addr][7:0]);
            // else
            //     $display ("     \033[1;32mPASS! \033[1;0m Deviation : %d"   , u_DRAM.DRAM_r[addr][7:0] - distance[framecount][i]);
        end
        else begin
            // if(u_DRAM.DRAM_r[addr][7:0] <= distance[framecount][i])begin
            //     $display ("     \033[1;31mFAIL! \033[1;0m Deviation : %d"   ,  distance[framecount][i] - u_DRAM.DRAM_r[addr][7:0]);
            // end
            // else begin
            //     $display ("     \033[1;31mFAIL! \033[1;0m Deviation : %d"   , u_DRAM.DRAM_r[addr][7:0] - distance[framecount][i]);
            // end  
            // $display ("=====================================================================================");
			// $display ("                            Your distance out of range!       				        ");
            // $display ("                              Wrong answer at : %h       	                   ",addr);
			// $display ("                              Your Answer is : %d       	   ",u_DRAM.DRAM_r[addr][7:0]);
			// $display ("                           Correct Answer is : %d           ", distance[framecount][i]);
            // addr =  { 12'h000, framecount[7:0]+8'h10, i[3:0], u_DRAM.DRAM_r[addr][7:0] - 8'd1 };
            // $display ("                           Value of wrong distance : %d    ", u_DRAM.DRAM_r[addr][7:0]);
            // addr =  { 12'h000, framecount[7:0]+8'h10, i[3:0], distance[framecount][i] - 8'd1};
            // $display ("                           Value of correct distance : %d  ", u_DRAM.DRAM_r[addr][7:0]);
			// $display ("=====================================================================================");
        end
        if(u_DRAM.DRAM_r[addr][7:0] <= distance[framecount][i]) begin
            if(type_reg == 2'b00)      total_error_0 = total_error_0 + distance[framecount][i] - u_DRAM.DRAM_r[addr][7:0];
            else if(type_reg == 2'b01) total_error_1 = total_error_1 + distance[framecount][i] - u_DRAM.DRAM_r[addr][7:0];
            else if(type_reg == 2'b10) total_error_2 = total_error_2 + distance[framecount][i] - u_DRAM.DRAM_r[addr][7:0];
            else if(type_reg == 2'b11) total_error_3 = total_error_3 + distance[framecount][i] - u_DRAM.DRAM_r[addr][7:0];
        end
        else begin
            if(type_reg == 2'b00)      total_error_0 = total_error_0 + u_DRAM.DRAM_r[addr][7:0] - distance[framecount][i];
            else if(type_reg == 2'b01) total_error_1 = total_error_1 + u_DRAM.DRAM_r[addr][7:0] - distance[framecount][i];
            else if(type_reg == 2'b10) total_error_2 = total_error_2 + u_DRAM.DRAM_r[addr][7:0] - distance[framecount][i];
            else if(type_reg == 2'b11) total_error_3 = total_error_3 + u_DRAM.DRAM_r[addr][7:0] - distance[framecount][i];
        end
        
    end 
    if(correct_pixel > 8)
        $display("  \033[1;35mAccuracy : (%1d/%02d) \033[1;32mPASS! \033[1;0m", correct_pixel, TOTAL_PIXEL);
    else begin
        $display("  \033[1;35mAccuracy : (%1d/%02d) \033[1;31mFAIL! \033[1;0m", correct_pixel, TOTAL_PIXEL);
        fail_count = fail_count + 1;
    end
        
end endtask

task wait_busy_task ; begin
	cycles = 0 ;
    while( busy === 0 )begin
        cycles = cycles + 1 ;
        if (cycles == MAX_CYCLE) begin
            $display ("=====================================================================================");
            $display ("                             Exceed maximun cycle!!!                                 ");
            $display ("=====================================================================================");
            $finish;
		end
        @(negedge clk);
    end
	while( busy === 1 ) begin
		cycles = cycles + 1 ;
		if (cycles == MAX_CYCLE) begin
            $display ("=====================================================================================");
            $display ("                             Exceed maximun cycle!!!                                 ");
            $display ("=====================================================================================");
            $finish;
		end
		@(negedge clk);
	end
	total_cycles = total_cycles + cycles ;
end endtask

task reset_task ;  begin
	#(20); rst_n = 0;
    in_valid = 0;
	#(20);
	if(busy!==0)begin
		reset_fail;
	end
	#(20);rst_n = 1;
	#(6); release clk;
end endtask

task reset_fail ; begin         
    $display ("=====================================================================================");
	$display ("                              Oops! Reset is Wrong                	    		    ");
    $display ("=====================================================================================");
	$finish;
end endtask

task error_task ; begin         
    $display ("=====================================================================================");
    $display ("                                     Distance ERROR!!!!!!                            ");
    $display ("=====================================================================================");
	$finish;
end endtask

task YOU_PASS_task; begin                                                                                                                                                                                            
    $display ("\033[1;32m                                          .:---:.                                                                                         ");                                  
    $display ("\033[1;32m                                       .*aa&&&&&aa#=                                                                                      ");                                  
    $display ("\033[1;32m                                    .#a#*+***###&aaaa&&&&&##**+=-::.                                                                      ");                                  
    $display ("\033[1;32m                                 .=*&aa&####***++++++++++++++****##&&&&##+=-:                                                             ");                                  
    $display ("\033[1;32m                              :*&aa&#*+++++++++++++++++++++++++++++++++++*##&&&#+=:.                                                      ");                                  
    $display ("\033[1;32m                           :+aa&*+=====================+++++++++++++++++++++++++*##&&#+-.                                                 ");                                  
    $display ("\033[1;32m                         =&a#*================================+++++++++++++++++++++++*#&a&*=.                                             ");                                  
    $display ("\033[1;32m                       +aa*===============+&&+==================++==+++++++++++++++++++++*#&aa*-     .----.                               ");                                  
    $display ("\033[1;32m                     =a&*==================**==================+aa+=====+++++++++++++++++++++#&aa#=+aa####&&&*-                           ");                                  
    $display ("\033[1;32m                   .&a*======================================================+++++++++++++++++++*&aa*++++++++*&a*.                        ");                                  
    $display ("\033[1;32m                  :a&+===========================================================++++++++++++++++++*++++*###**++#a*                       ");                                  
    $display ("\033[1;32m                 :a&==============++**#######*#aa*****#####**++=====================+++++++++++++++++++&a&&&&a&#++&&.                     ");                                  
    $display ("\033[1;32m                 &a=========+*#&#*+-:.       \033[1;37m=*::#:        .:-=#a&##*+\033[1;32m=================+++++++++++++++*a&&&&&&&a&++&& ");                                  
    $display ("\033[1;32m                =a+=====+*#*=:\033[1;37m***=         -*-   \033[1;37m.*+         =*=.:#:.\033[1;32m-=+*#*+==============+++++++++++++&&&&&&&&&&+++a*                                                      ");                                  
    $display ("\033[1;32m                #a===*##=.   \033[1;37m-##  #+     :*= \033[1;32m::    \033[1;37m=#.    .+*:    \033[1;32m.\033[1;37m#:     \033[1;32m.-+*#*+============+++++++++++#&a&&&a&*+++&a                        ");                                  
    $display ("\033[1;32m                #a*&*+#*\033[1;37m=   .&. \033[1;32m#+:\033[1;37m:*+.-*=  \033[1;32m*&*    \033[1;37m :*= -*+.     \033[1;32m.:.\033[1;37m#-         \033[1;32m.=+#*+===========+++++++++++*#**+++++&&    ");                                  
    $display ("\033[1;32m                =a&. #- \033[1;37m-*-:#.\033[1;32m.#+-*  \033[1;37m.=: \033[1;32m .#-+*      \033[1;37m -+-        \033[1;32m-a. \033[1;37m*+        \033[1;32m:++=:a*#*+=========+++++++++++++++++#a-    ");                                  
    $display ("\033[1;32m                 &a::#   \033[1;37m -=. \033[1;32m*+*&+      .#: =*..               :+a=  \033[1;37m=*    -++-.-  -* \033[1;32m:=*#+========+++++++++++++#a#.                                             ");                                  
    $display ("\033[1;32m                 :aa#:       *&#:&:      *=  :&&#...           ::##+   \033[1;37m:*+++:        *=   \033[1;32m:=*#+========+++++++++++&a:     ");                                  
    $display ("\033[1;32m                .#&:.       =a- .a-+*##**#*-  #*=#+++==--:::::::-a-*     .-=---+*=*  \033[1;37m#&:     \033[1;32m.=#*========++++++++++&&     ");                                  
    $display ("\033[1;32m               =a#.        :&. :*a*-. .           ..::--=++++++*#+-*     .--=+&&#&&:++\033[1;37m.&.      \033[1;32m.*a*========++++++++*a+    ");                                  
    $display ("\033[1;32m             -&&- :*      .&:.##-:=*******=.                      .=+++++++++*+  .-*a+.\033[1;37m:#:-=*++-:+*\033[1;32m#*=======++++++++&a    ");                                  
    $display ("\033[1;32m            #a&===&:      ++ &-.*#-:.....:+&-                            .-*##**+=:  =&+.-:.&    \033[1;37m:& \033[1;32m-#+=======++++++*a-   ");                                  
    $display ("\033[1;32m             .:-#a+      .&.   &+..........:&-                         :*#+-:...:-+&-  +*   a.    \033[1;37m#- \033[1;32m &+=======++++++a+   ");                                  
    $display ("\033[1;32m                a&.      ++   -&          ..&=                        :a+..........:a:      a.    \033[1;37m:#  \033[1;32m:&========+++++a*   ");                                  
    $display ("\033[1;32m               =a-      .&.   -&           +#.              .         =&         ...*+      a:     \033[1;37m#: \033[1;32m.&*========++++a*   ");                                  
    $display ("\033[1;32m               &&       =#     +#:      :+&=       +:==.  -##*        :a.           &-      a:     \033[1;37m:+=-\033[1;32m+#=========+++a*   ");                                  
    $display ("\033[1;32m              .a+      .#-   \033[1;31m...-+#****#*=.        \033[1;32m.+#=#+**--&         -&+:       -#+      :&:.        :a=========++*a=   ");                                  
    $display ("\033[1;32m              =a:     .:a. \033[1;31m......:..........        \033[1;32m-*:------&       \033[1;31m....-*#******+:     \033[1;32m##+*:.  .=:   .a==========+#a: ");                                  
    $display ("\033[1;32m              *a.     :-&  \033[1;31m....:=:...:-:.....       \033[1;32m=*-------&      \033[1;31m......::.....:...   \033[1;32m-#:#*-:=*+*+    a==========+&&  ");                                  
    $display ("\033[1;32m           --:*&     .:+*  \033[1;31m...:=:...:=:......       \033[1;32m=*------+*      \033[1;31m.....--:...:-:.... \033[1;32m.#&#####&*=+=   .a==========+a=  ");                                  
    $display ("\033[1;32m          .a&aa&     ::*=   \033[1;31m...:....::......        \033[1;32m-*------#=      \033[1;31m....::....--......\033[1;32m+&*+++++==+#a:   :&==========&&   ");                                  
    $display ("\033[1;32m           a*=&a+-.  ::*=..   \033[1;31m....:........         \033[1;32m:#:-----a.       \033[1;31m................\033[1;32m##++++=======&-   =#=========+a-   ");                                  
    $display ("\033[1;32m           aa*+++*##-::*&*::    \033[1;37m.:++:.           .   \033[1;32m&-----+*           \033[1;31m.:-=::....  \033[1;32m+#+++=========**   **=========a*    ");                                  
    $display ("\033[1;32m       .=*aa+====+++##\033[1;37m+#:-#:: .:=#.:#+:.      .:+*-..\033[1;32m=*----&- \033[1;37m+++-:.     :+*-+*=..  \033[1;32m.a+++==========**   &+========#a.   ");                                  
    $display ("\033[1;32m      .aa--a=======++\033[1;37m*&.  *+:::#=    =#-:.   .-#- =*=.\033[1;32m+*=+#+\033[1;37m-# .=*+-:. :=#    -**:\033[1;32m.#*++===========**  :&========#a:     ");                                  
    $display ("\033[1;32m       .#a+a========*\033[1;37m&.    &-=#:      .*+:..:=#.    -#=:\033[1;32m---\033[1;37m&:     .+*=:-&       .+\033[1;32m#&++============#-  **=======#a-      ");                                  
    $display ("\033[1;32m         :#a*======+a#*+=-:\033[1;37m=&*          -#-:*+        -#=:&:         -*&-..:-\033[1;32m=++*#a*++===========+&--.a=======#a:                           ");                                  
    $display ("\033[1;32m           +a+======#&*==++*#***++==-::..\033[1;37m:##=           +&=..\033[1;32m::--=+++**##**++====+&++============&+&.+#=====+&&.                            ");                                  
    $display ("\033[1;32m            =a*=======#&*===========+++****#***********#*****++++================&*+============#*#+:&=====#a=                                                  ");                                  
    $display ("\033[1;32m             :&&+=======#&#+====================================================+&++===========*&&###+===*a*.                                                   ");                                  
    $display ("\033[1;32m              .aa#========*#&#+=================================================&*+===========+a&**a*==#a*.                                                     ");                                  
    $display ("\033[1;32m               &&*a#+=======+*#&#*+============================================*&+===========+a#+++\033[1;31m&#&aa-                                             ");                                  
    $display ("\033[1;32m               -aa&*a&+=========+*#&##*+=======================================a+===========+&*+=\033[1;31m+a&&&&aa+                                            ");                                  
    $display ("\033[1;32m                =+. +a*##+===========+***=====================================*#============&*+===\033[1;31ma&&&&&a-                                            ");                                  
    $display ("\033[1;32m                     *a-#aa#*=+*=================---\033[1;33m:::::::::::::\033[1;32m---=======================*&+====\033[1;31m#a&&&aa#&&.                     ");                                  
    $display ("\033[1;32m                      *aa#.=#aa*============--\033[1;33m::::::::::::::::::::::::::\033[1;32m-==================++======\033[1;31m&&&aaa&&a*                     ");                                  
    $display ("\033[1;32m                       -*.   =a*=========-\033[1;33m::::::::::::::::::::::::::::::::::\033[1;32m-======================\033[1;31m+a&&&&&&a& .-+:                ");                                  
    $display ("\033[1;32m                             -a+=======-\033[1;33m::::::::::::::::::::::::::::::::::::::\033[1;32m-=====================\033[1;31m+&&&&&&aa&aaaa:  :.           ");                                  
    $display ("\033[1;32m                             .a#=====-\033[1;33m:::::::::::::::::::::::::::::::::::::::::::\033[1;32m=====================\033[1;31m#a&&&aa&&&&a&+&aa=          ");                                  
    $display ("\033[1;32m                              #&====\033[1;33m:::::::::::::::::::::::::::::::::::::::::::::::\033[1;32m-===================\033[1;31m+&&&&&&&&&aa&&&aa:         ");                                  
    $display ("\033[1;32m                              :a*==\033[1;33m::::::::::::::::::::::::::::::::::::::::::::::::::\033[1;32m====================\033[1;31m+##&&&&&&&&&&##=         ");   
    $display ("\033[1;35m           ==========================================================================================================");
	$display ("\033[1;35m                                                  Congratulations!                						             ");
	$display ("\033[1;35m                                           You have passed all patterns!          						             ");
	$display ("\033[1;35m                                           Your execution cycles = %5d cycles   					   ", total_cycles);
	$display ("\033[1;35m                                           Your clock period = %.1f ns        					        ", `CYCLE_TIME);
	$display ("\033[1;35m                                           Your total latency = %.1f ns         		   ", total_cycles*`CYCLE_TIME);
    $display ("\033[1;35m                                           Your total accuracy = %3d/%03d       		   ", PATTERN_NUM - fail_count, PATTERN_NUM);
    $display ("\033[1;35m                                           Your total error type 0 = %d           		                    ", total_error_0);
    $display ("\033[1;35m                                           Your total error type 1 = %d           		                    ", total_error_1);
    $display ("\033[1;35m                                           Your total error type 2 = %d           		                    ", total_error_2);
    $display ("\033[1;35m                                           Your total error type 3 = %d           		                    ", total_error_3);
    $display("\033[1;35m           ==========================================================================================================");  
    $display("\033[1;0m"); 
    repeat(5) @(negedge clk);
    $finish;
end endtask

endmodule
