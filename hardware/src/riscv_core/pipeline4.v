module pipeline4 (
    input clk,
    input flush,
    input regfile_we_m,
    input [1:0] regfile_src_sel_m,
    input [31:0] pc_plus4_m,
    input [31:0] alu_result_m,
    input [31:0] mem_data_m,
    input [4:0] wa_m,

    output reg regfile_we_w,
    output reg [1:0] regfile_src_sel_w,
    output reg [31:0] pc_plus4_w,
    output reg [31:0] alu_result_w,
    output reg [31:0] mem_data_w,
    output reg [4:0] wa_w
);
    always @(negedge clk) begin
        if (flush) begin
            regfile_we_w <= 1'b0;
            regfile_src_sel_w <= 2'b0;
            pc_plus4_w <= 32'b0;
            alu_result_w <= 32'b0;
            mem_data_w <= 32'b0;
            wa_w <= 5'b0;
        end
        else begin
            regfile_we_w <= regfile_we_m;
            regfile_src_sel_w <= regfile_src_sel_m;
            pc_plus4_w <= pc_plus4_m;
            alu_result_w <= alu_result_m;
            mem_data_w <= mem_data_m;
            wa_w <= wa_m;
        end
    end
endmodule