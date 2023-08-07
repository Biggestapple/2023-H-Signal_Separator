`timescale 1ns/1ps
//----------------------------------------------------------------------------------------------------------
//	FILE: 		top.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.7.25			create
//								2023.8.5			update:Standard naming...
//-----------------------------------------------------------------------------------------------------------
module top(
	

	input		sys_clk,
	
	//This signal is created by DDS module
	input		sys_rst_n,
	
	input		[9:0]		i_adc,
	output		oe,
	output		adc_clk,
	
	input		[9:0]		i_adc_dds,
	output		oe_dds,
	output		adc_dds_clk,
	
	output		dac_clk,
	output		[9:0]		o_dac,
	
	output		dacP_clk,
	output		[9:0]		o_dacP,
	
	
	//input		en_tri,						
	
	//Enable the tri_wave output
	input		phaseUpA,
	input		phaseDownA
	//input		phaseClrA
	
	
);
wire	en_tri;
wire	phaseClrA;
assign en_tri =1'b0;
assign phaseClrA =1'b0;

wire	 	[9:0]	adc_data;
wire	 	[9:0]	adc_dds_data;

wire	 	[9:0]	dac_data;
wire		[9:0]	la_filter_data;
wire		[9:0]	sin_to_tri_data;

wire		[9:0]	dacP_data;
wire		[9:0]	dacPMM_data;

(*KEEP="TRUE"*)	wire		[63:0]	sum;
(*KEEP="TRUE"*)	wire		[9:0]		mean_sum;
adc	adc_dutO(
	.clk			(sys_clk),
	
	.i_data			(i_adc),
	.o_data			(adc_data),
	
	.adc_clk		(adc_clk),
	.oe				(oe)
);

adc	adc_dutDds(
	.clk			(sys_clk),
	
	.i_data			(i_adc_dds),
	.o_data			(adc_dds_data),
	
	.adc_clk		(adc_dds_clk),
	.oe				(oe_dds)
);

dac	dac_dut(
	.clk			(sys_clk),
	
	.i_data			(dac_data),
	.o_data			(o_dac),
	
	.dac_clk			(dac_clk)
);

la_filter la_filter_dut(
	.clk			(sys_clk),
	.sys_rst_n		(sys_rst_n),
	
	
	//This is a test project not for any "real use"
	.input_signal	(adc_data),
	.sigmaS_out		(la_filter_data),
	
	.sum			(sum)
);


dac	dac_dutPhase(
	.clk			(sys_clk),
	
	.i_data			(dacPMM_data),
	.o_data			(o_dacP),
	
	.dac_clk		(dacP_clk)
);

phase_adjust phase_adjust_dut(
	.clk			(sys_clk),
	.sys_rst_n		(sys_rst_n),
	
	.input_signal	(adc_data),
	.output_signal	(dacP_data),
	
	.butt_phase_down(phaseUpA),
	.butt_phase_up	(phaseDownA),
	.butt_phase_clr	(phaseClrA)

);
sin_to_tri	sin_to_tri_dut(
	.clk			(sys_clk),
	.sys_rst_n		(sys_rst_n),
	
	.input_signal	(la_filter_data),
	.o_signal		(sin_to_tri_data),
	.mean_sum		(mean_sum)
);


//The stream signal selected...
signal_mux	signal_mux_dut(
	.en				(en_tri),
	.input_signalA	(la_filter_data),
	.input_signalB	(sin_to_tri_data),

	.output_signal	(dac_data)
	
);

b_rescue b_rescue_dut(
	.clk			(sys_clk),
	.sys_rst_n		(sys_rst_n),
	
	.rv_signal		(la_filter_data),
	.input_signalA	(dacP_data),
	.dds_input		(adc_dds_data),
	
	.dds_shift		(dacPMM_data)
);

endmodule