// delays are interpreted in 1us
// resolution is 10ns (any delay smaller than 10ns will be rounded)
`timescale 1us/10ns 

module tb_mux4_rb ();
  // parameters
  localparam CLK_PERIOD = 10;
  localparam      WIDTH = 8;

  // dut interface connectors
  logic clk = 0;
  logic wr_en, rst;
  logic [1:0] sel;
  logic [WIDTH-1:0] in1, in2, in3, in4, out;

  // mux instantiation
  mux4_registered #(
    .WIDTH  (WIDTH  )
  ) uu_mux4_rb (
    .clk    (clk    ),
    .rst    (rst    ),
    .wr_en  (wr_en  ),
    .sel    (sel    ),
    .in1    (in1    ),
    .in2    (in2    ),
    .in3    (in3    ),
    .in4    (in4    ),
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
    sel = 0;
    #5;

    // deassert reset and wait 5us
    rst = 0;
    #5;

    // write in register
    wr_en = 1;
    
    in1 = 0;
    in2 = 0;
    in3 = 0;
    in4 = 0;
    repeat(10) begin
      @(posedge clk);
      in1 = in1 + 1;
      in2 = in2 + 2;
      in3 = in3 + 3;
      in4 = in4 + 4;

      if(in1 > 5)
       sel = 2;
    end

    $display("\n\n");
    $finish();
  end

endmodule