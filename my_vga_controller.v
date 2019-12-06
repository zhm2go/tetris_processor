module my_vga_controller(a,
							 num1,
							 num2,
							 iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data);

input [9:0] a [19:0];
input [2 : 0] num1 [4 : 0];
input [2 : 0] num2 [4 : 0];	
input iRST_n;
input iVGA_CLK;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
////

parameter sq = 50;
parameter step = 5;
parameter [7:0] sq_r = 8'hff;
parameter [7:0] sq_g = 8'h00;
parameter [7:0] sq_b = 8'h00;
parameter offset_x = 40;
parameter offset_y = 100;
parameter block = 20;
parameter width = 10;
parameter height = 20;
parameter score_width = 3;
parameter score_height = 5;
parameter score_offsetx = 40;
parameter score_offsety = 330;
parameter score_offsetx2 = score_offsetx;
parameter score_offsety2 = score_offsety + score_block * score_width + score_block;
parameter score_block = 10;
reg [18:0] x, y;


initial begin
	x = 320;
	y = 240;
end

assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
end
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////
//////latch valid data at falling edge;

//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
//assign b_data = bgr_data[23:16];
//assign g_data = bgr_data[15:8];
//assign r_data = bgr_data[7:0];
wire [7:0] b_data_bk, g_data_bk, r_data_bk, b_data_sq, g_data_sq, r_data_sq;
assign b_data_bk = bgr_data[23:16];
assign g_data_bk = bgr_data[15:8];
assign r_data_bk = bgr_data[7:0];
assign b_data_sq = sq_b;
assign g_data_sq = sq_g;
assign r_data_sq = sq_r; 

addr2xy myaddr(scan_x, scan_y, ADDR);
reg inSquare;
reg [18:0] scan_x;
reg [18:0] scan_y;
reg [18:0] ax, ay;
reg [18:0] a2x, a2y;

always @(posedge VGA_CLK_n) begin
	if(scan_x >= offset_x && scan_y >= offset_y && scan_x < offset_x + height * block && scan_y < offset_y + width * block) begin
		ax = (scan_x - offset_x) / block;
		ay = (scan_y - offset_y) / block;
		if(a[ax][ay] == 1'b1) begin
			a2x = ax * block + offset_x;
			a2y = ay * block + offset_y;
			if(scan_x >= a2x && scan_x - a2x < block && scan_y >= a2y && scan_y - a2y < block) begin
				inSquare <= 1;
			end
			else begin
				inSquare <= 0;
			end
		end
		else begin
			inSquare <= 0;
		end
	end
	else begin
		inSquare <= 0;
	end
end

reg [18:0] num1x, num1y;
reg [18:0] num12x, num12y;
reg innum1;
always @(posedge VGA_CLK_n) begin
	if(scan_x >= score_offsetx && scan_y >= score_offsety && scan_x < score_offsetx + score_height * score_block && scan_y < score_offsety + score_width * score_block) begin
		num1x = (scan_x - score_offsetx) / score_block;
		num1y = (scan_y - score_offsety) / score_block;
		if(num1[num1x][num1y] == 1'b1) begin
			num12x = num1x * score_block + score_offsetx;
			num12y = num1y * score_block + score_offsety;
			if(scan_x >= num12x && scan_x - num12x < score_block && scan_y >= num12y && scan_y - num12y < score_block) begin
				innum1 <= 1;
			end
			else begin
				innum1 <= 0;
			end
		end
		else begin
			innum1 <= 0;
		end
	end
	else begin
		innum1 <= 0;
	end
end

reg [18:0] num2x, num2y;
reg [18:0] num22x, num22y;
reg innum2;
always @(posedge VGA_CLK_n) begin
	if(scan_x >= score_offsetx2 && scan_y >= score_offsety2 && scan_x < score_offsetx2 + score_height * score_block && scan_y < score_offsety2 + score_width * score_block) begin
		num2x = (scan_x - score_offsetx2) / score_block;
		num2y = (scan_y - score_offsety2) / score_block;
		if(num2[num2x][num2y] == 1'b1) begin
			num22x = num2x * score_block + score_offsetx2;
			num22y = num2y * score_block + score_offsety2;
			if(scan_x >= num22x && scan_x - num22x < score_block && scan_y >= num22y && scan_y - num22y < score_block) begin
				innum2 <= 1;
			end
			else begin
				innum2 <= 0;
			end
		end
		else begin
			innum2 <= 0;
		end
	end
	else begin
		innum2 <= 0;
	end
end
	
//assign b_data = inSquare ? b_data_sq : b_data_bk;
//assign g_data = inSquare ? g_data_sq : g_data_bk;
//assign r_data = inSquare ? r_data_sq : r_data_bk;
wire isIn;
assign isIn = inSquare | innum1 | innum2;
assign b_data = isIn ? b_data_sq : b_data_bk;
assign g_data = isIn ? g_data_sq : g_data_bk;
assign r_data = isIn ? r_data_sq : r_data_bk;
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule

module addr2xy(x, y, addr);
	output [18:0] x, y;
	input [18:0] addr;
	
	assign x = addr / 640;
	assign y = addr - 640*x;
endmodule