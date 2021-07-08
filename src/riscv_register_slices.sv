/// sequential logic
module riscv_register_slices #(
    parameter   DATA_WIDTH  = -1
) (
    input   logic                       clk,
    input   logic                       rst_n,
    input   logic   [DATA_WIDTH-1:0]    din,
    input   logic                       en,
    output  logic                       dout
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout <= 'd0;
        end
        else if (en) begin
            dout <= din;
        end
    end

endmodule
