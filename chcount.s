%include "syscalls.h"
%include "lib.s"

extern puts, printnum, putc

SECTION .bss
    chars: resq 1
    string: resq 1
    count: resq 1
    f: resb 1
    char: resb 1
    i: resq 1
    j: resq 1
    
SECTION .data
    errmesg:   db `Usage - ./chcount <chars> <string> \n`


SECTION .text



GLOBAL _start
_start: 
    cmp BYTE [rsp], 3           ; compares the byte argc contained in rsp
    jne .error
    mov rsi, [rsp+16]           ; put argv[1] in rsi
    mov QWORD [chars], rsi      ; put rsi into var string
    mov rsi, 0
    mov rsi, [rsp+24]           ; put argv[1] in rsi
    mov QWORD [string], rsi     ; put rsi into var string
    mov QWORD [count], 0        ; set count to 0 
    mov r10, QWORD [chars]
    mov r11, QWORD [string]
    mov rbx, 0
    mov [i], BYTE 0
.loop1:                          ; loops through the character string currently
    mov [j], BYTE 0
    mov rbx, QWORD [i]
    cmp BYTE [r10+rbx], 0x00    ; checks if null
    je .done
    mov al, BYTE [r10+rbx]           ; ch = chars[i]
    mov BYTE [char], al
    mov r15, 0
    mov r13, QWORD [j]
    mov r14, QWORD [i]
.loop2:
    cmp r13, r14
    je .loop1contd
    cmp BYTE [r10+r13], al
    je .continue
    inc r13
    jmp .loop2
.loop1contd:
    add [i], BYTE 1
    mov [j], BYTE 0
.loop3:
    mov rbx, QWORD [j]
    cmp BYTE [r11+rbx], 0x00
    je .loop1
    mov al, BYTE [r11+rbx]
    cmp [char], al
    je .incount
    add [j], BYTE 1
    jmp .loop3
.done:
    mov rax, QWORD [count]
    call printnum
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
.incount:
    add [count], BYTE 1
    add [j], BYTE 1
    jmp .loop3
.continue:
    add [i], BYTE 1
    jmp .loop1
.error:                         ; prints error msg on error and quits
    mov rsi, errmesg
    call puts
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
    
