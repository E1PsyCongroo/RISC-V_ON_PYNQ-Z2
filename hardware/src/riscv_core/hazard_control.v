`include "opcode.vh"
module hazard_control (
    input [4:0] ra1_r, ra2_r,
    input [4:0] wa_e,
    input [4:0] wa_m,
    input regfile_we_e,
    input regfile_we_m,
    input [1:0] regfile_src_sel_e,
    input [1:0] regfile_src_sel_m,
    output reg [1:0] rd1_sel,
    output reg [1:0] rd2_sel,
    output keep
);

    assign keep = (ra1_r == wa_e || ra2_r == wa_e) && (regfile_src_sel_e == `reg_mem);

    reg [1:0] rd_sel_m;
    always @(*) begin
        case(regfile_src_sel_m)
        `reg_alu: rd_sel_m = 2'b10;
        `reg_mem: rd_sel_m = 2'b11;
        default: rd_sel_m = 2'b00;
        endcase
    end

    wire [1:0] rd_sel_e;
    assign rd_sel_e = 2'b01;

    always @(*) begin
        if (wa_e != 5'b0 && ra1_r == wa_e) begin
            if (regfile_we_e) begin
                rd1_sel = rd_sel_e;
            end
            else begin
                rd1_sel = 2'b00;
            end
        end
        else if (wa_m != 5'b0 && ra1_r == wa_m) begin
            if (regfile_we_m) begin
                rd1_sel = rd_sel_m;
            end
            else begin
                rd1_sel = 2'b00;
            end
        end
        else begin
            rd1_sel = 2'b00;
        end

        if (wa_e != 5'b0 && ra2_r == wa_e) begin
            if (regfile_we_e) begin
                rd2_sel = rd_sel_e;
            end
            else begin
                rd2_sel = 2'b00;
            end
        end
        else if (wa_m != 5'b0 && ra2_r == wa_m) begin
            if (regfile_we_m) begin
                rd2_sel = rd_sel_m;
            end
            else begin
                rd2_sel = 2'b00;
            end
        end
        else begin
            rd2_sel = 2'b00;
        end
    end

endmodule