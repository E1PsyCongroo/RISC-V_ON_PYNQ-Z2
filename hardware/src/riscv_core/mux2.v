module mux2 #(parameter WIDTH=32) (
    input sel,
    input [WIDTH-1:0] ina, inb,
    output [WIDTH-1:0] out
);
    assign out = sel ? inb : ina;
endmodule