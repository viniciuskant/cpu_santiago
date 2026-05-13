// unit / resolution
`timescale 1us/10ns 

module tb_mem ();
  // parameters
  localparam CLK_PERIOD    = 10;
  localparam WIDTH         = 8;
  localparam WIDTH_ADDRESS = 3;

  // dut interface connectors
  logic clk = 0;
  logic memoryWrite, memoryRead;
  logic [2*WIDTH-1:0] memoryWriteData;
  logic [2:0] memoryAddress;
  logic[2*WIDTH-1:0] memoryOutData;

  logic[2*WIDTH-1:0] ref_mem[8];

  // mux instantiation
  memory #(
    .WIDTH            (WIDTH            ),
    .WIDTH_ADDRESS    (WIDTH_ADDRESS    )
  ) uu_mem (
    .clk              (clk              ),
    .memoryWrite      (memoryWrite      ),
    .memoryRead       (memoryRead       ),
    .memoryWriteData  (memoryWriteData  ),
    .memoryAddress    (memoryAddress    ),
    .memoryOutData    (memoryOutData    )
  );

  // clk gen
  always #(CLK_PERIOD/2) clk=~clk;

  // main block
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    // $fsdbDumpvars(); // vcs
    // $fsdbDumpMDA();

    // do nothing
    #13; 

    // "reset"
    memoryWrite   = 0;
    memoryRead    = 0;
    memoryAddress = 0;
    #5;

    // write
    memoryWrite = 1;
    for (int i = 0; i < 8; i++) begin
      memoryAddress   = $urandom_range(7,0);
      memoryWriteData = $urandom_range(7,0);
      @(posedge clk); // store
      ref_mem[memoryAddress] = memoryWriteData;

      #1;
      /*
      $display("mem[%3d] = %d", memoryAddress, tb_mem.uu_mem.mem[memoryAddress]);
      */
    end
    memoryWrite     = 0;
    memoryAddress   = 0;
    memoryWriteData = 0;

    // read
    @(posedge clk);
    $display("Memory contents:");
    $display("   %p", tb_mem.uu_mem.mem);
    // $display("   output: %d", memoryOutData); // must be x

    // read self-check
    memoryRead = 1;
    for (int i = 0; i < 8; i++) begin
      memoryAddress = i;
      @(posedge clk);

      #1;
      // $display("memoryAddress[%3d] = output: %d", memoryAddress, memoryOutData);
      if(memoryOutData !== ref_mem[i]) begin
        $display("memoryOutData 0x%x / ref_mem 0x%x / addr %d", memoryOutData, ref_mem[i], i);
        $fatal("error in reading process");
      end else begin
        $display("memoryOutData 0x%x / ref_mem 0x%x", memoryOutData, ref_mem[i]);
      end
    end
    memoryRead = 0;

    $display("PASS!");
    $display("\n\n");
    $finish();
  end

endmodule