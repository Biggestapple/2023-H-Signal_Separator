//----------------------------------------------------------------------------------------------------------
//	FILE: 		La_filter.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.7.25			create
//													Final_Tb
//-----------------------------------------------------------------------------------------------------------
module la_filter(
	input			clk,
	input			sys_rst_n,
	
	
	//This is a test project not for any "real use"
	input			[9:0]	input_signal,
	output			[9:0]	sigmaS_out,
	
	output			[63:0]	sum
);
reg	[9:0]	xi[0:127];
reg	[63:0]	sum;
reg	[31:0]	sum128_to_16[0:15];
reg	[31:0]	sum16_to_4[0:3];
reg	[3:0]	delay_cnt;							//Adding trees delay

integer	reg_index;
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		for(reg_index =0;reg_index <128;reg_index =reg_index +1) begin
			xi[reg_index] <='d0;
		end
		
		delay_cnt <=3'd0;
	end
	else begin
		if(delay_cnt ==3'd2) begin
			delay_cnt <=3'd0;
		//Ultra_long shift_reg
			xi[0] <=input_signal;
			for(reg_index =0;reg_index <127;reg_index =reg_index +1) begin
				xi[reg_index +1] <=xi[reg_index];
			end
		end
		else
			delay_cnt <=delay_cnt +1'b1;
	end


always @(posedge clk or negedge sys_rst_n)		//Adding trees construction
	if(!sys_rst_n) begin
		for(reg_index =0;reg_index <16;reg_index =reg_index +1) begin
			sum128_to_16[reg_index] <='d0;
		end
	end
	else begin
		for(reg_index =0;reg_index <16;reg_index =reg_index +1) begin
			sum128_to_16[reg_index] <=xi[reg_index*8]+xi[reg_index*8+1]+xi[reg_index*8+2]+xi[reg_index*8+3]
				+xi[reg_index*8+4]+xi[reg_index*8+5]+xi[reg_index*8+6]+xi[reg_index*8+7];
		end
	end
always @(posedge clk or negedge sys_rst_n)		//Final adding trees
	if(!sys_rst_n) begin
		for(reg_index =0;reg_index <4;reg_index =reg_index +1) begin
			sum16_to_4[reg_index] <='d0;
		end
	end
	else begin
		for(reg_index =0;reg_index <4;reg_index =reg_index +1) begin
			sum16_to_4[reg_index] <=sum128_to_16[4*reg_index] +sum128_to_16[4*reg_index+1] 
				+sum128_to_16[4*reg_index+2] +sum128_to_16[4*reg_index+3];
		end
	end

always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n)
		sum <='d0;
	else 
		sum <=sum16_to_4[0]+sum16_to_4[1]+sum16_to_4[2]+sum16_to_4[3];

assign 		sigmaS_out =sum[10:1];				//Make the code feasible is the key 	--Adjustable

endmodule