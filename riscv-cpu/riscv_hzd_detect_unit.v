/// hazard detection unit
`include "top_defines.v"
module riscv_hzd_detect_unit#(
    parameter   RF_ADDR_WIDTH   = -1
) (
    input   	[RF_ADDR_WIDTH-1:0] rs1_if2id_ff,
    input   	[RF_ADDR_WIDTH-1:0] rs2_if2id_ff,
	
    input   	[RF_ADDR_WIDTH-1:0] rd_id2ex_ff,
	input   	                    mem_read_id2ex_ff,
    input                           csr_rd_id2ex_ff,
    
    //input   	[RF_ADDR_WIDTH-1:0] rd_ex2mem_ff,
    //input       [1:0]               csr_rd_ex2mem_ff,
    output 	reg 	                stall
);
//notice that instr_id2ex may not have rs2
    always@(*) begin
        if ((mem_read_id2ex_ff | (csr_rd_id2ex_ff != 0)) && ((rd_id2ex_ff == rs1_if2id_ff) || (rd_id2ex_ff == rs2_if2id_ff)) && (rd_id2ex_ff!=0)) begin
            stall = 1'b1;
        end
        //else if(csr_rd_ex2mem_ff != 0) && ((rd_ex2mem_ff == rs1_if2id_ff) || (rd_ex2mem_ff == rs2_if2id_ff)) && (rd_ex2mem_ff!=0))begin
        //    stall = 1'b1;
        //end
		else stall = 1'b0;
    end

endmodule
