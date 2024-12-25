`timescale 1ns / 1ps
module fast_matrix_mult_3x3_tb;
    reg clk;
    reg rst_n;
    reg start;
    reg [71:0] matrix_a;
    reg [71:0] matrix_b;
    wire [71:0] result;
    wire valid_out;
    
    integer i;
    integer test_case;
    reg [71:0] expected_result;
    time start_time;

    // Instantiate the main module
    fast_matrix_mult_3x3 uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .result(result),
        .valid_out(valid_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end

    // Task for matrix display
    task display_matrix;
        input [71:0] matrix;
        input [127:0] matrix_name;
        begin
            $display("\n%s:", matrix_name);
            $display("[%3d %3d %3d]", matrix[71:64], matrix[63:56], matrix[55:48]);
            $display("[%3d %3d %3d]", matrix[47:40], matrix[39:32], matrix[31:24]);
            $display("[%3d %3d %3d]", matrix[23:16], matrix[15:8], matrix[7:0]);
        end
    endtask

    // Task for verification
    task verify_result;
        input [71:0] actual;
        input [71:0] expected;
        input [31:0] test_num;
        begin
            if (actual === expected)
                $display("Test Case %0d: PASSED", test_num);
            else begin
                $display("Test Case %0d: FAILED", test_num);
                $display("Expected Matrix (Packed): %h", expected);
                $display("Actual Matrix (Packed):   %h", actual);
                for (i = 0; i < 9; i = i + 1)
                    $display("Position %0d: Expected=%0d, Got=%0d", 
                            i, expected[i*8 +: 8], actual[i*8 +: 8]);
            end
        end
    endtask

    // Task for running test case
    task run_test_case;
        input [71:0] mat_a;
        input [71:0] mat_b;
        input [71:0] expected;
        input [31:0] test_num;
        begin
            // Initialize inputs
            matrix_a = mat_a;
            matrix_b = mat_b;
            expected_result = expected;
            
            $display("\nTest Case %0d:", test_num);
            display_matrix(matrix_a, "Matrix A");
            display_matrix(matrix_b, "Matrix B");
            
            // Start computation
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Wait for completion with timeout
            wait(valid_out || ($time - start_time > 10000));
				if (!valid_out) begin
					$display("Test Case %0d: Timeout - valid_out not asserted", test_num);
					disable run_test_case; // Exit the task by disabling it
				end
            
            // Allow result stabilization
            #10;
            
            display_matrix(result, "Result Matrix");
            display_matrix(expected_result, "Expected Matrix");
            
            verify_result(result, expected_result, test_num);
            
            // Wait between test cases
            #50;
        end
    endtask

    // Time tracking
    always @(posedge start) start_time = $time;

    // Test stimulus
    initial begin
        // Initialize
        rst_n = 0;
        start = 0;
        matrix_a = 0;
        matrix_b = 0;
        test_case = 0;
        
        // Reset sequence
        #100;
        rst_n = 1;
        #20;

        // Test cases
        run_test_case(
            {8'd1, 8'd2, 8'd3,  // Matrix A
             8'd4, 8'd5, 8'd6,
             8'd7, 8'd8, 8'd9},
            {8'd9, 8'd8, 8'd7,  // Matrix B
             8'd6, 8'd5, 8'd4,
             8'd3, 8'd2, 8'd1},
            {8'd30, 8'd24, 8'd18,  // Expected Result
             8'd84, 8'd69, 8'd54,
             8'd138, 8'd114, 8'd90},
            1
        );

        run_test_case(
            {8'd1, 8'd0, 8'd0,  // Identity Matrix
             8'd0, 8'd1, 8'd0,
             8'd0, 8'd0, 8'd1},
            {8'd9, 8'd8, 8'd7,  // Test Matrix
             8'd6, 8'd5, 8'd4,
             8'd3, 8'd2, 8'd1},
            {8'd9, 8'd8, 8'd7,  // Expected Result
             8'd6, 8'd5, 8'd4,
             8'd3, 8'd2, 8'd1},
            2
        );

        run_test_case(
            {8'd0, 8'd0, 8'd0,  // Zero Matrix
             8'd0, 8'd0, 8'd0,
             8'd0, 8'd0, 8'd0},
            {8'd9, 8'd8, 8'd7,  // Any Matrix
             8'd6, 8'd5, 8'd4,
             8'd3, 8'd2, 8'd1},
            {8'd0, 8'd0, 8'd0,  // Expected Result
             8'd0, 8'd0, 8'd0,
             8'd0, 8'd0, 8'd0},
            3
        );

        run_test_case(
            {8'd1, 8'd1, 8'd1,  // Matrix A
             8'd1, 8'd1, 8'd1,
             8'd1, 8'd1, 8'd1},
            {8'd1, 8'd1, 8'd1,  // Matrix B
             8'd1, 8'd1, 8'd1,
             8'd1, 8'd1, 8'd1},
            {8'd3, 8'd3, 8'd3,  // Expected Result
             8'd3, 8'd3, 8'd3,
             8'd3, 8'd3, 8'd3},
            4
        );

        // End of simulation
        #100;
        $display("\nAll test cases completed!");
        $finish;
    end

    // Monitor changes in key signals
    initial begin
        $monitor("Time=%0d rst_n=%b start=%b valid_out=%b", 
                 $time, rst_n, start, valid_out);
    end

endmodule


