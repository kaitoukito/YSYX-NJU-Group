`include "top_defines.v"
module axi_interconnect#(
    parameter   DATA_WIDTH  = 64,             	//数据位宽
    parameter   ADDR_WIDTH  = 64,               //地址位宽              
    parameter   ID_WIDTH    = 4,               	//ID位宽
    parameter   USER_WIDTH  = 1024,             //USER位宽
    parameter   STRB_WIDTH  = 8   				//STRB位宽
)(
	
	input                    i_clk                        ,   
	input                    i_rst_n                      ,

    /**********master0**********/

	input 		[ADDR_WIDTH-1:0]   S00_AXI_ARADDR               ,   
	input                    	   S00_AXI_ARVALID              ,   
	output reg               	   S00_AXI_ARREADY              ,   
	input 		[7:0]              S00_AXI_ARLEN                , 
	input 		[3:0]              S00_AXI_ARID                 ,   
	input 		[2:0]              S00_AXI_ARSIZE               ,   
	input 		[1:0]              S00_AXI_ARBURST              ,   
	input 		                   S00_AXI_ARLOCK               ,   
	input 		[3:0]              S00_AXI_ARCACHE              ,   
	input 		[2:0]              S00_AXI_ARPROT               ,   
	input 		[3:0]              S00_AXI_ARQOS                , 
	input 		[3:0]              S00_AXI_ARREGION             ,
    input 		[USER_WIDTH-1:0]   S00_AXI_ARUSER				,
	
	output reg	[DATA_WIDTH-1:0]   S00_AXI_RDATA                ,   
	output reg                     S00_AXI_RLAST                ,   
	output reg                     S00_AXI_RVALID               ,   
	input                    	   S00_AXI_RREADY               , 
	output reg  [3:0]              S00_AXI_RID                  ,   
	output reg	[1:0]              S00_AXI_RRESP                , 
	output reg	[USER_WIDTH-1:0]   S00_AXI_RUSER				,
    /**********master1**********/	

	input 		[ADDR_WIDTH-1:0]   S01_AXI_ARADDR               ,   
	input 		                   S01_AXI_ARVALID              ,   
	output reg		               S01_AXI_ARREADY              ,   
	input 		[7:0]              S01_AXI_ARLEN                , 
	input 		[3:0]              S01_AXI_ARID                 ,   
	input 		[2:0]              S01_AXI_ARSIZE               ,   
	input 		[1:0]              S01_AXI_ARBURST              ,   
	input 		                   S01_AXI_ARLOCK               ,   
	input 		[3:0]              S01_AXI_ARCACHE              ,   
	input 		[2:0]              S01_AXI_ARPROT               ,   
	input 		[3:0]              S01_AXI_ARQOS                , 
	input 		[3:0]              S01_AXI_ARREGION             ,
    input 		[USER_WIDTH-1:0]   S01_AXI_ARUSER				,
	
	output reg  [DATA_WIDTH-1:0]   S01_AXI_RDATA                ,   
	output reg                     S01_AXI_RLAST                ,   
	output reg                     S01_AXI_RVALID               ,   
	input                          S01_AXI_RREADY               , 
	output reg  [3:0]              S01_AXI_RID                  ,   
	output reg  [1:0]              S01_AXI_RRESP                ,
	output reg  [USER_WIDTH-1:0]   S01_AXI_RUSER				,	 	
	
	input 		[ADDR_WIDTH-1:0]   S01_AXI_AWADDR               ,   
	input 		                   S01_AXI_AWVALID              ,   
	output reg	                   S01_AXI_AWREADY              ,   
	input 		[7:0]              S01_AXI_AWLEN                , 
	input 		[ID_WIDTH-1:0]     S01_AXI_AWID                 ,   
	input 		[2:0]              S01_AXI_AWSIZE               ,   
	input 		[1:0]              S01_AXI_AWBURST              ,   
	input 		                   S01_AXI_AWLOCK               ,   
	input 		[3:0]              S01_AXI_AWCACHE              ,   
	input 		[2:0]              S01_AXI_AWPROT               ,   
	input 		[3:0]              S01_AXI_AWQOS                ,	
	input 		[3:0]              S01_AXI_AWREGION			    ,
    input 		[USER_WIDTH-1:0]   S01_AXI_AWUSER				,
	
	input 		[DATA_WIDTH-1:0]   S01_AXI_WDATA                ,   
	input 		                   S01_AXI_WLAST                ,   
	input 		                   S01_AXI_WVALID               ,   
	output reg		               S01_AXI_WREADY               , 
	input 		[STRB_WIDTH-1:0]   S01_AXI_WSTRB                , 
    input 		[USER_WIDTH-1:0]   S01_AXI_WUSER				,	
			
	output reg  [ID_WIDTH-1:0]   S01_AXI_BID                  ,   
	output reg  [1:0]              S01_AXI_BRESP                ,   
	output reg                     S01_AXI_BVALID               ,   
	input  		                   S01_AXI_BREADY               , 
	output reg  [USER_WIDTH-1:0]   S01_AXI_BUSER				,
	

	/********** slave0 **********/
	
	output reg	[ADDR_WIDTH-1:0]   M00_AXI_ARADDR              ,   
	output reg	                   M00_AXI_ARVALID             ,   
	input   	                   M00_AXI_ARREADY             ,   
	output reg	[7:0]              M00_AXI_ARLEN               , 
	output reg	[3:0]              M00_AXI_ARID                ,   
	output reg	[2:0]              M00_AXI_ARSIZE              ,   
	output reg	[1:0]              M00_AXI_ARBURST             ,   
	output reg	                   M00_AXI_ARLOCK              ,   
	output reg	[3:0]              M00_AXI_ARCACHE             ,   
	output reg	[2:0]              M00_AXI_ARPROT              ,   
	output reg	[3:0]              M00_AXI_ARQOS               , 
	output reg	[3:0]              M00_AXI_ARREGION            ,
    output reg	[USER_WIDTH-1:0]   M00_AXI_ARUSER			   ,
	
	input       [DATA_WIDTH-1:0]   M00_AXI_RDATA               ,   
	input                     	   M00_AXI_RLAST               ,   
	input                          M00_AXI_RVALID              ,   
	output reg                     M00_AXI_RREADY              , 
	input		[3:0]              M00_AXI_RID                 ,   
	input		[1:0]              M00_AXI_RRESP               ,
	input 		[USER_WIDTH-1:0]   M00_AXI_RUSER			   ,	 	
														  
	output reg  [ADDR_WIDTH-1:0]   M00_AXI_AWADDR              ,   
	output reg                     M00_AXI_AWVALID             ,   
	input                          M00_AXI_AWREADY             ,   
	output reg  [7:0]              M00_AXI_AWLEN               , 
	output reg  [ID_WIDTH-1:0]     M00_AXI_AWID                ,   
	output reg  [2:0]              M00_AXI_AWSIZE              ,   
	output reg  [1:0]              M00_AXI_AWBURST             ,   
	output reg                     M00_AXI_AWLOCK              ,   
	output reg  [3:0]              M00_AXI_AWCACHE             ,   
	output reg  [2:0]              M00_AXI_AWPROT              ,   
	output reg  [3:0]              M00_AXI_AWQOS               ,	
	output reg  [3:0]              M00_AXI_AWREGION			   ,
    output reg  [USER_WIDTH-1:0]   M00_AXI_AWUSER			   ,
														  
	output reg  [DATA_WIDTH-1:0]   M00_AXI_WDATA               ,   
	output reg                     M00_AXI_WLAST               ,   
	output reg                     M00_AXI_WVALID              ,   
	input                          M00_AXI_WREADY              , 
	output reg  [STRB_WIDTH-1:0]   M00_AXI_WSTRB               , 
    output reg  [USER_WIDTH-1:0]   M00_AXI_WUSER			   ,	
							                           
	input 		[ID_WIDTH-1:0]   M00_AXI_BID                 ,   
	input 		[1:0]              M00_AXI_BRESP               ,   
	input 		                   M00_AXI_BVALID              ,   
	output reg	                   M00_AXI_BREADY              , 
	input 		[USER_WIDTH-1:0]   M00_AXI_BUSER				   
);

wire  s0_addr_ring	;
wire  s1_addr_ring	;
wire  s0_data_ring	;
wire  s1_data_ring	;
// arbiter_r arbiter_r(
// .I_clk		(i_clk)		,
// .I_rst		(i_rst)		,

// .s0_arvalid (S00_AXI_ARVALID)    ,
// .s0_rready	(S00_AXI_RREADY) 	  	,

// .s1_arvalid	(S01_AXI_ARVALID) 	  	,
// .s1_rready	(S01_AXI_RREADY) 	  	,

// .s0_rvalid	(S00_AXI_RVALID) 		,
// .s0_rlast	(S00_AXI_RLAST) 		,

// .s1_rvalid	(S01_AXI_RVALID) 		,
// .s1_rlast	(S01_AXI_RLAST) 		,

// .s0_ring	(s0_ring)   			,
// .s1_ring	(s1_ring)   			,
// );

assign   s0_addr_ring  =	S00_AXI_ARVALID && ~s1_addr_ring	;
assign	 s1_addr_ring  =	S01_AXI_ARVALID ;
assign	 s0_data_ring  =	M00_AXI_RVALID && (M00_AXI_RID == 'd0) ;
assign	 s1_data_ring  =	M00_AXI_RVALID && (M00_AXI_RID == 'd1) ;

//读地址和读数据
always@(*) begin
	case({s1_addr_ring,s0_addr_ring}) 
		2'b01:begin
			M00_AXI_ARADDR     =	 S00_AXI_ARADDR     ;
		    M00_AXI_ARVALID    =     S00_AXI_ARVALID    ;   
		    M00_AXI_ARLEN      =     S00_AXI_ARLEN      ;
		    M00_AXI_ARID       =     S00_AXI_ARID       ;
		    M00_AXI_ARSIZE     =     S00_AXI_ARSIZE     ;
		    M00_AXI_ARBURST    =     S00_AXI_ARBURST    ;
		    M00_AXI_ARLOCK     =     S00_AXI_ARLOCK     ;
		    M00_AXI_ARCACHE    =     S00_AXI_ARCACHE    ;
		    M00_AXI_ARPROT     =     S00_AXI_ARPROT     ;
		    M00_AXI_ARQOS      =     S00_AXI_ARQOS      ;
		    M00_AXI_ARREGION   =     S00_AXI_ARREGION   ;
		    M00_AXI_ARUSER	   =     S00_AXI_ARUSER		;
			//M00_AXI_RREADY	   =     S00_AXI_RREADY		;
			S00_AXI_ARREADY	   =	 M00_AXI_ARREADY	;
			S01_AXI_ARREADY	   =	 'b0				;
		end
		2'b10:begin
			M00_AXI_ARADDR     =	 S01_AXI_ARADDR     ;			
		    M00_AXI_ARVALID    =     S01_AXI_ARVALID    ;		
		    M00_AXI_ARLEN      =     S01_AXI_ARLEN      ;		
		    M00_AXI_ARID       =     S01_AXI_ARID       ;		
		    M00_AXI_ARSIZE     =     S01_AXI_ARSIZE     ;		
		    M00_AXI_ARBURST    =     S01_AXI_ARBURST    ;		
		    M00_AXI_ARLOCK     =     S01_AXI_ARLOCK     ;		
		    M00_AXI_ARCACHE    =     S01_AXI_ARCACHE    ;		
		    M00_AXI_ARPROT     =     S01_AXI_ARPROT     ;		
		    M00_AXI_ARQOS      =     S01_AXI_ARQOS      ;		
		    M00_AXI_ARREGION   =     S01_AXI_ARREGION   ;		
		    M00_AXI_ARUSER	   =     S01_AXI_ARUSER		;
			//M00_AXI_RREADY	   =     S01_AXI_RREADY		;
			S00_AXI_ARREADY	   =	 'b0				;
			S01_AXI_ARREADY	   =	 M00_AXI_ARREADY	;
		end
		default:begin
			M00_AXI_ARADDR     =	 'b0				;			
		    M00_AXI_ARVALID    =     'b0				;		
		    M00_AXI_ARLEN      =     'b0				;		
		    M00_AXI_ARID       =     'b0				;		
		    M00_AXI_ARSIZE     =     'b0				;		
		    M00_AXI_ARBURST    =     'b0				;		
		    M00_AXI_ARLOCK     =     'b0				;		
		    M00_AXI_ARCACHE    =     'b0				;		
		    M00_AXI_ARPROT     =     'b0				;		
		    M00_AXI_ARQOS      =     'b0				;		
		    M00_AXI_ARREGION   =     'b0				;		
		    M00_AXI_ARUSER	   =     'b0				;
			//M00_AXI_RREADY	   =     'b0				;
			S00_AXI_ARREADY	   =	 'b0				;
			S01_AXI_ARREADY	   =	 'b0				;
		end
	endcase
end

always@(*) begin
	case({s1_data_ring,s0_data_ring}) 
		4'b01:begin
			M00_AXI_RREADY	   =    S00_AXI_RREADY		;
		
			S00_AXI_RDATA  	   =	M00_AXI_RDATA 		;
			S00_AXI_RLAST      =    M00_AXI_RLAST		; 
			S00_AXI_RVALID     =    M00_AXI_RVALID		;
			S00_AXI_RID        =    M00_AXI_RID			;   
			S00_AXI_RRESP      =    M00_AXI_RRESP		; 
			S00_AXI_RUSER	   =    M00_AXI_RUSER		;
					
			S01_AXI_RDATA  	   =	'b0					;
			S01_AXI_RLAST      =    'b0					; 
			S01_AXI_RVALID     =    'b0					;
			S01_AXI_RID        =    'b0					;   
			S01_AXI_RRESP      =    'b0					; 
			S01_AXI_RUSER	   =    'b0					;
		end
		4'b10:begin
			M00_AXI_RREADY	   =    S01_AXI_RREADY		;
						
			S00_AXI_RDATA  	   =	'b0					;
			S00_AXI_RLAST      =    'b0					;
			S00_AXI_RVALID     =    'b0					;
			S00_AXI_RID        =    'b0					;
			S00_AXI_RRESP      =    'b0					;
			S00_AXI_RUSER	   =    'b0					;	
			
			S01_AXI_RDATA  	   =	M00_AXI_RDATA 		;
			S01_AXI_RLAST      =    M00_AXI_RLAST		;
			S01_AXI_RVALID     =    M00_AXI_RVALID		;
			S01_AXI_RID        =    M00_AXI_RID			;
			S01_AXI_RRESP      =    M00_AXI_RRESP		;
			S01_AXI_RUSER	   =    M00_AXI_RUSER		;
		end
		default:begin
			M00_AXI_RREADY	   =	'b0					;
			
			S00_AXI_RDATA  	   =	'b0					;		
			S00_AXI_RLAST      =    'b0					;		
			S00_AXI_RVALID     =    'b0					;		
			S00_AXI_RID        =    'b0					;		
			S00_AXI_RRESP      =    'b0					;		
			S00_AXI_RUSER	   =    'b0					;		
						            
			S01_AXI_RDATA  	   =	'b0					;		
			S01_AXI_RLAST      =    'b0					;		
			S01_AXI_RVALID     =    'b0					;		
			S01_AXI_RID        =    'b0					;		
			S01_AXI_RRESP      =    'b0					;		
			S01_AXI_RUSER	   =    'b0					;
		end                         					
	endcase
end

//写地址和写数据、写相应
always@(*) begin
			M00_AXI_AWADDR 	   = 	S01_AXI_AWADDR      ;
	        M00_AXI_AWVALID    =    S01_AXI_AWVALID     ;
            M00_AXI_AWLEN      =    S01_AXI_AWLEN       ;
            M00_AXI_AWID       =    S01_AXI_AWID        ;
            M00_AXI_AWSIZE     =    S01_AXI_AWSIZE      ;
            M00_AXI_AWBURST    =    S01_AXI_AWBURST     ;
		    M00_AXI_AWLOCK     =    S01_AXI_AWLOCK      ;
		    M00_AXI_AWCACHE    =    S01_AXI_AWCACHE     ;
		    M00_AXI_AWPROT     =    S01_AXI_AWPROT      ;
		    M00_AXI_AWQOS      =    S01_AXI_AWQOS       ;
		    M00_AXI_AWREGION   =    S01_AXI_AWREGION    ;
		    M00_AXI_AWUSER	   =    S01_AXI_AWUSER	    ;
			S01_AXI_AWREADY    =    M00_AXI_AWREADY     ;
													    
		    M00_AXI_WDATA      =    S01_AXI_WDATA       ;
		    M00_AXI_WLAST      =    S01_AXI_WLAST       ;
		    M00_AXI_WVALID     =    S01_AXI_WVALID      ;
		    M00_AXI_WSTRB      =    S01_AXI_WSTRB       ;
		    M00_AXI_WUSER	   =    S01_AXI_WUSER	    ;
			S01_AXI_WREADY     =    M00_AXI_WREADY      ;
			
			S01_AXI_BID    	   =	M00_AXI_BID    		;
			S01_AXI_BRESP      =	M00_AXI_BRESP       ;
			S01_AXI_BVALID     =	M00_AXI_BVALID      ;
			S01_AXI_BUSER	   =	M00_AXI_BUSER	    ;
			M00_AXI_BREADY     =	S01_AXI_BREADY      ;
end
endmodule
			
