module tb_mux4 ();
  // parameters
  localparam WIDTH = 4;

  // dut interface connectors
  logic [WIDTH-1:0] data[4];
  logic [1:0] sel;
  logic [WIDTH-1:0] dout;

  // mux instantiation
  mux4 #(
    .WIDTH    (WIDTH    )
  ) uu_mux4 (
    .din1     (data[0]  ),
    .din2     (data[1]  ),
    .din3     (data[2]  ),
    .din4     (data[3]  ),
    .select   (sel      ),
    .dout     (dout     )
  );

  // main block
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    // set data to avoid X
    sel = 2'b00;
    for (int i = 0; i<4; i++) begin
      data[i] = i;
    end

    for (int i = 0; i<4; i++) begin
      #1us ;
      if(dout != i)
        $fatal("ERROR!");

      sel = sel + 2'b01;
    end

    $display("PASS");
    $display("\n\n");
    $finish();
  end

endmodule