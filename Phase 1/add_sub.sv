//Simple 1 bit adder
module full_adder_1bit (input A, input B, input Cin, output S, output Cout);
	assign S = A ^ B ^ Cin;
	assign Cout = (A&B) | (Cin & (A | B));
endmodule

module addsub_16bit (Sum, Error, A, B, sub, pad);
input [15:0] A, B; 	// Input data values
input sub;			// To indicate sub or add
input pad;			// To indicate pad or not pad
output [15:0] Sum; 	// Sum output
output Error; 		// To indicate overflows

// 
wire [15:0] interSum;
wire [3:0] temp_error;
wire [3:0] carry;
assign Error = (pad)? (temp_error[0] | temp_error[1] | temp_error[2] | temp_error[3]) 
		: (interSum[15] ? (~A[15]&~B[15]) : (A[15] & B[15]));
assign Sum = (pad) ? interSum : ((Error) ? ((~A[15])? 16'h7FFF : 16'h8000) : interSum);

// Carry Look Ahead
carry_look_ahead CLA [3:0] (.A(A), .B(B), .Cin({carry[2:0],sub}), .Cout(carry));

// Add/Sub
carry_look_ahead Partial [3:0] (.Sum(interSum), .Ovfl(temp_error), .A(A), .B(B), .pad(pad), .cin({carry[2:0],sub}));
endmodule

module RED (rs, rt, Sum); 
input [15: 0] rs, rt; // Input Data Values
output [15:0] Sum; // Final Sum of Values

wire [8:0] totalsumAB;
wire [8:0] totalsumCD;
wire [7:0] sumAB;
wire [7:0] sumCD;
wire [1:0] carry;
wire [11:0] interSum;

//tree layer 1
carry_look_ahead CLA1 [1:0] (.Sum(sumAB), .Ovfl(), .A(rs[15:8]), .B(rs[7:0]), .Cin('0), .Cout(carry[0]));
carry_look_ahead CLA2 [1:0] (.Sum(sumCD), .Ovfl(), .A(rt[15:8]), .B(rt[7:0]), .Cin('0), .Cout(carry[1]));
assign totalsumAB = ({carry[0], sumAB});
assign totalsumCD = ({carry[1], sumCD});

assign Sum = {{6{interSum[9]}}, interSum};

//tree layer 2
carry_look_ahead CLA3 [2:0] (.Sum(interSum), .Ovfl(), .A({{3{totalsumAB[7]}}, totalsumAB}), .B({{3{totalsumCD[7]}}, totalsumCD}), .Cin('0), .Cout());

endmodule






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
