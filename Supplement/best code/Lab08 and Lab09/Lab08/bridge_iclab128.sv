module bridge(input clk, INF.bridge_inf inf);

//================================================================
// logic 
//================================================================
logic [10:0] addr ; 
logic [7 :0] id   ;
//================================================================
// design 
//================================================================

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.AW_VALID <= 'd0 ; 
	end else if (inf.AW_READY && inf.AW_VALID)begin
		inf.AW_VALID <= 'd0 ; 
	end else if (inf.C_in_valid && inf.C_r_wb == 'd0 )begin
		inf.AW_VALID <= 'd1 ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.AR_VALID <= 'd0 ; 
	end else if (inf.AR_READY && inf.AR_VALID)begin
		inf.AR_VALID <= 'd0 ; 
	end else if (inf.C_in_valid && inf.C_r_wb == 'd1 )begin
		inf.AR_VALID <= 'd1 ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		id <= 'd0 ; 
	end else if (inf.C_in_valid)begin
		id <= inf.C_addr ; 
	end
end

assign addr = id * 'd8 ; 


always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.AW_ADDR <= 'd0 ; 
	end else begin
		inf.AW_ADDR <=  {1'b1 , 5'b0 , addr} ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.AR_ADDR <= 'd0 ; 
	end else  begin
		inf.AR_ADDR <=  {1'b1 , 5'b0 , addr} ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.B_READY <= 'd0 ; 
	end else  begin
		inf.B_READY <=  'd1 ; 
	end
end

// assign inf.R_READY = (!inf.rst_n) ? 'd0 : 
					 // (inf.R_VALID)? 'd0 : 'd1 ; 
					 
always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.W_VALID <= 'd0 ; 
	end else  begin
		inf.W_VALID <=  'd1 ; 
	end
end


always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.W_DATA <= 'd0 ; 
	end else if (inf.C_in_valid)begin
		inf.W_DATA <= inf.C_data_w ; 
	end
end

// assign inf.W_DATA  = inf.C_data_w ; 

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.R_READY  <= 'd0 ; 
	end else if (inf.R_VALID )begin
		inf.R_READY  <= 'd1  ; 
	end else begin
		inf.R_READY  <= 'd0 ; 
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.C_out_valid <= 'd0 ;
	end else if ( (inf.R_VALID && !inf.R_READY ) || (inf.B_VALID && inf.B_READY) )begin
		inf.C_out_valid <= 'd1 ;
	end else begin
		inf.C_out_valid <= 'd0 ;
	end
end

always_ff@(posedge clk , negedge inf.rst_n)begin
	if (!inf.rst_n)begin
		inf.C_data_r	<= 'd0 ;
	end else if (inf.R_VALID)begin
		inf.C_data_r	<= inf.R_DATA ;
	end
end
// assign inf.C_data_r = (!inf.rst_n)? 0 : inf.R_DATA ; 







endmodule