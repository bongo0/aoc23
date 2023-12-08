; fasm ./asd2.asm && chmod +x asd2 && echo "  " && ./asd2
format ELF64 executable

; https://chromium.googlesource.com/chromiumos/docs/+/HEAD/constants/syscalls.md
; linux syscalls
; arch   syscall_NR return arg0 arg1 arg2 arg3 arg4 arg5
; x86_64 rax        rax    rdi  rsi  rdx  r10  r8   r9
SYS_read equ 0
SYS_write equ 1
; ...
SYS_exit equ 60

STDOUT equ 1
STDERR equ 2

macro syscall1 callnum, a
{
    mov rdi, a
    mov rax, callnum
    syscall
}

macro syscall2 callnum, a, b
{
    mov rdi, a
    mov rsi, b
    mov rax, callnum
    syscall
}

; write buf to file descriptor fd
; unsigned int fd
; const char * buf
; size_t       size
macro write fd, buf, size
{
    mov rdi, fd
    mov rsi, buf
    mov rdx, size
    mov rax, SYS_write
    syscall
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
segment readable executable

; usin registers as 'variables' as much as possible
;r8
;r9
;r12
;r13
;r14 - even 0 odd 1
;r15 - loop range
;rbx - result
entry main
main:
    
    mov rdi, STDOUT
    mov rsi, qword [test_num]
    call write_uint64
    write STDOUT, newline, 1 ; write new line

    mov rbx, 1; result

    ;mov r8, qword [rtime]
    mov r9, 1 ; time loop counter
    xor r13, r13 ; counter for winners

    ; calc loop range: 1 .. rtime/2 + 1
    mov rax, [rtime]
    mov rcx, 2
    mov rdx, 0
    div rcx
    mov r14, rdx ; save reminder
    inc rax
    mov r15, rax
    

    mov rsi, r15
    mov rdi, STDOUT
    call write_uint64
    write STDOUT, newline, 1 ; write new line

.loop_time:
    ; r9 = time_held
    ; calc distance = time_held * ( time - time_held )
    mov r8, qword [rtime]
    sub r8, r9
    mov rax, r8
    mul r9
    mov r8, rax

    cmp r8, qword [rdist]
    jl .loop_time_end
    inc r13

.loop_time_end:
    ;mov rsi, r8
    ;mov rdi, STDOUT
    ;call write_uint64_n

    inc r9
    cmp r9, r15
    jl .loop_time


    write STDOUT, newline, 1 ; write new line

    mov rax, r13
    add rax, r13

    test r14, r14
    jnz .odd
    dec rax
.odd:
    mov rsi, rax
    mov rdi, STDOUT
    call write_uint64_n

    write STDOUT, delim, delim_len


    ;; exit syscall
    mov rax, 60 ;; exit syscall id
    mov rdi, 0  ;; exit call value
    syscall





; rdi - int    file_descriptor
; rsi - uint64 integer_to_write
write_uint64:
    test rsi, rsi
    jz .write_zero
    mov rcx, 10 ; base 10
    mov r10, 0  ; count of digits written
    mov rax, rsi ; div by rcx -> quotient -> rax
.write_next_digit:
    test rax, rax
    jz .done
    mov rdx, 0 ; ? 
    div rcx ; div rax by rcx -> quotient -> rax
    add rdx, '0'
    dec rsp ; push to stack
    mov byte [rsp], dl ; move last byte of d register ie rdx
    inc r10
    jmp .write_next_digit
.done:
    write rdi, rsp, r10
    add rsp, r10 ; free stack
    ret
.write_zero:
    dec rsp ; push '0' to stack
    mov byte [rsp], '0'
    write rdi, rsp, 1
    inc rsp
    ret

; write new line char at the end
; rdi - int    file_descriptor
; rsi - uint64 integer_to_write
write_uint64_n:
    test rsi, rsi
    jz .write_zero
    mov rcx, 10 ; base 10
    mov r10, 0  ; count of digits written
    mov rax, rsi ; div by rcx -> quotient -> rax
.write_next_digit:
    test rax, rax
    jz .done
    mov rdx, 0 ; ? 
    div rcx ; div rax by rcx -> quotient -> rax
    add rdx, '0'
    dec rsp ; push to stack
    mov byte [rsp], dl ; move last byte of d register ie rdx
    inc r10
    jmp .write_next_digit
.done:
    write rdi, rsp, r10
    add rsp, r10 ; free stack
    jmp .end
.write_zero:
    dec rsp ; push '0' to stack
    mov byte [rsp], '0'
    write rdi, rsp, 1
    inc rsp
.end:
    write STDOUT, newline, 1 ; write new line
    ret


segment readable writeable

test_num dq 42069

newline db 10

delim db "----------------------------------", 10
delim_len = 35 ;; fasm 

n_races = 4
rtime dq 47986698
rdist dq 400121310111540
race_times dq    47,     98,     66,     98
distances  dq   400,   1213,   1011,   1540
n_wins     dq     0,      0,      0,      0