//++++++++++++++ Include DesignWare++++++++++++++++++
// synopsys translate_off

// synopsys translate_on
//+++++++++++++++++++++++++++++++++++++++++++++++++
// evince /RAID2/EDA/synopsys/synthesis/2020.09/dw/doc/manuals/dwbb_userguide.pdf &
// else if(current_state == CAL && inOpt[1])begin
	// 	case (mult_counter)
	// 		0:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= zero;
	// 				mult_a[1] <= zero;
	// 				mult_a[2] <= zero;
	// 				mult_a[3] <= zero;
	// 				mult_a[4] <= inImage1[0];
	// 				mult_a[5] <= inImage1[1];
	// 				mult_a[6] <= zero;
	// 				mult_a[7] <= inImage1[4];
	// 				mult_a[8] <= inImage1[5];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= zero;
	// 				mult_a[1] <= zero;
	// 				mult_a[2] <= zero;
	// 				mult_a[3] <= zero;
	// 				mult_a[4] <= inImage2[0];
	// 				mult_a[5] <= inImage2[1];
	// 				mult_a[6] <= zero;
	// 				mult_a[7] <= inImage2[4];
	// 				mult_a[8] <= inImage2[5];
	// 			end
	// 			else begin
	// 				mult_a[0] <= zero;
	// 				mult_a[1] <= zero;
	// 				mult_a[2] <= zero;
	// 				mult_a[3] <= zero;
	// 				mult_a[4] <= inImage3[0];
	// 				mult_a[5] <= inImage3[1];
	// 				mult_a[6] <= zero;
	// 				mult_a[7] <= inImage3[4];
	// 				mult_a[8] <= inImage3[5];
	// 			end
	// 		end 
	// 		1: begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= zero;
	// 				mult_a[1] <= zero;
	// 				mult_a[2] <= zero;
	// 				mult_a[3] <= inImage1[0];
	// 				mult_a[4] <= inImage1[1];
	// 				mult_a[5] <= inImage1[2];
	// 				mult_a[6] <= inImage1[4];
	// 				mult_a[7] <= inImage1[5];
	// 				mult_a[8] <= inImage1[6];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= zero;
	// 				mult_a[1] <= zero;
	// 				mult_a[2] <= zero;
	// 				mult_a[3] <= inImage2[0];
	// 				mult_a[4] <= inImage2[1];
	// 				mult_a[5] <= inImage2[2];
	// 				mult_a[6] <= inImage2[4];
	// 				mult_a[7] <= inImage2[5];
	// 				mult_a[8] <= inImage2[6];
	// 			end
	// 			else begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= zero ;
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage3[0];
	// 				mult_a[4] <= inImage3[1];
	// 				mult_a[5] <= inImage3[2];
	// 				mult_a[6] <= inImage3[4];
	// 				mult_a[7] <= inImage3[5];
	// 				mult_a[8] <= inImage3[6];
	// 			end
	// 		end
	// 		2: begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= zero ;
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage1[1];
	// 				mult_a[4] <= inImage1[2];
	// 				mult_a[5] <= inImage1[3];
	// 				mult_a[6] <= inImage1[5];
	// 				mult_a[7] <= inImage1[6];
	// 				mult_a[8] <= inImage1[7];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= zero ;
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage2[1];
	// 				mult_a[4] <= inImage2[2];
	// 				mult_a[5] <= inImage2[3];
	// 				mult_a[6] <= inImage2[5];
	// 				mult_a[7] <= inImage2[6];
	// 				mult_a[8] <= inImage2[7];
	// 			end
	// 			else begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= zero ;
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage3[1];
	// 				mult_a[4] <= inImage3[2];
	// 				mult_a[5] <= inImage3[3];
	// 				mult_a[6] <= inImage3[5];
	// 				mult_a[7] <= inImage3[6];
	// 				mult_a[8] <= inImage3[7];
	// 			end
				
	// 		end
	// 		3: begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= zero ;
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage1[2];
	// 				mult_a[4] <= inImage1[3];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage1[6];
	// 				mult_a[7] <= inImage1[7];
	// 				mult_a[8] <= zero ;
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= zero ;
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage2[2];
	// 				mult_a[4] <= inImage2[3];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage2[6];
	// 				mult_a[7] <= inImage2[7];
	// 				mult_a[8] <= zero ;
	// 			end
	// 			else begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= zero ;
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage3[2];
	// 				mult_a[4] <= inImage3[3];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage3[6];
	// 				mult_a[7] <= inImage3[7];
	// 				mult_a[8] <= zero ;
	// 			end
				
	// 		end
	// 		4:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage1[0];
	// 				mult_a[2] <= inImage1[1];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage1[4];
	// 				mult_a[5] <= inImage1[5];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= inImage1[8];
	// 				mult_a[8] <= inImage1[9];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage2[0];
	// 				mult_a[2] <= inImage2[1];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage2[4];
	// 				mult_a[5] <= inImage2[5];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= inImage2[8];
	// 				mult_a[8] <= inImage2[9];
	// 			end
	// 			else begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage3[0];
	// 				mult_a[2] <= inImage3[1];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage3[4];
	// 				mult_a[5] <= inImage3[5];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= inImage3[8];
	// 				mult_a[8] <= inImage3[9];
	// 			end
				
	// 		end
	// 		5:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[0];
	// 				mult_a[1] <= inImage1[1];
	// 				mult_a[2] <= inImage1[2];
	// 				mult_a[3] <= inImage1[4];
	// 				mult_a[4] <= inImage1[5];
	// 				mult_a[5] <= inImage1[6];
	// 				mult_a[6] <= inImage1[8];
	// 				mult_a[7] <= inImage1[9];
	// 				mult_a[8] <= inImage1[10];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[0];
	// 				mult_a[1] <= inImage2[1];
	// 				mult_a[2] <= inImage2[2];
	// 				mult_a[3] <= inImage2[4];
	// 				mult_a[4] <= inImage2[5];
	// 				mult_a[5] <= inImage2[6];
	// 				mult_a[6] <= inImage2[8];
	// 				mult_a[7] <= inImage2[9];
	// 				mult_a[8] <= inImage2[10];
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[0];
	// 				mult_a[1] <= inImage3[1];
	// 				mult_a[2] <= inImage3[2];
	// 				mult_a[3] <= inImage3[4];
	// 				mult_a[4] <= inImage3[5];
	// 				mult_a[5] <= inImage3[6];
	// 				mult_a[6] <= inImage3[8];
	// 				mult_a[7] <= inImage3[9];
	// 				mult_a[8] <= inImage3[10];
	// 			end
	// 		end
	// 		6:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[1];
	// 				mult_a[1] <= inImage1[2];
	// 				mult_a[2] <= inImage1[3];
	// 				mult_a[3] <= inImage1[5];
	// 				mult_a[4] <= inImage1[6];
	// 				mult_a[5] <= inImage1[7];
	// 				mult_a[6] <= inImage1[9];
	// 				mult_a[7] <= inImage1[10];
	// 				mult_a[8] <= inImage1[11];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[1];
	// 				mult_a[1] <= inImage2[2];
	// 				mult_a[2] <= inImage2[3];
	// 				mult_a[3] <= inImage2[5];
	// 				mult_a[4] <= inImage2[6];
	// 				mult_a[5] <= inImage2[7];
	// 				mult_a[6] <= inImage2[9];
	// 				mult_a[7] <= inImage2[10];
	// 				mult_a[8] <= inImage2[11];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[1];
	// 				mult_a[1] <= inImage3[2];
	// 				mult_a[2] <= inImage3[3];
	// 				mult_a[3] <= inImage3[5];
	// 				mult_a[4] <= inImage3[6];
	// 				mult_a[5] <= inImage3[7];
	// 				mult_a[6] <= inImage3[9];
	// 				mult_a[7] <= inImage3[10];
	// 				mult_a[8] <= inImage3[11];	
	// 			end
				
	// 		end
	// 		7:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[2];
	// 				mult_a[1] <= inImage1[3];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage1[6];
	// 				mult_a[4] <= inImage1[7];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage1[10];
	// 				mult_a[7] <= inImage1[11];
	// 				mult_a[8] <= zero ;
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[2];
	// 				mult_a[1] <= inImage2[3];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage2[6];
	// 				mult_a[4] <= inImage2[7];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage2[10];
	// 				mult_a[7] <= inImage2[11];
	// 				mult_a[8] <= zero ;	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[2];
	// 				mult_a[1] <= inImage3[3];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage3[6];
	// 				mult_a[4] <= inImage3[7];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage3[10];
	// 				mult_a[7] <= inImage3[11];
	// 				mult_a[8] <= zero ;	
	// 			end
				
	// 		end
	// 		8:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage1[4];
	// 				mult_a[2] <= inImage1[5];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage1[8];
	// 				mult_a[5] <= inImage1[9];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= inImage1[12];
	// 				mult_a[8] <= inImage1[13];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage2[4];
	// 				mult_a[2] <= inImage2[5];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage2[8];
	// 				mult_a[5] <= inImage2[9];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= inImage2[12];
	// 				mult_a[8] <= inImage2[13];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage3[4];
	// 				mult_a[2] <= inImage3[5];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage3[8];
	// 				mult_a[5] <= inImage3[9];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= inImage3[12];
	// 				mult_a[8] <= inImage3[13];	
	// 			end
				
	// 		end
	// 		9:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[4];
	// 				mult_a[1] <= inImage1[5];
	// 				mult_a[2] <= inImage1[6];
	// 				mult_a[3] <= inImage1[8];
	// 				mult_a[4] <= inImage1[9];
	// 				mult_a[5] <= inImage1[10];
	// 				mult_a[6] <= inImage1[12];
	// 				mult_a[7] <= inImage1[13];
	// 				mult_a[8] <= inImage1[14];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[4];
	// 				mult_a[1] <= inImage2[5];
	// 				mult_a[2] <= inImage2[6];
	// 				mult_a[3] <= inImage2[8];
	// 				mult_a[4] <= inImage2[9];
	// 				mult_a[5] <= inImage2[10];
	// 				mult_a[6] <= inImage2[12];
	// 				mult_a[7] <= inImage2[13];
	// 				mult_a[8] <= inImage2[14];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[4];
	// 				mult_a[1] <= inImage3[5];
	// 				mult_a[2] <= inImage3[6];
	// 				mult_a[3] <= inImage3[8];
	// 				mult_a[4] <= inImage3[9];
	// 				mult_a[5] <= inImage3[10];
	// 				mult_a[6] <= inImage3[12];
	// 				mult_a[7] <= inImage3[13];
	// 				mult_a[8] <= inImage3[14];	
	// 			end
	// 		end
	// 		10:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[5];
	// 				mult_a[1] <= inImage1[6];
	// 				mult_a[2] <= inImage1[7];
	// 				mult_a[3] <= inImage1[9];
	// 				mult_a[4] <= inImage1[10];
	// 				mult_a[5] <= inImage1[11];
	// 				mult_a[6] <= inImage1[13];
	// 				mult_a[7] <= inImage1[14];
	// 				mult_a[8] <= inImage1[15];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[5];
	// 				mult_a[1] <= inImage2[6];
	// 				mult_a[2] <= inImage2[7];
	// 				mult_a[3] <= inImage2[9];
	// 				mult_a[4] <= inImage2[10];
	// 				mult_a[5] <= inImage2[11];
	// 				mult_a[6] <= inImage2[13];
	// 				mult_a[7] <= inImage2[14];
	// 				mult_a[8] <= inImage2[15];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[5];
	// 				mult_a[1] <= inImage3[6];
	// 				mult_a[2] <= inImage3[7];
	// 				mult_a[3] <= inImage3[9];
	// 				mult_a[4] <= inImage3[10];
	// 				mult_a[5] <= inImage3[11];
	// 				mult_a[6] <= inImage3[13];
	// 				mult_a[7] <= inImage3[14];
	// 				mult_a[8] <= inImage3[15];	
	// 			end
				
	// 		end
	// 		11:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[6];
	// 				mult_a[1] <= inImage1[7];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage1[10];
	// 				mult_a[4] <= inImage1[11];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage1[14];
	// 				mult_a[7] <= inImage1[15];
	// 				mult_a[8] <= zero ;
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[6];
	// 				mult_a[1] <= inImage2[7];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage2[10];
	// 				mult_a[4] <= inImage2[11];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage2[14];
	// 				mult_a[7] <= inImage2[15];
	// 				mult_a[8] <= zero ;	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[6];
	// 				mult_a[1] <= inImage3[7];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage3[10];
	// 				mult_a[4] <= inImage3[11];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= inImage3[14];
	// 				mult_a[7] <= inImage3[15];
	// 				mult_a[8] <= zero ;	
	// 			end
				
	// 		end
	// 		12:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage1[8];
	// 				mult_a[2] <= inImage1[9];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage1[12];
	// 				mult_a[5] <= inImage1[13];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage2[8];
	// 				mult_a[2] <= inImage2[9];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage2[12];
	// 				mult_a[5] <= inImage2[13];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;	
	// 			end
	// 			else begin
	// 				mult_a[0] <= zero ;
	// 				mult_a[1] <= inImage3[8];
	// 				mult_a[2] <= inImage3[9];
	// 				mult_a[3] <= zero ;
	// 				mult_a[4] <= inImage3[12];
	// 				mult_a[5] <= inImage3[13];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;	
	// 			end
				
	// 		end
	// 		13:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[8];
	// 				mult_a[1] <= inImage1[9];
	// 				mult_a[2] <= inImage1[10];
	// 				mult_a[3] <= inImage1[12];
	// 				mult_a[4] <= inImage1[13];
	// 				mult_a[5] <= inImage1[14];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[8];
	// 				mult_a[1] <= inImage2[9];
	// 				mult_a[2] <= inImage2[10];
	// 				mult_a[3] <= inImage2[12];
	// 				mult_a[4] <= inImage2[13];
	// 				mult_a[5] <= inImage2[14];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[8];
	// 				mult_a[1] <= inImage3[9];
	// 				mult_a[2] <= inImage3[10];
	// 				mult_a[3] <= inImage3[12];
	// 				mult_a[4] <= inImage3[13];
	// 				mult_a[5] <= inImage3[14];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;	
	// 			end
				
	// 		end
	// 		14:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[9];
	// 				mult_a[1] <= inImage1[10];
	// 				mult_a[2] <= inImage1[11];
	// 				mult_a[3] <= inImage1[13];
	// 				mult_a[4] <= inImage1[14];
	// 				mult_a[5] <= inImage1[15];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[9];
	// 				mult_a[1] <= inImage2[10];
	// 				mult_a[2] <= inImage2[11];
	// 				mult_a[3] <= inImage2[13];
	// 				mult_a[4] <= inImage2[14];
	// 				mult_a[5] <= inImage2[15];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[9];
	// 				mult_a[1] <= inImage3[10];
	// 				mult_a[2] <= inImage3[11];
	// 				mult_a[3] <= inImage3[13];
	// 				mult_a[4] <= inImage3[14];
	// 				mult_a[5] <= inImage3[15];
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;	
	// 			end
				
	// 		end
	// 		15:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[10];
	// 				mult_a[1] <= inImage1[11];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage1[14];
	// 				mult_a[4] <= inImage1[15];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[10];
	// 				mult_a[1] <= inImage2[11];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage2[14];
	// 				mult_a[4] <= inImage2[15];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[10];
	// 				mult_a[1] <= inImage3[11];
	// 				mult_a[2] <= zero ;
	// 				mult_a[3] <= inImage3[14];
	// 				mult_a[4] <= inImage3[15];
	// 				mult_a[5] <= zero ;
	// 				mult_a[6] <= zero ;
	// 				mult_a[7] <= zero ;
	// 				mult_a[8] <= zero ;	
	// 			end
				
	// 		end 
	// 	endcase
	// end
	// else if(current_state == CAL && !inOpt[1])begin
	// 	case (mult_counter)
	// 		0:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[0];
	// 				mult_a[1] <= inImage1[0];
	// 				mult_a[2] <= inImage1[1];
	// 				mult_a[3] <= inImage1[0];
	// 				mult_a[4] <= inImage1[0];
	// 				mult_a[5] <= inImage1[1];
	// 				mult_a[6] <= inImage1[4];
	// 				mult_a[7] <= inImage1[4];
	// 				mult_a[8] <= inImage1[5];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[0];
	// 				mult_a[1] <= inImage2[0];
	// 				mult_a[2] <= inImage2[1];
	// 				mult_a[3] <= inImage2[0];
	// 				mult_a[4] <= inImage2[0];
	// 				mult_a[5] <= inImage2[1];
	// 				mult_a[6] <= inImage2[4];
	// 				mult_a[7] <= inImage2[4];
	// 				mult_a[8] <= inImage2[5];
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[0];
	// 				mult_a[1] <= inImage3[0];
	// 				mult_a[2] <= inImage3[1];
	// 				mult_a[3] <= inImage3[0];
	// 				mult_a[4] <= inImage3[0];
	// 				mult_a[5] <= inImage3[1];
	// 				mult_a[6] <= inImage3[4];
	// 				mult_a[7] <= inImage3[4];
	// 				mult_a[8] <= inImage3[5];
	// 			end
	// 		end 
	// 		1: begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[0];
	// 				mult_a[1] <= inImage1[1];
	// 				mult_a[2] <= inImage1[2];
	// 				mult_a[3] <= inImage1[0];
	// 				mult_a[4] <= inImage1[1];
	// 				mult_a[5] <= inImage1[2];
	// 				mult_a[6] <= inImage1[4];
	// 				mult_a[7] <= inImage1[5];
	// 				mult_a[8] <= inImage1[6];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[0];
	// 				mult_a[1] <= inImage2[1];
	// 				mult_a[2] <= inImage2[2];
	// 				mult_a[3] <= inImage2[0];
	// 				mult_a[4] <= inImage2[1];
	// 				mult_a[5] <= inImage2[2];
	// 				mult_a[6] <= inImage2[4];
	// 				mult_a[7] <= inImage2[5];
	// 				mult_a[8] <= inImage2[6];
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[0];
	// 				mult_a[1] <= inImage3[1];
	// 				mult_a[2] <= inImage3[2];
	// 				mult_a[3] <= inImage3[0];
	// 				mult_a[4] <= inImage3[1];
	// 				mult_a[5] <= inImage3[2];
	// 				mult_a[6] <= inImage3[4];
	// 				mult_a[7] <= inImage3[5];
	// 				mult_a[8] <= inImage3[6];
	// 			end
	// 		end
	// 		2: begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[1];
	// 				mult_a[1] <= inImage1[2];
	// 				mult_a[2] <= inImage1[3];
	// 				mult_a[3] <= inImage1[1];
	// 				mult_a[4] <= inImage1[2];
	// 				mult_a[5] <= inImage1[3];
	// 				mult_a[6] <= inImage1[5];
	// 				mult_a[7] <= inImage1[6];
	// 				mult_a[8] <= inImage1[7];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[1];
	// 				mult_a[1] <= inImage2[2];
	// 				mult_a[2] <= inImage2[3];
	// 				mult_a[3] <= inImage2[1];
	// 				mult_a[4] <= inImage2[2];
	// 				mult_a[5] <= inImage2[3];
	// 				mult_a[6] <= inImage2[5];
	// 				mult_a[7] <= inImage2[6];
	// 				mult_a[8] <= inImage2[7];
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[1];
	// 				mult_a[1] <= inImage3[2];
	// 				mult_a[2] <= inImage3[3];
	// 				mult_a[3] <= inImage3[1];
	// 				mult_a[4] <= inImage3[2];
	// 				mult_a[5] <= inImage3[3];
	// 				mult_a[6] <= inImage3[5];
	// 				mult_a[7] <= inImage3[6];
	// 				mult_a[8] <= inImage3[7];
	// 			end
				
	// 		end
	// 		3: begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[2];
	// 				mult_a[1] <= inImage1[3];
	// 				mult_a[2] <= inImage1[3];
	// 				mult_a[3] <= inImage1[2];
	// 				mult_a[4] <= inImage1[3];
	// 				mult_a[5] <= inImage1[3];
	// 				mult_a[6] <= inImage1[6];
	// 				mult_a[7] <= inImage1[7];
	// 				mult_a[8] <= inImage1[7];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[2];
	// 				mult_a[1] <= inImage2[3];
	// 				mult_a[2] <= inImage2[3];
	// 				mult_a[3] <= inImage2[2];
	// 				mult_a[4] <= inImage2[3];
	// 				mult_a[5] <= inImage2[3];
	// 				mult_a[6] <= inImage2[6];
	// 				mult_a[7] <= inImage2[7];
	// 				mult_a[8] <= inImage2[7];
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[2];
	// 				mult_a[1] <= inImage3[3];
	// 				mult_a[2] <= inImage3[3];
	// 				mult_a[3] <= inImage3[2];
	// 				mult_a[4] <= inImage3[3];
	// 				mult_a[5] <= inImage3[3];
	// 				mult_a[6] <= inImage3[6];
	// 				mult_a[7] <= inImage3[7];
	// 				mult_a[8] <= inImage3[7];
	// 			end
				
	// 		end
	// 		4:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[0];
	// 				mult_a[1] <= inImage1[0];
	// 				mult_a[2] <= inImage1[1];
	// 				mult_a[3] <= inImage1[4];
	// 				mult_a[4] <= inImage1[4];
	// 				mult_a[5] <= inImage1[5];
	// 				mult_a[6] <= inImage1[8];
	// 				mult_a[7] <= inImage1[8];
	// 				mult_a[8] <= inImage1[9];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[0];
	// 				mult_a[1] <= inImage2[0];
	// 				mult_a[2] <= inImage2[1];
	// 				mult_a[3] <= inImage2[4];
	// 				mult_a[4] <= inImage2[4];
	// 				mult_a[5] <= inImage2[5];
	// 				mult_a[6] <= inImage2[8];
	// 				mult_a[7] <= inImage2[8];
	// 				mult_a[8] <= inImage2[9];
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[0];
	// 				mult_a[1] <= inImage3[0];
	// 				mult_a[2] <= inImage3[1];
	// 				mult_a[3] <= inImage3[4];
	// 				mult_a[4] <= inImage3[4];
	// 				mult_a[5] <= inImage3[5];
	// 				mult_a[6] <= inImage3[8];
	// 				mult_a[7] <= inImage3[8];
	// 				mult_a[8] <= inImage3[9];
	// 			end
				
	// 		end
	// 		5:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[0];
	// 				mult_a[1] <= inImage1[1];
	// 				mult_a[2] <= inImage1[2];
	// 				mult_a[3] <= inImage1[4];
	// 				mult_a[4] <= inImage1[5];
	// 				mult_a[5] <= inImage1[6];
	// 				mult_a[6] <= inImage1[8];
	// 				mult_a[7] <= inImage1[9];
	// 				mult_a[8] <= inImage1[10];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[0];
	// 				mult_a[1] <= inImage2[1];
	// 				mult_a[2] <= inImage2[2];
	// 				mult_a[3] <= inImage2[4];
	// 				mult_a[4] <= inImage2[5];
	// 				mult_a[5] <= inImage2[6];
	// 				mult_a[6] <= inImage2[8];
	// 				mult_a[7] <= inImage2[9];
	// 				mult_a[8] <= inImage2[10];
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[0];
	// 				mult_a[1] <= inImage3[1];
	// 				mult_a[2] <= inImage3[2];
	// 				mult_a[3] <= inImage3[4];
	// 				mult_a[4] <= inImage3[5];
	// 				mult_a[5] <= inImage3[6];
	// 				mult_a[6] <= inImage3[8];
	// 				mult_a[7] <= inImage3[9];
	// 				mult_a[8] <= inImage3[10];
	// 			end
	// 		end
	// 		6:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[1];
	// 				mult_a[1] <= inImage1[2];
	// 				mult_a[2] <= inImage1[3];
	// 				mult_a[3] <= inImage1[5];
	// 				mult_a[4] <= inImage1[6];
	// 				mult_a[5] <= inImage1[7];
	// 				mult_a[6] <= inImage1[9];
	// 				mult_a[7] <= inImage1[10];
	// 				mult_a[8] <= inImage1[11];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[1];
	// 				mult_a[1] <= inImage2[2];
	// 				mult_a[2] <= inImage2[3];
	// 				mult_a[3] <= inImage2[5];
	// 				mult_a[4] <= inImage2[6];
	// 				mult_a[5] <= inImage2[7];
	// 				mult_a[6] <= inImage2[9];
	// 				mult_a[7] <= inImage2[10];
	// 				mult_a[8] <= inImage2[11];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[1];
	// 				mult_a[1] <= inImage3[2];
	// 				mult_a[2] <= inImage3[3];
	// 				mult_a[3] <= inImage3[5];
	// 				mult_a[4] <= inImage3[6];
	// 				mult_a[5] <= inImage3[7];
	// 				mult_a[6] <= inImage3[9];
	// 				mult_a[7] <= inImage3[10];
	// 				mult_a[8] <= inImage3[11];	
	// 			end
				
	// 		end
	// 		7:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[2];
	// 				mult_a[1] <= inImage1[3];
	// 				mult_a[2] <= inImage1[3];
	// 				mult_a[3] <= inImage1[6];
	// 				mult_a[4] <= inImage1[7];
	// 				mult_a[5] <= inImage1[7];
	// 				mult_a[6] <= inImage1[10];
	// 				mult_a[7] <= inImage1[11];
	// 				mult_a[8] <= inImage1[11];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[2];
	// 				mult_a[1] <= inImage2[3];
	// 				mult_a[2] <= inImage2[3];
	// 				mult_a[3] <= inImage2[6];
	// 				mult_a[4] <= inImage2[7];
	// 				mult_a[5] <= inImage2[7];
	// 				mult_a[6] <= inImage2[10];
	// 				mult_a[7] <= inImage2[11];
	// 				mult_a[8] <= inImage2[11];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[2];
	// 				mult_a[1] <= inImage3[3];
	// 				mult_a[2] <= inImage3[3];
	// 				mult_a[3] <= inImage3[6];
	// 				mult_a[4] <= inImage3[7];
	// 				mult_a[5] <= inImage3[7];
	// 				mult_a[6] <= inImage3[10];
	// 				mult_a[7] <= inImage3[11];
	// 				mult_a[8] <= inImage3[11];	
	// 			end
				
	// 		end
	// 		8:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[4];
	// 				mult_a[1] <= inImage1[4];
	// 				mult_a[2] <= inImage1[5];
	// 				mult_a[3] <= inImage1[8];
	// 				mult_a[4] <= inImage1[8];
	// 				mult_a[5] <= inImage1[9];
	// 				mult_a[6] <= inImage1[12];
	// 				mult_a[7] <= inImage1[12];
	// 				mult_a[8] <= inImage1[13];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[4];
	// 				mult_a[1] <= inImage2[4];
	// 				mult_a[2] <= inImage2[5];
	// 				mult_a[3] <= inImage2[8];
	// 				mult_a[4] <= inImage2[8];
	// 				mult_a[5] <= inImage2[9];
	// 				mult_a[6] <= inImage2[12];
	// 				mult_a[7] <= inImage2[12];
	// 				mult_a[8] <= inImage2[13];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[4];
	// 				mult_a[1] <= inImage3[4];
	// 				mult_a[2] <= inImage3[5];
	// 				mult_a[3] <= inImage3[8];
	// 				mult_a[4] <= inImage3[8];
	// 				mult_a[5] <= inImage3[9];
	// 				mult_a[6] <= inImage3[12];
	// 				mult_a[7] <= inImage3[12];
	// 				mult_a[8] <= inImage3[13];	
	// 			end
				
	// 		end
	// 		9:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[4];
	// 				mult_a[1] <= inImage1[5];
	// 				mult_a[2] <= inImage1[6];
	// 				mult_a[3] <= inImage1[8];
	// 				mult_a[4] <= inImage1[9];
	// 				mult_a[5] <= inImage1[10];
	// 				mult_a[6] <= inImage1[12];
	// 				mult_a[7] <= inImage1[13];
	// 				mult_a[8] <= inImage1[14];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[4];
	// 				mult_a[1] <= inImage2[5];
	// 				mult_a[2] <= inImage2[6];
	// 				mult_a[3] <= inImage2[8];
	// 				mult_a[4] <= inImage2[9];
	// 				mult_a[5] <= inImage2[10];
	// 				mult_a[6] <= inImage2[12];
	// 				mult_a[7] <= inImage2[13];
	// 				mult_a[8] <= inImage2[14];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[4];
	// 				mult_a[1] <= inImage3[5];
	// 				mult_a[2] <= inImage3[6];
	// 				mult_a[3] <= inImage3[8];
	// 				mult_a[4] <= inImage3[9];
	// 				mult_a[5] <= inImage3[10];
	// 				mult_a[6] <= inImage3[12];
	// 				mult_a[7] <= inImage3[13];
	// 				mult_a[8] <= inImage3[14];	
	// 			end
	// 		end
	// 		10:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[5];
	// 				mult_a[1] <= inImage1[6];
	// 				mult_a[2] <= inImage1[7];
	// 				mult_a[3] <= inImage1[9];
	// 				mult_a[4] <= inImage1[10];
	// 				mult_a[5] <= inImage1[11];
	// 				mult_a[6] <= inImage1[13];
	// 				mult_a[7] <= inImage1[14];
	// 				mult_a[8] <= inImage1[15];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[5];
	// 				mult_a[1] <= inImage2[6];
	// 				mult_a[2] <= inImage2[7];
	// 				mult_a[3] <= inImage2[9];
	// 				mult_a[4] <= inImage2[10];
	// 				mult_a[5] <= inImage2[11];
	// 				mult_a[6] <= inImage2[13];
	// 				mult_a[7] <= inImage2[14];
	// 				mult_a[8] <= inImage2[15];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[5];
	// 				mult_a[1] <= inImage3[6];
	// 				mult_a[2] <= inImage3[7];
	// 				mult_a[3] <= inImage3[9];
	// 				mult_a[4] <= inImage3[10];
	// 				mult_a[5] <= inImage3[11];
	// 				mult_a[6] <= inImage3[13];
	// 				mult_a[7] <= inImage3[14];
	// 				mult_a[8] <= inImage3[15];	
	// 			end
				
	// 		end
	// 		11:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[6];
	// 				mult_a[1] <= inImage1[7];
	// 				mult_a[2] <= inImage1[7];
	// 				mult_a[3] <= inImage1[10];
	// 				mult_a[4] <= inImage1[11];
	// 				mult_a[5] <= inImage1[11];
	// 				mult_a[6] <= inImage1[14];
	// 				mult_a[7] <= inImage1[15];
	// 				mult_a[8] <= inImage1[15];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[6];
	// 				mult_a[1] <= inImage2[7];
	// 				mult_a[2] <= inImage2[7];
	// 				mult_a[3] <= inImage2[10];
	// 				mult_a[4] <= inImage2[11];
	// 				mult_a[5] <= inImage2[11];
	// 				mult_a[6] <= inImage2[14];
	// 				mult_a[7] <= inImage2[15];
	// 				mult_a[8] <= inImage2[15];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[6];
	// 				mult_a[1] <= inImage3[7];
	// 				mult_a[2] <= inImage3[7];
	// 				mult_a[3] <= inImage3[10];
	// 				mult_a[4] <= inImage3[11];
	// 				mult_a[5] <= inImage3[11];
	// 				mult_a[6] <= inImage3[14];
	// 				mult_a[7] <= inImage3[15];
	// 				mult_a[8] <= inImage3[15];	
	// 			end
				
	// 		end
	// 		12:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[8];
	// 				mult_a[1] <= inImage1[8];
	// 				mult_a[2] <= inImage1[9];
	// 				mult_a[3] <= inImage1[12];
	// 				mult_a[4] <= inImage1[12];
	// 				mult_a[5] <= inImage1[13];
	// 				mult_a[6] <= inImage1[12];
	// 				mult_a[7] <= inImage1[12];
	// 				mult_a[8] <= inImage1[13];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[8];
	// 				mult_a[1] <= inImage2[8];
	// 				mult_a[2] <= inImage2[9];
	// 				mult_a[3] <= inImage2[12];
	// 				mult_a[4] <= inImage2[12];
	// 				mult_a[5] <= inImage2[13];
	// 				mult_a[6] <= inImage2[12];
	// 				mult_a[7] <= inImage2[12];
	// 				mult_a[8] <= inImage2[13];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[8];
	// 				mult_a[1] <= inImage3[8];
	// 				mult_a[2] <= inImage3[9];
	// 				mult_a[3] <= inImage3[12];
	// 				mult_a[4] <= inImage3[12];
	// 				mult_a[5] <= inImage3[13];
	// 				mult_a[6] <= inImage3[12];
	// 				mult_a[7] <= inImage3[12];
	// 				mult_a[8] <= inImage3[13];	
	// 			end
				
	// 		end
	// 		13:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[8];
	// 				mult_a[1] <= inImage1[9];
	// 				mult_a[2] <= inImage1[10];
	// 				mult_a[3] <= inImage1[12];
	// 				mult_a[4] <= inImage1[13];
	// 				mult_a[5] <= inImage1[14];
	// 				mult_a[6] <= inImage1[12];
	// 				mult_a[7] <= inImage1[13];
	// 				mult_a[8] <= inImage1[14];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[8];
	// 				mult_a[1] <= inImage2[9];
	// 				mult_a[2] <= inImage2[10];
	// 				mult_a[3] <= inImage2[12];
	// 				mult_a[4] <= inImage2[13];
	// 				mult_a[5] <= inImage2[14];
	// 				mult_a[6] <= inImage2[12];
	// 				mult_a[7] <= inImage2[13];
	// 				mult_a[8] <= inImage2[14];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[8];
	// 				mult_a[1] <= inImage3[9];
	// 				mult_a[2] <= inImage3[10];
	// 				mult_a[3] <= inImage3[12];
	// 				mult_a[4] <= inImage3[13];
	// 				mult_a[5] <= inImage3[14];
	// 				mult_a[6] <= inImage3[12];
	// 				mult_a[7] <= inImage3[13];
	// 				mult_a[8] <= inImage3[14];	
	// 			end
				
	// 		end
	// 		14:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[9];
	// 				mult_a[1] <= inImage1[10];
	// 				mult_a[2] <= inImage1[11];
	// 				mult_a[3] <= inImage1[13];
	// 				mult_a[4] <= inImage1[14];
	// 				mult_a[5] <= inImage1[15];
	// 				mult_a[6] <= inImage1[13];
	// 				mult_a[7] <= inImage1[14];
	// 				mult_a[8] <= inImage1[15];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[9];
	// 				mult_a[1] <= inImage2[10];
	// 				mult_a[2] <= inImage2[11];
	// 				mult_a[3] <= inImage2[13];
	// 				mult_a[4] <= inImage2[14];
	// 				mult_a[5] <= inImage2[15];
	// 				mult_a[6] <= inImage2[13];
	// 				mult_a[7] <= inImage2[14];
	// 				mult_a[8] <= inImage2[15];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[9];
	// 				mult_a[1] <= inImage3[10];
	// 				mult_a[2] <= inImage3[11];
	// 				mult_a[3] <= inImage3[13];
	// 				mult_a[4] <= inImage3[14];
	// 				mult_a[5] <= inImage3[15];
	// 				mult_a[6] <= inImage3[13];
	// 				mult_a[7] <= inImage3[14];
	// 				mult_a[8] <= inImage3[15];	
	// 			end
				
	// 		end
	// 		15:begin
	// 			if(kernel_counter == 'd0)begin
	// 				mult_a[0] <= inImage1[10];
	// 				mult_a[1] <= inImage1[11];
	// 				mult_a[2] <= inImage1[11];
	// 				mult_a[3] <= inImage1[14];
	// 				mult_a[4] <= inImage1[15];
	// 				mult_a[5] <= inImage1[15];
	// 				mult_a[6] <= inImage1[14];
	// 				mult_a[7] <= inImage1[15];
	// 				mult_a[8] <= inImage1[15];
	// 			end
	// 			else if(kernel_counter == 'd1)begin
	// 				mult_a[0] <= inImage2[10];
	// 				mult_a[1] <= inImage2[11];
	// 				mult_a[2] <= inImage2[11];
	// 				mult_a[3] <= inImage2[14];
	// 				mult_a[4] <= inImage2[15];
	// 				mult_a[5] <= inImage2[15];
	// 				mult_a[6] <= inImage2[14];
	// 				mult_a[7] <= inImage2[15];
	// 				mult_a[8] <= inImage2[15];	
	// 			end
	// 			else begin
	// 				mult_a[0] <= inImage3[10];
	// 				mult_a[1] <= inImage3[11];
	// 				mult_a[2] <= inImage3[11];
	// 				mult_a[3] <= inImage3[14];
	// 				mult_a[4] <= inImage3[15];
	// 				mult_a[5] <= inImage3[15];
	// 				mult_a[6] <= inImage3[14];
	// 				mult_a[7] <= inImage3[15];
	// 				mult_a[8] <= inImage3[15];	
	// 			end
				
	// 		end 
	// 	endcase
	// end
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

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;
parameter inst_arch = 2;


parameter IDLE = 2'b00;
parameter LOAD = 2'b01;
parameter CAL  = 2'b11;
integer i,j;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_i, in_valid_k, in_valid_o;
input [inst_sig_width+inst_exp_width:0] Image1, Image2, Image3;
input [inst_sig_width+inst_exp_width:0] Kernel1, Kernel2, Kernel3;
input [1:0] Opt;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REGISTER DECLARATION
//---------------------------------------------------------------------
reg [1:0] current_state, next_state;

reg [1:0] inOpt;

reg [inst_sig_width+inst_exp_width:0] inImage1 [0:15];
reg [inst_sig_width+inst_exp_width:0] inImage2 [0:15];
reg [inst_sig_width+inst_exp_width:0] inImage3 [0:15];

reg [inst_sig_width+inst_exp_width:0] inKernel1[0:35];
reg [inst_sig_width+inst_exp_width:0] inKernel2[0:35];
reg [inst_sig_width+inst_exp_width:0] inKernel3[0:35];

reg [inst_sig_width+inst_exp_width:0] Output[0:63];
reg [inst_sig_width+inst_exp_width:0] out_temp;

reg [5:0] laod_counter;
reg [3:0] mult_counter;
reg [1:0] layer_counter;
reg [1:0] kernel_counter;
reg [5:0] out_save_counter;
reg [5:0] out_counter;

reg out_flag;

// Use for designware
wire [inst_sig_width+inst_exp_width:0] one, z_one, zero;
assign one   = 32'b00111111100000000000000000000000;
assign z_one = 32'b00111101110011001100110011001101;
assign zero  = 32'b00000000000000000000000000000000;

reg [inst_sig_width+inst_exp_width:0] mult_a[0:8];
reg [inst_sig_width+inst_exp_width:0] mult_b[0:8];
reg [inst_sig_width+inst_exp_width:0] sum_a, sum_b, sum_c;
reg [inst_sig_width+inst_exp_width:0] acti_in;

wire [inst_sig_width+inst_exp_width:0] mult_out[0:8];
wire [inst_sig_width+inst_exp_width:0] cnn_out[0:3];
wire [inst_sig_width+inst_exp_width:0] sum_out;
wire [inst_sig_width+inst_exp_width:0] exp_x, exp_nx;
wire [inst_sig_width+inst_exp_width:0] add_exp_nx, exp_x_sub_exp_nx;
wire [inst_sig_width+inst_exp_width:0] divide;
wire [inst_sig_width+inst_exp_width:0] ReLU_out;
wire [inst_sig_width+inst_exp_width:0] dividend, add_1;
assign dividend = (!inOpt[0])? one: exp_x_sub_exp_nx;
assign add_1 = (!inOpt[0])? one: exp_x;
//---------------------------------------------------------------------
//   IP
//---------------------------------------------------------------------
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M0 (.a(mult_a[0]), .b(mult_b[0]), .rnd(3'b000), .z(mult_out[0]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M1 (.a(mult_a[1]), .b(mult_b[1]), .rnd(3'b000), .z(mult_out[1]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M2 (.a(mult_a[2]), .b(mult_b[2]), .rnd(3'b000), .z(mult_out[2]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M3 (.a(mult_a[3]), .b(mult_b[3]), .rnd(3'b000), .z(mult_out[3]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M4 (.a(mult_a[4]), .b(mult_b[4]), .rnd(3'b000), .z(mult_out[4]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M5 (.a(mult_a[5]), .b(mult_b[5]), .rnd(3'b000), .z(mult_out[5]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M6 (.a(mult_a[6]), .b(mult_b[6]), .rnd(3'b000), .z(mult_out[6]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M7 (.a(mult_a[7]), .b(mult_b[7]), .rnd(3'b000), .z(mult_out[7]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M8 (.a(mult_a[8]), .b(mult_b[8]), .rnd(3'b000), .z(mult_out[8]));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S1 (.a(mult_out[0]), .b(mult_out[1]), .c(mult_out[2]), .z(cnn_out[0]), .rnd(3'b000));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S2 (.a(mult_out[3]), .b(mult_out[4]), .c(mult_out[5]), .z(cnn_out[1]), .rnd(3'b000));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S3 (.a(mult_out[6]), .b(mult_out[7]), .c(mult_out[8]), .z(cnn_out[2]), .rnd(3'b000));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S4 (.a( cnn_out[0]), .b( cnn_out[1]), .c( cnn_out[2]), .z(cnn_out[3]), .rnd(3'b000));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S5 (.a(sum_a), .b(sum_b), .c(sum_c), .z(sum_out), .rnd(3'b000));

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) EXPPX(.a(acti_in), .z(exp_x));
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) EXPNX(.a({~acti_in[31], acti_in[30:0]}), .z(exp_nx));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ADD(.a(add_1), .b(exp_nx), .rnd(3'b000), .z(add_exp_nx));
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) SUB(.a(exp_x), .b(exp_nx), .rnd(3'b000), .z(exp_x_sub_exp_nx));
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance) DIV(.a(dividend), .b(add_exp_nx), .z(divide), .rnd(3'b000));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ReLU (.a(acti_in), .b(z_one), .rnd(3'b000), .z(ReLU_out));
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

// out
always @(*) begin
	case (inOpt)
		'b00: out_temp = (acti_in[31])? zero: acti_in;
		'b01: out_temp = (acti_in[31])? ReLU_out: acti_in; 
		default: out_temp = divide;
	endcase
end

// Opt
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		inOpt <= 'd0;
	end	
	else if(in_valid_o)begin
		inOpt <= Opt; 
	end	
end

// inImage
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		for(i=0; i<16; i=i+1)begin
			inImage1[i] <= 'b0;
			inImage2[i] <= 'b0;
			inImage3[i] <= 'b0;
		end
	end
	else if(in_valid_i)begin
		case (laod_counter)
			0: begin
				inImage1[0] <= Image1; 
				inImage2[0] <= Image2; 
				inImage3[0] <= Image3; 
			end 
			1: begin
				inImage1[1] <= Image1;
				inImage2[1] <= Image2;
				inImage3[1] <= Image3;
			end
			2: begin
				inImage1[2] <= Image1;
				inImage2[2] <= Image2;
				inImage3[2] <= Image3;
			end
			3: begin
				inImage1[3] <= Image1; 
				inImage2[3] <= Image2; 
				inImage3[3] <= Image3; 
			end 
			4: begin
				inImage1[4] <= Image1;
				inImage2[4] <= Image2;
				inImage3[4] <= Image3;
			end
			5: begin
				inImage1[5] <= Image1;
				inImage2[5] <= Image2;
				inImage3[5] <= Image3;
			end
			6: begin
				inImage1[6] <= Image1;
				inImage2[6] <= Image2;
				inImage3[6] <= Image3;
			end
			7: begin
				inImage1[7] <= Image1;
				inImage2[7] <= Image2;
				inImage3[7] <= Image3;
			end
			8: begin
				inImage1[8] <= Image1;
				inImage2[8] <= Image2;
				inImage3[8] <= Image3;
			end
			9: begin
				inImage1[9] <= Image1;
				inImage2[9] <= Image2;
				inImage3[9] <= Image3;
			end
			10: begin
				inImage1[10] <= Image1;
				inImage2[10] <= Image2;
				inImage3[10] <= Image3;
			end
			11: begin
				inImage1[11] <= Image1;
				inImage2[11] <= Image2;
				inImage3[11] <= Image3;
			end
			12: begin
				inImage1[12] <= Image1;
				inImage2[12] <= Image2;
				inImage3[12] <= Image3;
			end
			13: begin
				inImage1[13] <= Image1;
				inImage2[13] <= Image2;
				inImage3[13] <= Image3;
			end
			14: begin
				inImage1[14] <= Image1;
				inImage2[14] <= Image2;
				inImage3[14] <= Image3;
			end
			15: begin
				inImage1[15] <= Image1;
				inImage2[15] <= Image2;
				inImage3[15] <= Image3;
			end		
		endcase
	end
	else if(in_valid_o)begin
		for(i=0; i<16; i=i+1)begin
			inImage1[i] <= 'b0;
			inImage2[i] <= 'b0;
			inImage3[i] <= 'b0;
		end
	end
end

// inKernel
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		for(i=0; i<36; i=i+1)begin
			inKernel1[i] <= 'b0;
			inKernel2[i] <= 'b0;
			inKernel3[i] <= 'b0;
		end
	end
	else if(in_valid_k)begin
		case (laod_counter)
			0:  begin
				inKernel1[0] <= Kernel1;
				inKernel2[0] <= Kernel2;
				inKernel3[0] <= Kernel3; 
			end
			1:  begin
				inKernel1[1] <= Kernel1;
				inKernel2[1] <= Kernel2;
				inKernel3[1] <= Kernel3; 
			end
			2:  begin
				inKernel1[2] <= Kernel1;
				inKernel2[2] <= Kernel2;
				inKernel3[2] <= Kernel3; 
			end
			3:  begin
				inKernel1[3] <= Kernel1;
				inKernel2[3] <= Kernel2;
				inKernel3[3] <= Kernel3; 
			end
			4:  begin
				inKernel1[4] <= Kernel1;
				inKernel2[4] <= Kernel2;
				inKernel3[4] <= Kernel3; 
			end
			5:  begin
				inKernel1[5] <= Kernel1;
				inKernel2[5] <= Kernel2;
				inKernel3[5] <= Kernel3; 
			end
			6:  begin
				inKernel1[6] <= Kernel1;
				inKernel2[6] <= Kernel2;
				inKernel3[6] <= Kernel3; 
			end
			7:  begin
				inKernel1[7] <= Kernel1;
				inKernel2[7] <= Kernel2;
				inKernel3[7] <= Kernel3; 
			end
			8:  begin
				inKernel1[8] <= Kernel1;
				inKernel2[8] <= Kernel2;
				inKernel3[8] <= Kernel3; 
			end
			9:  begin
				inKernel1[9] <= Kernel1;
				inKernel2[9] <= Kernel2;
				inKernel3[9] <= Kernel3; 
			end
			10: begin
				inKernel1[10] <= Kernel1;
				inKernel2[10] <= Kernel2;
				inKernel3[10] <= Kernel3; 
			end
			11: begin
				inKernel1[11] <= Kernel1;
				inKernel2[11] <= Kernel2;
				inKernel3[11] <= Kernel3; 
			end
			12: begin
				inKernel1[12] <= Kernel1;
				inKernel2[12] <= Kernel2;
				inKernel3[12] <= Kernel3; 
			end
			13: begin
				inKernel1[13] <= Kernel1;
				inKernel2[13] <= Kernel2;
				inKernel3[13] <= Kernel3; 
			end
			14: begin
				inKernel1[14] <= Kernel1;
				inKernel2[14] <= Kernel2;
				inKernel3[14] <= Kernel3; 
			end
			15: begin
				inKernel1[15] <= Kernel1;
				inKernel2[15] <= Kernel2;
				inKernel3[15] <= Kernel3; 
			end
			16: begin
				inKernel1[16] <= Kernel1;
				inKernel2[16] <= Kernel2;
				inKernel3[16] <= Kernel3; 
			end
			17: begin
				inKernel1[17] <= Kernel1;
				inKernel2[17] <= Kernel2;
				inKernel3[17] <= Kernel3; 
			end
			18: begin
				inKernel1[18] <= Kernel1;
				inKernel2[18] <= Kernel2;
				inKernel3[18] <= Kernel3; 
			end
			19: begin
				inKernel1[19] <= Kernel1;
				inKernel2[19] <= Kernel2;
				inKernel3[19] <= Kernel3; 
			end
			20: begin
				inKernel1[20] <= Kernel1;
				inKernel2[20] <= Kernel2;
				inKernel3[20] <= Kernel3; 
			end
			21: begin
				inKernel1[21] <= Kernel1;
				inKernel2[21] <= Kernel2;
				inKernel3[21] <= Kernel3; 
			end
			22: begin
				inKernel1[22] <= Kernel1;
				inKernel2[22] <= Kernel2;
				inKernel3[22] <= Kernel3; 
			end
			23: begin
				inKernel1[23] <= Kernel1;
				inKernel2[23] <= Kernel2;
				inKernel3[23] <= Kernel3; 
			end
			24: begin
				inKernel1[24] <= Kernel1;
				inKernel2[24] <= Kernel2;
				inKernel3[24] <= Kernel3; 
			end
			25: begin
				inKernel1[25] <= Kernel1;
				inKernel2[25] <= Kernel2;
				inKernel3[25] <= Kernel3; 
			end
			26: begin
				inKernel1[26] <= Kernel1;
				inKernel2[26] <= Kernel2;
				inKernel3[26] <= Kernel3; 
			end
			27: begin
				inKernel1[27] <= Kernel1;
				inKernel2[27] <= Kernel2;
				inKernel3[27] <= Kernel3; 
			end
			28: begin
				inKernel1[28] <= Kernel1;
				inKernel2[28] <= Kernel2;
				inKernel3[28] <= Kernel3; 
			end
			29: begin
				inKernel1[29] <= Kernel1;
				inKernel2[29] <= Kernel2;
				inKernel3[29] <= Kernel3; 
			end
			30: begin
				inKernel1[30] <= Kernel1;
				inKernel2[30] <= Kernel2;
				inKernel3[30] <= Kernel3; 
			end
			31: begin
				inKernel1[31] <= Kernel1;
				inKernel2[31] <= Kernel2;
				inKernel3[31] <= Kernel3; 
			end
			32: begin
				inKernel1[32] <= Kernel1;
				inKernel2[32] <= Kernel2;
				inKernel3[32] <= Kernel3; 
			end
			33: begin
				inKernel1[33] <= Kernel1;
				inKernel2[33] <= Kernel2;
				inKernel3[33] <= Kernel3; 
			end
			34: begin
				inKernel1[34] <= Kernel1;
				inKernel2[34] <= Kernel2;
				inKernel3[34] <= Kernel3; 
			end
			35: begin
				inKernel1[35] <= Kernel1;
				inKernel2[35] <= Kernel2;
				inKernel3[35] <= Kernel3; 
			end
		endcase   
	end
end

// load counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) laod_counter <= 'd0;
	else if(in_valid_i || in_valid_k) laod_counter <= laod_counter + 'd1;
	else laod_counter <= 'd0;
end

// mult counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) mult_counter <= 'd0;
	else if(current_state == CAL) begin
		if(kernel_counter == 'd2) begin
			if(mult_counter == 'd15) mult_counter <= 'd0;
			else mult_counter <= mult_counter + 'd1;
		end
		else mult_counter <= mult_counter;
	end 
	else mult_counter <= 'd0;
end

// kernel counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) kernel_counter <= 'd0;
	else if(current_state == CAL) kernel_counter <= (kernel_counter =='d2)? 'd0: kernel_counter + 'd1;
	else kernel_counter <= 'd0;
end

// out save counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) out_save_counter <= 'd0;
	else if(current_state == CAL) out_save_counter <= (kernel_counter == 'd2)? out_save_counter + 'd1: out_save_counter;
	else out_save_counter <= 'd0;
end

// layer counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) layer_counter <= 'd0;
	else if(current_state == CAL) begin
		if(mult_counter == 'd15 && kernel_counter == 'd2) begin
			layer_counter <= layer_counter + 'd1;
		end 
	end
	else layer_counter <= 'd0;
end

// out counter
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) out_counter <= 'd0;
	else if(out_flag) begin
		out_counter <= out_counter + 'd1;
	end
	else out_counter <= 'd0;
end

// out flag
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) out_flag <= 'd0;
	else if(out_save_counter == 'd51) out_flag <= 'd1;
	else if(out_counter == 'd63) out_flag <= 'd0;
	else out_flag <= out_flag;
end

// mult_a
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mult_a[0] <= 'd0;
		mult_a[1] <= 'd0;
		mult_a[2] <= 'd0;
		mult_a[3] <= 'd0;
		mult_a[4] <= 'd0;
		mult_a[5] <= 'd0;
		mult_a[6] <= 'd0;
		mult_a[7] <= 'd0;
		mult_a[8] <= 'd0;
	end
	else if(current_state == CAL)begin
		case (mult_counter)
			0:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= (inOpt[1])? zero: inImage1[0];
					mult_a[1] <= (inOpt[1])? zero: inImage1[0];
					mult_a[2] <= (inOpt[1])? zero: inImage1[1];
					mult_a[3] <= (inOpt[1])? zero: inImage1[0];
					mult_a[4] <= inImage1[0];
					mult_a[5] <= inImage1[1];
					mult_a[6] <= (inOpt[1])? zero: inImage1[4];
					mult_a[7] <= inImage1[4];
					mult_a[8] <= inImage1[5];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= (inOpt[1])? zero: inImage2[0];
					mult_a[1] <= (inOpt[1])? zero: inImage2[0];
					mult_a[2] <= (inOpt[1])? zero: inImage2[1];
					mult_a[3] <= (inOpt[1])? zero: inImage2[0];
					mult_a[4] <= inImage2[0];
					mult_a[5] <= inImage2[1];
					mult_a[6] <= (inOpt[1])? zero: inImage2[4];
					mult_a[7] <= inImage2[4];
					mult_a[8] <= inImage2[5];
				end
				else begin
					mult_a[0] <= (inOpt[1])? zero: inImage3[0];
					mult_a[1] <= (inOpt[1])? zero: inImage3[0];
					mult_a[2] <= (inOpt[1])? zero: inImage3[1];
					mult_a[3] <= (inOpt[1])? zero: inImage3[0];
					mult_a[4] <= inImage3[0];
					mult_a[5] <= inImage3[1];
					mult_a[6] <= (inOpt[1])? zero: inImage3[4];
					mult_a[7] <= inImage3[4];
					mult_a[8] <= inImage3[5];
				end
			end 
			1: begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= (inOpt[1])? zero: inImage1[0];
					mult_a[1] <= (inOpt[1])? zero: inImage1[1];
					mult_a[2] <= (inOpt[1])? zero: inImage1[2];
					mult_a[3] <= inImage1[0];
					mult_a[4] <= inImage1[1];
					mult_a[5] <= inImage1[2];
					mult_a[6] <= inImage1[4];
					mult_a[7] <= inImage1[5];
					mult_a[8] <= inImage1[6];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= (inOpt[1])? zero: inImage2[0];
					mult_a[1] <= (inOpt[1])? zero: inImage2[1];
					mult_a[2] <= (inOpt[1])? zero: inImage2[2];
					mult_a[3] <= inImage2[0];
					mult_a[4] <= inImage2[1];
					mult_a[5] <= inImage2[2];
					mult_a[6] <= inImage2[4];
					mult_a[7] <= inImage2[5];
					mult_a[8] <= inImage2[6];
				end
				else begin
					mult_a[0] <= (inOpt[1])? zero: inImage3[0];
					mult_a[1] <= (inOpt[1])? zero: inImage3[1];
					mult_a[2] <= (inOpt[1])? zero: inImage3[2];
					mult_a[3] <= inImage3[0];
					mult_a[4] <= inImage3[1];
					mult_a[5] <= inImage3[2];
					mult_a[6] <= inImage3[4];
					mult_a[7] <= inImage3[5];
					mult_a[8] <= inImage3[6];
				end
			end
			2: begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= (inOpt[1])? zero: inImage1[1];
					mult_a[1] <= (inOpt[1])? zero: inImage1[2];
					mult_a[2] <= (inOpt[1])? zero: inImage1[3];
					mult_a[3] <= inImage1[1];
					mult_a[4] <= inImage1[2];
					mult_a[5] <= inImage1[3];
					mult_a[6] <= inImage1[5];
					mult_a[7] <= inImage1[6];
					mult_a[8] <= inImage1[7];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= (inOpt[1])? zero: inImage2[1];
					mult_a[1] <= (inOpt[1])? zero: inImage2[2];
					mult_a[2] <= (inOpt[1])? zero: inImage2[3];
					mult_a[3] <= inImage2[1];
					mult_a[4] <= inImage2[2];
					mult_a[5] <= inImage2[3];
					mult_a[6] <= inImage2[5];
					mult_a[7] <= inImage2[6];
					mult_a[8] <= inImage2[7];
				end
				else begin
					mult_a[0] <= (inOpt[1])? zero: inImage3[1];
					mult_a[1] <= (inOpt[1])? zero: inImage3[2];
					mult_a[2] <= (inOpt[1])? zero: inImage3[3];
					mult_a[3] <= inImage3[1];
					mult_a[4] <= inImage3[2];
					mult_a[5] <= inImage3[3];
					mult_a[6] <= inImage3[5];
					mult_a[7] <= inImage3[6];
					mult_a[8] <= inImage3[7];
				end
				
			end
			3: begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= (inOpt[1])? zero: inImage1[2];
					mult_a[1] <= (inOpt[1])? zero: inImage1[3];
					mult_a[2] <= (inOpt[1])? zero: inImage1[3];
					mult_a[3] <= inImage1[2];
					mult_a[4] <= inImage1[3];
					mult_a[5] <= (inOpt[1])? zero: inImage1[3];
					mult_a[6] <= inImage1[6];
					mult_a[7] <= inImage1[7];
					mult_a[8] <= (inOpt[1])? zero: inImage1[7];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= (inOpt[1])? zero: inImage2[2];
					mult_a[1] <= (inOpt[1])? zero: inImage2[3];
					mult_a[2] <= (inOpt[1])? zero: inImage2[3];
					mult_a[3] <= inImage2[2];
					mult_a[4] <= inImage2[3];
					mult_a[5] <= (inOpt[1])? zero: inImage2[3];
					mult_a[6] <= inImage2[6];
					mult_a[7] <= inImage2[7];
					mult_a[8] <= (inOpt[1])? zero: inImage2[7];
				end
				else begin
					mult_a[0] <= (inOpt[1])? zero: inImage3[2];
					mult_a[1] <= (inOpt[1])? zero: inImage3[3];
					mult_a[2] <= (inOpt[1])? zero: inImage3[3];
					mult_a[3] <= inImage3[2];
					mult_a[4] <= inImage3[3];
					mult_a[5] <= (inOpt[1])? zero: inImage3[3];
					mult_a[6] <= inImage3[6];
					mult_a[7] <= inImage3[7];
					mult_a[8] <= (inOpt[1])? zero: inImage3[7];
				end
				
			end
			4:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= (inOpt[1])? zero: inImage1[0];
					mult_a[1] <= inImage1[0];
					mult_a[2] <= inImage1[1];
					mult_a[3] <= (inOpt[1])? zero: inImage1[4];
					mult_a[4] <= inImage1[4];
					mult_a[5] <= inImage1[5];
					mult_a[6] <= (inOpt[1])? zero: inImage1[8];
					mult_a[7] <= inImage1[8];
					mult_a[8] <= inImage1[9];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= (inOpt[1])? zero: inImage2[0];
					mult_a[1] <= inImage2[0];
					mult_a[2] <= inImage2[1];
					mult_a[3] <= (inOpt[1])? zero: inImage2[4];
					mult_a[4] <= inImage2[4];
					mult_a[5] <= inImage2[5];
					mult_a[6] <= (inOpt[1])? zero: inImage2[8];
					mult_a[7] <= inImage2[8];
					mult_a[8] <= inImage2[9];
				end
				else begin
					mult_a[0] <= (inOpt[1])? zero: inImage3[0];
					mult_a[1] <= inImage3[0];
					mult_a[2] <= inImage3[1];
					mult_a[3] <= (inOpt[1])? zero: inImage3[4];
					mult_a[4] <= inImage3[4];
					mult_a[5] <= inImage3[5];
					mult_a[6] <= (inOpt[1])? zero: inImage3[8];
					mult_a[7] <= inImage3[8];
					mult_a[8] <= inImage3[9];
				end
				
			end
			5:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[0];
					mult_a[1] <= inImage1[1];
					mult_a[2] <= inImage1[2];
					mult_a[3] <= inImage1[4];
					mult_a[4] <= inImage1[5];
					mult_a[5] <= inImage1[6];
					mult_a[6] <= inImage1[8];
					mult_a[7] <= inImage1[9];
					mult_a[8] <= inImage1[10];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[0];
					mult_a[1] <= inImage2[1];
					mult_a[2] <= inImage2[2];
					mult_a[3] <= inImage2[4];
					mult_a[4] <= inImage2[5];
					mult_a[5] <= inImage2[6];
					mult_a[6] <= inImage2[8];
					mult_a[7] <= inImage2[9];
					mult_a[8] <= inImage2[10];
				end
				else begin
					mult_a[0] <= inImage3[0];
					mult_a[1] <= inImage3[1];
					mult_a[2] <= inImage3[2];
					mult_a[3] <= inImage3[4];
					mult_a[4] <= inImage3[5];
					mult_a[5] <= inImage3[6];
					mult_a[6] <= inImage3[8];
					mult_a[7] <= inImage3[9];
					mult_a[8] <= inImage3[10];
				end
			end
			6:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[1];
					mult_a[1] <= inImage1[2];
					mult_a[2] <= inImage1[3];
					mult_a[3] <= inImage1[5];
					mult_a[4] <= inImage1[6];
					mult_a[5] <= inImage1[7];
					mult_a[6] <= inImage1[9];
					mult_a[7] <= inImage1[10];
					mult_a[8] <= inImage1[11];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[1];
					mult_a[1] <= inImage2[2];
					mult_a[2] <= inImage2[3];
					mult_a[3] <= inImage2[5];
					mult_a[4] <= inImage2[6];
					mult_a[5] <= inImage2[7];
					mult_a[6] <= inImage2[9];
					mult_a[7] <= inImage2[10];
					mult_a[8] <= inImage2[11];	
				end
				else begin
					mult_a[0] <= inImage3[1];
					mult_a[1] <= inImage3[2];
					mult_a[2] <= inImage3[3];
					mult_a[3] <= inImage3[5];
					mult_a[4] <= inImage3[6];
					mult_a[5] <= inImage3[7];
					mult_a[6] <= inImage3[9];
					mult_a[7] <= inImage3[10];
					mult_a[8] <= inImage3[11];	
				end
				
			end
			7:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[2];
					mult_a[1] <= inImage1[3];
					mult_a[2] <= (inOpt[1])? zero: inImage1[3];
					mult_a[3] <= inImage1[6];
					mult_a[4] <= inImage1[7];
					mult_a[5] <= (inOpt[1])? zero: inImage1[7];
					mult_a[6] <= inImage1[10];
					mult_a[7] <= inImage1[11];
					mult_a[8] <= (inOpt[1])? zero: inImage1[11];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[2];
					mult_a[1] <= inImage2[3];
					mult_a[2] <= (inOpt[1])? zero: inImage2[3];
					mult_a[3] <= inImage2[6];
					mult_a[4] <= inImage2[7];
					mult_a[5] <= (inOpt[1])? zero: inImage2[7];
					mult_a[6] <= inImage2[10];
					mult_a[7] <= inImage2[11];
					mult_a[8] <= (inOpt[1])? zero: inImage2[11];	
				end
				else begin
					mult_a[0] <= inImage3[2];
					mult_a[1] <= inImage3[3];
					mult_a[2] <= (inOpt[1])? zero: inImage3[3];
					mult_a[3] <= inImage3[6];
					mult_a[4] <= inImage3[7];
					mult_a[5] <= (inOpt[1])? zero: inImage3[7];
					mult_a[6] <= inImage3[10];
					mult_a[7] <= inImage3[11];
					mult_a[8] <= (inOpt[1])? zero: inImage3[11];	
				end
				
			end
			8:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= (inOpt[1])? zero: inImage1[4];
					mult_a[1] <= inImage1[4];
					mult_a[2] <= inImage1[5];
					mult_a[3] <= (inOpt[1])? zero: inImage1[8];
					mult_a[4] <= inImage1[8];
					mult_a[5] <= inImage1[9];
					mult_a[6] <= (inOpt[1])? zero: inImage1[12];
					mult_a[7] <= inImage1[12];
					mult_a[8] <= inImage1[13];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= (inOpt[1])? zero: inImage2[4];
					mult_a[1] <= inImage2[4];
					mult_a[2] <= inImage2[5];
					mult_a[3] <= (inOpt[1])? zero: inImage2[8];
					mult_a[4] <= inImage2[8];
					mult_a[5] <= inImage2[9];
					mult_a[6] <= (inOpt[1])? zero: inImage2[12];
					mult_a[7] <= inImage2[12];
					mult_a[8] <= inImage2[13];	
				end
				else begin
					mult_a[0] <= (inOpt[1])? zero: inImage3[4];
					mult_a[1] <= inImage3[4];
					mult_a[2] <= inImage3[5];
					mult_a[3] <= (inOpt[1])? zero: inImage3[8];
					mult_a[4] <= inImage3[8];
					mult_a[5] <= inImage3[9];
					mult_a[6] <= (inOpt[1])? zero: inImage3[12];
					mult_a[7] <= inImage3[12];
					mult_a[8] <= inImage3[13];	
				end
				
			end
			9:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[4];
					mult_a[1] <= inImage1[5];
					mult_a[2] <= inImage1[6];
					mult_a[3] <= inImage1[8];
					mult_a[4] <= inImage1[9];
					mult_a[5] <= inImage1[10];
					mult_a[6] <= inImage1[12];
					mult_a[7] <= inImage1[13];
					mult_a[8] <= inImage1[14];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[4];
					mult_a[1] <= inImage2[5];
					mult_a[2] <= inImage2[6];
					mult_a[3] <= inImage2[8];
					mult_a[4] <= inImage2[9];
					mult_a[5] <= inImage2[10];
					mult_a[6] <= inImage2[12];
					mult_a[7] <= inImage2[13];
					mult_a[8] <= inImage2[14];	
				end
				else begin
					mult_a[0] <= inImage3[4];
					mult_a[1] <= inImage3[5];
					mult_a[2] <= inImage3[6];
					mult_a[3] <= inImage3[8];
					mult_a[4] <= inImage3[9];
					mult_a[5] <= inImage3[10];
					mult_a[6] <= inImage3[12];
					mult_a[7] <= inImage3[13];
					mult_a[8] <= inImage3[14];	
				end
			end
			10:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[5];
					mult_a[1] <= inImage1[6];
					mult_a[2] <= inImage1[7];
					mult_a[3] <= inImage1[9];
					mult_a[4] <= inImage1[10];
					mult_a[5] <= inImage1[11];
					mult_a[6] <= inImage1[13];
					mult_a[7] <= inImage1[14];
					mult_a[8] <= inImage1[15];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[5];
					mult_a[1] <= inImage2[6];
					mult_a[2] <= inImage2[7];
					mult_a[3] <= inImage2[9];
					mult_a[4] <= inImage2[10];
					mult_a[5] <= inImage2[11];
					mult_a[6] <= inImage2[13];
					mult_a[7] <= inImage2[14];
					mult_a[8] <= inImage2[15];	
				end
				else begin
					mult_a[0] <= inImage3[5];
					mult_a[1] <= inImage3[6];
					mult_a[2] <= inImage3[7];
					mult_a[3] <= inImage3[9];
					mult_a[4] <= inImage3[10];
					mult_a[5] <= inImage3[11];
					mult_a[6] <= inImage3[13];
					mult_a[7] <= inImage3[14];
					mult_a[8] <= inImage3[15];	
				end
				
			end
			11:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[6];
					mult_a[1] <= inImage1[7];
					mult_a[2] <= (inOpt[1])? zero: inImage1[7];
					mult_a[3] <= inImage1[10];
					mult_a[4] <= inImage1[11];
					mult_a[5] <= (inOpt[1])? zero: inImage1[11];
					mult_a[6] <= inImage1[14];
					mult_a[7] <= inImage1[15];
					mult_a[8] <= (inOpt[1])? zero: inImage1[15];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[6];
					mult_a[1] <= inImage2[7];
					mult_a[2] <= (inOpt[1])? zero: inImage2[7];
					mult_a[3] <= inImage2[10];
					mult_a[4] <= inImage2[11];
					mult_a[5] <= (inOpt[1])? zero: inImage2[11];
					mult_a[6] <= inImage2[14];
					mult_a[7] <= inImage2[15];
					mult_a[8] <= (inOpt[1])? zero: inImage2[15];	
				end
				else begin
					mult_a[0] <= inImage3[6];
					mult_a[1] <= inImage3[7];
					mult_a[2] <= (inOpt[1])? zero: inImage3[7];
					mult_a[3] <= inImage3[10];
					mult_a[4] <= inImage3[11];
					mult_a[5] <= (inOpt[1])? zero: inImage3[11];
					mult_a[6] <= inImage3[14];
					mult_a[7] <= inImage3[15];
					mult_a[8] <= (inOpt[1])? zero: inImage3[15];	
				end
				
			end
			12:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= (inOpt[1])? zero: inImage1[8];
					mult_a[1] <= inImage1[8];
					mult_a[2] <= inImage1[9];
					mult_a[3] <= (inOpt[1])? zero: inImage1[12];
					mult_a[4] <= inImage1[12];
					mult_a[5] <= inImage1[13];
					mult_a[6] <= (inOpt[1])? zero: inImage1[12];
					mult_a[7] <= (inOpt[1])? zero: inImage1[12];
					mult_a[8] <= (inOpt[1])? zero: inImage1[13];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= (inOpt[1])? zero: inImage2[8];
					mult_a[1] <= inImage2[8];
					mult_a[2] <= inImage2[9];
					mult_a[3] <= (inOpt[1])? zero: inImage2[12];
					mult_a[4] <= inImage2[12];
					mult_a[5] <= inImage2[13];
					mult_a[6] <= (inOpt[1])? zero: inImage2[12];
					mult_a[7] <= (inOpt[1])? zero: inImage2[12];
					mult_a[8] <= (inOpt[1])? zero: inImage2[13];	
				end
				else begin
					mult_a[0] <= (inOpt[1])? zero: inImage3[8];
					mult_a[1] <= inImage3[8];
					mult_a[2] <= inImage3[9];
					mult_a[3] <= (inOpt[1])? zero: inImage3[12];
					mult_a[4] <= inImage3[12];
					mult_a[5] <= inImage3[13];
					mult_a[6] <= (inOpt[1])? zero: inImage3[12];
					mult_a[7] <= (inOpt[1])? zero: inImage3[12];
					mult_a[8] <= (inOpt[1])? zero: inImage3[13];	
				end
				
			end
			13:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[8];
					mult_a[1] <= inImage1[9];
					mult_a[2] <= inImage1[10];
					mult_a[3] <= inImage1[12];
					mult_a[4] <= inImage1[13];
					mult_a[5] <= inImage1[14];
					mult_a[6] <= (inOpt[1])? zero: inImage1[12];
					mult_a[7] <= (inOpt[1])? zero: inImage1[13];
					mult_a[8] <= (inOpt[1])? zero: inImage1[14];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[8];
					mult_a[1] <= inImage2[9];
					mult_a[2] <= inImage2[10];
					mult_a[3] <= inImage2[12];
					mult_a[4] <= inImage2[13];
					mult_a[5] <= inImage2[14];
					mult_a[6] <= (inOpt[1])? zero: inImage2[12];
					mult_a[7] <= (inOpt[1])? zero: inImage2[13];
					mult_a[8] <= (inOpt[1])? zero: inImage2[14];	
				end
				else begin
					mult_a[0] <= inImage3[8];
					mult_a[1] <= inImage3[9];
					mult_a[2] <= inImage3[10];
					mult_a[3] <= inImage3[12];
					mult_a[4] <= inImage3[13];
					mult_a[5] <= inImage3[14];
					mult_a[6] <= (inOpt[1])? zero: inImage3[12];
					mult_a[7] <= (inOpt[1])? zero: inImage3[13];
					mult_a[8] <= (inOpt[1])? zero: inImage3[14];	
				end
				
			end
			14:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[9];
					mult_a[1] <= inImage1[10];
					mult_a[2] <= inImage1[11];
					mult_a[3] <= inImage1[13];
					mult_a[4] <= inImage1[14];
					mult_a[5] <= inImage1[15];
					mult_a[6] <= (inOpt[1])? zero: inImage1[13];
					mult_a[7] <= (inOpt[1])? zero: inImage1[14];
					mult_a[8] <= (inOpt[1])? zero: inImage1[15];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[9];
					mult_a[1] <= inImage2[10];
					mult_a[2] <= inImage2[11];
					mult_a[3] <= inImage2[13];
					mult_a[4] <= inImage2[14];
					mult_a[5] <= inImage2[15];
					mult_a[6] <= (inOpt[1])? zero: inImage2[13];
					mult_a[7] <= (inOpt[1])? zero: inImage2[14];
					mult_a[8] <= (inOpt[1])? zero: inImage2[15];	
				end
				else begin
					mult_a[0] <= inImage3[9];
					mult_a[1] <= inImage3[10];
					mult_a[2] <= inImage3[11];
					mult_a[3] <= inImage3[13];
					mult_a[4] <= inImage3[14];
					mult_a[5] <= inImage3[15];
					mult_a[6] <= (inOpt[1])? zero: inImage3[13];
					mult_a[7] <= (inOpt[1])? zero: inImage3[14];
					mult_a[8] <= (inOpt[1])? zero: inImage3[15];	
				end
				
			end
			15:begin
				if(kernel_counter == 'd0)begin
					mult_a[0] <= inImage1[10];
					mult_a[1] <= inImage1[11];
					mult_a[2] <= (inOpt[1])? zero: inImage1[11];
					mult_a[3] <= inImage1[14];
					mult_a[4] <= inImage1[15];
					mult_a[5] <= (inOpt[1])? zero: inImage1[15];
					mult_a[6] <= (inOpt[1])? zero: inImage1[14];
					mult_a[7] <= (inOpt[1])? zero: inImage1[15];
					mult_a[8] <= (inOpt[1])? zero: inImage1[15];
				end
				else if(kernel_counter == 'd1)begin
					mult_a[0] <= inImage2[10];
					mult_a[1] <= inImage2[11];
					mult_a[2] <= (inOpt[1])? zero: inImage2[11];
					mult_a[3] <= inImage2[14];
					mult_a[4] <= inImage2[15];
					mult_a[5] <= (inOpt[1])? zero: inImage2[15];
					mult_a[6] <= (inOpt[1])? zero: inImage2[14];
					mult_a[7] <= (inOpt[1])? zero: inImage2[15];
					mult_a[8] <= (inOpt[1])? zero: inImage2[15];	
				end
				else begin
					mult_a[0] <= inImage3[10];
					mult_a[1] <= inImage3[11];
					mult_a[2] <= (inOpt[1])? zero: inImage3[11];
					mult_a[3] <= inImage3[14];
					mult_a[4] <= inImage3[15];
					mult_a[5] <= (inOpt[1])? zero: inImage3[15];
					mult_a[6] <= (inOpt[1])? zero: inImage3[14];
					mult_a[7] <= (inOpt[1])? zero: inImage3[15];
					mult_a[8] <= (inOpt[1])? zero: inImage3[15];	
				end
				
			end 
		endcase
	end
	else begin
		mult_a[0] <= 'd0;
		mult_a[1] <= 'd0;
		mult_a[2] <= 'd0;
		mult_a[3] <= 'd0;
		mult_a[4] <= 'd0;
		mult_a[5] <= 'd0;
		mult_a[6] <= 'd0;
		mult_a[7] <= 'd0;
		mult_a[8] <= 'd0;
	end
end

// mult_b
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mult_b[0] <= 'd0;
		mult_b[1] <= 'd0;
		mult_b[2] <= 'd0;
		mult_b[3] <= 'd0;
		mult_b[4] <= 'd0;
		mult_b[5] <= 'd0;
		mult_b[6] <= 'd0;
		mult_b[7] <= 'd0;
		mult_b[8] <= 'd0;
	end
	else if(current_state == CAL)begin
		case({layer_counter,kernel_counter})
		4'b0000:begin
			mult_b[0] <= inKernel1[0];
			mult_b[1] <= inKernel1[1];
			mult_b[2] <= inKernel1[2];
			mult_b[3] <= inKernel1[3];
			mult_b[4] <= inKernel1[4];
			mult_b[5] <= inKernel1[5];
			mult_b[6] <= inKernel1[6];
			mult_b[7] <= inKernel1[7];
			mult_b[8] <= inKernel1[8];
		end
		4'b0001:begin
			mult_b[0] <= inKernel2[0];
			mult_b[1] <= inKernel2[1];
			mult_b[2] <= inKernel2[2];
			mult_b[3] <= inKernel2[3];
			mult_b[4] <= inKernel2[4];
			mult_b[5] <= inKernel2[5];
			mult_b[6] <= inKernel2[6];
			mult_b[7] <= inKernel2[7];
			mult_b[8] <= inKernel2[8];
		end
		4'b0010:begin
			mult_b[0] <= inKernel3[0];
			mult_b[1] <= inKernel3[1];
			mult_b[2] <= inKernel3[2];
			mult_b[3] <= inKernel3[3];
			mult_b[4] <= inKernel3[4];
			mult_b[5] <= inKernel3[5];
			mult_b[6] <= inKernel3[6];
			mult_b[7] <= inKernel3[7];
			mult_b[8] <= inKernel3[8];
		end
		4'b0100:begin
			mult_b[0] <= inKernel1[ 9];
			mult_b[1] <= inKernel1[10];
			mult_b[2] <= inKernel1[11];
			mult_b[3] <= inKernel1[12];
			mult_b[4] <= inKernel1[13];
			mult_b[5] <= inKernel1[14];
			mult_b[6] <= inKernel1[15];
			mult_b[7] <= inKernel1[16];
			mult_b[8] <= inKernel1[17];
		end
		4'b0101:begin
			mult_b[0] <= inKernel2[ 9];
			mult_b[1] <= inKernel2[10];
			mult_b[2] <= inKernel2[11];
			mult_b[3] <= inKernel2[12];
			mult_b[4] <= inKernel2[13];
			mult_b[5] <= inKernel2[14];
			mult_b[6] <= inKernel2[15];
			mult_b[7] <= inKernel2[16];
			mult_b[8] <= inKernel2[17];
		end
		4'b0110:begin
			mult_b[0] <= inKernel3[ 9];
			mult_b[1] <= inKernel3[10];
			mult_b[2] <= inKernel3[11];
			mult_b[3] <= inKernel3[12];
			mult_b[4] <= inKernel3[13];
			mult_b[5] <= inKernel3[14];
			mult_b[6] <= inKernel3[15];
			mult_b[7] <= inKernel3[16];
			mult_b[8] <= inKernel3[17];
		end
		4'b1000:begin
			mult_b[0] <= inKernel1[18];
			mult_b[1] <= inKernel1[19];
			mult_b[2] <= inKernel1[20];
			mult_b[3] <= inKernel1[21];
			mult_b[4] <= inKernel1[22];
			mult_b[5] <= inKernel1[23];
			mult_b[6] <= inKernel1[24];
			mult_b[7] <= inKernel1[25];
			mult_b[8] <= inKernel1[26];
		end
		4'b1001:begin
			mult_b[0] <= inKernel2[18];
			mult_b[1] <= inKernel2[19];
			mult_b[2] <= inKernel2[20];
			mult_b[3] <= inKernel2[21];
			mult_b[4] <= inKernel2[22];
			mult_b[5] <= inKernel2[23];
			mult_b[6] <= inKernel2[24];
			mult_b[7] <= inKernel2[25];
			mult_b[8] <= inKernel2[26];
		end
		4'b1010:begin
			mult_b[0] <= inKernel3[18];
			mult_b[1] <= inKernel3[19];
			mult_b[2] <= inKernel3[20];
			mult_b[3] <= inKernel3[21];
			mult_b[4] <= inKernel3[22];
			mult_b[5] <= inKernel3[23];
			mult_b[6] <= inKernel3[24];
			mult_b[7] <= inKernel3[25];
			mult_b[8] <= inKernel3[26];
		end
		4'b1100:begin
			mult_b[0] <= inKernel1[27];
			mult_b[1] <= inKernel1[28];
			mult_b[2] <= inKernel1[29];
			mult_b[3] <= inKernel1[30];
			mult_b[4] <= inKernel1[31];
			mult_b[5] <= inKernel1[32];
			mult_b[6] <= inKernel1[33];
			mult_b[7] <= inKernel1[34];
			mult_b[8] <= inKernel1[35];
		end
		4'b1101:begin
			mult_b[0] <= inKernel2[27];
			mult_b[1] <= inKernel2[28];
			mult_b[2] <= inKernel2[29];
			mult_b[3] <= inKernel2[30];
			mult_b[4] <= inKernel2[31];
			mult_b[5] <= inKernel2[32];
			mult_b[6] <= inKernel2[33];
			mult_b[7] <= inKernel2[34];
			mult_b[8] <= inKernel2[35];
		end
		4'b1110:begin
			mult_b[0] <= inKernel3[27];
			mult_b[1] <= inKernel3[28];
			mult_b[2] <= inKernel3[29];
			mult_b[3] <= inKernel3[30];
			mult_b[4] <= inKernel3[31];
			mult_b[5] <= inKernel3[32];
			mult_b[6] <= inKernel3[33];
			mult_b[7] <= inKernel3[34];
			mult_b[8] <= inKernel3[35];
		end
		default:begin
			mult_b[0] <= mult_b[0];
			mult_b[1] <= mult_b[1];
			mult_b[2] <= mult_b[2];
			mult_b[3] <= mult_b[3];
			mult_b[4] <= mult_b[4];
			mult_b[5] <= mult_b[5];
			mult_b[6] <= mult_b[6];
			mult_b[7] <= mult_b[7];
			mult_b[8] <= mult_b[8];
		end
		endcase
	end
	else begin
		mult_b[0] <= 'd0;
		mult_b[1] <= 'd0;
		mult_b[2] <= 'd0;
		mult_b[3] <= 'd0;
		mult_b[4] <= 'd0;
		mult_b[5] <= 'd0;
		mult_b[6] <= 'd0;
		mult_b[7] <= 'd0;
		mult_b[8] <= 'd0;
	end
end

// sum a b c
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) sum_a <= 'd0;
	else if(current_state == CAL) begin
		sum_a <= (kernel_counter == 'd1)? cnn_out[3] : sum_a;
	end
	else sum_a <= 'd0;
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) sum_b <= 'd0;
	else if(current_state == CAL) begin
		sum_b <= (kernel_counter == 'd2)? cnn_out[3] : sum_b;
	end
	else sum_b <= 'd0;
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) sum_c <= 'd0;
	else if(current_state == CAL) begin
		sum_c <= (kernel_counter == 'd0)? cnn_out[3] : sum_c;
	end
	else sum_c <= 'd0;
end

// Output reg
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for (i=0; i<64; i=i+1) begin
			Output[i] <= 'd0;
		end
	end 
	else if(current_state == CAL && kernel_counter == 'd2 ) begin
		// if(out_save_counter == 'd0) Output[63] <= out_temp;
		// Output[out_save_counter -'d1] <= out_temp;
		case (out_save_counter)
			0 : Output[63] <= out_temp;
			1 : Output[0] <= out_temp;	
			2 : Output[2] <= out_temp;
			3 : Output[4] <= out_temp;
			4 : Output[6] <= out_temp;
			5 : Output[16] <= out_temp;
			6 : Output[18] <= out_temp;
			7 : Output[20] <= out_temp;
			8 : Output[22] <= out_temp;
			9 : Output[32] <= out_temp;
			10: Output[34] <= out_temp;
			11: Output[36] <= out_temp;
			12: Output[38] <= out_temp;
			13: Output[48] <= out_temp;
			14: Output[50] <= out_temp;
			15: Output[52] <= out_temp;
			16: Output[54] <= out_temp;
			17: Output[1] <= out_temp;
			18: Output[3] <= out_temp;
			19: Output[5] <= out_temp;
			20: Output[7] <= out_temp;
			21: Output[17] <= out_temp;
			22: Output[19] <= out_temp;
			23: Output[21] <= out_temp;
			24: Output[23] <= out_temp;
			25: Output[33] <= out_temp;
			26: Output[35] <= out_temp;
			27: Output[37] <= out_temp;
			28: Output[39] <= out_temp;
			29: Output[49] <= out_temp;
			30: Output[51] <= out_temp;
			31: Output[53] <= out_temp;
			32: Output[55] <= out_temp;
			33: Output[8] <= out_temp;
			34: Output[10] <= out_temp;
			35: Output[12] <= out_temp;
			36: Output[14] <= out_temp;
			37: Output[24] <= out_temp;
			38: Output[26] <= out_temp;
			39: Output[28] <= out_temp;
			40: Output[30] <= out_temp;
			41: Output[40] <= out_temp;
			42: Output[42] <= out_temp;
			43: Output[44] <= out_temp;
			44: Output[46] <= out_temp;
			45: Output[56] <= out_temp;
			46: Output[58] <= out_temp;
			47: Output[60] <= out_temp;
			48: Output[62] <= out_temp;
			49: Output[9] <= out_temp;
			50: Output[11] <= out_temp;
			51: Output[13] <= out_temp;
			52: Output[15] <= out_temp;
			53: Output[25] <= out_temp;
			54: Output[27] <= out_temp;
			55: Output[29] <= out_temp;
			56: Output[31] <= out_temp;
			57: Output[41] <= out_temp;
			58: Output[43] <= out_temp;
			59: Output[45] <= out_temp;
			60: Output[47] <= out_temp;
			61: Output[57] <= out_temp;
			62: Output[59] <= out_temp;
			63: Output[61] <= out_temp;				
		endcase
	end
end

// Activation input
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		acti_in <= 'd0;
	end 
	else if(current_state == CAL) begin
		acti_in <= sum_out;
	end
end
//---------------------------------------------------------------------
//   Finite State Machine
//---------------------------------------------------------------------
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
            IDLE  : next_state = (!in_valid_o)? IDLE : LOAD;
			LOAD  : next_state = (laod_counter == 'd8 && in_valid_k)? CAL:LOAD;
			CAL   : next_state = (out_counter == 'd40)? IDLE:CAL;
			default: next_state = IDLE;
        endcase
    end
end

// Output Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out <= 32'b0;
	else if(out_flag) begin
		out <= Output[out_counter];
		// case (out_counter)
		// 	0 : out <= Output[ 0];
		// 	1 : out <= Output[16];
		// 	2 : out <= Output[ 1];
		// 	3 : out <= Output[17];
		// 	4 : out <= Output[ 2];
		// 	5 : out <= Output[18];
		// 	6 : out <= Output[ 3];
		// 	7 : out <= Output[19]; 
		// 	8 : out <= Output[32];
		// 	9 : out <= Output[48];
		// 	10: out <= Output[33];
		// 	11: out <= Output[49];
		// 	12: out <= Output[34];
		// 	13: out <= Output[50];
		// 	14: out <= Output[35];
		// 	15: out <= Output[51];
		// 	16: out <= Output[ 4];
		// 	17: out <= Output[20];
		// 	18: out <= Output[ 5];
		// 	19: out <= Output[21];
		// 	20: out <= Output[ 6];
		// 	21: out <= Output[22];
		// 	22: out <= Output[ 7];
		// 	23: out <= Output[23];  
		// 	24: out <= Output[36];
		// 	25: out <= Output[52];
		// 	26: out <= Output[37];
		// 	27: out <= Output[53];
		// 	28: out <= Output[38];
		// 	29: out <= Output[54];
		// 	30: out <= Output[39];
		// 	31: out <= Output[55];
		// 	32: out <= Output[ 8];
		// 	33: out <= Output[24];
		// 	34: out <= Output[ 9];
		// 	35: out <= Output[25];
		// 	36: out <= Output[10];
		// 	37: out <= Output[26];
		// 	38: out <= Output[11];
		// 	39: out <= Output[27];
		// 	40: out <= Output[40];
		// 	41: out <= Output[56];
		// 	42: out <= Output[41];
		// 	43: out <= Output[57];
		// 	44: out <= Output[42];
		// 	45: out <= Output[58];
		// 	46: out <= Output[43];
		// 	47: out <= Output[59];
		// 	48: out <= Output[12];
		// 	49: out <= Output[28];
		// 	50: out <= Output[13];
		// 	51: out <= Output[29];
		// 	52: out <= Output[14];
		// 	53: out <= Output[30];
		// 	54: out <= Output[15];
		// 	55: out <= Output[31];
		// 	56: out <= Output[44];
		// 	57: out <= Output[60];
		// 	58: out <= Output[45];
		// 	59: out <= Output[61];
		// 	60: out <= Output[46];
		// 	61: out <= Output[62];
		// 	62: out <= Output[47];
		// 	63: out <= Output[63];
		// endcase
	end
	else out <= 32'b0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) out_valid <= 'd0;
	else if(out_flag) out_valid <= 'd1;
	else out_valid <= 'd0; 
end

endmodule