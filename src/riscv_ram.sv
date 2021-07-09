/// write enable phase = cs & we
/// read enable phase = cs & ~we
module riscv_ram #(
    parameter   DATA_WIDTH  = -1,
    parameter   ADDR_WIDTH  = -1
) (
    input   logic                       clk,
    input   logic                       cs,         // chip select signal
    input   logic                       we,         // 1: write, 0: read
    input   logic   [ADDR_WIDTH-1:0]    addr,
    input   logic   [DATA_WIDTH-1:0]    wr_data,
    output  logic   [DATA_WIDTH-1:0]    rd_data     // 1 clk delay after read enable phase
);

    logic   [DATA_WIDTH-1:0]    mem [2**ADDR_WIDTH-1:0];
    logic                       wr_en;
    logic                       rd_en;

    assign wr_en = cs & we;
    assign rd_en = cs & ~we;

    always @(posedge clk) begin
        if (wr_en) begin
            mem[addr] <= wr_data;
        end
    end

    always @(posedge clk) begin
        if (rd_en) begin
            rd_data <= mem[addr];
        end
    end

endmodule
