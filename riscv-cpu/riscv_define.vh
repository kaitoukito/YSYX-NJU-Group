//# RV32I opcode field
`define OP_IMM      7'b001_0011
`define LUI         7'b011_0111
`define AUIPC       7'b001_0111
`define OP          7'b011_0011
`define JAL         7'b110_1111
`define JALR        7'b110_0111
`define BRANCH      7'b110_0011
`define LOAD        7'b000_0011
`define STORE       7'b010_0011
`define MISC_MEM    7'b000_1111
`define SYSTEM      7'b111_0011

//# RV64I extended opcode field
`define OP_IMM_32   7'b001_1011
`define OP_32       7'b011_1011

`define BUS_WIDTH   63:0
`define ZERO_WORD   64'd0

//# CSR addr
`define M_CYCLE     12'hb00    
`define MSTATUS     12'h300
`define MIE         12'h304
`define MTVEC       12'h305    
`define MEPC        12'h341
`define MCAUSE      12'h342
`define MTVAL       12'h343
`define MINSTRET    12'hb02
`define MSCRATCH    12'h340