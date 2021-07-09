module riscv_ext #(
    parameter   IS_SIGNED = -1,     // 0: unsigned, otherwise: signed
    parameter   DATA_WIDTH_I = -1,
    parameter   DATA_WIDTH_O = -1,
) (
    input   logic   [DATA_WIDTH_I-1:0]  data_i,
    output  logic   [DATA_WIDTH_O-1:0]  data_o
);

    generate
        if (IS_SIGNED == 0) begin
            assign data_o = {{(DATA_WIDTH_O-DATA_WIDTH_I){1'b0}}, data_i};
        end
        else begin
            assign data_o = {{(DATA_WIDTH_O-DATA_WIDTH_I){data_i[DATA_WIDTH_I-1]}}, data_i};
        end
    endgenerate

endmodule
