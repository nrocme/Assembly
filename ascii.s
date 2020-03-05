%define SYS_WRITE	1
%define SYS_EXIT	60

%define STDOUT_FILENO	1


; To compile: nasm -felf64 argv.s
; To link:    ld -o argv argv.o

SECTION .bss
    cbuf:	resb 1
    nbuf:   resb 32


SECTION .text

GLOBAL putc
; Print the character that is in r13:
putc:
	mov	[cbuf], r13		; *cbuf = rbx;
	mov	rax, SYS_WRITE		; write(STDOUT_FILENO, &cbuf, 1);
	mov	rdi, STDOUT_FILENO
	mov	rsi, cbuf
	mov	rdx, 1
	syscall
	ret				; return from the function

	

GLOBAL putn
; Print the number in the r15 register
putn:
    mov rax, r15
	lea	rsi, [nbuf+32]
	mov	BYTE [rsi], 0

	mov	rbx, 10		; rbx = 10 (the base for our numbers)
	mov	r12, 0		; r12 = false (negative flag)
	cmp	rax, 0
	jge	.loop		; if (rax >= 0) goto .loop
	neg	rax		; rax = -rax;
	mov	r12, 1		; r12 = true (number is negative)

.loop:				; do {
	cqo
	div	rbx		;   rax = rax/rbx; rdx = rax%rbx;
	add	dl, '0'		;   rax += '0';
	dec	rsi		;   rsi--;
	mov	BYTE [rsi], dl	;   *rsi = dl;
	cmp	rax, 0		
	jne	.loop		; } while (rax > 0)

	cmp	r12, 1
	jne	.skipneg
	dec	rsi
	mov	BYTE [rsi], '-'
.skipneg:
	call	puts
	ret
	
GLOBAL puts	
puts:
	mov	rdx, 0
.loop:	cmp	BYTE [rsi+rdx], `\0`	; rdx = strlen(rsi);
	je	.stop
	inc	rdx
	jmp	.loop
.stop:	mov	rax, SYS_WRITE		; write(STDOUT_FILENO, rsi, rdx)
    mov	rdi, STDOUT_FILENO
	syscall
	ret
	
GLOBAL _start
printascii:
    mov r15, rbx
    mov r9, rbx
    call putn     ; prints whats in r15
    mov r13, 58
    call putc
    mov r13, 32
    call putc
    mov r13, r9
    cmp r13, 32
    jge .if1
    jl .else1
    ret
.if1:
    cmp r13, 127
    jge .else1
    call putc
    mov r13, `\t`
    call putc     ; prints whats in r13
    ret
.else1:
    mov r13, 46
    call putc
    mov r13, `\t`
    call putc     ; prints whats in r13
    ret
_start:
    mov r10, 0
.loop:
    mov rbx, r10
    call printascii
    mov rbx, r10
    add rbx, 32
    call printascii
    mov rbx, r10
    add rbx, 64
    call printascii
    mov rbx, r10
    add rbx, 96
    call printascii
    mov r13, `\n`
    call putc
    inc r10
    cmp r10, 32
    jl .loop
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

