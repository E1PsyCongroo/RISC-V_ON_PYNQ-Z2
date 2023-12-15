`include "opcode.vh"
module decoder (
    input [31:0] instruction,

    output reg alu_srca_sel,
    output reg alu_srcb_sel,
    output reg [3:0] alu_control,
    output reg [2:0] imm_type,
    output reg jump,
    output reg branch,
    output reg [2:0] branch_type,
    output reg [1:0] mem_src_sel,
    output reg [2:0] mem_type,
    output reg mem_we,
    output reg regfile_we,
    output reg [1:0] regfile_src_sel,
    output iflag
);
    wire [6:0] opcode;
    wire [4:0] opcode_5;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    assign opcode = instruction[6:0];
    assign opcode_5 = opcode[6:2];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 =instruction[24:20];
    assign funct7 = instruction[31:25];

    always @(*) begin
        alu_srca_sel = (opcode_5 == `OPC_BRANCH_5 || opcode_5 == `OPC_AUIPC_5 || opcode_5 == `OPC_LUI_5 || opcode_5 == `OPC_JAL_5);
        alu_srcb_sel = ~(opcode[5] & opcode[4] & ~opcode[2]);
        jump = opcode[6] & opcode[2];
        branch = (opcode_5 == `OPC_BRANCH_5);
        branch_type = funct3;
        mem_src_sel = (opcode_5 == `OPC_STORE_5 ? `mem_rd2 : { 1'b1, funct3[2] });
        mem_type = (opcode_5 == `OPC_CSR_5 ? `mem_csr : funct3);
        mem_we = (opcode_5 == `OPC_STORE_5 || opcode_5 == `OPC_CSR_5);
        regfile_we = ~(opcode_5 == `OPC_STORE_5 || opcode_5 == `OPC_BRANCH_5);
        case (opcode_5)
        `OPC_ARI_RTYPE_5:   begin
            alu_control = { funct3[2:0], funct7[5] };
            imm_type = `i_type;
            regfile_src_sel = `reg_alu;
        end
        `OPC_LOAD_5:        begin
            alu_control = { `add_op, 1'b0 };
            imm_type = `i_type;
            regfile_src_sel = `reg_mem;
        end
        `OPC_ARI_ITYPE_5:   begin
            alu_control = { funct3[2:0], (funct3 == `srl_op ? funct7[5] : 1'b0) };
            imm_type = `i_type;
            regfile_src_sel = `reg_alu;
        end
        `OPC_STORE_5:       begin
            alu_control = { `add_op, 1'b0 };
            imm_type = `s_type;
            regfile_src_sel = `reg_alu;
        end
        `OPC_BRANCH_5:      begin
            alu_control = { `add_op, 1'b0 };
            imm_type = `b_type;
            regfile_src_sel = `reg_alu;
        end
        `OPC_AUIPC_5:       begin
            alu_control = { `add_op, 1'b0 };
            imm_type = `u_type;
            regfile_src_sel = `reg_alu;
        end
        `OPC_LUI_5:         begin
            alu_control = `srcb_op;
            imm_type = `u_type;
            regfile_src_sel = `reg_alu;
        end
        `OPC_JAL_5:         begin
            alu_control = { `add_op, 1'b0 };
            imm_type = `j_type;
            regfile_src_sel = `reg_pc;
        end
        `OPC_JALR_5:        begin
            alu_control = { `add_op, 1'b0 };
            imm_type = `i_type;
            regfile_src_sel = `reg_pc;
        end
        `OPC_CSR_5:         begin
            alu_control = { `add_op, 1'b0 };
            imm_type = `i_type;
            regfile_src_sel = `reg_mem;
        end
        default:            begin
            alu_control = { `add_op, 1'b0 };
            imm_type = `i_type;
            regfile_src_sel = `reg_alu;
        end
        endcase
    end

    assign iflag = 1'b1;

endmodule