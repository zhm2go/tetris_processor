//module ps2_detect(clk, ps2_out, ps2_key_pressed, out);
//	input clk;
//	input [7:0] ps2_out;
//	input ps2_key_pressed;
//	output [7:0] out;
//	reg 
//	
//	always @(posedge clk) begin
//		if(ps2_key_pressed == 1) begin
//			out = 1;
//		end
//		else begin
//			out = 0;
//		end;
//	end
//endmodule

module ps2_helper(clk, ps2_out, outReg);
	input clk;
	input [7:0] ps2_out;
	output [7:0] outReg;
	reg [7:0] outReg;
	reg [7:0] prevReg;
	
	always @(negedge clk) begin
		if (prevReg == ps2_out) begin
			outReg = 8'b0;
		end
		else begin
			outReg = ps2_out;
			prevReg = ps2_out;
		end
	end
	
endmodule
