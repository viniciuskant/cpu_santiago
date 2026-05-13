module mux4_registered #(
    parameter WIDTH = 8
) (
    input  logic clk,
    input  logic rst,
    input  logic wr_en,
    input  logic [1:0] sel,
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,
    input  logic [WIDTH-1:0] in3,
    input  logic [WIDTH-1:0] in4,
    output logic [WIDTH-1:0] out
);

    logic [WIDTH-1:0] out_in;

    mux4 #(.WIDTH(WIDTH)) uu_mux4 (
        .din1(in1),
        .din2(in2),
        .din3(in3),
        .din4(in4),
        .select(sel),
        .dout(out_in)
    );


    register_bank u_reg (
        .clk (clk),
        .rst (rst),
        .in  (out_in),
        .out (out),
        .wr_en (wr_en)
    );

endmodule
