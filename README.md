# DSD-project
 The project is fast matrix multiplication on FPGA. Data must be transferred from PC to FPGA via UART or Ethernet cable and result be sent back and stored in a file. 
## UART One-Way Communication
This repository demonstrates the implementation of a UART (Universal Asynchronous Receiver/Transmitter) one-way communication system on FPGA using Verilog. It includes a UART transmitter module [uart_tx](#uart-tx) and its corresponding testbench  [uart_tx_tb](#uart-tx-tb)
### Overview
UART is a widely used communication protocol that transmits data serially, one bit at a time. This implementation focuses on the one-way communication aspect of UART, where data is transmitted from the FPGA to an external receiver.
###uart_tx One Way communication
![image](https://github.com/user-attachments/assets/1df4b1d0-1395-465f-889e-8208c6ce1ebc)
 
## UART two-way communication

Implementing a UARt two-way communication system, enabling data transmission and reception between devices.

### Key Features:
* Transmission (TX): Sends 8-bit parallel data as serial data through the UART protocol.
* Reception (RX): Receives serial data and converts it back to 8-bit parallel data.
* Transmission Control: The transmission process is controlled via a tx_start signal, which triggers the start of data transmission.
* Receiver Control: The receiver detects the start bit, reads each data bit serially, and outputs the received byte when ready.
* Busy/Ready Flags: Provides feedback on whether the transmitter is busy (tx_busy) and whether the receiver has successfully received a byte (rx_ready).

#### Components:
* Transmitter Module: Implements the logic to send data bit by bit, starting with a start bit and ending with a stop bit.
* Receiver Module: Captures serial data, stores it in a buffer, and outputs the received data when the transmission is complete.
* Top-Level Module [uart_two_way_comm](#uart_two_way_comm): Combines both the transmitter and receiver modules to enable full two-way communication.

![image](https://github.com/user-attachments/assets/ba8b69ce-c5fa-4afb-9e4b-d1dce3bbf091)



## Serial Matrix Multiplication on FPGA

#### Overview
This project implements **Serial Matrix Multiplication** on an FPGA. The design focuses on multiplying two matrices in a serial fashion, where data is processed sequentially for each element of the matrices. This approach reduces hardware resource utilization at the cost of increased computation time.

#### Key Features:
- **Serial Multiplication**: The system reads one matrix element at a time, performs multiplication and accumulation sequentially.
- **Matrix Sizes**: Configurable to work for matrices of size **3x3** or **10x10**.
- **UART Communication**: Data is transferred between the PC and FPGA using a UART interface.
- **Resource-Efficient Design**: The serial processing minimizes the number of multipliers required, suitable for FPGA implementations with limited hardware resources.
- **Output Storage**: The final result of the matrix multiplication is sent back to the PC and stored in a file.

#### Workflow:
1. **Data Input**: The two matrices are sent to the FPGA via UART.
2. **Serial Computation**:
   - Multiply corresponding elements of the matrices.
   - Accumulate the results in a register to compute each output element.
3. **Result Transmission**: The computed matrix is sent back to the PC through UART.

#### Files:
1. **serial_matrix_mult.v**: Implements the serial matrix multiplication logic.
2. **uart_interface.v**: Handles UART communication for data input/output.
3. **top_module.v**: Combines the matrix multiplication logic and UART interface.
4. **testbench.v**: Testbench to simulate and verify the design behavior.

#### How It Works:
- **Input Format**: Matrix data is sent as a sequence of numbers via UART.
- **Computation**:
   - A nested loop-like structure processes one element of the matrices at a time.
   - Results are stored temporarily in an accumulation register.
- **Output**: The final result matrix is sent serially back to the PC using UART.

#### Applications:
- Ideal for FPGA-based systems where resource optimization is critical.
- Useful for low-power embedded systems requiring matrix operations.

---

This project combines matrix multiplication, serial data handling, and FPGA hardware design, demonstrating efficient resource utilization for computational tasks.

