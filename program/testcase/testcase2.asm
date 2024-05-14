.text
loop:
    lw t5, 20(gp)
    beq t5, t4, loop
    lw a1, 8(gp)
    li s1, 0
    beq a1, s1, test_0
    li s1, 1
    beq a1, s1, test_1
    li s1, 2
    beq a1, s1, test_2
    li s1, 3
    beq a1, s1, test_3
    li s1, 4
    beq a1, s1, test_4
    li s1, 5
    beq a1, s1, test_5
    li s1, 6
    beq a1, s1, test_6
    li s1, 7
    beq a1, s1, test_7
    j loop
    

test_0:
	lw a2,0(gp)
	li t0,0
	count:
	beq a2,zero,exit_0
	srli a2,a2,1
	addi t0,t0,1
	j count
	exit_0:
	addi t1,zero,8
	sub t0,t1,t0
	sw t0,12(gp)
	j loop


test_1:
	lw a2,0(gp)
	lw a3,4(gp)
	addi t1,a3,0
	andi t2,a2,3
	slli t2,t2,8
	add t1,t1,t2
	andi t2,a2,124
	srli t2,t2,2
	addi t1,t1,1024
	li a5,128
	and t3,a2,a5
	#t1是已经加了1的f，t2是位移之后的e,t3是没有位移的符号位
	li t6,25
	sub t4,t6,t2
	bge t4,zero,shift_right_1  #右移
	sub t4,t2,t6
	sll t5,t1,t4
	j out_1
	
out_1:
	beq t3,zero,positive_1_1
	sub t5,zero,t5
	lw t5,40(gp)
	j loop
	
positive_1_1:
	lw t5,40(gp)
	j loop
	
shift_right_1:
	srl t5,t1,t4
	li t6,32
	sub t4,t6,t4
	sll t1,t1,t4
	beq t1,zero,out_1
	beq t3,zero,positive_1_2
	sub t5,zero,t5
	lw t5,40(gp)
	j loop
	
positive_1_2:
	addi t5,t5,1
	lw t5,40(gp)
	j loop
	

test_2:
	lw a2,0(gp)
	lw a3,4(gp)
	addi t1,a3,0
	andi t2,a2,3
	slli t2,t2,8
	add t1,t1,t2
	andi t2,a2,124
	srli t2,t2,2
	addi t1,t1,1024
	li a5,128
	and t3,a2,a5
	#t1是已经加了1的f，t2是位移之后的e,t3是没有位移的符号位
	li t6,25
	sub t4,t6,t2
	bge t4,zero,shift_right_2  #右移
	sub t4,t2,t6
	sll t5,t1,t4
	j out_1
	
shift_right_2:
	srl t5,t1,t4
	li t6,32
	sub t4,t6,t4
	sll t1,t1,t4
	beq t1,zero,out_1
	beq t3,zero,positive_2_2
	addi t5,t5,1
	sub t5,zero,t5
	lw t5,40(gp)
	j loop
	
positive_2_2:
	lw t5,40(gp)
	j loop
	
	
test_3:
	lw a2,0(gp)
	lw a3,4(gp)
	addi t1,a3,0
	andi t2,a2,3
	slli t2,t2,8
	add t1,t1,t2
	andi t2,a2,124
	srli t2,t2,2
	addi t1,t1,1024
	li a5,128
	and t3,a2,a5
	#t1是已经加了1的f，t2是位移之后的e,t3是没有位移的符号位
	li t6,25
	sub t4,t6,t2
	bge t4,zero,shift_right_3  #右移
	sub t4,t2,t6
	sll t5,t1,t4
	j out_1
	
shift_right_3:
	srl t5,t1,t4
	li t6,32
	sub s1,t6,t4
	sll s0,t1,s1
	beq s0,zero,out_1
	li t6,1
	addi t4,t4,-1
	sll t6,t6,t4
	and s2,t1,t6
	addi t4,t4,1
	beq s2,zero,test_3_down
	j test_3_up
	
test_3_down:
	beq t3,zero,positive_2_2
	sub t5,zero,t5
	lw t5,40(gp)
	j loop
	
test_3_up:
	beq t3,zero,positive_1_2
	addi t5,t5,1
	sub t5,zero,t5
	lw t5,40(gp)
	j loop
	

test_4:
	lw a2,0(gp)
	lw a3,4(gp)
	add t1,a2,a3
	srli t2,t1,8
	beq t2,zero,inverse_num
	add t1,t1,t2
	j inverse_num
	
inverse_num:
	li t3,-1
	xor t1,t1,t3
	sw t3,12(gp)
	j loop
	

test_5:
	lw a2,0(gp)
	lw a3,4(gp)
	li t1,15
	and t2,t1,a2
	slli a3,a3,8
	and t2,a3,a2
	sw t2,40(gp)
	j loop

test_6:
	

test_7:
	j loop