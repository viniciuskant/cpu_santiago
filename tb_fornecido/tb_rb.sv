// delays are interpreted in 1us
// resolution is 10ns (any delay smaller than 10ns will be rounded)
`timescale 1us/10ns 

module tb_rb ();
  // parameters
  localparam CLK_PERIOD = 10;
  localparam      WIDTH = 8;

  // dut interface connectors
  logic clk = 0;
  logic wr_en, rst;
  logic [WIDTH-1:0] in, out;

  // mux instantiation
  register_bank #(
    .WIDTH  (WIDTH  )
  ) uu_rb (
    .clk    (clk    ),
    .rst    (rst    ),
    .wr_en  (wr_en  ),
    .in     (in     ),
    .out    (out    )
  );

  // clk gen
  always #(CLK_PERIOD/2) clk=~clk;

  // main block
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    // no reset (output must be all x)
    #13us; 

    // reset routine for 10us (default is us)
    rst = 0;
    #5;
    rst = 1;
    #5;

    // deassert reset and wait 5us
    rst = 0;
    #5;

    // write in register
    wr_en = 1;
    
    in = 0;
    repeat(300) begin
      @(posedge clk);
      in = in + 1;
    end

    $display("\n\n");
    $finish();
  end

endmodule