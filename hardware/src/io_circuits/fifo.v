module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 32,
    parameter POINTER_WIDTH = $clog2(DEPTH)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [WIDTH-1:0] din,
    output full,

    // Read side
    input rd_en,
    output [WIDTH-1:0] dout,
    output empty
);
    reg [WIDTH-1:0] stack_reg[DEPTH-1:0];
    reg [POINTER_WIDTH:0] read_pointer, write_pointer;
    reg [WIDTH-1:0] read_data;

    wire is_empty, is_full;
    assign is_empty = read_pointer == write_pointer;
    assign is_full = read_pointer[POINTER_WIDTH] != write_pointer[POINTER_WIDTH] && read_pointer[POINTER_WIDTH-1:0] == write_pointer[POINTER_WIDTH-1:0];

    always @(posedge clk) begin
        if (rst) begin
            read_pointer <= 0;
            write_pointer <= 0;
            read_data <= 0;
        end
        else begin
            if (wr_en && !full) begin
                stack_reg[write_pointer[POINTER_WIDTH-1:0]] <= din;
                if (write_pointer[POINTER_WIDTH-1:0] == DEPTH - 1) begin
                    write_pointer[POINTER_WIDTH] <= ~write_pointer[POINTER_WIDTH];
                    write_pointer[POINTER_WIDTH-1:0] <= 0;
                end
                else begin
                    write_pointer <= write_pointer + 1;
                end
            end
            if (rd_en && !empty) begin
                read_data <= stack_reg[read_pointer[POINTER_WIDTH-1:0]];
                if (read_pointer[POINTER_WIDTH-1:0] == DEPTH - 1) begin
                    read_pointer[POINTER_WIDTH] <= ~read_pointer[POINTER_WIDTH];
                    read_pointer[POINTER_WIDTH-1:0] <= 0;
                end
                else begin
                    read_pointer <= read_pointer + 1;
                end
            end
        end
    end

    assign full = is_full;
    assign empty = is_empty;
    assign dout = read_data;

endmodule
