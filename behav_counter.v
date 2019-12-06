module behav_counter(clk, out);

input   clk;
output out;

reg  [25:0] cnt;
reg out;

always @ (posedge clk)
begin
    cnt <= cnt + 1;
	 out <= 1'b0;
	 if (cnt == 2500000)
	 //if (cnt == 5)
	 begin
		 cnt <= 0;
		 out <= 1'b1;
	 end
end 

endmodule

module ClkDivider (clk, clk_div);
    input clk;
    output clk_div;
	 reg clk_div;
	 localparam constantNumber = 10000000;
	 
	 reg [31:0] count;
 
	always @ (posedge clk)
	begin
   
	if (count == constantNumber - 1)
        count <= 32'b0;
   else
        count <= count + 1;
	end
	
	always @ (posedge clk)
	begin
    if (count == constantNumber - 1)
        clk_div <= ~clk_div;
    else
        clk_div <= clk_div;
	end
 
endmodule

module ClkDividerNew (clk, clk_div, c);
    input clk;
    output clk_div;
	 reg clk_div;
	 input [31:0] c;
	 
	 reg [31:0] count;
 
	always @ (posedge clk)
	begin
   
	if (count == c - 1)
        count <= 32'b0;
   else
        count <= count + 1;
	end
	
	always @ (posedge clk)
	begin
    if (count == c - 1)
        clk_div <= ~clk_div;
    else
        clk_div <= clk_div;
	end
 
endmodule
