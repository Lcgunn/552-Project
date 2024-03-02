module ALU (output [15:0] ALU_Out, output [2:0] flags, input [3:0] opcode, input [15:0] operand1, input [15:0] operand2);
	wire[15:0] inter_adder, inter_shift, inter_RED, ALU_Out;
	
	wire [3:0] shift_mode;
	reg [2:0] flags;//OVERFLOW[2]. NEGATIVE [1], ZERO IS [0]
	reg [2:0] flag_enable;
	wire temp_Ovfl
	wire sub;
	PSA_16bit adder (.Sum(inter_adder),.Ovfl(temp_Ovfl), .A(operand1),.B(operand2),.Sub(sub),.pad());//FIXME SUB should be implemented
	//Operand2 [3;0]
	Shifter shift(.Shift_out(inter_shift),.Shift_In(operand1),.Shift_Val(operand2[3:0]),.Mode(shift_mode));
	
	dff Conditions [2:0] (.q(flags),.d(), .wen(flag_enable), .clk(clk), rst)
	//RED
	reg error;
	always @ opcode begin
	flags = '0;
		case (opcode)
		(4'h0000): //Add
			ALU_Out = inter_adder;
			flags[0]= ~(|ALU_Out);
			flags[1]= ALU_Out[15];
			flags[2] = temp_Ovfl;
			error = 1'b0;
		(4'h0001): //Sub
			ALU_Out = inter_adder;
			flags[0]= ~(|ALU_Out);
			flags[1]= ALU_Out[15];
			flags[2] = temp_Ovfl;
			error = 1'b0;
		(4'h0010): //XOR
			ALU_Out = operand1 ^ operand2
			flags[0]= |ALU_Out;
			error = 1'b0;
		(4'h0011): //RED
			//FIXME TODO Implemet RED
			error = 1'b0;
		(4'h0100): //SLL
			ALU_Out = inter_shift;
			shift_mode = 00;
			flags[0]= |ALU_Out;
			error = 1'b0;
		(4'h0101): //SRA
		flags[0]= |ALU_Out;
			error = 1'b0;
		(4'h0110): //ROR
		flags[0]= |ALU_Out;
			error = 1'b0;
		(4'h0111): //PADDSB
		
			error = 1'b0;
		(4'h1000): //LW
			
			error = 1'b0;
		(4'h1001): //SW
			error = 1'b0;
			
			
		(4'h1010): //LLB
			error = 1'b0;
		(4'h1011): //LHB
			error = 1'b0;
		(4'h1100): //B
			error = 1'b0;
		(4'h1101): //BR
			error = 1'b0;
		(4'h1110): //PCS
			error = 1'b0;
		(4'h1111): //HLT
			error = 1'b0;
		default:
			error =1'b1;
		endcase
	end
	
endmodule 
