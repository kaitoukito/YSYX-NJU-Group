`include "top_defines.v"
module mem_axi_rw#(
    parameter   DATA_WIDTH  = 64,             	//数据位宽
    parameter   ADDR_WIDTH  = 64,               //地址位宽              
    parameter   ID_WIDTH    = 4,               	//ID位宽
    parameter   USER_WIDTH  = 1024,             //USER位宽
	parameter	STRB_WIDTH  = 8
)(
	input        			clk			,
	input		 			rst			,

	input  [63:0] 	  		  data_addr  				   ,
	input 					  data_rd_addr_valid  		   ,
	output [DATA_WIDTH-1:0]   data_rd     				   ,
	output					  data_rd_valid				   ,
	input 					  data_wr_valid  		   	   ,
    input  [7:0] 		  	  data_wmask 				   ,
	input  [DATA_WIDTH-1:0]   data_wr    				   ,
	output	reg				  data_wr_ready				   ,
	
	output [ADDR_WIDTH-1:0]   M01_AXI_ARADDR               ,   
	output                    M01_AXI_ARVALID              ,   
	input                     M01_AXI_ARREADY              ,   
	output [7:0]              M01_AXI_ARLEN                , 
	output [ID_WIDTH-1:0]     M01_AXI_ARID                 ,   
	output [2:0]              M01_AXI_ARSIZE               ,   
	output [1:0]              M01_AXI_ARBURST              ,   
	output                    M01_AXI_ARLOCK               ,   
	output [3:0]              M01_AXI_ARCACHE              ,   
	output [2:0]              M01_AXI_ARPROT               ,   
	output [3:0]              M01_AXI_ARQOS                , 
	output [3:0]              M01_AXI_ARREGION             ,
    output [USER_WIDTH-1:0]   M01_AXI_ARUSER			   ,
	
	input [DATA_WIDTH-1:0]    M01_AXI_RDATA                ,   
	input                     M01_AXI_RLAST                ,   
	input                     M01_AXI_RVALID               ,   
	output                    M01_AXI_RREADY               , 
	input [ID_WIDTH-1:0]      M01_AXI_RID                  ,   
	input [1:0]               M01_AXI_RRESP                , 
	input [USER_WIDTH-1:0]	  M01_AXI_RUSER				   ,

	output [ADDR_WIDTH-1:0]   M01_AXI_AWADDR               , 
	output                    M01_AXI_AWVALID              , 
	input                     M01_AXI_AWREADY              , 
	output [7:0]              M01_AXI_AWLEN                , 
	output [ID_WIDTH-1:0]     M01_AXI_AWID                 , 
	output [2:0]              M01_AXI_AWSIZE               , 
	output [1:0]              M01_AXI_AWBURST              , 
	output                    M01_AXI_AWLOCK               , 
	output [3:0]              M01_AXI_AWCACHE              , 
	output [2:0]              M01_AXI_AWPROT               , 
	output [3:0]              M01_AXI_AWQOS                ,	
	output [3:0]              M01_AXI_AWREGION			  ,
    output [USER_WIDTH-1:0]   M01_AXI_AWUSER				  ,
	
	output [DATA_WIDTH-1:0]   M01_AXI_WDATA                , 
	output                    M01_AXI_WLAST                , 
	output                    M01_AXI_WVALID               , 
	input                     M01_AXI_WREADY               , 
	output [STRB_WIDTH-1:0]   M01_AXI_WSTRB                , 
    output [USER_WIDTH-1:0]   M01_AXI_WUSER				  ,	
	
	input [ID_WIDTH-1:0]      M01_AXI_BID                  , 
	input [1:0]               M01_AXI_BRESP                , 
	input                     M01_AXI_BVALID               , 
	output                    M01_AXI_BREADY               , 
	input [USER_WIDTH-1:0]    M01_AXI_BUSER				  	
);

reg		R_rd_state	= 'b0		;
parameter [1:0]  S_IDLE = 'd0	;
parameter [1:0]  S_ADDR_OVER = 'd1 ;
always@(posedge clk) begin
	if(rst) begin
		R_rd_state <=  S_IDLE			;
	end
	else case(R_rd_state) 
		S_IDLE: begin
			if(data_rd_addr_valid && M01_AXI_ARREADY ) 
				R_rd_state	<=	S_ADDR_OVER	;
		end
		S_ADDR_OVER:begin
			if(M01_AXI_RVALID)
				R_rd_state 	<=	S_IDLE		;
		end
		default:begin
			R_rd_state	<=	S_IDLE			;
		end
	endcase
end
	
			

assign 	  M01_AXI_ARADDR     =    data_addr			;
assign    M01_AXI_ARVALID    =	  (R_rd_state == S_IDLE) && data_rd_addr_valid;    
assign    M01_AXI_ARLEN 	 =	  'd0				;     
assign    M01_AXI_ARID		 =	  'd1				;       
assign    M01_AXI_ARSIZE	 = 	  'b011				;     
assign    M01_AXI_ARBURST	 =	  'b001				;    
assign    M01_AXI_ARLOCK     =  	'd0				;
assign    M01_AXI_ARCACHE    =    	'd0				;
assign    M01_AXI_ARPROT     =     	'd0				;
assign    M01_AXI_ARQOS      =		'd0				;
assign    M01_AXI_ARREGION   =  	'd0				;
assign    M01_AXI_ARUSER	 =      'd0				;
    
assign    data_rd 			 = 	M01_AXI_RDATA		;	           
assign    data_rd_valid		 =	M01_AXI_RVALID		;     
assign    M01_AXI_RREADY 	 = 'b1					;    


reg  [1:0]  R_wr_state 	     = 'd0	;
parameter [1:0]	 S_DEAL		 = 'd2	;
parameter [1:0]	 S_OVER		 = 'd3	;

always@(posedge clk) begin
	if(rst)
		R_wr_state <= S_IDLE		;
	else begin
		case(R_wr_state)
			S_IDLE:begin
				if(data_wr_valid && M01_AXI_AWREADY && M01_AXI_WREADY)
					R_wr_state  <= S_OVER		;
				else if(data_wr_valid && M01_AXI_AWREADY)
					R_wr_state	<=	S_ADDR_OVER	;
			end
			S_ADDR_OVER:begin
				if(data_wr_valid && M01_AXI_WREADY)
					R_wr_state  <=  S_OVER		;
				else if(~data_wr_valid) 
					R_wr_state 	<=  S_DEAL		;
			end
			S_DEAL:begin
				if(M01_AXI_WREADY)
					R_wr_state   <=    S_IDLE		;
			end
			S_OVER:begin
				if(M01_AXI_BVALID)
					R_wr_state  <=	S_IDLE		;
			end
			default:begin
				R_wr_state	<=	S_IDLE			;
			end
		endcase
	end
end
	
always@(*) begin
	case(R_wr_state)
	S_OVER:
		data_wr_ready = M01_AXI_BVALID;
	default:
		data_wr_ready = 'b0				;
	endcase
end

assign	  M01_AXI_AWADDR	 =  data_addr			;     
assign    M01_AXI_AWVALID 	 =(R_wr_state == S_IDLE)?	data_wr_valid:'b0;       
assign    M01_AXI_AWLEN		 =	  'd0				; 					    
assign    M01_AXI_AWID       =	  'd1				; 
assign    M01_AXI_AWSIZE     = 	  'b011				; 
assign    M01_AXI_AWBURST    =	  'b001				; 
assign    M01_AXI_AWLOCK     =  	'd0				;
assign    M01_AXI_AWCACHE    =    	'd0				;
assign    M01_AXI_AWPROT     =     	'd0				;
assign    M01_AXI_AWQOS      =		'd0				;
assign    M01_AXI_AWREGION	 =  	'd0				;
assign    M01_AXI_AWUSER	 =      'd0				;	
   
assign    M01_AXI_WDATA		 =	data_wr				;      
assign    M01_AXI_WLAST      = M01_AXI_WVALID		;
assign    M01_AXI_WVALID	 =  ((R_wr_state == S_IDLE && M01_AXI_AWREADY)||(R_wr_state == S_ADDR_OVER))? data_wr_valid:((R_wr_state == S_DEAL)?'b1:'b0)		;	        
assign    M01_AXI_WSTRB 	 =	(R_wr_state == S_DEAL)?'b0:data_wmask			;    
assign    M01_AXI_WUSER		 =	'd0					;
        
assign    M01_AXI_BREADY	 =	'b1					;  





endmodule  
		