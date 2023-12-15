module reg_file #(
    parameter DEPTH = 32
)(
    input clk,
    input we,
    input [4:0] ra1, ra2, wa,
    input [DEPTH-1:0] wd,
    output [DEPTH-1:0] rd1, rd2
);
    reg [DEPTH-1:0] mem [0:31];
    assign rd1 = mem[ra1];
    assign rd2 = mem[ra2];

    always @(posedge clk) begin
        if (we && (wa != 0)) begin
            mem[wa] <= wd;
        end
        mem[0] <= 32'b0;
    end
endmodule
