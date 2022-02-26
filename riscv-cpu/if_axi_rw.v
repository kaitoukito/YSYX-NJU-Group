`include "top_defines.v"
module if_axi_rw#(
    parameter   DATA_WIDTH  = 64,             	//数据位宽
    parameter   ADDR_WIDTH  = 64,               //地址位宽              
    parameter   ID_WIDTH    = 4,               	//ID位宽
    parameter   USER_WIDTH  = 1024              //USER位宽
)(
	input           		clk					,
	input	   	 			rst					,
			   
	input	   				inst_addr_valid		,
	input	   [63:0]		inst_addr			,
	output	   [31:0]		inst				,
	output	   				inst_valid			,
	
	output reg [ADDR_WIDTH-1:0]   M00_AXI_ARADDR               ,   
	output reg                    M00_AXI_ARVALID              ,   
	input                         M00_AXI_ARREADY              ,   
	output     [7:0]              M00_AXI_ARLEN                , 
	output     [ID_WIDTH-1:0]     M00_AXI_ARID                 ,   
	output     [2:0]              M00_AXI_ARSIZE               ,   
	output     [1:0]              M00_AXI_ARBURST              ,   
	output                        M00_AXI_ARLOCK               ,   
	output     [3:0]              M00_AXI_ARCACHE              ,   
	output     [2:0]              M00_AXI_ARPROT               ,   
	output     [3:0]              M00_AXI_ARQOS                , 
	output     [3:0]              M00_AXI_ARREGION             ,
    output     [USER_WIDTH-1:0]   M00_AXI_ARUSER			   ,
		      
	input      [DATA_WIDTH-1:0]   M00_AXI_RDATA                ,   
	input                         M00_AXI_RLAST                ,   
	input                         M00_AXI_RVALID               ,   
	output                        M00_AXI_RREADY               , 
	input      [ID_WIDTH-1:0]     M00_AXI_RID                  ,   
	input      [1:0]              M00_AXI_RRESP                , 
	input      [USER_WIDTH-1:0]	  M00_AXI_RUSER				  
);


assign   M00_AXI_ARLEN   =   8'b00000111;
assign   M00_AXI_ARID	 =   'd0		;
assign   M00_AXI_ARSIZE  =   3'b011		;
assign	 M00_AXI_ARBURST =   3'b001		;
assign   M00_AXI_ARLOCK  =  	'd0		;
assign   M00_AXI_ARCACHE =    	'd0		;
assign   M00_AXI_ARPROT  =     	'd0		;
assign   M00_AXI_ARQOS   =		'd0		;  
assign   M00_AXI_ARREGION=  	'd0		;
assign   M00_AXI_ARUSER	 =      'd0		;

wire	 			addr_hit			;
reg      [63:0]		fifo_addr	=	'b0	;
assign   addr_hit	=	(inst_addr[63:3] == fifo_addr[63:3])	;

reg     	[1:0]		R_state   	=  'b0      ;
parameter	[1:0]		S_IDLE  	=  'd0		;
parameter   [1:0]		S_AXI_RD	=  'd1		;
parameter	[1:0]		S_INST_RD 	=  'd2		;

wire     	fifo_valid					 ;
wire	 	fifo_empty					 ;
wire	 	fifo_full					 ;
wire [64:0] fifo_dout					 ;
wire        fifo_rd_en					 ;

always@(posedge clk) begin
	if(rst) begin
		R_state <=  S_IDLE			;
	end
	else case(R_state)
		S_IDLE:begin
			if(inst_addr_valid)
				R_state  <=  S_AXI_RD  ;
		end
		S_AXI_RD:begin
			if(M00_AXI_RLAST & M00_AXI_RVALID)
				R_state  <=  S_INST_RD	;
		end
		S_INST_RD:begin
			if(~addr_hit)
				R_state  <=	 S_IDLE	;
		end
		default:	R_state <= S_IDLE;
	endcase
end	

assign      fifo_rd_en  = addr_hit & ~fifo_empty & fifo_addr[2];
assign      inst = (inst_addr[2])?fifo_dout[63:32]:fifo_dout[31:0];
assign		inst_valid = fifo_valid && addr_hit	;

fifo #(
	.FIFO_DEPTH ('d4)	,//指数关系
	.FIFO_WIDTH	('d65)	   	
)inst_fifo(
	.clk	(clk)							,
	.rst	(~addr_hit)						,
	.din	({M00_AXI_RLAST,M00_AXI_RDATA})	,
	.wr_en	(M00_AXI_RVALID&M00_AXI_RREADY)	,
	.rd_en  (fifo_rd_en)     				,
	.dout	(fifo_dout)						,
	.valid	(fifo_valid)					,
	.empty	(fifo_empty)					,
	.full	(fifo_full)
);

assign  M00_AXI_RREADY	=	~fifo_full		;

always@(posedge clk) begin
	if((R_state == S_IDLE)&& inst_addr_valid) 
		fifo_addr <= {inst_addr[63:3],3'b0}				;
	else if((R_state == S_AXI_RD || R_state == S_INST_RD)&&fifo_rd_en)
		fifo_addr <= fifo_addr + 'd8		;
end

always@(posedge clk) begin
	if((R_state == S_IDLE) && inst_addr_valid) begin
		M00_AXI_ARADDR	<=	{inst_addr[63:3],3'b0}		;
		M00_AXI_ARVALID	<=	'b1				;
	end
	else if((R_state == S_AXI_RD)&& M00_AXI_ARVALID && M00_AXI_ARREADY) begin
		M00_AXI_ARVALID	<=	'b0				;
	end
end
endmodule