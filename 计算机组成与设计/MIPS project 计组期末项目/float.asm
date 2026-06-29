# ============================================================
# IEEE 754 Single-Precision Float Simulator
# File: float.asm
# Authors: [Your Name]
# Tool:    MARS 4.5 MIPS Simulator
#
# Project Requirements Fulfilled:
#   (1) Menu-driven text interface
#   (2) Accept decimal input, store as IEEE 754, display in
#       binary and hexadecimal
#   (3) Float add, subtract, multiply
#   (4) Integer instructions only - no FPU instructions used
#
# Register Conventions (saved/restored across all calls):
#   $s0 = sign bit of current number being parsed (0=pos,1=neg)
#   $s1 = integer part of current number
#   $s2 = fraction numerator (e.g. "625" for ".625")
#   $s3 = IEEE 754 encoding of operand A
#   $s4 = IEEE 754 encoding of operand B
#   $s5 = IEEE 754 encoding of result
#   $sp = stack pointer (used for saving $ra and $s regs)
#
# Memory Layout:
#   str_buf_a / str_buf_b : input string buffers (32 bytes each)
#   All string literals stored in .data segment
# ============================================================

.data
    # Input buffers
    str_buf_a:    .space 32         # buffer for number A input
    str_buf_b:    .space 32         # buffer for number B input

    # Menu and prompts (ASCII only to avoid MARS encoding issues)
    str_menu:     .asciiz "\n=== IEEE 754 Float Simulator ===\n1. Decimal -> IEEE 754\n2. Float Add (A+B)\n3. Float Sub (A-B)\n4. Float Mul (A*B)\n0. Exit\nChoice: "
    str_enter_a:  .asciiz "Enter number A: "
    str_enter_b:  .asciiz "Enter number B: "

    # Output labels
    str_a_label:  .asciiz "A =      "
    str_b_label:  .asciiz "B =      "
    str_result:   .asciiz "Result:  "
    str_bin:      .asciiz "Binary:  "
    str_hex:      .asciiz "Hex:     "
    str_newline:  .asciiz "\n"
    str_invalid:  .asciiz "Invalid choice. Try again.\n"
    str_sep:      .asciiz "--------------------------------\n"

.text
.globl main

# ============================================================
# MAIN
# Entry point. Displays menu in a loop until user chooses 0.
# Uses syscall 5 (read int) for menu selection.
# ============================================================
main:
menu_loop:
    # Print menu string
    li   $v0, 4
    la   $a0, str_menu
    syscall

    # Read user choice as integer
    li   $v0, 5
    syscall
    move $t0, $v0               # t0 = menu choice

    # Dispatch based on choice
    beq  $t0, $zero, menu_exit  # 0 -> exit
    li   $t1, 1
    beq  $t0, $t1, do_convert   # 1 -> decimal to IEEE 754
    li   $t1, 2
    beq  $t0, $t1, do_add       # 2 -> addition
    li   $t1, 3
    beq  $t0, $t1, do_sub       # 3 -> subtraction
    li   $t1, 4
    beq  $t0, $t1, do_mul       # 4 -> multiplication

    # Unknown choice
    li   $v0, 4
    la   $a0, str_invalid
    syscall
    j    menu_loop

menu_exit:
    li   $v0, 10
    syscall

# ============================================================
# do_convert
# Option 1: Read one decimal number, display its IEEE 754
# encoding in both binary and hexadecimal formats.
# ============================================================
do_convert:
    # Prompt and read input string
    li   $v0, 4
    la   $a0, str_enter_a
    syscall
    li   $v0, 8
    la   $a0, str_buf_a
    li   $a1, 32
    syscall

    # Convert string -> IEEE 754 (result in $v0)
    la   $a0, str_buf_a
    jal  decimal_to_float
    move $s3, $v0               # save result

    # Print separator
    li   $v0, 4
    la   $a0, str_sep
    syscall

    # Print binary representation
    li   $v0, 4
    la   $a0, str_bin
    syscall
    move $a0, $s3
    jal  print_binary

    # Print hexadecimal representation
    li   $v0, 4
    la   $a0, str_hex
    syscall
    move $a0, $s3
    jal  print_hex

    j    menu_loop

# ============================================================
# do_add
# Option 2: Read A and B, compute A + B, display result.
# ============================================================
do_add:
    jal  read_two_operands      # $s3=A, $s4=B
    move $a0, $s3
    move $a1, $s4
    jal  float_add              # $v0 = A + B
    move $s5, $v0
    jal  print_result
    j    menu_loop

# ============================================================
# do_sub
# Option 3: Read A and B, compute A - B.
# Subtraction is implemented as A + (-B):
#   negate B by flipping its sign bit (XOR with 0x80000000)
# ============================================================
do_sub:
    jal  read_two_operands      # $s3=A, $s4=B
    li   $t0, 0x80000000
    xor  $s4, $s4, $t0          # negate B: flip sign bit
    move $a0, $s3
    move $a1, $s4               # now A1 = -B
    jal  float_add              # A + (-B) = A - B
    move $s5, $v0
    # restore original B for display (flip sign back)
    xor  $s4, $s4, $t0
    jal  print_result
    j    menu_loop

# ============================================================
# do_mul
# Option 4: Read A and B, compute A * B.
# ============================================================
do_mul:
    jal  read_two_operands      # $s3=A, $s4=B
    move $a0, $s3
    move $a1, $s4
    jal  float_mul              # $v0 = A * B
    move $s5, $v0
    jal  print_result
    j    menu_loop

# ============================================================
# read_two_operands
# Reads strings for A and B, converts both to IEEE 754.
# Output: $s3 = IEEE 754(A),  $s4 = IEEE 754(B)
# Saves/restores $ra via stack.
# ============================================================
read_two_operands:
    sub  $sp, $sp, 4
    sw   $ra, 0($sp)

    # Read A
    li   $v0, 4
    la   $a0, str_enter_a
    syscall
    li   $v0, 8
    la   $a0, str_buf_a
    li   $a1, 32
    syscall
    la   $a0, str_buf_a
    jal  decimal_to_float
    move $s3, $v0               # s3 = A

    # Read B
    li   $v0, 4
    la   $a0, str_enter_b
    syscall
    li   $v0, 8
    la   $a0, str_buf_b
    li   $a1, 32
    syscall
    la   $a0, str_buf_b
    jal  decimal_to_float
    move $s4, $v0               # s4 = B

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# ============================================================
# print_result
# Displays A, B, and Result in binary format, plus Result hex.
# ============================================================
print_result:
    sub  $sp, $sp, 4
    sw   $ra, 0($sp)

    li   $v0, 4
    la   $a0, str_sep
    syscall

    # Print A
    li   $v0, 4
    la   $a0, str_a_label
    syscall
    move $a0, $s3
    jal  print_binary

    # Print B
    li   $v0, 4
    la   $a0, str_b_label
    syscall
    move $a0, $s4
    jal  print_binary

    # Print result binary
    li   $v0, 4
    la   $a0, str_result
    syscall
    move $a0, $s5
    jal  print_binary

    # Print result hex
    li   $v0, 4
    la   $a0, str_hex
    syscall
    move $a0, $s5
    jal  print_hex

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# ============================================================
# float_add
# Adds two IEEE 754 single-precision floats using integer ops.
#
# Input:  $a0 = operand A (IEEE 754)
#         $a1 = operand B (IEEE 754)
# Output: $v0 = A + B (IEEE 754)
#
# Algorithm:
#   1. Extract sign[1], exponent[8], mantissa[23] from A and B
#   2. Restore implicit leading 1 -> 24-bit significand
#   3. Align: shift smaller-exp operand's significand right
#      by (exp_large - exp_small) to match exponents
#   4. Add significands if same sign; subtract if different sign
#   5. Normalize result back to 1.xxx * 2^n form
#   6. Reassemble sign | exponent | mantissa
# ============================================================
float_add:
    # Save callee-saved registers and return address
    sub  $sp, $sp, 20
    sw   $ra,  0($sp)
    sw   $s0,  4($sp)
    sw   $s1,  8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)

    # ---- Extract fields from A ($a0) ----
    srl  $t0, $a0, 31           # t0 = sign_A (bit 31)
    srl  $t1, $a0, 23           # shift exponent field down
    andi $t1, $t1, 0xFF         # t1 = exp_A (8 bits, biased)
    li   $t2, 0x7FFFFF
    and  $t2, $a0, $t2          # t2 = mantissa_A (23 bits)
    ori  $t2, $t2, 0x800000     # restore implicit leading 1 -> 24 bits

    # ---- Extract fields from B ($a1) ----
    srl  $t3, $a1, 31           # t3 = sign_B
    srl  $t4, $a1, 23
    andi $t4, $t4, 0xFF         # t4 = exp_B
    li   $t5, 0x7FFFFF
    and  $t5, $a1, $t5          # t5 = mantissa_B (23 bits)
    ori  $t5, $t5, 0x800000     # restore implicit leading 1

    # ---- Step 3: Align exponents ----
    # Ensure A has the larger exponent (swap if needed)
    bge  $t1, $t4, fa_no_swap
    # Swap A and B so that A always has larger exponent
    move $t6, $t0
    move $t0, $t3
    move $t3, $t6               # swap sign_A <-> sign_B
    move $t6, $t1
    move $t1, $t4
    move $t4, $t6               # swap exp_A  <-> exp_B
    move $t6, $t2
    move $t2, $t5
    move $t5, $t6               # swap mant_A <-> mant_B
fa_no_swap:
    # Shift B's significand right to align with A
    sub  $t6, $t1, $t4          # t6 = exp difference (shift amount)
    srlv $t5, $t5, $t6          # align B significand

    # ---- Step 4: Add or subtract significands ----
    beq  $t0, $t3, fa_same_sign

    # Different signs: subtract (A is guaranteed larger after swap)
    sub  $t2, $t2, $t5          # significand result
    move $t7, $t0               # result sign = sign of larger operand (A)
    bgez $t2, fa_normalize      # if positive, go normalize
    xori $t7, $t7, 1            # result is negative, flip sign
    sub  $t2, $zero, $t2        # negate to get positive magnitude
    j    fa_normalize

fa_same_sign:
    add  $t2, $t2, $t5          # add significands
    move $t7, $t0               # result sign = common sign

    # ---- Step 5: Normalize ----
fa_normalize:
    beq  $t2, $zero, fa_return_zero

    # Case A: overflow (bit 24 set after addition of same-sign values)
    srl  $t6, $t2, 24
    beq  $t6, $zero, fa_find_leading
    srl  $t2, $t2, 1            # shift right 1
    addi $t1, $t1, 1            # increment exponent
    j    fa_strip_implicit

    # Case B: leading 1 below bit 23 (subtraction result)
    # Shift left until bit 23 is set, decrement exponent each time
fa_find_leading:
    li   $t6, 23
fa_norm_loop:
    srlv $t8, $t2, $t6          # check bit t6
    andi $t8, $t8, 1
    bne  $t8, $zero, fa_strip_implicit
    sll  $t2, $t2, 1            # shift left
    addi $t1, $t1, -1           # decrement exponent
    addi $t6, $t6, -1
    bgez $t6, fa_norm_loop
    j    fa_return_zero         # significand became zero

fa_strip_implicit:
    # Mask off the implicit leading 1 at bit 23
    li   $t6, 0x7FFFFF
    and  $t2, $t2, $t6

    # ---- Step 6: Reassemble IEEE 754 result ----
    sll  $t7, $t7, 31           # sign to bit 31
    sll  $t1, $t1, 23           # exponent to bits [30:23]
    or   $v0, $t7, $t1
    or   $v0, $v0, $t2          # OR in mantissa bits [22:0]
    j    fa_done

fa_return_zero:
    li   $v0, 0                 # return +0.0

fa_done:
    # Restore callee-saved registers
    lw   $ra,  0($sp)
    lw   $s0,  4($sp)
    lw   $s1,  8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    addi $sp, $sp, 20
    jr   $ra

# ============================================================
# float_mul
# Multiplies two IEEE 754 single-precision floats.
#
# Input:  $a0 = operand A (IEEE 754)
#         $a1 = operand B (IEEE 754)
# Output: $v0 = A * B (IEEE 754)
#
# Algorithm:
#   sign_R = sign_A XOR sign_B
#   exp_R  = exp_A + exp_B - 127  (subtract one bias)
#   mant_R = (mant_A * mant_B) >> 23
#            where mant_A/B are 24-bit (with implicit 1)
#            product is 48-bit; keep upper 24 bits
# ============================================================
float_mul:
    sub  $sp, $sp, 4
    sw   $ra, 0($sp)

    # Extract A fields
    srl  $t0, $a0, 31           # t0 = sign_A
    srl  $t1, $a0, 23
    andi $t1, $t1, 0xFF         # t1 = exp_A
    li   $t2, 0x7FFFFF
    and  $t2, $a0, $t2
    ori  $t2, $t2, 0x800000     # t2 = significand_A (24-bit)

    # Extract B fields
    srl  $t3, $a1, 31           # t3 = sign_B
    srl  $t4, $a1, 23
    andi $t4, $t4, 0xFF         # t4 = exp_B
    li   $t5, 0x7FFFFF
    and  $t5, $a1, $t5
    ori  $t5, $t5, 0x800000     # t5 = significand_B (24-bit)

    # Result sign = XOR of input signs
    xor  $t6, $t0, $t3          # t6 = result sign

    # Result biased exponent = exp_A + exp_B - 127
    add  $t7, $t1, $t4
    addi $t7, $t7, -127         # t7 = result biased exponent

    # Multiply 24-bit significands using MIPS multu (unsigned)
    # Result is 48 bits stored in HI (upper 32) : LO (lower 32)
    multu $t2, $t5
    mfhi $t0                    # upper 32 bits of product
    mflo $t1                    # lower 32 bits of product

    # Reconstruct 24-bit result from bit positions [46:23] of 48-bit product
    # bit[46] of product = bit[14] of HI
    # Combine: shift HI left 9, OR with LO >> 23
    sll  $t0, $t0, 9            # HI << 9
    srl  $t1, $t1, 23           # LO >> 23
    or   $t2, $t0, $t1          # t2 = 24-bit product significand

    # Normalize: if bit 24 is set, product overflowed 24 bits
    srl  $t3, $t2, 24
    beq  $t3, $zero, fm_mask
    srl  $t2, $t2, 1            # shift right 1 to normalize
    addi $t7, $t7, 1            # increment exponent

fm_mask:
    # Strip implicit leading 1 to get 23-bit mantissa
    li   $t3, 0x7FFFFF
    and  $t2, $t2, $t3

    # Reassemble result: sign | exponent | mantissa
    sll  $t6, $t6, 31           # sign to bit 31
    sll  $t7, $t7, 23           # exponent to bits [30:23]
    or   $v0, $t6, $t7
    or   $v0, $v0, $t2          # mantissa in bits [22:0]

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# ============================================================
# decimal_to_float
# Converts a null/newline-terminated decimal string to IEEE 754.
#
# Input:  $a0 = address of string (e.g. "-6.5\n" or "3.14\0")
# Output: $v0 = 32-bit IEEE 754 single-precision encoding
#
# Parsing steps:
#   1. Check for leading '-' -> set sign bit
#   2. Read digits before '.' -> build integer part in $s1
#   3. Read digits after  '.' -> build fraction as num/$t8
#   4. Convert fraction to binary bits (multiply-by-2 method)
#   5. Combine integer bits | fraction bits into $t2
#   6. Find position of leading 1 bit (normalization point)
#   7. Compute biased exponent = position + 127
#   8. Extract 23-bit mantissa (strip implicit 1)
#   9. Assemble: ($s0 << 31) | (exp << 23) | mantissa
# ============================================================
decimal_to_float:
    sub  $sp, $sp, 4
    sw   $ra, 0($sp)

    move $t9, $a0               # t9 = current read pointer into string

    # ---- Step 1: Detect and consume sign character ----
    li   $s0, 0                 # default: positive
    lb   $t0, 0($t9)            # load first character
    li   $t1, 45                # ASCII code for '-'
    bne  $t0, $t1, dtf_parse_int
    li   $s0, 1                 # negative number
    addi $t9, $t9, 1            # advance past '-'

    # ---- Step 2: Parse integer digits ----
dtf_parse_int:
    li   $s1, 0                 # $s1 = integer accumulator
dtf_int_loop:
    lb   $t0, 0($t9)            # load next character
    li   $t1, 46                # ASCII '.'
    beq  $t0, $t1, dtf_found_dot    # hit decimal point
    li   $t1, 10                # ASCII '\n' (newline from syscall 8)
    beq  $t0, $t1, dtf_no_dot       # end of input, no decimal point
    beq  $t0, $zero, dtf_no_dot     # null terminator
    # digit: s1 = s1 * 10 + (char - '0')
    mul  $s1, $s1, 10
    addi $t0, $t0, -48          # convert ASCII digit to integer value
    add  $s1, $s1, $t0
    addi $t9, $t9, 1
    j    dtf_int_loop

    # ---- Step 3: Parse fraction digits ----
dtf_found_dot:
    addi $t9, $t9, 1            # advance past '.'
    li   $s2, 0                 # fraction numerator
    li   $t8, 1                 # fraction denominator (power of 10)
dtf_frac_loop:
    lb   $t0, 0($t9)
    li   $t1, 10                # '\n'
    beq  $t0, $t1, dtf_frac_done
    beq  $t0, $zero, dtf_frac_done
    mul  $s2, $s2, 10
    addi $t0, $t0, -48
    add  $s2, $s2, $t0
    mul  $t8, $t8, 10           # denominator *= 10 for each digit
    addi $t9, $t9, 1
    j    dtf_frac_loop
dtf_frac_done:
    j    dtf_build

dtf_no_dot:
    li   $s2, 0                 # no fraction
    li   $t8, 1

    # ---- Check for zero input ----
dtf_build:
    bne  $s1, $zero, dtf_not_zero
    beq  $s2, $zero, dtf_return_zero   # both parts zero -> return +/-0
dtf_not_zero:

    # ---- Step 4: Convert fraction to binary bits ----
    # Method: multiply numerator by 2 each iteration
    #   if result >= denominator: bit = 1, subtract denominator
    #   else:                     bit = 0
    # Collect into $t5, count bits in $t4 (max 23)
    li   $t5, 0                 # fraction bits accumulator
    li   $t4, 0                 # number of fraction bits generated
    li   $t6, 23                # max fraction bits to generate
dtf_frac_bit_loop:
    beq  $t6, $zero, dtf_frac_bits_done
    beq  $s2, $zero, dtf_frac_bits_done    # fraction exhausted
    mul  $s2, $s2, 2            # numerator * 2
    sll  $t5, $t5, 1            # shift accumulator left (make room for new bit)
    blt  $s2, $t8, dtf_frac_bit_zero       # if num < denom, bit = 0
    ori  $t5, $t5, 1            # bit = 1
    sub  $s2, $s2, $t8          # num -= denom
dtf_frac_bit_zero:
    addi $t4, $t4, 1            # increment bit count
    addi $t6, $t6, -1           # decrement remaining budget
    j    dtf_frac_bit_loop
dtf_frac_bits_done:

    # ---- Step 5: Combine integer and fraction bits ----
    # Shift integer part left by $t4 to make room for fraction bits
    move $t2, $s1
    sllv $t2, $t2, $t4          # t2 = integer bits in upper positions
    or   $t2, $t2, $t5          # OR in the fraction bits

    # ---- Step 6: Find position of most significant 1 bit ----
    li   $t3, 31                # start checking from bit 31
dtf_find_leading:
    srlv $t6, $t2, $t3          # shift right by t3 to bring target bit to LSB
    andi $t6, $t6, 1            # isolate LSB
    bne  $t6, $zero, dtf_found_leading  # found it
    addi $t3, $t3, -1
    bgez $t3, dtf_find_leading
    j    dtf_return_zero        # no set bit found (shouldn't happen)

dtf_found_leading:
    # t3 = bit position of leading 1 in the combined integer|fraction value
    # True (unbiased) exponent = (bit position) - (fraction bits count)
    sub  $t3, $t3, $t4          # true exponent
    addi $t3, $t3, 127          # biased exponent (add IEEE 754 bias)

    # ---- Step 7 & 8: Extract 23-bit mantissa ----
    # We need the 23 bits immediately below the leading 1.
    # original leading-1 position = (biased_exp - 127) + t4
    move $t6, $t3
    addi $t6, $t6, -127
    add  $t6, $t6, $t4          # t6 = original bit position of leading 1
    addi $t6, $t6, -23          # shift amount needed to place leading 1 at bit 23

    bgez $t6, dtf_shift_right   # positive -> shift right
    # Negative shift amount means we need to shift LEFT
    sub  $t7, $zero, $t6        # make positive
    sllv $t2, $t2, $t7
    j    dtf_mask_mantissa
dtf_shift_right:
    srlv $t2, $t2, $t6          # shift right to align

dtf_mask_mantissa:
    # Mask to 23 bits, stripping the implicit leading 1
    li   $t6, 0x7FFFFF
    and  $t2, $t2, $t6          # t2 = 23-bit mantissa field

    # ---- Step 9: Assemble IEEE 754 result ----
    # Format: [31]=sign [30:23]=biased_exp [22:0]=mantissa
    sll  $t7, $s0, 31           # sign bit to position 31
    sll  $t3, $t3, 23           # biased exponent to positions [30:23]
    or   $v0, $t7, $t3
    or   $v0, $v0, $t2          # combine all three fields

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

dtf_return_zero:
    # Return +0.0 or -0.0 (sign bit only, all other bits zero)
    sll  $v0, $s0, 31
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# ============================================================
# print_binary
# Prints a 32-bit value as binary digits, MSB first.
# Inserts spaces after bit 31 (sign) and bit 23 (end of exp)
# to visually separate the three IEEE 754 fields.
#
# Input:  $a0 = 32-bit value to print
# Output: printed to stdout as "S EEEEEEEE MMMMMMMMMMMMMMMMMMMMMMM\n"
# ============================================================
print_binary:
    sub  $sp, $sp, 4
    sw   $ra, 0($sp)

    move $t0, $a0               # t0 = value to print
    li   $t1, 31                # t1 = current bit position (31 down to 0)

pb_loop:
    # Extract bit at position t1
    srlv $t2, $t0, $t1
    andi $t2, $t2, 1
    addi $t2, $t2, 48           # convert to ASCII '0' or '1'
    li   $v0, 11                # syscall 11: print character
    move $a0, $t2
    syscall

    # Insert space after sign bit (pos 31) and after exponent (pos 23)
    li   $t3, 31
    beq  $t1, $t3, pb_space
    li   $t3, 23
    beq  $t1, $t3, pb_space
    j    pb_no_space
pb_space:
    li   $v0, 11
    li   $a0, 32                # ASCII space
    syscall
pb_no_space:
    addi $t1, $t1, -1           # next bit
    bgez $t1, pb_loop           # loop while t1 >= 0

    # Print newline
    li   $v0, 4
    la   $a0, str_newline
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# ============================================================
# print_hex
# Prints a 32-bit value as "0x" followed by 8 hex digits.
# Uses uppercase A-F for hex digits 10-15.
#
# Input:  $a0 = 32-bit value to print
# Output: printed to stdout as "0xXXXXXXXX\n"
# ============================================================
print_hex:
    sub  $sp, $sp, 4
    sw   $ra, 0($sp)

    move $t0, $a0               # t0 = value to print

    # Print "0x" prefix
    li   $v0, 11
    li   $a0, 48                # '0'
    syscall
    li   $a0, 120               # 'x'
    syscall

    li   $t1, 28                # start with top nibble (bits [31:28])

ph_loop:
    srlv $t2, $t0, $t1          # shift current nibble to LSB
    andi $t2, $t2, 0xF          # isolate 4-bit nibble
    li   $t3, 10
    blt  $t2, $t3, ph_decimal   # 0-9: use '0'+n
    addi $t2, $t2, 55           # 10-15: 'A'=65, 65-10=55, so add 55
    j    ph_print
ph_decimal:
    addi $t2, $t2, 48           # '0' = 48
ph_print:
    li   $v0, 11
    move $a0, $t2
    syscall
    addi $t1, $t1, -4           # next nibble (4 bits lower)
    bgez $t1, ph_loop

    li   $v0, 4
    la   $a0, str_newline
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
