	.text
	.globl	create_list
	.type	create_list, @function
create_list:
	# %edi is argument for malloc which contain sizeof(list) 
	movl	$8, %edi
	call	malloc
	# return address in %rax and assign NULL to l->head
	movq	$0, (%rax)
	ret
.LFE2:
	.size	create_list, .-create_list
	.globl	push
	.type	push, @function
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
.LFE3:
	.size	push, .-push
	.globl	pop
	.type	pop, @function	
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
	.section	.rodata
	.align 8
.STR1:
	.string	"\nCommands:\n c  create list\n a  add key to top of list\n p  pop list from top\n q  quit \n\nchoice: "
.STR2:
	.string	"enter key: "
.STR3:
	.string	"%d"
.STR4:
	.string	""
.STR6:
	.string "\nlist: "
.STR7:
	.string "\nInlavid command\n"
.JTABLE:
	.quad	.CASEA
	.quad	.DEFAULT
	.quad	.CASEC
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.DEFAULT
	.quad	.CASEP
	.quad	.Exit
.LFE6:
	.text
	.globl	main
	.type	main, @function
main:
    # save prev %rbp (frame ptr in MIPS) and assign cur %rbp
	pushq	%rbp
	movq	%rsp, %rbp
	# push local var to stack (list ptr, choice, key) 
	# so we have addr of list ptr in -8(%rbp) (init to NULL) and so on...
	pushq	$0
	pushq	$0
	pushq	$0
.SWITCH:
	# print command
	movl	$.STR1, %edi
	movl	$0, %eax
	call	printf
	# call fgets, little endian so str will in high exp pos of integer
	movq	stdin(%rip), %rdx
	leaq	-16( %rbp), %rdi
	movl	$8, %esi
	call	fgets
	# mov char to %eax (unsigned extention)
	movzbl	-16(%rbp), %eax
	# %eax -= 'a'
	subl	$97, %eax
	# 'q' - 'a' == 16
	cmpl	$16, %eax
	ja		.DEFAULT
	# using jump table to handle multiwat branch (switch) 
	jmp		*.JTABLE(,%eax, 8)
.CASEA:
	movl	$.STR2, %edi
	movl	$0, %eax
	call	printf
	# call scanf
	leaq	-24(%rbp), %rsi
	movl	$.STR3, %edi
	movl	$0, %eax
	call	__isoc99_scanf
	movq	-8(%rbp), %rdi
	movl	-24(%rbp), %esi
	call	push
	jmp		.PRINT
.CASEC:
	call	create_list
	movq	%rax, -8(%rbp)
	jmp		.PRINT
.CASEP:
	movq	-8(%rbp) ,%rdi
	call	pop
	jmp		.PRINT
.DEFAULT:
	movl	$.STR7, %edi
	movl	$0, %eax
	call	printf
	jmp		.SWITCH
.PRINT:
	movl	$.STR6, %edi
	movl	$0, %eax
	call	printf
	movq	-8(%rbp), %rdi
	call	print
	jmp		.SWITCH
.Exit:
	# return 0
	movl	$0, %eax
	leave
	ret
.LFE7:
	.size	main, .-main
