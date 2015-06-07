/*****************************************************************************
 *                                     LDA Circuit Module                            *
 *****************************************************************************
 *
 * This file implements the optimized Bresenham's line algorithm.
 * The algorithm is designed to draw a line between points (x0,y0) and (x1,y1).
 * The algorithm is given below:
 *  ------------------------------------------------------------
 *	 function line_drawing_algorithm(x0, y0, x1, y1)
 *   {
 *	     boolean steep = abs(y1 - y0) > abs(x1 - x0)
 *	     if steep then
 *	         swap(x0, y0)
 *	         swap(x1, y1)
 *	     if x0 > x1 then
 *	         swap(x0, x1)
 *	         swap(y0, y1)
 *	     int deltax = x1 - x0
 *	     int deltay = abs(y1 - y0)
 *	     int error = -deltax / 2
 *	     int ystep
 *	     int y = y0
 *	     if y0 < y1 then ystep = 1 else ystep = -1
 *	     for x from x0 to x1
 *	         if steep then plot(y,x) else plot(x,y)
 *	         error = error + deltay
 *	         if error > 0 then
 *	             y = y + ystep
 *	             error = error - deltax
 *   }
 *****************************************************************************/

`define IDLE_STATE    0
`define DRAWING_STATE 1
`define WAITING_STATE 2
`define DONE_STATE    3

module LDA_circuit(
		// clock and reset signals
		input				clk,
		input				resetn,

		// signals communicate with ASC
		input				Go,
		input  [8:0]	X0, X1,
		input  [7:0] 	Y0, Y1,
		output reg			Done,

		// signals communicate with AMC
		input				     Write_Finish,
		output reg			 Draw,
    output [31:0]	   Pixel_Address,

		// inout signal, its value is unchanged in this module
		inout  [15:0]		Color,
		input  [31:0] 	Base_Addr
);

/*******************************************************************************/
/*                        Please Write your code below                         */
/*******************************************************************************/

// Holds abs(x1 - x0)
wire [8:0] abs_x_difference;
assign abs_x_difference = ($signed(X1 - X0) > 0) ? X1 - X0 : X0 - X1;

// Holds abs(y1 - y0)
wire [7:0] abs_y_difference;
assign abs_y_difference = ($signed(Y1 - Y0) > 0) ? Y1 - Y0 : Y0 - Y1;

// True if the line is steep
wire is_steep;
assign is_steep = (abs_y_difference > abs_x_difference);

wire [8:0] X0_temp, X1_temp, Y0_temp, Y1_temp;

// Swap the X's with the Y's depending on steepness of the line
assign X0_temp = is_steep ? Y0 : X0;
assign X1_temp = is_steep ? Y1 : X1;
assign Y0_temp = is_steep ? X0 : Y0;
assign Y1_temp = is_steep ? X1 : Y1;

// True if we need to reverse the X values (x0 > x1)
wire x_reverse;
assign x_reverse = (X0_temp > X1_temp);

wire [8:0] X0_new, X1_new, Y0_new, Y1_new;

// Swap the X and Y values
assign X0_new = x_reverse ? X1_temp : X0_temp;
assign X1_new = x_reverse ? X0_temp : X1_temp;
assign Y0_new = x_reverse ? Y1_temp : Y0_temp;
assign Y1_new = x_reverse ? Y0_temp : Y1_temp;

wire [8:0] delta_X, delta_Y;

// Calculate the deltas in the X and Y directions, to be used as slope
assign delta_X = X1_new - X0_new;
assign delta_Y = ($signed(Y1_new - Y0_new) >= 0) ? Y1_new - Y0_new : Y0_new - Y1_new;

wire signed [8:0] Y_step;
assign Y_step = (Y0_new < Y1_new) ? 1 : -1;

reg   [1:0] next_state;
wire  [1:0] current_state;

wire signed [8:0] error;
reg signed [8:0] next_error;

wire [8:0] Y, X;
reg [8:0] next_X, next_Y;

assign Pixel_Address = is_steep ?
                        {Base_Addr[31:18], next_X[7:0], next_Y[8:0], 1'b0} :
                        {Base_Addr[31:18], next_Y[7:0], next_X[8:0], 1'b0};


always @(*) begin
  case (current_state)
    `IDLE_STATE: begin
      next_state = Go ? `WAITING_STATE : `IDLE_STATE;
      Done = 1;
      Draw = 0;
      next_X = X0_new;
      next_Y = Y0_new;
      next_error = -(delta_X / 2);
    end
    `DRAWING_STATE: begin
      next_state = `WAITING_STATE;
      Done = 0;
      Draw = next_state != `DONE_STATE;
      next_X = X + 1;
      next_Y = (error + $signed(delta_Y) > 0) ? $signed(Y) + Y_step : Y;
      next_error = (error + $signed(delta_Y) > 0) ? error + $signed(delta_Y - delta_X) : error + delta_Y;
    end
    `WAITING_STATE: begin
      if (Write_Finish) begin
        next_state = (X >= X1_new) ? `DONE_STATE : `DRAWING_STATE;
      end else begin
        next_state = `WAITING_STATE;
      end
      Done = 0;
      Draw = 1;
      next_X = X;
      next_Y = Y;
      next_error = error;
    end
    `DONE_STATE: begin
      next_state = `IDLE_STATE;
      Done = 1;
      Draw = 0;
      next_X = 0;
      next_Y = 0;
      next_error = 0;
    end
    default: begin
      next_state = `IDLE_STATE;
      Done = 0;
      Draw = 0;
      next_X = 0;
      next_Y = 0;
      next_error = 0;
    end
  endcase
end

dffre #(2) state_ff (
  .clk    (clk),
  .reset  (~resetn),
  .en     (1'b1),
  .d      (next_state),
  .q      (current_state)
);

dffre #(9) x_ff (
  .clk    (clk),
  .reset  (~resetn),
  .en     (1'b1),
  .d      (next_X),
  .q      (X)
);

dffre #(9) y_ff (
  .clk    (clk),
  .reset  (~resetn),
  .en     (1'b1),
  .d      (next_Y),
  .q      (Y)
);

dffre #(9) error_ff (
  .clk    (clk),
  .reset  (~resetn),
  .en     (1'b1),
  .d      (next_error),
  .q      (error)
);

endmodule
