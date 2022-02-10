    .section .text
    .global dyn_printf
# int dyn_printf(const char *restrict fmt, uint64_t args[], size_t n)
dyn_printf:
    # prologue
    sub $32, %rsp
    mov %r12, (%rsp)   # store %rdx
    mov %r13, 8(%rsp)  # store %r8
    mov %r14, 16(%rsp) # store %r9
    mov %rbx, 24(%rsp) # store %rsp on printf invocation

    mov %rdx, %r12
    mov %r8, %r13
    mov %rsp, %rbx

    # first argument
    cmp $0, %r13
    je .L.finish
    mov (%r12), %rdx
    movd %rdx, %xmm0

    # second argument
    cmp $1, %r13
    je .L.finish
    mov 8(%r12), %r8
    movd %r8, %xmm1

    # third argument
    cmp $2, %r13
    je .L.finish
    mov 16(%r12), %r9
    movd %r9, %xmm2

    # further arguments, pushed on to stack using a loop
    mov $3, %r14
    .L.loop:
    cmp %r13, %r14
    je .L.finish
    push (%r12, %r14, 8)
    inc %r14
    jmp .L.loop

    # call printf
    .L.finish:
    and $-16, %rsp
    sub $32, %rsp
    mov %r13, %rax
    call printf

    # epilogue
    mov %rbx, %rsp
    mov (%rsp), %r12
    mov 8(%rsp), %r13
    mov 16(%rsp), %r14
    mov 24(%rsp), %r15
    add $32, %rsp

    repz retq
