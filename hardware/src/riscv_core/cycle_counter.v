module cycle_counter (
    input clk,
    input rst,

    output reg [31:0] count
);

    always @(posedge clk) begin
        if (rst) begin
            count <= 32'b0;
        end
        else begin
            count <= count + 1;
        end
    end
endmodule