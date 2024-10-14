.data
# Predefined test data (16-bit BF16 values)
    test_data: 
        .word 0x3f800000    # Corresponds to 1.0
        .word 0xC0200000    # Corresponds to -2.5 
        .word 0x7Fc00001    # Corresponds to NaN 
        .word 0x3FFFFFF8    # Corresponds to 1.999999
        .word 0xC19FFFFF    # Corresponds to -19.999999        

    expected_results:        
        .word 0x3f80     # Expected 1.0 in BF16
        .word 0xC020     # Expected -2.5 in BF16
        .word 0x7Fc0     # Expected NaN in BF16
        .word 0x4000     # Expected 1.999999 in BF16
        .word 0xC1A0     # Expected -19.999999 in BF16

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
    # Load test data
    li t3, 0x7fffffff        # Set t3 to 0x7FFFFFFF (for get absolute value)
    lw t4, 0(t0)             # Load a 16-bit BF16 value from t0 into t4
    
    # Extract exponent and fraction to check for NaN
    and t5, t4, t3           # Mask to get absolute value (no sign)
    li t3, 0x7f800000        # Set t3 to 0x7F800000 (for NaN comparison)
    blt t5, t3, not_nan      # If value is less than NaN, jump to not_nan

    # NaN handling
    srli t4, t4, 16          # Shift right by 16 bits to get BF16
    ori t4, t4, 64           # Force to quiet NaN by OR-ing with 64
    j store_result           # Jump to store_result
    
not_nan:
    # FP32 to BF16 conversion
    srli t5, t4, 16          # Get upper 16 bits of FP32 (high bits of BF16)
    li t3, 0xFFFF            # Set t3 to 0xFFFF 
    andi t5, t5, 1           # Extract the least significant bit
    li t3, 0x7fff            # Set t3 to 0x7FFF 
    add t5, t5, t3           # Add rounding constant to least significant bit
    add t4, t4, t5           # Add rounding adjustment to the original value
    srli t4, t4, 16          # Get BF16
    
store_result:
    # Load expected result
    lw t5, 0(t1)             # Load expected result from expected results into a0

    # Compare the result with the expected value
    beq t4, t5, success      # If they are equal, jump to success label
    la a0, fai               # Load the address of the string " fail "
    j end                   # If not equal, jump to fail label

success: 
    # Output success 
    # Move to next test case
    addi t0, t0, 4           # Move to the next BF16 value (halfword = 4 bytes)
    addi t1, t1, 4           # Move to the next expected FP32 result (word = 4 bytes)
    addi t2, t2, -1          # Decrease the test cases count
    bgtz t2, test_loop       # If test case count > 0, continue loop
    la a0, suc               # Load the address of the string " success "

    # End program successfully
end:
    li a7, 4                 # System call code for printing a string
    ecall
    li a7, 10                # ECALL for exit
    ecall
