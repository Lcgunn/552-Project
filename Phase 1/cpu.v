`default_nettype none
module cpu (output hlt, output pc[15:0], input clk, input rst_n);
	wire [15:0] current_instruction, next_instruction, stored_instruction, ALU_result, reg_1_data,reg_2_data;
	wire [2:0] iflags;
	//These are not passed by reference, and also the src variables should change
														//	
	memory1c Instr_mem(.data_out(current_instruction), .data_in(stored_instruction), addr, enable, wr, .clk(clk), .rst(~rst_n);
	
	memory1c Data_mem(data_out, data_in, addr, enable, wr, .clk(clk), .rst(~rst_n);

													//Instructions follow the sequence: OPCODE, RD (destination), and then (RT and RS) or Immediate value 
													//Watch out for the load lower and upper load
	RegisterFile Registers (.clk(clk),.rst(~rst_n),.SrcReg1(current_instruction[7:4]),.SrcReg2(current_instruction[3:0]),.DstReg(current_instruction[15:12]),.WriteReg(WriteReg),.DstData(ALU_result),.SrcData1(reg_1_data),.SrcData2(reg_2_data));
	
	control_logic controls (.Instr(current_instruction[15:12]), .immediate_or_reg())
	
	PC_control pc (.C, .I, .F, .PC_in(stored_instruction), .PC_out(next_instruction));	
	dff stored_pc [15:0] (.q(stored_instruction),.d(next_instruction), .wen(flag_enable), .clk(clk), .rst(~rst_n));


	ALU i_alu (.ALU_Out(ALU_result),.opcode(current_instruction[15:12]), .flags(iflags).operand1(reg_1_data),.operand2());
	
endmodule
