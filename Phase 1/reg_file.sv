module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);
	// assign Wordline[0] = ~RegId[0] & ~RegId[1] & ~RegId[2] & ~RegId[3];  
	// assign Wordline[1] = RegId[0] & ~RegId[1] & ~RegId[2] & ~RegId[3];  
	// assign Wordline[2] = ~RegId[0] & RegId[1] & ~RegId[2] & ~RegId[3];  
	// assign Wordline[3] = RegId[0] & RegId[1] & RegId[2] & ~RegId[3];  
	// assign Wordline[4] = ~RegId[0] & ~RegId[1] & RegId[2] & ~RegId[3];  
	// assign Wordline[5] = RegId[0] & ~RegId[1] & RegId[2] & ~RegId[3];  
	// assign Wordline[6] = ~RegId[0] & RegId[1] & RegId[2] & ~RegId[3]; 
	// assign Wordline[7] = RegId[0] & RegId[1] & RegId[2] & ~RegId[3]; 
	// assign Wordline[8] = RegId[0] & RegId[1] & RegId[2] & ~RegId[3]; 
		// Seperate idea
	wire [15:0] shift3, shift2,shift1,shiftv;
	assign shiftv = 16'h0001;
	assign shift3 = RegId[3] ? (shiftv << 8) : shiftv;
	assign shift2 = RegId[2] ? (shift3 << 4) : shift3;
	assign shift1 = RegId[1] ? (shift2 << 2) : shift2;
	assign shift0 = RegId[0] ? (shift1 << 1) : shift1;
	assign Wordline = shift0;

endmodule

module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output [15:0] Wordline);
	wire [15:0] shift3, shift2,shift1,shiftv;
	assign shiftv = 16'h0001;
	assign shift3 = RegId[3] ? (shiftv << 8) : shiftv;
	assign shift2 = RegId[2] ? (shift3 << 4) : shift3;
	assign shift1 = RegId[1] ? (shift2 << 2) : shift2;
	assign shift0 = RegId[0] ? (shift1 << 1) : shift1;
	assign Wordline = WriteReg ? shift0 : 16'b0000;
endmodule

module BitCell( input clk,  input rst, input D, input WriteEnable, input ReadEnable1, input ReadEnable2, inout Bitline1, inout Bitline2);
	reg temp_q;
	dff one_flop(.q(temp_q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));
	assign Bitline1 = ~ReadEnable1 ? temp_q : 1'bz;
	assign Bitline2 = ~ReadEnable2 ? temp_q : 1'bz;	

endmodule

module Register( input clk,  input rst, input [15:0] D, input WriteReg, input ReadEnable1, input ReadEnable2, inout [15:0] Bitline1, inout [15:0] Bitline2);
	BitCell line [15:0] (.clk(clk),  .rst(rst), .D(D), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1), .Bitline2(Bitline2));
endmodule

module RegisterFile(input clk, input rst, input [3:0] SrcReg1, input [3:0] SrcReg2, input [3:0] DstReg, input WriteReg, input [15:0] DstData, inout [15:0] SrcData1, inout [15:0] SrcData2);
	wire [15:0] read_1en, read_2en;
	ReadDecoder_4_16 read_src1 (.RegId(SrcReg1),.Wordline(read_1en));
	ReadDecoder_4_16 read_src2 (.RegId(SrcReg2),.Wordline(read_2en));
	WriteDecoder_4_16 write_d  (.RegId(DstReg),.WriteReg(WriteReg),.Wordline(write_en));
	Register regs [15:0] (.clk(clk),  .rst(rst), .D(DstData), .WriteReg(write_en), .ReadEnable1(read_1en), .ReadEnable2(read_2en), .Bitline1(SrcData1), .Bitline2(SrcData2));
endmodule