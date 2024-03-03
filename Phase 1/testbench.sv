//Test Module for addsub_16bit
module t_addsub_16bit();
logic signed [15:0] A,B;
logic [15:0] Sum; //sum output
logic Ovfl; //To indicate overflow
logic pad;
logic isub;

addsub_16bit DUT (.Sum(Sum), .Error(Ovfl), .A(A), .B(B), .sub(isub), .pad(pad));

initial begin
	// Test Case 1: Negative overflow with padding
	pad = '1;
	isub = '0;
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

	//Test Case 2: Positive Overflow with padding
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

	//Test Case 3: Negative Overflow without padding
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

	//Test Case 4: Positive overflow without padding
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

	//Test Case 5: Random Test Cases
	repeat (8) begin
	pad = '0;
	isub = '1;
	A = $random();
	B = $random();
	#5;
	end
		
	//Test Case 6: Random Test Cases
	repeat (8) begin
	pad = '0;
	isub = '0;
	A = $random();
	B = $random();
	#5;
	end

	//Test Case 7: Zero Input
	#5
	A = 16'h0000;
	B = 16'h0000;
	#5
	if(Sum != 16'h0000) begin
		$display("Sum is %h, when it should be %h", Sum, 16'h0000);
		$stop();
	end
	if(Ovfl != 1'b0) begin
		$display("Ovfl incorrect value");
		$stop();
	end

	#10
		$display("Yahoooo!! Test passed");
		$stop();
		
end
endmodule

//Test Module for ALU
module t_ALU();
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
		//Test Case 0: Initial State Check
		 a = '0;
		 b = '0;
		 iOp = '0;
		$display("Hello!");
		#5
		if (out !== '0) begin
			$display("Wrong output");
			$stop();
		end

		//Test Case 1: Random inputs and Opcodes 
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

			//Test Case 2: Adder operation and overflow check
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

				//Test Case 3: Subtraction Operation and overflow check
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
			
			//Test Case 4: Logical operations (NAND and XOR)
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

module t_RED();
logic signed [15:0] rs, rt;
logic [15:0] Sum;

RED redDUT (.rs(rs), .rt(rt), .Sum(Sum));

initial begin
	//Test Case 1: Inputs are 0
	rs = 16'h0000;
	rt = 16'h0000;
	#5
	if(Sum != 16'h0000) begin	
		$display("Sum is %h, when it should be %h", Sum, 16'h0000);
		$stop();
	end
	
	// Test Case 2: Positive values
    	rs = 16'h1111;
    	rt = 16'h1111;
    	#5
    	if (Sum !== 16'h0044) begin
        	$display("Sum is %h, when it should be %h", Sum, 16'h0044);
        	$stop();
    	end

	//Test Case 3: Negative Values
	rs = 16'hF1F1;
    	rt = 16'hF1F1;
    	#5
    	if (Sum !== 16'hFFE4) begin
        	$display("Sum is %h, when it should be %h", Sum, 16'hFFE4);
        	$stop();
    	end
end
endmodule

module t_RegisterFile();
logic clk,rst,WriteReg;
logic [3:0] SrcReg1,SrcReg2,DstReg;
logic [15:0] DstData, SrcData1, SrcData2;
	
RegisterFile iDUT (.clk(clk),.rst(rst),.SrcReg1(SrcReg1),.SrcReg2(SrcReg2),.DstReg(DstReg),.WriteReg(WriteReg),.DstData(DstData),.SrcData1(SrcData1),.SrcData2(SrcData2));
always
#5 clk <= ~clk;
initial begin
	clk = 0;
	rst = 1;
	#10;
	assert(DstData === '0 & SrcData1 === '0 & SrcData2 === '0)
	else begin
		$display("Bad Reset");
		$stop();
	end
	#10;
	$display("Wahooooo!!! Test Passed");
	$stop();
end
endmodule

module t_shifter();
logic [15:0] Shift_In;
logic [3:0] Shift_Val;
logic [1:0] Mode;
logic [15:0] Shift_Out;

Shifter shifterDUT (.Shift_Out(Shift_Out), .Shift_In(Shift_In), .Shift_Val(Shift_Val), .Mode(Mode));

initial begin 
	//Test Case 1: SLL
	Shift_In = 16'hAAAA;
	Shift_Val = 4'b0101;
	Mode = 2'b00;
	#10;
	if (Shift_Out !== 16'h5400) begin
		$display("Shift_Out is %h when it should be %h", Shift_Out, 16'h5400);
		$stop();
	end

	//Test Case 2: SRA
	Shift_In = 16'hFFFE;
	Shift_Val = 4'b0010;
	Mode = 2'b01;
	#10;
	if (Shift_Out !== 16'hFFFE) begin
		$display("Shift_Out is %h when it should be %h", Shift_Out, 16'hFFFE);
		$stop();
	end

	//Test Case 3: ROR
	Shift_In = 16'h1234;
	Shift_Val = 4'b0101;
	Mode = 2'b10;
	#10;
	if (Shift_Out !== 16'h1234) begin
		$display("Shift_Out is %h when it should be %h", Shift_Out, 16'h1234);
		$stop();
	end
	#10;
	$display("Wahooooo!!! Test Passed");
	$stop();
end
endmodule
