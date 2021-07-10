/// RV 64I Base Integer Instruction Set
module riscv #(
    parameter   IBUS_DATA_WIDTH = 32,               // instruction bus data width
    parameter   DBUS_DATA_WIDTH = 64,               // data bus data width
    parameter   RF_ADDR_WIDTH   = $clog2(32),       // register file address width
    parameter   IMEM_ADDR_WIDTH = $clog2(4096),     // instruction memory address width
    parameter   DMEM_ADDR_WIDTH = $clog2(16384)     // data memory address width
) (
    input   logic   clk,
    input   logic   rst_n,      // asynchronous reset
    input   logic   sft_rst     // synchronous reset
);

    //----------------------------------------
    // Declarations
    //----------------------------------------

    logic   [DBUS_DATA_WIDTH-1:0]   pc;

    // IF nets

    // IF to ID FFs
    logic   [IBUS_DATA_WIDTH-1:0]   instr_if2id_ff;

    // ID nets
    logic   [6:0]                   opcode_id_stage;
    logic                           alu_src_id_stage;
    logic                           mem2reg_id_stage;
    logic                           reg_write_id_stage;
    logic                           mem_read_id_stage;
    logic                           mem_write_id_stage;
    logic                           branch_id_stage;
    logic   [1:0]                   alu_op_id_stage;
    logic   [RF_ADDR_WIDTH-1:0]     rf_rd1_addr_id_stage;
    logic   [RF_ADDR_WIDTH-1:0]     rf_rd2_addr_id_stage;

    // ID 2 EX FFs
    logic   [DBUS_DATA_WIDTH-1:0]   rf_rd1_data_id2ex_ff;
    logic   [DBUS_DATA_WIDTH-1:0]   rf_rd2_data_id2ex_ff;
    logic   [DBUS_DATA_WIDTH-1:0]   imm_id2ex_ff;

    // EX nets
    logic   [DBUS_DATA_WIDTH-1:0]   a_ex_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   b_ex_stage;
    logic   [3:0]                   alu_ctrl_ex_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   alu_out_ex_stage;
    logic                           zero_ex_stage;

    // EX 2 MEM FFs
    logic   [DBUS_DATA_WIDTH-1:0]   alu_out_ex2mem_ff;

    // MEM nets
    logic   [DMEM_ADDR_WIDTH-1:0]   dmem_addr_mem_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   dmem_wr_data_mem_stage;

    // MEM 2 WB FFs
    logic   [DBUS_DATA_WIDTH-1:0]   dmem_rd_data_mem2wb_ff;
    logic   [DBUS_DATA_WIDTH-1:0]   alu_out_mem2wb_ff;

    // WB nets
    logic   [RF_ADDR_WIDTH-1:0]     rf_wr_addr_wb_stage;
    logic                           rf_wr_en_wb_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   rf_wr_data_wb_stage;

    //----------------------------------------
    // Implementations
    //----------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 'd0;
        end
        else if (sft_rst) begin
            pc <= 'd0;
        end
        else begin
            pc <= pc + 4;
        end
    end

    //----------------------------------------
    // IF stage
    //----------------------------------------

    // instruction memory
    riscv_ram #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    ),
        .ADDR_WIDTH (IMEM_ADDR_WIDTH    )
    ) U_RISCV_IMEM (
        .clk        (clk                ),
        .cs         (1'b1               ),
        .we         (1'b0               ),
        .addr       (pc[IMEM_ADDR_WIDTH-1:0]),
        .wr_data    ('0                 ),
        .rd_data    (instr_if2id_ff     )
    );

    riscv_adder #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    )
    ) U_RISCV_ADDER_IF (
        .a          (),
        .b          (),
        .s          ()
    );

    //----------------------------------------
    // ID stage
    //----------------------------------------

    assign opcode_id_stage = instr_if2id_ff[6:0];

    riscv_ctrl U_RISCV_CTRL (
        .opcode     (opcode_id_stage    ), // I
        .alu_src    (alu_src_id_stage   ), // O
        .mem2reg    (mem2reg_id_stage   ), // O
        .reg_write  (reg_write_id_stage ), // O
        .mem_read   (mem_read_id_stage  ), // O
        .mem_write  (mem_write_id_stage ), // O
        .branch     (branch_id_stage    ), // O
        .alu_op     (alu_op_id_stage    )  // O
    )

    assign rf_rd1_addr_id_stage = instr_if2id_ff[19:15];
    assign rf_rd2_addr_id_stage = instr_if2id_ff[24:20];

    riscv_rf #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    ),
        .ADDR_WIDTH (RF_ADDR_WIDTH      )
    ) U_RISCV_RF (
        .clk        (clk                ),
        .rd1_addr   (rf_rd1_addr_id_stage),
        .rd1_en     (1'b1               ),
        .rd1_data   (rf_rd1_data_id2ex_ff),
        .rd2_addr   (rf_rd2_addr_id_stage),
        .rd2_en     (1'b1               ),
        .rd2_data   (rf_rd2_data_id2ex_ff),
        .wr_addr    (rf_wr_addr_wb_stage),
        .wr_en      (rf_wr_en_wb_stage  ),
        .wr_data    (rf_wr_data_wb_stage)
    );

    riscv_imm_gen #(
        .IBUS_DATA_WIDTH(IBUS_DATA_WIDTH),
        .DBUS_DATA_WIDTH(DBUS_DATA_WIDTH)
) (
        .instr      (instr_if2id_ff     ), // I
        .imm        (imm_id2ex_ff       )  // O
);

    //----------------------------------------
    // EX stage
    //----------------------------------------

    riscv_alu #(
        .WIDTH      (DBUS_DATA_WIDTH    )
    ) U_RISCV_ALU (
        .a          (a_ex_stage         ),
        .b          (b_ex_stage         ),
        .alu_ctrl   (alu_ctrl_ex_stage  ),
        .alu_out    (alu_out_ex_stage   ),
        .zero       (zero_ex_stage      )
    )

    riscv_adder #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    )
    ) U_RISCV_ADDER_EX (
        .a          (),
        .b          (),
        .s          ()
    );

    //----------------------------------------
    // MEM stage
    //----------------------------------------

    // data memory
    riscv_ram #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    ),
        .ADDR_WIDTH (DMEM_ADDR_WIDTH    )
    ) U_RISCV_DMEM (
        .clk        (clk                ),
        .cs         (),
        .we         (),
        .addr       (dmem_addr_mem_stage),
        .wr_data    (dmem_wr_data_mem_stage),
        .rd_data    (dmem_rd_data_mem2wb_ff)
    );

    //----------------------------------------
    // WB stage
    //----------------------------------------

endmodule
