`include "top_defines.v"
module riscv_alu_ctrl (
    input      		[2:0]   alu_op,
    input      		[3:0]   func_code,
    output  reg   	[3:0]   alu_ctrl
);

    //always_comb begin
    //    case ({alu_op, func_code})
    //        6'b10_0000  : alu_ctrl = 4'b0010;   // add
    //        6'b10_0010  : alu_ctrl = 4'b0110;   // sub
    //        6'b10_0100  : alu_ctrl = 4'b0000;   // and
    //        6'b10_0101  : alu_ctrl = 4'b0001;   // or
    //        6'b10_0111  : alu_ctrl = 4'b1100;   // nor
    //        6'b10_1010  : alu_ctrl = 4'b0111;   // slt
    //        default     : alu_ctrl = 4'b1111;
    //    endcase
    //end

    // assign alu_ctrl[3] = 1'b0;
    // assign alu_ctrl[2] = (~alu_op[1] & alu_op[0]) | (alu_op[1] & func_code[1]);
    // assign alu_ctrl[1] = ~alu_op[1] | ~func_code[2];
    // assign alu_ctrl[0] = (alu_op[1] & func_code[0]) | (alu_op[1] & func_code[3]);
	always@(*) begin
		if(alu_op == 3'b000)
			alu_ctrl = 4'b0000;
		else if(alu_op == 3'b001)
			alu_ctrl = 4'b1000;
		else if(alu_op == 3'b010)
			case(func_code)
				4'b0000 : alu_ctrl = 4'b0000;   // add
				4'b1000 : alu_ctrl = 4'b1000;   // sub
				4'b0001	: alu_ctrl = 4'b0001;	// sll
				4'b0010	: alu_ctrl = 4'b0010;	// slt1
				4'b0011	: alu_ctrl = 4'b0011;	// sltu
				4'b0100	: alu_ctrl = 4'b0100;	// xor
				4'b0101	: alu_ctrl = 4'b0101;	// srl
				4'b1101	: alu_ctrl = 4'b1101;	// sra
				4'b0110 : alu_ctrl = 4'b0110;   // or
				4'b0111 : alu_ctrl = 4'b0111;   // and
			default     : alu_ctrl = 4'b1111;
			endcase
		else if(alu_op == 3'b011)
			casez(func_code)
				4'b?000 : alu_ctrl = 4'b0000;   // add					
				4'b0001	: alu_ctrl = 4'b0001;	// sll			
				4'b?010	: alu_ctrl = 4'b0010;	// slt			
				4'b?011	: alu_ctrl = 4'b0011;	// sltu			
				4'b?100	: alu_ctrl = 4'b0100;	// xor			
				4'b0101	: alu_ctrl = 4'b0101;	// srl			
				4'b1101	: alu_ctrl = 4'b1101;	// sra			
				4'b?110 : alu_ctrl = 4'b0110;   // or			
				4'b?111 : alu_ctrl = 4'b0111;   // and			
			default     : alu_ctrl = 4'b1111;			
			endcase	
		else if(alu_op == 3'b110)
			case(func_code)
				4'b0000	: alu_ctrl = 4'b1001;	// addw
				4'b1000 : alu_ctrl = 4'b1010;	// subw
				4'b0001 : alu_ctrl = 4'b1011;	// sllw
				4'b0101 : alu_ctrl = 4'b1100;	// srlw
				4'b1101 : alu_ctrl = 4'b1110;	// sraw
			default		: alu_ctrl = 4'b1111;
			endcase
		else if(alu_op == 3'b111)
			case(func_code)
				4'b0000,4'b1000 : alu_ctrl = 4'b1001;	// addw
				4'b0001 : alu_ctrl = 4'b1011;	// sllw
				4'b0101 : alu_ctrl = 4'b1100;	// srlw
				4'b1101 : alu_ctrl = 4'b1110;	// sraw
			default		: alu_ctrl = 4'b1111;
			endcase	
		else
			alu_ctrl = 4'b1111;
	end
endmodule