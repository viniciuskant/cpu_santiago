`timescale 1us/10ns 

/*
  Esse tb é foi pensando para tentar usar a o circuito para usar o metodo babilônico da raiz e a fatorização como uma tentativa 'divertida' de verifica
  para isso foi usada duas task e também alguns nops no 'código'
*/

module top_tb_completo ();
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
  logic [WIDTH-1:0] dout_low, prev_dout_low;
  logic [WIDTH-1:0] dout_high;
  logic [WIDTH-1:0] address;
  logic cpu_rdy;
  logic zero;
  logic error;

  always_comb begin
    if (cpu_rdy == 1'b1) prev_dout_low = dout_low;
  end

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

  task automatic run_tb_fornecido();
    begin
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

      din_1 = 0;
      din_2 = 8'hf9; // -7
      din_3 = 8'hf06; // 6

      cmdin = {2'b01, 2'b00, DIV}; //Espero erro
      @(posedge cpu_rdy);

      din_1 = 0;
      din_2 = 8'h07; // 7
      din_3 = 8'hf8; // -6

      cmdin = {2'b01, 2'b11, ADD}; //Espero erro, pois estou usando a divisão errada
      @(posedge cpu_rdy);


      cmdin = {2'b11, 2'b00, SUB}; //Espero erro, pois estou usando a soma errada
      @(posedge cpu_rdy);

      cmdin = {2'b01, 2'b10, MUL}; //Espero -42 ou d6
      @(posedge cpu_rdy);


      cmdin = {2'b01, 2'b10, MUL}; //Espero -42 ou d6
      #35;
      rst = 1;
      #5;
      rst = 0;

      din_1 = 0;
      din_2 = 8'h0f; // -1
      din_3 = 8'h0f; // -1

      cmdin = {2'b01, 2'b10, SUB}; //Espero zero
      @(posedge cpu_rdy);

    end
  endtask

  // Função que executa o método babilônico para um dado N
  task automatic run_sqrt_test(input integer N);
    begin
  
      rst = 1;
      #5;
      rst = 0;
      #5;

      // b0
      din_1 = N; // n =
      din_2 = 8'h00; // init
      din_3 = 8'h01; // a0
      cmdin = {2'b00, 2'b10, DIV};
      @(posedge cpu_rdy);

      // a1
      cmdin = {2'b10, 2'b11, ADD};
      @(posedge cpu_rdy);
      din_2 = 8'h02; // denominador
      din_3 = dout_low;
      cmdin = {2'b10, 2'b01, DIV};
      @(posedge cpu_rdy);
      din_2 = 8'h02; // address
      cmdin = {2'b01 , 2'b11, STORE};
      @(posedge cpu_rdy);

      // b1
      din_2 = 8'h02; // address
      cmdin = {2'b01, 2'b10, LOAD};
      @(posedge cpu_rdy);
      cmdin = {2'b00, 2'b11, DIV};
      @(posedge cpu_rdy);

      // a2
      din_3 = prev_dout_low;
      cmdin = {2'b10, 2'b11, ADD};
      @(posedge cpu_rdy);
      din_2 = 8'h02; // denominador
      din_3 = dout_low;
      cmdin = {2'b10, 2'b01, DIV};
      @(posedge cpu_rdy);
      din_2 = 8'h03; // address
      cmdin = {2'b01 , 2'b11, STORE};
      @(posedge cpu_rdy);

      // b2
      din_2 = 8'h03; // address
      cmdin = {2'b01, 2'b10, LOAD};
      @(posedge cpu_rdy);
      cmdin = {2'b00, 2'b11, DIV};
      @(posedge cpu_rdy);

      // a3
      din_3 = prev_dout_low;
      cmdin = {2'b10, 2'b11, ADD};
      @(posedge cpu_rdy);
      din_2 = 8'h02; // denominador
      din_3 = dout_low;
      cmdin = {2'b10, 2'b01, DIV};
      @(posedge cpu_rdy);
      din_2 = 8'h04; // address
      cmdin = {2'b01 , 2'b11, STORE};
      @(posedge cpu_rdy);

      // b3
      din_2 = 8'h04; // address
      cmdin = {2'b01, 2'b10, LOAD};
      @(posedge cpu_rdy);
      cmdin = {2'b00, 2'b11, DIV};
      @(posedge cpu_rdy);

      // a4
      din_3 = prev_dout_low;
      cmdin = {2'b10, 2'b11, ADD};
      @(posedge cpu_rdy);
      din_2 = 8'h02; // denominador
      din_3 = dout_low;
      cmdin = {2'b10, 2'b01, DIV};
      @(posedge cpu_rdy);
      din_2 = 8'h05; // address
      cmdin = {2'b01 , 2'b11, STORE};
      @(posedge cpu_rdy);

      cmdin = {2'b11 , 2'b00, NOP1};
      @(posedge cpu_rdy);

      // b4
      din_2 = 8'h05; // address
      cmdin = {2'b01, 2'b10, LOAD};
      @(posedge cpu_rdy);
      cmdin = {2'b00, 2'b11, DIV};
      @(posedge cpu_rdy);

      // a5
      din_3 = prev_dout_low;
      cmdin = {2'b10, 2'b11, ADD};
      @(posedge cpu_rdy);
      din_2 = 8'h02; // denominador
      din_3 = dout_low;
      cmdin = {2'b10, 2'b01, DIV};
      @(posedge cpu_rdy);
      din_2 = 8'h06; // address
      cmdin = {2'b01 , 2'b11, STORE};
      @(posedge cpu_rdy);

      cmdin = {2'b10 , 2'b00, NOP};
      @(posedge cpu_rdy);

      // b5
      din_2 = 8'h06; // address
      cmdin = {2'b01, 2'b10, LOAD};
      @(posedge cpu_rdy);
        cmdin = {2'b00, 2'b00, NOP1};
      @(posedge cpu_rdy);
      cmdin = {2'b00, 2'b11, DIV};
      @(posedge cpu_rdy);

      // a6
      din_3 = prev_dout_low;
      cmdin = {2'b10, 2'b11, ADD};
      @(posedge cpu_rdy);
      din_2 = 8'h02; // denominador
      din_3 = dout_low;
      cmdin = {2'b10, 2'b01, DIV};
      @(posedge cpu_rdy);
      $display("\t*raiz de %d e %d", N, dout_low);
      din_2 = 8'h07; // address
      cmdin = {2'b01 , 2'b11, STORE};
      @(posedge cpu_rdy);
      
      #50; // pequena pausa entre os testes
    end
  endtask

  task automatic run_fatorial_test(input integer N);
    logic [7:0] address;
    logic [7:0] current_value;
        
    rst = 1;
    #5;
    rst = 0;
    #5;

    // Inicializa variaveis
    din_1 = N;
    din_2 = 8'h02;
    din_3 = 8'h00;
    address = 8'h00;
    
    while (din_1 > 1) begin
      cmdin = {2'b00, 2'b01, DIV};  
      @(posedge cpu_rdy);
      cmdin = {2'b01, 2'b11, MUL};
      @(posedge cpu_rdy);
      cmdin = {2'b00, 2'b11, SUB};
      @(posedge cpu_rdy);

      cmdin = {2'b01, 2'b11, NOP};
      @(posedge cpu_rdy);

      if (zero == 1'b1) begin
        cmdin = {2'b00, 2'b01, DIV}; 
        @(posedge cpu_rdy);
        din_1 = dout_low;
        din_3 = 8'h00;
        cmdin = {2'b10, 2'b01, ADD}; 
        @(posedge cpu_rdy);
        cmdin = {2'b11, 2'b10, NOP1};
        @(posedge cpu_rdy);
        din_3 = address;
        cmdin = {2'b10, 2'b01, STORE}; //guardo o divisor (d2)
        @(posedge cpu_rdy);
        
        din_3 = 8'h01;
        cmdin = {2'b00, 2'b10, SUB}; //se zero subir eu cheguei a zero
        @(posedge cpu_rdy);

        if (zero == 1) begin
          break;
        end
        address = address + 1;
      end else begin
        din_2 = din_2 + 1; // não é divisor, incrementa divisor
      end
    end
    
    // Lê e imprime todos os valores armazenados na memória
    $display("\t*valores de %0d!:", N);
    for (int i = 0; i <= address; i++) begin
      din_2 = i;
      cmdin = {2'b01, 2'b00, LOAD};
      @(posedge cpu_rdy);
      $display("\t\tmemoria[%0d] = %0d", i, dout_low);
    end
    
  endtask

  // main block
  initial begin
    // msim
    $dumpfile("dump.vcd");
    $dumpvars;

    // vcs to get all:
    // $fsdbDumpfile("waveform.fsdb");
    // $fsdbDumpvars("+all");

    rst = 1;
    #5;
    rst = 0;
    #5;

    // Executar testes para diferentes valores de N
    for (int i = 2; i <= 126; i++) begin
        $display("\nTeste para o numero %d:", i);
        run_fatorial_test(i);
        run_sqrt_test(i);
    end

    run_tb_fornecido();

    #1000;
    $display("\n\n");
    $finish();
  end
endmodule