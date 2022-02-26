`include "top_defines.v"
module fifo #(
	parameter      FIFO_DEPTH 	= 'd8	,//指数关系
	parameter	   FIFO_WIDTH	= 'd32	   	
)(
	input								clk			,
	input								rst			,
	input   		[FIFO_WIDTH-1:0]	din			,
	input			                    rd_en       ,
	input   		                    wr_en		,
	output  reg  	[FIFO_WIDTH-1:0]	dout		,
	output  reg   						valid		,
	output	reg							empty		,
	output	reg							full
);
	reg [FIFO_DEPTH-1:0]  rd_item						;
	reg	[FIFO_DEPTH-1:0]  wr_item						; 
	reg [FIFO_WIDTH-1:0]  fifo_mem [2**FIFO_DEPTH-1:0]	;
	
	always@(*) begin
		if(rst) begin
			dout 	= 'b0 				;
			valid	= 'b0				; 
		end
		else if(~empty) begin
			dout 	= fifo_mem[rd_item];
			valid	=	'b1				;
		end
		else begin
			dout	= fifo_mem[rd_item];
			valid   =	'b0				;
		end
	end

	always@(posedge clk) begin
		if(rst) begin
			fifo_mem[wr_item] <= 'b0	;
		end
		else if(wr_en&& ~full) begin
			fifo_mem[wr_item] <= din	;
		end
	end
	
	always@(posedge clk) begin
		if(rst) 
			rd_item <= 'b0				;
		else if(rd_en && ~empty) 
			rd_item <=  rd_item + 'b1	;
	end
	
	always@(posedge clk) begin
		if(rst)
			wr_item <=	'b0				;
		else if(wr_en && ~full)
			wr_item <=	wr_item +  'b1	;
	end
	
	always@(posedge clk) begin
		if(rst) 
			empty   <=  'b1        		;
		else if((rd_item == wr_item - 'b1) && rd_en)
			empty	<=	'b1				;
		else if(rd_item != wr_item)
			empty	<=	'b0				;
		else if(rd_item == wr_item && wr_en)
			empty	<=	'b0				;
	end
	
	always@(posedge clk) begin
		if(rst) 
			full	<=	'b0				;
		else if((wr_item == rd_item - 'b1) && wr_en) 
			full	<=	'b1				;
		else if(rd_item != wr_item)
			full	<=	'b0				;
		else if(rd_item == wr_item && rd_en)
			full	<=	'b0				;
	end
endmodule