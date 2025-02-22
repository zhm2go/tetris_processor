module regfile(
	clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA,
	data_readRegB, score, scoreadd, terType, terTypeChange
);

	
	//myinput
	input [31:0] score;
	output [31:0] scoreadd;
	input [31:0] terType;
	output [31:0] terTypeChange;
	
	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;
	output [31:0] data_readRegA, data_readRegB;

	reg[31:0] registers[31:0];
	
	always @(posedge clock or posedge ctrl_reset)
	begin
		if(ctrl_reset)
			begin
				integer i;
				for(i = 0; i < 32; i = i + 1)
					begin
						registers[i] = 32'd0;
					end
			end
		else begin
			if(ctrl_writeEnable == 1 && ctrl_writeReg != 5'd00000) begin
				registers[1] = score;
				registers[3] = terType;
				registers[ctrl_writeReg] = data_writeReg;
			end
			scoreadd = registers[2];
			terTypeChange = registers[4];
//			if(ctrl_writeReg != 5'd0 && ctrl_writeReg != 5'd0)
//				registers[ctrl_writeReg] = data_writeReg;
		end
	end
	
	assign data_readRegA = ctrl_writeEnable && (ctrl_writeReg == ctrl_readRegA) ? 32'bz : registers[ctrl_readRegA];
	assign data_readRegB = ctrl_writeEnable && (ctrl_writeReg == ctrl_readRegB) ? 32'bz : registers[ctrl_readRegB];
	
endmodule
