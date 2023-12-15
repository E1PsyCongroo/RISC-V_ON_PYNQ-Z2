`include "opcode.vh"
module mem_control #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115200
) (
    input clk,
    input rst,
    input [31:0] pc_addr,
    input pc_m_30,
    input [31:0] alu_addr,
    input [2:0] mem_type,
    input mem_we,
    input [31:0] mem_win,
    input iflag,

    output reg [31:0] instruction,
    output reg [31:0] mem_data,

    input serial_in,
    output serial_out
);

    reg [31:0] mem_din;
    wire [31:0] bios_douta, bios_doutb;
    bios_mem u_bios (
        .clk(clk), .ena(1'b1), .addra(pc_addr[13:2]), .douta(bios_douta),
        .enb(1'b1), .addrb(alu_addr[13:2]), .doutb(bios_doutb)
    );

    wire [31:0] csr_reg;
    reg csr_we;
    csr_reg u_csr (
        .clk(clk), .we(csr_we), .din(mem_din), .dout(csr_reg)
    );

    reg dmem_en;
    wire [3:0] dmem_we;
    wire [31:0] dmem_dout;
    dmem u_dmem (
        .clk(clk), .en(dmem_en), .we(dmem_we), .addr(alu_addr[15:2]), .din(mem_din), .dout(dmem_dout)
    );

    reg imem_ena;
    wire [3:0] imem_wea;
    reg [31:0] imem_doutb;
    imem u_imem (
        .clk(clk), .ena(imem_ena), .wea(imem_wea), .addra(alu_addr[15:2]), .dina(mem_din),
        .addrb(pc_addr[15:2]), .doutb(imem_doutb)
    );

    reg io_we, io_en;
    reg [31:0] io_dout;
    io_control #(
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_io_control (
        .clk(clk), .rst(rst), .en(io_en), .we(io_we), .addr(alu_addr[7:0]), .din(mem_din), .iflag(iflag),
        .dout(io_dout),
        .serial_in(serial_in), .serial_out(serial_out)
    );

    // PC Addr
    always @(*) begin
        case(pc_addr[31:28])
        4'b0001: begin
            instruction = imem_doutb;
        end
        4'b0100: begin
            instruction = bios_douta;
        end
        default: begin
            instruction = `NOP;
        end
        endcase
    end

    // ALU Addr
    reg [31:0] read_data;
    reg [3:0] mem_mask;
    wire [4:0] index;
    assign index = { 3'b0, alu_addr[1:0] } << 5'd3;
    always @(*) begin
        case(mem_type)
        `mem_w: begin
            mem_data = read_data;
            mem_mask = 4'b1111;
            mem_din = mem_win;
            csr_we = 1'b0;
        end
        `mem_h: begin
            mem_data = { { 16{ read_data[index + 15] } }, read_data[index +: 16] };
            mem_mask = 4'b0011 << alu_addr[1:0];
            mem_din = mem_win << index;
            csr_we = 1'b0;
        end
        `mem_hu: begin
            mem_data = { 16'b0, read_data[index +: 16] };
            mem_mask = 4'b0011 << alu_addr[1:0];
            mem_din = mem_win << index;
            csr_we = 1'b0;
        end
        `mem_b: begin
            mem_data = { { 24{read_data[index + 7] } }, read_data[index +: 8] };
            mem_mask = 4'b0001 << alu_addr[1:0];
            mem_din = mem_win << index;
            csr_we = 1'b0;
        end
        `mem_bu: begin
            mem_data = { 24'b0, read_data[index +: 8] };
            mem_mask = 4'b0001 << alu_addr[1:0];
            mem_din = mem_win << index;
            csr_we = 1'b0;
        end
        `mem_csr: begin
            mem_data = csr_reg;
            mem_mask = 4'b0;
            mem_din = mem_win;
            csr_we = mem_we;
        end
        default: begin
            mem_data = 32'b0;
            mem_mask = 4'b0;
            mem_din = 32'b0;
            csr_we = 1'b0;
        end
        endcase
    end

    assign dmem_we = mem_mask & { 4{mem_we} };
    assign imem_wea = mem_mask & { 4{mem_we} };

    always @(*) begin
        case(alu_addr[31:28])
        4'b0001: begin
            dmem_en = 1;
            imem_ena = 0;
            io_en = 0;
            io_we = 0;
            read_data = dmem_dout;
        end
        4'b0010: begin
            dmem_en = 0;
            imem_ena = pc_m_30 & mem_we;
            io_en = 0;
            io_we = 0;
            read_data = 32'b0;
        end
        4'b0011: begin
            dmem_en = 1;
            imem_ena = pc_m_30 & mem_we;
            io_en = 0;
            io_we = 0;
            read_data = dmem_dout;
        end
        4'b0100: begin
            dmem_en = 0;
            imem_ena = 0;
            io_en = 0;
            io_we = 0;
            read_data = bios_doutb;
        end
        4'b1000: begin
            dmem_en = 0;
            imem_ena = 0;
            io_en = 1;
            io_we = mem_we;
            read_data = io_dout;
        end
        default: begin
            dmem_en = 0;
            imem_ena = 0;
            io_en = 1;
            io_we = 0;
            read_data = 32'b0;
        end
        endcase
    end

endmodule