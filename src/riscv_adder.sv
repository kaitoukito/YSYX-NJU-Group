module riscv_adder #(
    parameter   DATA_WIDTH  = -1
) (
    input   logic   [DATA_WIDTH-1:0]    a,
    input   logic   [DATA_WIDTH-1:0]    b,
    output  logic   [DATA_WIDTH-1:0]    s
);

    assign s = a + b;

endmodule
