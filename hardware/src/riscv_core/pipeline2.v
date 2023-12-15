module pipeline2 (
    input clk,
    input flush,
    input alu_srca_sel_r,
    input alu_srcb_sel_r,
    input [3:0] alu_control_r,
    input jump_r,
    input branch_r,
    input [2:0] branch_type_r,
    input [1:0] mem_src_sel_r,
    input [2:0] mem_type_r,
    input mem_we_r,
    input regfile_we_r,
    input [1:0] regfile_src_sel_r,
    input iflag_r,
    input [31:0] pc_r,
    input [31:0] pc_plus4_r,
    input [31:0] imm_result_r,
    input [31:0] rd1_r,
    input [31:0] rd2_r,
    input [4:0] ra1_r,
    input [4:0] ra2_r,
    input [4:0] wa_r,

    output reg alu_srca_sel_e,
    output reg alu_srcb_sel_e,
    output reg [3:0] alu_control_e,
    output reg jump_e,
    output reg branch_e,
    output reg [2:0] branch_type_e,
    output reg [1:0] mem_src_sel_e,
    output reg [2:0] mem_type_e,
    output reg mem_we_e,
    output reg regfile_we_e,
    output reg [1:0] regfile_src_sel_e,
    output reg iflag_e,
    output reg [31:0] pc_e,
    output reg [31:0] pc_plus4_e,
    output reg [31:0] imm_result_e,
    output reg [31:0] rd1_e,
    output reg [31:0] rd2_e,
    output reg [4:0] ra1_e,
    output reg [4:0] ra2_e,
    output reg [4:0] wa_e
);

    always @(negedge clk) begin
        if (flush) begin
            alu_srca_sel_e <= 1'b0;
            alu_srcb_sel_e <= 1'b0;
            alu_control_e <= 4'b0;
            jump_e <= 1'b0;
            branch_e <= 1'b0;
            branch_type_e <= 3'b0;
            mem_src_sel_e <= 2'b0;
            mem_type_e <= 3'b0;
            mem_we_e <= 1'b0;
            regfile_we_e <= 1'b0;
            regfile_src_sel_e <= 2'b0;
            iflag_e <= 1'b0;
            pc_e <= 32'b0;
            pc_plus4_e <= 32'b0;
            imm_result_e <= 32'b0;
            rd1_e <= 32'b0;
            rd2_e <= 32'b0;
            ra1_e <= 5'b0;
            ra2_e <= 5'b0;
            wa_e <= 5'b0;
        end
        else begin
            alu_srca_sel_e <= alu_srca_sel_r;
            alu_srcb_sel_e <= alu_srcb_sel_r;
            alu_control_e <= alu_control_r;
            jump_e <= jump_r;
            branch_e <= branch_r;
            branch_type_e <= branch_type_r;
            mem_src_sel_e <= mem_src_sel_r;
            mem_type_e <= mem_type_r;
            mem_we_e <= mem_we_r;
            regfile_we_e <= regfile_we_r;
            regfile_src_sel_e <= regfile_src_sel_r;
            iflag_e <= iflag_r;
            pc_e <= pc_r;
            pc_plus4_e <= pc_plus4_r;
            imm_result_e <= imm_result_r;
            rd1_e <= rd1_r;
            rd2_e <= rd2_r;
            ra1_e <= ra1_r;
            ra2_e <= ra2_r;
            wa_e <= wa_r;
        end
    end

endmodule