`include "top_defines.v"
`define AXI_TOP_INTERFACE(name) io_memAXI_0_``name

module SimTop(
    input         clock,
    input         reset,

    input  [63:0] io_logCtrl_log_begin,
    input  [63:0] io_logCtrl_log_end,
    input  [63:0] io_logCtrl_log_level,
    input         io_perfInfo_clean,
    input         io_perfInfo_dump,

    output        io_uart_out_valid,
    output [7:0]  io_uart_out_ch,
    output        io_uart_in_valid,
    input  [7:0]  io_uart_in_ch ,

    input                               `AXI_TOP_INTERFACE(aw_ready),
    output                              `AXI_TOP_INTERFACE(aw_valid),
    output [`AXI_ADDR_WIDTH-1:0]        `AXI_TOP_INTERFACE(aw_bits_addr),
    output [2:0]                        `AXI_TOP_INTERFACE(aw_bits_prot),
    output [`AXI_ID_WIDTH-1:0]          `AXI_TOP_INTERFACE(aw_bits_id),
    output [`AXI_USER_WIDTH-1:0]        `AXI_TOP_INTERFACE(aw_bits_user),
    output [7:0]                        `AXI_TOP_INTERFACE(aw_bits_len),
    output [2:0]                        `AXI_TOP_INTERFACE(aw_bits_size),
    output [1:0]                        `AXI_TOP_INTERFACE(aw_bits_burst),
    output                              `AXI_TOP_INTERFACE(aw_bits_lock),
    output [3:0]                        `AXI_TOP_INTERFACE(aw_bits_cache),
    output [3:0]                        `AXI_TOP_INTERFACE(aw_bits_qos),
    
    input                               `AXI_TOP_INTERFACE(w_ready    ),
    output                              `AXI_TOP_INTERFACE(w_valid    ),
    output [`AXI_DATA_WIDTH-1:0]        `AXI_TOP_INTERFACE(w_bits_data) [3:0],
    output [`AXI_DATA_WIDTH/8-1:0]      `AXI_TOP_INTERFACE(w_bits_strb),
    output                              `AXI_TOP_INTERFACE(w_bits_last),
    
    output                              `AXI_TOP_INTERFACE(b_ready),
    input                               `AXI_TOP_INTERFACE(b_valid),
    input  [1:0]                        `AXI_TOP_INTERFACE(b_bits_resp),
    input  [`AXI_ID_WIDTH-1:0]          `AXI_TOP_INTERFACE(b_bits_id),
    input  [`AXI_USER_WIDTH-1:0]        `AXI_TOP_INTERFACE(b_bits_user),

    input                               `AXI_TOP_INTERFACE(ar_ready),
    output                              `AXI_TOP_INTERFACE(ar_valid),
    output [`AXI_ADDR_WIDTH-1:0]        `AXI_TOP_INTERFACE(ar_bits_addr),
    output [2:0]                        `AXI_TOP_INTERFACE(ar_bits_prot),
    output [`AXI_ID_WIDTH-1:0]          `AXI_TOP_INTERFACE(ar_bits_id),
    output [`AXI_USER_WIDTH-1:0]        `AXI_TOP_INTERFACE(ar_bits_user),
    output [7:0]                        `AXI_TOP_INTERFACE(ar_bits_len),
    output [2:0]                        `AXI_TOP_INTERFACE(ar_bits_size),
    output [1:0]                        `AXI_TOP_INTERFACE(ar_bits_burst),
    output                              `AXI_TOP_INTERFACE(ar_bits_lock),
    output [3:0]                        `AXI_TOP_INTERFACE(ar_bits_cache),
    output [3:0]                        `AXI_TOP_INTERFACE(ar_bits_qos),
    
    output                              `AXI_TOP_INTERFACE(r_ready),
    input                               `AXI_TOP_INTERFACE(r_valid),
    input  [1:0]                        `AXI_TOP_INTERFACE(r_bits_resp),
    input  [`AXI_DATA_WIDTH-1:0]        `AXI_TOP_INTERFACE(r_bits_data)         [3:0],
    input                               `AXI_TOP_INTERFACE(r_bits_last),
    input  [`AXI_ID_WIDTH-1:0]          `AXI_TOP_INTERFACE(r_bits_id),
    input  [`AXI_USER_WIDTH-1:0]        `AXI_TOP_INTERFACE(r_bits_user)
  // ......
);


// AXI parameter
localparam   DATA_WIDTH  = 64  ;             	// 数据位宽
localparam   ADDR_WIDTH  = 64  ;               // 地址位宽              
localparam   ID_WIDTH    = 4   ;               	// ID位宽
localparam   USER_WIDTH  = 1024;             // USER位宽
localparam	  STRB_WIDTH  = 8   ;

// cpu port
wire [31:0]	inst            ;
wire        inst_valid      ;
wire [63:0]	inst_addr       ;
wire		    inst_ena        ;
wire        inst_addr_valid ;

wire		    data_wr_en      ;
wire		    data_rd_en      ;
wire [7:0]	data_wmask      ;
wire [63:0]	data_addr       ;
wire [63:0]	data_wr         ;
wire [63:0]	data_rd         ;
wire        data_rd_valid   ;
wire        data_wr_ready   ;


wire		    w_dmem_data_wr_en ;
wire		    w_dmem_data_rd_en ;
wire [7:0]	w_dmem_data_wmask ;
wire [63:0]	w_dmem_data_addr  ;
wire [63:0]	w_dmem_data_wr    ;
wire [63:0]	w_dmem_data_rd    ;
wire		    w_dmem_data_rd_valid ;
wire		    w_dmem_data_wr_ready ;

wire		    w_clint_data_wr_en    ;
wire		    w_clint_data_rd_en    ;
wire [63:0]	w_clint_data_addr     ;
wire [63:0]	w_clint_data_wr       ;
wire [63:0]	w_clint_data_rd       ;
wire		    w_clint_rd_data_valid ;
wire		    w_clint_wr_ready      ;

// mem_ctrl port
wire		    data_wr_en_ram    ;
wire		    data_rd_en_ram    ;
wire [63:0]	data_wmask_ram    ;
wire [63:0]	data_addr_ram     ;
wire [63:0]	data_wr_ram       ;
wire [63:0]	data_rd_ram       ;

wire   [64-1 : 0]  o_rf_0 		;
wire   [64-1 : 0]  o_rf_1 		;
wire   [64-1 : 0]  o_rf_2 		;
wire   [64-1 : 0]  o_rf_3 		;
wire   [64-1 : 0]  o_rf_4 		;
wire   [64-1 : 0]  o_rf_5 		;
wire   [64-1 : 0]  o_rf_6 		;
wire   [64-1 : 0]  o_rf_7 		;
wire   [64-1 : 0]  o_rf_8 		;
wire   [64-1 : 0]  o_rf_9 		;
wire   [64-1 : 0]  o_rf_10		;
wire   [64-1 : 0]  o_rf_11		;
wire   [64-1 : 0]  o_rf_12		;
wire   [64-1 : 0]  o_rf_13		;
wire   [64-1 : 0]  o_rf_14		;
wire   [64-1 : 0]  o_rf_15		;
wire   [64-1 : 0]  o_rf_16		;
wire   [64-1 : 0]  o_rf_17		;
wire   [64-1 : 0]  o_rf_18		;
wire   [64-1 : 0]  o_rf_19		;
wire   [64-1 : 0]  o_rf_20		;
wire   [64-1 : 0]  o_rf_21		;
wire   [64-1 : 0]  o_rf_22		;
wire   [64-1 : 0]  o_rf_23		;
wire   [64-1 : 0]  o_rf_24		;
wire   [64-1 : 0]  o_rf_25		;
wire   [64-1 : 0]  o_rf_26		;
wire   [64-1 : 0]  o_rf_27		;
wire   [64-1 : 0]  o_rf_28		;
wire   [64-1 : 0]  o_rf_29		;
wire   [64-1 : 0]  o_rf_30		;
wire   [64-1 : 0]  o_rf_31		;

// timer IRQ PORT
wire   w_clint_timer_irq ;
wire   w_timer_irq_ready ;  // only for timer interrupt

// TOP AXI interface 
wire [`AXI_ADDR_WIDTH-1:0]  ar_addr   ;
wire                        ar_valid  ;
wire                        ar_ready  ;
wire [7:0]                  ar_len    ;
wire [`AXI_ID_WIDTH-1:0]    ar_id     ;
wire [2:0]                  ar_size   ;
wire [1:0]                  ar_burst  ;
wire                        ar_lock   ;
wire [3:0]                  ar_cache  ;
wire [2:0]                  ar_prot   ;
wire [3:0]                  ar_qos    ;
wire [3:0]                  ar_region ;
wire [`AXI_USER_WIDTH-1:0]  ar_user   ;

wire [`AXI_DATA_WIDTH-1:0]  r_data    ;   
wire                        r_last    ; 
wire                        r_valid   ;
wire                        r_ready   ;
wire [`AXI_ID_WIDTH-1:0]    r_id      ;
wire [1:0]                  r_resp    ;
wire [`AXI_USER_WIDTH-1:0]  r_user    ;

wire [`AXI_ADDR_WIDTH-1:0]  aw_addr   ;
wire                        aw_valid  ;
wire                        aw_ready  ;
wire [7:0]                  aw_len    ;
wire [`AXI_ID_WIDTH-1:0]    aw_id     ;
wire [2:0]                  aw_size   ;
wire [1:0]                  aw_burst  ;
wire                        aw_lock   ; 
wire [3:0]                  aw_cache  ;   
wire [2:0]                  aw_prot   ;
wire [3:0]                  aw_qos    ;
wire [3:0]                  aw_region ;
wire [`AXI_USER_WIDTH-1:0]  aw_user   ;

wire [`AXI_DATA_WIDTH-1:0]  w_data    ;
wire                        w_last    ;
wire                        w_valid   ;
wire                        w_ready   ;
wire [`AXI_DATA_WIDTH/8-1:0]w_strb    ;
wire [`AXI_USER_WIDTH-1:0]  w_user    ;

wire [`AXI_ID_WIDTH-1:0]    b_id      ;  
wire [1:0]                  b_resp    ;
wire                        b_valid   ;
wire                        b_ready   ;
wire [`AXI_USER_WIDTH-1:0]  b_user    ;

// Instruction fetch AXI interface 
wire [`AXI_ADDR_WIDTH-1:0]  if_axi_ar_addr   ;
wire                        if_axi_ar_valid  ;
wire                        if_axi_ar_ready  ;
wire [7:0]                  if_axi_ar_len    ;
wire [`AXI_ID_WIDTH-1:0]    if_axi_ar_id     ;
wire [2:0]                  if_axi_ar_size   ;
wire [1:0]                  if_axi_ar_burst  ;
wire                        if_axi_ar_lock   ;
wire [3:0]                  if_axi_ar_cache  ;
wire [2:0]                  if_axi_ar_prot   ;
wire [3:0]                  if_axi_ar_qos    ;
wire [3:0]                  if_axi_ar_region ;
wire [`AXI_USER_WIDTH-1:0]  if_axi_ar_user   ;

wire [`AXI_DATA_WIDTH-1:0]  if_axi_r_data    ;   
wire                        if_axi_r_last    ; 
wire                        if_axi_r_valid   ;
wire                        if_axi_r_ready   ;
wire [`AXI_ID_WIDTH-1:0]    if_axi_r_id      ;
wire [1:0]                  if_axi_r_resp    ;
wire [`AXI_USER_WIDTH-1:0]  if_axi_r_user    ;

// Mem AXI interface 
wire [`AXI_ADDR_WIDTH-1:0]  mem_axi_ar_addr   ;
wire                        mem_axi_ar_valid  ;
wire                        mem_axi_ar_ready  ;
wire [7:0]                  mem_axi_ar_len    ;
wire [`AXI_ID_WIDTH-1:0]    mem_axi_ar_id     ;
wire [2:0]                  mem_axi_ar_size   ;
wire [1:0]                  mem_axi_ar_burst  ;
wire                        mem_axi_ar_lock   ;
wire [3:0]                  mem_axi_ar_cache  ;
wire [2:0]                  mem_axi_ar_prot   ;
wire [3:0]                  mem_axi_ar_qos    ;
wire [3:0]                  mem_axi_ar_region ;
wire [`AXI_USER_WIDTH-1:0]  mem_axi_ar_user   ;

wire [`AXI_DATA_WIDTH-1:0]  mem_axi_r_data    ;   
wire                        mem_axi_r_last    ; 
wire                        mem_axi_r_valid   ;
wire                        mem_axi_r_ready   ;
wire [`AXI_ID_WIDTH-1:0]    mem_axi_r_id      ;
wire [1:0]                  mem_axi_r_resp    ;
wire [`AXI_USER_WIDTH-1:0]  mem_axi_r_user    ;

wire [`AXI_ADDR_WIDTH-1:0]  mem_axi_aw_addr   ;
wire                        mem_axi_aw_valid  ;
wire                        mem_axi_aw_ready  ;
wire [7:0]                  mem_axi_aw_len    ;
wire [`AXI_ID_WIDTH-1:0]    mem_axi_aw_id     ;
wire [2:0]                  mem_axi_aw_size   ;
wire [1:0]                  mem_axi_aw_burst  ;
wire                        mem_axi_aw_lock   ; 
wire [3:0]                  mem_axi_aw_cache  ;   
wire [2:0]                  mem_axi_aw_prot   ;
wire [3:0]                  mem_axi_aw_qos    ;
wire [3:0]                  mem_axi_aw_region ;
wire [`AXI_USER_WIDTH-1:0]  mem_axi_aw_user   ;

wire [`AXI_DATA_WIDTH-1:0]  mem_axi_w_data    ;
wire                        mem_axi_w_last    ;
wire                        mem_axi_w_valid   ;
wire                        mem_axi_w_ready   ;
wire [`AXI_DATA_WIDTH/8-1:0]mem_axi_w_strb    ;
wire [`AXI_USER_WIDTH-1:0]  mem_axi_w_user    ;

wire [`AXI_ID_WIDTH-1:0]    mem_axi_b_id      ;  
wire [1:0]                  mem_axi_b_resp    ;
wire                        mem_axi_b_valid   ;
wire                        mem_axi_b_ready   ;
wire [`AXI_USER_WIDTH-1:0]  mem_axi_b_user    ;

// axi_interconnect to top (assign)
assign ar_ready                                 = `AXI_TOP_INTERFACE(ar_ready);
assign `AXI_TOP_INTERFACE(ar_valid)             = ar_valid;
assign `AXI_TOP_INTERFACE(ar_bits_addr)         = ar_addr;
assign `AXI_TOP_INTERFACE(ar_bits_prot)         = ar_prot;
assign `AXI_TOP_INTERFACE(ar_bits_id)           = ar_id;
assign `AXI_TOP_INTERFACE(ar_bits_user)         = ar_user;
assign `AXI_TOP_INTERFACE(ar_bits_len)          = ar_len;
assign `AXI_TOP_INTERFACE(ar_bits_size)         = ar_size;
assign `AXI_TOP_INTERFACE(ar_bits_burst)        = ar_burst;
assign `AXI_TOP_INTERFACE(ar_bits_lock)         = ar_lock;
assign `AXI_TOP_INTERFACE(ar_bits_cache)        = ar_cache;
assign `AXI_TOP_INTERFACE(ar_bits_qos)          = ar_qos;
    
assign `AXI_TOP_INTERFACE(r_ready)              = r_ready;
assign r_valid                                  = `AXI_TOP_INTERFACE(r_valid);
assign r_resp                                   = `AXI_TOP_INTERFACE(r_bits_resp);
assign r_data                                   = `AXI_TOP_INTERFACE(r_bits_data)[0];
assign r_last                                   = `AXI_TOP_INTERFACE(r_bits_last);
assign r_id                                     = `AXI_TOP_INTERFACE(r_bits_id);
assign r_user                                   = `AXI_TOP_INTERFACE(r_bits_user);

assign aw_ready                                 = `AXI_TOP_INTERFACE(aw_ready)   ;
assign `AXI_TOP_INTERFACE(aw_bits_addr  )       =   aw_addr   ;
assign `AXI_TOP_INTERFACE(aw_valid      )       =   aw_valid  ;

assign `AXI_TOP_INTERFACE(aw_bits_len   )       =   aw_len    ;
assign `AXI_TOP_INTERFACE(aw_bits_id    )       =   aw_id     ;
assign `AXI_TOP_INTERFACE(aw_bits_size  )       =   aw_size   ;
assign `AXI_TOP_INTERFACE(aw_bits_burst )       =   aw_burst  ;
assign `AXI_TOP_INTERFACE(aw_bits_lock  )       =   aw_lock   ;
assign `AXI_TOP_INTERFACE(aw_bits_cache )       =   aw_cache  ;
assign `AXI_TOP_INTERFACE(aw_bits_prot  )       =   aw_prot   ;
assign `AXI_TOP_INTERFACE(aw_bits_qos   )       =   aw_qos    ;
                                                      //aw_region 
assign `AXI_TOP_INTERFACE(aw_bits_user  )       =   aw_user   ;

assign w_ready                                  = `AXI_TOP_INTERFACE(w_ready )   ;
assign `AXI_TOP_INTERFACE(w_bits_data    )[0]   = w_data      ;
assign `AXI_TOP_INTERFACE(w_bits_last    )      = w_last      ;
assign `AXI_TOP_INTERFACE(w_valid        )      = w_valid     ;
assign `AXI_TOP_INTERFACE(w_bits_strb    )      = w_strb      ;

assign `AXI_TOP_INTERFACE(b_ready)  = b_ready      ;
assign b_valid                      = `AXI_TOP_INTERFACE(b_valid    ) ;
assign b_resp                       = `AXI_TOP_INTERFACE(b_bits_resp) ;
assign b_id                         = `AXI_TOP_INTERFACE(b_bits_id  ) ;
assign b_user                       = `AXI_TOP_INTERFACE(b_bits_user) ;

riscv #(
	  .IBUS_DATA_WIDTH(32),               // instruction bus data width
    .DBUS_DATA_WIDTH(64),               // data bus data width
    .RF_ADDR_WIDTH  ($clog2(32)),       // register file address width
    .IMEM_ADDR_WIDTH(64),     // instruction memory address width
    .DMEM_ADDR_WIDTH(64)     // data memory address width
) U_RISCV(
	.clk		(clock),
	//.rst_n		(1'b1),      // asynchronous reset
	.sft_rst	(reset),     // synchronous reset
	
    // INST and DATA port
	.i_inst   		    (inst           ),
  .i_inst_valid     (inst_valid     ),
	.o_inst_addr      (inst_addr      ),
	.o_inst_ena    	  (inst_ena       ),
  .o_inst_addr_valid(inst_addr_valid),

	.o_data_wr_en  	(data_wr_en),
	.o_data_rd_en  	(data_rd_en),
  .o_data_wmask 	(data_wmask),
	.o_data_addr  	(data_addr ),
	.o_data_wr    	(data_wr   ),
	.i_data_rd      (data_rd   ),
  .i_data_rd_valid(data_rd_valid),
  .i_data_wr_ready(data_wr_ready),

	.o_rf_0 		(o_rf_0),  
	.o_rf_1 		(o_rf_1),  
	.o_rf_2 		(o_rf_2),  
	.o_rf_3 		(o_rf_3),
	.o_rf_4 		(o_rf_4),  
	.o_rf_5 		(o_rf_5),  
	.o_rf_6 		(o_rf_6),  
	.o_rf_7 		(o_rf_7),
	.o_rf_8 		(o_rf_8),  
	.o_rf_9 		(o_rf_9),  
	.o_rf_10		(o_rf_10),  
	.o_rf_11		(o_rf_11),
	.o_rf_12		(o_rf_12),  
	.o_rf_13		(o_rf_13),  
	.o_rf_14		(o_rf_14),  
	.o_rf_15		(o_rf_15),
	.o_rf_16		(o_rf_16),  
	.o_rf_17		(o_rf_17),  
	.o_rf_18		(o_rf_18),  
	.o_rf_19		(o_rf_19),
	.o_rf_20		(o_rf_20),  
	.o_rf_21		(o_rf_21),  
	.o_rf_22		(o_rf_22),  
	.o_rf_23		(o_rf_23),
	.o_rf_24		(o_rf_24),  
	.o_rf_25		(o_rf_25),  
	.o_rf_26		(o_rf_26),  
	.o_rf_27		(o_rf_27),
	.o_rf_28		(o_rf_28),  
	.o_rf_29		(o_rf_29),  
	.o_rf_30		(o_rf_30),  
	.o_rf_31		(o_rf_31),
  
  .i_clint_timer_irq(w_clint_timer_irq),
  .o_timer_irq_ready(w_timer_irq_ready)    // only for timer interrupt
	
);

if_axi_rw #(
    .DATA_WIDTH(64  ) ,  //数据位宽
    .ADDR_WIDTH(64  ) ,  //地址位宽              
    .ID_WIDTH  (4   ) ,  //ID位宽
    .USER_WIDTH(1024)    //USER位宽
) U_IF_AXI_RW (
	.clk					    (clock) , // input           	
	.rst					    (reset) , // input	   	 

	.inst				      (inst           ) , // output	 [31:0]				  
	.inst_addr			  (inst_addr      ) , // input	   [63:0]		
	.inst_valid		  	(inst_valid     ) , // output
	.inst_addr_valid	(inst_addr_valid) , // input	   	   				
	
	.M00_AXI_ARADDR               (if_axi_ar_addr   ),  // output reg [ADDR_WIDTH-1:0]      
	.M00_AXI_ARVALID              (if_axi_ar_valid  ),  // output reg                       
	.M00_AXI_ARREADY              (if_axi_ar_ready  ),  // input                            
	.M00_AXI_ARLEN                (if_axi_ar_len    ),  // output     [7:0]               
	.M00_AXI_ARID                 (if_axi_ar_id     ),  // output     [ID_WIDTH-1:0]        
	.M00_AXI_ARSIZE               (if_axi_ar_size   ),  // output     [2:0]                 
	.M00_AXI_ARBURST              (if_axi_ar_burst  ),  // output     [1:0]                 
	.M00_AXI_ARLOCK               (if_axi_ar_lock   ),  // output                           
	.M00_AXI_ARCACHE              (if_axi_ar_cache  ),  // output     [3:0]                 
	.M00_AXI_ARPROT               (if_axi_ar_prot   ),  // output     [2:0]                 
	.M00_AXI_ARQOS                (if_axi_ar_qos    ),  // output     [3:0]               
	.M00_AXI_ARREGION             (if_axi_ar_region ),  // output     [3:0]              
  .M00_AXI_ARUSER			          (if_axi_ar_user   ),  // output     [USER_WIDTH-1:0]   
		      
	.M00_AXI_RDATA                (if_axi_r_data    ),  // input      [DATA_WIDTH-1:0]      
	.M00_AXI_RLAST                (if_axi_r_last    ),  // input                            
	.M00_AXI_RVALID               (if_axi_r_valid   ),  // input                            
	.M00_AXI_RREADY               (if_axi_r_ready   ),  // output                         
	.M00_AXI_RID                  (if_axi_r_id      ),  // input      [ID_WIDTH-1:0]        
	.M00_AXI_RRESP                (if_axi_r_resp    ),  // input      [1:0]               
	.M00_AXI_RUSER				        (if_axi_r_user    )   // input      [USER_WIDTH-1:0]	  
);


riscv_router #(
  .DBUS_DATA_WIDTH (64),
  .DMEM_ADDR_WIDTH (64)
) U_RISCV_ROUTER(

  .i_core_data_wr_en    (data_wr_en   ),
  .i_core_data_rd_en    (data_rd_en   ),
  .i_core_data_mask     (data_wmask   ),
  .i_core_addr          (data_addr    ),
  .i_core_wdata         (data_wr      ),
  .o_core_rdata         (data_rd      ),
  .o_core_rdata_valid   (data_rd_valid),  
  .o_core_data_wr_ready (data_wr_ready),

  .o_port0_wr_en        (w_dmem_data_wr_en    ), // to  mem_ctrl 
  .o_port0_rd_en        (w_dmem_data_rd_en    ), // to  mem_ctrl
  .o_port0_data_mask    (w_dmem_data_wmask    ), // to mem_axi_rw 
  .o_port0_addr         (w_dmem_data_addr     ), // to or mem_ctrl
  .o_port0_wdata        (w_dmem_data_wr       ), // to  mem_ctrl
  .i_port0_rdata        (w_dmem_data_rd       ), // to  mem_ctrl
  .i_port0_rdata_valid  (w_dmem_data_rd_valid ), // to mem_axi_rw   
  .i_port0_wr_ready	    (w_dmem_data_wr_ready ), // to mem_axi_rw   

  .o_port1_wr_en        (w_clint_data_wr_en   ),
  .o_port1_rd_en        (w_clint_data_rd_en   ),
  .o_port1_addr         (w_clint_data_addr    ),
  .o_port1_wdata        (w_clint_data_wr      ),
  .i_port1_rdata        (w_clint_data_rd      ),
  .i_port1_rdata_valid  (w_clint_rd_data_valid),
  .i_port1_wr_ready     (w_clint_wr_ready     )

);


riscv_clint #(
  .ADDR_WIDTH  (64),
  .D_BUS_WIDTH (64)
)U_RISCV_CLINT(
  .clk                  (clock                  ),
  .rst                  (reset                  ),
  .wr_en                (w_clint_data_wr_en     ),
  .rd_en                (w_clint_data_rd_en     ),
  .rw_addr              (w_clint_data_addr      ),
  .wr_data              (w_clint_data_wr        ),
  .rd_data              (w_clint_data_rd        ),
  .o_clint_rd_data_valid(w_clint_rd_data_valid  ),
  .o_clint_wr_ready     (w_clint_wr_ready       ),
  .i_core_ready         (w_timer_irq_ready      ),
  .o_clint_timer_irq    (w_clint_timer_irq      )  

);
     
mem_ctrl U_mem_ctrl(
  .rst(reset),
  // CPU端接口
  .mem_byte_enble (w_dmem_data_wmask ),
  .mem_addr       (w_dmem_data_addr  ),
  .mem_rd_en      (w_dmem_data_rd_en ),
  .mem_wr_en      (w_dmem_data_wr_en ),
  .mem_wr_data    (w_dmem_data_wr    ),
  .mem_rd_data    (w_dmem_data_rd    ),
  // 内存接口
  .ram_addr   (data_addr_ram  ) ,
  .ram_wr_en  (data_wr_en_ram ) ,
  .ram_wmask  (data_wmask_ram ) , // 暂时无用
  .ram_wr_data(data_wr_ram    ) ,
  .ram_rd_en  (data_rd_en_ram ) ,
  .ram_rd_data(data_rd_ram    )   
);  

mem_axi_rw #(
  .DATA_WIDTH(64  ),             	//数据位宽
  .ADDR_WIDTH(64  ),               //地址位宽              
  .ID_WIDTH  (4   ),               	//ID位宽
  .USER_WIDTH(1024),             //USER位宽
	.STRB_WIDTH(8   )
) U_MEM_AXI_RW(
	.clk			                    (clock),
	.rst			                    (reset),

	.data_addr  				          (data_addr_ram        ), //input  [63:0] 	  		    
	.data_rd_addr_valid           (data_rd_en_ram       ), //input 					          
	.data_rd     				          (data_rd_ram          ), //output [DATA_WIDTH-1:0]   
	.data_rd_valid				        (w_dmem_data_rd_valid ), //output					          
	.data_wr_valid  		          (data_wr_en_ram       ), //input 					          
  .data_wmask 				          ({data_wmask_ram[56],data_wmask_ram[48],data_wmask_ram[40],data_wmask_ram[32],data_wmask_ram[24],data_wmask_ram[16],data_wmask_ram[8],data_wmask_ram[0]}    ), //input  [7:0] 		  	      
	.data_wr    				          (data_wr_ram          ), //input  [DATA_WIDTH-1:0]   
	.data_wr_ready				        (w_dmem_data_wr_ready ), //output	reg				        
	
  .M01_AXI_ARADDR               (mem_axi_ar_addr   ),	//output [ADDR_WIDTH-1:0]      
  .M01_AXI_ARVALID              (mem_axi_ar_valid  ),	//output                       
  .M01_AXI_ARREADY              (mem_axi_ar_ready  ),	//input                        
  .M01_AXI_ARLEN                (mem_axi_ar_len    ),	//output [7:0]               
  .M01_AXI_ARID                 (mem_axi_ar_id     ),	//output [ID_WIDTH-1:0]        
  .M01_AXI_ARSIZE               (mem_axi_ar_size   ),	//output [2:0]                 
  .M01_AXI_ARBURST              (mem_axi_ar_burst  ),	//output [1:0]                 
  .M01_AXI_ARLOCK               (mem_axi_ar_lock   ),	//output                       
  .M01_AXI_ARCACHE              (mem_axi_ar_cache  ),	//output [3:0]                 
  .M01_AXI_ARPROT               (mem_axi_ar_prot   ),	//output [2:0]                 
  .M01_AXI_ARQOS                (mem_axi_ar_qos    ),	//output [3:0]               
  .M01_AXI_ARREGION             (mem_axi_ar_region ),	//output [3:0]              
  .M01_AXI_ARUSER			          (mem_axi_ar_user   ), //output [USER_WIDTH-1:0]   
	
	.M01_AXI_RDATA                (mem_axi_r_data    ), //input [DATA_WIDTH-1:0]       
	.M01_AXI_RLAST                (mem_axi_r_last    ), //input                        
	.M01_AXI_RVALID               (mem_axi_r_valid   ), //input                        
	.M01_AXI_RREADY               (mem_axi_r_ready   ), //output                     
	.M01_AXI_RID                  (mem_axi_r_id      ), //input [ID_WIDTH-1:0]         
	.M01_AXI_RRESP                (mem_axi_r_resp    ), //input [1:0]                
	.M01_AXI_RUSER				        (mem_axi_r_user    ), //input [USER_WIDTH-1:0]	  

	.M01_AXI_AWADDR               (mem_axi_aw_addr   ), //output [ADDR_WIDTH-1:0]    
	.M01_AXI_AWVALID              (mem_axi_aw_valid  ), //output                     
	.M01_AXI_AWREADY              (mem_axi_aw_ready  ), //input                      
	.M01_AXI_AWLEN                (mem_axi_aw_len    ), //output [7:0]               
	.M01_AXI_AWID                 (mem_axi_aw_id     ), //output [ID_WIDTH-1:0]      
	.M01_AXI_AWSIZE               (mem_axi_aw_size   ), //output [2:0]               
	.M01_AXI_AWBURST              (mem_axi_aw_burst  ), //output [1:0]               
	.M01_AXI_AWLOCK               (mem_axi_aw_lock   ), //output                     
	.M01_AXI_AWCACHE              (mem_axi_aw_cache  ), //output [3:0]               
	.M01_AXI_AWPROT               (mem_axi_aw_prot   ), //output [2:0]               
	.M01_AXI_AWQOS                (mem_axi_aw_qos    ), //output [3:0]              	
	.M01_AXI_AWREGION			        (mem_axi_aw_region ), //output [3:0]              
  .M01_AXI_AWUSER				        (mem_axi_aw_user   ), //output [USER_WIDTH-1:0]   
	
	.M01_AXI_WDATA                (mem_axi_w_data    ), //output [DATA_WIDTH-1:0] 
	.M01_AXI_WLAST                (mem_axi_w_last    ), //output                  
	.M01_AXI_WVALID               (mem_axi_w_valid   ), //output                  
	.M01_AXI_WREADY               (mem_axi_w_ready   ), //input                   
	.M01_AXI_WSTRB                (mem_axi_w_strb    ), //output [STRB_WIDTH-1:0] 
  .M01_AXI_WUSER				        (mem_axi_w_user    ), //output [USER_WIDTH-1:0]	
	
	.M01_AXI_BID                  (mem_axi_b_id      ), //input [USER_WIDTH-1:0] 
	.M01_AXI_BRESP                (mem_axi_b_resp    ), //input [1:0]            
	.M01_AXI_BVALID               (mem_axi_b_valid   ), //input                  
	.M01_AXI_BREADY               (mem_axi_b_ready   ), //output                 
	.M01_AXI_BUSER			          (mem_axi_b_user    )  //input [USER_WIDTH-1:0]	  	
);

axi_interconnect #(
    .DATA_WIDTH  (64   ),   //数据位宽
    .ADDR_WIDTH  (64   ),   //地址位宽              
    .ID_WIDTH    (4    ),   //ID位宽
    .USER_WIDTH  (1024 ),   //USER位宽
    .STRB_WIDTH  (8   )			//STRB位宽
) U_AXI_INTERCONNECT (
	
	.i_clk                        (clock),   
	.i_rst_n                      (reset),

    /**********master0:if_axi port**********/

	.S00_AXI_ARADDR               (if_axi_ar_addr   ), // input 		[ADDR_WIDTH-1:0]      
	.S00_AXI_ARVALID              (if_axi_ar_valid  ), // input                    	      
	.S00_AXI_ARREADY              (if_axi_ar_ready  ), // output reg               	      
	.S00_AXI_ARLEN                (if_axi_ar_len    ), // input 		[7:0]               
	.S00_AXI_ARID                 (if_axi_ar_id     ), // input 		[3:0]                 
	.S00_AXI_ARSIZE               (if_axi_ar_size   ), // input 		[2:0]                 
	.S00_AXI_ARBURST              (if_axi_ar_burst  ), // input 		[1:0]                 
	.S00_AXI_ARLOCK               (if_axi_ar_lock   ), // input 		                      
	.S00_AXI_ARCACHE              (if_axi_ar_cache  ), // input 		[3:0]                 
	.S00_AXI_ARPROT               (if_axi_ar_prot   ), // input 		[2:0]                 
	.S00_AXI_ARQOS                (if_axi_ar_qos    ), // input 		[3:0]               
	.S00_AXI_ARREGION             (if_axi_ar_region ), // input 		[3:0]              
  .S00_AXI_ARUSER				        (if_axi_ar_user   ), // input 		[USER_WIDTH-1:0]   
	
	.S00_AXI_RDATA                (if_axi_r_data    ), // output reg	[DATA_WIDTH-1:0]     
	.S00_AXI_RLAST                (if_axi_r_last    ), // output reg                       
	.S00_AXI_RVALID               (if_axi_r_valid   ), // output reg                       
	.S00_AXI_RREADY               (if_axi_r_ready   ), // input                    	     
	.S00_AXI_RID                  (if_axi_r_id      ), // output reg  [3:0]                
	.S00_AXI_RRESP                (if_axi_r_resp    ), // output reg	[1:0]              
	.S00_AXI_RUSER				        (if_axi_r_user    ), // output reg	[USER_WIDTH-1:0]   

    /**********master1:mem axi port **********/	

	.S01_AXI_ARADDR               (mem_axi_ar_addr   ),  // input 		[ADDR_WIDTH-1:0]      
	.S01_AXI_ARVALID              (mem_axi_ar_valid  ),  // input 		                      
	.S01_AXI_ARREADY              (mem_axi_ar_ready  ),  // output reg		                  
	.S01_AXI_ARLEN                (mem_axi_ar_len    ),  // input 		[7:0]               
	.S01_AXI_ARID                 (mem_axi_ar_id     ),  // input 		[3:0]                 
	.S01_AXI_ARSIZE               (mem_axi_ar_size   ),  // input 		[2:0]                 
	.S01_AXI_ARBURST              (mem_axi_ar_burst  ),  // input 		[1:0]                 
	.S01_AXI_ARLOCK               (mem_axi_ar_lock   ),  // input 		                      
	.S01_AXI_ARCACHE              (mem_axi_ar_cache  ),  // input 		[3:0]                 
	.S01_AXI_ARPROT               (mem_axi_ar_prot   ),  // input 		[2:0]                 
	.S01_AXI_ARQOS                (mem_axi_ar_qos    ),  // input 		[3:0]               
	.S01_AXI_ARREGION             (mem_axi_ar_region ),  // input 		[3:0]              
  .S01_AXI_ARUSER				        (mem_axi_ar_user   ),  // input 		[USER_WIDTH-1:0]   
	
	.S01_AXI_RDATA                (mem_axi_r_data    ),  // output reg  [DATA_WIDTH-1:0]      
	.S01_AXI_RLAST                (mem_axi_r_last    ),  // output reg                        
	.S01_AXI_RVALID               (mem_axi_r_valid   ),  // output reg                        
	.S01_AXI_RREADY               (mem_axi_r_ready   ),  // input                           
	.S01_AXI_RID                  (mem_axi_r_id      ),  // output reg  [3:0]                 
	.S01_AXI_RRESP                (mem_axi_r_resp    ),  // output reg  [1:0]              
	.S01_AXI_RUSER				        (mem_axi_r_user    ),  // output reg  [USER_WIDTH-1:0]   	 	
	
	.S01_AXI_AWADDR               (mem_axi_aw_addr   ),  // input 		[ADDR_WIDTH-1:0]      
	.S01_AXI_AWVALID              (mem_axi_aw_valid  ),  // input 		                      
	.S01_AXI_AWREADY              (mem_axi_aw_ready  ),  // output reg	                    
	.S01_AXI_AWLEN                (mem_axi_aw_len    ),  // input 		[7:0]               
	.S01_AXI_AWID                 (mem_axi_aw_id     ),  // input 		[ID_WIDTH-1:0]        
	.S01_AXI_AWSIZE               (mem_axi_aw_size   ),  // input 		[2:0]                 
	.S01_AXI_AWBURST              (mem_axi_aw_burst  ),  // input 		[1:0]                 
	.S01_AXI_AWLOCK               (mem_axi_aw_lock   ),  // input 		                      
	.S01_AXI_AWCACHE              (mem_axi_aw_cache  ),  // input 		[3:0]                 
	.S01_AXI_AWPROT               (mem_axi_aw_prot   ),  // input 		[2:0]                 
	.S01_AXI_AWQOS                (mem_axi_aw_qos    ),  // input 		[3:0]              	
	.S01_AXI_AWREGION			        (mem_axi_aw_region ),  // input 		[3:0]              
  .S01_AXI_AWUSER				        (mem_axi_aw_user   ),  // input 		[USER_WIDTH-1:0]   
	
	.S01_AXI_WDATA                (mem_axi_w_data    ),  // input 		[DATA_WIDTH-1:0]      
	.S01_AXI_WLAST                (mem_axi_w_last    ),  // input 		                      
	.S01_AXI_WVALID               (mem_axi_w_valid   ),  // input 		                      
	.S01_AXI_WREADY               (mem_axi_w_ready   ),  // output reg		                
	.S01_AXI_WSTRB                (mem_axi_w_strb    ),  // input 		[STRB_WIDTH-1:0]    
  .S01_AXI_WUSER				        (mem_axi_w_user    ),  // input 		[USER_WIDTH-1:0]   	
			
	.S01_AXI_BID                  (mem_axi_b_id      ),  // output reg  [USER_WIDTH-1:0]      
	.S01_AXI_BRESP                (mem_axi_b_resp    ),  // output reg  [1:0]                 
	.S01_AXI_BVALID               (mem_axi_b_valid   ),  // output reg                        
	.S01_AXI_BREADY               (mem_axi_b_ready   ),  // input  		                      
	.S01_AXI_BUSER			         	(mem_axi_b_user    ),  // output reg  [USER_WIDTH-1:0]   
	

	/********** slave0 : axi top**********/
	
	.M00_AXI_ARADDR              (ar_addr   ), // output reg	[ADDR_WIDTH-1:0]      
	.M00_AXI_ARVALID             (ar_valid  ), // output reg	                      
	.M00_AXI_ARREADY             (ar_ready  ), // input   	                        
	.M00_AXI_ARLEN               (ar_len    ), // output reg	[7:0]               
	.M00_AXI_ARID                (ar_id     ), // output reg	[3:0]                 
	.M00_AXI_ARSIZE              (ar_size   ), // output reg	[2:0]                 
	.M00_AXI_ARBURST             (ar_burst  ), // output reg	[1:0]                 
	.M00_AXI_ARLOCK              (ar_lock   ), // output reg	                      
	.M00_AXI_ARCACHE             (ar_cache  ), // output reg	[3:0]                 
	.M00_AXI_ARPROT              (ar_prot   ), // output reg	[2:0]                 
	.M00_AXI_ARQOS               (ar_qos    ), // output reg	[3:0]               
	.M00_AXI_ARREGION            (ar_region ), // output reg	[3:0]              
  .M00_AXI_ARUSER			         (ar_user   ), // output reg	[USER_WIDTH-1:0]   
	
	.M00_AXI_RDATA               (r_data    ), // input       [DATA_WIDTH-1:0]      
	.M00_AXI_RLAST               (r_last    ), // input                     	      
	.M00_AXI_RVALID              (r_valid   ), // input                             
	.M00_AXI_RREADY              (r_ready   ), // output reg                      
	.M00_AXI_RID                 (r_id      ), // input		[3:0]                     
	.M00_AXI_RRESP               (r_resp    ), // input		[1:0]                  
	.M00_AXI_RUSER			         (r_user    ), // input 		[USER_WIDTH-1:0]     	 	
														  
	.M00_AXI_AWADDR              (aw_addr   ), // output reg  [ADDR_WIDTH-1:0]      
	.M00_AXI_AWVALID             (aw_valid  ), // output reg                        
	.M00_AXI_AWREADY             (aw_ready  ), // input                             
	.M00_AXI_AWLEN               (aw_len    ), // output reg  [7:0]               
	.M00_AXI_AWID                (aw_id     ), // output reg  [ID_WIDTH-1:0]        
	.M00_AXI_AWSIZE              (aw_size   ), // output reg  [2:0]                 
	.M00_AXI_AWBURST             (aw_burst  ), // output reg  [1:0]                 
	.M00_AXI_AWLOCK              (aw_lock   ), // output reg                        
	.M00_AXI_AWCACHE             (aw_cache  ), // output reg  [3:0]                 
	.M00_AXI_AWPROT              (aw_prot   ), // output reg  [2:0]                 
	.M00_AXI_AWQOS               (aw_qos    ), // output reg  [3:0]              	
	.M00_AXI_AWREGION			       (aw_region ), // output reg  [3:0]              
  .M00_AXI_AWUSER			         (aw_user   ), // output reg  [USER_WIDTH-1:0]   
														  
	.M00_AXI_WDATA               (w_data    ), // output reg  [DATA_WIDTH-1:0]      
	.M00_AXI_WLAST               (w_last    ), // output reg                        
	.M00_AXI_WVALID              (w_valid   ), // output reg                        
	.M00_AXI_WREADY              (w_ready   ), // input                           
	.M00_AXI_WSTRB               (w_strb    ), // output reg  [STRB_WIDTH-1:0]    
  .M00_AXI_WUSER			         (w_user    ), // output reg  [USER_WIDTH-1:0]   	
							                           
	.M00_AXI_BID                 (b_id      ), // input 		[USER_WIDTH-1:0]      
	.M00_AXI_BRESP               (b_resp    ), // input 		[1:0]                 
	.M00_AXI_BVALID              (b_valid   ), // input 		                      
	.M00_AXI_BREADY              (b_ready   ), // output reg	                  
	.M00_AXI_BUSER				       (b_user    )  // input 		[USER_WIDTH-1:0]   
);
// RAM_1W2R #(
// 	.IBUS_DATA_WIDTH(32),    // instruction bus data width
//     .DBUS_DATA_WIDTH(64),    // data bus data width
//     .IMEM_ADDR_WIDTH(64),    // instruction memory address width
//     .DMEM_ADDR_WIDTH(64)     // data memory address width
// ) U_RAM_1W2R(
//   .clk		(clock),
  
//   .inst_addr	(inst_addr),
//   .inst_ena	(inst_ena),
//   .inst		(inst),

//     // DATA PORT
// 	.ram_wr_en	(data_wr_en_ram),
// 	.ram_rd_en	(data_rd_en_ram),
// 	.ram_wmask	(data_wmask_ram),
// 	.ram_addr	(data_addr_ram),
// 	.ram_wr_data(data_wr_ram),
//   .ram_rd_data(data_rd_ram)
// );

reg r_wen;
reg [7:0]r_wdest;
reg [63:0]r_wdata,r_pc;
reg [31:0]r_inst;
reg valid;
reg [63:0] clk_cnt;
reg [63:0] instrCnt;
reg skip  = 0 ;

always @(posedge clock) begin
  if(reset)begin
    r_wen     <= 'd0;
    r_wdest   <= 'd0;
    r_wdata   <= 'd0;
    r_pc      <= 'd0;
    r_inst    <= 'd0;
    valid     <= 'd0;
    clk_cnt   <= 'd0;
    instrCnt  <= 'd0;
    skip      <= 'd0;
  end else begin
    r_wen     <= U_RISCV.reg_write_mem2wb_ff   ; // 这里面的u_riscvcpu 是cpu核的例化名
    r_wdest   <= {3'd0,U_RISCV.instr_mem2wb_ff[11:7]};
    r_wdata   <= U_RISCV.wr_data_wb_stage;
    r_pc      <= {U_RISCV.pc_mem2wb_ff[63:0]};
    r_inst    <= {U_RISCV.instr_mem2wb_ff};
    valid     <= (((U_RISCV.instr_mem2wb_ff != 32'd0)) | (U_RISCV.pc_mem2wb_ff[63:0] == 64'h8000_0000)) & (!U_RISCV.w_irq_flush);
    clk_cnt   <= clk_cnt + 1;
    instrCnt  <= instrCnt + (U_RISCV.instr_mem2wb_ff != 64'd0);
    skip      <= (U_RISCV.instr_mem2wb_ff == 32'h7b) |
     (U_RISCV.instr_mem2wb_ff[6:0] == 7'b111_0011 && ((U_RISCV.instr_mem2wb_ff[31:20] == 12'hb00) | (U_RISCV.instr_mem2wb_ff[31:20] == 12'hb02)))
     | (((U_RISCV.o_data_addr_mem2wb_ff == 64'h2004000) | (U_RISCV.o_data_addr_mem2wb_ff == 64'h200bff8)) && ((U_RISCV.instr_mem2wb_ff[6:0] == 7'b000_0011) | (U_RISCV.instr_mem2wb_ff[6:0] == 7'b010_0011)))
     ;// && U_RISCV.instr_mem2wb_ff[31:20] == 12'hb00);
  end
end

DifftestInstrCommit U_inst_commit(
  .clock    ( clock ),
  .coreid   ( 8'd0 ),//8bit
  .index    ( 8'd0 ),//8bit
  .valid    ( valid),
  .pc       ( r_pc ),//64bit
  .instr    ( r_inst ),//32bit
  .skip     ( skip),
  .isRVC    ( 1'b0 ),
  .scFailed ( 1'b0 ),
  .wen      ( r_wen    ),
  .wdest    ( r_wdest ),//8bit
  .wdata    ( r_wdata ) //64bit
);


DifftestArchIntRegState U_DifftestArchIntRegState(
  .clock(clock),
  .coreid(8'd0),
  .gpr_0(o_rf_0),
  .gpr_1(o_rf_1),
  .gpr_2(o_rf_2),
  .gpr_3(o_rf_3),
  .gpr_4(o_rf_4),
  .gpr_5(o_rf_5),
  .gpr_6(o_rf_6),
  .gpr_7(o_rf_7),
  .gpr_8(o_rf_8),
  .gpr_9(o_rf_9),
  .gpr_10(o_rf_10),
  .gpr_11(o_rf_11),
  .gpr_12(o_rf_12),
  .gpr_13(o_rf_13),
  .gpr_14(o_rf_14),
  .gpr_15(o_rf_15),
  .gpr_16(o_rf_16),
  .gpr_17(o_rf_17),
  .gpr_18(o_rf_18),
  .gpr_19(o_rf_19),
  .gpr_20(o_rf_20),
  .gpr_21(o_rf_21),
  .gpr_22(o_rf_22),
  .gpr_23(o_rf_23),
  .gpr_24(o_rf_24),
  .gpr_25(o_rf_25),
  .gpr_26(o_rf_26),
  .gpr_27(o_rf_27),
  .gpr_28(o_rf_28),
  .gpr_29(o_rf_29),
  .gpr_30(o_rf_30),
  .gpr_31(o_rf_31)
);

DifftestCSRState U_DifftestCSRState(
  .clock(clock),
  .coreid('d0),
  .mstatus(U_RISCV.U_CSR.w_mstatus),
  .mcause(U_RISCV.U_CSR.w_mcause),
  .mepc(U_RISCV.U_CSR.o_pc_mepc),
  .sstatus(U_RISCV.U_CSR.w_mstatus & 64'h80000003000DE122),
  .scause('d0),
  .sepc('d0),
  .satp('d0),
  .mip('d0),
  .mie(U_RISCV.U_CSR.o_mie),
  .mscratch(U_RISCV.U_CSR.w_mscratch),
  .sscratch('d0),
  .mideleg('d0),
  .medeleg('d0),
  .mtval('d0),
  .stval('d0),
  .mtvec(U_RISCV.U_CSR.o_pc_mtvec),
  .stvec('d0),
  //.priviledgeMode(U_RISCV.U_CSR.w_mstatus[12:11])
  .priviledgeMode('d3)
);

DifftestTrapEvent U_DifftestTrapEvent(
	.clock    (clock),
	.coreid   (8'd0),
	.valid    (r_inst == 32'h0000006b),
	.code     (0),
	.pc       (r_pc),
	.cycleCnt (clk_cnt),
	.instrCnt (instrCnt));

DifftestArchEvent U_DifftestArchEvent(
  .clock  (clock),
  .coreid (8'd0),
  .intrNO(r_intrNO),
  .cause('d0),
  .exceptionInst(U_RISCV.U_CSR.r_mepc_instr),
  .exceptionPC(U_RISCV.w_pc_mepc));

reg [31:0]  r_intrNO =32'd0;
always@(posedge clock)begin
  if(U_RISCV.w_irq_flush == 'd1) r_intrNO <= 32'h80000007;
  else r_intrNO <= 'b0;
end

endmodule
