.globl main 
.equ STDOUT, 1
.equ STDIN, 0
.equ __NR_READ, 63
.equ __NR_WRITE, 64
.equ __NR_EXIT, 93

.text
main:
	# main() prolog
	addi sp, sp, -24
	sw ra, 20(sp)
	
    jal sekret_fn

	# main() body
	la a0, prompt
	call puts

	mv a0, sp
	call gets

	mv a0, sp
	call puts

    

	# main() epilog
	lw ra, 20(sp)
	addi sp, sp, 24
	ret

.space 12288

sekret_fn:
	addi sp, sp, -4
	sw ra, 0(sp)
	la a0, sekret_data
	call puts
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

##############################################################
# Add your implementation of puts() and gets() below here
##############################################################
getchar:
    addi sp, sp, -4     
    li a0, 0            # STDIN
    mv a1, sp
    li a2, 1            
    li a7, 63          # Read __NR_READ
    ecall
    lbu a0, 0(sp)
    
    addi sp, sp, 4      
    ret
    
   
putchar:
    addi sp, sp, -4     
    sw a0, 0(sp)        # Save a0
    li a0, 1            # STDOUT
    addi a1, sp, 0      # Address of char
    li a2, 1            
    li a7, 64           # Write __NR_WRITE
    ecall
    
    lw a0, 0(sp)        # Load char into a0
    addi sp, sp, 4      
    ret
    
 
gets:
    addi sp, sp, -12    
    sw ra, 8(sp)        # Save ra
    sw a0, 4(sp)        # Save a0
    sw s0, 0(sp)        # Save s0
    mv s0, a0           # Buffer address to s0

gets_loop:
    jal ra, getchar     # Call getchar
    bltz a0, gets_error # Check for error
    sb a0, 0(s0)        # Store char
    addi s0, s0, 1      # Increment buffer
    li t0, 10           # Load newline
    bne a0, t0, gets_loop # Check newline

    sb zero, 0(s0)
    
    lw ra, 8(sp) 
    lw a0, 4(sp)
    lw s0, 0(sp
    
    addi sp, sp, 12 
    sub a0, s0, a0      # Length
    ret

gets_error:
    lw ra, 8(sp)        # Restore ra
    lw a0, 4(sp)        # a0 has error code
    lw s0, 0(sp)        # Restore s0
    addi sp, sp, 12     # Restore sp
    ret
    

puts:
    addi sp, sp, -12   # Make room for 12 bytes
    sw ra, 8(sp)       # Save ra
    sw s0, 4(sp)       # Save s0
    sw a0, 0(sp)       # Save a0
    
    mv s0, a0          # Copy a0 to s0

puts_loop:
    lb a0, 0(s0)       # Load byte from string
    beqz a0, puts_exit # Check for null terminator
    
    jal ra, putchar    # Call putchar
    addi s0, s0, 1     # Increment string pointer
    j puts_loop        # Continue loop

puts_exit:
    li a0, 10          # Newline
    jal ra, putchar    # Print newline
    
    lw ra, 8(sp)       # Restore ra
    lw s0, 4(sp)       # Restore s0
    lw a0, 0(sp)       # Restore a0
    
    addi sp, sp, 12    # Restore sp
    ret

.data
prompt:   .ascii  "Enter a message: "
prompt_end:

.word 0
sekret_data:
.word 0x73564753, 0x67384762, 0x79393256, 0x3D514762, 0x0000000A
