# Fast 3x3 Matrix Multiplication with UART Communication

This project implements fast matrix multiplication for 3x3 matrices on an FPGA. The design includes a UART interface for data communication, allowing matrices to be transmitted and results to be received serially.

## Features
- **Fast Matrix Multiplication:** 
  - Uses a pipelined approach to compute the product of two 3x3 matrices efficiently.
- **UART Communication:** 
  - Allows external devices to transmit matrices to the FPGA and receive computed results via serial communication.
- **Modular Design:**
  - Includes separate modules for processing elements, UART receiver, UART transmitter, and matrix computation.

---

## File Structure
- **`processing_element`**:
  - A single element in the matrix multiplication pipeline that computes the product of two input values and adds it to an accumulated sum.

- **`fast_matrix_mult_3x3`**:
  - The main module that coordinates matrix multiplication for 3x3 matrices using the processing elements.

- **`uart_rx`**:
  - A UART receiver module to receive data serially.

- **`uart_tx`**:
  - A UART transmitter module to send data serially.

- **`fast_matrix_mult_3x3_uart`**:
  - A top-level module integrating the UART interface and matrix multiplication logic.

---

## Module Descriptions

### 1. **Processing Element (`processing_element`)**
- **Inputs:** 
  - `clk`: Clock signal.
  - `rst_n`: Active-low reset.
  - `a_in`: First input operand (8 bits).
  - `b_in`: Second input operand (8 bits).
  - `sum_in`: Accumulated sum input (16 bits).
- **Output:** 
  - `sum_out`: Accumulated sum output (16 bits).

This module performs the multiplication of `a_in` and `b_in` and adds the result to `sum_in`.

---

### 2. **Fast Matrix Multiplication (`fast_matrix_mult_3x3`)**
- **Inputs:**
  - `clk`, `rst_n`, `start`: Control signals.
  - `matrix_a`, `matrix_b`: 3x3 matrices packed into 72-bit vectors.
- **Outputs:**
  - `result`: Resultant matrix packed into a 72-bit vector.
  - `valid_out`: Indicates when the result is ready.

This module computes the product of two 3x3 matrices.

---

### 3. **UART Receiver (`uart_rx`)**
- **Inputs:**
  - `clk`, `rst_n`: Control signals.
  - `rx`: Serial input.
- **Outputs:**
  - `rx_data`: 8-bit received data.
  - `rx_done`: Indicates when a byte is received.

This module receives serial data and outputs it in 8-bit chunks.

---

### 4. **UART Transmitter (`uart_tx`)**
- **Inputs:**
  - `clk`, `rst_n`: Control signals.
  - `tx_data`: 8-bit data to transmit.
  - `tx_start`: Signal to start transmission.
- **Output:**
  - `tx`: Serial output.

This module sends data serially.

---

### 5. **Top-Level Module (`fast_matrix_mult_3x3_uart`)**
- **Inputs:**
  - `clk`, `rst_n`: Control signals.
  - `rx`: UART serial input.
- **Outputs:**
  - `tx`: UART serial output.
  - `result`: Matrix multiplication result.
  - `valid_out`: Indicates when the result is ready.

This module integrates UART communication and matrix multiplication logic, allowing matrices to be transmitted and results received serially.

---


## Simulation
- Use the `uart_rx` module to simulate receiving matrices.
- Use the `fast_matrix_mult_3x3` module to verify multiplication logic.
- Use the `uart_tx` module to simulate transmitting results.

---


## Parameters and Constants
- **`CLKS_PER_BIT`**: Defines the number of clock cycles per UART bit. Adjust based on your system clock and desired baud rate.

### OUTPUT of matrix multiplication

![image](https://github.com/user-attachments/assets/8b91aedb-731e-48c3-b329-e37d90d1799a)
![image](https://github.com/user-attachments/assets/53e79568-dc0c-4fa7-b853-83d4bc6c3fbd)


