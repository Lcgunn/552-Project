module ALU (output [15:0] ALU_Out, output [2:0] flags, input [3:0] opcode, input [15:0] operand1, input [15:0] operand2, input clk, input rst);
	wire[15:0] inter_adder;		// Output for adder (LW & SW too)
	wire [15:0] inter_shift;	// Output for shift
	wire [15:0] inter_RED;		// Output for red

	wire [3:0] shift_mode;
	reg [2:0] flaginput;//OVERFLOW[2]. NEGATIVE [1], ZERO IS [0]
	reg [2:0] flag_enable;
	wire [15:0] inter_operand2;
	wire temp_Ovfl;
	reg isub, ipad;
	// Implementing ADD/SUB/PADDSB
	PSA_16bit adder (.Sum(inter_adder),.Ovfl(temp_Ovfl), .A(operand1),.B(inter_operand2),.sub(isub),.pad(ipad));//FIXME SUB should be implemented
	
	// Implementing SLL/SRA/ROR
	Shifter shift(.Shift_out(inter_shift),.Shift_In(operand1),.Shift_Val(operand2[3:0]),.Mode(shift_mode));

	// Implementing RED
	RED red (.rs(operand1), .rt(operand2), .Sum(inter_RED)); 
	
	dff Conditions [2:0] (.q(flags),.d(flaginput), .wen(flag_enable), .clk(clk), .rst(rst));
	//RED
	reg error;
	always @ opcode begin
	isub = '0;
	ipad = '0;
	flag_enable = '0;
	inter_operand2 = operand2;
		case (opcode)
		(4'h0000): //Add
			ALU_Out = inter_adder;
			flaginput[0]= ~(|ALU_Out);	// If all bits are zero flag is 1
			flaginput[1]= ALU_Out[15];	// If MSB of sum is 1, then negative
			flaginput[2] = temp_Ovfl;	// If overflow, then overflow flag is 1
			error = 1'b0;
		(4'h0001): //Sub
			sub = '1;
			ALU_Out = inter_adder;
			flaginput[0]= ~(|ALU_Out);	// If all bits are zero flag is 1
			flaginput[1]= ALU_Out[15];	// If MSB of sum is 1, then negative
			flaginput[2] = temp_Ovfl;	// If overflow, then overflow flag is 1
			error = 1'b0;
		(4'h0010): //XOR
			ALU_Out = operand1 ^ operand2;
			flaginput[0]= ~(|ALU_Out);		// If all bits are zero flag is 1
			error = 1'b0;
		(4'h0011): //RED
			ALU_Out = inter_RED;
			error = 1'b0;
		(4'h0100): //SLL
			shift_mode = 2'b00;
			ALU_Out = inter_shift;
			flaginput[0]= ~(|ALU_Out);	// If all bits are zero flag is 1
			error = 1'b0;
		(4'h0101): //SRA
			shift_mode = 2'b01;
			ALU_Out = inter_shift;
			flaginput[0]= ~(|ALU_Out);	// If all bits are zero flag is 1
			error = 1'b0;
		(4'h0110): //ROR
			shift_mode = 2'b10;			// Mode can be 10 or 11
			ALU_Out = inter_shift;
			flaginput[0]= ~(|ALU_Out);	// If all bits are zero flag is 1
			error = 1'b0;
		(4'h0111): //PADDSB
			pad = '1;
			error = 1'b0;
		(4'h1000): //LW
			inter_operand2 = operand2 << 1;
			ALU_Out = inter_adder;
			error = 1'b0;
		(4'h1001): //SW
			inter_operand2 = operand2 << 1;
			ALU_Out = inter_adder;
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
