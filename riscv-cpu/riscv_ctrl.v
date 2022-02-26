`include"riscv_define.vh"
`include "top_defines.v"
module riscv_ctrl (
    input   wire  [6:0]   opcode, // instruction[6:0]
	input	wire  [2:0]	  funct_code,
    output  reg           alu_src,
    output  reg   [2:0]   mem2reg,//000代表ALU提供寄存器输入，001代表存储器提供寄存器输入，010代表立即数提供寄存器输入，011代表PC+4提供寄存器输入,100代表PC+立即数提供寄存器输入
								  //101代表csr提供输入
    output  reg           reg_write,
    output  reg           mem_read,
    output  reg           mem_write,
    output  reg           branch,
	output  reg	  [1:0]	  pc_src_ctrl,//10寄存器加立即数计算结果跳转,01无条件跳转,00无强制跳转
    output  reg   [2:0]   alu_op,
	output	reg			  csr_rd
);

    //	ECALL,EBREAK unimplemented,maybe additional siganls need to be added
    always@(*) begin
        case (opcode)
            7'b000_0000 :   {csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00000_0000_00000;
			//LUI                                                                                             
            `LUI 		:   {csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00010_1000_00000;
			//AUIPC                                                                                           
			`AUIPC 		:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00100_1000_00000;
			//JAL                                                                                             
			`JAL 		:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00011_1000_01000;
			//JALR                                                                                            
			`JALR 		:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00011_1000_10000;
			//BEQ,BNE,BLT,BGE,BLTU,BGEU                                                                       
			`BRANCH 	:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00000_0001_00001;
			//LB,LH,LW,LBU,LHU                                                                                
			`LOAD 		:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b01001_1100_00000;
			//SB,SH,SW                                                                                        
			`STORE 		:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b01000_0010_00000;
			//ADDI,SLTI,SLTIU,XORI,ORI,ANNDI,SLLI,SRLI,SRAI                                                   
			`OP_IMM 	:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b01000_1000_00011;
			//ADD,SUB,SLL,SLT,SLTU,XOR,SRL,SRA,OR,AND                                                         
			`OP 		:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00000_1000_00010;
			//FENCE                                                                                           
			`MISC_MEM 	:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00000_0000_00000;
			//CSRRW,CSRRS,CSRRC,CSRRWI,CSRRSI,CSRRCI                                                                             
			`SYSTEM 	:begin
				if(funct_code == 3'b000)begin
					{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00000_0000_00000;
				end
				else begin
					{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b10101_1000_00000;
				end
			end
			//ADDIW,SLLIW,SRLIW,SRAIW                                                                                      
			`OP_IMM_32	:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b01000_1000_00111;
			//ADDW,SUBW,SLLW,SRLW,SRAW
			`OP_32		:	{csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b00000_1000_00110;
			default     :   {csr_rd,alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 14'b0000_0000_0000;
        endcase
    end

endmodule
