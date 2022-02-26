`include "top_defines.v"
module RAM_1W2R #(
	parameter   IBUS_DATA_WIDTH = 32,    // instruction bus data width
    parameter   DBUS_DATA_WIDTH = 64,    // data bus data width
    parameter   IMEM_ADDR_WIDTH = 64,    // instruction memory address width
    parameter   DMEM_ADDR_WIDTH = 64     // data memory address width

) (
    input   clk,
    
    input   [IMEM_ADDR_WIDTH-1 : 0] inst_addr,
    input                           inst_ena,
    output  [IBUS_DATA_WIDTH-1 : 0] inst,

    // DATA PORT
    input                           ram_wr_en,
    input                           ram_rd_en,
    input   [DBUS_DATA_WIDTH-1 : 0] ram_wmask,
    input   [DMEM_ADDR_WIDTH-1 : 0] ram_addr,
    input   [DBUS_DATA_WIDTH-1 : 0] ram_wr_data,
    output  [DBUS_DATA_WIDTH-1 : 0] ram_rd_data
);

    // INST PORT

    wire [DBUS_DATA_WIDTH-1 : 0] inst_2 ;
    assign inst_2 = ram_read_helper(inst_ena,{3'b000,(inst_addr-64'h0000_0000_8000_0000)>>3});

    assign inst = inst_addr[2] ? inst_2[63:32] : inst_2[31:0];

    // DATA PORT 
    assign ram_rd_data = ram_read_helper(ram_rd_en, {3'b000,(ram_addr-64'h0000_0000_8000_0000)>>3});

    always @(posedge clk) begin
        ram_write_helper((ram_addr-64'h0000_0000_8000_0000)>>3, ram_wr_data, ram_wmask, ram_wr_en);
    end

endmodule
