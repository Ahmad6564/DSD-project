// Code your design here
`timescale 1ns / 1ps
module uart_tx (
    input wire clk,            // System clock
    input wire reset,          // Reset signal
    input wire [7:0] data_in,  // Data to transmit
    input wire tx_start,       // Start transmission
    output reg tx,             // UART transmit line
    output reg tx_busy         // Indicates if transmitter is busy
);

//     parameter CLK_FREQ = 50000000; // 50 MHz clock
//     parameter BAUD_RATE = 9600;   // UART baud rate
    parameter CLK_FREQ = 1000000; // 1 MHz clock
    parameter BAUD_RATE = 1000;   // Reduced baud rate
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    // State machine states
    typedef enum reg [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT
    } state_t;
    
    state_t state = IDLE;
    reg [15:0] bit_count = 0;      // Counts clock cycles for bit period
    reg [2:0] bit_index = 0;       // Tracks which bit of data is being sent
    reg [7:0] shift_reg = 0;       // Holds data being transmitted

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1;               // UART line idle is high
            tx_busy <= 0;
            bit_count <= 0;
            bit_index <= 0;
            shift_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;       // Keep UART line high
                    tx_busy <= 0;
                    if (tx_start) begin
                        tx_busy <= 1;
                        shift_reg <= data_in;
                        bit_index <= 0;
                        bit_count <= 0;
                        state <= START_BIT;
                    end
                end
                
                START_BIT: begin
                    tx <= 0;       // Send start bit
                    if (bit_count < BIT_PERIOD - 1) begin
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 0;
                        state <= DATA_BITS;
                    end
                end
                
                DATA_BITS: begin
                    tx <= shift_reg[bit_index]; // Send current data bit
                    if (bit_count < BIT_PERIOD - 1) begin
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= STOP_BIT;
                        end
                    end
                end
                
                STOP_BIT: begin
                    tx <= 1;       // Send stop bit
                    if (bit_count < BIT_PERIOD - 1) begin
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
