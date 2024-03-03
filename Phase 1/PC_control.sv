`default_nettype none
module PC_control(input [2:0]C, input [8:0] I, input [2:0] F, input branch, input [15:0] PC_in, output [15:0] PC_out);
	//Overflow is [2], Negative[1], Zero[0]	
	//wire [2:0] C;
	//wire [8:0] I;
	//wire [2:0] F;
	reg [15:0] calculated_pc,normal_pc, inter_PC_out;
	
	PSA_16bit normal (.Sum(normal_pc),.Ovfl(), .A(PC_in),. B(16'h0002),.Sub(0),.pad(0));
	PSA_16bit immediate (.Sum(calculated_pc),.Ovfl(), .A(normal_pc),. B(I << 1),.Sub(0),.pad(0));
	
	// If branch instruction, take the pc decided, else go to next pc address
	assign PC_out = (branch)? inter_PC_out : normal_pc;

	//Watch out for the reset
	reg error;
	always @ (C,I,F) begin
	error = 1'b0;
	//Overflow is [2], Negative[1], Zero[0]
		case(C) 
			3'b000: //Not Equal
				inter_PC_out = ~F[0] ? calculated_pc : normal_pc; 	
			3'b001: //Equal
				inter_PC_out = F[0] ? calculated_pc : normal_pc;
			3'b010: //Greater Than
				inter_PC_out = (~F[0] & ~F[1]) ? calculated_pc : normal_pc;	
			3'b011: //Less Than
				inter_PC_out = F[1] ? calculated_pc : normal_pc;
			3'b100: //Greater Than or Equal
				inter_PC_out = (F[0] | (~F[0] & ~F[1])) ? calculated_pc : normal_pc;	
			3'b101: //Less Than or Equal
				inter_PC_out = (F[0] | F[1]) ? calculated_pc : normal_pc;			
			3'b110: //Overflow
				inter_PC_out = (F[2]) ? calculated_pc : normal_pc;	
			3'b111: //Unconditional
				inter_PC_out = calculated_pc;
			default:
				error = 1'b1;
		endcase
	end
endmodule

module t_PC_control ();
	logic [2:0] iC;
	logic signed [8:0] iI;
	logic [2:0] iF;
	logic [15:0] iPC_in, iPC_out;
	PC_control iDUT (.C(iC), .I(iI), .F(iF), .PC_in(iPC_in), .PC_out(iPC_out));

	initial begin
		iC = '0;
		iF = '0;
		iI ='0;
		iPC_in = '0;
		#5;
	end
endmodule
