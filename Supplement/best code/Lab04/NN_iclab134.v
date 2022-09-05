module NN(
	// Input signals
	clk,
	rst_n,
	in_valid_i,
	in_valid_k,
	in_valid_o,
	Image1,
	Image2,
	Image3,
	Kernel1,
	Kernel2,
	Kernel3,
	Opt,
	// Output signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameters
parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 1;
parameter sum3_arch = 1;
parameter exp_arch = 1;
parameter inst_faithful_round=1;
integer j;
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_i, in_valid_k, in_valid_o;
input [sig_width+exp_width:0] Image1, Image2, Image3;
input [sig_width+exp_width:0] Kernel1, Kernel2, Kernel3;
input [1:0] Opt;
output reg	out_valid;
output reg [sig_width+exp_width:0] out;

reg [2:0]STATE,NS;
reg ovb1,ovb2,ovb3,ovmac1,ovmac2,ovmac3,ovmaco,ovact1,ovact2,ovact3;

reg [31:0]im1[0:3][0:3];//im[row][col]
reg [31:0]im2[0:3][0:3];
reg [31:0]im3[0:3][0:3];
reg [31:0]k1[0:3][0:9];//k[out_ch][row_col]
reg [31:0]k2[0:3][0:9];
reg [31:0]k3[0:3][0:9];
reg [1:0]opt;

reg [3:0]im_cnt;
reg [1:0]kc_cnt;
reg [3:0]kp_cnt;
reg [5:0]fcnt,fcnt_b1,fcnt_b2;

reg [95:0]conv_im1_r,conv_im2_r,conv_im3_r,conv_im4_r,conv_im5_r,conv_im6_r,conv_im7_r,conv_im8_r,conv_im9_r;
reg [95:0]conv_im1,conv_im2,conv_im3,conv_im4,conv_im5,conv_im6,conv_im7,conv_im8,conv_im9;
reg [95:0]conv_k1,conv_k2,conv_k3,conv_k4,conv_k5,conv_k6,conv_k7,conv_k8,conv_k9;

wire [31:0]mac1[0:26];
wire [7:0]mult_status[0:26];
reg [31:0]mac_r1[0:26];
wire [31:0]mac2[0:8];
reg [31:0]mac_r2[0:8];
wire [31:0]mac3[0:2];
reg [31:0]mac_r3[0:2];
wire [31:0]mac_o;
reg [31:0]mac_out;
wire [7:0]sum_status[0:12];

wire [31:0]exp_o,rec_o,act_ad_o,act_sb_o,result;
reg [31:0]act_ad_i,div_id,div_in;
reg [31:0]act1_1,act1_2,act2_1,act2_2,act2_3,act3_1,act3_2;
wire [7:0]act_status[0:4];

wire [31:0]cvim1[0:2][0:2];
assign cvim1[0][0]=conv_im1[31:0];
assign cvim1[0][1]=conv_im2[31:0];
assign cvim1[0][2]=conv_im3[31:0];
assign cvim1[1][0]=conv_im4[31:0];
assign cvim1[1][1]=conv_im5[31:0];
assign cvim1[1][2]=conv_im6[31:0];
assign cvim1[2][0]=conv_im7[31:0];
assign cvim1[2][1]=conv_im8[31:0];
assign cvim1[2][2]=conv_im9[31:0];

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		STATE<=0;
		out_valid<=0;
		out<=0;
		
		ovb1<=0;
		ovb2<=0;
		ovb3<=0;
		ovmac1<=0;
		ovmac2<=0;
		ovmac3<=0;
		ovmaco<=0;
		ovact1<=0;
		ovact2<=0;
		ovact3<=0;
	end
	else begin
		STATE<=NS;
		
		ovb1<=(STATE==6||STATE==7)?1:0;
		ovb2<=ovb1;
		ovb3<=ovb2;
		ovmac1<=ovb3;
		ovmac2<=ovmac1;
		ovmac3<=ovmac2;
		ovmaco<=ovmac3;
		ovact1<=ovmaco;
		ovact2<=ovact1;
		ovact3<=ovact2;
		out_valid<=ovact3;
		
		out<=ovact3?result:0;
	end

end

always@(*)begin
	case(STATE)
		0:begin //IDLE
			if(in_valid_o)begin
				NS<=1;
			end
			else begin
				NS<=STATE;
			end
		end
		1:begin //opt in
			NS<=2;
		end
		2:begin //wait im in
			if(in_valid_i)begin
				NS<=3;
			end
			else begin
				NS<=STATE;
			end
		end
		3:begin //im in
			if(in_valid_i==0)begin
				NS<=4;
			end
			else begin
				NS<=STATE;
			end
		end
		4:begin //wait kernel in
			if(in_valid_k)begin
				NS<=5;
			end
			else begin
				NS<=STATE;
			end
		end
		5:begin //kernel in
			if(kc_cnt==2&&kp_cnt==7)begin
				NS<=6;
			end
			else begin
				NS<=STATE;
			end
		end
		6:begin //kernel in w/ forward compute
			if(in_valid_k==0)begin
				NS<=7;
			end
			else begin
				NS<=STATE;
			end
		end
		7:begin //forward compute
			if(fcnt==63)begin
				NS<=0;
			end
			else begin
				NS<=STATE;
			end
		end
		default:begin
			NS<=STATE;
		end
	endcase
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		im_cnt<=0;
		kp_cnt<=0;
		kc_cnt<=0;
		fcnt<=0;
	end
	else begin
		if(NS!=3)begin
			im_cnt<=0;
		end
		else begin
			im_cnt<=im_cnt+1;
		end
		
		if((NS!=5&&NS!=6)||kp_cnt==8)begin
			kp_cnt<=0;
		end
		else begin
			kp_cnt<=kp_cnt+1;
		end
		
		if(NS!=5&&NS!=6)begin
			kc_cnt<=0;
		end
		else if(kp_cnt==8)begin
			kc_cnt<=kc_cnt+1;
		end
		
		if(STATE!=6&&STATE!=7)begin
			fcnt<=0;
		end
		else begin
			fcnt<=fcnt+1;
		end
		
		fcnt_b1<=fcnt;
		fcnt_b2<=fcnt_b1;
		
	end
end

always@(posedge clk)begin
	
	if(NS==1)begin
		opt<=Opt;
	end
	
	if(NS==3)begin
		im1[im_cnt[3:2]][im_cnt[1:0]]<=Image1;
		im2[im_cnt[3:2]][im_cnt[1:0]]<=Image2;
		im3[im_cnt[3:2]][im_cnt[1:0]]<=Image3;
	end
	
	if(NS==5||NS==6)begin
		k1[kc_cnt][kp_cnt]<=Kernel1;
		k2[kc_cnt][kp_cnt]<=Kernel2;
		k3[kc_cnt][kp_cnt]<=Kernel3;
	end
	
	if(fcnt[0])begin
		conv_im2_r<=conv_im3_r;
		conv_im1_r<=conv_im2_r;
		conv_im5_r<=conv_im6_r;
		conv_im4_r<=conv_im5_r;
		conv_im8_r<=conv_im9_r;
		conv_im7_r<=conv_im8_r;
	end
end

always@(*)begin
	case(fcnt[5:4])
		0:begin
			conv_im3_r[31:0]<=im1[0][fcnt[2:1]];
			conv_im6_r[31:0]<=im1[0][fcnt[2:1]];
			conv_im9_r[31:0]<=im1[1][fcnt[2:1]];
			conv_im3_r[63:32]<=im2[0][fcnt[2:1]];
			conv_im6_r[63:32]<=im2[0][fcnt[2:1]];
			conv_im9_r[63:32]<=im2[1][fcnt[2:1]];
			conv_im3_r[95:64]<=im3[0][fcnt[2:1]];
			conv_im6_r[95:64]<=im3[0][fcnt[2:1]];
			conv_im9_r[95:64]<=im3[1][fcnt[2:1]];
		end
		1:begin
			conv_im3_r[31:0]<=im1[0][fcnt[2:1]];
			conv_im6_r[31:0]<=im1[1][fcnt[2:1]];
			conv_im9_r[31:0]<=im1[2][fcnt[2:1]];
			conv_im3_r[63:32]<=im2[0][fcnt[2:1]];
			conv_im6_r[63:32]<=im2[1][fcnt[2:1]];
			conv_im9_r[63:32]<=im2[2][fcnt[2:1]];
			conv_im3_r[95:64]<=im3[0][fcnt[2:1]];
			conv_im6_r[95:64]<=im3[1][fcnt[2:1]];
			conv_im9_r[95:64]<=im3[2][fcnt[2:1]];
		end
		2:begin
			conv_im3_r[31:0]<=im1[1][fcnt[2:1]];
			conv_im6_r[31:0]<=im1[2][fcnt[2:1]];
			conv_im9_r[31:0]<=im1[3][fcnt[2:1]];
			conv_im3_r[63:32]<=im2[1][fcnt[2:1]];
			conv_im6_r[63:32]<=im2[2][fcnt[2:1]];
			conv_im9_r[63:32]<=im2[3][fcnt[2:1]];
			conv_im3_r[95:64]<=im3[1][fcnt[2:1]];
			conv_im6_r[95:64]<=im3[2][fcnt[2:1]];
			conv_im9_r[95:64]<=im3[3][fcnt[2:1]];
		end
		3:begin
			conv_im3_r[31:0]<=im1[2][fcnt[2:1]];
			conv_im6_r[31:0]<=im1[3][fcnt[2:1]];
			conv_im9_r[31:0]<=im1[3][fcnt[2:1]];
			conv_im3_r[63:32]<=im2[2][fcnt[2:1]];
			conv_im6_r[63:32]<=im2[3][fcnt[2:1]];
			conv_im9_r[63:32]<=im2[3][fcnt[2:1]];
			conv_im3_r[95:64]<=im3[2][fcnt[2:1]];
			conv_im6_r[95:64]<=im3[3][fcnt[2:1]];
			conv_im9_r[95:64]<=im3[3][fcnt[2:1]];
		end
	endcase
end	

always@(posedge clk)begin
	
	if((fcnt_b2[5:4]==0||fcnt_b2[2:1]==0)&&opt[1]==1)begin
		conv_im1<=0;	
	end
	else if(fcnt_b2[2:1]==0)begin
		conv_im1<=conv_im2_r;
	end
	else begin
		conv_im1<=conv_im1_r;
	end
	
	if(opt[1]==1&&fcnt_b2[5:4]==0)begin
		conv_im2<=0;
	end
	else begin
		conv_im2<=conv_im2_r;
	end
	
	if((fcnt_b2[5:4]==0||fcnt_b2[2:1]==3)&&opt[1]==1)begin
		conv_im3<=0;	
	end
	else if(fcnt_b2[2:1]==3)begin
		conv_im3<=conv_im2_r;
	end
	else begin
		conv_im3<=conv_im3_r;
	end
	
	if(fcnt_b2[2:1]==0)begin
		if(opt[1]==1)begin
			conv_im4<=0;
		end
		else begin
			conv_im4<=conv_im5_r;
		end
	end
	else begin
		conv_im4<=conv_im4_r;
	end
	
	conv_im5<=conv_im5_r;
	
	if(fcnt_b2[2:1]==3)begin
		if(opt[1]==1)begin
			conv_im6<=0;
		end
		else begin
			conv_im6<=conv_im5_r;
		end
	end
	else begin
		conv_im6<=conv_im6_r;
	end
	
	if((fcnt_b2[5:4]==3||fcnt_b2[2:1]==0)&&opt[1]==1)begin
		conv_im7<=0;	
	end
	else if(fcnt_b2[2:1]==0)begin
		conv_im7<=conv_im8_r;
	end
	else begin
		conv_im7<=conv_im7_r;
	end
	
	if(opt[1]==1&&fcnt_b2[5:4]==3)begin
		conv_im8<=0;
	end
	else begin
		conv_im8<=conv_im8_r;
	end
	
	if((fcnt_b2[5:4]==3||fcnt_b2[2:1]==3)&&opt[1]==1)begin
		conv_im9<=0;	
	end
	else if(fcnt_b2[2:1]==3)begin
		conv_im9<=conv_im8_r;
	end
	else begin
		conv_im9<=conv_im9_r;
	end
	
	conv_k1[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][0];
	conv_k1[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][0];
	conv_k1[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][0];
	conv_k2[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][1];
	conv_k2[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][1];
	conv_k2[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][1];
	conv_k3[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][2];
	conv_k3[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][2];
	conv_k3[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][2];
	conv_k4[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][3];
	conv_k4[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][3];
	conv_k4[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][3];
	conv_k5[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][4];
	conv_k5[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][4];
	conv_k5[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][4];
	conv_k6[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][5];
	conv_k6[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][5];
	conv_k6[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][5];
	conv_k7[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][6];
	conv_k7[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][6];
	conv_k7[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][6];
	conv_k8[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][7];
	conv_k8[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][7];
	conv_k8[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][7];
	conv_k9[31:0]<=k1[{fcnt_b2[3],fcnt_b2[0]}][8];
	conv_k9[63:32]<=k2[{fcnt_b2[3],fcnt_b2[0]}][8];
	conv_k9[95:64]<=k3[{fcnt_b2[3],fcnt_b2[0]}][8];
	
end

always@(posedge clk)begin
	for(j=0;j<27;j=j+1)begin
		mac_r1[j]<=mac1[j];
	end
	for(j=0;j<9;j=j+1)begin
		mac_r2[j]<=mac2[j];
	end
	for(j=0;j<3;j=j+1)begin
		mac_r3[j]<=mac3[j];
	end
	mac_out<=mac_o;
	act1_1<=exp_o;
	act1_2<=mac_out;
	act2_1<=rec_o;
	act2_2<=act1_1;
	act2_3<=act1_2;
	act3_1<=div_id;
	act3_2<=div_in;
end

always@(*)begin
	if(opt[0])begin
		act_ad_i<=act2_2;
	end
	else begin
		act_ad_i<=32'b00111111100000000000000000000000;
	end
	
	//if(opt[1]==0&&act2_3[31]==1)begin
	if(opt[1]==0&&act2_3[31]==1)begin
		div_id<=32'b01000001001000000000000000000000;
	end
	else if(opt[1]==0)begin
		div_id<=32'b00111111100000000000000000000000;
	end
	else begin
		//div_id<=act2_1;
		div_id<=act_ad_o;
	end
	
	if(opt==3)begin
		//div_in<=act2_2;
		div_in<=act_sb_o;
	end
	else if(opt==2)begin
		div_in<=32'b00111111100000000000000000000000;
	end
	//else if(opt==0&&act2_3[31]==1)begin
	else if(opt==0&&act2_3[31]==1)begin
		div_in<=32'b00000000000000000000000000000000;
	end
	else begin
		//div_in<=act2_3;
		div_in<=act2_3;
	end
	
end

DW_fp_mult #(sig_width,exp_width,ieee_compliance) M0(.a(conv_im1[31:0]),.b(conv_k1[31:0]),.rnd(3'b000),.z(mac1[0]),.status(mult_status[0]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance) M1(.a(conv_im2[31:0]),.b(conv_k2[31:0]),.rnd(3'b000),.z(mac1[1]),.status(mult_status[1]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance) M2(.a(conv_im3[31:0]),.b(conv_k3[31:0]),.rnd(3'b000),.z(mac1[2]),.status(mult_status[2]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance) M3(.a(conv_im4[31:0]),.b(conv_k4[31:0]),.rnd(3'b000),.z(mac1[3]),.status(mult_status[3]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance) M4(.a(conv_im5[31:0]),.b(conv_k5[31:0]),.rnd(3'b000),.z(mac1[4]),.status(mult_status[4]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance) M5(.a(conv_im6[31:0]),.b(conv_k6[31:0]),.rnd(3'b000),.z(mac1[5]),.status(mult_status[5]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance) M6(.a(conv_im7[31:0]),.b(conv_k7[31:0]),.rnd(3'b000),.z(mac1[6]),.status(mult_status[6]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance) M7(.a(conv_im8[31:0]),.b(conv_k8[31:0]),.rnd(3'b000),.z(mac1[7]),.status(mult_status[7]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance) M8(.a(conv_im9[31:0]),.b(conv_k9[31:0]),.rnd(3'b000),.z(mac1[8]),.status(mult_status[8]));

DW_fp_mult #(sig_width,exp_width,ieee_compliance) M9(.a(conv_im1[63:32]),.b(conv_k1[63:32]),.rnd(3'b000),.z(mac1[9]),.status(mult_status[9]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M10(.a(conv_im2[63:32]),.b(conv_k2[63:32]),.rnd(3'b000),.z(mac1[10]),.status(mult_status[10]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M11(.a(conv_im3[63:32]),.b(conv_k3[63:32]),.rnd(3'b000),.z(mac1[11]),.status(mult_status[11]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M12(.a(conv_im4[63:32]),.b(conv_k4[63:32]),.rnd(3'b000),.z(mac1[12]),.status(mult_status[12]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M13(.a(conv_im5[63:32]),.b(conv_k5[63:32]),.rnd(3'b000),.z(mac1[13]),.status(mult_status[13]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M14(.a(conv_im6[63:32]),.b(conv_k6[63:32]),.rnd(3'b000),.z(mac1[14]),.status(mult_status[14]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M15(.a(conv_im7[63:32]),.b(conv_k7[63:32]),.rnd(3'b000),.z(mac1[15]),.status(mult_status[15]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M16(.a(conv_im8[63:32]),.b(conv_k8[63:32]),.rnd(3'b000),.z(mac1[16]),.status(mult_status[16]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M17(.a(conv_im9[63:32]),.b(conv_k9[63:32]),.rnd(3'b000),.z(mac1[17]),.status(mult_status[17]));

DW_fp_mult #(sig_width,exp_width,ieee_compliance)M18(.a(conv_im1[95:64]),.b(conv_k1[95:64]),.rnd(3'b000),.z(mac1[18]),.status(mult_status[18]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M19(.a(conv_im2[95:64]),.b(conv_k2[95:64]),.rnd(3'b000),.z(mac1[19]),.status(mult_status[19]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M20(.a(conv_im3[95:64]),.b(conv_k3[95:64]),.rnd(3'b000),.z(mac1[20]),.status(mult_status[20]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M21(.a(conv_im4[95:64]),.b(conv_k4[95:64]),.rnd(3'b000),.z(mac1[21]),.status(mult_status[21]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M22(.a(conv_im5[95:64]),.b(conv_k5[95:64]),.rnd(3'b000),.z(mac1[22]),.status(mult_status[22]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M23(.a(conv_im6[95:64]),.b(conv_k6[95:64]),.rnd(3'b000),.z(mac1[23]),.status(mult_status[23]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M24(.a(conv_im7[95:64]),.b(conv_k7[95:64]),.rnd(3'b000),.z(mac1[24]),.status(mult_status[24]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M25(.a(conv_im8[95:64]),.b(conv_k8[95:64]),.rnd(3'b000),.z(mac1[25]),.status(mult_status[25]));
DW_fp_mult #(sig_width,exp_width,ieee_compliance)M26(.a(conv_im9[95:64]),.b(conv_k9[95:64]),.rnd(3'b000),.z(mac1[26]),.status(mult_status[26]));
//DW_fp_mult #(sig_width,exp_width,ieee_compliance) M(.a(conv_im[:]),.b(conv_k[:]),.rnd(3'b000),.z(mult_out[]),.status(mult_status[]));
genvar i;
generate
	for(i=0;i<9;i=i+1)begin:SUM3_1
		DW_fp_sum3 #(sig_width,exp_width,ieee_compliance,sum3_arch) S1(.a(mac_r1[i*3]),.b(mac_r1[i*3+1]),.c(mac_r1[i*3+2]),.rnd(3'b000),.z(mac2[i]),.status(sum_status[i]));
	end
	
	for(i=0;i<3;i=i+1)begin:SUM3_2
		DW_fp_sum3 #(sig_width,exp_width,ieee_compliance,sum3_arch) S2(.a(mac_r2[i*3]),.b(mac_r2[i*3+1]),.c(mac_r2[i*3+2]),.rnd(3'b000),.z(mac3[i]),.status(sum_status[i+9]));
	end
endgenerate
DW_fp_sum3 #(sig_width,exp_width,ieee_compliance,sum3_arch) S3(.a(mac_r3[0]),.b(mac_r3[1]),.c(mac_r3[2]),.rnd(3'b000),.z(mac_o),.status(sum_status[12]));
DW_fp_exp #(sig_width, exp_width, ieee_compliance, exp_arch) EXP(.a(mac_out),.z(exp_o),.status(act_status[0]) );
DW_fp_recip #(sig_width, exp_width, ieee_compliance, inst_faithful_round) RECIP(.a(act1_1),.rnd(3'b000),.z(rec_o),.status(act_status[1]) );
DW_fp_add #(sig_width, exp_width, ieee_compliance) ADD( .a(act_ad_i), .b(act2_1), .rnd(3'b000), .z(act_ad_o), .status(act_status[2]) );
DW_fp_sub #(sig_width, exp_width, ieee_compliance) SUB( .a(act2_2), .b(act2_1), .rnd(3'b000), .z(act_sb_o), .status(act_status[3]) );
DW_fp_div #(sig_width, exp_width, ieee_compliance, inst_faithful_round) DIV( .a(act3_2), .b(act3_1), .rnd(3'b000), .z(result), .status(act_status[4]));


endmodule



