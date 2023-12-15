# checkpoint1

1. How many stages is the datapath you’ve drawn? (i.e. How many cycles does it take to execute 1 instruction?)

    A: 5 stages

2. How do you handle ALU → ALU hazards?
    addi x1, x2, 100
    addi x2, x1, 100

    A: `alu_result_m` 数据从 `Me` 阶段转发到 `Ex` 阶段，通过危险控制器 `u_hazard` 控制转发选择器选择合理的寄存器文件数据。

3. How do you handle ALU → MEM hazards?
    addi x1, x2, 100
    sw x1, 0(x3)

    A: 同第二题

4. How do you handle MEM → ALU hazards?
    lw x1, 0(x3)
    addi x1, x1, 100

    A: `mem_data_m` 数据从 `Me` 阶段转发到 `Ex` 阶段，通过危险控制器 `u_hazard` 控制转发选择器选择合理的 `rd_e` 数据。

5. How do you handle MEM → MEM hazards?
    lw x1, 0(x2)
    sw x1, 4(x2)
    also consider:
    lw x1, 0(x2)
    sw x3, 0(x1)

    A: `mem_data_m` 数据从 `Me` 阶段转发到 `Ex` 阶段，通过危险控制器 `u_harzard` 控制转发选择器选择合理的 `rd1_e` 数据。

6. Do you need special handling for 2 cycle apart hazards?
    addi x1, x2, 100
    nop
    addi x1, x1, 100

    A: 需要。`wd_m` 数据从 `Wb` 阶段转发到 `Ex` 阶段，通过危险控制器 `u_harzard` 控制转发选择器选择合理的 `rd_e` 数据

7. How do you handle branch control hazards? (What is the mispredict latency, what prediction scheme are you using, are you just injecting NOPs until the branch is resolved, what about data hazards in the branch?)

8. How do you handle jump control hazards? Consider jal and jalr separately. What optimizations can be made to special-case handle jal?

9. What is the most likely critical path in your design?

10. Where do the UART modules, instruction, and cycle counters go? How are you going to drive uart_tx_data_in_valid and uart_rx_data_out_ready (give logic expressions)?

11. What is the role of the CSR register? Where does it go?

12. When do we read from BIOS for instructions? When do we read from IMem for instructions? How do we switch from BIOS address space to IMem address space? In which case can we write to IMem, and why do we need to write to IMem? How do we know if a memory instruction is intended for DMem or any IO device?
