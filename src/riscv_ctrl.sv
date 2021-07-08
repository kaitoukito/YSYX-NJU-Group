module riscv_ctrl (
    input   logic   [6:0]   opcode, // instruction[6:0]

    output  logic           alu_src,
    output  logic           mem2reg,
    output  logic           reg_write,
    output  logic           mem_read,
    output  logic           mem_write,
    output  logic           branch,
    output  logic   [1:0]   alu_op
);

    // TODO
    always_comb begin
        case (opcode)
            7'b000_0000 :   {alu_src, mem2reg, reg_write, mem_read, mem_write, branch, alu_op} = 7'b000_0000;
            default     :   {alu_src, mem2reg, reg_write, mem_read, mem_write, branch, alu_op} = 7'b111_1111;
        endcase
    end

endmodule
