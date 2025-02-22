module skeleton(resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	debug_data_in, debug_addr, leds, 						// extra debugging ports
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50, //);  													// 50 MHz clock
	
	//for my test
	count,
	left,
	right,
	rot);	
	////////////////////////	VGA	////////////////////////////
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	input				CLOCK_50;

	////////////////////////	PS2	////////////////////////////
	input 			resetn;
	inout 			ps2_data, ps2_clock;
	
	////////////////////////	LCD and Seven Segment	////////////////////////////
	output 			   lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_data_in;
	output   [11:0]   debug_addr;
	
	
	
	input left, right, rot;
	
	wire			 clock;
	wire			 lcd_write_en;
	wire 	[31:0] lcd_write_data;
	wire	[7:0]	 ps2_key_data;
	wire			 ps2_key_pressed;
	wire	[7:0]	 ps2_out;
	wire	[7:0]  myps2_out;
	
	// clock divider (by 5, i.e., 10 MHz)
	pll div(CLOCK_50,inclock);
	assign clock = CLOCK_50;
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	//assign clock = inclock;
		//
	parameter width = 10;
	parameter height = 20;
	parameter block = 20;
	parameter width_score = 3;
	parameter height_score = 5;
	
	//states
	parameter Snew = 4'b0000;
	parameter ScheckFall = 4'b0001;
	parameter Sfall = 4'b0010;
	parameter ScheckKey = 4'b0011;
	parameter Sleft = 4'b0100;
	parameter Sright = 4'b0101;
	parameter Sdelete = 4'b0111;
	parameter Srot = 4'b1000;
	parameter ScheckOver = 4'b1110;
	parameter Sover = 4'b1111;
	
	
	reg [width - 1 : 0] a[height - 1 : 0];
	reg [4:0] x1, x2, x3, x0;
	reg [4:0] y1, y2, y3, y0;
	reg [31:0] terType, terType1, terTypeChange;
	output count;
	reg [3:0] curr;
	reg [3:0] game_state, next;
	
	reg [4:0] i;
	reg count_neg;
	reg [4:0] mx;
	reg [4:0] my;
	reg [4:0] mz;
	reg [4:0] mk, mp, mq;
	reg [4:0] overi, overj, overk;
	reg n, m, isover, x;
	reg [4:0] speedup;
	reg [31:0] score;
	reg [width_score - 1 : 0] num1[height_score - 1 : 0];
	reg [width_score - 1 : 0] num2[height_score - 1 : 0];
	reg [31:0] time_count;
	reg [31:0] press_count;
	reg gameover;
	
	//for test
	reg [7:0] ledReg;
	reg [31:0] score_test;
	
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	ps2_helper myps2Helper(count, ps2_out, myps2_out);
//	reg [7:0] ps;
//	ps_read(count, ps2_key_pressed, ps2_out, ps);	
	
	//behav_counter mycounter(clock, count);
	//ClkDivider (clock, count);
	convertNum myconvert(score, count, num1, num2);
	
	reg [31:0] c, d;
	initial
	begin
		curr = Snew;
		next = Snew;
		c = 10000000;
		speedup = 1;
		d = 10000000;
		terType = 0;
		gameover = 0;
	end
	ClkDividerNew (clock, count, d);
	//ClkDivider (clock, count);
	
	wire ps2;
	ps2my ps(clock, ps2_key_pressed, ps2, speedup);
	
	always @(posedge clock) begin
		if(score >= 10) speedup = 2;
		else if (score >= 20) speedup = 3;
		else speedup = 1;
		d = c / speedup;
	end
		
	always @(negedge count) begin
		curr = next;
	end
	
	always @(negedge count) begin
		time_count = time_count + 1;
	end
	
	always @(posedge ps2_key_pressed) begin
		press_count = press_count + 1;
	end
	
	reg signal, tsignal;
	reg [31:0] scoreadd;
	
	always @(posedge signal) begin
		score = scoreadd;
		if(gameover == 1) score = 1;
	end
	
//	reg [31:0] nextType;
//	always @(negedge count) begin
//		nextType = (press_count + time_count) % 14; 
//		if(nextType == 0) nextType = 1;
//	end
		
	always @(posedge count) 
	begin
		case(curr)
			Snew: begin
				//score = score + 1;
				signal = 1'b1;
				terType = (press_count + time_count) % 14; 
				if(terType == 0) terType = 1;
				case (terType)
					1: begin
						a[0][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[1][width / 2] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						x0 = 0;
						x1 = 0;
						x2 = 1;
						x3 = 1;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2;
						y3 = width / 2 + 1;
					end
					2: begin
						a[0][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						a[1][width / 2 + 2] = 1'b1;
						x0 = 0;
						x1 = 0;
						x2 = 1;
						x3 = 1;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2 + 1;
						y3 = width / 2 + 2;
					end
					3: begin
						a[1][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						a[2][width / 2] = 1'b1;
						x0 = 1;
						x1 = 0;
						x2 = 1;
						x3 = 2;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2 + 1;
						y3 = width / 2;
					end
					4: begin
						a[0][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[0][width / 2 + 2] = 1'b1;
						a[0][width / 2 + 3] = 1'b1;
						x0 = 0;
						x1 = 0;
						x2 = 0;
						x3 = 0;
						y0 = width / 2 ;
						y1 = width / 2 + 1;
						y2 = width / 2 + 2;
						y3 = width / 2 + 3;
					end
					5: begin
						a[0][width / 2] = 1'b1;
						a[1][width / 2] = 1'b1;
						a[2][width / 2] = 1'b1;
						a[3][width / 2] = 1'b1;
						x0 = 0;
						x1 = 1;
						x2 = 2;
						x3 = 3;
						y0 = width / 2;
						y1 = width / 2;
						y2 = width / 2;
						y3 = width / 2;
					end
					6: begin
						a[0][width / 2] = 1'b1;
						a[1][width / 2] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						a[1][width / 2 + 2] = 1'b1;
						x0 = 0;
						x1 = 1;
						x2 = 1;
						x3 = 1;
						y0 = width / 2;
						y1 = width / 2;
						y2 = width / 2 + 1;
						y3 = width / 2 + 2;
					end
					7: begin
						a[0][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[1][width / 2] = 1'b1;
						a[2][width / 2] = 1'b1;
						x0 = 0;
						x1 = 0;
						x2 = 1;
						x3 = 2;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2;
						y3 = width / 2;
					end
					8: begin
						a[0][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[0][width / 2 + 2] = 1'b1;
						a[0][width / 2 + 2] = 1'b1;
						x0 = 0;
						x1 = 0;
						x2 = 0;
						x3 = 1;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2 + 2;
						y3 = width / 2 + 2;
					end
					9: begin
						a[2][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						a[2][width / 2 + 1] = 1'b1;
						x0 = 2;
						x1 = 0;
						x2 = 1;
						x3 = 2;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2 + 1;
						y3 = width / 2 + 1;
					end
					10: begin
						a[0][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[0][width / 2 + 2] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						x0 = 0;
						x1 = 0;
						x2 = 0;
						x3 = 1;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2 + 2;
						y3 = width / 2 + 1;
					end
					11: begin
						a[1][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						a[2][width / 2 + 1] = 1'b1;
						x0 = 1;
						x1 = 0;
						x2 = 1;
						x3 = 2;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2 + 1;
						y3 = width / 2 + 1;
					end
					12: begin
						a[1][width / 2] = 1'b1;
						a[0][width / 2 + 1] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						a[1][width / 2 + 2] = 1'b1;
						x0 = 1;
						x1 = 0;
						x2 = 1;
						x3 = 1;
						y0 = width / 2;
						y1 = width / 2 + 1;
						y2 = width / 2 + 1;
						y3 = width / 2 + 2;
					end
					13: begin
						a[0][width / 2] = 1'b1;
						a[1][width / 2] = 1'b1;
						a[1][width / 2 + 1] = 1'b1;
						a[2][width / 2] = 1'b1;
						x0 = 0;
						x1 = 1;
						x2 = 1;
						x3 = 2;
						y0 = width / 2;
						y1 = width / 2;
						y2 = width / 2 + 1;
						y3 = width / 2;
					end
				endcase
				next = ScheckKey;
			end
			
			ScheckKey:begin
				gameover = 1'b0;
				signal = 1'b0;
				if(ps2_out == 8'h6b && ps2 == 1 && y0 >= 1 && y1 >= 1 && y2 >= 1 && y3 >= 1) begin
					case(terType)
					1: begin
						if(a[x0][y0 - 1] == 0 && a[x2][y2 - 1] == 0)
							next = Sleft;
						else
							next = ScheckFall;
					end
					2: begin
							if(a[x0][y0 - 1] == 0 && a[x2][y2 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						3: begin
							if(a[x1][y1 - 1] == 0 && a[x0][y0 - 1] == 0 && a[x3][y3 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						4: begin
							if(a[x0][y0 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						5: begin
							if(a[x0][y0 - 1] == 0 && a[x1][y1 - 1] == 0 && a[x2][y2 - 1] == 0 && a[x3][y3 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						6: begin
							if(a[x0][y0 - 1] == 0 && a[x1][y1 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						7: begin
							if(a[x0][y0 - 1] == 0 && a[x2][y2 - 1] == 0 && a[x3][y3 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						8: begin
							if(a[x0][y0 - 1] == 0 && a[x3][y3 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						9: begin
							if(a[x0][y0 - 1] == 0 && a[x1][y1 - 1] == 0 && a[x2][y2 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						10: begin
							if(a[x0][y0 - 1] == 0 && a[x3][y3 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						11: begin
							if(a[x0][y0 - 1] == 0 && a[x1][y1 - 1] == 0 && a[x3][y3 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						12: begin
						if(a[x0][y0 - 1] == 0 && a[x1][y1 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
						13: begin
							if(a[x0][y0 - 1] == 0 && a[x1][y1 - 1] == 0 && a[x3][y3 - 1] == 0)begin
								next = Sleft;
							end
							else begin
								next = ScheckFall;
							end
						end
					endcase
				end
				else if(ps2_out == 8'h74 && ps2 == 1 && y0 < width - 1 && y1 < width - 1 && y2 < width - 1 && y3 < width - 1) begin
					case(terType)
						1: begin
							if(a[x1][y1 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						2: begin
							if(a[x1][y1 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						3: begin
							if(a[x1][y1 + 1] == 0 && a[x2][y2 + 1] == 0 && a[x3][y3 + 1] == 0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						4: begin
							if(a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						5: begin
							if(a[x0][y0 + 1] == 0 && a[x1][y1 + 1] == 0 && a[x2][y2 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						6: begin
							if(a[x0][y0 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						7: begin
							if(a[x1][y1 + 1] == 0 && a[x2][y2 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						8: begin
							if(a[x2][y2 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						9: begin
							if(a[x1][y1 + 1] == 0 && a[x2][y2 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						10: begin
							if(a[x2][y2 + 1] == 0 && a[x3][y3 + 1] == 0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						11: begin
							if(a[x1][y1 + 1] == 0 && a[x2][y2 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						12: begin
							if(a[x1][y1 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
						13: begin
							if(a[x0][y0 + 1] == 0 && a[x2][y2 + 1] == 0 && a[x3][y3 + 1] ==0)begin
								next = Sright;
							end
							else begin
								next = ScheckFall;
							end
						end
					endcase
				end
				//else if(ps2_out == 8'h72)
				else if(ps2_out == 8'h75 && ps2 == 1) begin
					case(terType)
					1: begin
							next = ScheckFall;
						end
						2: begin
							if(a[x0 + 1][y0] == 0 && a[x1 - 1][y1] == 0 && x0 > 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						3: begin
							if(y2 <= width - 2 && a[x2 + 1][y2] == 0 && a[x2 + 1][y2 + 1] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						4: begin
							if(x1 >= 1 && x1 <= height - 3 && a[x1 - 1][y1] == 0 && a[x1 + 1][y1] == 0 && a[x1 + 2][y1] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						5: begin
							if(y1 >= 1 && y1 <= width - 3 && a[x1][y1 - 1] == 0 && a[x1][y1 + 1] == 0 && a[x1][y1 + 2] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						6: begin
							if(x1 <= height - 3 && a[x1 + 1][y1] == 0 && a[x1 + 2][y1] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						7: begin
							if(y0 >= 2 && a[x0][y0 - 1] == 0 && a[x0][y0 - 2] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						8: begin
							if(x2 >= 2 && a[x2 - 1][y2] == 0 & a[x2 - 2][y2] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						9: begin
							if(y3 <= width - 3 && a[x3][y3 + 1] == 0&& a[x3][y3 + 2] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						10: begin
							if(x1 >= 1 && a[x1 - 1][y1] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						11: begin
							if(y2 <= width - 2 && a[x2][y2 + 1] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						12: begin
							if(x2 <= height - 2 && a[x2 + 1][y2] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
						13: begin
							if(y1 >= 1 && a[x1][y1 - 1] == 0)begin
								next = Srot;
								tsignal = 1'b1;
							end
							else begin
								next = ScheckFall;
							end
						end
					endcase
				end
				else begin
					next = ScheckFall;
				end
			end
			
			ScheckFall: begin
				case(terType)
					1: begin
						if(a[x2 + 1][y2] == 1 || a[x3 + 1][y3] == 1 || x2 > height -2 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					2: begin
						if(a[x0 + 1][y0] == 1 || a[x2 + 1][y2] || a[x3 + 1][y3] || x2 > height - 2 || x3 > height -2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
//					
					3: begin
						if(a[x3 + 1][y3] == 1 || a[x2 + 1][y2] == 1 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					4: begin
						if(a[x0 + 1][y0] == 1 || a[x1 + 1][y1] == 1 || a [x2 + 1][y2] == 1 || a[x3 + 1][y3] || x0 > height - 2 || x1 > height - 2 || x2 > height - 2 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					5: begin
						if(a[x3 + 1][y3] == 1 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					6: begin
						if(a[x1 + 1][y1] == 1 || a[x2 + 1][y2] == 1 || a[x3 + 1][y3] == 1 || x1 > height - 2 || x2 > height - 2 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					7: begin
						if(a[x3 + 1][y3] == 1 || a[x1 + 1][y1] == 1 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					8: begin
						if(a[x0 + 1][y0] == 1 || a[x1 + 1][y1] == 1|| a[x3 + 1][y3] ==1 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					9: begin
						if(a[x0 + 1][y0] == 1 || a[x3 + 1][y3] == 1 || x0 > height - 2 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					10: begin
						if(a[x0 + 1][y0] == 1 || a[x3 + 1][y3]  == 1 || a[x2 + 1][y2] == 1 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					11: begin
						if(a[x0 + 1][y0] == 1 || a[x3 + 1][y3] == 1 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					12: begin
						if(a[x0 + 1][y0] == 1 || a[x2 + 1][y2] == 1 || a[x3 + 1][y3] == 1 || x0 > height - 2 || x2 > height - 2 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
					13: begin
							if(a[x3 + 1][y3] == 1 || a[x2 + 1][y2] == 1 || x3 > height - 2) begin
							next = Sdelete;
						end
						else begin
							next = Sfall;
						end
					end
				endcase
			end		
		
			Sfall: begin
				a[x0][y0] = 0;
				a[x1][y1] = 0;
				a[x2][y2] = 0;
				a[x3][y3] = 0;
				x0 = x0 + 1;
				x1 = x1 + 1;
				x2 = x2 + 1;
				x3 = x3 + 1;
				a[x0][y0] = 1;
				a[x1][y1] = 1;
				a[x2][y2] = 1;
				a[x3][y3] = 1;
				next = ScheckKey;
			end	
//			
			Sleft: begin
				a[x0][y0] = 0;
				a[x1][y1] = 0;
				a[x2][y2] = 0;
				a[x3][y3] = 0;
				y0 = y0 - 1;
				y1 = y1 - 1;
				y2 = y2 - 1;
				y3 = y3 - 1;
				a[x0][y0] = 1;
				a[x1][y1] = 1;
				a[x2][y2] = 1;
				a[x3][y3] = 1;
				next = ScheckFall;
			end			
			
			Sright: begin
				a[x0][y0] = 0;
				a[x1][y1] = 0;
				a[x2][y2] = 0;
				a[x3][y3] = 0;
				y0 = y0 + 1;
				y1 = y1 + 1;
				y2 = y2 + 1;
				y3 = y3 + 1;
				a[x0][y0] = 1;
				a[x1][y1] = 1;
				a[x2][y2] = 1;
				a[x3][y3] = 1;
				next = ScheckFall;
			end
//			
			Sdelete: begin
				for(mx = height - 1; mx > 0; mx = mx - 1) begin
					n = 1;
					for(my = 0; my < width; my = my + 1) begin
						n = n & a[mx][my];
					end
					if(n == 1) begin
						for(mz = mx; mz > 1; mz = mz -1) begin
							a[mz] = a[mz - 1];
						end
					end
				end
				m = 0;
				for(mk = height - 1; mk > 0; mk = mk - 1) begin
					x = 1;
					for(mp = 0; mp < width; mp = mp + 1) begin
						x = x & a[mk][mp];
					end
					m = m | x;
				end
				if(m == 1) next = Sdelete;
				else next = ScheckOver;			
			end
			
			ScheckOver: begin
				isover = 1'b0;
				for(overi = 0; overi < width; overi  = overi + 1) begin
					isover = isover | a[0][overi];
				end
				if (isover == 1) next = Sover;
				else next = Snew;
			end
			
			Sover: begin
				next = Sover;
				if(ps2_out == 8'h5A && ps2 == 1) begin
					for(overj = 0; overj < height; overj = overj + 1) begin
						for(overk = 0; overk < width; overk = overk + 1) begin
							a[overj][overk] = 1'b0;
						end
					end
					//score = 0;
					next = Snew;
					gameover = 1'b1;
				end
			end
					
			Srot: begin
				case(terType)
					2:begin
						a[x1][y1] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x1 = x0 - 1;
						x2 = x0;
						x3 = x0 + 1;
						y1 = y0 + 1;
						y2 = y0 + 1;
						y3 = y0;
						a[x1][y1] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 3;
						next = ScheckFall;
						terType = terTypeChange;
					end
					3:begin
						a[x1][y1] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x1 = x0;
						x2 = x0 + 1;
						x3 = x0 + 1;
						y1 = y0 + 1;
						y2 = y0 + 1;
						y3 = y0 + 2;
						a[x1][y1] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 2;
						next = ScheckFall;
						terType = terTypeChange;
					end
					4:begin
						a[x0][y0] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x0 = x1 - 1;
						x2 = x1 + 1;
						x3 = x1 + 2;
						y0 = y1;
						y2 = y1;
						y3 = y1;
						a[x0][y0] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 5;
						next = ScheckFall;
						terType = terTypeChange;
					end
					5:begin
						a[x0][y0] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x0 = x1;
						x2 = x1;
						x3 = x1;
						y0 = y1 - 1;
						y2 = y1 + 1;
						y3 = y1 + 2;
						a[x0][y0] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 4;
						next = ScheckFall;
						terType = terTypeChange;
					end
					6:begin
						a[x0][y0] = 0;
						a[x1][y1] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x0 = x0 + 1;
						x1 = x0;
						x2 = x0 + 1;
						x3 = x0 + 2;
						y1 = y0 + 1;
						y2 = y0;
						y3 = y0;
						a[x0][y0] = 1;
						a[x1][y1] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 7;
						next = ScheckFall;
						terType = terTypeChange;
					end
					7:begin
						a[x0][y0] = 0;
						a[x1][y1] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x2 = x0;
						y2 = y0;
						x0 = x2;
						x1 = x2;
						x3 = x2 + 1;
						y0 = y2 - 2;
						y1 = y2 - 1;
						y3 = y2;
						a[x0][y0] = 1;
						a[x1][y1] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 8;
						next = ScheckFall;
						terType = terTypeChange;
					end
					8:begin
						a[x0][y0] = 0;
						a[x1][y1] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x3 = x2;
						y3 = y2;
						x0 = x3;
						x1 = x3 - 2;
						x2 = x3 - 1;
						y0 = y3 - 1;
						y1 = y3;
						y2 = y3;
						a[x0][y0] = 1;
						a[x1][y1] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 9;
						next = ScheckFall;
						terType = terTypeChange;
					end
					9:begin
						a[x0][y0] = 0;
						a[x1][y1] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x1 = x3;
						y1 = y3;
						x0 = x1 - 1;
						x2 = x1;
						x3 = x1;
						y0 = y1;
						y2 = y1 + 1;
						y3 = y1 + 2;
						a[x0][y0] = 1;
						a[x1][y1] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 6;
						next = ScheckFall;
						terType = terTypeChange;
					end
					10:begin
						a[x0][y0] = 0;
						a[x1][y1] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x2 = x1;
						y2 = y1;
						x1 = x2 - 1;
						x3 = x2 + 1;
						x0 = x2;
						y0 = y2 - 1;
						y1 = y2;
						y3 = y2;
						a[x0][y0] = 1;
						a[x1][y1] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 11;
						next = ScheckFall;
						terType = terTypeChange;
					end
					11:begin
						a[x3][y3] = 0;
						x3 = x2;
						y3 = y2 + 1;
						a[x3][y3] = 1;
						//terType = 12;
						next = ScheckFall;
						terType = terTypeChange;
					end
					12:begin
						a[x0][y0] = 0;
						a[x1][y1] = 0;
						a[x2][y2] = 0;
						a[x3][y3] = 0;
						x1 = x2;
						y1 = y2;
						x0 = x1 - 1;
						x2 = x1;
						x3 = x1 + 1;
						y0 = y1;
						y2 = y1 + 1;
						y3 = y1;
						a[x0][y0] = 1;
						a[x1][y1] = 1;
						a[x2][y2] = 1;
						a[x3][y3] = 1;
						//terType = 13;
						next = ScheckFall;
						terType = terTypeChange;
					end
					13:begin
						a[x0][y0] = 0;
						x0 = x1;
						y0 = y1 - 1;
						a[x0][y0] = 1;
						//terType = 10;
						next = ScheckFall;
						terType = terTypeChange;
					end
				endcase
			end
				
	endcase  //case curr
end						
	
	always @(posedge count) begin
		if(left == 1'b0)
			ledReg = 8'hf0;
		else if(right == 1'b0)
			ledReg = 8'h0f;
		else
			ledReg = 8'h00;
	end
	
	assign leds = ledReg;
	
	
	
	// your processor
	 wire clk_by2, clk_by4;
	 divider_2 div2(clock, reset, clk_by2);
	 divider_2 div4(clk_by2, reset, clk_by4);
	 assign processor_clock = ~clk_by4 && ~clk_by2;
	 assign imem_clock = clk_by4 && clk_by2;
	 assign dmem_clock = clk_by4 && ~clk_by2;
	 assign regfile_clock = ~clk_by4 && clk_by2;
	 
	 wire [11:0] address_imem;
    wire [31:0] q_imem;
    imem my_imem(
        .address    (address_imem),            // address of data
        .clock      (imem_clock),                  // you may need to invert the clock
        .q          (q_imem)                   // the raw instruction
    );
	 
	 wire [11:0] address_dmem;
    wire [31:0] data;
    wire wren;
    wire [31:0] q_dmem;
    dmem my_dmem(
        .address    (address_dmem),       // address of data
        .clock      (dmem_clock),                  // may need to invert the clock
        .data	     (data),    // data you want to write
        .wren	     (wren),      // write enable
        .q          (q_dmem)    // data from dmem
    );
	 
	  /** REGFILE **/
    // Instantiate your regfile
    wire ctrl_writeEnable;
    wire [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    wire [31:0] data_writeReg;
    wire [31:0] data_readRegA, data_readRegB;
    regfile my_regfile(
        regfile_clock,
        ctrl_writeEnable,
		  reset,
        ctrl_writeReg,
        ctrl_readRegA,
        ctrl_readRegB,
        data_writeReg,
        data_readRegA,
        data_readRegB, 
		  score, 
		  scoreadd,
		  terType, 
		  terTypeChange
		  
    );
	 
	 processor my_processor(
        // Control signals
        processor_clock,                          // I: The master clock
        reset,                          // I: A reset signal

        // Imem
        address_imem,                   // O: The address of the data to get from imem
        q_imem,                         // I: The data from imem

        // Dmem
        address_dmem,                   // O: The address of the data to get or put from/to dmem
        data,                           // O: The data to write to dmem
        wren,                           // O: Write enable for dmem
        q_dmem,                         // I: The data from dmem

        // Regfile
        ctrl_writeEnable,               // O: Write enable for regfile
        ctrl_writeReg,                  // O: Register to write to in regfile
        ctrl_readRegA,                  // O: Register to read from port A of regfile
        ctrl_readRegB,                  // O: Register to read from port B of regfile
        data_writeReg,                  // O: Data to write to for regfile
        data_readRegA,                  // I: Data from port A of regfile
        data_readRegB,                    // I: Data from port B of regfile
		  
		  //for test
 );
	 
	 
	 
	 //processor myprocessor(clock, ~resetn, /*ps2_key_pressed, ps2_out, lcd_write_en, lcd_write_data,*/ debug_data_in, debug_addr);
	
	// keyboard controller
	//PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	
	// lcd controller
	lcd mylcd(clock, ~resetn, 1'b1, ps2_out, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// example for sending ps2 data to the first two seven segment displays
	Hexadecimal_To_Seven_Segment hex1(a[19][3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(a[19][7:4], seg2);
	Hexadecimal_To_Seven_Segment hex3(a[18][3:0], seg3);
	Hexadecimal_To_Seven_Segment hex4(a[18][7:4], seg4);
	Hexadecimal_To_Seven_Segment hex5(curr, seg5);
	Hexadecimal_To_Seven_Segment hex6(terType, seg6);
//	Hexadecimal_To_Seven_Segment hex7(ps[3:0], seg7);
//	Hexadecimal_To_Seven_Segment hex8(ps[7:4], seg8);
	// the other seven segment displays are currently set to 0
	//Hexadecimal_To_Seven_Segment hex7(4'b0, seg7);
	//Hexadecimal_To_Seven_Segment hex8(4'b0, seg8);
	
	// some LEDs that you could use for debugging if you wanted
	//assign leds = 8'b00101011;
		
	// VGA
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
	my_vga_controller vga_ins(.a(a),
								 .num1(num1), 
								 .num2(num2),
								 .iRST_n(DLY_RST),
								 .iVGA_CLK(VGA_CLK),
								 .oBLANK_n(VGA_BLANK),
								 .oHS(VGA_HS),
								 .oVS(VGA_VS),
								 .b_data(VGA_B),
								 .g_data(VGA_G),
								 .r_data(VGA_R));
	
	
endmodule
