
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
// Wire & Reg Declaration
// ===============================================================
reg [1:0] mazemap [0:16][0:16];
reg [4:0] position [0:1];
reg stall;
reg signed [8:0] password [0:3];
reg signed [8:0] temp,temp1;
reg [3:0] zero_3,four_7;
reg signed [8:0]  golden_data [0:3];

wire [4:0]check_maze;
assign check_maze = mazemap[position[0]][position[1]];
// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
integer input_file;
integer total_cycles, cycles;
integer hostage_n,in_valid2_count,hostage_code,saved_hostage;
integer patcount;
integer gap;
integer a,b;
integer i,j;
integer golden_step;
integer seed = 123456789;
integer p,half_range;

parameter  PATNUM = 500;
// ===============================================================
// Clock
// ===============================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;


initial begin
    rst_n    = 1'b1;
    in_valid1 = 1'b0;
    in_valid2 = 1'b0;
    in = 'bx;
    in_data = 'bx;
    total_cycles = 0;
    input_file  = $fopen("../00_TESTBED/input.txt","r");

    force clk = 0;
	reset_task;

    
    @(posedge clk);
    

    for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		
        input_data;
        generate_password;
        for ( in_valid2_count = 0 ; in_valid2_count< hostage_n; in_valid2_count=in_valid2_count+1) begin
            if(out_valid1===1)SPEC_9_FAIL;
            check_out;
            give_code;
            if(out_valid1===1 && position[0]!=16 && position[1]!=16 )SPEC_10_FAIL;
        end
        @(negedge clk);
        check_out;
        calculate_golden_data;
        check_out_data;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end

    #(1000);
	YOU_PASS_task;
    $finish;


end

task generate_password;begin

      
    for (i = 0;i<4;i=i+1 ) begin
        password[i] = 0;
    end

    if(hostage_n%2==0 && hostage_n!=0)begin
        for (i = 0; i< hostage_n ; i=i+1) begin
            zero_3 = $urandom_range(3,12);
            four_7 = $urandom_range(3,12);
            password[i] = {$urandom_range(0,1),four_7,zero_3};
            //$display("password :%d",password[i]);  
        end
        //password[0] = -205;
        //password[1] = -204;
        //password[2] = -52;
        //password[3] = 52;//TO DO: NUMBER MAY BE (-)
    end
    else begin
        for (i = 0; i< hostage_n ; i=i+1) begin
            password[i] = $random(seed);
            //$display("password :%d",password[i]);  
        end 
    end
    
end endtask

task calculate_golden_data;begin
    //$display(password[0],password[1],password[2],password[3]);
    //$display("%b ",password[0]," %b ",password[1]," %b ",password[2]," %b ",password[3]);
    case (hostage_n)
        0:begin
            golden_data[0] = 9'd0;
        end
        1:begin
            golden_data[0] = password[0];
            //$display("golden answer:",golden_data[0]);
        end
        2:begin
            //sort 
            if(password[0]<password[1])begin
                temp = password[0];
                password[0] = password[1];
                password[1] = temp;
            end
            //xs-3
            for (i = 0; i<2; i=i+1) begin
                p = (password[i][7:4]-4'b0011)*10+(password[i][3:0]-4'b0011);
                p = password[i][8]? -p : p;
                //$display("%d ",p);
                password[i] = p;
            end
            //subtract half of range
            half_range = (password[0]+password[1])/2;
            golden_data[0] = password[0] - half_range;
            golden_data[1] = password[1] - half_range;
            //$display("golden answer:",golden_data[0],golden_data[1]);
        end
        3:begin
            //sort
            if(password[0]<password[1])begin
                temp = password[0];
                password[0] = password[1];
                password[1] = temp;
            end
            if(password[1]<password[2])begin
                temp = password[1];
                password[1] = password[2];
                password[2] = temp;
            end
            if(password[0]<password[1])begin
                temp = password[0];
                password[0] = password[1];
                password[1] = temp;
            end
            //$display("after sorting:",password[0],password[1],password[2]);
            //subtract half of range 
            half_range = (password[0]+password[2])/2;
            //$display("half_range",half_range);
            password[0] = password[0] - half_range;
            password[1] = password[1] - half_range;
            password[2] = password[2] - half_range;
            //$display("after shr:",password[0],password[1],password[2]);
            //cumulation 
            golden_data[0] = password[0];
            golden_data[1] = (password[0]+password[0]+password[1])/3;
            golden_data[2] = (golden_data[1]+golden_data[1]+password[2])/3;
            //$display("golden answer:",golden_data[0],golden_data[1],golden_data[2]);      

        end
        4:begin
            //sort
            if(password[0]<password[1])begin
                temp = password[0];
                password[0] = password[1];
                password[1] = temp;
            end
            if(password[2]<password[3])begin
                temp = password[2];
                password[2] = password[3];
                password[3] = temp;
            end
            if(password[1]<password[2])begin
                temp = password[1];
                password[1] = password[2];
                password[2] = temp;
            end
            if(password[0]<password[1])begin
                temp = password[0];
                password[0] = password[1];
                password[1] = temp;
            end
            if(password[2]<password[3])begin
                temp = password[2];
                password[2] = password[3];
                password[3] = temp;
            end
            if(password[1]<password[2])begin
                temp = password[1];
                password[1] = password[2];
                password[2] = temp;
            end
            //$display("after sorting:",password[0],password[1],password[2],password[3]);
            //$display("%b ",password[0]," %b ",password[1]," %b ",password[2]," %b ",password[3]);
            //xs-3
            for (i = 0; i<4; i=i+1) begin
                p = (password[i][7:4]-4'b0011)*10+(password[i][3:0]-4'b0011);
                p = password[i][8]? -p : p;
                password[i] = p;
            end
            //$display("after xs-3:",password[0],password[1],password[2],password[3]);
            //$display("%b ",password[0]," %b ",password[1]," %b ",password[2]," %b ",password[3]);       
            //subtract half of range 
            if (password[0]<password[1]) begin
                temp = password[0];
                temp1 = password[1];
            end
            else begin
                temp1 = password[0];
                temp = password[1];
            end

            for (i = 2; i<4; i=i+1) begin
                if (password[i]<temp) temp = password[i];
                else if(password[i]>temp1) temp1 = password[i];
            end
            half_range = (temp1+temp)/2;
            //$display("temp:",temp," temp1:",temp1,"half_range",half_range);
            password[0] = password[0] - half_range;
            password[1] = password[1] - half_range;
            password[2] = password[2] - half_range;
            password[3] = password[3] - half_range;
            //$display("after shr:",password[0],password[1],password[2],password[3]);
            //cumulation 
            golden_data[0] = password[0];
            golden_data[1] = (password[0]+password[0]+password[1])/3;
            golden_data[2] = (golden_data[1]+golden_data[1]+password[2])/3;
            golden_data[3] = (golden_data[2]+golden_data[2]+password[3])/3;
            //$display("golden answer:",golden_data[0],golden_data[1],golden_data[2],golden_data[3]); 
        end 
        default:begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                          FAIL!                                                                             ");
            $display ("                                   The number of hostages should be 0~4, this maze has %d hostages                                          ",hostage_n);
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");      
            #(100);
            $finish ;
        end 
    endcase
end endtask

task input_data; begin
	
    hostage_n = 0;
    hostage_code =0;
    cycles =0;
    gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);

	in_valid1 = 1'b1;
    
    for (i = 0; i< 17; i=i+1) begin
        for (j=0; j<17; j=j+1)  b = $fscanf (input_file, "%d", mazemap[i][j]);
    end
	
    for (i = 0; i< 17; i=i+1) begin
        for (j=0; j<17; j=j+1)  begin
            in = mazemap[i][j];
            if(mazemap[i][j]==3) hostage_n = hostage_n + 1;
            if((out_valid1 === 1) || (out_valid2 === 1)||in_valid2===1 )SPEC_5_FAIL;
            if(out!=0)SPEC_4_FAIL;
            @(negedge clk); 
        end
        
    end
    
	in_valid1 = 1'b0;
	in = 'bx;

    position[0]=0;//x
    position[1]=0;//y
    
    
end endtask

task reset_task ; begin
	#(10); rst_n = 0;
	#(10);
	if((out_valid1 !== 0) || (out_valid2 !== 0) || (out !== 0) || (out_data !== 0)) SPEC_3_FAIL;
	#(10); rst_n = 1 ;
	#(3.0); release clk;
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

task check_out;begin
    stall = 1'b0;  
    while (out_valid2!==1) begin
        cycles = cycles + 1;
        @(negedge clk);
        if(cycles >3000)SPEC_6_FAIL;
    end
    while (out_valid2 === 1)begin
        //$display("now position x:",position[0]," y:",position[1]);
        //$display("NEXT STEP : OUT = ",out);
        if(out_valid1===1||in_valid1===1||in_valid2===1)SPEC_5_FAIL;
        
        if(out_data!==0)SPEC_7_FAIL;

        if(cycles >3000)SPEC_6_FAIL;

        else if (mazemap[position[0]][position[1]]==2 && stall==0) begin 
            
            if(out!==4)begin
                //$display ("YOU ARE TRAPPED! DON'T MOVE!");
                SPEC_7_FAIL;
            end
            else begin
                stall = 1;
            end
        end

        else begin

            if(out===0)begin//right
            stall = 0;
                if(mazemap[position[0]][position[1]+1]==0||position[1]+1==17)begin  
                    //$display ("Hit the wall at position %d ,%d",position[0],position[1]);
                    SPEC_7_FAIL;
                end
                else begin
                    position[1]=position[1]+1;
                end
            end
            else if(out ===1)begin//down
            stall = 0;
                if(mazemap[position[0]+1][position[1]]==0||position[0]+1==17)begin
                    //$display ("Hit the wall at position %d ,%d",position[0],position[1]);
                    SPEC_7_FAIL;
                end
                else begin
                    position[0]=position[0]+1;
                end
            end
            else if(out===2)begin//left
            stall = 0;
                if(mazemap[position[0]][position[1]-1]==0||position[1]-1==-1)begin
                    //$display ("Hit the wall at position %d ,%d",position[0],position[1]);
                    SPEC_7_FAIL;
                end
                else begin
                    position[1]=position[1]-1;
                end
            end
            else if(out===3)begin//up
            stall = 0;
                if(mazemap[position[0]-1][position[1]]==0||position[0]-1==-1)begin
                   // $display ("Hit the wall at position %d ,%d",position[0],position[1]);
                    SPEC_7_FAIL;  
                end
                else begin
                    position[0]=position[0]-1;
                end
            end
            else if(out===4)begin//stall
                if (mazemap[position[0]][position[1]]!=2) begin
                    //$display ("YOU ARE NOT TRAPPED");
                    SPEC_7_FAIL;
                end
                else if(mazemap[position[0]][position[1]]==2&&stall==1)begin
                    //$display ("YOU STALL TWICE, HOW LONG DO YOU WANT TO STAY HERE?");
                    SPEC_7_FAIL;
                end
            end
            else begin
                //$display ("out is not the legal direction",out);
                SPEC_7_FAIL;
            end

            if(mazemap[position[0]][position[1]]==2)begin
                stall=0;
            end

        end
    cycles = cycles+1;
    @(negedge clk);    
    
    end
    if(out_valid2!==1 && out!==0)begin
        SPEC_4_FAIL;
    end
    if(!((position[0]==16&&position[1]==16)||(mazemap[position[0]][position[1]]==3)))SPEC_8_FAIL;
end endtask

task give_code;begin
    //$display("give code!!!");
    gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);

	in_valid2 = 1'b1;
    
    in_data = password[hostage_code];

    if(out_valid1===1||out_valid2===1||in_valid1===1)SPEC_5_FAIL;

    if(out!==0)SPEC_4_FAIL;

    @(negedge clk);
    in_valid2 = 1'b0;
    cycles = cycles +1;
    in_data = 9'bx;
    hostage_code = hostage_code +1;

end endtask
 
task check_out_data;begin

    while(out_valid1!==1)begin
        cycles = cycles + 1;
        @(negedge clk)
        if(out!==0)SPEC_4_FAIL;
        if (cycles>3000) SPEC_6_FAIL;
    end
    if(position[0]!=16||position[1]!=16)SPEC_8_FAIL;
    golden_step = 0;
    while(out_valid1===1)begin  

        if(out_valid2===1||in_valid1===1||in_valid2===1)SPEC_5_FAIL;

        if ( out_data !== golden_data[ golden_step ] )SPEC_10_FAIL;
        @(negedge clk);
		golden_step=golden_step+1;

    end
    //$display(golden_step,hostage_n);
    if(hostage_n==0)begin
        if((golden_step) !== 1 )SPEC_9_FAIL;
    end 
    else begin
        if ((golden_step) !== hostage_n) SPEC_9_FAIL;
    end 

    if(out_data!=0) SPEC_11_FAIL;
    total_cycles = total_cycles + cycles;
end endtask

task SPEC_3_FAIL;begin
    $display ("SPEC 3 IS FAIL!");
    $finish ;
end endtask

task SPEC_4_FAIL;begin
    $display ("SPEC 4 IS FAIL!");
    $finish ;
end endtask

task SPEC_5_FAIL;begin
    $display ("SPEC 5 IS FAIL!");
    $finish ;
end endtask

task SPEC_6_FAIL;begin
    $display ("SPEC 6 IS FAIL!");
    $finish ; 
end endtask

task SPEC_7_FAIL;begin
    $display ("SPEC 7 IS FAIL!");
    $finish ;  
end endtask

task SPEC_8_FAIL;begin
    $display ("SPEC 8 IS FAIL!");
    $finish;
end endtask

task SPEC_9_FAIL;begin
    $display ("SPEC 9 IS FAIL!");
    $finish;
end endtask

task SPEC_10_FAIL;begin 
    $display ("SPEC 10 IS FAIL!");
    $finish;
end endtask

task SPEC_11_FAIL;begin
    $display ("SPEC 11 IS FAIL!");
    $finish;
end endtask

endmodule