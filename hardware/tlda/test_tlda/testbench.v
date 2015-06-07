`timescale 1 ns / 100 ps

module testbench (
);

reg clk;
reg resetn;
reg Go;
reg [8:0] X0, X1;
reg [7:0] Y0, Y1;
reg Write_Finish;
reg [15:0] Color;
reg [8:0] Thickness;
reg [31:0] Base_Addr;

wire Done;
wire Draw;
wire [31:0] Pixel_Address;

TLDA_circuit dut(
  .clk  (clk),
  .resetn (resetn),
  .Go     (Go),

  .X0     (X0),
  .X1     (X1),
  .Y0     (Y0),
  .Y1     (Y1),

  .Done   (Done),
  .Write_Finish (Write_Finish),
  .Draw   (Draw),
  .Pixel_Address  (Pixel_Address),

  .Color    (),
  .Thickness(Thickness),
  .Base_Addr (Base_Addr)
);

always begin
  #5;
  clk = ~clk;
end

initial begin
  // Reset device
  resetn = 0;
  clk = 0;
  X0 = 0;
  X1 = 0;
  Y0 = 0;
  Y1 = 0;
  Go = 0;
  Write_Finish = 0;
  Color = 0;
  Base_Addr = 32'h09000000;

  // Bring out of reset
  #20;
  resetn = 1;
  #10;

  // Specify a line
  // Horizontal right now.
  // Next tests: vertical & any sloped line
  X0 = 0;
  Y0 = 0;
  X1 = 0;
  Y1 = 10;
  Color = 16'hFFFF;
  Thickness = 10;

  // Command to draw
  Go = 1;
  #20;
  Go = 0;

  repeat (400) begin
    Write_Finish = 1;
    #20;
    Write_Finish = 0;
    #20;
  end


  $finish;
end

endmodule
