module ps_read(clk, ps2_key_pressed, ps2_out, out);
	input ps2_key_pressed;
	input clk;
	input [7:0] ps2_out;
	output [7:0] out;
	reg [7:0] count;
	reg [7:0] out;
	parameter value = 10000000;
	//reg [7:0] out_curr;
	
	always @(posedge ps2_key_pressed) begin
		if(count < value)
			out <= ps2_out;
		else
			out <= 0;
	end
	
	always @(posedge clk, posedge ps2_key_pressed) begin
		if(count < value) begin
			count <= count + 1;
		end
		else begin
			count <= value + 1;
		end
		if(ps2_key_pressed == 1) begin
			count <= 0;
		end
	end		
endmodule						