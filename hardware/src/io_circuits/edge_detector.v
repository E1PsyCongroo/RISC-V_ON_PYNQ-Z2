module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge

    // Remove this line once you create your edge detector
    reg [WIDTH-1:0] cur_signal = 0, pre_signal = 0;
    always @(posedge clk) begin
        pre_signal <= cur_signal;
        cur_signal <= signal_in;
    end
    assign edge_detect_pulse = ~pre_signal & cur_signal;
endmodule
