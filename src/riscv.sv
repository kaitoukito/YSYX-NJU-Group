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
    logic   [DBUS_DATA_WIDTH-1:0]   pc_seq_if_stage;

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
    logic   [3:0]                   func_code_id_stage;
    logic   [3:0]                   alu_ctrl_id_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   imm_id_stage;

    // ID 2 EX FFs
    logic   [DBUS_DATA_WIDTH-1:0]   rf_rd1_data_id2ex_ff;
    logic   [DBUS_DATA_WIDTH-1:0]   rf_rd2_data_id2ex_ff;
    logic   [DBUS_DATA_WIDTH-1:0]   imm_id2ex_ff;
    logic                           alu_src_id2ex_ff;
    logic   [3:0]                   alu_ctrl_id2ex_ff;
    logic   [DBUS_DATA_WIDTH-1:0]   pc_id2ex_ff;
    logic                           branch_id2ex_ff;
    logic                           pc_branch_id2ex_ff;

    // EX nets
    logic   [DBUS_DATA_WIDTH-1:0]   alu_a_ex_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   alu_b_ex_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   alu_out_ex_stage;
    logic                           zero_ex_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   adder_b_ex_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   adder_s_ex_stage;
    logic                           pc_sel_ex_stage;

    // EX 2 MEM FFs
    logic   [DBUS_DATA_WIDTH-1:0]   alu_out_ex2mem_ff;
    logic                           mem_read_ex2mem_ff;
    logic                           mem_write_ex2mem_ff;

    // MEM nets
    logic   [DMEM_ADDR_WIDTH-1:0]   dmem_addr_mem_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   dmem_wr_data_mem_stage;

    // MEM 2 WB FFs
    logic   [DBUS_DATA_WIDTH-1:0]   dmem_rd_data_mem2wb_ff;
    logic   [DBUS_DATA_WIDTH-1:0]   alu_out_mem2wb_ff;
    logic                           mem2reg_mem2wb_ff;
    logic                           reg_write_mem2wb_ff;

    // WB nets
    logic   [RF_ADDR_WIDTH-1:0]     rf_wr_addr_wb_stage;
    logic   [DBUS_DATA_WIDTH-1:0]   rf_wr_data_wb_stage;

    //----------------------------------------
    // Implementations
    //----------------------------------------

    assign pc_sel_ex_stage = branch_id2ex_ff & zero_ex_stage;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 'd0;
        end
        else if (sft_rst) begin
            pc <= 'd0;
        end
        else if (pc_sel_ex_stage) begin
            pc <= pc_branch_id2ex_ff;
        end
        else begin
            pc <= pc_seq_if_stage;
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
        .a          (pc                 ), // I
        .b          (64'd4              ), // I
        .s          (pc_seq_if_stage    )  // O
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
        .rd1_addr   (rf_rd1_addr_id_stage), // I
        .rd1_en     (1'b1               ), // I
        .rd1_data   (rf_rd1_data_id2ex_ff), // O
        .rd2_addr   (rf_rd2_addr_id_stage), // I
        .rd2_en     (1'b1               ), // I
        .rd2_data   (rf_rd2_data_id2ex_ff), // O
        .wr_addr    (rf_wr_addr_wb_stage), // I
        .wr_en      (reg_write_mem2wb_ff), // I
        .wr_data    (rf_wr_data_wb_stage)  // I
    );

    riscv_imm_gen #(
        .IBUS_DATA_WIDTH(IBUS_DATA_WIDTH),
        .DBUS_DATA_WIDTH(DBUS_DATA_WIDTH)
    ) U_RISCV_IMM_GEN (
        .instr      (instr_if2id_ff     ), // I
        .imm        (imm_id_stage       )  // O
    );

    assign func_code_id_stage = {instr_if2id_ff[30], instr_if2id_ff[14:12]};

    riscv_alu_ctrl (
        .alu_op     (alu_op_id_stage    ), // I
        .func_code  (func_code_id_stage ), // I
        .alu_ctrl   (alu_ctrl_id_stage  )  // O
    );

    // generate FFs of ID 2 EX stage
    module riscv_rs #(
        .DATA_WIDTH (4)
    ) U_RISCV_RS_ID2EX (
        .clk        (clk                ),
        .rst_n      (rst_n              ),
        .sft_rst    (sft_rst            ),
        .din        (alu_ctrl_id_stage),
        .en         (1'b1               ),
        .dout       (alu_ctrl_id2ex_ff)
    );

    //----------------------------------------
    // EX stage
    //----------------------------------------

    assign alu_a_ex_stage = rf_rd1_data_id2ex_ff;
    assign alu_b_ex_stage = alu_src_id2ex_ff ? imm_id2ex_ff : rf_rd2_data_id2ex_ff;

    riscv_alu #(
        .WIDTH      (DBUS_DATA_WIDTH    )
    ) U_RISCV_ALU (
        .a          (alu_a_ex_stage     ), // I
        .b          (alu_b_ex_stage     ), // I
        .alu_ctrl   (alu_ctrl_id2ex_ff  ), // I
        .alu_out    (alu_out_ex_stage   ), // O
        .zero       (zero_ex_stage      )  // O
    )

    assign adder_b_ex_stage = {imm_id2ex_ff[DBUS_DATA_WIDTH-2:0], 1'b0};

    riscv_adder #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    )
    ) U_RISCV_ADDER_EX (
        .a          (pc_id2ex_ff        ), // I
        .b          (adder_b_ex_stage   ), // I
        .s          (adder_s_ex_stage   )  // O
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
        .cs         (mem_read_ex2mem_ff | mem_write_ex2mem_ff), // I
        .we         (mem_write_ex2mem_ff), // I
        .addr       (dmem_addr_mem_stage[DMEM_ADDR_WIDTH-1:0]), // I
        .wr_data    (dmem_wr_data_mem_stage), // I
        .rd_data    (dmem_rd_data_mem2wb_ff)  // O
    );

    //----------------------------------------
    // WB stage
    //----------------------------------------

    assign rf_wr_data_wb_stage = mem2reg_mem2wb_ff ? dmem_rd_data_mem2wb_ff : alu_out_mem2wb_ff;

endmodule
