`timescale 1us/10ns 

module tb_top ();
  // parameters
  localparam CLK_PERIOD = 10;
  localparam      WIDTH = 8;

  // dut interface connectors
  logic clk = 0;
  logic rst;
  logic [6:0] cmdin;
  logic [WIDTH-1:0] din_1 = 0;
  logic [WIDTH-1:0] din_2 = 0;
  logic [WIDTH-1:0] din_3 = 0;
  logic [WIDTH-1:0] dout_low;
  logic [WIDTH-1:0] dout_high;
  logic cpu_rdy;
  logic zero;
  logic error;

  typedef enum logic [2:0] {
    ADD = 0,
    SUB,
    MUL,
    DIV,
    NOP1, //ESTAVA FALTANDO
    LOAD,
    STORE,
    NOP
  } ISA_ENUM_T;

  // mux instantiation
  top #(
    .WIDTH  (WIDTH  )
  ) uu_top (
    .clk(clk),
    .rst(rst),
    .cmdin(cmdin),
    .din_1(din_1),
    .din_2(din_2),
    .din_3(din_3),
    .dout_low(dout_low),
    .dout_high(dout_high),
    .cpu_rdy(cpu_rdy),
    .zero(zero),
    .error(error)
  );

  // clk gen
  always #(CLK_PERIOD/2) clk=~clk;

  // main block
  initial begin
    // msim
    $dumpfile("dump.vcd");
    $dumpvars;

    // vcs to get all:
    // $fsdbDumpfile("waveform.fsdb");
    // $fsdbDumpvars("+all");

    // no reset (output must be all x)
    #13us; 

    // reset routine for 10us (default is us)
    rst = 0;
    #5;
    rst = 1;
    #5;

    // deassert reset and does the first operation 
    // ADD
    rst   = 0;
    din_1 = 1;
    din_2 = 2;
    cmdin = {2'b00, 2'b01, ADD};
    @(posedge cpu_rdy);

    // STORE
    din_1 = 3;
    cmdin = {2'b00, 2'b01, STORE};
    @(posedge cpu_rdy);

    // NOP
    cmdin = {2'b00, 2'b01, NOP};
    @(posedge cpu_rdy);

    // SUB
    cmdin = {2'b00, 2'b01, SUB};
    @(posedge cpu_rdy);

    // STORE
    din_1 = 4;
    cmdin = {2'b00, 2'b00, STORE};
    @(posedge cpu_rdy);

    // NOP
    cmdin = {2'b00, 2'b01, NOP};
    @(posedge cpu_rdy);

    // LOAD
    din_1 = 3;
    cmdin = {2'b00, 2'b01, LOAD}; //Espero 3
    @(posedge cpu_rdy);

    // LOAD
    din_1 = 4;
    cmdin = {2'b00, 2'b01, LOAD}; //Espero 1
    @(posedge cpu_rdy);

    #100;
    $display("\n\n");
    $finish();
  end

endmodule