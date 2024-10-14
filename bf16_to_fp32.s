    .data
# Predefined test data (16-bit BF16 values)
    test_data: 
        .half 0x3f80    # Corresponds to 1.0 
        .half 0xC020    # Corresponds to -2.5 
        .half 0x7F80    # Corresponds to +Infinity 
        .half 0xFF80    # Corresponds to -Infinity 
        .half 0x7Fc0    # Corresponds to NaN 

    expected_results:
        .word 0x3f800000    # Expected 1.0 in FP32
        .word 0xC0200000    # Expected -2.5 in FP32
        .word 0x7F800000    # Expected +Infinity in FP32
        .word 0xFF800000    # Expected -Infinity in FP32
        .word 0x7Fc00000    # Expected NaN in FP32
        
    length: .word 5
    suc: .string " success "
    fai: .string " fail "
    .text
    .globl _start

_start:
    # Initialize data addresses
    la t0, test_data          # Load address of test data into t0
    la t1, expected_results   # Load address of expected results into t1
    lw t2, length             # Number of test cases

test_loop:
    # Load BF16 data
    lh t3, 0(t0)             # Load a 16-bit BF16 value from t0 into t3
    slli t3, t3, 16          # Shift BF16 value left by 16 bits, converting to 32-bit FP32

    # Load expected FP32 result
    lw t4, 0(t1)             # Load expected 32-bit FP32 result from t1 into t4

    # Compare the result with the expected value
    beq t3, t4, success      # If they are equal, jump to success label
    j fail                   # If not equal, jump to fail label

success: 
    # Output success 
    # Move to next test case
    addi t0, t0, 2           # Move to the next BF16 value (halfword = 2 bytes)
    addi t1, t1, 4           # Move to the next expected FP32 result (word = 4 bytes)
    addi t2, t2, -1          # Decrease the test cases count
    bgtz t2, test_loop       # If test case count > 0, continue loop

    # End program successfully
    la a0, suc               # Load the address of the string " success "
    li a7, 4                 # System call code for printing a string
    ecall
    li a7, 10                # ECALL for exit
    ecall

fail:
    # Handle failure case 
    la a0, fai               # Load the address of the string " fail "
    li a7, 4                 # System call code for printing a string
    ecall
    li a7, 10                # ECALL for exit
    ecall
