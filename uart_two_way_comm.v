`timescale 1ns / 1ps

module uart_two_way_comm (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,   // Data to send
    input wire tx_start,        // Start transmission signal
    input wire rx,              // Serial data input (received)
    output wire tx,             // Serial data output (transmit)
    output wire [7:0] data_out, // Received parallel data
    output wire tx_busy,        // TX is busy
    output wire rx_ready        // RX data is ready
);
    // Instantiate the transmitter
    uart_tx tx_module (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Instantiate the receiver
    uart_rx rx_module (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .rx_ready(rx_ready)
    );
endmodule


module uart_tx (
    input wire clk,           // Clock signal
    input wire reset,         // Reset signal
    input wire [7:0] data_in, // Parallel data input
    input wire tx_start,      // Start transmission signal
    output reg tx,            // Serial data output
    output reg tx_busy        // Indicates if the transmitter is busy
);
    // Baud rate related parameters
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state = IDLE;
    reg [3:0] bit_count;
    reg [7:0] data_buffer;
    
    // For baud rate simulation
    reg [15:0] baud_counter;   // Adjust size depending on clock frequency
    parameter BAUD_DIVISOR = 10416;  // Set this for 9600 baud if 50 MHz clock

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1'b1; // Line idle is high
            tx_busy <= 1'b0;
            bit_count <= 0;
            baud_counter <= 0;
        end else begin
            if (baud_counter == BAUD_DIVISOR) begin
                baud_counter <= 0;  // Reset the baud counter
                case (state)
                    IDLE: begin
                        tx <= 1'b1; // Idle state
                        if (tx_start && !tx_busy) begin
                            data_buffer <= data_in;
                            tx_busy <= 1'b1;
                            state <= START;
                        end
                    end
                    START: begin
                        tx <= 1'b0; // Start bit
                        state <= DATA;
                    end
                    DATA: begin
                        tx <= data_buffer[bit_count];
                        bit_count <= bit_count + 1;
                        if (bit_count == 7) state <= STOP;
                    end
                    STOP: begin
                        tx <= 1'b1; // Stop bit
                        tx_busy <= 1'b0;
                        state <= IDLE;
                    end
                endcase
            end else begin
                baud_counter <= baud_counter + 1;  // Increment baud counter
            end
        end
    end
endmodule


module uart_rx (
    input wire clk,       // Clock signal
    input wire reset,     // Reset signal
    input wire rx,        // Serial data input
    output reg [7:0] data_out, // Parallel data output
    output reg rx_ready   // Indicates new data is ready
);
    // Baud rate related parameters
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state = IDLE;
    reg [3:0] bit_count;
    reg [7:0] data_buffer;
    
    // For baud rate simulation
    reg [15:0] baud_counter;   // Adjust size depending on clock frequency
    parameter BAUD_DIVISOR = 10416;  // Set this for 9600 baud if 50 MHz clock

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_ready <= 1'b0;
            data_out <= 8'd0;
            bit_count <= 0;
            baud_counter <= 0;
        end else begin
            if (baud_counter == BAUD_DIVISOR) begin
                baud_counter <= 0;  // Reset the baud counter
                case (state)
                    IDLE: begin
                        rx_ready <= 1'b0;
                        if (rx == 1'b0) state <= START; // Detect start bit
                    end
                    START: begin
                        if (rx == 1'b0) state <= DATA; // Confirm start bit
                    end
                    DATA: begin
                        data_buffer[bit_count] <= rx;
                        bit_count <= bit_count + 1;
                        if (bit_count == 7) state <= STOP;
                    end
                    STOP: begin
                        if (rx == 1'b1) begin
                            data_out <= data_buffer;
                            rx_ready <= 1'b1;
                            state <= IDLE;
                        end
                    end
                endcase
            end else begin
                baud_counter <= baud_counter + 1;  // Increment baud counter
            end
        end
    end
endmodule
