	.text
	.globl	create_list
	.type	create_list, @function
crate_list:
	# %edi is argument for malloc which contain sizeof(list) 
	movl	$8, %edi
	call	malloc
	# return address in %rax and assign NULL to l->head
	movq	$0, (%rax)
	ret
.LFE3:
	.size	push, .-push
	.globl	pop
	.type	pop, @function
push:
	pushq	%rbp
    movq	%rsp, %rbp
	# push arg to stack 
	pushq	%rdi
	pushq	%rsi
	# %rax = malloc(16), 16 is sizeof(node)
	movl	$16, %edi
	call	malloc
	# cant use two mem access in single instr
	# so we need to assign the val to %edx first
	movl	-16(%rbp), %edx
	movl	%edx, (%rax)
	# mov &list to %rdx, and get list->head
	movq	-8(%rbp), %rdx
	movq	(%rdx), %rdx
	# (new node)->next = head
	movq	%rdx, 8(%rax)
	# list->head = (new node)
	movq	-8(%rbp), %rdx
	movq	%rax, (%rdx)
	leave
	ret
pop:
	movq (%rdi), %rax
	movq 8(%rax), %rdx
	movq %rdx, (%rdi)
	ret
.LFE4:
	.size	pop, .-pop
	.section	.rodata
.LC0:
	.string	"%d "
	.text
	.globl	print
	.type	print, @function
print:
	pushq	%rbp
    movq	%rsp, %rbp
	# push list->head to stack rather than &list
	# because caller need to save %rax, so we need to push this val to stack
	pushq	(%rdi)
	movq	(%rdi), %rax
.Loop3:
	# check if it's a NULL ptr 
	testq	%rax, %rax
	je		.Ret
	# pass node.key to %esi as arg of printf
	movl	(%rax), %esi 
	movl	$.LC0, %edi
	# without this instr, will occur segfault in printf
	movl	$0, %eax
	call printf
	movq	-8(%rbp), %rax
	# node = node->next
	movq	8(%rax), %rax
	movq	%rax, -8(%rbp)
	jmp		.Loop3
.Ret:
	movl	$10, %edi
	call	putchar
	leave
	ret		
.LFE5:
	.size	print, .-print
	.globl	main
	.type	main, @function
main:
    # save prev %rbp (frame ptr in MIPS) and assign cur %rbp
    pushq	%rbp
    movq	%rsp, %rbp
	call	crate_list
	# push return val to stack and i (loop counter) 
	# so we have addr of list in -8(%rbp) i in -16(%rbx)  
	pushq	%rax
	pushq	$0
.Loop1:
	cmpl	$9, -16(%rbp) 
	jg		.L1
	# assign 1th 2th arg in %esi and %rdi respectively
	movq	-8(%rbp), %rdi
	movl	-16(%rbp), %esi
	call 	push
	addl	$1, -16(%rbp)
	jmp		.Loop1
.L1:
	# assign i to zero reuse this variable in next for loop
	movl	$0, -16(%rbp)
.Loop2:
	cmpl	$9, -16(%rbp) 
	jg		.Exit
	movq	-8(%rbp), %rdi
	call	print
	movq	-8(%rbp), %rdi
	call	pop
	addl	$1, -16(%rbp)
	jmp		.Loop2
.Exit:
	# return 0
	movl	$0, %eax
	leave
	ret
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 7.4.0-1ubuntu1~16.04~ppa1) 7.4.0"
	.section	.note.GNU-stack,"",@progbits
