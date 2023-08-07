//----------------------------------------------------------------------------------------------------------
//	FILE: 		signal_mux.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	
//	Warning:	
//	DESCRIBE:	This is testbench file that will generater tri_wave in 8-bits formula
// 	KEYWORDS:	fpga, basic module, DSP....
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.7.12		create
//-----------------------------------------------------------------------------------------------------------
module signal_mux(
	input		en,
	input		[9:0]	input_signalA,
	input		[9:0]	input_signalB,

	output		[9:0]	output_signal
);


assign output_signal =(en ==1'b0) ?input_signalA:input_signalB;
endmodule