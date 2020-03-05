%define SYS_WRITE   1
%define SYS_EXIT    60

%define STDOUT_FILENO   1

 
SECTION .bss
    cbuf:   resb 1
    numbuf:	resb	32
SECTION .data

errmesg:   db `Usage - ./bitcount <number> \n`
bitmesg:   db `^ Number contains the number of 1 bits displayed here ->`


SECTION .text

putc:
	mov	[cbuf], al		; *cbuf = al;
	mov	rax, SYS_WRITE		; write(STDOUT_FILENO, &cbuf, 1);
	mov	rdi, STDOUT_FILENO
	mov	rsi, cbuf
	mov	rdx, 1
	syscall
	ret
; Print the string pointed to by rsi:
puts:
    mov rdx, 0
.loop:  cmp BYTE [rsi+rdx], `\0`    ; rdx = strlen(rsi);
    je  .stop
    inc rdx
    jmp .loop
.stop:  mov rax, SYS_WRITE      ; write(STDOUT_FILENO, rsi, rdx)
    mov rdi, STDOUT_FILENO
    syscall
    ret
; prints number in rax
printnum:
	lea	rsi, [numbuf+32]
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
   
; Takes r14 and converts it from ascii to integer and puts it in r10
atoi:
    mov r10, 0  
    mov r11, 0
    cmp BYTE [r14], '-' ; cmp the a byte value located in r14 wiht '-'
    je .if1
    jne .loop
.if1:
    mov r11, 1
    inc r14
.loop:
    cmp BYTE [r14], '0'
    jl .done
    cmp BYTE [r14], '9'
    jg .done
    imul r10, 10
    movzx r13, BYTE [r14]
    sub r13, '0'
    add r10, r13
    inc r14
    jmp .loop
.done:
    cmp r11, 0
    je .return
    neg r10
.return:
    ret

GLOBAL _start
_start: 
    cmp BYTE [rsp], 2        ; compares the byte argc contained in rsp
    jl .error
    mov r14, [rsp+16] ; moves argv[1] to r14 
    call atoi
    mov rax, r10
    call printnum
    mov al, `\n`
    call putc
    mov r12, 0         ; count register
.loop:
    mov r11, r10
    and r11, 1
    cmp r11, 1
    je .inccount
.loopcontd:
    shr r10, 1
    jnz .loop
    jmp .done
.inccount:
    inc r12
    jmp .loopcontd
.done:
    mov rsi, bitmesg
    call puts
    mov rax, r12
    call printnum
    mov al, `\n`
    call putc
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
.error:
    mov rsi, errmesg
    call puts
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
