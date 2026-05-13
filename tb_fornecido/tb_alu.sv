// delay / resolution
`timescale 1us/10ns 

module tb_alu ();
  // parameters
  localparam WIDTH = 8;

  // one-hot to use less comb logic
  typedef enum logic [3:0] {
    ADD = 4'b0001,
    SUB = 4'b0010,
    MUL = 4'b0100,
    DIV = 4'b1000
  } OPERATION_ENUM_T;

  // dut interface connectors

  // in
  logic [WIDTH-1:0] in1, in2;
  OPERATION_ENUM_T op;
  logic invalid_data;

  // out
  logic [2*WIDTH-1:0] out;
  logic zero;
  logic error;

  // alu instantiation
  ALU #(
    .WIDTH          (WIDTH        )
  ) uu_alu (
    .in1            (in1          ),
    .in2            (in2          ),
    .op             (op           ),
    .nvalid_data   (invalid_data ),
    .out            (out          ),
    .zero           (zero         ),
    .error          (error        )
  );

  // main block
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    // or $fsdbDumpvars(); // vcs

    // just propagate X
    #3;

    // set data and does operations
    invalid_data = 0;
    in1 = 3;
    in2 = 5;

    op = ADD;
    exec();

    op = SUB;
    exec();

    op = MUL;
    exec();

    op = DIV;
    exec();

    // invalid data with DIV -> out -1 and and error = 1
    invalid_data = 1;
    exec();

    // test zero
    invalid_data = 0;
    in1 = 10;
    in2 = 10;
    op = SUB;
    exec();

    if(zero != 1)
      $fatal("error to detect zero op");

    $display("\n\n");
    $finish();
  end

  task exec();
    logic [2*WIDTH-1:0] expected_out;

    #1;
    case(op)  
      ADD: begin
        expected_out = in1 + in2;

        if(expected_out != out)
          $fatal("error in ADD");
        else begin
          $display("[ADD] in1 + in2 = %0d + %0d = %0d / expected = %0d", in1, in2, out, expected_out);
        end
      end

      SUB: begin
        expected_out = in1 - in2;

        if(expected_out != out)
          $fatal("error in SUB");
        else begin
          $display("[SUB] in1 - in2 = %0d - %0d = %0d / expected = %0d", in1, in2, $signed(out), $signed(expected_out));
        end
      end

      MUL: begin
        expected_out = in1 * in2;

        if(expected_out != out)
          $fatal("error in MUL");
        else begin
          $display("[MUL] in1 * in2 = %0d * %0d = %0d / expected = %0d", in1, in2, out, expected_out);
          // or value - 2^(WIDTH-1)
        end
      end

      DIV: begin
        // invalid data
        if(in2 == 0 || invalid_data) begin
          expected_out = -1;
          if(error != 1)
            $fatal("error in DIV - invalid_data");
        end
        // normal
        else begin
          expected_out = in1 / in2;
        end

        if(expected_out != out) begin
          $display("[DIV] in1 / in2 = %0d / %0d = %0d / expected = %0d", in1, in2, out, expected_out);
          $fatal("error in DIV");
        end else begin
          $display("[DIV] in1 / in2 = %0d / %0d = %0d / expected = %0d", in1, in2, out, expected_out);
        end
      end

      default: begin
        $fatal("ERROR");
      end
    endcase
  endtask

endmodule