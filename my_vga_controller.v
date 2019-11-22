module my_vga_controller(count,
                      up,
							 down,
							 left,
							 right,
							 iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data);

	
input iRST_n;
input iVGA_CLK;
input count;
input up, down, left, right;
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
assign rst = ~iRST_n;

parameter sq = 50;
parameter step = 5;
parameter [7:0] sq_r = 8'hff;
parameter [7:0] sq_g = 8'h00;
parameter [7:0] sq_b = 8'h00;

reg [9:0] x, y;
//wire [9:0] scan_x;
//wire [9:0] scan_y;
//reg inSquare;
	
initial begin
	x = 480/2 - sq/2;
	y = 640/2 - sq/2;
end	

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
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;

//always @(posedge up_r, posedge down_r, posedge left_r, posedge right_r) begin
//always@(posedge iVGA_CLK) begin
//	if(up_r == 1'b1)
//		y = y - step;
//	else if(down_r == 1'b1)
//		y = y + step;
//	else if(left_r == 1'b1)
//		x = x - step;
//	else if(right_r == 1'b1)
//		x = x + step;
//end

always @(posedge count) begin
	if(up == 1'b0)
		x = x - step;
	if(down == 1'b0)
		x = x + step;
	if(left == 1'b0)
		y = y - step;
	if(right == 1'b0)
		y = y + step;
	
		
end

wire [9:0] scan_x;
wire [9:0] scan_y;
reg inSquare;

addr2xy myaddr(scan_x, scan_y, ADDR);
always @(posedge VGA_CLK_n) begin
	if(scan_x - x < sq && scan_y - y <sq)
		inSquare <= 1'b1;
	else
		inSquare <= 1'b0;
end

assign b_data = inSquare ? b_data_sq : b_data_bk;
assign g_data = inSquare ? g_data_sq : g_data_bk;
assign r_data = inSquare ? r_data_sq : r_data_bk;
	
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule