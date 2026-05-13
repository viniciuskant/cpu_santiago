`timescale 1ns/1ps

module mux4_registerd_tb;
    parameter WIDTH  = 8;
    parameter N      = 4;
    parameter PERIOD = 10;

    logic clk;
    logic rst;
    logic wr_en;
    logic [$clog2(N)-1:0] sel;
    logic [N-1:0][WIDTH-1:0] in; 
    logic [WIDTH-1:0] out;

    mux4_registered #(.WIDTH(WIDTH), .N(N)) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .sel(sel),
        .in(in),
        .out(out)
    );

    always #(PERIOD/2) clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        wr_en = 0;
        sel = 0;
        in = '0;

        #PERIOD;
        rst = 0;

        // escrita
        for (int i = 0; i < N; i++) begin
            @(posedge clk);
            wr_en = 1;
            sel = i;
            in[i] = i * 8'h11;
        end

        @(posedge clk);
        wr_en = 0;

        // leitura
        for (int i = 0; i < N; i++) begin
            @(posedge clk);
            sel = i;
            @(posedge clk);
            $display("REG[%0d] = %h", i, out);
        end

        #20;
        $display("Fim dos testes");
        $finish;
    end

endmodule
