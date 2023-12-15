`include "opcode.vh"
module branch(
    input [31:0] rd1, rd2,
    input jump,
    input branch,
    input [2:0] branch_type,
    output reg pc_sel
);
    always @(*) begin
        if(jump) pc_sel = 1'b1;
        else if (branch) begin
            case (branch_type)
            `branch_eq: pc_sel = rd1 == rd2;
            `branch_ne: pc_sel = rd1 != rd2;
            `branch_lt: pc_sel = $signed(rd1) < $signed(rd2) ? 1'b1 : 1'b0;
            `branch_ge: pc_sel = $signed(rd1) < $signed(rd2) ? 1'b0 : 1'b1;
            `branch_ltu: pc_sel = $unsigned(rd1) < $unsigned(rd2) ? 1'b1 : 1'b0;
            `branch_geu: pc_sel = $unsigned(rd1) < $unsigned(rd2) ? 1'b0 : 1'b1;
            default: pc_sel = 1'b0;
            endcase
        end
        else pc_sel = 1'b0;
    end

endmodule