module bridge(input clk, INF.bridge_inf inf);


//================================================================
// AXI read 
//================================================================
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)                        inf.AR_ADDR <= 0 ;
    else if(inf.C_in_valid && inf.C_r_wb) inf.AR_ADDR <= {1'b1 , 5'b0, inf.C_addr,3'd0};
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)                          inf.AR_VALID <= 0;
    else if(inf.C_in_valid && inf.C_r_wb)   inf.AR_VALID <= 1;
    else if(inf.AR_READY)                   inf.AR_VALID <= 0;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)        inf.R_READY <= 0;
    else if(inf.AR_READY) inf.R_READY <= 1;
    else if(inf.R_VALID)  inf.R_READY <= 0;
end


always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)       inf.C_data_r <= 0 ;
    else if(inf.R_VALID) inf.C_data_r <= inf.R_DATA;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)                      inf.C_out_valid <= 0 ;
    else if(inf.B_VALID || inf.R_VALID) inf.C_out_valid <= 1;
    else inf.C_out_valid <= 0 ;
end
//================================================================
// AXI write 
//================================================================
always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)                         inf.AW_ADDR <= 0 ;
    else if(inf.C_in_valid && !inf.C_r_wb) inf.AW_ADDR <= {1'b1 , 5'b0, inf.C_addr,3'd0};
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)                         inf.AW_VALID <= 0;
    else if(inf.C_in_valid && !inf.C_r_wb) inf.AW_VALID <= 1;
    else if(inf.AW_READY)                  inf.AW_VALID <= 0;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)        inf.W_VALID <= 0;
    else if(inf.AW_READY) inf.W_VALID <= 1;
    else if(inf.W_READY)  inf.W_VALID <= 0;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)        inf.B_READY <= 0;
    else if(inf.AW_READY) inf.B_READY <= 1;
    else if(inf.B_VALID)  inf.B_READY <= 0;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)                         inf.W_DATA <= 0 ;
    else if(inf.C_in_valid && !inf.C_r_wb) inf.W_DATA <= inf.C_data_w;
end

endmodule