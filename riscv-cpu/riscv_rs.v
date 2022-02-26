/// sequential logic
/// register slices
`include "top_defines.v"
module riscv_rs #(
    parameter   DATA_WIDTH  = -1
) (
    input   	                        clk,
    input   	                        sft_rst,
    input   	    [DATA_WIDTH-1:0]    din,
    input   	                        en,
    //input                             stall_IF2ID_ff,
	input								stall,
    //input                             excep_stall,
    input								flush,
	output  reg     [DATA_WIDTH-1:0]    dout
);

    always @(posedge clk) begin
        if (sft_rst) begin
            dout <= 'd0;
        end
        //else if(excep_stall)begin
		else if(flush)begin
			dout <= 'd0;
        end
        else if(stall)begin
            dout <= dout;
        end
        else if (en) begin
            dout <= din;
        end
		else	dout <='d0;
    end

endmodule
