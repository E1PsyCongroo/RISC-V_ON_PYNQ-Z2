module instruction_counter (
    input clk,
    input rst,
    input iflag,

    output reg[31:0] count
);

    always @(posedge clk) begin
        if (rst) begin
            count <= 32'b0;
        end
        else if (iflag) begin
            count <= count + 1;
        end
        else begin
            count <= count;
        end
    end

endmodule