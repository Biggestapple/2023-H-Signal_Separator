//----------------------------------------------------------------------------------------------------------
//	FILE: 		phase_adjust.v
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
module phase_adjust(
	input		clk,
	input		sys_rst_n,
	
	input		[9:0]	input_signal,
	output		[9:0]	output_signal,
	
	input		butt_phase_down,
	input		butt_phase_up,
	
	input		butt_phase_clr					//Clear the register contents
);

wire	butt_phase_down_o;
wire	butt_phase_up_o;

reg			butt_phase_up_1,butt_phase_up_2;	
reg			butt_phase_down_1,butt_phase_down_2;	

reg	[8:0]		OUTPHASE;
parameter		PHASEFACTER		=16'd365;
integer			index;

reg	[9:0]	signal_shiftR[PHASEFACTER-1:0];
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		for(index =0;index <PHASEFACTER;index =index +1) begin
			signal_shiftR[index] <='d0;
		end
	end
	else begin
		signal_shiftR[0] <=input_signal;
		for(index =0;index <PHASEFACTER -1;index =index +1) begin
			signal_shiftR[index +1] <=signal_shiftR[index];
		end
	end

assign output_signal =signal_shiftR[OUTPHASE-1];
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		OUTPHASE <='d256;
	end
	else begin
		if(~butt_phase_down_o &&butt_phase_up_o && !butt_phase_clr)
			OUTPHASE <=OUTPHASE +'d2; 
		else if(butt_phase_down_o &&~butt_phase_up_o && !butt_phase_clr)
			OUTPHASE <=OUTPHASE -'d2;  
		else if (butt_phase_clr)
			OUTPHASE <='d256;
		else begin
			OUTPHASE <=OUTPHASE;
		end
	end

always @(posedge clk or negedge sys_rst_n) 
if(!sys_rst_n)begin
	butt_phase_down_1 <=1'b0;
	butt_phase_down_2 <=1'b0;
	
	butt_phase_up_1 <=1'b0;
	butt_phase_up_2 <=1'b0;
end
else begin
	butt_phase_down_1 <=butt_phase_down;
	butt_phase_down_2 <=butt_phase_down_1;
	
	butt_phase_up_1 <=butt_phase_up;
	butt_phase_up_2 <=butt_phase_up_1;
end

assign butt_phase_down_o =(butt_phase_down_2 &&~butt_phase_down_1);
assign butt_phase_up_o =(butt_phase_up_2 &&~butt_phase_up_1);	
endmodule