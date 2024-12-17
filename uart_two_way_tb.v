`timescale 1ns / 1ps

module uart_two_way_tb;
    reg clk;
    reg reset;
    reg [7:0] data_in;
    reg tx_start;
    reg rx;  // Simulate serial input
    wire tx;
    wire [7:0] data_out;
    wire tx_busy;
    wire rx_ready;

    // Instantiate the two-way UART communication module
    uart_two_way_comm uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .tx_start(tx_start),
        .rx(rx),
        .tx(tx),
        .data_out(data_out),
        .tx_busy(tx_busy),
        .rx_ready(rx_ready)
    );

    // Clock generation
    always #10 clk = ~clk; // 50 MHz clock (10 ns period)

    // Test case for file handling output
    integer file_id;

    initial begin
        // Open file for writing simulation output
        file_id = $fopen("two-way_output.txt", "w");
        if (file_id == 0) begin
            $display("Error: Unable to open file for writing!");
            $finish;
        end
    end

    // Dump waveform
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, uart_two_way_tb);
    end

    // Test cases
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        data_in = 8'h00;
        tx_start = 0;
        rx = 1; // Idle high for RX

        // Apply reset
        #50 reset = 0;

        // Test case 1: Transmit byte 0x55 (01010101)
        #50 data_in = 8'h55; // Data to send: 0x55 (01010101)
        tx_start = 1;        // Start the transmission
        #20 tx_start = 0;    // Stop the transmission trigger

        // Simulate receiving the byte 0x55 on RX
        #50 rx = 0;  // Start bit (0)
        #80 rx = 1;  // Data bit 1 (1)
        #80 rx = 0;  // Data bit 2 (0)
        #80 rx = 1;  // Data bit 3 (1)
        #80 rx = 0;  // Data bit 4 (0)
        #80 rx = 1;  // Data bit 5 (1)
        #80 rx = 0;  // Data bit 6 (0)
        #80 rx = 1;  // Data bit 7 (1)
        #80 rx = 1;  // Stop bit (1)

        // Wait for RX to finish and check received data
        #100;
        if (rx_ready) begin
            $display("Received data: %h", data_out);  // Display received data
            $fwrite(file_id, "Received data: %h\n", data_out);  // Write to file
        end else begin
            $display("No data received.");
        end

        // Test case 2: Transmit byte 0x3C (00111100)
        #50 data_in = 8'h3C; // Data to send: 0x3C (00111100)
        tx_start = 1;
        #20 tx_start = 0;

        // Simulate receiving the byte 0x3C on RX
        #50 rx = 0;  // Start bit (0)
        #80 rx = 0;  // Data bit 1 (0)
        #80 rx = 1;  // Data bit 2 (1)
        #80 rx = 1;  // Data bit 3 (1)
        #80 rx = 1;  // Data bit 4 (1)
        #80 rx = 0;  // Data bit 5 (0)
        #80 rx = 0;  // Data bit 6 (0)
        #80 rx = 1;  // Data bit 7 (1)
        #80 rx = 1;  // Stop bit (1)

        // Wait for RX to finish and check received data
        #100;
        if (rx_ready) begin
            $display("Received data: %h", data_out);  // Display received data
            $fwrite(file_id, "Received data: %h\n", data_out);  // Write to file
        end else begin
            $display("No data received.");
        end

        // End simulation
        #200;
        $fclose(file_id);  // Close the output file
        $finish;
    end
endmodule
