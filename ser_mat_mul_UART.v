// Code your design here
`timescale 1ns/1ps

module uart_rx (
    input wire clk,
    input wire reset,
    input wire rx,
    output reg [7:0] data_out,
    output reg rx_done
);

    // Parameters
    parameter CLOCK_FREQ = 50000000;  // 50 MHz
    parameter BAUD_RATE = 9600;
    parameter BIT_PERIOD = CLOCK_FREQ / BAUD_RATE;

    // States
    typedef enum reg [1:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT
    } state_t;
    state_t state, next_state;

    reg [12:0] bit_counter;
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 0;
            bit_idx <= 0;
            shift_reg <= 0;
            rx_done <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    rx_done <= 0;
                    if (rx == 0) begin
                        bit_counter <= 0;
                        next_state <= START_BIT;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                START_BIT: begin
                    if (bit_counter == BIT_PERIOD / 2) begin
                        if (rx == 0) begin
                            bit_counter <= 0;
                            next_state <= DATA_BITS;
                        end else begin
                            next_state <= IDLE;
                        end
                    end else begin
                        bit_counter <= bit_counter + 1;
                        next_state <= START_BIT;
                    end
                end

                DATA_BITS: begin
                    if (bit_counter == BIT_PERIOD - 1) begin
                        shift_reg[bit_idx] <= rx;
                        bit_counter <= 0;
                        if (bit_idx == 7) begin
                            next_state <= STOP_BIT;
                        end else begin
                            bit_idx <= bit_idx + 1;
                            next_state <= DATA_BITS;
                        end
                    end else begin
                        bit_counter <= bit_counter + 1;
                        next_state <= DATA_BITS;
                    end
                end

                STOP_BIT: begin
                    if (bit_counter == BIT_PERIOD - 1) begin
                        bit_counter <= 0;
                        data_out <= shift_reg;
                        rx_done <= 1;
                        next_state <= IDLE;
                    end else begin
                        bit_counter <= bit_counter + 1;
                        next_state <= STOP_BIT;
                    end
                end
            endcase
        end
    end
endmodule




module uart_tx (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    input wire tx_start,
    output reg tx,
    output reg tx_done
);

    // Parameters
    parameter CLOCK_FREQ = 50000000;  // 50 MHz
    parameter BAUD_RATE = 9600;
    parameter BIT_PERIOD = CLOCK_FREQ / BAUD_RATE;

    // States
    typedef enum reg [1:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT
    } state_t;
    state_t state, next_state;

    reg [12:0] bit_counter;
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 0;
            bit_idx <= 0;
            shift_reg <= 0;
            tx <= 1;
            tx_done <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    tx <= 1;
                    tx_done <= 0;
                    if (tx_start) begin
                        shift_reg <= data_in;
                        bit_idx <= 0;
                        bit_counter <= 0;
                        next_state <= START_BIT;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                START_BIT: begin
                    tx <= 0;
                    if (bit_counter == BIT_PERIOD - 1) begin
                        bit_counter <= 0;
                        next_state <= DATA_BITS;
                    end else begin
                        bit_counter <= bit_counter + 1;
                        next_state <= START_BIT;
                    end
                end

                DATA_BITS: begin
                    tx <= shift_reg[bit_idx];
                    if (bit_counter == BIT_PERIOD - 1) begin
                        bit_counter <= 0;
                        if (bit_idx == 7) begin
                            next_state <= STOP_BIT;
                        end else begin
                            bit_idx <= bit_idx + 1;
                            next_state <= DATA_BITS;
                        end
                    end else begin
                        bit_counter <= bit_counter + 1;
                        next_state <= DATA_BITS;
                    end
                end

                STOP_BIT: begin
                    tx <= 1;
                    if (bit_counter == BIT_PERIOD - 1) begin
                        bit_counter <= 0;
                        tx_done <= 1;
                        next_state <= IDLE;
                    end else begin
                        bit_counter <= bit_counter + 1;
                        next_state <= STOP_BIT;
                    end
                end
            endcase
        end
    end
endmodule
















module top_module (
    input wire clk,
    input wire reset,
    input wire rx,
    output wire tx
);

    wire [7:0] data_in;
    reg [7:0] data_out;
    wire rx_done;
    reg tx_start;
    wire tx_done;

    reg [7:0] matrix_a [3:0][3:0];
    reg [7:0] matrix_b [3:0][3:0];
    reg [15:0] result [3:0][3:0];
    reg [4:0] i, j, k;

    // Instantiate UART receiver
    uart_rx uart_receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_in),
        .rx_done(rx_done)
    );

    // Instantiate UART transmitter
    uart_tx uart_transmitter (
        .clk(clk),
        .reset(reset),
        .data_in(data_out),
        .tx_start(tx_start),
        .tx(tx),
        .tx_done(tx_done)
    );

    // State machine for matrix multiplication
    typedef enum reg [2:0] {
        IDLE,
        RECEIVE_A,
        RECEIVE_B,
        COMPUTE,
        SEND_RESULT
    } state_t;
    state_t state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            i <= 0;
            j <= 0;
            k <= 0;
            tx_start <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    if (rx_done) begin
                        next_state <= RECEIVE_A;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                RECEIVE_A: begin
                    if (rx_done) begin
                        matrix_a[i][j] <= data_in;
                        j <= j + 1;
                        if (j == 3) begin
                            j <= 0;
                            i <= i + 1;
                        end
                        if (i == 3 && j == 3) begin
                            i <= 0;
                            j <= 0;
                            next_state <= RECEIVE_B;
                        end else begin
                            next_state <= RECEIVE_A;
                        end
                    end else begin
                        next_state <= RECEIVE_A;
                    end
                end

                RECEIVE_B: begin
                    if (rx_done) begin
                        matrix_b[i][j] <= data_in;
                        j <= j + 1;
                        if (j == 3) begin
                            j <= 0;
                            i <= i + 1;
                        end
                        if (i == 3 && j == 3) begin
                            i <= 0;
                            j <= 0;
                            next_state <= COMPUTE;
                        end else begin
                            next_state <= RECEIVE_B;
                        end
                    end else begin
                        next_state <= RECEIVE_B;
                    end
                end

                COMPUTE: begin
                    result[i][j] <= 0;
                    for (k = 0; k < 4; k = k + 1) begin
                        result[i][j] <= result[i][j] + matrix_a[i][k] * matrix_b[k][j];
                    end
                    j <= j + 1;
                    if (j == 3) begin
                        j <= 0;
                        i <= i + 1;
                    end
                    if (i == 3 && j == 3) begin
                        i <= 0;
                        j <= 0;
                        next_state <= SEND_RESULT;
                    end else begin
                        next_state <= COMPUTE;
                    end
                end

                SEND_RESULT: begin
                    if (tx_done) begin
                        data_out <= result[i][j][7:0];  // Sending lower byte
                        tx_start <= 1;
                        j <= j + 1;
                        if (j == 3) begin
                            j <= 0;
                            i <= i + 1;
                        end
                        if (i == 3 && j == 3) begin
                            next_state <= IDLE;
                        end else begin
                            next_state <= SEND_RESULT;
                        end
                    end else begin
                        tx_start <= 0;
                        next_state <= SEND_RESULT;
                    end
                end

                default: next_state <= IDLE;
            endcase
        end
    end
endmodule
