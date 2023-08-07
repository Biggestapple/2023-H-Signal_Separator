//----------------------------------------------------------------------------------------------------------
//	FILE: 		adc.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.7.25			create
//													Adding:DC_BIAS parameter
//-----------------------------------------------------------------------------------------------------------
module adc(
	input			clk,
	
	input	[9:0]	i_data,
	output	[9:0]	o_data,
	
	output			adc_clk,
	output	oe
);
parameter	DC_BIAS =10'd380;

wire	adc_clk_oddr;
assign 	adc_clk_oddr=~clk;
assign oe =1'b0;
ODDR2 #(
      .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
      .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
      .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
   ) ODDR2_inst (
      .Q(adc_clk),   // 1-bit DDR output data
      .C0(adc_clk_oddr),   // 1-bit clock input
      .C1(~adc_clk_oddr),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D0(1'b1), // 1-bit data input (associated with C0)
      .D1(1'b0), // 1-bit data input (associated with C1)
      .R(1'b0),   // 1-bit reset input
      .S(1'b0)    // 1-bit set input
   );

assign o_data =i_data -DC_BIAS;
endmodule