`include"riscv_define.vh"
`include "top_defines.v"
module riscv_jalr_hzd_detect_unit#(
    parameter   RF_ADDR_WIDTH   = -1			,
	parameter	IBUS_DATA_WIDTH = -1
) (
	input		[IBUS_DATA_WIDTH-1:0]	instr_if2id_ff,

	input   	[RF_ADDR_WIDTH-1:0] 	rd_id2ex_ff,
    input   	                    	reg_write_id2ex_ff,
	
	input   	[RF_ADDR_WIDTH-1:0] 	rd_ex2mem_ff,
	input								mem_read_ex2mem_ff,
    input   	                    	reg_write_ex2mem_ff,	
	
	input   	[RF_ADDR_WIDTH-1:0] 	rd_mem2wb_ff,
    input   	                    	reg_write_mem2wb_ff,
	
	output	reg	[1:0]					fwd_jalr,
    output 	reg 	                	stall_jalr
);

    always@(*) begin
        if (instr_if2id_ff[6:0]	== `JALR) begin
			if(instr_if2id_ff[19:15] == rd_id2ex_ff && reg_write_id2ex_ff)begin
				stall_jalr = 1'b1;
			end
			else if(instr_if2id_ff[19:15] == rd_ex2mem_ff && mem_read_ex2mem_ff)begin
				stall_jalr = 1'b1;
			end
			else stall_jalr = 1'b0;
		end
		else stall_jalr = 1'b0;
    end
	
	always@(*)begin
		if(instr_if2id_ff[6:0]	== `JALR)begin
			if(instr_if2id_ff[19:15] == rd_ex2mem_ff && reg_write_ex2mem_ff && !mem_read_ex2mem_ff)begin
				fwd_jalr = 2'b01;
			end
			else if(instr_if2id_ff[19:15] == rd_mem2wb_ff && reg_write_mem2wb_ff)begin
				fwd_jalr = 2'b10;
			end
			else fwd_jalr = 2'b00;
		end
		else fwd_jalr = 2'b00;
	end
endmodule