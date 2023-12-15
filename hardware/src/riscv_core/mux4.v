module mux4 #(parameter WIDTH=32) (
    input [1:0] sel,
    input [WIDTH-1:0] ina, inb, inc, ind,
    output [WIDTH-1:0] out
);
    wire [WIDTH-1:0] out1, out2;
    mux2 #(.WIDTH(WIDTH)) select1 (.sel(sel[0]), .ina(ina), .inb(inb), .out(out1));
    mux2 #(.WIDTH(WIDTH)) select2 (.sel(sel[0]), .ina(inc), .inb(ind), .out(out2));
    mux2 #(.WIDTH(WIDTH)) select3 (.sel(sel[1]), .ina(out1), .inb(out2), .out(out));
endmodule