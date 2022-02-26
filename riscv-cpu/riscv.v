`include"riscv_define.vh"
`include "top_defines.v"
module riscv #(
	parameter   IBUS_DATA_WIDTH = 32,               // instruction bus data width
    parameter   DBUS_DATA_WIDTH = 64,               // data bus data width
    parameter   RF_ADDR_WIDTH   = $clog2(32),       // register file address width
    parameter   IMEM_ADDR_WIDTH = 64,     // instruction memory address width
    parameter   DMEM_ADDR_WIDTH = 64     // data memory address width

) (
	input   wire   clk,
    input   wire   sft_rst,     // synchronous reset

    // INST and DATA port
	input   wire   [IBUS_DATA_WIDTH-1:0]	i_inst   				,
	input                                   i_inst_valid            ,
	output  wire   [64 - 1:0] 				o_inst_addr    			,
	output  wire   							o_inst_ena    			,
	output	wire							o_inst_addr_valid		,
		
		
	output  wire   							o_data_wr_en  			,
	input	wire							i_data_wr_ready			,
	output  wire  						 	o_data_rd_en  			,
	input   wire   [DBUS_DATA_WIDTH-1 : 0] 	i_data_rd       		,
	input									i_data_rd_valid			,
    output  wire   [8-1 : 0] 				o_data_wmask 			,
	output  wire   [64 - 1 : 0] 			o_data_addr  			,
	output  wire   [DBUS_DATA_WIDTH-1 : 0] 	o_data_wr    			,

	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_0 		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_1 		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_2 		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_3 		,
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_4 		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_5 		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_6 		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_7 		,
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_8 		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_9 		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_10		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_11		,
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_12		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_13		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_14		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_15		,
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_16		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_17		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_18		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_19		,
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_20		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_21		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_22		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_23		,
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_24		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_25		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_26		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_27		,
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_28		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_29		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_30		,  
	output  wire   [DBUS_DATA_WIDTH-1 : 0]  o_rf_31		,

	// IRQ PORT
    input   i_clint_timer_irq,
	output  o_timer_irq_ready    // only for timer interrupt

			    
);


	//----------------------------------------
    // Declarations
    //----------------------------------------
	
	reg		[DBUS_DATA_WIDTH-1:0]   pc = 64'h8000_0000;		
	
	wire							inst_stall;
	wire                            pc_stall ;
	
	//  PC self-increment result
	wire	[DBUS_DATA_WIDTH-1:0]   pc_seq_if_stage;
	
	//	IF stage
	wire	[IBUS_DATA_WIDTH-1:0]	instr_if_stage;

	
	//  IF to ID FFs	
	wire	[IBUS_DATA_WIDTH-1:0]	instr_if2id_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	pc_if2id_ff;

	//ID stage	
	// ID opcode
	wire	[6:0]	opcode_id_stage;
	wire 	[2:0]	funct_code_id_stage;
	wire			ecall_if_stage;

	//opcode decode result
	wire	                        alu_src_id_stage;
    wire	[2:0]                   mem2reg_id_stage;
    wire	                        reg_write_id_stage;
    wire	                        mem_read_id_stage;
    wire	                        mem_write_id_stage;
    wire	                        branch_id_stage;
    wire	[2:0]                   alu_op_id_stage;
	wire	[1:0]					pc_src_id_stage;
	wire							csr_rd_id_stage;

	reg		[DBUS_DATA_WIDTH-1:0]	adder_s1_id_stage;
	reg		[DBUS_DATA_WIDTH-1:0]	adder_s2_id_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	pc_jump_id_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	rf_s1_id_stage;
	wire							jump_signal;
	
	wire    [RF_ADDR_WIDTH-1:0]     rf_rd1_addr_id_stage;
	wire    [RF_ADDR_WIDTH-1:0]     rf_rd2_addr_id_stage;
	wire    [DBUS_DATA_WIDTH-1:0]	rf_rd1_data_id_stage;
	wire    [DBUS_DATA_WIDTH-1:0]	rf_rd2_data_id_stage;
	wire    [DBUS_DATA_WIDTH-1:0]   imm_id_stage;
	wire	[3:0]					alu_ctrl_id_stage;
	
	wire							stall_hzd;//stall signal
	wire	[1:0]					fwd_jalr;
	wire							stall_jalr;
	//  ID to EX FFs	
	//opcode decode result ff
	wire	                        alu_src_id2ex_ff;
    wire	[2:0]                   mem2reg_id2ex_ff;
    wire	   	                    reg_write_id2ex_ff;
    wire	       	                mem_read_id2ex_ff;
    wire	           	            mem_write_id2ex_ff;
    wire	               	        branch_id2ex_ff;
    wire	[2:0]                   alu_op_id2ex_ff;
	wire	[1:0]					pc_src_id2ex_ff;
	wire	[3:0]					alu_ctrl_id2ex_ff;
	wire							csr_rd_id2ex_ff;

	wire	[IBUS_DATA_WIDTH-1:0] 	instr_id2ex_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	imm_id2ex_ff;
	wire   	[DBUS_DATA_WIDTH-1:0]   rf_rd1_data_id2ex_ff;
	wire 	[DBUS_DATA_WIDTH-1:0]   rf_rd2_data_id2ex_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	pc_id2ex_ff;
	
	
	//EX stage
	reg		[DBUS_DATA_WIDTH-1:0]	alu_s1_data_ex_stage;
	reg		[DBUS_DATA_WIDTH-1:0]	alu_s2_data_ex_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	adder_b_ex_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	adder_s_ex_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	imm_ls_ex_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	alu_a_ex_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	alu_b_ex_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	alu_out_ex_stage;
	wire	[DBUS_DATA_WIDTH-1:0]	store_rd2_data_ex_stage;
	reg		[DBUS_DATA_WIDTH-1:0]	result_ex_stage;
	wire							zero_ex_stage;
	wire							branch_out_signal;
	wire	[1:0]					fwd_a;
	wire	[1:0]					fwd_b;
	
	//EX to MEM FFs
	wire	[2:0]                   mem2reg_ex2mem_ff;
    wire	   	                    reg_write_ex2mem_ff;
    wire	       	                mem_read_ex2mem_ff;
    wire	           	            mem_write_ex2mem_ff;
	
	wire	[DBUS_DATA_WIDTH-1:0]	adder_s_ex2mem_ff;	
	wire	[IBUS_DATA_WIDTH-1:0] 	instr_ex2mem_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	imm_ls_ex2mem_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	pc_ex2mem_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	alu_out_ex2mem_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	result_ex2mem_ff;
	wire   	[DBUS_DATA_WIDTH-1:0]   rf_rd1_data_ex2mem_ff;
	wire 	[DBUS_DATA_WIDTH-1:0]   rf_rd2_data_ex2mem_ff;
	wire 							csr_rd_ex2mem_ff;			
	//MEM stage
	wire 	[DBUS_DATA_WIDTH-1:0]   rd_data_mem_stage;
	wire 	[DBUS_DATA_WIDTH-1:0]   load_data_mem_stage;
	wire							mem_stall;
	
	//MEM to WB FFs
	wire	[IBUS_DATA_WIDTH-1:0] 	instr_mem2wb_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	result_mem2wb_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	rd_data_mem2wb_stage;
	wire	[2:0]                   mem2reg_mem2wb_ff;
    wire	   	                    reg_write_mem2wb_ff;
	wire 							csr_rd_mem2wb_ff;	
	wire	[DBUS_DATA_WIDTH-1:0]	adder_s_mem2wb_ff;
	//wire	[IBUS_DATA_WIDTH-1:0]	instr_mem2wb_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	imm_ls_mem2wb_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	pc_mem2wb_ff;
	wire	[DBUS_DATA_WIDTH-1:0]	alu_out_mem2wb_ff;
	//WB stage
	reg		[DBUS_DATA_WIDTH-1:0]	wr_data_wb_stage;
	reg 	[DBUS_DATA_WIDTH-1:0]	rd_csr_data;
	reg		[DBUS_DATA_WIDTH-1:0]	wr_csr_data;
	wire                            reg_write_wb_stage  ;

	//CSR interface
	wire    [DBUS_DATA_WIDTH-1:0]   w_pc_mtvec 			;
	wire    [DBUS_DATA_WIDTH-1:0]   w_pc_mepc 			;
	wire    						w_excep_flush		;
	wire  							w_irq_flush			;
	wire 	[1:0]					w_excep_csr_upd 	;
	wire							w_mret_csr_upd  	;                                                    
	wire    [DBUS_DATA_WIDTH-1:0] 	w_mie               ;
    wire    [DBUS_DATA_WIDTH-1:0] 	w_mstatus           ;  
	//----------------------------------------
    // Implementations
    //----------------------------------------
	
	always @(posedge clk) begin
		if (sft_rst) begin
            pc <= 64'h8000_0000;
        end
		else if (w_mret_csr_upd) begin
			pc <= w_pc_mepc ;
		end
		else if (w_excep_flush | w_irq_flush) begin
			pc <= {w_pc_mtvec[DBUS_DATA_WIDTH-1:2],2'b0} ;
		end
        else if (branch_out_signal) begin
            pc <= adder_s_ex_stage;
        end
		else if(jump_signal) begin
			pc <= pc_jump_id_stage;
		end
		//stall the pipeline
		else if (stall_hzd | stall_jalr | inst_stall | mem_stall)begin//not implemented
			pc <= pc;
		end
		else if (instr_if_stage[6:0] == `JALR)begin
			pc <= {pc_seq_if_stage[DBUS_DATA_WIDTH-1:1],1'b0};
		end
		// else if (ecall_if_stage)begin
		// 	pc <= {U_CSR.csr_rg[`mtvec][63:2],2'b0};
		// end
		//pc+4 or jump instruction
        else begin
            pc <= pc_seq_if_stage;
        end
    end
	
	
	
	//----------------------------------------
    // IF stage
    //----------------------------------------

	assign instr_if_stage 		= (o_inst_addr_valid & i_inst_valid)?i_inst:'d0					;
	assign o_inst_addr    		= {pc[IMEM_ADDR_WIDTH-1:0]}  									;
	assign o_inst_ena     		= 1      														;
	assign inst_stall			= o_inst_addr_valid && !i_inst_valid							;
	
	assign pc_stall = stall_hzd | stall_jalr | (mem_stall) 					    				;
	assign o_inst_addr_valid	= (o_inst_addr != 'd0) & !(pc_stall)							;//not implemented
	
	
	
	assign ecall_if_stage = (instr_if_stage[6:0] == `SYSTEM && instr_if_stage[14:12] == 3'b000) ;


	riscv_adder #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    )
    ) U_RISCV_ADDER_IF (
        .a          (pc				    ), // I
        .b          (64'd4			    ), // I
        .s          (pc_seq_if_stage    )  // O
    );
	
	// always@(*)begin
		// case(instr_if_stage[6:0])
			// `JALR:begin	
				// if(fwd_jalr == 2'b01)	adder_s1_if_stage = result_ex2mem_ff;
				// else if(fwd_jalr == 2'b10)	adder_s1_if_stage = wr_data_wb_stage;
				// else adder_s1_if_stage = rf_s1_if_stage;		
			// end
			// default:	adder_s1_if_stage = pc;
		// endcase
	// end
	
	// always@(*)begin
		// case(instr_if_stage[6:0])
			// `JAL:	adder_s2_if_stage = {{43{instr_if_stage[31]}},instr_if_stage[31],instr_if_stage[19:12],instr_if_stage[20],instr_if_stage[30:21],1'b0};
			// `JALR:	adder_s2_if_stage = {{52{instr_if_stage[31]}},instr_if_stage[31:20]};
			// default:	adder_s2_if_stage = 64'd4;
		// endcase
	// end
	
	// riscv_jalr_hzd_detect_unit#(
		// .RF_ADDR_WIDTH(RF_ADDR_WIDTH),
		// .IBUS_DATA_WIDTH(IBUS_DATA_WIDTH)
	// ) U_RISCV_JALR_HZD_DETECT_UNIT_IF(

		// .instr_if_stage(instr_if_stage),
		// .instr_if2id_ff(instr_if2id_ff),
		// .reg_write_id_stage(reg_write_id_stage),
		// .rd_id2ex_ff(instr_id2ex_ff[11:7]),
		// .reg_write_id2ex_ff(reg_write_id2ex_ff),
		// .rd_ex2mem_ff(instr_ex2mem_ff[11:7]),
		// .mem_read_ex2mem_ff(mem_read_ex2mem_ff),
		// .reg_write_ex2mem_ff(reg_write_ex2mem_ff),	
		// .rd_mem2wb_ff(instr_mem2wb_ff[11:7]),
		// .reg_write_mem2wb_ff(reg_write_mem2wb_ff),
		// .fwd_jalr(fwd_jalr),
		// .stall_jalr(stall_jalr)
	// );
	//funct_code_id_stage
	//----------------------------------------
    // IF to ID FFs
    //----------------------------------------
	riscv_rs #(
		.DATA_WIDTH(IBUS_DATA_WIDTH+DBUS_DATA_WIDTH)
	)U_RISCV_RS_IF2ID (
		.clk(clk),
		.sft_rst(sft_rst),
		.din({instr_if_stage,pc}),
		.flush(w_irq_flush | w_excep_flush | w_mret_csr_upd),//when excep occurs, this instr should not be executed
		
		
		.stall(stall_hzd | mem_stall | stall_jalr),
		
		
		.en(!branch_out_signal & !inst_stall & !jump_signal),//two scenes:stall the pipeline or branch instruction
		.dout({instr_if2id_ff,pc_if2id_ff})
	);
	
	//----------------------------------------
    // ID stage
    //----------------------------------------
	
	assign opcode_id_stage = instr_if2id_ff[6:0];
	assign funct_code_id_stage = instr_if2id_ff[14:12];
	assign jump_signal = (opcode_id_stage == `JAL) | (opcode_id_stage == `JALR);
	
	riscv_adder #(
      .DATA_WIDTH (DBUS_DATA_WIDTH    )
    ) U_RISCV_ADDER_ID (
        .a          (adder_s1_id_stage  ), // I
        .b          (adder_s2_id_stage  ), // I
        .s          (pc_jump_id_stage   )  // O  // pc_jalr_id_stage => pc_jump_id_stage
    );
	
	always@(*)begin
		case(opcode_id_stage)
			`JALR:begin	
				if(fwd_jalr == 2'b01)	adder_s1_id_stage = result_ex2mem_ff;
				else if(fwd_jalr == 2'b10)	adder_s1_id_stage = wr_data_wb_stage;
				else adder_s1_id_stage = rf_s1_id_stage;		
			end
			default:	adder_s1_id_stage = pc_if2id_ff;
		endcase
	end
	
	always@(*)begin
		case(opcode_id_stage)
			`JAL:	adder_s2_id_stage = {{43{instr_if2id_ff[31]}},instr_if2id_ff[31],instr_if2id_ff[19:12],instr_if2id_ff[20],instr_if2id_ff[30:21],1'b0};
			`JALR:	adder_s2_id_stage = {{52{instr_if2id_ff[31]}},instr_if2id_ff[31:20]};
			default:	adder_s2_id_stage = 64'd0;
		endcase
	end
	
	riscv_jalr_hzd_detect_unit#(
		.RF_ADDR_WIDTH(RF_ADDR_WIDTH),
		.IBUS_DATA_WIDTH(IBUS_DATA_WIDTH)
	) U_RISCV_JALR_HZD_DETECT_UNIT_ID(
		.instr_if2id_ff(instr_if2id_ff),
		.rd_id2ex_ff(instr_id2ex_ff[11:7]),
		.reg_write_id2ex_ff(reg_write_id2ex_ff),
		.rd_ex2mem_ff(instr_ex2mem_ff[11:7]),
		.mem_read_ex2mem_ff(mem_read_ex2mem_ff),
		.reg_write_ex2mem_ff(reg_write_ex2mem_ff),	
		.rd_mem2wb_ff(instr_mem2wb_ff[11:7]),
		.reg_write_mem2wb_ff(reg_write_mem2wb_ff),
		.fwd_jalr(fwd_jalr),
		.stall_jalr(stall_jalr)
	);

	
	riscv_ctrl U_RISCV_CTRL (
        .opcode     (opcode_id_stage    ), // I
		.funct_code	(funct_code_id_stage),
        .alu_src    (alu_src_id_stage   ), // O
        .mem2reg    (mem2reg_id_stage   ), // O
        .reg_write  (reg_write_id_stage ), // O
        .mem_read   (mem_read_id_stage  ), // O
        .mem_write  (mem_write_id_stage ), // O
        .branch     (branch_id_stage    ), // O
		.pc_src_ctrl(pc_src_id_stage	), // O
        .alu_op     (alu_op_id_stage    ),  // O
		.csr_rd		(csr_rd_id_stage	)
    );
	
	riscv_alu_ctrl U_RISCV_ALU_CTRL(
		.alu_op(alu_op_id_stage),
		.func_code({instr_if2id_ff[30],instr_if2id_ff[14:12]}),
		.alu_ctrl(alu_ctrl_id_stage)
	);
	
	assign rf_rd1_addr_id_stage = instr_if2id_ff[19:15];
    assign rf_rd2_addr_id_stage = instr_if2id_ff[24:20];
	
	
	riscv_rf #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    ),
        .ADDR_WIDTH (RF_ADDR_WIDTH      )
    ) U_RISCV_RF (
        .clk        (clk                ), // I
        .rd1_addr   (rf_rd1_addr_id_stage), // I
        .rd1_en     (1'b1               ), // I
        .rd1_data   (rf_rd1_data_id_stage), // O
        .rd2_addr   (rf_rd2_addr_id_stage), // I
        .rd2_en     (1'b1               ), // I
        .rd2_data   (rf_rd2_data_id_stage), // O
		
		//JALR read register in IF stage 
		.rd3_addr   (instr_if2id_ff[19:15]),
		.rd3_en     (1'b1               ), // I
        .rd3_data   (rf_s1_id_stage		), // O
		
        .wr_addr    (instr_mem2wb_ff[11:7]), // I
        .wr_en      (reg_write_wb_stage), // I
        .wr_data    (wr_data_wb_stage),  // 
		.o_rf_0     (o_rf_0 ),
		.o_rf_1     (o_rf_1 ),
		.o_rf_2     (o_rf_2 ),
		.o_rf_3     (o_rf_3 ), 
		.o_rf_4     (o_rf_4 ),
		.o_rf_5     (o_rf_5 ),  
		.o_rf_6     (o_rf_6 ),
		.o_rf_7     (o_rf_7 ),
		.o_rf_8     (o_rf_8 ),
		.o_rf_9     (o_rf_9 ), 
		.o_rf_10    (o_rf_10),
		.o_rf_11    (o_rf_11),  
		.o_rf_12    (o_rf_12),
		.o_rf_13    (o_rf_13),
		.o_rf_14    (o_rf_14),
		.o_rf_15    (o_rf_15), 
		.o_rf_16    (o_rf_16),
		.o_rf_17    (o_rf_17),  
		.o_rf_18    (o_rf_18),
		.o_rf_19    (o_rf_19),
		.o_rf_20    (o_rf_20),
		.o_rf_21    (o_rf_21), 
		.o_rf_22    (o_rf_22),
		.o_rf_23    (o_rf_23), 
		.o_rf_24    (o_rf_24),
		.o_rf_25    (o_rf_25),  
		.o_rf_26    (o_rf_26),
		.o_rf_27    (o_rf_27),
		.o_rf_28    (o_rf_28),
		.o_rf_29    (o_rf_29), 
		.o_rf_30    (o_rf_30),
		.o_rf_31    (o_rf_31)
    );
	
	riscv_imm_gen #(
        .IBUS_DATA_WIDTH(IBUS_DATA_WIDTH),
        .DBUS_DATA_WIDTH(DBUS_DATA_WIDTH)
    ) U_RISCV_IMM_GEN (
        .instr      (instr_if2id_ff     ), // I
        .imm        (imm_id_stage       )  // O
    );

	riscv_hzd_detect_unit#(
		.RF_ADDR_WIDTH(RF_ADDR_WIDTH)
	)U_RISCV_HZD_DETECT_UNIT (
		.rs1_if2id_ff(instr_if2id_ff[19:15]),
		.rs2_if2id_ff(instr_if2id_ff[24:20]),
		
		.rd_id2ex_ff(instr_id2ex_ff[11:7]),
		.csr_rd_id2ex_ff(csr_rd_id2ex_ff),
		//.csr_rd_ex2mem_ff(csr_rd_ex2mem_ff),
		.mem_read_id2ex_ff(mem_read_id2ex_ff),
	    
		.stall(stall_hzd)
	);
	
	//---------------------------------riscv_rs-------
    // ID to EX FFs
    //----------------------------------------
	riscv_rs #(
		.DATA_WIDTH(1+1+3+1+1+1+1+3+2+4+IBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH)
	)U_RISCV_RS_ID2EX (
		.clk(clk),
		.sft_rst(sft_rst),
		.stall(mem_stall),
		.flush(w_irq_flush | w_excep_flush | w_mret_csr_upd),
		.din({
			alu_src_id_stage,
			mem2reg_id_stage,
			reg_write_id_stage,
			mem_read_id_stage,
			mem_write_id_stage,
			branch_id_stage,
			alu_op_id_stage,
			pc_src_id_stage,
			alu_ctrl_id_stage,
			csr_rd_id_stage,
			instr_if2id_ff,
			imm_id_stage,
			rf_rd1_data_id_stage,
			rf_rd2_data_id_stage,
			pc_if2id_ff
		}),
		.en(!branch_out_signal & !stall_hzd & !stall_jalr),//branch instruction
		.dout({
			alu_src_id2ex_ff,
		    mem2reg_id2ex_ff,
		    reg_write_id2ex_ff,
		    mem_read_id2ex_ff,
		    mem_write_id2ex_ff,
		    branch_id2ex_ff,
		    alu_op_id2ex_ff,
		    pc_src_id2ex_ff,
		    alu_ctrl_id2ex_ff,
			csr_rd_id2ex_ff,
			instr_id2ex_ff,
			imm_id2ex_ff,
			rf_rd1_data_id2ex_ff,
			rf_rd2_data_id2ex_ff,
			pc_id2ex_ff
		})
	);
	
	//----------------------------------------
    // EX Stage
    //----------------------------------------	
	
	assign alu_a_ex_stage = alu_s1_data_ex_stage;
	assign alu_b_ex_stage = (alu_src_id2ex_ff == 1)?imm_id2ex_ff:alu_s2_data_ex_stage;

	always@(*)begin
		case(fwd_a)
			2'b10:	alu_s1_data_ex_stage = result_ex2mem_ff;
			2'b01:	alu_s1_data_ex_stage = wr_data_wb_stage;
			default:	alu_s1_data_ex_stage = rf_rd1_data_id2ex_ff[DBUS_DATA_WIDTH-1:0];
		endcase
	end
	
	always@(*)begin
		case(fwd_b)
			2'b10:	alu_s2_data_ex_stage = result_ex2mem_ff;
			2'b01:	alu_s2_data_ex_stage = wr_data_wb_stage;
			default:	alu_s2_data_ex_stage = rf_rd2_data_id2ex_ff[DBUS_DATA_WIDTH-1:0];
		endcase
	end
	
	riscv_alu #(
        .WIDTH      (DBUS_DATA_WIDTH    )
    ) U_RISCV_ALU (
        .a          (alu_a_ex_stage     ), // I
        .b          (alu_b_ex_stage     ), // I
        .alu_ctrl   (alu_ctrl_id2ex_ff  ), // I
        .alu_out    (alu_out_ex_stage   ), // O
        .zero       (zero_ex_stage      )  // O
    );
	
	riscv_branch #(
		.WIDTH(DBUS_DATA_WIDTH)
	) U_RISCV_BRANCH(
		.branch(branch_id2ex_ff),
		.func_code(instr_id2ex_ff[14:12]),
		.alu_out(alu_out_ex_stage[DBUS_DATA_WIDTH-1]),
		.rs1(alu_a_ex_stage[DBUS_DATA_WIDTH-1]),
		.rs2(alu_b_ex_stage[DBUS_DATA_WIDTH-1]),
		.zero(zero_ex_stage),
		.branch_out(branch_out_signal)
	);

	riscv_adder #(
        .DATA_WIDTH (DBUS_DATA_WIDTH    )
    ) U_RISCV_ADDER_EX (
        .a          (pc_id2ex_ff        ), // I
        .b          (adder_b_ex_stage   ), // I
        .s          (adder_s_ex_stage   )  // O
    );
	
	//立即数左移12位结果,符号扩展已在立即数生成时完成
	assign imm_ls_ex_stage = imm_id2ex_ff<<12;
	
	//指令是AUIPC、分支指令时需特殊对待
	assign adder_b_ex_stage = (mem2reg_id2ex_ff == 3'b100)?imm_ls_ex_stage:((branch_id2ex_ff == 1)?imm_id2ex_ff:64'd4);
	
	riscv_fwd_unit #(
    .RF_ADDR_WIDTH(RF_ADDR_WIDTH)
	) U_RISCV_FWD_UNIT(
		.rs1_id2ex_ff(instr_id2ex_ff[19:15]),
		.rs2_id2ex_ff(instr_id2ex_ff[24:20]),
		
		.rd_ex2mem_ff(instr_ex2mem_ff[11:7]),
		.rd_mem2wb_ff(instr_mem2wb_ff[11:7]),
	
		.reg_write_ex2mem_ff(reg_write_ex2mem_ff),
		.reg_write_mem2wb_ff(reg_write_mem2wb_ff),
	
		.fwd_a(fwd_a),
		.fwd_b(fwd_b)
	);
	
	always@(*)begin
		case(mem2reg_id2ex_ff)
			3'b000:	result_ex_stage = alu_out_ex_stage;
			3'b001:	result_ex_stage = alu_out_ex_stage;
			3'b010:	result_ex_stage = imm_ls_ex_stage;
			3'b011:	result_ex_stage = adder_s_ex_stage;
			3'b100:	result_ex_stage = adder_s_ex_stage;
			default:	result_ex_stage = alu_out_ex_stage;
		endcase
	end
	
	wire[7:0]	data_wmask;

	riscv_store#(
    .WIDTH (DBUS_DATA_WIDTH)
	) RISCV_STORE_EX(
		.mem_read(mem_read_id2ex_ff),
		.mem_write(mem_write_id2ex_ff),
		.func_code(instr_id2ex_ff[14:12]),
		.reg2_out(alu_s2_data_ex_stage[DBUS_DATA_WIDTH-1:0]),
		.store_out(store_rd2_data_ex_stage),
		.mask_out(data_wmask)
	);
	
	//----------------------------------------
    // EX to MEM FFs
    //----------------------------------------
	riscv_rs #(
		.DATA_WIDTH(1+8+3+1+1+1+DBUS_DATA_WIDTH+IBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH)
	)U_RISCV_RS_EX2MEM (
		.clk(clk),
		.sft_rst(sft_rst),
		.stall(mem_stall),
		.flush(w_irq_flush | w_excep_flush | w_mret_csr_upd),
		.din({
			mem2reg_id2ex_ff,
			reg_write_id2ex_ff,
			mem_read_id2ex_ff,
			mem_write_id2ex_ff,
			csr_rd_id2ex_ff,
			data_wmask,
			adder_s_ex_stage,
			instr_id2ex_ff,
			imm_ls_ex_stage,
			pc_id2ex_ff,
			alu_out_ex_stage,
			result_ex_stage,
			rf_rd1_data_id2ex_ff,
			store_rd2_data_ex_stage
		}),
		.en(1'b1), // 1'b1
		.dout({
			mem2reg_ex2mem_ff,
			reg_write_ex2mem_ff,
			mem_read_ex2mem_ff,
			mem_write_ex2mem_ff,
			csr_rd_ex2mem_ff,
			o_data_wmask,
			adder_s_ex2mem_ff,
			instr_ex2mem_ff,
			imm_ls_ex2mem_ff,
			pc_ex2mem_ff,
			alu_out_ex2mem_ff,
			result_ex2mem_ff,
			rf_rd1_data_ex2mem_ff,
			rf_rd2_data_ex2mem_ff
		})
	);
	
	//----------------------------------------
    // MEM stage
    //----------------------------------------
	
	assign o_data_wr_en  	= (mem_read_ex2mem_ff | mem_write_ex2mem_ff) &   mem_write_ex2mem_ff & !(w_irq_flush | w_excep_flush | w_mret_csr_upd);
	assign o_data_rd_en  	= (mem_read_ex2mem_ff | mem_write_ex2mem_ff) & (~mem_write_ex2mem_ff) & !(w_irq_flush | w_excep_flush | w_mret_csr_upd);
	assign o_data_addr  	= {alu_out_ex2mem_ff[DMEM_ADDR_WIDTH-1:0]};
	assign o_data_wr    	= rf_rd2_data_ex2mem_ff;
	assign rd_data_mem_stage  = i_data_rd    		;

	riscv_load #(
		.WIDTH (DBUS_DATA_WIDTH)
	) RISCV_LOAD_DMEM(
		.mem_read(mem_read_ex2mem_ff),
		.func_code(instr_ex2mem_ff[14:12]),
		.mem_out(rd_data_mem_stage),
		.load_out(load_data_mem_stage)
	);

	assign mem_stall = {o_data_wr_en & !i_data_wr_ready} | (o_data_rd_en & !i_data_rd_valid);
	
	wire [63:0]	o_data_addr_mem2wb_ff;

	//----------------------------------------
    // MEM to WB FFs
    //----------------------------------------
	riscv_rs #(
		.DATA_WIDTH(1+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+3+1+DBUS_DATA_WIDTH+DBUS_DATA_WIDTH+IBUS_DATA_WIDTH+DBUS_DATA_WIDTH)
	)U_RISCV_RS_MEM2WB (
		.clk(clk),
		.sft_rst(sft_rst),
		.stall(1'd0),
		.flush(w_irq_flush | w_excep_flush | w_mret_csr_upd),
		.din({
			load_data_mem_stage,
			mem2reg_ex2mem_ff,
			reg_write_ex2mem_ff,
			csr_rd_ex2mem_ff,
			imm_ls_ex2mem_ff,
			pc_ex2mem_ff,
			alu_out_ex2mem_ff,
			instr_ex2mem_ff,
			result_ex2mem_ff,
			adder_s_ex2mem_ff,
			o_data_addr
		}),
		.en(!mem_stall), //1'b1
		.dout({
			rd_data_mem2wb_stage,
			mem2reg_mem2wb_ff,
			reg_write_mem2wb_ff,
			csr_rd_mem2wb_ff,
			imm_ls_mem2wb_ff,
			pc_mem2wb_ff,
			alu_out_mem2wb_ff,
			instr_mem2wb_ff,
			result_mem2wb_ff,
			adder_s_mem2wb_ff,
			o_data_addr_mem2wb_ff
		})
	);
	//----------------------------------------
    // WB stage
    //----------------------------------------
	
	always@(*)begin
		if(reg_write_mem2wb_ff && (instr_mem2wb_ff[11:7] != 0))begin
			case(mem2reg_mem2wb_ff)
				3'b000:	wr_data_wb_stage = alu_out_mem2wb_ff;
				3'b001:	wr_data_wb_stage = rd_data_mem2wb_stage;
				3'b010:	wr_data_wb_stage = imm_ls_mem2wb_ff;
				3'b011:	wr_data_wb_stage = adder_s_mem2wb_ff;
				3'b100:	wr_data_wb_stage = adder_s_mem2wb_ff;
				3'b101:	wr_data_wb_stage = rd_csr_data;
				default:	wr_data_wb_stage = 64'd0;
			endcase
		end
		else	wr_data_wb_stage = 64'd0;
	end

	riscv_csr#(
    	.ADDR_WIDTH(12),
    	.D_BUS_WIDTH(64)
	)U_CSR(
	    .clk(clk),
	    .rst(sft_rst),

	    .wr_en(csr_rd_mem2wb_ff),
	    .wr_addr(instr_mem2wb_ff[31:20]),
	    .wr_data(wr_csr_data),
        .rd_en(csr_rd_mem2wb_ff),
	    .rd_addr(instr_mem2wb_ff[31:20]),
	    .rd_data(rd_csr_data),

		.o_pc_mtvec       (w_pc_mtvec 	   ) ,
		.o_pc_mepc		  (w_pc_mepc       ) ,
		.instr_if_stage	  (instr_if_stage  ),
		.instr_if2id_ff   (instr_if2id_ff  ),
		.instr_id2ex_ff	  (instr_id2ex_ff  ) ,
		.instr_ex2mem_ff  (instr_ex2mem_ff ) ,
		.instr_mem2wb_ff  (instr_mem2wb_ff ) ,
		.pc_if2id_ff	  (pc_if2id_ff     ),
		.pc_id2ex_ff  	  (pc_id2ex_ff     ),
		.pc_ex2mem_ff     (pc_ex2mem_ff    ),
		.pc_mem2wb_ff	  (pc_mem2wb_ff    ) ,
		.pc_if_stage	  (pc			   ) ,
    	.i_excep_csr_upd  (w_excep_csr_upd ) ,
    	.i_mret_csr_upd   (w_mret_csr_upd  ) ,
    	.o_mie            (w_mie           ) ,
    	.o_mstatus        (w_mstatus       ) 
	);

	riscv_excep_detect_unit#(
		.ADDR_WIDTH (12),
		.I_BUS_WIDTH(32),
		.D_BUS_WIDTH(64)
	) U_RISCV_EXCEP_DETECT_UNIT (
		.i_instr_mem2wb_ff (instr_mem2wb_ff ) ,
		//.i_instr_if_stage  (pc				),
		.i_clint_timer_irq (i_clint_timer_irq),
		.i_mie             (w_mie    		) ,
		.i_mstatus         (w_mstatus		) ,
		.o_excep_stall     (w_excep_flush	) ,  // 
		.o_irq_stall       (w_irq_flush		) ,  // 计时器中断引起的stall
		.o_excep_csr_upd   (w_excep_csr_upd ) ,  // output to csr to uopdate  the CSRs by ecall instruction and so on
		.o_mret_csr_upd    (w_mret_csr_upd  ) ,  // output to csr to uopdate  the CSRs by mret instruction
		.o_core_ready	   (o_timer_irq_ready)

	);
       
	assign reg_write_wb_stage = (w_irq_flush) ? 0:reg_write_mem2wb_ff ;

	always@(*)begin
		case(instr_mem2wb_ff[14:12])
			3'b001:	wr_csr_data	= U_RISCV_RF.rf[instr_mem2wb_ff[19:15]];
			3'b010:	wr_csr_data	= U_RISCV_RF.rf[instr_mem2wb_ff[19:15]] | U_CSR.csr_rg[instr_mem2wb_ff[31:20]];
			3'b011:	wr_csr_data	= ~U_RISCV_RF.rf[instr_mem2wb_ff[19:15]] & U_CSR.csr_rg[instr_mem2wb_ff[31:20]];
			3'b101:	wr_csr_data = {59'd0,instr_mem2wb_ff[19:15]};
			3'b110:	wr_csr_data = {59'd0,instr_mem2wb_ff[19:15]} | U_CSR.csr_rg[instr_mem2wb_ff[31:20]];
			3'b111:	wr_csr_data = ~{59'd0,instr_mem2wb_ff[19:15]} & U_CSR.csr_rg[instr_mem2wb_ff[31:20]];
			default:wr_csr_data = 64'd0;
		endcase
	end

	//test putch implementation

	integer	handle1;
	initial begin
		handle1=$fopen("/home/wyf/RISCV-CPU/test.txt","w");
	end
	always@(posedge clk)begin
		if(instr_mem2wb_ff == 64'h7b)begin
			//$fdisplay(handle1,"%c",o_rf_10);
			$write("%c",o_rf_10);
		end
	end


endmodule