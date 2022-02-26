`include "top_defines.v"
module riscv_branch #(
    parameter   WIDTH   = 32
) (
    input      			    		branch,
    input      		[2:0]   		func_code,
	input			            	alu_out,
	input							rs1,
	input							rs2,
	input							zero,
    output  reg   		    		branch_out
);

	wire    alu_out1	;
	wire    alu_out2	;
	assign  alu_out1		= (rs1&~rs2)|((rs1^~rs2)&alu_out)	;	//rs1 <  rs2
	assign  alu_out2		= (~rs1&rs2)|((rs1^~rs2)&alu_out)	;	//rs1 <  rs2(无符号数比较)
	always@(*) begin
		if(branch == 'b1)
			case(func_code)
				3'b000 	:branch_out = zero	; 
				3'b001	:branch_out = ~zero	;
				3'b100	:branch_out = alu_out1	;	
				3'b101	:branch_out = ~alu_out1	;
				3'b110 	:branch_out = alu_out2	; 
				3'b111 	:branch_out = ~alu_out2	;
			default     :branch_out = 'b0		;
			endcase
		else
			branch_out = 'b0					;
	end
endmodule