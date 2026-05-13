module control (
    input  logic clk,
    input  logic rst,
    input  logic p_error,
    input  logic [6:0] cmd_in,

    output logic aluin_reg_en,
    output logic datain_reg_en,

    output logic memoryWrite,
    output logic memoryRead,

    output logic selmux2,
    output logic cpu_rdy,
    output logic aluout_reg_en,

    output logic rst_out,

    output logic nvalid_data,
    output logic [1:0] in_select_a,
    output logic [1:0] in_select_b,

    output logic [3:0] opcode
);

    logic [2:0] in_opcode;

    assign rst_out = rst;

    assign in_opcode = cmd_in[2:0];

    typedef enum logic [1:0] {
        RESET = 2'b00,
        FETCH = 2'b01,
        EXEC = 2'b10,
        STORE = 2'b11
    } state_t;

    state_t current_state, next_state;

    // lógica de transição
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= RESET;
        else
            current_state <= next_state;
    end

    // lógica de próximo estado
    always_comb begin
        next_state = current_state;

        unique case (current_state)
            RESET: next_state = FETCH;
            FETCH: next_state = EXEC;
            EXEC: next_state = STORE;
            STORE: next_state = FETCH;
            default: next_state = RESET;
        endcase
    end

    // Lógica de saída, olha para os estádos e define a saída
    // colocar aqui as saídas padrões que são esperadas-
    always_comb begin
        in_select_a = 2'b00;
        in_select_b = 2'b00;
        aluin_reg_en = 1'b0;
        datain_reg_en = 1'b0;
        aluout_reg_en = 1'b0;
        cpu_rdy = 1'b0;
        selmux2 = 1'b0;
        memoryRead = 1'b0;
        memoryWrite = 1'b0;

        nvalid_data = 1'b0;
        opcode = 4'b0001; // NOP
        
        unique case (current_state)

            RESET: begin
                cpu_rdy = 0;
                datain_reg_en = 1;
            end

            FETCH: begin
                aluin_reg_en = 1;
                in_select_a = cmd_in[6:5];
                in_select_b = cmd_in[4:3];
            end

            EXEC: begin
                // falta definir como seria o nvalid_data
                if (in_opcode == 3'b101) memoryRead = 1'b1;
                else memoryRead = 1'b0;

                if (in_opcode == 3'b110) memoryWrite = 1'b1;
                else memoryWrite = 1'b0;

                //Se NOP ou Operação da ALU, escolhi o NOP para garantur o -1
                if (in_opcode[2] == 0 | (in_opcode == 3'b111 ) | (in_opcode == 3'b111)) selmux2 = 1'b1; //Deve selecioar a saida da ALU
                else selmux2 = 1'b0; //Deve selecioar a saida da Memória

                unique case (in_opcode)
                    3'b000: opcode = 4'b0001; // ADD
                    3'b001: opcode = 4'b0010; // SUB
                    3'b010: opcode = 4'b0100; // MUX
                    3'b011: opcode = 4'b1000; // DIV
                    default: opcode = 4'b0001; // ADD
                endcase

                if ((in_opcode == 3'b111 )| (in_opcode == 3'b100)) nvalid_data = 1'b1; //NOP
                else nvalid_data = 1'b0;
                
                if (p_error & ((in_opcode == 3'b111 ) | (in_opcode == 3'b100))) aluout_reg_en = 1'b0;
                else aluout_reg_en = 1'b1;
            end

            STORE: begin
                // só salva se for operação válida
                datain_reg_en = 1;
                cpu_rdy = 1;
            end

            default: begin
                aluin_reg_en = 1'b0;
                datain_reg_en = 1'b0;
                aluout_reg_en = 1'b0;
                cpu_rdy = 1'b0;
                selmux2 = 1'b0;
                memoryRead = 1'b0;
                memoryWrite = 1'b0;
                nvalid_data = 1'b0;
                opcode = 4'b0000;
            end

        endcase
    end

endmodule