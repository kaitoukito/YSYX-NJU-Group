`include"riscv_define.vh"
`include "top_defines.v"
module riscv_imm_gen #(
    parameter   IBUS_DATA_WIDTH = -1,
    parameter   DBUS_DATA_WIDTH = -1
) (
    input   	    [IBUS_DATA_WIDTH-1:0]   instr,
    output  reg    [DBUS_DATA_WIDTH-1:0]   imm
);

    wire  [6:0] opcode;

    reg   is_rtype;
    reg   is_itype;
    reg   is_stype;
    reg   is_btype;
    reg   is_utype;
    reg   is_jtype;

    wire   [11:0]  imm_itype;
    wire   [11:0]  imm_stype;
    wire   [12:0]  imm_btype;
    wire   [19:0]  imm_utype;
    wire   [20:0]  imm_jtype;

    wire   [DBUS_DATA_WIDTH-1:0]   imm_sext_itype;
    wire   [DBUS_DATA_WIDTH-1:0]   imm_sext_stype;
    wire   [DBUS_DATA_WIDTH-1:0]   imm_sext_btype;
    wire   [DBUS_DATA_WIDTH-1:0]   imm_sext_utype;
    wire   [DBUS_DATA_WIDTH-1:0]   imm_sext_jtype;

    // TODO
	
	// assign is_rtype;
    // assign is_itype;
    // assign is_stype;
    // assign is_btype;
    // assign is_utype;
    // assign is_jtype;
	
	always@(*) begin
        case (opcode)
			`OP					            :	{is_jtype, is_utype, is_btype, is_stype, is_itype, is_rtype} = 6'b00_0001;
			`JALR,`LOAD,`OP_IMM,`OP_IMM_32	:   {is_jtype, is_utype, is_btype, is_stype, is_itype, is_rtype} = 6'b00_0010;
            `STORE  			            :   {is_jtype, is_utype, is_btype, is_stype, is_itype, is_rtype} = 6'b00_0100;
            `BRANCH 			            :   {is_jtype, is_utype, is_btype, is_stype, is_itype, is_rtype} = 6'b00_1000;
            `LUI,`AUIPC  		            :   {is_jtype, is_utype, is_btype, is_stype, is_itype, is_rtype} = 6'b01_0000;
            `JAL  				            :   {is_jtype, is_utype, is_btype, is_stype, is_itype, is_rtype} = 6'b10_0000;
            default     		            :   {is_jtype, is_utype, is_btype, is_stype, is_itype, is_rtype} = 6'b00_0000;
        endcase
    end
	
    assign opcode = instr[6:0];

    assign imm_itype = instr[31:20];
    assign imm_stype = {instr[31:25], instr[11:7]};
    assign imm_btype = {instr[31], instr[7], instr[30:25], instr[11:8],1'b0};
    assign imm_utype = instr[31:12];
    assign imm_jtype = {instr[31], instr[19:12], instr[20], instr[30:21],1'b0};

    riscv_ext #(
        .IS_SIGNED      (1              ),
        .DATA_WIDTH_I   (12             ),
        .DATA_WIDTH_O   (DBUS_DATA_WIDTH)
    ) U_RISCV_SEXT_ITYPE (
        .data_i         (imm_itype      ),
        .data_o         (imm_sext_itype )
    );

    riscv_ext #(
        .IS_SIGNED      (1              ),
        .DATA_WIDTH_I   (12             ),
        .DATA_WIDTH_O   (DBUS_DATA_WIDTH)
    ) U_RISCV_SEXT_STYPE (
        .data_i         (imm_stype      ),
        .data_o         (imm_sext_stype )
    );

    riscv_ext #(
        .IS_SIGNED      (1              ),
        .DATA_WIDTH_I   (13             ),
        .DATA_WIDTH_O   (DBUS_DATA_WIDTH)
    ) U_RISCV_SEXT_BTYPE (
        .data_i         (imm_btype      ),
        .data_o         (imm_sext_btype )
    );

    riscv_ext #(
        .IS_SIGNED      (1              ),
        .DATA_WIDTH_I   (20             ),
        .DATA_WIDTH_O   (DBUS_DATA_WIDTH)
    ) U_RISCV_SEXT_UTYPE (
        .data_i         (imm_utype      ),
        .data_o         (imm_sext_utype )
    );

    riscv_ext #(
        .IS_SIGNED      (1              ),
        .DATA_WIDTH_I   (21             ),
        .DATA_WIDTH_O   (DBUS_DATA_WIDTH)
    ) U_RISCV_SEXT_JTYPE (
        .data_i         (imm_jtype      ),
        .data_o         (imm_sext_jtype )
    );

    // one-hot code
    always@(*) begin
        case ({is_jtype, is_utype, is_btype, is_stype, is_itype, is_rtype})
            6'b00_0001  :   imm = 'd0;
            6'b00_0010  :   imm = imm_sext_itype;
            6'b00_0100  :   imm = imm_sext_stype;
            6'b00_1000  :   imm = imm_sext_btype;
            6'b01_0000  :   imm = imm_sext_utype;
            6'b10_0000  :   imm = imm_sext_jtype;
            default     :   imm = 'd0;
        endcase
    end

endmodule
