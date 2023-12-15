`include "opcode.vh"
module alu(
    input [31:0] srca, srcb,
    input [3:0] op,
    output reg[31:0] result
);
    always @(*) begin
        case (op[3:1])
            `add_op: begin
                case (op[0])
                1'b0: result = srca + srcb;
                1'b1: result = srca - srcb;
                endcase
            end
            `sll_op: result = srca << srcb[4:0];
            `slt_op: result = $signed(srca) < $signed(srcb) ? 32'b1 : 32'b0;
            `sltu_op: result = $unsigned(srca) < $unsigned(srcb) ? 32'b1 : 32'b0;
            `xor_op: result = srca ^ srcb;
            `srl_op: begin
                case (op[0])
                1'b0: result = srca >> srcb[4:0];
                1'b1: result = $signed(srca) >>> srcb[4:0];
                endcase
            end
            `or_op: result = srca | srcb;
            `and_op: begin
                case (op[0])
                1'b0: result = srca & srcb;
                1'b1: result = srcb;
                endcase
            end
            default: result = 32'b0;
        endcase
    end
endmodule