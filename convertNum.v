module convertNum(score, clk, out1, out2);
	input [31:0] score;
	input clk;
	output [2 : 0] out1 [4 : 0];
	output [2 : 0] out2 [4 : 0];
	reg [2 : 0] out1 [4 : 0];
	reg [2 : 0] out2 [4 : 0];
	
	reg [4:0]a, b;
	
	always @(posedge clk) begin
		a = score / 10;
		case(a)
			0: begin
				out1[0] <= 3'b000;
				out1[1] <= 3'b000;
				out1[2] <= 3'b000;
				out1[3] <= 3'b000;
				out1[4] <= 3'b000;
			end
			1: begin
				out1[0] <= 3'b010;
				out1[1] <= 3'b010;
				out1[2] <= 3'b010;
				out1[3] <= 3'b010;
				out1[4] <= 3'b010;
			end
			2: begin
				out1[0] <= 3'b111;
				out1[1] <= 3'b100;
				out1[2] <= 3'b111;
				out1[3] <= 3'b001;
				out1[4] <= 3'b111;
			end
			3: begin
				out1[0] <= 3'b111;
				out1[1] <= 3'b100;
				out1[2] <= 3'b111;
				out1[3] <= 3'b100;
				out1[4] <= 3'b111;
			end
			4: begin 
				out1[0] <= 3'b101;
				out1[1] <= 3'b101;
				out1[2] <= 3'b111;
				out1[3] <= 3'b100;
				out1[4] <= 3'b100;
			end
			5: begin 
				out1[0] <= 3'b111;
				out1[1] <= 3'b001;
				out1[2] <= 3'b111;
				out1[3] <= 3'b100;
				out1[4] <= 3'b111;
			end
			6: begin 
				out1[0] <= 3'b001;
				out1[1] <= 3'b001;
				out1[2] <= 3'b111;
				out1[3] <= 3'b101;
				out1[4] <= 3'b111;
			end
			7: begin 
				out1[0] <= 3'b111;
				out1[1] <= 3'b100;
				out1[2] <= 3'b100;
				out1[3] <= 3'b100;
				out1[4] <= 3'b100;
			end
			8: begin 
				out1[0] <= 3'b111;
				out1[1] <= 3'b101;
				out1[2] <= 3'b111;
				out1[3] <= 3'b101;
				out1[4] <= 3'b111;
			end
			9: begin 
				out1[0] <= 3'b111;
				out1[1] <= 3'b101;
				out1[2] <= 3'b111;
				out1[3] <= 3'b100;
				out1[4] <= 3'b100;
			end
		endcase
		b = score - 10 * a;
		case(b)
			0: begin
				out2[0] <= 3'b111;
				out2[1] <= 3'b101;
				out2[2] <= 3'b101;
				out2[3] <= 3'b101;
				out2[4] <= 3'b111;
			end
			1: begin
				out2[0] <= 3'b010;
				out2[1] <= 3'b010;
				out2[2] <= 3'b010;
				out2[3] <= 3'b010;
				out2[4] <= 3'b010;
			end
			2: begin
				out2[0] <= 3'b111;
				out2[1] <= 3'b100;
				out2[2] <= 3'b111;
				out2[3] <= 3'b001;
				out2[4] <= 3'b111;
			end
			3: begin
				out2[0] <= 3'b111;
				out2[1] <= 3'b100;
				out2[2] <= 3'b111;
				out2[3] <= 3'b100;
				out2[4] <= 3'b111;
			end
			4: begin 
				out2[0] <= 3'b101;
				out2[1] <= 3'b101;
				out2[2] <= 3'b111;
				out2[3] <= 3'b100;
				out2[4] <= 3'b100;
			end
			5: begin 
				out2[0] <= 3'b111;
				out2[1] <= 3'b001;
				out2[2] <= 3'b111;
				out2[3] <= 3'b100;
				out2[4] <= 3'b111;
			end
			6: begin 
				out2[0] <= 3'b001;
				out2[1] <= 3'b001;
				out2[2] <= 3'b111;
				out2[3] <= 3'b101;
				out2[4] <= 3'b111;
			end
			7: begin 
				out2[0] <= 3'b111;
				out2[1] <= 3'b100;
				out2[2] <= 3'b100;
				out2[3] <= 3'b100;
				out2[4] <= 3'b100;
			end
			8: begin 
				out2[0] <= 3'b111;
				out2[1] <= 3'b101;
				out2[2] <= 3'b111;
				out2[3] <= 3'b101;
				out2[4] <= 3'b111;
			end
			9: begin 
				out2[0] <= 3'b111;
				out2[1] <= 3'b101;
				out2[2] <= 3'b111;
				out2[3] <= 3'b100;
				out2[4] <= 3'b100;
			end
		endcase
	end
endmodule
