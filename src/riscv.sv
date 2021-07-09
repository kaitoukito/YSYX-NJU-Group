module riscv #(
    parameter   DATA_WIDTH      = 32,
    parameter   RF_ADDR_WIDTH   = $clog(32),
    parameter   IMEM_ADDR_WIDTH = $clog(4096),
    parameter   DMEM_ADDR_WIDTH = $clog(16384)
) (
    input   logic   clk,
    input   logic   rst_n,      // asynchronous reset
    input   logic   sft_rst     // synchronous reset
);

    logic   [DATA_WIDTH-1:0]        pc;

    // IF nets

    // IF to ID FFs
    logic   [DATA_WIDTH-1:0]        instr_if2id_ff;

    // ID nets
    logic   [6:0]                   opcode_id_stage;
    logic                           alu_src_id_stage;
    logic                           mem2reg_id_stage;
    logic                           reg_write_id_stage;
    logic                           mem_read_id_stage;
    logic                           mem_write_id_stage;
    logic                           branch_id_stage;
    logic   [1:0]                   alu_op_id_stage;
    logic   [4:0]                   rd1_addr_id_stage;
    logic   [4:0]                   rd2_addr_id_stage;
    logic   [4:0]                   wr_addr_id_stage;
    logic   [DATA_WIDTH-1:0]        wr_data_id_stage;

    // ID 2 EX FFs
    logic   [DATA_WIDTH-1:0]        rd1_data_id2ex_ff;
    logic   [DATA_WIDTH-1:0]        rd2_data_id2ex_ff;

    // EX nets
    logic   [DATA_WIDTH-1:0]        a_ex_stage;
    logic   [DATA_WIDTH-1:0]        b_ex_stage;
    logic   [3:0]                   alu_ctrl_ex_stage;
    logic   [DATA_WIDTH-1:0]        alu_out_ex_stage;
    logic                           zero_ex_stage;

    // EX 2 MEM FFs
    logic   [DATA_WIDTH-1:0]        alu_out_ex2mem_ff;

    // MEM nets
    logic   [DMEM_ADDR_WIDTH-1:0]   dmem_addr_mem_stage;
    logic   [DATA_WIDTH-1:0]        dmem_wr_data_mem_stage;

    // MEM 2 WB FFs
    logic   [DATA_WIDTH-1:0]        dmem_rd_data_mem2wb_ff;
    logic   [DATA_WIDTH-1:0]        alu_out_mem2wb_ff;

    // WB nets

    //----------------------------------------
    // IF stage
    //----------------------------------------

    // instruction memory, totally 32KiB
    riscv_ram #(
        .DATA_WIDTH (DATA_WIDTH         ),
        .ADDR_WIDTH (IMEM_ADDR_WIDTH    )
    ) U_RISCV_IMEM (
        .clk        (clk                ),
        .cs         (1'b1               ),
        .we         (1'b0               ),
        .addr       (pc[ADDR_WIDTH-1:0] ),
        .wr_data    ({ADDR_WIDTH{1'b0}} ),
        .rd_data    (instr_if2id_ff     )
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

    riscv_rf #(
        .DATA_WIDTH (DATA_WIDTH         ),
        .ADDR_WIDTH (RF_ADDR_WIDTH      )
    ) U_RISCV_RF (
        .clk        (clk                ),
        .rd1_addr   (rd1_addr_id_stage  ),
        .rd1_en     (),
        .rd1_data   (rd1_data_id2ex_ff  ),
        .rd2_addr   (rd2_addr_id_stage  ),
        .rd2_en     (),
        .rd2_data   (rd2_data_id2ex_ff  ),
        .wr_addr    (wr_addr_id_stage   ),
        .wr_en      (),
        .wr_data    (wr_data_id_stage   )
);

    //----------------------------------------
    // EX stage
    //----------------------------------------

    riscv_alu #(
        .WIDTH      (64),
    ) U_RISCV_ALU (
        .a          (a_ex_stage         ),
        .b          (b_ex_stage         ),
        .alu_ctrl   (alu_ctrl_ex_stage  ),
        .alu_out    (alu_out_ex_stage   ),
        .zero       (zero_ex_stage      )
    )

    //----------------------------------------
    // MEM stage
    //----------------------------------------

    // data memory, totally 128KiB
    riscv_ram #(
        .DATA_WIDTH (64                 ),
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
