
//Simple 1 bit adder
module full_adder_1bit (input A, input B, input Cin, output S, output Cout);
	assign S = A ^ B ^ Cin;
	assign Cout = (A&B) | (Cin & (A | B));
endmodule

//Instantiates full_adder_1bit to make it 4 wide
//overflow is determined by seperate logic than carry out
module carry_look_ahead (Sum, Ovfl, A, B, pad, cin, Cout);
	input pad; //pad-notpad indicator
	input [3:0] A, B; //Input values
	input cin;
	output [3:0] Sum; //sum output
	output Ovfl; //To indicate overflow
	output Cout;
	wire ovfl;
	wire interCin;
	wire [3:0] interC;
	wire [3:0] interB;
	wire [3:0] interSum;
	assign interB = sub ? ~B : B;
	assign interCin = (pad) ? '0 : cin;
	wire [3:0] P, G;

	// Get propagate for each bit
	assign P[0] = A[0] ^ B[0];
	assign P[1] = A[1] ^ B[1];
	assign P[2] = A[2] ^ B[2];
	assign P[3] = A[3] ^ B[3];

	// Get generate for each bit
	assign G[0] = A[0] & B[0];
	assign G[1] = A[1] & B[1];
	assign G[2] = A[2] & B[2];
	assign G[3] = A[3] & B[3];

	// Calculate carry-outs
	//assign Cout[0] = G[0] ^ (P[0]&Cin);
	//assign Cout[1] = G[1] ^ (P[1]&G[0]) ^(P[1]&P[0]&Cin);
	//assign Cout[2] = G[2] ^ (P[2]&G[1]) ^ (P[2]&P[1]&G[0]) ^(P[2]P[1]&P[0]&Cin);
	assign Cout = G[3] | (P[3]&G[2]) | (P[3]&P[2]&G[1]) | (P[3]&P[2]&P[1]&G[0]) | (P[3]&P[2]&P[1]&P[0]&Cin);

	//note interB is not technically full2s compliment, but its close enough for the calculation needed
	assign Ovfl = (interSum[3] ? (~A[3]&~interB[3]) : (A[3] & interB[3])); 
	// Saturating arithmetic
	assign Sum = (pad)? ((Ovfl) ? ((~A[3])? 4'b0111 : 4'b1000): interSum) : interSum;

	full_adder_1bit FA [3:0]  (.A(A),.B(interB),.Cin({interC[2:0],interCin}),.Cout(interC),.S(interSum));
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


module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);
input [15:0] Shift_In; 	// This is the input data to perform shift operation on
input [3:0] Shift_Val; 	// Shift amount (used to shift the input data)
input  Mode; 		// To indicate 0=SLL or 1=SRA //sim:/saturate_tb/Ovfl
output [15:0] Shift_Out; 	// Shifted output data


wire [15:0] shift3, shift2,shift1,shift0;
wire [15:0] ashift3, ashift2,ashift1,ashift0;
	assign ashift3 = Shift_Val[3] ? ({{8{Shift_In[15]}},Shift_In[15:8]}) : Shift_In;
	assign ashift2 = Shift_Val[2] ? ({{4{ashift3[15]}},ashift3[15:4]}) : ashift3;
	assign ashift1 = Shift_Val[1] ? ({{2{ashift2[15]}},ashift2[15:2]}) : ashift2;
	assign ashift0 = Shift_Val[0] ? ({{1{ashift1[15]}},ashift1[15:1]}) : ashift1;
//sim:/saturate_tb/Ovfl
	assign Shift_Out = Mode ? ashift0 : shift0;
endmodule


module RED (rs, rt, Sum); 
input [15, 0] rs, rd; // Input Data Values
output [8:0] Sum; // Final Sum of Values

wire [8:0] totalsumAB;
wire [8:0] totalsumCD;
wire [7:0] sumAB;
wire [7:0] sumCD;
wire [1:0] carry;

//tree layer 1
carry_look_ahead CLA1 [1:0] (.Sum(sumAB), .Ovfl(), .A(rs[15:8]), .B(rs[7:0]), .Cin(0), .Cout(carry[0]));
carry_look_ahead CLA2 [1:0] (.Sum(sumCD), .Ovfl(), .A(rt[15:8]), .B(rt[7:0]), .Cin(0), .Cout(carry[1]));
totalsumAB = {carry[0], sumAB}
totalsumCD = {carry[1], sumCD}

//tree layer 2
carry_look_ahead CLA3 [2:0] (.Sum(Sum), .Ovfl(), .A(totalsumAB), .B(totalsumCD), .Cin(0), .Cout());

endmodule






module saturate_tb();
logic signed [15:0] A,B;
logic [15:0] Sum; //sum output
logic Ovfl; //To indicate overflow
logic pad;

addsub_16bit DUT (.Sum(Sum), .Error(Ovfl), .A(A), .B(B), .pad(pad));

initial begin
	pad = '1;
	A = 16'h8009;
	B = 16'h9009;
	#5
	if(Sum != 16'h8008) begin
		$display("Sum is %h, when it should be %h", Sum, 16'h8008);
		$stop();
	end
	if(!Ovfl) begin
		$display("Should be negative overflow");
		$stop();
	end
	#5
	A = 16'h0FD8;
	B = 16'h0019;
	#5
	if(Sum != 16'h0FE8) begin
		$display("Sum is %h, when it should be %h", Sum, 16'h0FEF);
		$stop();
	end
	if(!Ovfl) begin
		$display("Should be positive overflow");
		$stop();
	end
	#5
	pad = !pad;
	A = 16'h8800;
	B = 16'h8901;
	#5
	if(Sum != 16'h8000) begin
		$display("Sum is %h, when it should be %h", Sum, 16'h8000);
		$stop();
	end
	if(!Ovfl) begin
		$display("Should be negative overflow");
		$stop();
	end
	#5
	A = 16'h7FFF;
	B = 16'h0001;
	#5
	if(Sum != 16'h7FFF) begin
		$display("Sum is %h, when it should be %h", Sum, 16'h7FFF);
		$stop();
	end
	if(!Ovfl) begin
		$display("Should be positive overflow");
		$stop();
	end
	#10
		$display("Yahoooo!! Test passed");
		$stop();
end
endmodule

//Test bench fo 4 bit adder
`timescale 1ns/100ps
module t_carry_look_ahead;
	logic signed [3:0] a;
	logic signed  [3:0] b;
	//These ints are used to calculate overflow later. This is so the same
	//logic that is used to calculate the DUT overflow is not the same as
	//the testbench
	int a_in;
	int b_in;
	reg sub;
	reg iover;
	wire signed [3:0] sum;
	
	carry_look_ahead iDUT (.Sum(sum),.Ovfl(iover),.A(a),.B(b),.sub(sub));

	initial begin
		 a = '0;
		 b = '0;
		 sub = 0;
		# 5
		if (iDUT.Sum !== '0) begin
			$display("Wrong output");
			$stop();
		end
		$display("Right Start");
		repeat (128) begin
			a = $random();
			b = $random();
			sub = $random();
			a_in = a;
			b_in = b;
			#5
			if (!sub) begin
				//check for overflow flag
				if (a_in + b_in > 7 || a_in + b_in < -8) begin
					assert(iover === 1'b1) $display("overflow checking...");
					else begin
						$display("Error");
						$stop();

					end
				end
				else begin
					assert(iover === 1'b0)
					else begin
						$display("Overflow error with adder going over");
						$stop();
					end
				end
				//check sum with normal bits
				if (iDUT.Sum !== a + b) begin
					$display("Error");
					$stop();
				end
			end else begin
				if (a_in - b_in < -8 || a_in - b_in  > 7) begin
					assert(iover === 1'b1) $display("overflow checking...");
					else begin
						$display("Error");
						$stop();

					end
				end
				else begin
					assert(iover === 1'b0)
					else begin
						$display("Overflow error with adder going over");
						$stop();
					end
				end
				if (iDUT.Sum !== a - b) begin
					$display("Error");
					$stop();
				end
			end
		end
		$display("Wahooooo!!! Test Passed");
		#10 $stop();
	end

endmodule
module t_ALU;
	logic signed [3:0] a;
	logic signed  [3:0] b;
	logic [1:0] iOp;
	int a_in;
	int b_in;
	reg iover;
	wire signed [3:0] out;
	
	ALU iDUT (.ALU_Out(out), .Error(iover), .ALU_In1(a), .ALU_In2(b), .Opcode(iOp));

	//The default case statement should never go high; this always
	//statements outside of the initial statement keeps tabs on that
	always @ (posedge iDUT.flag) begin
		$display("ERROR! opcode mux reached default statement %d", iDUT.flag );
		$stop();
	end

	initial begin
		 a = '0;
		 b = '0;
		 iOp = '0;
		$display("Hello!");
		#5
		if (out !== '0) begin
			$display("Wrong output");
			$stop();
		end

		$display("Right Start");
		repeat (256) begin
			a = $random();
			b = $random();
			iOp = $random();
			a_in = a;
			b_in = b;
			#5

			assert(iDUT.flag !== 1) 
			else begin
				$display("ERROR! opcode mux reached default statement %d", iDUT.flag );
				$stop();
			end
			//The upper bit of opcode determines add or sub
			if (iOp[1] == 0) begin 
				if (!iOp[0]) begin
					if (a_in + b_in > 7) begin
						assert(iover === 1'b1) $display("overflow check");
						else begin
							$display("Error");
							$stop();

						end
					end
					else begin
						assert(iover === 1'b0)
						else begin
							$display("Overflow error with adder going over");
							$stop();
						end
					end
					if (out !== a + b) begin
						$display("Error");
						$stop();
					end
				end 
				else begin
					if (a_in - b_in < -8) begin
						assert(iover === 1'b1) $display("overflow check");
						else begin
							$display("Error");
							$stop();
						end
					end
					else begin
						assert(iover === 1'b0)
						else begin
							$display("Overflow error with adder going over");
							$stop();
						end
					end
					if (out !== a - b) begin
						$display("Error");
						$stop();
					end
				end
			end 
			//lower opcode bit checks the NAND and XOR
			else begin
				//There cannot be an overflow error in logical
				//operations
				assert(iover === 1'b0)
				else begin
					$display("Error");
					$stop();
				end
				if (iOp[0] === 0) begin
					assert( out === ~(a & b))
					else begin
						$display("Error");
						$stop();
					end
				end
				else begin
					assert( out === a ^ b)
					else begin
						$display("Error");
						$stop();
					end
				end
			end
		end
		$display("Yahooooo!!! Test Passed");
		#10 $stop();
	end

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
