module b_rescue(
	input		clk,
	input		sys_rst_n,
	
	input		[9:0]	rv_signal,
	input		[9:0]	input_signalA,
	input		[9:0]	dds_input,
	
	output		[9:0]	dds_shift
);

reg	[9:0]	dds_input_shift	[255:0];
reg	[7:0]	shift_reg;
reg	[7:0]	tim_delay;

wire	signed [15:0]	R_error;
wire	signed [15:0]	N_error;
wire	signed [15:0]	L_error;


wire	 [15:0]	AbsR_error;
wire	 [15:0]	AbsN_error;
wire	 [15:0]	AbsL_error;

assign R_error =dds_input_shift[shift_reg+'d1]+rv_signal		-input_signalA;

assign L_error =dds_input_shift[shift_reg-'d1] +rv_signal  	-input_signalA;


assign AbsR_error=R_error[15] ==1'b1 ?~R_error+1'b1:R_error;
assign AbsN_error=N_error[15] ==1'b1 ?~N_error+1'b1:N_error;
assign AbsL_error=L_error[15] ==1'b1 ?~L_error+1'b1:L_error;


localparam	THOLD	='d11;				//Adjustable ..
integer	reg_index;
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		for(reg_index =0;reg_index <256;reg_index =reg_index +1) begin
			dds_input_shift[reg_index] <='d0;
		end
	end
	else begin
		dds_input_shift[0] <=dds_input;
		for(reg_index =0;reg_index <255;reg_index =reg_index +1) begin
			dds_input_shift[reg_index +1] <=dds_input_shift[reg_index];
		end
	end

//Time_delay for 128_clks
always @(posedge clk or negedge sys_rst_n) 
	if(!sys_rst_n)
		tim_delay <='d0;
	else if(tim_delay !=240) begin
		tim_delay <=tim_delay +1'b1;
	end
	else begin
		tim_delay <=tim_delay;
	end
always @(posedge clk or negedge sys_rst_n) 
	if(!sys_rst_n)
		shift_reg <=8'h00;
	else if(tim_delay ==240) begin
		if(AbsR_error <AbsN_error  &&AbsN_error -AbsR_error >THOLD)
			shift_reg <=shift_reg +'d1;
		else if(AbsL_error <AbsN_error  &&AbsN_error -AbsL_error >THOLD)
			shift_reg <=shift_reg -'d1;
		else begin
			shift_reg <=shift_reg;
		end
	end
	else begin
		shift_reg <=8'h00;
	end

assign dds_shift =dds_input_shift[shift_reg];
endmodule