/// register file
`include "top_defines.v"
module riscv_rf #(
    parameter   DATA_WIDTH  = -1,
    parameter   ADDR_WIDTH  = -1
) (
    input   	                      clk,

    input  		  [ADDR_WIDTH-1:0]    rd1_addr,
    input  		                      rd1_en,
    output 	reg	  [DATA_WIDTH-1:0]    rd1_data,   
		
    input  		  [ADDR_WIDTH-1:0]    rd2_addr,
    input  		                      rd2_en,
    output 	reg	  [DATA_WIDTH-1:0]    rd2_data,   
		
	input  		  [ADDR_WIDTH-1:0]    rd3_addr,
    input  		                      rd3_en,
    output 	reg	  [DATA_WIDTH-1:0]    rd3_data,   
			
    input  		  [ADDR_WIDTH-1:0]    wr_addr,
    input  		                      wr_en,
    input  		  [DATA_WIDTH-1:0]    wr_data,
    output        [DATA_WIDTH-1:0]    o_rf_0  ,
    output        [DATA_WIDTH-1:0]    o_rf_1  ,
    output        [DATA_WIDTH-1:0]    o_rf_2  ,
    output        [DATA_WIDTH-1:0]    o_rf_3  , 
    output        [DATA_WIDTH-1:0]    o_rf_4  ,
    output        [DATA_WIDTH-1:0]    o_rf_5  ,  
    output        [DATA_WIDTH-1:0]    o_rf_6  ,
    output        [DATA_WIDTH-1:0]    o_rf_7  ,
    output        [DATA_WIDTH-1:0]    o_rf_8  ,
    output        [DATA_WIDTH-1:0]    o_rf_9  , 
    output        [DATA_WIDTH-1:0]    o_rf_10 ,
    output        [DATA_WIDTH-1:0]    o_rf_11 ,  
    output        [DATA_WIDTH-1:0]    o_rf_12 ,
    output        [DATA_WIDTH-1:0]    o_rf_13 ,
    output        [DATA_WIDTH-1:0]    o_rf_14 ,
    output        [DATA_WIDTH-1:0]    o_rf_15 , 
    output        [DATA_WIDTH-1:0]    o_rf_16 ,
    output        [DATA_WIDTH-1:0]    o_rf_17 ,  
    output        [DATA_WIDTH-1:0]    o_rf_18 ,
    output        [DATA_WIDTH-1:0]    o_rf_19 ,
    output        [DATA_WIDTH-1:0]    o_rf_20 ,
    output        [DATA_WIDTH-1:0]    o_rf_21 , 
    output        [DATA_WIDTH-1:0]    o_rf_22 ,
    output        [DATA_WIDTH-1:0]    o_rf_23 , 
    output        [DATA_WIDTH-1:0]    o_rf_24 ,
    output        [DATA_WIDTH-1:0]    o_rf_25 ,  
    output        [DATA_WIDTH-1:0]    o_rf_26 ,
    output        [DATA_WIDTH-1:0]    o_rf_27 ,
    output        [DATA_WIDTH-1:0]    o_rf_28 ,
    output        [DATA_WIDTH-1:0]    o_rf_29 , 
    output        [DATA_WIDTH-1:0]    o_rf_30 ,
    output        [DATA_WIDTH-1:0]    o_rf_31 
);

    reg   [DATA_WIDTH-1:0]    rf  [2**ADDR_WIDTH-1:0];    // register file

    assign o_rf_0   = rf[0 ] ;
    assign o_rf_1   = rf[1 ] ;
    assign o_rf_2   = rf[2 ] ;
    assign o_rf_3   = rf[3 ] ;
    assign o_rf_4   = rf[4 ] ;
    assign o_rf_5   = rf[5 ] ;
    assign o_rf_6   = rf[6 ] ;
    assign o_rf_7   = rf[7 ] ; 
    assign o_rf_8   = rf[8 ] ;
    assign o_rf_9   = rf[9 ] ;
    assign o_rf_10  = rf[10] ;
    assign o_rf_11  = rf[11] ;
    assign o_rf_12  = rf[12] ;
    assign o_rf_13  = rf[13] ;
    assign o_rf_14  = rf[14] ;
    assign o_rf_15  = rf[15] ;
    assign o_rf_16  = rf[16] ;
    assign o_rf_17  = rf[17] ;
    assign o_rf_18  = rf[18] ;
    assign o_rf_19  = rf[19] ;
    assign o_rf_20  = rf[20] ;
    assign o_rf_21  = rf[21] ;
    assign o_rf_22  = rf[22] ;
    assign o_rf_23  = rf[23] ; 
    assign o_rf_24  = rf[24] ;
    assign o_rf_25  = rf[25] ;
    assign o_rf_26  = rf[26] ;
    assign o_rf_27  = rf[27] ;
    assign o_rf_28  = rf[28] ;
    assign o_rf_29  = rf[29] ;
    assign o_rf_30  = rf[30] ;
    assign o_rf_31  = rf[31] ;  

    always @(*) begin
        if (rd1_en) begin
            if((rd1_addr == wr_addr) && wr_en)begin
                rd1_data = wr_data;
            end
            else rd1_data = rf[rd1_addr];
        end
    end

    always @(*) begin
        if (rd2_en) begin
            if((rd2_addr == wr_addr) && wr_en)begin
                rd2_data = wr_data;
            end
            else rd2_data = rf[rd2_addr];
        end
    end

	always @(*) begin
        if (rd3_en) begin
            if((rd3_addr == wr_addr) && wr_en)begin
                rd3_data = wr_data;
            end
            else rd3_data = rf[rd3_addr];
        end
    end
	
    always @(posedge clk) begin
        if (wr_en) begin
            rf[wr_addr] <= wr_data;
        end
    end

endmodule