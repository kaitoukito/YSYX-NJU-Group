`include "top_defines.v"
module riscv_ext #(
    parameter   IS_SIGNED = -1,     // 0: unsigned, otherwise: signed
    parameter   DATA_WIDTH_I = -1,
    parameter   DATA_WIDTH_O = -1
) (
    input   wire   [DATA_WIDTH_I-1:0]  data_i,
    output  reg	   [DATA_WIDTH_O-1:0]  data_o
);

   always@(*)begin
       if (IS_SIGNED == 0) begin
           data_o = {{(DATA_WIDTH_O-DATA_WIDTH_I){1'b0}}, data_i};
       end
       else begin
           data_o = {{(DATA_WIDTH_O-DATA_WIDTH_I){data_i[DATA_WIDTH_I-1]}}, data_i};
       end
end
endmodule
