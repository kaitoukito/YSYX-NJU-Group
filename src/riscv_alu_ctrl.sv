/// This module is coded accoding to
/// Computer Organization and Design RISC-V Edition
/// Appendix C
module riscv_alu_ctrl (
    input   logic   [1:0]   alu_op,
    input   logic   [3:0]   func_code,
    output  logic   [3:0]   alu_ctrl
)

    //always_comb begin
    //    case ({alu_op, func_code})
    //        6'b10_0000  : alu_ctrl = 4'b0010;   // add
    //        6'b10_0010  : alu_ctrl = 4'b0110;   // sub
    //        6'b10_0100  : alu_ctrl = 4'b0000;   // and
    //        6'b10_0101  : alu_ctrl = 4'b0001;   // or
    //        6'b10_0111  : alu_ctrl = 4'b1100;   // nor
    //        6'b10_1010  : alu_ctrl = 4'b0111;   // slt
    //        default     : alu_ctrl = 4'b1111;
    //    endcase
    //end

    assign alu_ctrl[3] = 1'b0;
    assign alu_ctrl[2] = (~alu_op[1] & alu_op[0]) | (alu_op[1] & func_code[1]);
    assign alu_ctrl[1] = ~alu_op[1] | ~func_code[2];
    assign alu_ctrl[0] = (alu_op[1] & func_code[0]) | (alu_op[1] & func_code[3]);

endmodule
