%include "syscalls.h"            
%include "lib.s"           

extern puts, printnum, putc
;puts prints rsi
;printnum prints rax
;putc prints al
SECTION .bss
    chars: resq 1
    string: resq 1
    count: resq 1
    f: resb 1
    char: resb 1
    i: resb 1
    
SECTION .data
    fizz:   db `Fizz`, 0
    buzz:   db `Buzz`, 0

SECTION .text

GLOBAL _start
_start: 
    mov [i], BYTE 0
.loop:
    add [i], BYTE 1
    mov r10, [i]
    cmp r10, 101
    je .done
    mov rax, [i]
    cqo
    mov rbx, 3
    div rbx
    cmp rdx, 0
    je .fizz
    mov rax, [i]
    cqo
    mov rbx, 5
    div rbx
    cmp rdx, 0
    je .buzz
    mov rax, r10
    call printnum
    mov al, `\n`
    call putc
    jmp .loop
.fizz:
    mov rsi, 0
    mov rsi, fizz
    call puts
    mov rax, [i]
    cqo
    mov rbx, 5
    div rbx
    cmp rdx, 0
    je .buzz
    mov al, `\n`
    call putc
    jmp .loop
.buzz:
    mov rsi, 0
    mov rsi, buzz
    call puts
    mov al, `\n`
    call putc
    jmp .loop
.done:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
