module CHIP(
  // input signals
  clk,
  rst_n,
  in_valid,
  in_image,
  // output signals
  out_valid,
  out_image
);

input clk;
input rst_n;
input in_valid;
input [7:0] in_image;

output out_valid;
output [7:0] out_image;

//==================PARAMETER=====================//
// genvar i;

//==================Wire & Register===================//
wire        C_clk;
wire        C_rst_n;
wire        C_in_valid;
wire [7:0]  C_in_image;

wire        C_out_valid;
wire [7:0]  C_out_image;

//TA has already defined for you
//LBP module

LBP LBP(
  .clk(C_clk),
  .rst_n(C_rst_n),
  .in_valid(C_in_valid),
  .in_image(C_in_image),
  .out_valid(C_out_valid),
  .out_image(C_out_image)
);

// input pads
P8C I_CLK         (.Y(C_clk),           .P(clk),          .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C I_RST_N       (.Y(C_rst_n),         .P(rst_n),        .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_VALID    (.Y(C_in_valid),      .P(in_valid),     .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_IMAGE_0  (.Y(C_in_image[0]),   .P(in_image[0]),  .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_IMAGE_1  (.Y(C_in_image[1]),   .P(in_image[1]),  .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_IMAGE_2  (.Y(C_in_image[2]),   .P(in_image[2]),  .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_IMAGE_3  (.Y(C_in_image[3]),   .P(in_image[3]),  .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_IMAGE_4  (.Y(C_in_image[4]),   .P(in_image[4]),  .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_IMAGE_5  (.Y(C_in_image[5]),   .P(in_image[5]),  .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_IMAGE_6  (.Y(C_in_image[6]),   .P(in_image[6]),  .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P4C I_IN_IMAGE_7  (.Y(C_in_image[7]),   .P(in_image[7]),  .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
// generate
//   for (i=0; i<8; i=i+1) begin
//     P4C I_IN_IMAGE  (.Y(C_in_image[i]),  .P(in_image[i]), .A(1'b0), .ODEN(1'b0),  .OCEN(1'b0),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
//   end
// endgenerate

// output pads
P8C O_OUT_VALID   (.A(C_out_valid),     .P(out_valid),    .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_IMAGE_0 (.A(C_out_image[0]),  .P(out_image[0]), .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_IMAGE_1 (.A(C_out_image[1]),  .P(out_image[1]), .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_IMAGE_2 (.A(C_out_image[2]),  .P(out_image[2]), .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_IMAGE_3 (.A(C_out_image[3]),  .P(out_image[3]), .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_IMAGE_4 (.A(C_out_image[4]),  .P(out_image[4]), .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_IMAGE_5 (.A(C_out_image[5]),  .P(out_image[5]), .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_IMAGE_6 (.A(C_out_image[6]),  .P(out_image[6]), .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_IMAGE_7 (.A(C_out_image[7]),  .P(out_image[7]), .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
// generate
//   for (i=0; i<8; i=i+1) begin
//     P8C O_OUT_IMAGE (.A(C_out_image[i]), .P(out_image[i]),  .ODEN(1'b1),  .OCEN(1'b1),  .PU(1'b1),  .PD(1'b0),  .CEN(1'b1), .CSEN(1'b0));
//   end
// endgenerate

//I/O power 3.3V pads x? (DVDD + DGND)
PVDDR VDDP0 ();
PVSSR GNDP0 ();
PVDDR VDDP1 ();
PVSSR GNDP1 ();
PVDDR VDDP2 ();
PVSSR GNDP2 ();
PVDDR VDDP3 ();
PVSSR GNDP3 ();
// PVDDR VDDP4 ();
// PVSSR GNDP4 ();
// PVDDR VDDP5 ();
// PVSSR GNDP5 ();
// PVDDR VDDP6 ();
// PVSSR GNDP6 ();
// PVDDR VDDP7 ();
// PVSSR GNDP7 ();

//Core poweri 1.8V pads x? (VDD + GND)
PVDDC VDDC0 ();
PVSSC GNDC0 ();
PVDDC VDDC1 ();
PVSSC GNDC1 ();
PVDDC VDDC2 ();
PVSSC GNDC2 ();
PVDDC VDDC3 ();
PVSSC GNDC3 ();

// Pad: VDDP0
// Pad: GNDP0
// Pad: VDDP1
// Pad: GNDP1
// Pad: VDDP2
// Pad: GNDP2
// Pad: VDDP3
// Pad: GNDP3

// Pad: VDDC0
// Pad: GNDC0
// Pad: VDDC1
// Pad: GNDC1
// Pad: VDDC2
// Pad: GNDC2
// Pad: VDDC3
// Pad: GNDC3

// Pad: I_CLK
// Pad: I_RST_N
// Pad: I_IN_VALID
// Pad: I_IN_IMAGE_0
// Pad: I_IN_IMAGE_1
// Pad: I_IN_IMAGE_2
// Pad: I_IN_IMAGE_3
// Pad: I_IN_IMAGE_4
// Pad: I_IN_IMAGE_5
// Pad: I_IN_IMAGE_6
// Pad: I_IN_IMAGE_7

// Pad: O_OUT_VALID
// Pad: O_OUT_IMAGE_0
// Pad: O_OUT_IMAGE_1
// Pad: O_OUT_IMAGE_2
// Pad: O_OUT_IMAGE_3
// Pad: O_OUT_IMAGE_4
// Pad: O_OUT_IMAGE_5
// Pad: O_OUT_IMAGE_6
// Pad: O_OUT_IMAGE_7


endmodule

