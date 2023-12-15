`include "opcode.vh"
module pipeline1 (
    input clk,
    input flush,
    input keep,
    input [31:0] instruction_i,
    input [31:0] pc_i,
    input [31:0] pc_plus4_i,

    output reg [31:0] instruction_r,
    output reg [31:0] pc_r,
    output reg [31:0] pc_plus4_r
);
    always @(negedge clk) begin
        if (flush) begin
            instruction_r <= `NOP;
            pc_r <= 32'b0;
            pc_plus4_r <= 32'b0;
        end
        else if (keep) begin
            instruction_r <= instruction_r;
            pc_r <= pc_r;
            pc_plus4_r <= pc_plus4_r;
        end
        else begin
            instruction_r <= instruction_i;
            pc_r <= pc_i;
            pc_plus4_r <= pc_plus4_i;
        end
    end

endmodule