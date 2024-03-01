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
