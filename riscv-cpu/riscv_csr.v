`include"riscv_define.vh"
`include "top_defines.v"
module riscv_csr#(
    parameter ADDR_WIDTH  = 12,
    parameter I_BUS_WIDTH = 32,
    parameter D_BUS_WIDTH = 64
)(
    input                              clk              ,
    input                              rst              ,

    input                              wr_en            ,
    input          [ADDR_WIDTH-1:0]    wr_addr          ,
    input          [D_BUS_WIDTH-1:0]   wr_data          ,
  
    input                              rd_en            ,
    input          [ADDR_WIDTH-1:0]    rd_addr          ,
    output  reg    [D_BUS_WIDTH-1:0]   rd_data          ,

    output         [D_BUS_WIDTH-1:0]   o_pc_mtvec       ,  // 中断服务函数入口
    output         [D_BUS_WIDTH-1:0]   o_pc_mepc        ,  // 中断函数返回地址
    //input          [D_BUS_WIDTH-1:0]   pc_if2id_ff      ,
    input          [I_BUS_WIDTH-1:0]   instr_if_stage   ,
    input          [I_BUS_WIDTH-1:0]   instr_if2id_ff   ,
    input          [I_BUS_WIDTH-1:0]   instr_id2ex_ff   ,
    input          [I_BUS_WIDTH-1:0]   instr_ex2mem_ff  ,
    input          [I_BUS_WIDTH-1:0]   instr_mem2wb_ff  ,
    input          [D_BUS_WIDTH-1:0]   pc_if2id_ff      ,
    input          [D_BUS_WIDTH-1:0]   pc_id2ex_ff      ,
    input          [D_BUS_WIDTH-1:0]   pc_ex2mem_ff     ,
    input          [D_BUS_WIDTH-1:0]   pc_mem2wb_ff     ,
    input          [D_BUS_WIDTH-1:0]   pc_if_stage      ,
    input          [1:0]               i_excep_csr_upd  ,
    input                              i_mret_csr_upd   ,
    output         [D_BUS_WIDTH-1:0]   o_mie            ,
    output         [D_BUS_WIDTH-1:0]   o_mstatus        
);

reg    [D_BUS_WIDTH-1:0] csr_rg  [2**ADDR_WIDTH-1:0];

//rd_data
always@(*)begin
    if(rst) rd_data = 'd0;
    else if(rd_en)  rd_data = csr_rg[rd_addr];
    else rd_data = 'd0;
end

//m_cycle(csr_rg[])
always@(posedge clk)begin
    if(rst) csr_rg[`M_CYCLE] <= 'd0;
    else if(wr_en && wr_addr == `M_CYCLE)  csr_rg[`M_CYCLE] <= wr_data;
    else csr_rg[`M_CYCLE] <= csr_rg[`M_CYCLE] + 'd1;
end

// mstatus
wire  [D_BUS_WIDTH-1:0] w_mstatus  ;
assign w_mstatus = csr_rg[`MSTATUS];
assign o_mstatus = w_mstatus       ;

always@(posedge clk)begin
    if(rst) csr_rg[`MSTATUS] <= 'd0;
    else if(i_excep_csr_upd!=2'b00)
        csr_rg[`MSTATUS] <= {w_mstatus[D_BUS_WIDTH-1:13],2'b11,w_mstatus[10:8],w_mstatus[3],w_mstatus[6:4],1'b0,w_mstatus[2:0]} ;
    else if(i_mret_csr_upd)
        csr_rg[`MSTATUS] <= {w_mstatus[D_BUS_WIDTH-1:13],2'b11,w_mstatus[10:8],1'b1,w_mstatus[6:4],w_mstatus[7],w_mstatus[2:0]} ;    
    else if(wr_en && wr_addr == `MSTATUS)begin
         csr_rg[`MSTATUS] <= {((wr_data[16:15] == 2'b11) | (wr_data[14:13] == 2'b11)),wr_data[62:0]};
    end 
    else csr_rg[`MSTATUS] <= csr_rg[`MSTATUS] ;
end

// mie 
assign o_mie = csr_rg[`MIE] ;
always@(posedge clk)begin
    if(rst) csr_rg[`MIE] <= 'd0;
    else if(wr_en && wr_addr == `MIE)  csr_rg[`MIE] <= wr_data;
    else csr_rg[`MIE] <= csr_rg[`MIE] ;
end

// mtvec 
assign o_pc_mtvec = csr_rg[`MTVEC];

always@(posedge clk)begin
    if(rst) csr_rg[`MTVEC] <= 'd0;
    else if(wr_en && wr_addr == `MTVEC)  csr_rg[`MTVEC] <= wr_data;
    else csr_rg[`MTVEC] <= csr_rg[`MTVEC] ;
end

// mepc
reg    [I_BUS_WIDTH-1:0] r_mepc_instr ;
assign o_pc_mepc = csr_rg[`MEPC] ;

always@(posedge clk)begin
    if(rst) begin 
        r_mepc_instr  <= 'd0 ;
        csr_rg[`MEPC] <= 'd0 ;
    end
    else if(i_excep_csr_upd == 2'b01) begin
        csr_rg[`MEPC] <= pc_mem2wb_ff ;  // 保存进入trap前的pc
        r_mepc_instr  <= instr_mem2wb_ff ;
    end
    else if(i_excep_csr_upd == 2'b10) begin
        if(pc_mem2wb_ff != 'd0) begin
            r_mepc_instr  <= instr_mem2wb_ff ;
            csr_rg[`MEPC] <= pc_mem2wb_ff;
        end
        else if(pc_ex2mem_ff != 'd0) begin
            r_mepc_instr  <= instr_ex2mem_ff ;
            csr_rg[`MEPC] <= pc_ex2mem_ff;
        end
        else if(pc_if2id_ff != 'd0) begin
            r_mepc_instr  <= instr_id2ex_ff ;
            csr_rg[`MEPC] <= pc_id2ex_ff;    
        end
        else begin
            r_mepc_instr  <= instr_id2ex_ff ;  // attention
            csr_rg[`MEPC] <= pc_if_stage;    
        end     
    end
    else if(wr_en && wr_addr == `MEPC)  begin
        csr_rg[`MEPC] <= wr_data;
        r_mepc_instr  <= r_mepc_instr ;
    end
    else begin
        csr_rg[`MEPC] <= csr_rg[`MEPC] ;
        r_mepc_instr  <= r_mepc_instr ;
    end
end

// mcause
wire [63:0] w_mcause;
assign w_mcause = csr_rg[`MCAUSE];
always@(posedge clk)begin
    if(rst) csr_rg[`MCAUSE] <= 'd0;
    else if(i_excep_csr_upd==2'b01) 
        csr_rg[`MCAUSE] <= 64'd11 ;
    else if(i_excep_csr_upd==2'b10) 
        csr_rg[`MCAUSE] <= 64'h8000_0000_8000_0007 ;
    else if(wr_en && wr_addr == `MCAUSE)  csr_rg[`MCAUSE] <= wr_data;
    else csr_rg[`MCAUSE] <= csr_rg[`MCAUSE] ;
end

//mtval
wire [63:0] w_mtval;
assign w_mtval = csr_rg[`MTVAL];
always@(posedge clk)begin
    csr_rg[`MTVAL] <= 64'd0;
end

//minstret
wire [63:0] w_minstret;
assign w_minstret = csr_rg[`MINSTRET];
always@(posedge clk)begin
    if(rst) csr_rg[`MINSTRET] <= 'd0;
    else if(i_excep_csr_upd != 2'b10 && instr_mem2wb_ff != 'd0)   csr_rg[`MINSTRET] <= csr_rg[`MINSTRET] + 64'd1;
    else csr_rg[`MINSTRET] <= csr_rg[`MINSTRET];
end

//mscratch
wire [63:0] w_mscratch;
assign w_mscratch = csr_rg[`MSCRATCH];
always@(posedge clk)begin
    if(rst) csr_rg[`MSCRATCH] <= 'd0;
    else if(wr_en && wr_addr == `MSCRATCH)  csr_rg[`MSCRATCH] <= wr_data;
    else csr_rg[`MSCRATCH] <= csr_rg[`MSCRATCH] ;
end
endmodule
