//Simple 1 bit adder
module full_adder_1bit (input A, input B, input Cin, output S, output Cout);
	assign S = A ^ B ^ Cin;
	assign Cout = (A&B) | (Cin & (A | B));
endmodule

//Instantiates full_adder_1bit to make it 4 wide
//overflow is determined by seperate logic than carry out
module addsub_4bit (Sum, Ovfl, A, B, sub, pad, cin);
	input [3:0] A, B; //Input values
	input sub; // add-sub indicator
	input pad; //pad-notpad indicator
	input cin;
	output [3:0] Sum; //sum output
	output Ovfl; //To indicate overflow
	wire ovfl;
	wire interCin;
	wire [3:0] interC;
	wire [3:0] interB;
	wire [3:0] interSum;
	assign interB = sub ? ~B : B;
	assign interCin = (pad) ? sub : cin ^ sub;

	//note interB is not technically full2s compliment, but its close enough for the calculation needed
	assign Ovfl = (interSum[3] ? (~A[3]&~interB[3]) : (A[3] & interB[3])); 
	// Saturating arithmetic
	assign Sum = (pad)? ((Ovfl) ? ((~A[3])? 4'b0111 : 4'b1000): interSum) : interSum;

	full_adder_1bit FA [3:0]  (.A(A),.B(interB),.Cin({interC[2:0],interCin}),.Cout(interC),.S(interSum));
endmodule


module addsub_16bit (Sum, Error, A, B, pad);
input [15:0] A, B; 	// Input data values
input pad;			// To indicate pad or not pad
output [15:0] Sum; 	// Sum output
output Error; 	// To indicate overflows
wire [15:0] interSum;
wire [3:0] temp_error;
assign Error = (pad)? (temp_error[0] | temp_error[1] | temp_error[2] | temp_error[3]) 
		: (interSum[15] ? (~A[15]&~B[15]) : (A[15] & B[15]));
assign Sum = (pad) ? interSum : ((Error) ? ((~A[15])? 16'h7FFF : 16'h8000) : interSum);
addsub_4bit Partial1 (.Sum(interSum[3:0]), .Ovfl(temp_error[0]), .A(A[3:0]), .B(B[3:0]), .sub('0), .pad(pad), .cin('0));
addsub_4bit Partial2 (.Sum(interSum[7:4]), .Ovfl(temp_error[1]), .A(A[7:4]), .B(B[7:4]), .sub('0), .pad(pad), .cin(temp_error[0]));
addsub_4bit Partial3 (.Sum(interSum[11:8]), .Ovfl(temp_error[2]), .A(A[11:8]), .B(B[11:8]), .sub('0), .pad(pad), .cin(temp_error[1]));
addsub_4bit Partial4 (.Sum(interSum[15:12]), .Ovfl(temp_error[3]), .A(A[15:12]), .B(B[15:12]), .sub('0), .pad(pad), .cin(temp_error[2]));
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
