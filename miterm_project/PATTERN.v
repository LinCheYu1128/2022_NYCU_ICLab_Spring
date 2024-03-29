`ifdef RTL
    `define CYCLE_TIME 20
`endif
`ifdef GATE
    `define CYCLE_TIME 3.8
`endif

`include "../00_TESTBED/pseudo_DRAM.v"


module PATTERN #(parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32)(
    // CHIP IO 
    clk,    
    rst_n,    
    in_valid,    
    start,
    stop,
    window,
    mode,
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
output reg [1:0]        window; 
output reg              mode;
output reg [4:0]        frame_id;
input                   busy;       

// << AXI Interface wire connecttion for pseudo DRAM read/write >>
// (1)     axi write address channel 
//         src master
input wire [ID_WIDTH-1:0]      awid_s_inf; //[3:0]
input wire [ADDR_WIDTH-1:0]  awaddr_s_inf; //[31:0]
input wire [2:0]             awsize_s_inf;
input wire [1:0]            awburst_s_inf;
input wire [7:0]              awlen_s_inf;
input wire                  awvalid_s_inf;
//         src slave
output wire                 awready_s_inf;
// -----------------------------

// (2)    axi write data channel 
//         src master
input wire [DATA_WIDTH-1:0]   wdata_s_inf; //[127:0]
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
    // axi write address channel
    .   awid_s_inf(   awid_s_inf),
    . awaddr_s_inf( awaddr_s_inf),
    . awsize_s_inf( awsize_s_inf),
    .awburst_s_inf(awburst_s_inf),
    .  awlen_s_inf(  awlen_s_inf),
    .awvalid_s_inf(awvalid_s_inf),
    .awready_s_inf(awready_s_inf),
    // axi write data channel
    .  wdata_s_inf(  wdata_s_inf),
    .  wlast_s_inf(  wlast_s_inf),
    . wvalid_s_inf( wvalid_s_inf),
    . wready_s_inf( wready_s_inf),
    // axi write response channel
    .    bid_s_inf(    bid_s_inf),
    .  bresp_s_inf(  bresp_s_inf),
    . bvalid_s_inf( bvalid_s_inf),
    . bready_s_inf( bready_s_inf),
    // axi read address channel
    .   arid_s_inf(   arid_s_inf),
    . araddr_s_inf( araddr_s_inf),
    .  arlen_s_inf(  arlen_s_inf),
    . arsize_s_inf( arsize_s_inf),
    .arburst_s_inf(arburst_s_inf),
    .arvalid_s_inf(arvalid_s_inf),
    .arready_s_inf(arready_s_inf), 
    // axi read data channel 
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
integer framecount;
integer in_read,out_read;
integer i,j,l,a,gap;
integer curr_cycle, cycles, total_cycles;
    // initialize DRAM: $readmemh("../00_TESTBED/dram.dat", u_DRAM.DRAM_r);
    // direct access DRAM: u_DRAM.DRAM_r[addr][7:0];
reg [7:0] temp [0:15][0:254];
reg [1:0] window_reg[0:31];
integer addr, count, max_stop, mode_reg;
reg stop_reg[0:15];
reg [7:0] distance [0:31][0:15];

initial begin
    $readmemh("../00_TESTBED/dram.dat", u_DRAM.DRAM_r);
    in_read  = $fopen("../00_TESTBED/input.txt", "r");
    out_read = $fopen("../00_TESTBED/output.txt", "r");
    rst_n    = 'b1;
    in_valid = 'bx;
    start    = 'bx;
    stop     = 'bx;     
    window   = 'bx; 
    mode     = 'bx;
    frame_id = 'bx;
    force clk = 0 ;
    reset_task;
    total_cycles = 0;
    load_output;

    for(i=0; i<32; i=i+1)begin
        a = $fscanf(in_read, "%d", window_reg[i]);
    end
    for(framecount = 0;framecount < FRAME; framecount = framecount+1)begin
        // framecount = 6;
        mode_reg = $random % 2;
        if(mode_reg==0)begin
            // load dram to temp and clean dram
            // input stop to design
            // check hist(compare with temp) and dist(compare with output.txt) in dram
            load_data;
            input_task_0;
            wait_busy_task;
            check_answer_0;
        end
        else begin
            // no need to load
            // input mode to design
            // check dist in dram
            input_task_1;
            // repeat(500) @(negedge clk);
            // addr = {12'h000,framecount[7:0]+8'h10,4'h0,8'h16};
            // $display("%h", u_DRAM.DRAM_r[addr][7:0]);
            // for(j=0; j<255; j=j+1)begin
            //     addr = {12'h000,framecount[7:0]+8'h10,4'h0,j[7:0]};
            //     $display("%h", u_DRAM.DRAM_r[addr][7:0]);
            // end
            // $finish;
            wait_busy_task;
            check_answer_1;
        end   
        // @(negedge clk);
    end
    repeat(10) @(negedge clk);
    YOU_PASS_task;
    
end

task check_answer_0; begin
    for(i=0; i<16; i=i+1)begin
        for(j=0; j<255; j=j+1)begin
            addr = {12'h000,framecount[7:0]+8'h10,i[3:0],j[7:0]};
            if(temp[i][j] != u_DRAM.DRAM_r[addr][7:0])begin
                $display ("----------------------------------------------------------------------------------------------------------------------");
                $display ("                                                Your histogram is Wrong!             						             ");
                $display ("                                                  Wrong answer at : %h       	                                     ",addr);
                $display ("                                                  Your Answer is : %h       	                                     ",u_DRAM.DRAM_r[addr][7:0]);
                $display ("                                               Correct Answer is : %h           			              ", temp[i][j]);
                $display ("----------------------------------------------------------------------------------------------------------------------");
                repeat(1)  @(negedge clk);
                $finish;
            end 
        end
        addr = {12'h000,framecount[7:0]+8'h10,i[3:0],8'hFF};
        if(u_DRAM.DRAM_r[addr][7:0]!=distance[framecount][i] + 1)begin
            $display ("----------------------------------------------------------------------------------------------------------------------");
			$display ("                                                Your distance is Wrong!             						             ");
            $display ("                                                  Wrong answer at : %h       	                                     ",addr);
			$display ("                                                  Your Answer is : %d       	                                     ",u_DRAM.DRAM_r[addr][7:0]);
			$display ("                                               Correct Answer is : %03d           			              ", distance[framecount][i]+1);
			$display ("----------------------------------------------------------------------------------------------------------------------");
			repeat(1)  @(negedge clk);
			$finish;
        end 
    end 
end endtask

task check_answer_1; begin
    for(i=0; i<16; i=i+1)begin
        addr = {12'h000,framecount[7:0]+8'h10,i[3:0],8'hFF};
        if(u_DRAM.DRAM_r[addr][7:0]!=distance[framecount][i]+1)begin
            $display ("----------------------------------------------------------------------------------------------------------------------");
			$display ("                                                Your distance is Wrong!             						             ");
            $display ("                                                  Wrong answer at : %h       	                                     ",addr);
			$display ("                                                  Your Answer is : %d       	                                     ",u_DRAM.DRAM_r[addr][7:0]);
			$display ("                                               Correct Answer is : %03d           			              ", distance[framecount][i]+1);
			$display ("----------------------------------------------------------------------------------------------------------------------");
			repeat(1)  @(negedge clk);
			$finish;
        end 
    end 
end endtask

task load_output; begin
    max_stop = 0;
    for(i=0; i<32; i=i+1)begin
        for(j=0; j<16; j=j+1)begin
            a = $fscanf(out_read, "%d", distance[i][j]);
        end
    end
end endtask

task load_data; begin
    max_stop = 0;
    for(i=0; i<16; i=i+1)begin
        for(j=0; j<255; j=j+1)begin
            addr = {12'h000,framecount[7:0]+8'h10,i[3:0],j[7:0]};
            temp[i][j] = u_DRAM.DRAM_r[addr][7:0];
            u_DRAM.DRAM_r[addr][7:0] = 8'h00;
            if(temp[i][j] > max_stop) max_stop = temp[i][j];
        end
    end
end endtask

task input_task_0; begin
	$display ("start Frame No.%1d",framecount);
	gap = $urandom_range(3,10);
	repeat(gap) @(negedge clk);
	count = 0;
	in_valid = 1'b1;
	window = window_reg[framecount];
    mode = mode_reg;
    frame_id = framecount;
    stop = 'b0;
    start = 0;
    @(negedge clk);
    window = 'bx;
    mode = 'bx;
    frame_id = 'bx;
	
	for(i = 0; i < max_stop; i=i+1)begin
        start = 0;
        stop = 0;
        repeat(gap-1) @(negedge clk);
        start = 1;
        for (j = 0; j<255; j=j+1) begin
            for(l = 0; l<16; l=l+1)begin
                // stop_reg[l] = (temp[l][j] > count)?1:0;
                if(temp[l][j] > count)begin
                    stop[l] = 1'b1;
                end
                else stop[l] = 1'b0;
            end
            // stop = {stop_reg[15], stop_reg[14], stop_reg[13], stop_reg[12], stop_reg[11], stop_reg[10], 10'b0000000000};
            @(negedge clk);
        end
        count = count + 1;
    end
    start = 'bx;
    stop = 'bx;
    in_valid = 1'b0;
end endtask

task input_task_1; begin
	$display ("start Frame No.%1d",framecount);
	gap = $urandom_range(3,10);
	repeat(gap) @(negedge clk);
	in_valid = 1'b1;
	window = window_reg[framecount];
    mode = mode_reg;
    frame_id = framecount;
    stop = 'b0;
    start = 0;
    @(negedge clk);
    window = 'bx;
    mode = 'bx;
    frame_id = 'bx;
    start = 'bx;
    stop = 'bx;
    in_valid = 1'b0;
end endtask

task wait_busy_task ; begin
	cycles = 0 ;
    while( busy==0 )begin
        cycles = cycles + 1 ;
        if (cycles==10000) begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                            Exceed maximun cycle!!!                                                         ");
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(5)  @(negedge clk);
            $finish;
		end
        @(negedge clk);
    end
	while( busy!=0 ) begin
		cycles = cycles + 1 ;
		if (cycles==10000) begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                            Exceed maximun cycle!!!                                                         ");
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(5)  @(negedge clk);
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
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Oops! Reset is Wrong                						             ");
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask

task YOU_PASS_task; begin                                                                                                                                                                                            
    $display("\033[1;32m                                          .:---:.                                                                         ");                                  
    $display("\033[1;32m                                       .*aa&&&&&aa#=                                                                      ");                                  
    $display("\033[1;32m                                    .#a#*+***###&aaaa&&&&&##**+=-::.                                                     ");                                  
    $display("\033[1;32m                                 .=*&aa&####***++++++++++++++****##&&&&##+=-:                                             ");                                  
    $display("\033[1;32m                              :*&aa&#*+++++++++++++++++++++++++++++++++++*##&&&#+=:.                                      ");                                  
    $display("\033[1;32m                           :+aa&*+=====================+++++++++++++++++++++++++*##&&#+-.                                 ");                                  
    $display("\033[1;32m                         =&a#*================================+++++++++++++++++++++++*#&a&*=.                             ");                                  
    $display("\033[1;32m                       +aa*===============+&&+==================++==+++++++++++++++++++++*#&aa*-     .----.               ");                                  
    $display("\033[1;32m                     =a&*==================**==================+aa+=====+++++++++++++++++++++#&aa#=+aa####&&&*-           ");                                  
    $display("\033[1;32m                   .&a*======================================================+++++++++++++++++++*&aa*++++++++*&a*.        ");                                  
    $display("\033[1;32m                  :a&+===========================================================++++++++++++++++++*++++*###**++#a*       ");                                  
    $display("\033[1;32m                 :a&==============++**#######*#aa*****#####**++=====================+++++++++++++++++++&a&&&&a&#++&&.     ");                                  
    $display("\033[1;32m                 &a=========+*#&#*+-:.       \033[1;37m=*::#:        .:-=#a&##*+\033[1;32m=================+++++++++++++++*a&&&&&&&a&++&&     ");                                  
    $display("\033[1;32m                =a+=====+*#*=:\033[1;37m***=         -*-   \033[1;37m.*+         =*=.:#:.\033[1;32m-=+*#*+==============+++++++++++++&&&&&&&&&&+++a*    ");                                  
    $display("\033[1;32m                #a===*##=.   \033[1;37m-##  #+     :*= \033[1;32m::    \033[1;37m=#.    .+*:    \033[1;32m.\033[1;37m#:     \033[1;32m.-+*#*+============+++++++++++#&a&&&a&*+++&a    ");                                  
    $display("\033[1;32m                #a*&*+#*\033[1;37m=   .&. \033[1;32m#+:\033[1;37m:*+.-*=  \033[1;32m*&*    \033[1;37m :*= -*+.     \033[1;32m.:.\033[1;37m#-         \033[1;32m.=+#*+===========+++++++++++*#**+++++&&    ");                                  
    $display("\033[1;32m                =a&. #- \033[1;37m-*-:#.\033[1;32m.#+-*  \033[1;37m.=: \033[1;32m .#-+*      \033[1;37m -+-        \033[1;32m-a. \033[1;37m*+        \033[1;32m:++=:a*#*+=========+++++++++++++++++#a-    ");                                  
    $display("\033[1;32m                 &a::#   \033[1;37m -=. \033[1;32m*+*&+      .#: =*..               :+a=  \033[1;37m=*    -++-.-  -* \033[1;32m:=*#+========+++++++++++++#a#.     ");                                  
    $display("\033[1;32m                 :aa#:       *&#:&:      *=  :&&#...           ::##+   \033[1;37m:*+++:        *=   \033[1;32m:=*#+========+++++++++++&a:     ");                                  
    $display("\033[1;32m                .#&:.       =a- .a-+*##**#*-  #*=#+++==--:::::::-a-*     .-=---+*=*  \033[1;37m#&:     \033[1;32m.=#*========++++++++++&&     ");                                  
    $display("\033[1;32m               =a#.        :&. :*a*-. .           ..::--=++++++*#+-*     .--=+&&#&&:++\033[1;37m.&.      \033[1;32m.*a*========++++++++*a+    ");                                  
    $display("\033[1;32m             -&&- :*      .&:.##-:=*******=.                      .=+++++++++*+  .-*a+.\033[1;37m:#:-=*++-:+*\033[1;32m#*=======++++++++&a    ");                                  
    $display("\033[1;32m            #a&===&:      ++ &-.*#-:.....:+&-                            .-*##**+=:  =&+.-:.&    \033[1;37m:& \033[1;32m-#+=======++++++*a-   ");                                  
    $display("\033[1;32m             .:-#a+      .&.   &+..........:&-                         :*#+-:...:-+&-  +*   a.    \033[1;37m#- \033[1;32m &+=======++++++a+   ");                                  
    $display("\033[1;32m                a&.      ++   -&          ..&=                        :a+..........:a:      a.    \033[1;37m:#  \033[1;32m:&========+++++a*   ");                                  
    $display("\033[1;32m               =a-      .&.   -&           +#.              .         =&         ...*+      a:     \033[1;37m#: \033[1;32m.&*========++++a*   ");                                  
    $display("\033[1;32m               &&       =#     +#:      :+&=       +:==.  -##*        :a.           &-      a:     \033[1;37m:+=-\033[1;32m+#=========+++a*   ");                                  
    $display("\033[1;32m              .a+      .#-   \033[1;31m...-+#****#*=.        \033[1;32m.+#=#+**--&         -&+:       -#+      :&:.        :a=========++*a=   ");                                  
    $display("\033[1;32m              =a:     .:a. \033[1;31m......:..........        \033[1;32m-*:------&       \033[1;31m....-*#******+:     \033[1;32m##+*:.  .=:   .a==========+#a:   ");                                  
    $display("\033[1;32m              *a.     :-&  \033[1;31m....:=:...:-:.....       \033[1;32m=*-------&      \033[1;31m......::.....:...   \033[1;32m-#:#*-:=*+*+    a==========+&&    ");                                  
    $display("\033[1;32m           --:*&     .:+*  \033[1;31m...:=:...:=:......       \033[1;32m=*------+*      \033[1;31m.....--:...:-:.... \033[1;32m.#&#####&*=+=   .a==========+a=    ");                                  
    $display("\033[1;32m          .a&aa&     ::*=   \033[1;31m...:....::......        \033[1;32m-*------#=      \033[1;31m....::....--......\033[1;32m+&*+++++==+#a:   :&==========&&     ");                                  
    $display("\033[1;32m           a*=&a+-.  ::*=..   \033[1;31m....:........         \033[1;32m:#:-----a.       \033[1;31m................\033[1;32m##++++=======&-   =#=========+a-     ");                                  
    $display("\033[1;32m           aa*+++*##-::*&*::    \033[1;37m.:++:.           .   \033[1;32m&-----+*           \033[1;31m.:-=::....  \033[1;32m+#+++=========**   **=========a*      ");                                  
    $display("\033[1;32m       .=*aa+====+++##\033[1;37m+#:-#:: .:=#.:#+:.      .:+*-..\033[1;32m=*----&- \033[1;37m+++-:.     :+*-+*=..  \033[1;32m.a+++==========**   &+========#a.      ");                                  
    $display("\033[1;32m      .aa--a=======++\033[1;37m*&.  *+:::#=    =#-:.   .-#- =*=.\033[1;32m+*=+#+\033[1;37m-# .=*+-:. :=#    -**:\033[1;32m.#*++===========**  :&========#a:       ");                                  
    $display("\033[1;32m       .#a+a========*\033[1;37m&.    &-=#:      .*+:..:=#.    -#=:\033[1;32m---\033[1;37m&:     .+*=:-&       .+\033[1;32m#&++============#-  **=======#a-        ");                                  
    $display("\033[1;32m         :#a*======+a#*+=-:\033[1;37m=&*          -#-:*+        -#=:&:         -*&-..:-\033[1;32m=++*#a*++===========+&--.a=======#a:         ");                                  
    $display("\033[1;32m           +a+======#&*==++*#***++==-::..\033[1;37m:##=           +&=..\033[1;32m::--=+++**##**++====+&++============&+&.+#=====+&&.          ");                                  
    $display("\033[1;32m            =a*=======#&*===========+++****#***********#*****++++================&*+============#*#+:&=====#a=            ");                                  
    $display("\033[1;32m             :&&+=======#&#+====================================================+&++===========*&&###+===*a*.             ");                                  
    $display("\033[1;32m              .aa#========*#&#+=================================================&*+===========+a&**a*==#a*.               ");                                  
    $display("\033[1;32m               &&*a#+=======+*#&#*+============================================*&+===========+a#+++\033[1;31m&#&aa-                 ");                                  
    $display("\033[1;32m               -aa&*a&+=========+*#&##*+=======================================a+===========+&*+=\033[1;31m+a&&&&aa+                ");                                  
    $display("\033[1;32m                =+. +a*##+===========+***=====================================*#============&*+===\033[1;31ma&&&&&a-                ");                                  
    $display("\033[1;32m                     *a-#aa#*=+*=================---\033[1;33m:::::::::::::\033[1;32m---=======================*&+====\033[1;31m#a&&&aa#&&.             ");                                  
    $display("\033[1;32m                      *aa#.=#aa*============--\033[1;33m::::::::::::::::::::::::::\033[1;32m-==================++======\033[1;31m&&&aaa&&a*             ");                                  
    $display("\033[1;32m                       -*.   =a*=========-\033[1;33m::::::::::::::::::::::::::::::::::\033[1;32m-======================\033[1;31m+a&&&&&&a& .-+:        ");                                  
    $display("\033[1;32m                             -a+=======-\033[1;33m::::::::::::::::::::::::::::::::::::::\033[1;32m-=====================\033[1;31m+&&&&&&aa&aaaa:  :.   ");                                  
    $display("\033[1;32m                             .a#=====-\033[1;33m:::::::::::::::::::::::::::::::::::::::::::\033[1;32m=====================\033[1;31m#a&&&aa&&&&a&+&aa=  ");                                  
    $display("\033[1;32m                              #&====\033[1;33m:::::::::::::::::::::::::::::::::::::::::::::::\033[1;32m-===================\033[1;31m+&&&&&&&&&aa&&&aa: ");                                  
    $display("\033[1;32m                              :a*==\033[1;33m::::::::::::::::::::::::::::::::::::::::::::::::::\033[1;32m====================\033[1;31m+##&&&&&&&&&&##= ");                                  
    $display("\033[1;35m           ==========================================================================================================");
	$display ("\033[1;35m                                                  Congratulations!                						             ");
	$display ("\033[1;35m                                           You have passed all patterns!          						             ");
	$display ("\033[1;35m                                           Your execution cycles = %5d cycles   						                 ", total_cycles);
	$display ("\033[1;35m                                           Your clock period = %.1f ns        					                     ", `CYCLE_TIME);
	$display ("\033[1;35m                                           Your total latency = %.1f ns         						                 ", total_cycles*`CYCLE_TIME);
    $display("\033[1;35m           ==========================================================================================================");  
    $display("\033[1;0m"); 
    repeat(5) @(negedge clk);
    $finish;
end endtask

endmodule
