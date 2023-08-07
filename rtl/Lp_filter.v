//----------------------------------------------------------------------------------------------------------
//	FILE: 		Lp_filter.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.8.6			create
//													Final_Tb
//-----------------------------------------------------------------------------------------------------------
module lp_filter(
	input			clk,
	input			sys_rst_n,
	
	
	//This is a test project not for any "real use"
	input		signed	[9:0]	input_Refsignal,
	input		signed	[9:0]	input_Sigsignal,
	
	output		adjust
);
	//Pll error_up module --By IP core

wire	signed [19:0]	o_p_multi;
	multix10b multix10b_dut(
	.clk		(clk), 
	.a			(input_Refsignal), 
	.b			(input_Sigsignal), 
	.p			(o_p_multi)
);

localparam	THOLD_AD	=32'h00ff_1111;
	//Unsigned...
	//Adding these vector --32_stages
signed reg	[19:0]	xi			[31:0]	;
signed reg	[27:0]	sum32_to_4	[3:0]	;
signed reg	[31:0]	sum4_to_1			;
unsigned wire	sum4_to_1_abs;
reg	[3:0]	delay_cnt;							//Adding trees delay

integer	reg_index;
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		for(reg_index =0;reg_index <32;reg_index =reg_index +1) begin
			xi[reg_index] <='d0;
		end
		
		delay_cnt <=4'd0;						//Adjustable
	end
	else begin
		if(delay_cnt ==4'd1) begin
			delay_cnt <=4'd0;
		//Ultra_long shift_reg
			xi[0] <=o_p_multi;
			for(reg_index =0;reg_index <31;reg_index =reg_index +1) begin
				xi[reg_index +1] <=xi[reg_index];
			end
		end
		else
			delay_cnt <=delay_cnt +1'b1;
	end

	//Low_pass filters

always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		sum32_to_4[0] <='d0;
		sum32_to_4[1] <='d0;
		sum32_to_4[2] <='d0;
		sum32_to_4[3] <='d0;
	end
	else begin
		sum32_to_4[0] <=xi[0] +xi[1] +xi[2] +xi[3] +xi[4] +xi[5] +xi[6] +xi[7];
		sum32_to_4[1] <=xi[8] +xi[9] +xi[10] +xi[11] +xi[12] +xi[13] +xi[14] +xi[15];
		sum32_to_4[2] <=xi[16] +xi[17] +xi[18] +xi[19] +xi[20] +xi[21] +xi[22] +xi[23];
		sum32_to_4[3] <=xi[24] +xi[25] +xi[26] +xi[27] +xi[28] +xi[29] +xi[30] +xi[31];
	end

always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		sum4_to_1 <='d0;
	end
	else begin
		sum4_to_1 <=sum32_to_4[0] +sum32_to_4[1] +sum32_to_4[2] +sum32_to_4[3];
	end

assign sum4_to_1_abs =(sum4_to_1[31] ==1'b0) ?sum4_to_1 :~sum4_to_1+1'b1;
assign adjust =(sum4_to_1_abs>=THOLD_AD);
endmodule