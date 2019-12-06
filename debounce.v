module ps2my(clock, ps2_key_pressed, co, speedup);
	input clock;
	input ps2_key_pressed;
	input [4:0] speedup;
	output co;
	reg co;
	
	reg [31:0] count, count_prev;
	reg [3:0] out;
	reg [3:0] d;
	always @(posedge clock) begin
		count = count + 1;
		if(ps2_key_pressed == 1) begin
			count_prev = count;
			d = d + 1;
			co = 1;
		end
		if(co == 1) out = out + 1;
		if(count - count_prev > 9500000*4/speedup) begin
			co = 0;
		end
	end
endmodule
