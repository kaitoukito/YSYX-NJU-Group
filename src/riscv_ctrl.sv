module riscv_ctrl (
    input   logic   [6:0]   opcode, // instruction[6:0]

    output  logic           alu_src,
    output  logic   [2:0]   mem2reg,//000代表ALU提供寄存器输入，001代表存储器提供寄存器输入，010代表立即数提供寄存器输入，011代表PC+4提供寄存器输入,100代表PC+立即数提供寄存器输入
    output  logic           reg_write,
    output  logic           mem_read,
    output  logic           mem_write,
    output  logic           branch,
	output  logic	[1:0]	pc_src_ctrl,//10寄存器加立即数计算结果跳转,01无条件跳转,00无强制跳转
    output  logic   [1:0]   alu_op
);

    // TODO
    always_comb begin
        case (opcode)
            7'b000_0000 :   {alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b0000_0000_0000;
			//LUI
            `LUI 		:   {alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b1010_1000_0000;
			//AUIPC
			`AUIPC 		:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b1100_1000_0000;
			//JAL
			`JAL 		:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b0011_1000_0100;
			//JALR
			`JALR 		:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b0011_1000_1000;
			//BEQ,BNE,BLT,BGE,BLTU,BGEU
			`BRANCH 	:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b0000_1001_0001;
			//LB,LH,LW,LBU,LHU
			`LOAD 		:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b1001_1100_0000;
			//SB,SH,SW
			`STORE 		:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b1000_0010_0000;
			//ADDI,SLTI,SLTIU,XORI,ORI,ANNDI,SLLI,SRLI,SRAI
			`OP_IMM 	:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b1000_1000_0010;
			//ADD,SUB,SLL,SLT,SLTU,XOR,SRL,SRA,OR,AND
			`OP 		:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b0000_1000_0010;
			//FENCE
			`MISC_MEM 	:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b0000_0000_0000;
			//ECALL,EBREAK
			`SYSTEM 	:	{alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b0000_0000_0000;
			default     :   {alu_src, mem2reg, reg_write, mem_read, mem_write, branch, pc_src_ctrl, alu_op} = 12'b0000_0000_0000;
        endcase
    end

endmodule
