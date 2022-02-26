`include "top_defines.v"
module riscv_store #(
    parameter   WIDTH   = 32
) (
    input      			    		mem_write,
	input							mem_read ,
    input      		[2:0]   		func_code,
	input			[WIDTH-1:0]     reg2_out,
    output  reg   	[WIDTH-1:0]    	store_out,
	output	reg		[7:0]			mask_out
);

	always@(*) begin
		if((mem_write == 'b1)||(mem_read == 'b1))
			case(func_code)
				3'b100,3'b000 	:begin
					store_out = {{56{reg2_out[7]}},reg2_out[7:0]}	; 
					mask_out  = 8'b0000_0001						;
					end
				3'b101,3'b001	:begin
					store_out = {{48{reg2_out[15]}},reg2_out[15:0]}	;
					mask_out  = 8'b0000_0011 						;
					end
				3'b110,3'b010  :begin
					store_out = {{32{reg2_out[31]}},reg2_out[31:0]}	;
					mask_out  = 8'b0000_1111						;
					end
				3'b011	:begin
					store_out = reg2_out							;
					mask_out = 8'b1111_1111							;
					end
			default     :begin
				store_out =64'b0									;
				mask_out = 8'b0										;
				end	
			endcase
		else begin
			store_out = 'b0											;
			mask_out  = 'b0											;
		end
		end
endmodule