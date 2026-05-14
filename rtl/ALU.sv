module ALU #(
    WIDTH = 8
) (
    input [WIDTH-1:0] in1, in2,
    input [3:0] op,
    input nvalid_data,
    output logic signed [2*WIDTH-1:0] out,
    output logic zero,
    output logic error
);
    localparam SH_MAX_WIDTH = $clog2(WIDTH);

    // assert ($onehot(op));
    /*
        4'b0001: // ADD or ADDI 
        4'b0010: // SUB 
        4'b0100  // MUL
        4'b1000  // DIV
        default: in1
    */

    function automatic logic tree_zero_detector(input logic [2*WIDTH-1:0] bits);
        logic [2*WIDTH-1:0] or_tree;
        int k, i;
        or_tree = bits;
        k = 2*WIDTH;
        while (k > 1) begin
            for (i = 0; i < k/2; i++) begin
                or_tree[i] = or_tree[2*i] | or_tree[2*i+1];
            end
            k = k / 2;
        end
        return ~or_tree[0];
    endfunction

    // sinalização
    logic zero_in2;
    assign zero = tree_zero_detector(out); //teste
    // assign zero = ~(|out);

    assign zero_in2 = tree_zero_detector(in2); //teste
    // assign zero_in2 = ~(|in2);

    assign error = (op[3] & zero_in2) | nvalid_data;

    // sinais internos com extensão de sinal para operações aritméticas
    logic signed [2*WIDTH-1:0] sin1, sin2;

    assign sin1 = signed'(in1); // extensão para signed (complemento de dois)
    assign sin2 = signed'(in2); // extensão para signed (complemento de dois)

    always_comb begin
        if (nvalid_data == 1'b0) begin
            unique case (op)
                4'b0001: out = sin1 + sin2; // ADD (signed)
                4'b0010: out = sin1 - sin2; // SUB (signed)
                4'b0100: out = sin1 * sin2; // MUL (signed)
                4'b1000: out = (zero_in2) ? -1 : sin1 / sin2; //cometi um erro aqui, não podia atribuir FFFF, pois 
                                                            //ele entende isso como sem sinal e faz uma conversão em cima disso
                // default: out = sin1;                       // remover o default simplificou o circuito, pois virou de fato onehot
            endcase
        end else begin
            out = -1;
        end
    end

endmodule
