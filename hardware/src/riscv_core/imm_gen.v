`include "opcode.vh"
module imm_gen (
    input [31:7] instruction,
    input [2:0] imm_type,

    output reg [31:0] imm_result
);
    always @(*) begin
        case (imm_type)
        `i_type: imm_result = { {20{instruction[31]}}, instruction[31:20] };
        `s_type: imm_result = { {20{instruction[31]}}, instruction[31:25], instruction[11:8], instruction[7] };
        `b_type: imm_result = { {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
        `u_type: imm_result = { instruction[31], instruction[30:20], instruction[19:12], 12'b0 };
        `j_type: imm_result = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:25], instruction[24:21], 1'b0 };
        default: imm_result = 32'b0;
        endcase
    end
endmodule