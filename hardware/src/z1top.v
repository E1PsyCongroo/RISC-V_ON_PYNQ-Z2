module z1top #(
    parameter BAUD_RATE = 115_200,
    // Warning: CPU_CLOCK_FREQ must match the PLL parameters!
    parameter CPU_CLOCK_FREQ = 50_000_000,
    // PLL Parameters: sets the CPU clock = 125Mhz * 34 / 5 / 17 = 50 MHz
    parameter CPU_CLK_CLKFBOUT_MULT = 34,
    parameter CPU_CLK_DIVCLK_DIVIDE = 5,
    parameter CPU_CLK_CLKOUT_DIVIDE  = 17,
    /* verilator lint_off REALCVT */
    // Sample the button signal every 500us
    parameter integer B_SAMPLE_CNT_MAX = 0.0005 * CPU_CLOCK_FREQ,
    // The button is considered 'pressed' after 100ms of continuous pressing
    parameter integer B_PULSE_CNT_MAX = 0.100 / 0.0005,
    /* lint_on */
    // The PC the RISC-V CPU should start at after reset
    parameter RESET_PC = 32'h4000_0000,
    parameter N_VOICES = 1
) (
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS,
    input  FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
    // output AUD_PWM,
    // output AUD_SD
);
    // Clocks and PLL lock status
    // wire cpu_clk, cpu_clk_locked, pwm_clk, pwm_clk_locked;
    wire cpu_clk, cpu_clk_locked;

    // Buttons after the button_parser
    wire [3:0] buttons_pressed;

    // Reset the CPU and all components on the cpu_clk if the reset button is
    // pushed or whenever the CPU clock PLL isn't locked
    wire cpu_reset;
    assign cpu_reset = buttons_pressed[0] || !cpu_clk_locked;

    // Use IOBs to drive/sense the UART serial lines
    wire cpu_tx, cpu_rx;
    (* IOB = "true" *) reg fpga_serial_tx_iob;
    (* IOB = "true" *) reg fpga_serial_rx_iob;
    assign FPGA_SERIAL_TX = fpga_serial_tx_iob;
    assign cpu_rx = fpga_serial_rx_iob;
    always @(posedge cpu_clk) begin
        fpga_serial_tx_iob <= cpu_tx;
        fpga_serial_rx_iob <= FPGA_SERIAL_RX;
    end

    // // Use IOBs to drive the PWM output
    // (* IOB = "true" *) reg pwm_iob;
    // wire pwm_out; // TODO: connect this wire to your DAC
    // assign pwm_out = 1'b0;
    // assign AUD_PWM = pwm_iob;
    // assign AUD_SD = 1'b1;
    // always @(posedge pwm_clk) begin
    //     pwm_iob <= pwm_out;
    // end

    // Generate a reset for the PWM clock domain
    // wire pwm_rst, reset_button_pwm_domain;
    // synchronizer rst_pwm_sync (.async_signal(buttons_pressed[0]), .sync_signal(reset_button_pwm_domain), .clk(pwm_clk));
    // assign pwm_rst = reset_button_pwm_domain || ~pwm_clk_locked;

    clocks #(
        .CPU_CLK_CLKFBOUT_MULT(CPU_CLK_CLKFBOUT_MULT),
        .CPU_CLK_DIVCLK_DIVIDE(CPU_CLK_DIVCLK_DIVIDE),
        .CPU_CLK_CLKOUT_DIVIDE(CPU_CLK_CLKOUT_DIVIDE)
    ) clk_gen (
        .clk_125mhz(CLK_125MHZ_FPGA),
        .cpu_clk(cpu_clk),
        .cpu_clk_locked(cpu_clk_locked)
        // .pwm_clk(pwm_clk),
        // .pwm_clk_locked(pwm_clk_locked)
    );

    button_parser #(
        .WIDTH(4),
        .SAMPLE_CNT_MAX(B_SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX(B_PULSE_CNT_MAX)
    ) bp (
        .clk(cpu_clk),
        .in(BUTTONS),
        .out(buttons_pressed)
    );

    cpu #(
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
        .RESET_PC(RESET_PC),
        .BAUD_RATE(BAUD_RATE)
    ) cpu (
        .clk(cpu_clk),
        .rst(cpu_reset),
        .serial_out(cpu_tx),
        .serial_in(cpu_rx)
    );

    reg [31:0] counter1, counter2;
    always @(posedge CLK_125MHZ_FPGA) begin
        if (cpu_reset) begin
            counter1 <= 0;
        end
        else if (counter1 < 32'd125_000_000)begin
            counter1 <= counter1 + 1;
        end
        else begin
            counter1 <= counter1;
        end
    end

    always @(posedge cpu_clk) begin
        if (cpu_reset) begin
            counter2 <= 0;
        end
        else if (counter2 < CPU_CLOCK_FREQ)begin
            counter2 <= counter2 + 1;
        end
        else begin
            counter2 <= counter2;
        end
    end
    assign LEDS[0] = (counter1 == 32'd125_000_000);
    assign LEDS[1] = (counter2 == CPU_CLOCK_FREQ);
    assign LEDS[4] = ~cpu_clk_locked;
    // _to_synth_cdc #(
    //     .N_VOICES(N_VOICES)
    // ) cdc (
    //     .cpu_clk(cpu_clk),
    //     .synth_clk(pwm_clk),
    //     .cpu_carrier_fcws(24'd0),
    //     .cpu_mod_fcw(24'd0),
    //     .cpu_mod_shift(5'd0),
    //     .cpu_note_en(1'd0),
    //     .cpu_synth_shift(5'd0),
    //     .cpu_req(1'd0),
    //     .cpu_ack(),

    //     .synth_carrier_fcws(),
    //     .synth_mod_fcw(),
    //     .synth_mod_shift(),
    //     .synth_note_en(),
    //     .synth_synth_shift()
    // );

    // synth #(
    //     .N_VOICES(N_VOICES)
    // ) synth (
    //     .clk(pwm_clk),
    //     .rst(pwm_rst),
    //     .carrier_fcws(24'd0),
    //     .mod_fcw(24'd0),
    //     .mod_shift(5'd0),
    //     .note_en(1'd0),
    //     .sample(),
    //     .sample_valid(),
    //     .sample_ready(1'd0)
    // );

    // scaler scaler (
    //     .clk(pwm_clk),
    //     .synth_shift(5'd0),
    //     .synth_out(14'd0),
    //     .code()
    // );

    // sampler sampler (
    //     .clk(pwm_clk),
    //     .rst(pwm_rst),
    //     .synth_valid(1'd0),
    //     .synth_ready(),
    //     .scaled_synth_code(10'd0),
    //     .pwm_out(pwm_out)
    // );
endmodule
