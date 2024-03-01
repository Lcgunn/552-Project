
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
	assign Cout = G[3] | (P[3]&G[2]) | (P[3]&P[2]&G[1]) | (P[3]&P[2]&P[1]&G[0]) | (P[3]&P[2]&P[1]&P[0]&cin);

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

wire [15:0] interSum;
wire [15:0] interB;
wire [3:0] temp_error;
wire [3:0] carry;
assign interB = sub ? ~B : B;
assign Error = (pad)? (temp_error[0] | temp_error[1] | temp_error[2] | temp_error[3]) 
		: (interSum[15] ? (~A[15]&~B[15]) : (A[15] & B[15]));
assign Sum = (pad) ? interSum : ((Error) ? ((~A[15])? 16'h7FFF : 16'h8000) : interSum);

// Carry Look Ahead
carry_look_ahead CLA [3:0] (.Sum(interSum), .Ovfl(temp_error), .A(A), .B(B), .Cin({carry[2:0],sub}), .Cout(carry));

// Add/Sub
//carry_look_ahead Partial [3:0] (.Sum(interSum), .Ovfl(temp_error), .A(A), .B(B), .pad(pad), .cin({carry[2:0],sub}));
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




module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);
input [15:0] Shift_In; 	// This is the input data to perform shift operation on
input [3:0] Shift_Val; 	// Shift amount (used to shift the input data)
input  [1:0] Mode; 		// To indicate 0=SLL or 1=SRA 
output [15:0] Shift_Out; 	// Shifted output data

wire [15:0] shift3, shift2,shift1,shift0;
wire [15:0] ashift3, ashift2,ashift1,ashift0;
wire [15:0] rshift3, rshift2,rshift1,rshift0;
	assign shift3 = Shift_Val[3] ? (Shift_In << 8) : Shift_In;
	assign shift2 = Shift_Val[2] ? (shift3 << 4) : shift3;
	assign shift1 = Shift_Val[1] ? (shift2 << 2) : shift2;
	assign shift0 = Shift_Val[0] ? (shift1 << 1) : shift1;

	assign ashift3 = Shift_Val[3] ? ({{8{Shift_In[15]}},Shift_In[15:8]}) : Shift_In;
	assign ashift2 = Shift_Val[2] ? ({{4{ashift3[15]}},ashift3[15:4]}) : ashift3;
	assign ashift1 = Shift_Val[1] ? ({{2{ashift2[15]}},ashift2[15:2]}) : ashift2;
	assign ashift0 = Shift_Val[0] ? ({{1{ashift1[15]}},ashift1[15:1]}) : ashift1;

	assign rshift3 = Shift_Val[3] ? ({Shift_In[7:0],Shift_In[15:8]}) : Shift_In;
	assign rshift2 = Shift_Val[2] ? ({rshift3[3:0],rshift3[15:4]}) : rshift3;
	assign rshift1 = Shift_Val[1] ? ({rshift2[1:0],rshift2[15:2]}) : rshift2;
	assign rshift0 = Shift_Val[0] ? ({rshift1[0],rshift1[15:1]}) : rshift1;
	
	assign Shift_Out = Mode[1] ? rshift0 : (Mode[0] ? ashift0 : shift0);
endmodule



