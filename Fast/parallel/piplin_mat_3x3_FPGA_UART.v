// Code your design here
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
    // Process elements in correct order
    // First row: C00, C01, C02
    result[71:64] <= (matrix_a[71:64] * matrix_b[71:64]) + 
                     (matrix_a[63:56] * matrix_b[47:40]) + 
                     (matrix_a[55:48] * matrix_b[23:16]);
                     
    result[63:56] <= (matrix_a[71:64] * matrix_b[63:56]) + 
                     (matrix_a[63:56] * matrix_b[39:32]) + 
                     (matrix_a[55:48] * matrix_b[15:8]);
                     
    result[55:48] <= (matrix_a[71:64] * matrix_b[55:48]) + 
                     (matrix_a[63:56] * matrix_b[31:24]) + 
                     (matrix_a[55:48] * matrix_b[7:0]);

    // Second row: C10, C11, C12
    result[47:40] <= (matrix_a[47:40] * matrix_b[71:64]) + 
                     (matrix_a[39:32] * matrix_b[47:40]) + 
                     (matrix_a[31:24] * matrix_b[23:16]);
                     
    result[39:32] <= (matrix_a[47:40] * matrix_b[63:56]) + 
                     (matrix_a[39:32] * matrix_b[39:32]) + 
                     (matrix_a[31:24] * matrix_b[15:8]);
                     
    result[31:24] <= (matrix_a[47:40] * matrix_b[55:48]) + 
                     (matrix_a[39:32] * matrix_b[31:24]) + 
                     (matrix_a[31:24] * matrix_b[7:0]);

    // Third row: C20, C21, C22
    result[23:16] <= (matrix_a[23:16] * matrix_b[71:64]) + 
                     (matrix_a[15:8]  * matrix_b[47:40]) + 
                     (matrix_a[7:0]   * matrix_b[23:16]);
                     
    result[15:8]  <= (matrix_a[23:16] * matrix_b[63:56]) + 
                     (matrix_a[15:8]  * matrix_b[39:32]) + 
                     (matrix_a[7:0]   * matrix_b[15:8]);
                     
    result[7:0]   <= (matrix_a[23:16] * matrix_b[55:48]) + 
                     (matrix_a[15:8]  * matrix_b[31:24]) + 
                     (matrix_a[7:0]   * matrix_b[7:0]);

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





module uart_rx #(
    parameter CLKS_PER_BIT = 868
) (
    input wire clk,
    input wire rst_n,
    input wire rx,
    output reg [7:0] rx_data,
    output reg rx_done
);
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;

    reg [1:0] state;
    reg [31:0] clk_count;
    reg [2:0] bit_index;
    reg rx_data_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            rx_done <= 0;
            clk_count <= 0;
            bit_index <= 0;
            rx_data <= 8'h00;
            rx_data_r <= 1'b1;
        end else begin
            rx_data_r <= rx;
            case (state)
                IDLE: begin
                    rx_done <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx_data_r == 1'b0) state <= START;
                end
                START: begin
                    if (clk_count == (CLKS_PER_BIT-1)/2) begin
                        if (rx_data_r == 1'b0) begin
                            clk_count <= 0;
                            state <= DATA;
                        end else state <= IDLE;
                    end else clk_count <= clk_count + 1;
                end
                DATA: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_data[bit_index] <= rx_data_r;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= STOP;
                        end
                    end
                end
                STOP: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        rx_done <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule

////////////////////// UART Transmitter Module //////////////////////
module uart_tx #(
    parameter CLKS_PER_BIT = 868
) (
    input wire clk,
    input wire rst_n,
    input wire [7:0] tx_data,
    input wire tx_start,
    output reg tx
);
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;

    reg [1:0] state;
    reg [31:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] tx_data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx <= 1'b1;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (tx_start) begin
                        tx_data_reg <= tx_data;
                        state <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= DATA;
                    end
                end
                DATA: begin
                    tx <= tx_data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= STOP;
                        end
                    end
                end
                STOP: begin
                    tx <= 1'b1;
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule





module fast_matrix_mult_3x3_uart (
    input wire clk,
    input wire rst_n,
    input wire rx,
    output wire tx,
    output wire [71:0] result,
    output wire valid_out
);
    parameter CLKS_PER_BIT = 87;  // Changed for simulation speed

    // Internal signals
    reg [71:0] matrix_a;
    reg [71:0] matrix_b;
    wire [7:0] rx_data;
    wire rx_done;
    reg [3:0] byte_count;
    reg start_mult;
    reg computation_done;
    
    // State machine states
    localparam IDLE = 2'b00;
    localparam RECEIVE_A = 2'b01;
    localparam RECEIVE_B = 2'b10;
    localparam COMPUTE = 2'b11;
    reg [1:0] state;

    // Edge detection for rx_done
    reg prev_rx_done;
    wire rx_done_edge;
    
    always @(posedge clk) begin
        prev_rx_done <= rx_done;
    end
    assign rx_done_edge = rx_done && !prev_rx_done;

    // Instantiate UART receiver
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Instantiate matrix multiplier
    fast_matrix_mult_3x3 matrix_mult (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_mult),
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .result(result),
        .valid_out(valid_out)
    );

    // Instantiate UART transmitter
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(result[7:0]),
        .tx_start(valid_out),
        .tx(tx)
    );
   
  // Control logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        byte_count <= 0;
        matrix_a <= 72'd0;
        matrix_b <= 72'd0;
        start_mult <= 0;
    end else begin
        case (state)
            IDLE: begin
                start_mult <= 0;
                if (rx_done_edge) begin
                    state <= RECEIVE_A;
                    byte_count <= 1;
                    matrix_a[71:64] <= rx_data; // Store in MSB
                end
            end
            
            RECEIVE_A: begin
                if (rx_done_edge) begin
                    case (byte_count)
                        1: matrix_a[63:56] <= rx_data;
                        2: matrix_a[55:48] <= rx_data;
                        3: matrix_a[47:40] <= rx_data;
                        4: matrix_a[39:32] <= rx_data;
                        5: matrix_a[31:24] <= rx_data;
                        6: matrix_a[23:16] <= rx_data;
                        7: matrix_a[15:8]  <= rx_data;
                        8: matrix_a[7:0]   <= rx_data;
                    endcase
                    
                    if (byte_count == 8) begin
                        state <= RECEIVE_B;
                        byte_count <= 0;
                    end else begin
                        byte_count <= byte_count + 1;
                    end
                end
            end

            RECEIVE_B: begin
                if (rx_done_edge) begin
                    case (byte_count)
                        0: matrix_b[71:64] <= rx_data;
                        1: matrix_b[63:56] <= rx_data;
                        2: matrix_b[55:48] <= rx_data;
                        3: matrix_b[47:40] <= rx_data;
                        4: matrix_b[39:32] <= rx_data;
                        5: matrix_b[31:24] <= rx_data;
                        6: matrix_b[23:16] <= rx_data;
                        7: matrix_b[15:8]  <= rx_data;
                        8: matrix_b[7:0]   <= rx_data;
                    endcase
                    
                    if (byte_count == 8) begin
                        state <= COMPUTE;
                        start_mult <= 1;
                    end else begin
                        byte_count <= byte_count + 1;
                    end
                end
            end

            COMPUTE: begin
                start_mult <= 0;
                if (valid_out) begin
                    state <= IDLE;
                end
            end
        endcase
    end
end
  
  
endmodule
