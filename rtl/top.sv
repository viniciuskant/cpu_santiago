module top #(
    parameter WIDTH = 8,
    parameter WIDTH_ADDRESS = 3,
    parameter N = 4
)(
    input clk,
    input rst,
    input [6:0] cmdin,
    input [WIDTH-1:0] din_1,
    input [WIDTH-1:0] din_2,
    input [WIDTH-1:0] din_3,
    output logic [WIDTH-1:0] dout_low,
    output logic [WIDTH-1:0] dout_high,
    output logic cpu_rdy,
    output logic zero,
    output logic error
);

    logic [WIDTH-1:0] muxA_out, muxB_out;
    logic [WIDTH-1:0] regA_out, regB_out;
    logic [2*WIDTH-1:0] alu_out;
    logic [2*WIDTH-1:0] mem_out;
    logic [2*WIDTH-1:0] muxCPU_OUT;
    logic [2*WIDTH-1:0] regCPU_OUT;

    logic [1:0] in_select_a, in_select_b;
    logic [3:0] opcode;

    logic memoryWrite, memoryRead;
    logic selmux2;
    logic aluout_reg_en;
    logic aluin_reg_en;
    logic datain_reg_en;
    logic nvalid_data;
    logic rst_out;

    logic error_in, zero_in;
    logic [6:0] regCMD_IN;

    assign {dout_high, dout_low} = regCPU_OUT;

    register_bank #(.WIDTH(7)) reg_CMD_IN (
        .clk(clk),
        .rst(rst_out),
        .in(cmdin),
        .out(regCMD_IN),
        .wr_en(datain_reg_en)
    );

    register_bank #(.WIDTH(WIDTH)) reg_A (
        .clk(clk),
        .rst(rst_out),
        .in(muxA_out),
        .out(regA_out),
        .wr_en(aluin_reg_en)
    );

    register_bank #(.WIDTH(WIDTH)) reg_B (
        .clk(clk),
        .rst(rst_out),
        .in(muxB_out),
        .out(regB_out),
        .wr_en(aluin_reg_en)
    );

    register_bank #(.WIDTH(2*WIDTH)) reg_OUT (
        .clk(clk),
        .rst(rst_out),
        .in(muxCPU_OUT),
        .out(regCPU_OUT),
        .wr_en(aluout_reg_en)
    );

    register_bank #(.WIDTH(2)) reg_FLAG_OUT (
        .clk(clk),
        .rst(rst_out),
        .in({zero_in, error_in}),
        .out({zero, error}),
        .wr_en(aluout_reg_en)
    );

    mux4 #(.WIDTH(WIDTH)) muxA (
        .din1(din_1),
        .din2(din_2),
        .din3(din_3),
        .din4(dout_high),
        .select(in_select_a),
        .dout(muxA_out)
    );

    mux4 #(.WIDTH(WIDTH)) muxB (
        .din1(din_1),
        .din2(din_2),
        .din3(din_3),
        .din4(dout_low),
        .select(in_select_b),
        .dout(muxB_out)
    );

    assign muxCPU_OUT = (selmux2 == 1'b1) ?  alu_out :  mem_out;

    ALU #(.WIDTH(WIDTH)) u_alu (
        .in1(regA_out),
        .in2(regB_out),
        .op(opcode),
        .nvalid_data(nvalid_data),
        .out(alu_out),
        .zero(zero_in),
        .error(error_in)
    );


    memory #(
        .WIDTH(WIDTH),
        .WIDTH_ADDRESS(WIDTH_ADDRESS)
    ) u_memory (
        .clk(clk),
        .memoryWrite(memoryWrite),
        .memoryRead(memoryRead),
        .memoryWriteData({dout_high, dout_low}),
        .memoryAddress(regA_out[WIDTH_ADDRESS-1:0]), 
        .memoryOutData(mem_out)
    );


    control u_control (
        .clk(clk),
        .rst(rst),
        .rst_out(rst_out),
        .p_error(error),
        .cmd_in(regCMD_IN),

        .aluin_reg_en(aluin_reg_en),
        .datain_reg_en(datain_reg_en),

        .memoryWrite(memoryWrite),
        .memoryRead(memoryRead),

        .selmux2(selmux2),
        .cpu_rdy(cpu_rdy),
        .aluout_reg_en(aluout_reg_en),

        .nvalid_data(nvalid_data),
        .in_select_a(in_select_a),
        .in_select_b(in_select_b),

        .opcode(opcode)
    );

endmodule