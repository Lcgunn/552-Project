module cpu (output hlt, output pc[15:0], input clk, input rst_n);
	wire [15:0] current_instruction, next_instruction;
	//FIXME: THE PC SHOULD BE STORED IN 16 D flip flops
	//These are not passed by reference, and also the src variables should change
	memory1c Instr_mem(data_out, .data_in(current_instruction), addr, enable, wr, .clk(clk), .rst(~rst_n);
	
	memory1c Data_mem(data_out, data_in, addr, enable, wr, .clk(clk), .rst(~rst_n);

	RegisterFile Registers (.clk(clk),.rst(rst),.SrcReg1(SrcReg1),.SrcReg2(SrcReg2),.DstReg(DstReg),.WriteReg(WriteReg),.DstData(DstData),.SrcData1(SrcData1),.SrcData2(SrcData2));
	ALU i_alu (ALU_Out,opcode,operand1,operand2);
	
endmodule
