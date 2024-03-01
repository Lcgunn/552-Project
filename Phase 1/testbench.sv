module t_RED();
logic signed [15:0] rs, rt;
logic [15:0] Sum;

RED redDUT (.rs(rs), .rt(rt), .Sum(Sum));

initial begin
	rs = 16'h1111;
	rt = 16'h1111;
	#5
	if(Sum != 16'h2222) begin	
		$display("Sum is %h, when it should be %h", Sum, 16'h2222);
		$stop();
	end
	#5;
end
endmodule
