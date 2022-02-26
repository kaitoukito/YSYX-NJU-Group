`include "top_defines.v"
module riscv_alu #(
    parameter   WIDTH   = 32
) (
    input   signed	   [WIDTH-1:0]     a,
    input   signed	   [WIDTH-1:0]     b,
    input   	   	   [3:0]           alu_ctrl,   // {ainvert, bnegate, operation[1:0]}
    output reg signed  [WIDTH-1:0]     alu_out,
    output  	                   	   zero
);

	wire   [WIDTH-1:0]   ua;
	wire   [WIDTH-1:0]   ub;
	wire   [WIDTH-1:0]	 add_data;
	wire   [WIDTH-1:0]	 sub_data;
	wire   [31:0]		sllw_data;
	wire  signed [31:0]	sraw_data;
	wire   [31:0]		srlw_data;
	assign ua  =  a	 ;
	assign ub  =  b   ;
	assign add_data =  a + b;
	assign sub_data  =  a - b;
	assign sllw_data =a[31:0] << b[4:0];  	
	assign sraw_data =a[31:0];
	assign srlw_data =a[31:0]>> b[4:0];
    always@(*) begin
        case (alu_ctrl)
            4'b0000 :   alu_out = add_data ;								//add,addi
			4'b0001 :   alu_out = a << b[5:0];								//sll,slli
            4'b0010 :   alu_out = (a < b) ? 'd1 : 'd0;						//slt,slti
            4'b0011 :   alu_out = (ua < ub) ? 'd1 : 'd0;					//sltu,sltiu
			4'b0100	:	alu_out = a ^ b	;									//xor,xori
            4'b0101 :   alu_out = a >> b[5:0];								//srl,srli
            4'b0110 :   alu_out = a | b ; 									//or,ori
			4'b0111 :	alu_out = a & b ;									//and,andi
			4'b1000 :   alu_out = sub_data ;								//sub
			4'b1001 : 	alu_out = {{32{add_data[31]}},add_data[31:0]};		//addw,addiw
			4'b1010 :	alu_out = {{32{sub_data[31]}},sub_data[31:0]};		//subw
			4'b1011 :   alu_out = {{32{sllw_data[31]}},sllw_data};			//sllw,slliw
			4'b1100 :   alu_out = {{32{srlw_data[31]}},srlw_data};				//srlw,srliw
			4'b1101 :   alu_out = a >>> b[5:0];								//sra,srai
			4'b1110 :   alu_out = {{32{a[31]}},sraw_data >>>b[4:0]};		//sraw,sraiw							
            default :   alu_out = 'd0;
        endcase
    end

    assign zero = (alu_out == 'd0);

endmodule
