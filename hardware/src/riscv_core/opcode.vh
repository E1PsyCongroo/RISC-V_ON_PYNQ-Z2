// List of RISC-V opcodes and funct codes.
// Use `include "opcode.vh" to use these in the decoder

`ifndef OPCODE
`define OPCODE

// NOP instruction
`define NOP 32'b0000_0000_0000_0000_0000_0000_0001_0011

// ***** Opcodes *****
// CSR instructions
`define OPC_CSR 7'b1110011

// Special immediate instructions
`define OPC_LUI         7'b0110111
`define OPC_AUIPC       7'b0010111

// Jump instructions
`define OPC_JAL         7'b1101111
`define OPC_JALR        7'b1100111

// Branch instructions
`define OPC_BRANCH      7'b1100011

// Load and store instructions
`define OPC_STORE       7'b0100011
`define OPC_LOAD        7'b0000011

// Arithmetic instructions
`define OPC_ARI_RTYPE   7'b0110011
`define OPC_ARI_ITYPE   7'b0010011

// ***** 5-bit Opcodes *****
`define OPC_LUI_5       5'b01101
`define OPC_AUIPC_5     5'b00101
`define OPC_JAL_5       5'b11011
`define OPC_JALR_5      5'b11001
`define OPC_BRANCH_5    5'b11000
`define OPC_STORE_5     5'b01000
`define OPC_LOAD_5      5'b00000
`define OPC_ARI_RTYPE_5 5'b01100
`define OPC_ARI_ITYPE_5 5'b00100
`define OPC_CSR_5       5'b11100

// ***** Function codes *****

// Branch function codes
`define FNC_BEQ         3'b000
`define FNC_BNE         3'b001
`define FNC_BLT         3'b100
`define FNC_BGE         3'b101
`define FNC_BLTU        3'b110
`define FNC_BGEU        3'b111

// Load and store function codes
`define FNC_LB          3'b000
`define FNC_LH          3'b001
`define FNC_LW          3'b010
`define FNC_LBU         3'b100
`define FNC_LHU         3'b101
`define FNC_SB          3'b000
`define FNC_SH          3'b001
`define FNC_SW          3'b010

// Arithmetic R-type and I-type functions codes
`define FNC_ADD_SUB     3'b000
`define FNC_SLL         3'b001
`define FNC_SLT         3'b010
`define FNC_SLTU        3'b011
`define FNC_XOR         3'b100
`define FNC_OR          3'b110
`define FNC_AND         3'b111
`define FNC_SRL_SRA     3'b101

// ADD and SUB use the same opcode + function code
// SRA and SRL also use the same opcode + function code
// For these operations, we also need to look at bit 30 of the instruction
`define FNC2_ADD        1'b0
`define FNC2_SUB        1'b1
`define FNC2_SRL        1'b0
`define FNC2_SRA        1'b1

`define FNC7_0  7'b0000000 // ADD, SRL
`define FNC7_1  7'b0100000 // SUB, SRA
`endif //OPCODE

// ALU Control

`define add_op  3'b000
`define sub_op  4'b0001
`define sll_op  3'b001
`define slt_op  3'b010
`define sltu_op 3'b011
`define xor_op  3'b100
`define srl_op  3'b101
`define sra_op  4'b1011
`define or_op   3'b110
`define and_op  3'b111
`define srcb_op 4'b1111

// Imm Type

`define i_type  3'b000
`define s_type  3'b001
`define b_type  3'b010
`define u_type  3'b011
`define j_type  3'b100

// Branch Type

`define branch_eq   3'b000
`define branch_ne   3'b001
`define branch_lt   3'b100
`define branch_ge   3'b101
`define branch_ltu  3'b110
`define branch_geu  3'b111

// Mem Type

`define mem_b   3'b000
`define mem_h   3'b001
`define mem_w   3'b010
`define mem_bu  3'b100
`define mem_hu  3'b101
`define mem_csr 3'b111

// Reg Src

`define reg_alu 2'b00
`define reg_mem 2'b01
`define reg_pc  2'b10

// Mem Src

`define mem_rd2 2'b00
`define mem_rd1 2'b10
`define mem_uimm 2'b11