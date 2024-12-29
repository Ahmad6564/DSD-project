`timescale 1ns / 1ps

module fast_matrix_mult_3x3_uart_tb;
    // Parameters
    parameter CLK_PERIOD = 10;
    parameter CLKS_PER_BIT = 87;
    parameter BIT_PERIOD = CLKS_PER_BIT * CLK_PERIOD;
    
    // DUT Signals
    reg clk;
    reg rst_n;
    reg rx;
    wire tx;
    wire [71:0] result;
    wire valid_out;
    
    // Test variables
    reg [71:0] test_matrix_a;
    reg [71:0] test_matrix_b;
    reg [71:0] expected_result;
    reg [71:0] captured_result;
    reg valid_detected;
    integer i;

    // Instantiate DUT
    fast_matrix_mult_3x3_uart #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .tx(tx),
        .result(result),
        .valid_out(valid_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Task to display a matrix
    task display_matrix;
        input [71:0] matrix;
        input string name;
        begin
            $display("\n%s:", name);
            $display("[%3d %3d %3d]", 
                    matrix[71:64], matrix[63:56], matrix[55:48]);
            $display("[%3d %3d %3d]", 
                    matrix[47:40], matrix[39:32], matrix[31:24]);
            $display("[%3d %3d %3d]", 
                    matrix[23:16], matrix[15:8], matrix[7:0]);
        end
    endtask

    // UART byte transmission task
    task send_uart_byte;
        input [7:0] data;
        integer bit_index;
        begin
            rx = 0;
            #(BIT_PERIOD);
            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                rx = data[bit_index];
                #(BIT_PERIOD);
            end
            rx = 1;
            #(BIT_PERIOD);
            #(BIT_PERIOD/2);
        end
    endtask

    // Task to send matrix over UART
    task send_matrix;
        input [71:0] matrix;
        input string name;
        reg [7:0] bytes[0:8];
        integer idx;
        begin
            $display("\nSending %s:", name);
            for(idx = 0; idx < 9; idx = idx + 1) begin
                bytes[idx] = matrix[71-idx*8 -: 8];
                send_uart_byte(bytes[idx]);
                #(BIT_PERIOD);
            end
            $display("%s transmission complete", name);
        end
    endtask

    // Main test sequence
    initial begin
        // Initialize
        rx = 1;
        rst_n = 0;
        valid_detected = 0;
        
        // Define test matrices
        test_matrix_a = {8'd1, 8'd2, 8'd3,
                        8'd4, 8'd5, 8'd6,
                        8'd7, 8'd8, 8'd9};
        
        test_matrix_b = {8'd9, 8'd8, 8'd7,
                        8'd6, 8'd5, 8'd4,
                        8'd3, 8'd2, 8'd1};
        
        expected_result = {8'd30, 8'd24, 8'd18,
                          8'd84, 8'd69, 8'd54,
                          8'd138, 8'd114, 8'd90};

        $display("\nMatrix Multiplication Test");
        $display("------------------------");
        display_matrix(test_matrix_a, "Matrix A");
        display_matrix(test_matrix_b, "Matrix B");
        $display("\nExpected Result:");
        display_matrix(expected_result, "Expected Matrix");

        // Reset sequence
        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 10);

        // Send matrices
        send_matrix(test_matrix_a, "Matrix A");
        #(BIT_PERIOD * 2);
        send_matrix(test_matrix_b, "Matrix B");

        // Wait for valid_out to assert or timeout
        fork
            begin : wait_valid
                @(posedge valid_out);
                captured_result = result;
                valid_detected = 1;
                display_matrix(captured_result, "Result Matrix");
                
                if (captured_result === expected_result) begin
                    $display("\nVerification: PASSED");
                end else begin
                    $display("\nVerification: FAILED");
                end
                #(BIT_PERIOD * 10);
                $finish(0);
            end

            begin : timeout_monitor
                #(BIT_PERIOD * 2000);  // Increased timeout period
                if (!valid_detected) begin
                    $display("\nError: Computation timeout");
                    $finish(1);
                end
            end
        join_any
        disable wait_valid;
        disable timeout_monitor;
    end

    // Generate waveform file
    initial begin
        $dumpfile("matrix_mult_uart_tb.vcd");
        $dumpvars(0, fast_matrix_mult_3x3_uart_tb);
    end

endmodule








// `timescale 1ns / 1ps

// module fast_matrix_mult_3x3_uart_tb;
//     // Parameters
//     parameter CLK_PERIOD = 10;     // 100MHz clock
//     parameter CLKS_PER_BIT = 87;   // For simulation speed
//     parameter BIT_PERIOD = CLKS_PER_BIT * CLK_PERIOD;
    
//     // DUT Signals
//     reg clk;
//     reg rst_n;
//     reg rx;
//     wire tx;
//     wire [71:0] result;
//     wire valid_out;
    
//     // Test variables
//     reg [71:0] test_matrix_a;
//     reg [71:0] test_matrix_b;
//     reg [71:0] expected_result;
//     reg [71:0] captured_result;
//     reg valid_detected;
//     integer i;

//     // Debug variables
//     integer error_count;
//     reg test_passed;

//     // Instantiate DUT
//     fast_matrix_mult_3x3_uart #(
//         .CLKS_PER_BIT(CLKS_PER_BIT)
//     ) uut (
//         .clk(clk),
//         .rst_n(rst_n),
//         .rx(rx),
//         .tx(tx),
//         .result(result),
//         .valid_out(valid_out)
//     );

//     // Clock generation
//     initial begin
//         clk = 0;
//         forever #(CLK_PERIOD/2) clk = ~clk;
//     end

//     // Task to display a matrix in readable format
//     task display_matrix;
//         input [71:0] matrix;
//         input string name;
//         begin
//             $display("\n%s:", name);
//             $display("[%3d %3d %3d]", 
//                     matrix[71:64], matrix[63:56], matrix[55:48]);
//             $display("[%3d %3d %3d]", 
//                     matrix[47:40], matrix[39:32], matrix[31:24]);
//             $display("[%3d %3d %3d]", 
//                     matrix[23:16], matrix[15:8], matrix[7:0]);
//         end
//     endtask

//     // UART byte transmission task
//     task send_uart_byte;
//         input [7:0] data;
//         integer bit_index;
//         begin
//             // Start bit
//             rx = 0;
//             #(BIT_PERIOD);
            
//             // Data bits (LSB first)
//             for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
//                 rx = data[bit_index];
//                 #(BIT_PERIOD);
//             end
            
//             // Stop bit
//             rx = 1;
//             #(BIT_PERIOD);
//             #(BIT_PERIOD/2);  // Extra delay between bytes
//         end
//     endtask

//     // Task to send matrix data over UART
//     task send_matrix;
//         input [71:0] matrix;
//         input string name;
//         reg [7:0] bytes[0:8];
//         integer idx;
//         begin
//             $display("\nSending %s:", name);
            
//             // Convert matrix to bytes in correct order
//             for(idx = 0; idx < 9; idx = idx + 1) begin
//                 bytes[idx] = matrix[71-idx*8 -: 8];
//             end
            
//             // Send bytes
//             for(idx = 0; idx < 9; idx = idx + 1) begin
//                 $display("Sending byte %0d: %h", idx, bytes[idx]);
//                 send_uart_byte(bytes[idx]);
//                 #(BIT_PERIOD);
//             end
            
//             $display("%s transmission complete at %0t", name, $time);
//         end
//     endtask

//     // Result capture and verification
//     always @(posedge clk) begin
//         if (valid_out) begin
//             captured_result <= result;
//             valid_detected <= 1;
//             $display("\nResult captured at time %0t", $time);
//             display_matrix(result, "Captured Result");
//         end
//     end

//     // Main test sequence
//     initial begin
//         // Initialize signals
//         rx = 1;
//         rst_n = 0;
//         valid_detected = 0;
//         error_count = 0;
//         test_passed = 0;
        
//         // Define test matrices (in correct bit order)
//         // Matrix A = [1 2 3; 4 5 6; 7 8 9]
//         test_matrix_a = {8'd1, 8'd2, 8'd3,
//                         8'd4, 8'd5, 8'd6,
//                         8'd7, 8'd8, 8'd9};
        
//         // Matrix B = [9 8 7; 6 5 4; 3 2 1]
//         test_matrix_b = {8'd9, 8'd8, 8'd7,
//                         8'd6, 8'd5, 8'd4,
//                         8'd3, 8'd2, 8'd1};
        
//         // Expected result = A × B
//         expected_result = {8'd30, 8'd24, 8'd18,
//                           8'd84, 8'd69, 8'd54,
//                           8'd138, 8'd114, 8'd90};

//         // Display test setup
//         $display("\nMatrix Multiplication Test Setup:");
//         display_matrix(test_matrix_a, "Matrix A");
//         display_matrix(test_matrix_b, "Matrix B");
//         display_matrix(expected_result, "Expected Result");

//         // Reset sequence
//         #(CLK_PERIOD * 10);
//         rst_n = 1;
//         #(CLK_PERIOD * 10);

//         // Send matrices
//         send_matrix(test_matrix_a, "Matrix A");
//         #(BIT_PERIOD * 2);
//         send_matrix(test_matrix_b, "Matrix B");

//         // Wait for result with timeout
//         fork
//             begin: wait_for_result
//                 repeat (1000) @(posedge clk);
//                 if (!valid_detected) begin
//                     $display("ERROR: Timeout waiting for valid_out signal");
//                     error_count = error_count + 1;
//                     $finish;
//                 end
//             end

//             begin: check_result
//                 @(posedge valid_detected);
//                 disable wait_for_result;
                
//                 #(CLK_PERIOD * 2);  // Wait for result to stabilize
                
//                 // Compare results
//                 $display("\nValidating Results at time %0t:", $time);
//                 display_matrix(expected_result, "Expected Result");
//                 display_matrix(captured_result, "Actual Result");
                
//                 if (captured_result === expected_result) begin
//                     $display("\nTEST PASSED: Results match exactly!");
//                     test_passed = 1;
//                 end else begin
//                     $display("\nTEST FAILED: Results do not match!");
//                     error_count = error_count + 1;
                    
//                     // Detailed error analysis
//                     for(i = 0; i < 9; i = i + 1) begin
//                         if (captured_result[i*8 +: 8] !== expected_result[i*8 +: 8]) begin
//                             $display("Mismatch at element [%0d]: Expected=%0d, Got=%0d",
//                                    i,
//                                    expected_result[i*8 +: 8],
//                                    captured_result[i*8 +: 8]);
//                         end
//                     end
//                 end
                
//                 // Test summary
//                 $display("\nTest Summary:");
//                 $display("Total Errors: %0d", error_count);
//                 $display("Test Status: %s", test_passed ? "PASSED" : "FAILED");
                
//                 #(BIT_PERIOD * 20);
//                 $finish;
//             end
//         join
//     end

//     // Signal monitoring
//     initial begin
//         $monitor("Time=%0t rst_n=%b rx=%b valid_out=%b", 
//                  $time, rst_n, rx, valid_out);
//     end

//     // Generate waveform file
//     initial begin
//         $dumpfile("matrix_mult_uart_tb.vcd");
//         $dumpvars(0, fast_matrix_mult_3x3_uart_tb);
//     end

// endmodule


