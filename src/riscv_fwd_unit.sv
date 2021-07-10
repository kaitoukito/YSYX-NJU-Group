/// forwarding unit
module riscv_fwd_unit #(
    parameter   RF_ADDR_WIDTH   = -1
) (
    input   logic   [RF_ADDR_WIDTH-1:0] rs1_id2ex_ff,
    input   logic   [RF_ADDR_WIDTH-1:0] rs2_id2ex_ff,

    input   logic   [RF_ADDR_WIDTH-1:0] rd_ex2mem_ff,
    input   logic   [RF_ADDR_WIDTH-1:0] rd_mem2wb_ff,

    input   logic                       reg_write_ex2mem_ff,
    input   logic                       reg_write_mem2wb_ff,

    output  logic   [1:0]               fwd_a,
    output  logic   [1:0]               fwd_b
);

    // blocked assignment
    // the second if-statement will cover the first one, if condition is true
    always_comb begin
        fwd_a = 2'b00;
        if (reg_write_mem2wb_ff && (rd_mem2wb_ff != 'd0) && (rd_mem2wb_ff == rs1_id2ex_ff)) begin
            fwd_a = 2'b01;
        end
        if (reg_write_ex2mem_ff && (rd_ex2mem_ff != 'd0) && (rd_ex2mem_ff == rs1_id2ex_ff)) begin
            fwd_a = 2'b10;
        end
    end

    // blocked assignment
    // the second if-statement will cover the first one, if condition is true
    always_comb begin
        fwd_b = 2'b00;
        if (reg_write_mem2wb_ff && (rd_mem2wb_ff != 'd0) && (rd_mem2wb_ff == rs2_id2ex_ff)) begin
            fwd_b = 2'b01;
        end
        if (reg_write_ex2mem_ff && (rd_ex2mem_ff != 'd0) && (rd_ex2mem_ff == rs2_id2ex_ff)) begin
            fwd_b = 2'b10;
        end
    end

endmodule
