# FPGA-Based 3x3 Matrix Multiplication
## Project Overview

This part implements a high-performance 3x3 matrix multiplication system on FPGA using Verilog HDL. The design features a pipelined architecture with processing elements (PEs) and includes comprehensive testbench verification.

## Architecture

The implementation consists of two main modules:

1. Processing Element (PE)
* Performs elementary multiply-accumulate operations
* Pipelined design for optimal throughput
* 8-bit input precision with 16-bit output precision
2. Matrix Multiplication Controller
* Manages 3x3 matrix multiplication
* State machine-based control flow (IDLE → LOAD → COMPUTE → DONE)
* Parallel processing using multiple PEs

## Specifications
* Matrix Size: 3x3
* Input Data Width: 8 bits per element
* Output Data Width: 8 bits per element
* Clock Frequency: 100 MHz
* Total Input Width: 72 bits per matrix (9 elements × 8 bits)
* Total Output Width: 72 bits (9 elements × 8 bits)

## Module Interface  
#### processing_element
![image](https://github.com/user-attachments/assets/58811dfe-bb77-463e-b264-6bbc908e3b61)
#### Matrix Multiplication Controller
![image](https://github.com/user-attachments/assets/53daadab-e796-4a4a-939c-d1da9ed35cd3)


## Features
* Pipelined architecture for high throughput
* DSP-optimized multiplication
* Four-stage computation process
* Automatic result validation
* Comprehensive test suite
* Real-time status monitoring

## Test Cases
The testbench includes four fundamental test cases:
* Standard matrix multiplication
* Identity matrix multiplication
* Zero matrix multiplication
* All-ones matrix multiplication

## Verification Features
* Automated result verification
* Matrix display functionality
* Timing analysis
* Timeout detection
* Detailed error reporting
* Signal monitoring

## Test Output Format

![image](https://github.com/user-attachments/assets/3d1061ef-048c-4300-9e95-9763d6068345)
![image](https://github.com/user-attachments/assets/09fb0643-d255-40dc-b346-b933e34c6963)
![image](https://github.com/user-attachments/assets/2011260a-8d0c-4dcb-a3cc-e533c045fc59)
![image](https://github.com/user-attachments/assets/1748df59-51a1-4a87-8501-92d2a1ce80a6)


## Implementation Details
### State Machine States:
* IDLE (2'b00)
* LOAD (2'b01)
* COMPUTE (2'b10)
* DONE (2'b11)



