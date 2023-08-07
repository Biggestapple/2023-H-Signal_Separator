//----------------------------------------------------------------------------------------------------------
//	FILE: 		sin_to_tri.v
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
module sin_to_tri(
	input		clk,
	input		sys_rst_n,
	
	input		[9:0]	input_signal,
	output	reg	[9:0]	o_signal,
	output		[9:0]	mean_sum

);
reg		[9:0]	input_signalA;
reg		[9:0]	input_signalN;
reg		[9:0]	input_signalF;

reg		[9:0]	max_e;
reg		[9:0]	min_e;

reg		[9:0]	st_dy;
reg		[9:0]	end_dy;
always @(posedge clk or negedge sys_rst_n) 
	if(!sys_rst_n) begin
		input_signalA <='d0;
		input_signalN <='d0;
		input_signalF <='d0;
	end
	else begin
		input_signalF <=input_signal; 
		input_signalN <=input_signalF;
		input_signalA <=input_signalN;
	end
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		max_e <='d0;
		min_e <='d0;
	end
	else if(st_dy ==10'd512) begin
		if(end_dy !=10'd1022)
			end_dy <=end_dy +1'b1;
		else
			end_dy <=end_dy;
		
		
		if((input_signalN >input_signalF || input_signalN >input_signalA )&&max_e <= input_signalN &&end_dy !=10'd1022)
			max_e <=input_signalN;
		else if((input_signalN<input_signalF || input_signalN<input_signalA )&&min_e >= input_signalN &&end_dy !=10'd1022)
			min_e <=input_signalN;
		else begin
			max_e <=max_e;
			min_e <=min_e;
		end
	end
	else begin
		max_e <=max_e;
		min_e <=min_e;
	end
	
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n)
		st_dy <='d0;
	else if(st_dy !=10'd512) 
		st_dy <=st_dy +1'b1;
	else
		st_dy <=st_dy;

assign mean_sum =(max_e +min_e) >1;
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) 
		o_signal <='d0;
	else if(input_signal >=mean_sum)
		o_signal <=o_signal +1'b1;
	else if(input_signal <mean_sum)
		o_signal <=o_signal -1'b1;
	else
		o_signal <=o_signal;
	
endmodule