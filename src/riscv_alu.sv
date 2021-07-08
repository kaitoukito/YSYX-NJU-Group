module riscv_alu #(
    parameter   WIDTH   = 64
) (
    input   logic   [WIDTH-1:0]     a,
    input   logic   [WIDTH-1:0]     b,
    input   logic   [3:0]           alu_ctrl,   // {ainvert, bnegate, operation[1:0]}
    output  logic   [WIDTH-1:0]     alu_out,
    output  logic                   zero
)

    always_comb begin
        case (alu_ctrl)
            4'b0000 :   alu_out = a & b;
            4'b0001 :   alu_out = a | b;
            4'b0010 :   alu_out = a + b;
            4'b0110 :   alu_out = a - b;
            4'b0111 :   alu_out = (a < b) ? 'd1 : 'd0;
            4'b1100 :   alu_out = ~(a | b); // ~(a | b) = ~a & ~b
            default :   alu_out = 'd0;
        endcase
    end

    assign zero = (alu_out == 'd0);

endmodule
