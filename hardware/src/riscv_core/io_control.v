module io_control #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115200
) (
    input clk,
    input rst,
    input en,
    input we,
    input [7:0] addr,
    input [31:0] din,
    input iflag,

    output reg [31:0] dout,

    input serial_in,
    output serial_out
);

    reg counter_rst;
    wire [31:0] cycle_count;
    cycle_counter u_cycle_counter (.clk(clk), .rst(counter_rst), .count(cycle_count));

    wire [31:0] instruction_count;
    instruction_counter u_instruction_counter (.clk(clk), .rst(counter_rst), .iflag(iflag), .count(instruction_count));

    reg [7:0] uart_din;
    reg data_in_valid, data_out_ready;
    wire data_in_ready, data_out_valid;
    wire [7:0] uart_dout;
    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_uart (
        .clk(clk), .reset(rst),
        .data_in(uart_din), .data_in_ready(data_in_ready), .data_in_valid(data_in_valid),
        .data_out(uart_dout), .data_out_valid(data_out_valid), .data_out_ready(data_out_ready),
        .serial_in(serial_in), .serial_out(serial_out)
    );

    always @(*) begin
        if (en) begin
            counter_rst = (addr == 8'h18) | rst;
            case (addr)
            8'h00: begin
                dout = { 30'b0, data_out_valid, data_in_ready };
                uart_din = 8'b0;
                data_out_ready = 1'b0;
                data_in_valid = 1'b0;
            end
            8'h04: begin
                dout = { 24'b0, uart_dout };
                uart_din = 8'b0;
                data_out_ready = 1'b1;
                data_in_valid = 1'b0;
            end
            8'h08: begin
                dout = 32'b0;
                uart_din = din[7:0];
                data_out_ready = 1'b0;
                data_in_valid = we;
            end
            8'h10: begin
                dout = cycle_count;
                uart_din = 8'b0;
                data_out_ready = 1'b0;
                data_in_valid = 1'b0;
            end
            8'h14: begin
                dout = instruction_count;
                uart_din = 8'b0;
                data_out_ready = 1'b0;
                data_in_valid = 1'b0;
            end
            default: begin
                dout = 32'b0;
                uart_din = 8'b0;
                data_out_ready = 1'b0;
                data_in_valid = 1'b0;
            end
            endcase
        end
        else begin
            counter_rst = 1'b0;
            dout = 32'b0;
            uart_din = 8'b0;
            data_out_ready = 1'b0;
            data_in_valid = 1'b0;
        end
    end

endmodule