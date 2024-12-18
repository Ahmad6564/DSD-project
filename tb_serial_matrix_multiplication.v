`timescale 1ns / 1ps


module tb_serial_matrix_multiplication();
    reg clk;
    reg reset;
    reg start;
    reg [15:0] A[0:2][0:2];
    reg [15:0] B[0:2][0:2];
    wire [15:0] C[0:2][0:2];
    wire done;

    // Instantiate the serial matrix multiplication module
    serial_matrix_multiplication uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .done(done)
    );

    // Generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Initialize inputs and simulate
    initial begin
        reset = 1;
        start = 0;
        #10 reset = 0;

        // Initialize matrix A
        A[0][0] = 16'd1; A[0][1] = 16'd2; A[0][2] = 16'd3;
        A[1][0] = 16'd4; A[1][1] = 16'd5; A[1][2] = 16'd6;
        A[2][0] = 16'd7; A[2][1] = 16'd8; A[2][2] = 16'd9;

        // Initialize matrix B
        B[0][0] = 16'd1; B[0][1] = 16'd2; B[0][2] = 16'd3;
        B[1][0] = 16'd0; B[1][1] = 16'd1; B[1][2] = 16'd0;
        B[2][0] = 16'd0; B[2][1] = 16'd0; B[2][2] = 16'd1;

        // Start the computation
        #20 start = 1;
        #10 start = 0;

        // Wait for computation to complete
        wait(done);

        // Display results
        $display("Matrix C:");
        $display("%d %d %d", C[0][0], C[0][1], C[0][2]);
        $display("%d %d %d", C[1][0], C[1][1], C[1][2]);
        $display("%d %d %d", C[2][0], C[2][1], C[2][2]);

        $finish;
    end
endmodule
