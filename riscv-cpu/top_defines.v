`timescale 1ns / 1ps

//`define ZERO_WORD  64'h00000000_00000000
`define PC_START   64'h00000000_80000000  
`define REG_BUS    63 : 0     
`define INST_ADD   8'h11

`define AXI_ADDR_WIDTH      64
`define AXI_DATA_WIDTH      64
`define AXI_ID_WIDTH        4
`define AXI_USER_WIDTH      1024

`define SIZE_B              2'b00
`define SIZE_H              2'b01
`define SIZE_W              2'b10
`define SIZE_D              2'b11

`define REQ_READ            1'b0
`define REQ_WRITE           1'b1

`define RISCV_PRIV_MODE_U   0
`define RISCV_PRIV_MODE_S   1
`define RISCV_PRIV_MODE_M   3