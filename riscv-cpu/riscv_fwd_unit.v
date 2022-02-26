/// forwarding unit
`include"riscv_define.vh"
`include "top_defines.v"
module riscv_fwd_unit #(
    parameter   RF_ADDR_WIDTH   = -1		

) (
    input    	[RF_ADDR_WIDTH-1:0] rs1_id2ex_ff,
    input    	[RF_ADDR_WIDTH-1:0] rs2_id2ex_ff,
	
    input    	[RF_ADDR_WIDTH-1:0] rd_ex2mem_ff,
    input    	[RF_ADDR_WIDTH-1:0] rd_mem2wb_ff,
	
    input    	                    reg_write_ex2mem_ff,
    input    	                    reg_write_mem2wb_ff,
	
    output   reg	[1:0]               fwd_a,
    output   reg	[1:0]               fwd_b
);

    always@(*) begin
        if (reg_write_ex2mem_ff && (rd_ex2mem_ff != 'd0) && (rd_ex2mem_ff == rs1_id2ex_ff)) begin
            fwd_a = 2'b10;
        end
        else if (reg_write_mem2wb_ff && (rd_mem2wb_ff != 'd0) && (rd_mem2wb_ff == rs1_id2ex_ff)) begin
            fwd_a = 2'b01;
        end
        else begin
            fwd_a = 2'b00;
        end
    end

    always@(*) begin
        if (reg_write_ex2mem_ff && (rd_ex2mem_ff != 'd0) && (rd_ex2mem_ff == rs2_id2ex_ff)) begin
            fwd_b = 2'b10;
        end
        else if (reg_write_mem2wb_ff && (rd_mem2wb_ff != 'd0) && (rd_mem2wb_ff == rs2_id2ex_ff)) begin
            fwd_b = 2'b01;
        end
        else begin
            fwd_b = 2'b00;
        end
    end

endmodule
