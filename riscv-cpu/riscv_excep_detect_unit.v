`include"riscv_define.vh"
`include "top_defines.v"
module riscv_excep_detect_unit #(
    parameter ADDR_WIDTH  = 12,
    parameter I_BUS_WIDTH = 32,
    parameter D_BUS_WIDTH = 64
)(
    input [I_BUS_WIDTH-1:0] i_instr_mem2wb_ff,
    //input [I_BUS_WIDTH-1:0] i_instr_if_stage ,
    input                   i_clint_timer_irq,

    input [D_BUS_WIDTH-1:0] i_mie            ,
    input [D_BUS_WIDTH-1:0] i_mstatus        ,  

    output                  o_excep_stall    ,  // 
    output                  o_irq_stall      ,  // 
    output  reg   [1:0]     o_excep_csr_upd  ,  // output to csr to update the CSRs by ecall instruction and so on
    output                  o_mret_csr_upd   ,  // output to csr to update the CSRs by mret instruction
    output                  o_core_ready 

);
    wire clint_timer_irq_vld ;
    // wire excep_vld ;

    assign o_core_ready        = i_mstatus[3] & i_mie[7] ;
    assign clint_timer_irq_vld = i_clint_timer_irq & i_mstatus[3] & i_mie[7] ;
    assign o_excep_stall       = (i_instr_mem2wb_ff[6:0] == 7'b1110011 && i_instr_mem2wb_ff[31:20] == 12'd0);  //仅支持了 ecall 指令
    assign o_irq_stall         = clint_timer_irq_vld ;
    assign o_mret_csr_upd      = (i_instr_mem2wb_ff[6:0] == 7'b1110011 && i_instr_mem2wb_ff[31:20] == 12'b0011_0000_0010) ;

    always@(*)begin
        if(o_excep_stall)  // 异常发生
            o_excep_csr_upd = 2'b01 ;
        else if(clint_timer_irq_vld)  // 计时器中断，在 MTIE和 MIE位有效时
            o_excep_csr_upd = 2'b10 ;
        else
            o_excep_csr_upd = 2'b00 ;
    end

endmodule