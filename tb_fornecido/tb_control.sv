// delay / resolution
`timescale 1us/10ns 

module tb_control ();
  // parameters
  localparam CLK_PERIOD = 10;
  localparam      WIDTH = 8;

  // dut interface connectors
  logic clk = 0;
  logic rst;
  logic [6:0] cmd_in;
  logic p_error;
  logic aluin_reg_en;
  logic datain_reg_en;
  logic memoryWrite, memoryRead, selmux2;
  logic cpu_rdy;
  logic aluout_reg_en;
  logic nvalid_data;
  logic [1:0] in_select_a;
  logic [1:0] in_select_b;
  logic [3:0] opcode;

  // control instantiation
  control uu_control (
    .clk            (clk            ),
    .rst            (rst            ),
    .cmd_in         (cmd_in         ),
    .p_error        (p_error        ),
    .aluin_reg_en   (aluin_reg_en   ),
    .datain_reg_en  (datain_reg_en  ),
    .memoryWrite    (memoryWrite    ),
    .memoryRead     (memoryRead     ),
    .selmux2        (selmux2        ),
    .cpu_rdy        (cpu_rdy        ),
    .aluout_reg_en  (aluout_reg_en  ),
    .nvalid_data    (nvalid_data    ),
    .in_select_a    (in_select_a    ),
    .in_select_b    (in_select_b    ),
    .opcode         (opcode         )
  );

  // clk gen
  always #(CLK_PERIOD/2) clk=~clk;

  // main block
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    // no reset (output must be all x)
    #13us; 

    // reset routine
    rst = 0;
    #3;
    rst = 1;
    repeat(2) @(negedge clk);
    rst = 0;

    // set input and wait for 2 clocks, nx command must be catch on S_STORE
    p_error = 0;
    cmd_in  = {2'b00, 2'b00, 3'b111};
    repeat(3) @(posedge clk);

    // nx instruction
    @(negedge clk);
    cmd_in  = {2'b01, 2'b10, 3'b001};
    repeat(3) @(posedge clk);

    #10;
    $display("\n\n");
    $finish();
  end

endmodule