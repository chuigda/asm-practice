    .section .rdata
    .align 8
L.jumptable:
    # dummy entry
    .quad 0
    # funktsina
    .quad L.do_sum - L.jumptable
    .quad L.do_sub - L.jumptable
    .quad L.do_mul - L.jumptable
    .quad L.do_div - L.jumptable

    .section .text
    .global evaluate
# int64_t evaluate(tree_node_base *base, int64_t *error)
evaluate:
    movq $0, (%rdx)

    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rbx, (%rsp)
    mov %r12, 8(%rsp)
    mov %r13, 16(%rsp)
    mov %r14, 24(%rsp)

    mov (%rcx), %r14
    test %r14, %r14
    je L.return_simple_value

    mov %rcx, %rbx

    mov 8(%rbx), %rcx
    call evaluate
    mov %rax, %r12
    mov (%rdx), %rax
    test %rax, %rax
    jne L.epilogue

    mov 16(%rbx), %rcx
    call evaluate
    mov %rax, %r13
    mov (%rdx), %rax
    test %rax, %rax
    jne L.epilogue

    mov %r12, %rax
    lea L.jumptable(%rip), %rbx
    add (%rbx, %r14, 8), %rbx
    jmp *%rbx

    L.do_sum:
    add %r13, %rax
    jmp L.epilogue

    L.do_sub:
    sub %r13, %rax
    jmp L.epilogue

    L.do_mul:
    mov %rdx, %rbx
    imul %r13
    mov %rbx, %rdx
    jmp L.epilogue

    L.do_div:
    test %r13, %r13
    jz L.err_div_by_zero
    mov %rdx, %rbx
    xor %rdx, %rdx
    idiv %r13
    mov %rbx, %rdx
    jmp L.epilogue

    L.err_div_by_zero:
    movq $1, (%rdx)
    jmp L.epilogue

    L.return_simple_value:
    mov 8(%rcx), %rax

    L.epilogue:
    mov (%rsp), %rbx
    mov 8(%rsp), %r12
    mov 16(%rsp), %r13
    mov 24(%rsp), %r14
    add $32, %rsp
    pop %rbp
    repz ret
