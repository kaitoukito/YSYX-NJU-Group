module riscv_register_file #(
    parameter   DATA_WIDTH  = 64,
    parameter   ADDR_WIDTH  = $clog2(32)
) (
    input   logic                       clk,

    input   logic   [ADDR_WIDTH-1:0]    rd1_addr,
    input   logic                       rd1_en,
    output  logic   [DATA_WIDTH-1:0]    rd1_data,   // 1clk after rd1_en

    input   logic   [ADDR_WIDTH-1:0]    rd2_addr,
    input   logic                       rd2_en,
    output  logic   [DATA_WIDTH-1:0]    rd2_data,   // 1clk after rd2_en

    input   logic   [ADDR_WIDTH-1:0]    wr_addr,
    input   logic                       wr_en,
    input   logic   [DATA_WIDTH-1:0]    wr_data
);

    logic   [DATA_WIDTH-1:0]    rf  [31:0]; // register file

    always @(posedge clk) begin
        if (rd1_en) begin
            rd1_data <= rf[rd1_addr];
        end
    end

    always @(posedge clk) begin
        if (rd2_en) begin
            rd2_data <= rf[rd2_addr];
        end
    end

    always @(posedge clk) begin
        if (wr_en) begin
            rf[wr_addr] <= wr_data;
        end
    end

endmodule
