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
