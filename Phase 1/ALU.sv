module ALU (output [15:0] ALU_Out, output [2:0] flags, input [3:0] opcode, input [15:0] operand1, input [15:0] operand2, input clk, input rst);
	wire[15:0] inter_adder;		// Output for adder (LW & SW too)
	wire [15:0] inter_shift;	// Output for shift
	wire [15:0] inter_RED;		// Output for red
	reg [15:0] inter_ALU_Out;

	reg [3:0] shift_mode;
	reg [2:0] flaginput;//OVERFLOW[2]. NEGATIVE [1], ZERO IS [0]
	reg [2:0] flag_enable;
	reg [15:0] inter_operand2;
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

	assign ALU_Out = inter_ALU_Out;

	reg error;
	always @ opcode begin
	isub = '0;
	ipad = '0;
	flag_enable = '0;
	inter_operand2 = operand2;
		case (opcode)
		(4'b0000): begin//Add
			inter_ALU_Out = inter_adder;
			flaginput[0] = ~(|inter_ALU_Out);	// If all bits are zero flag is 1
			flaginput[1] = inter_ALU_Out[15];	// If MSB of sum is 1, then negative
			flaginput[2] = temp_Ovfl;	// If overflow, then overflow flag is 1
			error = 1'b0;
			end
		(4'b0001): begin//Sub
			isub = '1;
			inter_ALU_Out = inter_adder;
			flaginput[0]= ~(|inter_ALU_Out);	// If all bits are zero flag is 1
			flaginput[1]= inter_ALU_Out[15];	// If MSB of sum is 1, then negative
			flaginput[2] = temp_Ovfl;	// If overflow, then overflow flag is 1
			error = 1'b0;
			end
		(4'b0010): begin //XOR
			inter_ALU_Out = operand1 ^ operand2;
			flaginput[0]= ~(|inter_ALU_Out);		// If all bits are zero flag is 1
			error = 1'b0;
			end
		(4'b0011): begin//RED
			inter_ALU_Out = inter_RED;
			error = 1'b0;
			end
		(4'b0100): begin //SLL
			shift_mode = 2'b00;
			inter_ALU_Out = inter_shift;
			flaginput[0]= ~(|inter_ALU_Out);	// If all bits are zero flag is 1
			error = 1'b0;
			end
		(4'b0101): begin //SRA
			shift_mode = 2'b01;
			inter_ALU_Out = inter_shift;
			flaginput[0]= ~(|inter_ALU_Out);	// If all bits are zero flag is 1
			error = 1'b0;
			end
		(4'b0110): begin //ROR
			shift_mode = 2'b10;			// Mode can be 10 or 11
			inter_ALU_Out = inter_shift;
			flaginput[0]= ~(|inter_ALU_Out);	// If all bits are zero flag is 1
			error = 1'b0;
			end
		(4'b0111): begin //PADDSB
			ipad = '1;
			error = 1'b0;
			end
		(4'b1000): begin //LW
			inter_operand2 = operand2 << 1;
			inter_ALU_Out = inter_adder;
			error = 1'b0;
			end
		(4'b1001): begin //SW
			inter_operand2 = operand2 << 1;
			inter_ALU_Out = inter_adder;
			error = 1'b0;
			end
		(4'b1010): begin //LLB
			error = 1'b0;
			end
		(4'b1011): begin //LHB
			error = 1'b0;
			end
		(4'b1100): begin //B
			error = 1'b0;
			end
		(4'b1101): begin //BR
			error = 1'b0;
			end
		(4'b1110): begin //PCS
			error = 1'b0;
			end
		(4'b1111): begin //HLT
			error = 1'b0;
			end
		default:
			error =1'b1;
		endcase
	end
	
endmodule 