`timescale 1ns / 1ps
module serial_matrix_multiplication (
    input clk,
    input reset,
    input start,
    input [15:0] A[0:2][0:2],
    input [15:0] B[0:2][0:2],
    output reg [15:0] C[0:2][0:2],
    output reg done
);
    reg [1:0] i, j, k;
    reg [15:0] temp;
    reg state;

    parameter IDLE = 1'b0, COMPUTE = 1'b1;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i <= 0;
            j <= 0;
            k <= 0;
            C[0][0] <= 0;
            C[0][1] <= 0;
            C[0][2] <= 0;
            C[1][0] <= 0;
            C[1][1] <= 0;
            C[1][2] <= 0;
            C[2][0] <= 0;
            C[2][1] <= 0;
            C[2][2] <= 0;
            temp <= 0;
            state <= IDLE;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        i <= 0;
                        j <= 0;
                        k <= 0;
                        state <= COMPUTE;
                        done <= 0;
                    end
                end
                COMPUTE: begin
                    if (k < 3) begin
                        temp <= temp + A[i][k] * B[k][j];
                        k <= k + 1;
                    end else begin
                        C[i][j] <= temp;
                        temp <= 0;
                        k <= 0;
                        if (j < 2) begin
                            j <= j + 1;
                        end else begin
                            j <= 0;
                            if (i < 2) begin
                                i <= i + 1;
                            end else begin
                                done <= 1;
                                state <= IDLE;
                            end
                        end
                    end
                end
            endcase
        end
    end
endmodule
