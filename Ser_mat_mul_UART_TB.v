`timescale 1ns/1ps
module tb_top_module;

    reg clk;
    reg reset;
    reg rx;
    wire tx;

    // Instantiate the top module
    top_module uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 50 MHz clock
    end

    // Reset and UART test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        rx = 1;

        // Wait for global reset
        #100;
        reset = 0;

        // Send Matrix A
        send_matrix_a();
        
        // Send Matrix B
        send_matrix_b();

        // Wait for computation and result transmission
        #20000;

        // Finish simulation
        $finish;
    end

    // Task to send matrix A
    task send_matrix_a;
        integer i, j;
        reg [7:0] data;
        begin
            // Define matrix A
            reg [7:0] matrix_a [3:0][3:0];
            matrix_a[0][0] = 8'd1;  matrix_a[0][1] = 8'd2;  matrix_a[0][2] = 8'd3;  matrix_a[0][3] = 8'd4;
            matrix_a[1][0] = 8'd5;  matrix_a[1][1] = 8'd6;  matrix_a[1][2] = 8'd7;  matrix_a[1][3] = 8'd8;
            matrix_a[2][0] = 8'd9;  matrix_a[2][1] = 8'd10; matrix_a[2][2] = 8'd11; matrix_a[2][3] = 8'd12;
            matrix_a[3][0] = 8'd13; matrix_a[3][1] = 8'd14; matrix_a[3][2] = 8'd15; matrix_a[3][3] = 8'd16;

            // Send matrix A elements via UART
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    data = matrix_a[i][j];
                    send_uart_byte(data);
                    #104170;  // Ensure sufficient delay between bytes
                end
            end
        end
    endtask

    // Task to send matrix B
    task send_matrix_b;
        integer i, j;
        reg [7:0] data;
        begin
            // Define matrix B
            reg [7:0] matrix_b [3:0][3:0];
            matrix_b[0][0] = 8'd17; matrix_b[0][1] = 8'd18; matrix_b[0][2] = 8'd19; matrix_b[0][3] = 8'd20;
            matrix_b[1][0] = 8'd21; matrix_b[1][1] = 8'd22; matrix_b[1][2] = 8'd23; matrix_b[1][3] = 8'd24;
            matrix_b[2][0] = 8'd25; matrix_b[2][1] = 8'd26; matrix_b[2][2] = 8'd27; matrix_b[2][3] = 8'd28;
            matrix_b[3][0] = 8'd29; matrix_b[3][1] = 8'd30; matrix_b[3][2] = 8'd31; matrix_b[3][3] = 8'd32;

            // Send matrix B elements via UART
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 4; j = j + 1) begin
                    data = matrix_b[i][j];
                    send_uart_byte(data);
                    #104170;  // Ensure sufficient delay between bytes
                end
            end
        end
    endtask

    // Task to send a byte via UART (including start and stop bits)
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Send start bit
            rx = 0;
            #10417;  // Bit period for 9600 baud rate at 50 MHz clock

            // Send data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #10417;
            end

            // Send stop bit
            rx = 1;
            #10417;
        end
    endtask

    // Monitor for displaying results
    initial begin
        $monitor("Time = %0t | tx = %b", $time, tx);
    end
  
  // Generate VCD file for waveform viewing 
  initial begin 
    $dumpfile("matrix_mult_tb.vcd");
    $dumpvars(0, tb_top_module); 
  end

endmodule
