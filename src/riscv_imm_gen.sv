module riscv_imm_gen #(
    parameter   IBUS_DATA_WIDTH = -1,
    parameter   DBUS_DATA_WIDTH = -1
) (
    input   logic   [IBUS_DATA_WIDTH-1:0]   instr,
    output  logic   [DBUS_DATA_WIDTH-1:0]   imm
);

    logic   opcode;

    logic   is_rtype;
    logic   is_itype;
    logic   is_stype;
    logic   is_btype;
    logic   is_utype;
    logic   is_jtype;

    logic   [11:0]  imm_itype;
    logic   [11:0]  imm_stype;
    logic   [12:1]  imm_btype;
    logic   [31:12] imm_utype;
    logic   [20:1]  imm_jtype;

    logic   [DBUS_DATA_WIDTH-1:0]   imm_sext_itype;
    logic   [DBUS_DATA_WIDTH-1:0]   imm_sext_stype;
    logic   [DBUS_DATA_WIDTH-1:0]   imm_sext_btype;
    logic   [DBUS_DATA_WIDTH-1:0]   imm_sext_utype;
    logic   [DBUS_DATA_WIDTH-1:0]   imm_sext_jtype;

    // TODO
    assign opcode = instr[6:0];

    assign is_rtype;
    assign is_itype;
    assign is_stype;
    assign is_btyep;
    assign is_utype;
    assign is_jtype;

    assign imm_itype = instr[31:20];
    assign imm_stype = {instr[31:25], instr[11:7]};
    assign imm_btype = {instr[31], instr[7], instr[30:25], instr[11:8]};
    assign imm_utype = instr[31:12];
    assign imm_jtype = {instr[31], instr[19:12], instr[20], instr[30:21]};

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
        .DATA_WIDTH_I   (12             ),
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
        .DATA_WIDTH_I   (20             ),
        .DATA_WIDTH_O   (DBUS_DATA_WIDTH)
    ) U_RISCV_SEXT_JTYPE (
        .data_i         (imm_jtype      ),
        .data_o         (imm_sext_jtype )
    );

    // one-hot code
    always_comb begin
        case ({is_jtype, is_utype, is_btyep, is_stype, is_itype, is_rtype})
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
