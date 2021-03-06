/*
	Four Function Calculator

	strobe is used to enter a new token
	tokens are BCD 0 through 9, plus
		A : + (addition)
		B : - (subtraction)
		C : * (multiplication)
		D : / (division)
		E : = (equals)
		F : clear

	MUST first enter clear to initialize each calculation
*/

module ffCalc (

	input clk,					// clock
	input strobe,				// active-high synchronous write enable
	input [3:0] token,			// infix expression input

	output ready,				// active-high ready to accept next token
	output [3:0] answer			// intermediate and final answers
);

	// functions
	parameter token_ADD	= 4'hA;
	parameter token_SUB	= 4'hB;
	parameter token_MUL	= 4'hC;
	parameter token_DIV	= 4'hD;
	parameter token_EQU	= 4'hE;
	parameter token_CLR	= 4'hF;

	// ff_calc states
	parameter fsm_IDLE			= 3'd0; // waiting for token
	parameter fsm_WAIT			= 3'd1; // waiting for shunting yard
	parameter fsm_CALC			= 3'd2; // calculate answer
	parameter fsm_PUSH_NUMBER	= 3'd3; // push number onto stack
	parameter fsm_EXECUTE		= 3'd4; // do arithmetic function

	// convert infix to RPN
	wire rd_en;					// active-high synchronous read enable for shunting yard output_queue
	wire shunt_yard_ready;		// active-high when shunting yard is ready to accept next token
	wire [3:0] output_queue;	// shunting yard postfix expression output
	ShuntingYard shunt_yard(
		.clk(clk),
		.rd_en(rd_en),
		.wr_en(strobe),
		.token(token),
		.ready(shunt_yard_ready),
		.output_queue(output_queue)
	);

	// helper signals
	wire clear = strobe & (token_CLR==token);
	wire is_equal = (token_EQU==token);
	wire is_number = (output_queue < 4'hA);
	wire is_finished = (token_EQU==output_queue);

	// ff_calc FSM
    reg [2:0] state = fsm_IDLE;
    reg [2:0] next_state = fsm_IDLE;
    always @(posedge clk) begin
      if (clear) state <= fsm_IDLE;
      else state <= next_state;
    end

    // next state logic
    always @* begin
      case (state)
		// idle, wait for a token
        fsm_IDLE  : if (strobe) next_state = fsm_WAIT;
					else next_state = fsm_IDLE;

		// wait for shunting yard
		fsm_WAIT : if (shunt_yard_ready) next_state = is_equal ? fsm_CALC : fsm_IDLE;
				   else next_state = fsm_WAIT;

		// do calculation
        fsm_CALC : if (is_number) next_state = fsm_PUSH_NUMBER;
				   else next_state = is_finished ? fsm_IDLE : fsm_EXECUTE;

		// push number onto stack
        fsm_PUSH_NUMBER : next_state = fsm_CALC;

		// do operation
		fsm_EXECUTE : next_state = fsm_CALC;

        default: next_state = fsm_IDLE;
      endcase
    end

	// FSM outputs
	assign ready = (fsm_IDLE==state);
	assign rd_en = (fsm_PUSH_NUMBER==state) | (fsm_EXECUTE==state);

	// stack
	reg [3:0] stack[0:7];
    always @(posedge clk) begin
		if (fsm_PUSH_NUMBER==state) stack[stack_pointer] <= output_queue;
		else if (fsm_EXECUTE==state) stack[stack_pointer-2] <= accumulator;
	end

	reg [2:0] stack_pointer = 3'd0;
    always @(posedge clk) begin
		if (clear) stack_pointer <= 3'd0;
		else if (fsm_PUSH_NUMBER==state) stack_pointer <= stack_pointer + 1'd1;
		else if (fsm_EXECUTE==state) stack_pointer <= stack_pointer - 1'd1;
	end

	// ALU
	reg [3:0] accumulator;
	always @* begin
		case (output_queue)
			token_ADD : accumulator = stack[stack_pointer-2] + stack[stack_pointer-1];
			token_SUB : accumulator = stack[stack_pointer-2] - stack[stack_pointer-1];
			token_MUL : accumulator = stack[stack_pointer-2] * stack[stack_pointer-1];
			token_DIV : accumulator = stack[stack_pointer-2] / stack[stack_pointer-1];
			default : accumulator = 4'd0;
		endcase
	end

	// update output
	reg [3:0] answer = 4'd0;
    always @(posedge clk) begin
		if (clear) answer <= 4'd0;
		else if (fsm_EXECUTE==state) answer <= accumulator;
	end

endmodule
