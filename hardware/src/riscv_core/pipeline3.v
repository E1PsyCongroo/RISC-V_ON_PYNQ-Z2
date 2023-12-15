module pipeline3 (
    input clk,
    input flush,
    input [1:0] mem_src_sel_e,
    input [2:0] mem_type_e,
    input mem_we_e,
    input regfile_we_e,
    input [1:0] regfile_src_sel_e,
    input iflag_e,
    input pc_e_30,
    input [31:0] pc_plus4_e,
    input [31:0] alu_result_e,
    input [31:0] rd1_e,
    input [31:0] rd2_e,
    input [4:0] wa_e,
    input [4:0] ra1_e,

    output reg [1:0] mem_src_sel_m,
    output reg [2:0] mem_type_m,
    output reg mem_we_m,
    output reg regfile_we_m,
    output reg [1:0] regfile_src_sel_m,
    output reg iflag_m,
    output reg pc_m_30,
    output reg [31:0] pc_plus4_m,
    output reg [31:0] alu_result_m,
    output reg [31:0] rd1_m,
    output reg [31:0] rd2_m,
    output reg [4:0] wa_m,
    output reg [4:0] ra1_m
);
    always @(negedge clk) begin
        if (flush) begin
            mem_src_sel_m <= 2'b0;
            mem_type_m <= 3'b0;
            mem_we_m <= 1'b0;
            regfile_we_m <= 1'b0;
            regfile_src_sel_m <= 2'b0;
            iflag_m <= 1'b0;
            pc_m_30 <= 1'b0;
            pc_plus4_m <= 32'b0;
            alu_result_m <= 32'b0;
            rd1_m <= 32'b0;
            rd2_m <= 32'b0;
            wa_m <= 5'b0;
            ra1_m <= 5'b0;
        end
        else begin
            mem_src_sel_m <= mem_src_sel_e;
            mem_type_m <= mem_type_e;
            mem_we_m <= mem_we_e;
            regfile_we_m <= regfile_we_e;
            regfile_src_sel_m <= regfile_src_sel_e;
            iflag_m <= iflag_e;
            pc_m_30 <= pc_e_30;
            pc_plus4_m <= pc_plus4_e;
            alu_result_m <= alu_result_e;
            rd1_m <= rd1_e;
            rd2_m <= rd2_e;
            wa_m <= wa_e;
            ra1_m <= ra1_e;
        end
    end
endmodule