module pc #(
    parameter RESET_PC = 32'h4000_0000
) (
    input clk,
    input rst,
    input keep,
    input [31:0] pc_next,

    output reg [31:0] pc
);

    always @(posedge clk) begin
        if (rst) begin
            pc <= RESET_PC;
        end
        else if (keep) begin
            pc <= pc;
        end
        else begin
            pc <= pc_next;
        end
    end
endmodule