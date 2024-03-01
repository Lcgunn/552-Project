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
