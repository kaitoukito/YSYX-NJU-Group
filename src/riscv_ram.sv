module riscv_ram #(
    parameter   DATA_WIDTH  = 64,
    parameter   DATA_DEPTH  = 4096, // 4096 * 64 / 8 Byte = 32KiB
        parameter   ADDR_WIDTH  = $clog2(DATA_DEPTH)
) (
    input   logic                       clk,
    input   logic                       we,         // 1: write, 0: read
    input   logic   [ADDR_WIDTH-1:0]    addr,
    input   logic   [DATA_WIDTH-1:0]    wr_data,
    output  logic   [DATA_WIDTH-1:0]    rd_data     // combinational logic, needs buffered before being used
);

    logic   [DATA_WIDTH-1:0]    mem [DATA_DEPTH-1:0];

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= wr_data;
        end
    end

    assign rd_data = mem[addr];

endmodule
