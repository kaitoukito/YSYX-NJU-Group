`include "top_defines.v"
module riscv_load #(
    parameter   WIDTH   = 32
) (
    input      		     	  		mem_read,
    input      		[2:0]   		func_code,
	input			[WIDTH-1:0]     mem_out,
    output  reg   	[WIDTH-1:0]	    load_out
);

	always@(*) begin
		if(mem_read == 'b1)
			case(func_code)
				3'b000 	:load_out = {{56{mem_out[7]}},mem_out[7:0]}		; 
				3'b001	:load_out = {{48{mem_out[15]}},mem_out[15:0]}	;
				3'b010  :load_out = {{32{mem_out[31]}},mem_out[31:0]}	;
				3'b011	:load_out = mem_out								;
				3'b100	:load_out = {56'b0,mem_out[7:0]}				;	
				3'b101	:load_out = {48'b0,mem_out[15:0]}				;
				3'b110 	:load_out = {32'b0,mem_out[31:0]}				;
			default     :load_out = 'b0									;
			endcase
		else
			load_out = 'b0					;
	end
endmodule