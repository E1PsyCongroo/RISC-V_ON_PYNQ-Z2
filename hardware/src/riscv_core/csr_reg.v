module csr_reg (
    input clk,
    input we,
    input [31:0] din,

    output reg [31:0] dout
);

    always @(posedge clk) begin
        if (we) begin
            dout <= din;
        end
        else begin
            dout <= dout;
        end
    end

endmodule