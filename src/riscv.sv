module riscv #(
    parameter   DATA_WIDTH  = 64
) (
    input   logic   clk,
    input   logic   rst_n
);

    logic   [DATA_WIDTH-1:0]    rd1_data_id2ex_stage;
    logic   [DATA_WIDTH-1:0]    imm_out_id2ex_stage;
    logic   [3:0]               alu_ctrl_id2ex_stage;
    logic   [DATA_WIDTH-1:0]    alu_out_id2ex_stage;
    logic                       zero_id2ex_stage;

    //----------------------------------------
    // IF stage
    //----------------------------------------

    // instruction memory, totally 32KiB
    riscv_ram #(
        .DATA_WIDTH (64     ),
        .DATA_DEPTH (4096   )
    ) U_IMEM (
        .clk        (),
        .we         (),
        .addr       (),
        .wr_data    (),
        .rd_data    ()
    );

    //----------------------------------------
    // ID stage
    //----------------------------------------



    //----------------------------------------
    // EX stage
    //----------------------------------------

    riscv_alu #(
        .WIDTH      (64),
    ) U_RISCV_ALU (
        .a          (rd1_data_id2ex_stage   ),
        .b          (imm_out_id2ex_stage    ),
        .alu_ctrl   (alu_ctrl_id2ex_stage   ),
        .alu_out    (alu_out_id2ex_stage    ),
        .zero       (zero_id2ex_stage       )
    )

    //----------------------------------------
    // MEM stage
    //----------------------------------------

    // data memory, totally 128KiB
    riscv_ram #(
        .DATA_WIDTH (64     ),
        .DATA_DEPTH (16384  )
    ) U_IMEM (
        .clk        (),
        .we         (),
        .addr       (),
        .wr_data    (),
        .rd_data    ()
    );

    //----------------------------------------
    // WB stage
    //----------------------------------------

endmodule
