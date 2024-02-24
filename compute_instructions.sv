//Simple 1 bit adder
module full_adder_1bit (input A, input B, input Cin, output S, output Cout);
	assign S = A ^ B ^ Cin;
	assign Cout = (A&B) | (Cin & (A | B));
endmodule

//Instantiates full_adder_1bit to make it 4 wide
//overflow is determined by seperate logic than carry out
module addsub_4bit (Sum, Ovfl, A, B, sub);
	input [3:0] A, B; //Input values
	input sub; // add-sub indicator
	output [3:0] Sum; //sum output
	output Ovfl; //To indicate overflow
	wire ovfl;
	wire [3:0] interC;
	wire [3:0] interB;
	wire [3:0] interSum;
	assign interB = sub ? ~B : B;

	//note interB is not technically full2s compliment, but its close enough for the calculation needed
	assign Ovfl = (interSum[3] ? (~A[3]&~interB[3]) : (A[3] & interB[3])); 
	// Saturating arithmetic
	assign Sum = (Ovfl) ? ((~A[3])? 4'b0111 : 4'b1000): interSum;

	full_adder_1bit FA [3:0]  (.A(A),.B(interB),.Cin({interC[2:0],sub}),.Cout(interC),.S(interSum));
endmodule

module PSA_16bit (Sum, Error, A, B);
input [15:0] A, B; 	// Input data values
output [15:0] Sum; 	// Sum output
output Error; 	// To indicate overflows
wire [3:0] temp_error;

	assign Error = |temp_error;//sim:/saturate_tb/Ovfl


	addsub_4bit Partial [3:0]  (.Sum(Sum), .Ovfl(temp_error), .A(A), .B(B), .sub('0));
endmodule

module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);
input [15:0] Shift_In; 	// This is the input data to perform shift operation on
input [3:0] Shift_Val; 	// Shift amount (used to shift the input data)
input  Mode; 		// To indicate 0=SLL or 1=SRA 
output [15:0] Shift_Out; 	// Shifted output data

wire [15:0] shift3, shift2,shift1,shift0;
wire [15:0] ashift3, ashift2,ashift1,ashift0;
	assign shift3 = Shift_Val[3] ? (Shift_In << 8) : Shift_In;
	assign shift2 = Shift_Val[2] ? (shift3 << 4) : shift3;
	assign shift1 = Shift_Val[1] ? (shift2 << 2) : shift2;
	assign shift0 = Shift_Val[0] ? (shift1 << 1) : shift1;

	assign ashift3 = Shift_Val[3] ? ({{8{Shift_In[15]}},Shift_In[15:8]}) : Shift_In;
	assign ashift2 = Shift_Val[2] ? ({{4{ashift3[15]}},ashift3[15:4]}) : ashift3;
	assign ashift1 = Shift_Val[1] ? ({{2{ashift2[15]}},ashift2[15:2]}) : ashift2;
	assign ashift0 = Shift_Val[0] ? ({{1{ashift1[15]}},ashift1[15:1]}) : ashift1;

	assign Shift_Out = Mode ? ashift0 : shift0;
endmodule

module saturate_tb();
logic signed [3:0] A,B;
logic [3:0] Sum; //sum output
logic Ovfl; //To indicate overflow

addsub_4bit DUT (.Sum(Sum), .Ovfl(Ovfl), .A(A), .B(B), .sub('0));

initial begin
	A = 4'b1001;
	B = 4'b1001;
	#5
	if(Sum != 4'b1000) begin
		$display("Sum is %d, when it should be -8", Sum);
		$stop();
	end
	if(!Ovfl) begin
		$display("Should be negative overflow");
		$stop();
	end
	#5
	A = 4'b0111;
	B = 4'b0001;
	#5
	if(Sum != 4'b0111) begin
		$display("Sum is %d, when it should be 7", Sum);
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