/// hazard detection unit
module #(
    parameter   RF_ADDR_WIDTH   = -1
) (
    input   logic   [RF_ADDR_WIDTH-1:0] rs1_if2id_ff,
    input   logic   [RF_ADDR_WIDTH-1:0] rs2_if2id_ff,

    input   logic   [RF_ADDR_WIDTH-1:0] rd_id2ex_ff,

    input   logic                       mem_read_id2ex_ff,

    output  logic                       stall
);

    always_comb begin
        if (mem_read_id2ex_ff && ((rd_id2ex_ff == rs1_if2id_ff) || (rd_id2ex_ff == rs2_if2id_ff))) begin
            stall = 1'b1;
        end
    end

endmodule
