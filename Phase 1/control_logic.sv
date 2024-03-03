			//this determines if the alu gets imm or reg
module control_logic(input [3:0]Instr, output Jump, output reg Branch, output reg MemRead, output reg MemtoReg, output reg ALUOp, output reg Memwrite, output reg ALU_Src, output reg RegWrite);
	
	always @Instr begin
	Jump = '0;
	Branch = '0;
	


	case(Instr)
		(4'b0000): begin //Add
			
			
			end
		(4'b0001): begin //Sub
			
			end
		(4'b0010): begin //XOR
			
			end
		(4'b0011): begin //RED
			
			end
		(4'b0100): begin //SLL
			
			end
		(4'b0101): begin //SRA
			
			end
		(4'b0110): begin //ROR
			
			end
		(4'b0111): begin //PADDSB
			
			end
		(4'b1000): begin //LW
			
			end
		(4'b1001): begin //SW
			
			end
		(4'b1010): begin //LLB
			
			end
		(4'b1011): begin //LHB
			
			end
		(4'b1100): begin //B	
			
			end
		(4'b1101): begin //BR	

			end
		(4'b1110): begin //PCS	

			end
		(4'b1111): begin //HLT	

			end
		default:
			error =1'b1;
		endcase
	end
	
endmodule 