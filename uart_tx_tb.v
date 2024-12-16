// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module uart_tx_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] data_in;
    wire tx;
    wire tx_busy;

    // Parameters
    parameter CLK_PERIOD = 20; // 50 MHz clock -> 20 ns period

    // Instantiate the UART transmitter module
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Clock generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Waveform dumping
    initial begin
        $dumpfile("waveform.vcd"); // Name of the waveform file
        $dumpvars(0, uart_tx_tb);  // Dump all variables in the testbench
    end

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        tx_start = 0;
        data_in = 8'h00;

        // Apply reset
        #100;
        reset = 0;

        // Test Case 1: Transmit byte 0x55
        #100;
        data_in = 8'h55; // ASCII 'U'
        tx_start = 1;
        #20;             // Wait for a clock cycle
        tx_start = 0;

        // Wait for transmission to complete
        wait (tx_busy == 0);

        // Test Case 2: Transmit byte 0xA5
        #100;
        data_in = 8'hA5; // Custom data
        tx_start = 1;
        #20;
        tx_start = 0;

        // Wait for transmission to complete
        wait (tx_busy == 0);

        // End simulation
        #200;
        $finish;
    end
endmodule
