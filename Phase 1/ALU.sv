module ALU (ALU_Out, Error, ALU_In1, ALU_In2, Opcode);
input [3:0] ALU_In1, ALU_In2;
input [1:0] Opcode; 
output reg [3:0] ALU_Out;
output reg Error; // Just to show overflow
wire [3:0] sum;
wire ovfl;
reg flag;

	carry_look_ahead Adder (.Sum(sum),.Ovfl(ovfl),.A(ALU_In1),.B(ALU_In2),.sub(Opcode[0]));
	always @ (Opcode, ALU_In1, ALU_In2) begin
		case (Opcode)
		2'b10 :
		begin	ALU_Out = ~(ALU_In1 & ALU_In2);
			Error = 0'b0;
			flag = 0'b0;
		end
		2'b11 :
		begin	ALU_Out = ALU_In1 ^ ALU_In2;
			Error = 0'b0;
			flag = 0'b0;
		end
		2'b00:
		begin	ALU_Out = sum;
			Error = ovfl;
			flag = 0'b0;
		end
		2'b01:
		begin	ALU_Out = sum;
			Error = ovfl;
			flag = 0'b0;
		end
		//This case should never be reached. If it is, testbench
		//should throw and error
		default:
			flag = 1'b1;
		endcase
	end

endmodule

