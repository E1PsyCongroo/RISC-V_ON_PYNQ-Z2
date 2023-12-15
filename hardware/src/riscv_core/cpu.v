module cpu #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 115200
) (
    input clk,
    input rst,
    input serial_in,
    output serial_out
);
    // // BIOS Memory
    // // Synchronous read: read takes one cycle
    // // Synchronous write: write takes one cycle
    // wire [11:0] bios_addra, bios_addrb;
    // wire [31:0] bios_douta, bios_doutb;
    // wire bios_ena, bios_enb;
    // bios_mem bios_mem (
    //   .clk(clk),
    //   .ena(bios_ena),
    //   .addra(bios_addra),
    //   .douta(bios_douta),
    //   .enb(bios_enb),
    //   .addrb(bios_addrb),
    //   .doutb(bios_doutb)
    // );

    // // Data Memory
    // // Synchronous read: read takes one cycle
    // // Synchronous write: write takes one cycle
    // // Write-byte-enable: select which of the four bytes to write
    // wire [13:0] dmem_addr;
    // wire [31:0] dmem_din, dmem_dout;
    // wire [3:0] dmem_we;
    // wire dmem_en;
    // dmem dmem (
    //   .clk(clk),
    //   .en(dmem_en),
    //   .we(dmem_we),
    //   .addr(dmem_addr),
    //   .din(dmem_din),
    //   .dout(dmem_dout)
    // );

    // // Instruction Memory
    // // Synchronous read: read takes one cycle
    // // Synchronous write: write takes one cycle
    // // Write-byte-enable: select which of the four bytes to write
    // wire [31:0] imem_dina, imem_doutb;
    // wire [13:0] imem_addra, imem_addrb;
    // wire [3:0] imem_wea;
    // wire imem_ena;
    // imem imem (
    //   .clk(clk),
    //   .ena(imem_ena),
    //   .wea(imem_wea),
    //   .addra(imem_addra),
    //   .dina(imem_dina),
    //   .addrb(imem_addrb),
    //   .doutb(imem_doutb)
    // );

    // // Register file
    // // Asynchronous read: read data is available in the same cycle
    // // Synchronous write: write takes one cycle
    // wire we;
    // wire [4:0] ra1, ra2, wa;
    // wire [31:0] wd;
    // wire [31:0] rd1, rd2;
    // reg_file rf (
    //     .clk(clk),
    //     .we(we),
    //     .ra1(ra1), .ra2(ra2), .wa(wa),
    //     .wd(wd),
    //     .rd1(rd1), .rd2(rd2)
    // );

    // // On-chip UART
    // //// UART Receiver
    // wire [7:0] uart_rx_data_out;
    // wire uart_rx_data_out_valid;
    // wire uart_rx_data_out_ready;
    // //// UART Transmitter
    // wire [7:0] uart_tx_data_in;
    // wire uart_tx_data_in_valid;
    // wire uart_tx_data_in_ready;
    // uart #(
    //     .CLOCK_FREQ(CPU_CLOCK_FREQ),
    //     .BAUD_RATE(BAUD_RATE)
    // ) on_chip_uart (
    //     .clk(clk),
    //     .reset(rst),

    //     .serial_in(serial_in),
    //     .data_out(uart_rx_data_out),
    //     .data_out_valid(uart_rx_data_out_valid),
    //     .data_out_ready(uart_rx_data_out_ready),

    //     .serial_out(serial_out),
    //     .data_in(uart_tx_data_in),
    //     .data_in_valid(uart_tx_data_in_valid),
    //     .data_in_ready(uart_tx_data_in_ready)
    // );

    // reg [31:0] tohost_csr = 0;

    // TODO: Your code to implement a fully functioning RISC-V core
    // Add as many modules as you want
    // Feel free to move the memory modules around

    // **Var Defination**
    // IF Stage
    reg [31:0] pc_i;
    wire [31:0] pc, pc_next, instruction_i, pc_plus4_i, alu_result_i;
    wire pc_sel_i;
    wire keep;

    assign pc_plus4_i = pc_i + 4;

    mux2 u_pc_mux (.sel(pc_sel_i), .ina(pc_plus4_i), .inb(alu_result_i), .out(pc_next));

    pc #(.RESET_PC(RESET_PC)) u_pc (.clk(clk), .rst(rst), .keep(keep), .pc_next(pc_next), .pc(pc));

    always @(negedge clk) begin
        if (rst) begin
            pc_i <= RESET_PC;
        end
        else begin
            pc_i <= pc;
        end
    end

    // ID Stage
    wire [31:0] instruction_r, pc_r, pc_plus4_r, imm_result_r, rd1_r, rd2_r;
    wire alu_srca_sel_r, alu_srcb_sel_r;
    wire [3:0] alu_control_r;
    wire [2:0] imm_type_r;
    wire jump_r, branch_r;
    wire [2:0] branch_type_r;
    wire [1:0] mem_src_sel_r;
    wire [2:0] mem_type_r;
    wire mem_we_r;
    wire regfile_we_r;
    wire [1:0] regfile_src_sel_r;
    wire iflag_r;
    wire [4:0] ra1_r, ra2_r, wa_r;
    wire [4:0] wa;
    wire regfile_we;
    wire [31:0] regfile_wd;
    wire [1:0] rd1_sel, rd2_sel;
    wire [31:0] data_forward1_input0, data_forward1_input1, data_forward1_input2, data_forward1_input3, data_forward1;
    wire [31:0] data_forward2_input0, data_forward2_input1, data_forward2_input2, data_forward2_input3, data_forward2;

    reg flush;
    pipeline1 u_pipeline1 (
        .clk(clk),
        .flush(rst | pc_sel_i),
        .keep(keep),
        .instruction_i(instruction_i),
        .pc_i(pc_i),
        .pc_plus4_i(pc_plus4_i),
        .instruction_r(instruction_r),
        .pc_r(pc_r),
        .pc_plus4_r(pc_plus4_r)
    );

    decoder u_decoder (
        .instruction(instruction_r),
        .alu_srca_sel(alu_srca_sel_r),
        .alu_srcb_sel(alu_srcb_sel_r),
        .alu_control(alu_control_r),
        .imm_type(imm_type_r),
        .jump(jump_r),
        .branch(branch_r),
        .branch_type(branch_type_r),
        .mem_src_sel(mem_src_sel_r),
        .mem_type(mem_type_r),
        .mem_we(mem_we_r),
        .regfile_we(regfile_we_r),
        .regfile_src_sel(regfile_src_sel_r),
        .iflag(iflag_r)
    );

    imm_gen u_imm_gen (
        .instruction(instruction_r[31:7]),
        .imm_type(imm_type_r),
        .imm_result(imm_result_r)
    );

    assign ra1_r = instruction_r[19:15];
    assign ra2_r = instruction_r[24:20];
    assign wa_r = instruction_r[11:7];
    reg_file u_reg_file (
        .clk(clk),
        .we(regfile_we),
        .ra1(ra1_r),
        .ra2(ra2_r),
        .wa(wa),
        .wd(regfile_wd),
        .rd1(rd1_r),
        .rd2(rd2_r)
    );

    assign data_forward1_input0 = rd1_r;
    assign data_forward2_input0 = rd2_r;

    mux4 u_dataforward1 (
        .sel(rd1_sel),
        .ina(data_forward1_input0),
        .inb(data_forward1_input1),
        .inc(data_forward1_input2),
        .ind(data_forward1_input3),
        .out(data_forward1)
    );

    mux4 u_dataforward2 (
        .sel(rd2_sel),
        .ina(data_forward2_input0),
        .inb(data_forward2_input1),
        .inc(data_forward2_input2),
        .ind(data_forward2_input3),
        .out(data_forward2)
    );


    // Ex Stage
    wire alu_srca_sel_e;
    wire alu_srcb_sel_e;
    wire [3:0] alu_control_e;
    wire jump_e;
    wire branch_e;
    wire [2:0] branch_type_e;
    wire [1:0] mem_src_sel_e;
    wire [2:0] mem_type_e;
    wire mem_we_e;
    wire regfile_we_e;
    wire [1:0] regfile_src_sel_e;
    wire iflag_e;
    wire [31:0] pc_e;
    wire [31:0] pc_plus4_e;
    wire [31:0] imm_result_e;
    wire [31:0] rd1_e;
    wire [31:0] rd2_e;
    wire [4:0] ra1_e;
    wire [4:0] ra2_e;
    wire [4:0] wa_e;
    wire [31:0] srca, srcb;
    wire [31:0] alu_result_e;
    wire pc_sel_e;

    pipeline2 u_pipeline2 (
        .clk(clk),
        .flush(rst | pc_sel_i | keep),
        .alu_srca_sel_r(alu_srca_sel_r),
        .alu_srcb_sel_r(alu_srcb_sel_r),
        .alu_control_r(alu_control_r),
        .jump_r(jump_r),
        .branch_r(branch_r),
        .branch_type_r(branch_type_r),
        .mem_src_sel_r(mem_src_sel_r),
        .mem_type_r(mem_type_r),
        .mem_we_r(mem_we_r),
        .regfile_we_r(regfile_we_r),
        .regfile_src_sel_r(regfile_src_sel_r),
        .iflag_r(iflag_r),
        .pc_r(pc_r),
        .pc_plus4_r(pc_plus4_r),
        .imm_result_r(imm_result_r),
        .rd1_r(data_forward1),
        .rd2_r(data_forward2),
        .ra1_r(ra1_r),
        .ra2_r(ra2_r),
        .wa_r(wa_r),
        .alu_srca_sel_e(alu_srca_sel_e),
        .alu_srcb_sel_e(alu_srcb_sel_e),
        .alu_control_e(alu_control_e),
        .jump_e(jump_e),
        .branch_e(branch_e),
        .branch_type_e(branch_type_e),
        .mem_src_sel_e(mem_src_sel_e),
        .mem_type_e(mem_type_e),
        .mem_we_e(mem_we_e),
        .regfile_we_e(regfile_we_e),
        .regfile_src_sel_e(regfile_src_sel_e),
        .iflag_e(iflag_e),
        .pc_e(pc_e),
        .pc_plus4_e(pc_plus4_e),
        .imm_result_e(imm_result_e),
        .rd1_e(rd1_e),
        .rd2_e(rd2_e),
        .ra1_e(ra1_e),
        .ra2_e(ra2_e),
        .wa_e(wa_e)
    );

    mux2 u_srca_mux (
        .sel(alu_srca_sel_e),
        .ina(rd1_e),
        .inb(pc_e),
        .out(srca)
    );

    mux2 u_srcb_mux (
        .sel(alu_srcb_sel_e),
        .ina(rd2_e),
        .inb(imm_result_e),
        .out(srcb)
    );

    branch u_branch (
        .rd1(rd1_e),
        .rd2(rd2_e),
        .jump(jump_e),
        .branch(branch_e),
        .branch_type(branch_type_e),
        .pc_sel(pc_sel_e)
    );

    alu u_alu (
        .srca(srca),
        .srcb(srcb),
        .op(alu_control_e),
        .result(alu_result_e)
    );

    assign alu_result_i = alu_result_e;
    assign pc_sel_i = pc_sel_e;

    assign data_forward1_input1 = alu_result_e;
    assign data_forward2_input1 = alu_result_e;

    // Me Stage
    wire [1:0] mem_src_sel_m;
    wire [2:0] mem_type_m;
    wire mem_we_m;
    wire regfile_we_m;
    wire [1:0] regfile_src_sel_m;
    wire iflag_m;
    wire pc_m_30;
    wire [31:0] pc_plus4_m;
    wire [31:0] alu_result_m;
    wire [31:0] rd1_m, rd2_m;
    wire [4:0] wa_m;
    wire [4:0] ra1_m;
    wire [31:0] mem_din;
    wire [31:0] mem_data_m;

    pipeline3 u_pipeline3 (
        .clk(clk),
        .flush(rst),
        .mem_src_sel_e(mem_src_sel_e),
        .mem_type_e(mem_type_e),
        .mem_we_e(mem_we_e),
        .regfile_we_e(regfile_we_e),
        .regfile_src_sel_e(regfile_src_sel_e),
        .iflag_e(iflag_e),
        .pc_e_30(pc_e[30]),
        .pc_plus4_e(pc_plus4_e),
        .alu_result_e(alu_result_e),
        .rd1_e(rd1_e),
        .rd2_e(rd2_e),
        .wa_e(wa_e),
        .ra1_e(ra1_e),
        .mem_src_sel_m(mem_src_sel_m),
        .mem_type_m(mem_type_m),
        .mem_we_m(mem_we_m),
        .regfile_we_m(regfile_we_m),
        .regfile_src_sel_m(regfile_src_sel_m),
        .iflag_m(iflag_m),
        .pc_m_30(pc_m_30),
        .pc_plus4_m(pc_plus4_m),
        .alu_result_m(alu_result_m),
        .rd1_m(rd1_m),
        .rd2_m(rd2_m),
        .wa_m(wa_m),
        .ra1_m(ra1_m)
    );

    mux4 u_csr_mux (
        .sel(mem_src_sel_m),
        .ina(rd2_m),
        .inb(32'b0),
        .inc(rd1_m),
        .ind({ 27'b0, ra1_m[4:0] }),
        .out(mem_din)
    );

    mem_control #(
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_mem_control (
        .clk(clk),
        .rst(rst),
        .pc_addr(pc_i),
        .pc_m_30(pc_m_30),
        .alu_addr(alu_result_m),
        .mem_type(mem_type_m),
        .mem_we(mem_we_m),
        .mem_win(mem_din),
        .iflag(iflag_m),
        .instruction(instruction_i),
        .mem_data(mem_data_m),
        .serial_in(serial_in),
        .serial_out(serial_out)
    );

    hazard_control u_harzard_control (
        .ra1_r(ra1_r),
        .ra2_r(ra2_r),
        .wa_e(wa_e),
        .wa_m(wa_m),
        .regfile_we_e(regfile_we_e),
        .regfile_we_m(regfile_we_m),
        .regfile_src_sel_e(regfile_src_sel_e),
        .regfile_src_sel_m(regfile_src_sel_m),
        .rd1_sel(rd1_sel),
        .rd2_sel(rd2_sel),
        .keep(keep)
    );

    assign data_forward1_input2 = alu_result_m;
    assign data_forward2_input2 = alu_result_m;
    assign data_forward1_input3 = mem_data_m;
    assign data_forward2_input3 = mem_data_m;

    // WB Stage
    wire regfile_we_w;
    wire [1:0] regfile_src_sel_w;
    wire [31:0] pc_plus4_w;
    wire [31:0] alu_result_w;
    wire [31:0] mem_data_w;
    wire [4:0] wa_w;
    wire [31:0] regfile_wd_w;

    pipeline4 u_pipeline4 (
        .clk(clk),
        .flush(rst),
        .regfile_we_m(regfile_we_m),
        .regfile_src_sel_m(regfile_src_sel_m),
        .pc_plus4_m(pc_plus4_m),
        .alu_result_m(alu_result_m),
        .mem_data_m(mem_data_m),
        .wa_m(wa_m),
        .regfile_we_w(regfile_we_w),
        .regfile_src_sel_w(regfile_src_sel_w),
        .pc_plus4_w(pc_plus4_w),
        .alu_result_w(alu_result_w),
        .mem_data_w(mem_data_w),
        .wa_w(wa_w)
    );

    mux4 u_wd_mux (
        .sel(regfile_src_sel_w),
        .ina(alu_result_w),
        .inb(mem_data_w),
        .inc(pc_plus4_w),
        .ind(32'b0),
        .out(regfile_wd_w)
    );

    assign regfile_wd = regfile_wd_w;
    assign wa = wa_w;
    assign regfile_we = regfile_we_w;
endmodule
