`include "top_defines.v"
module riscv_router #(
    parameter DBUS_DATA_WIDTH      = 64,               // data bus data width
    parameter DMEM_ADDR_WIDTH      = 64                // data memory address width
)(
    // CPU core interface
    input                              i_core_data_wr_en    ,  // from cpu
    input                              i_core_data_rd_en    ,  // from cpu
    input [7:0]                        i_core_data_mask     ,  // from cpu
    input [DMEM_ADDR_WIDTH-1 : 0]      i_core_addr          ,  // from cpu
    input [DBUS_DATA_WIDTH-1 : 0]      i_core_wdata         ,  // from cpu
    output reg [DBUS_DATA_WIDTH-1 : 0] o_core_rdata         ,  // to cpu
    output reg                         o_core_rdata_valid   ,  // to cpu
    output reg                         o_core_data_wr_ready ,  // to cpu
    // data mem interface
    output reg                         o_port0_wr_en        ,  // data_wr_valid
    output reg                         o_port0_rd_en        ,  // data_rd_addr_valid
    output reg [7:0]                   o_port0_data_mask    ,  // data_wmask
    output reg [DMEM_ADDR_WIDTH-1 : 0] o_port0_addr         ,  // data_addr
    output reg [DBUS_DATA_WIDTH-1 : 0] o_port0_wdata        ,  // data_wr
    input      [DBUS_DATA_WIDTH-1 : 0] i_port0_rdata        ,  // data_rd
    input                              i_port0_rdata_valid  ,  // data_rd_valid
    input     				           i_port0_wr_ready	    ,  // data_wr_ready
    // clint interface
    output reg                         o_port1_wr_en     ,
    output reg                         o_port1_rd_en     ,
    output reg [DMEM_ADDR_WIDTH-1 : 0] o_port1_addr      , 
    output reg [DBUS_DATA_WIDTH-1 : 0] o_port1_wdata     ,
    input      [DBUS_DATA_WIDTH-1 : 0] i_port1_rdata     ,
    input    				           i_port1_wr_ready	    ,  // data_wr_ready
    input                              i_port1_rdata_valid     // data_rd_valid     

);

localparam PORT0_ADDR_PATTERN   = 64'h0000_0000_8000_0000  ;  // data mem map 0x8000_0000 and above
localparam PORT1_ADDR_PATTERN   = 64'h0000_0000_0200_0000  ;  // clint address map 0x0200_0000 to 0x0200_ffff
localparam PORT0_ADDR_MASK      = 64'h0000_0000_FFFF_0000  ;
localparam PORT1_ADDR_MASK      = 64'h0000_0000_FFFF_0000  ;

reg [1:0] port_sel ;


// always @(*) begin
//     if((i_core_addr) == PORT1_ADDR_PATTERN)       port_sel = 2'b01 ; // data from clint
//     //else if((i_core_addr & PORT0_ADDR_MASK) == PORT0_ADDR_PATTERN)  port_sel = 2'b00 ; // data from data mem
//     else port_sel = 2'b00 ;
// end

always @(*) begin
    if((i_core_addr & PORT1_ADDR_MASK) == PORT1_ADDR_PATTERN)       port_sel = 2'b01 ; // data from clint
    else if((i_core_addr & PORT0_ADDR_MASK) == PORT0_ADDR_PATTERN)  port_sel = 2'b00 ; // data from data mem
    else port_sel = 2'b00 ;
end

always@(*) begin
    case(port_sel)
        2'b00 : begin 
            o_core_rdata        = i_port0_rdata        ;
            o_core_data_wr_ready= i_port0_wr_ready	   ;
            o_core_rdata_valid  = i_port0_rdata_valid  ;
        end
        2'b01 : begin 
            o_core_rdata        = i_port1_rdata ;
            o_core_data_wr_ready= i_port1_wr_ready	   ;
            o_core_rdata_valid  = i_port1_rdata_valid  ;
        end
        default : begin 
            o_core_rdata        = i_port0_rdata ;
            o_core_data_wr_ready= i_port0_wr_ready	   ;
            o_core_rdata_valid  = i_port0_rdata_valid  ;
        end
    endcase
end

always@(*) begin
    if(port_sel ==2'b00) begin
        o_port0_wdata = i_core_wdata        ;
        o_port0_addr  = i_core_addr         ;
        o_port0_wr_en = i_core_data_wr_en   ;
        o_port0_rd_en = i_core_data_rd_en   ;
        o_port0_data_mask  =  i_core_data_mask ;   
    end
    else begin
        o_port0_wdata = {(DBUS_DATA_WIDTH){1'b0}} ;
        o_port0_addr  = {(DMEM_ADDR_WIDTH){1'b0}} ;
        o_port0_wr_en = 1'b0 ;
        o_port0_rd_en = 1'b0 ;   
        o_port0_data_mask  =  8'd0 ;       
    end
end

// always@(*) begin
//     o_port0_wdata = i_core_wdata        ;
//     o_port0_addr  = i_core_addr         ;
//     o_port0_wr_en = i_core_data_wr_en   ;
//     o_port0_rd_en = i_core_data_rd_en   ;
//     o_port0_data_mask  =  i_core_data_mask ;   
// end

always@(*) begin
    if(port_sel ==2'b01) begin
        o_port1_wdata = i_core_wdata        ;
        o_port1_addr  = i_core_addr         ;
        o_port1_wr_en = i_core_data_wr_en   ;
        o_port1_rd_en = i_core_data_rd_en   ;
    end
    else begin
        o_port1_wdata = {(DBUS_DATA_WIDTH){1'b0}} ;
        o_port1_addr  = {(DMEM_ADDR_WIDTH){1'b0}} ;
        o_port1_wr_en = 1'b0 ;
        o_port1_rd_en = 1'b0 ;         
    end
end


endmodule


