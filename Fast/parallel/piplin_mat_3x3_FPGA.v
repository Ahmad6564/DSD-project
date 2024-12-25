`timescale 1ns / 1ps
////////////////////// Processing Element Module //////////////////////
module processing_element (
    input wire clk,
    input wire rst_n,
    input wire [7:0] a_in,
    input wire [7:0] b_in,
    input wire [15:0] sum_in,
    output reg [15:0] sum_out
);
    reg [15:0] mult_result;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mult_result <= 16'd0;
            sum_out <= 16'd0;
        end else begin
            mult_result <= a_in * b_in;
            sum_out <= sum_in + mult_result;
        end
    end
endmodule

////////////////////// Main Matrix Multiplication Module //////////////////////
module fast_matrix_mult_3x3 (
    input wire clk,                        // 100MHz system clock
    input wire rst_n,                      // Active low reset
    input wire start,                      // Start computation
    input wire [71:0] matrix_a,            // First matrix (9x8 bits = 72 bits)
    input wire [71:0] matrix_b,            // Second matrix (9x8 bits = 72 bits)
    output reg [71:0] result,              // Result matrix (9x8 bits = 72 bits)
    output reg valid_out                   // Result valid flag
);

    // State definitions
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam COMPUTE = 2'b10;
    localparam DONE = 2'b11;

    // Internal registers to store matrix elements
    reg [7:0] stage1_regs_a [0:8];
    reg [7:0] stage1_regs_b [0:8];
    reg [15:0] stage2_mult [0:8];
    reg [15:0] stage3_acc [0:2];

    // Control signals
    reg [1:0] state;
    reg [2:0] compute_count;
    
    // Processing Element instances
    wire [15:0] pe_results [0:8];
    
    genvar i;
    generate
        for(i = 0; i < 9; i = i + 1) begin : pe_array
            processing_element pe (
                .clk(clk),
                .rst_n(rst_n),
                .a_in(stage1_regs_a[i]),
                .b_in(stage1_regs_b[i]),
                .sum_in(16'd0),
                .sum_out(pe_results[i])
            );
        end
    endgenerate

    integer j;
    // Main control FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            compute_count <= 0;
            valid_out <= 0;
            result <= 72'd0;
            // Reset all pipeline registers
            for (j = 0; j < 9; j = j + 1) begin
                stage1_regs_a[j] <= 8'd0;
                stage1_regs_b[j] <= 8'd0;
                stage2_mult[j] <= 16'd0;
                if (j < 3) stage3_acc[j] <= 16'd0;
            end
        end else begin
            case (state)
                IDLE: begin
                    valid_out <= 0;
                    if (start) begin
                        state <= LOAD;
                        compute_count <= 0;
                    end
                end
                
                LOAD: begin
                    // Load input matrices from packed vectors
                    for (j = 0; j < 9; j = j + 1) begin
                        stage1_regs_a[j] <= matrix_a[j*8 +: 8];
                        stage1_regs_b[j] <= matrix_b[j*8 +: 8];
                    end
                    state <= COMPUTE;
                end
                
                
					
					COMPUTE: begin
        // Corrected matrix multiplication logic
        // First row
        result[7:0]   <= (matrix_a[7:0]   * matrix_b[7:0]) + 
                        (matrix_a[15:8]  * matrix_b[31:24]) + 
                        (matrix_a[23:16] * matrix_b[55:48]);
        
        result[15:8]  <= (matrix_a[7:0]   * matrix_b[15:8]) + 
                        (matrix_a[15:8]  * matrix_b[39:32]) + 
                        (matrix_a[23:16] * matrix_b[63:56]);
        
        result[23:16] <= (matrix_a[7:0]   * matrix_b[23:16]) + 
                        (matrix_a[15:8]  * matrix_b[47:40]) + 
                        (matrix_a[23:16] * matrix_b[71:64]);

        // Second row
        result[31:24] <= (matrix_a[31:24] * matrix_b[7:0]) + 
                        (matrix_a[39:32] * matrix_b[31:24]) + 
                        (matrix_a[47:40] * matrix_b[55:48]);
        
        result[39:32] <= (matrix_a[31:24] * matrix_b[15:8]) + 
                        (matrix_a[39:32] * matrix_b[39:32]) + 
                        (matrix_a[47:40] * matrix_b[63:56]);
        
        result[47:40] <= (matrix_a[31:24] * matrix_b[23:16]) + 
                        (matrix_a[39:32] * matrix_b[47:40]) + 
                        (matrix_a[47:40] * matrix_b[71:64]);

        // Third row
        result[55:48] <= (matrix_a[55:48] * matrix_b[7:0]) + 
                        (matrix_a[63:56] * matrix_b[31:24]) + 
                        (matrix_a[71:64] * matrix_b[55:48]);
        
        result[63:56] <= (matrix_a[55:48] * matrix_b[15:8]) + 
                        (matrix_a[63:56] * matrix_b[39:32]) + 
                        (matrix_a[71:64] * matrix_b[63:56]);
        
        result[71:64] <= (matrix_a[55:48] * matrix_b[23:16]) + 
                        (matrix_a[63:56] * matrix_b[47:40]) + 
                        (matrix_a[71:64] * matrix_b[71:64]);

        if (compute_count < 4) begin
            compute_count <= compute_count + 1;
        end else begin
            state <= DONE;
        end
    end
					

                
                DONE: begin
                    valid_out <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
