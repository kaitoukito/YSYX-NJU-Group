`include"riscv_define.vh"
`include "top_defines.v"
module riscv_clint #(
    parameter ADDR_WIDTH  = 64,
    parameter D_BUS_WIDTH = 64
)(
    input                              clk                   ,
    input                              rst                   ,

    input                              wr_en                 ,
    input                              rd_en                 ,
    input          [ADDR_WIDTH-1:0]    rw_addr               ,
    input          [D_BUS_WIDTH-1:0]   wr_data               ,
    output  reg    [D_BUS_WIDTH-1:0]   rd_data               ,
    output                             o_clint_rd_data_valid ,
    output                             o_clint_wr_ready      ,
    
    input                              i_core_ready          ,
    output  reg                        o_clint_timer_irq ='d0   

);

reg [D_BUS_WIDTH-1:0] mtime = 64'd0;
reg [D_BUS_WIDTH-1:0] mtimecmp = 'd100000; 

assign o_clint_wr_ready         = 1 ;    
assign o_clint_rd_data_valid    = 1 ;

always @(posedge clk) begin
    if(rst) begin
        mtime <= 'd0;
    end
    else begin
        mtime <= mtime + 1 ;
    end
end

always @(posedge clk ) begin
    if(rst) begin
        mtimecmp <= 'd100000;
    end
    else begin
        //if(wr_en && rw_addr == 64'h0000_0000_0200_4000)
        if(wr_en && rw_addr == 64'h0000_0000_0200_4000)
            mtimecmp <= wr_data ;
        else 
            mtimecmp <= mtimecmp ;
    end
end

always @(*) begin
    if(rd_en) begin
        if(rw_addr == 64'h0000_0000_0200_4000)        rd_data = mtimecmp ;
        else if(rw_addr == 64'h0000_0000_0200_BFF8)   rd_data = mtime    ;
        else rd_data = 'd0 ;
    end
    else begin
        rd_data = 'd0 ;
    end
end

always @(posedge clk) begin
    if(rst) begin
        o_clint_timer_irq <= 0;
    end
    else if(mtime == mtimecmp) begin
        o_clint_timer_irq <= 1 ;
    end
    else if(i_core_ready) begin
        o_clint_timer_irq <= 0 ;
    end    
    else begin
        o_clint_timer_irq <= o_clint_timer_irq ;
    end
end

endmodule

