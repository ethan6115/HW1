    .data
n:      .word 10                 # Input value n

    .text
    .globl main
main:
    lw a0, n                    # Load n into a0
    li t0, 1                    # first = 1 (ways to reach step 1)
    li t1, 2                    # second = 2 (ways to reach step 2)

    beq a0, t1, return_two       # If n == 2, return 2
    beq a0, t0, return_one       # If n == 1, return 1
    
    li t2, 2                    # Initialize i to 2

loop:
    add t3, t0, t1              # ans = a + b
    addi t2, t2, 1              # Increment i(move to here since data hazard)
    addi t0, t1, 0                 # a = b
    addi t1, t3, 0                 # b = ans
    blt t2, a0, loop            # If i < n, go to loop

return_result:
    
    addi a0, t3, 0                 # Move result to a0
    li a7, 1                    # Prepare to print result(move to here since data hazard)
    j print_result
    
return_one:
    li a0, 1                    # Return 1
    j print_result

return_two:
    li a0, 2                    # Return 2
    j print_result

print_result:
    ecall                       # Print the result
