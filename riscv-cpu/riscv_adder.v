`include "top_defines.v"
module riscv_adder #(
    parameter   DATA_WIDTH  = -1
) (
    input      [DATA_WIDTH-1:0]    a,
    input      [DATA_WIDTH-1:0]    b,
    output     [DATA_WIDTH-1:0]    s
);

    assign s = a + b;

endmodule