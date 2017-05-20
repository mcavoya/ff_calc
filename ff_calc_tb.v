`timescale 1ns / 1ps

module ffCalc_tb;

	// Inputs
	reg clk;
	reg strobe;
	reg [3:0] token;

	// Outputs
	wire ready;
	wire [3:0] answer;

	// Instantiate Unit Under Test (UUT)
	ffCalc ff_calc(
		.clk(clk),
		.strobe(strobe),
		.token(token),
		.ready(ready),
		.answer(answer)
	);

	// 40MHz clock
	always begin
		#12 clk = 0;
		#13 clk = 1;
	end

	initial begin
		// create files for waveform viewer
		$dumpfile("ff_calc.lxt");
		$dumpvars;

		// Initialize Inputs
		clk = 1;
		strobe = 0;
		token = 4'h0;

		// 3 + 4 =
		puttok(4'hF); // clear
		puttok(4'h3); // 3
		puttok(4'hA); // +
		puttok(4'h4); // 4
		puttok(4'hE); // =

		// 7 - 8 / 4 =
		puttok(4'hF); // clear
		puttok(4'h7); // 7
		puttok(4'hB); // -
		puttok(4'h8); // 8
		puttok(4'hD); // /
		puttok(4'h4); // 4
		puttok(4'hE); // =

		// 3 + 4 * 2 - 1 =
		puttok(4'hF); // clear
		puttok(4'h3); // 3
		puttok(4'hA); // +
		puttok(4'h4); // 4
		puttok(4'hC); // *
		puttok(4'h2); // 2
		puttok(4'hB); // -
		puttok(4'h1); // 1
		puttok(4'hE); // =

		// Finished
		#100 $display("finished");
		$finish;
	end

	task puttok;
		input [3:0] value;
		begin
			wait(!clk) #1 token = value;
			wait(clk) #1 strobe = 1;
			wait(!clk);
			wait(clk) #1 strobe = 0;
			wait(!clk);
			wait(ready);
		end
	endtask

endmodule
