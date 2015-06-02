module falling_dffre #(
    parameter WIDTH = 1
  )(
    input   clk,
    input   reset,
    input   en,

    input       [WIDTH - 1 : 0]   d,
    output reg  [WIDTH - 1 : 0]   q
);

always @(negedge clk) begin
  if (reset) begin
    q <= 0;
  end else if (en) begin
    q <= d;
  end else begin
    q <= q;
  end
end

endmodule

module dffre #(
    parameter WIDTH = 1
  )(
    input   clk,
    input   reset,
    input   en,

    input       [WIDTH - 1 : 0]   d,
    output reg  [WIDTH - 1 : 0]   q
);

always @(posedge clk) begin
  if (reset) begin
    q <= 0;
  end else if (en) begin
    q <= d;
  end else begin
    q <= q;
  end
end

endmodule
