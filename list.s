    .extern malloc
    .extern free
    .extern memcpy

    .global list_init
# void list_init(linked_list *list)
list_init:
    # list->head = NULL
    movq $0, (%rcx)
    # list->phantom_item_size = SIZE_MAX
    movq $0xFFFFFFFFFFFFFFFF, %r11
    # return
    repz ret

    .global list_push_back
# void list_push_back(linked_list *list, void *item, size_t item_size)
list_push_back:
    # %r9 = list
    movq %rcx, %r9

    # %rcx = malloc(item_size + 16)
    leaq 16(%r8), %rcx
    push %rdx
    push %r8
    push %r9
    sub $32, %rsp
    call malloc
    add $32, %rsp
    pop %r9
    pop %r8
    pop %rdx
    movq %rax, %rcx
    # %rcx->next = NULL
    movq $0, (%rcx)
    # %rcx->item_size = item_size
    movq %r8, 8(%rcx)
    # memcpy(%rcx + 16, item, item_size)
    push %rcx
    push %r9
    add $16, %rcx
    sub $32, %rsp
    callq memcpy
    add $32, %rsp
    pop %r9
    pop %rcx

    # %r10 = %r9->head
    movq (%r9), %r10
    # $if (%r10 != NULL) goto L.list_has_element
    testq %r10, %r10
    jne L.list_has_element
    # %r9->p_head = %rcx
    movq %rcx, (%r9)
    # return
    repz ret

    L.list_has_element:
    # %r11 = %r10->next
    movq (%r10), %r11
    # $if (%r11 == NULL) goto L.list_last_element
    testq %r11, %r11
    je L.list_last_element
    # %r10 = %r11
    movq %r11, %r10
    # goto L.list_has_element
    jmp L.list_has_element

    L.list_last_element:
    # %r10->next = %rcx
    movq %rcx, (%r10)
    # return
    repz ret

    .global list_length
# size_t list_length(linked_list *list)
list_length:
    # %rax = 0
    xorq %rax, %rax
    L.process_next_item:
    # %rcx = %rcx[0]
    movq (%rcx), %rcx
    # $if (%rcx == NULL) goto L.done
    testq %rcx, %rcx
    je L.done
    # %rax += 1
    incq %rax
    # goto L.process_next_item
    jmp L.process_next_item

    L.done:
    # return
    repz ret

    .global list_traverse
# void list_traverse(linked_list *list, void (*callback)(void *item, size_t item_size, void *ctx), void *ctx)
list_traverse:
    # prologue
    sub $24, %rsp
    mov %rbx, (%rsp)
    mov %r12, 8(%rsp)
    mov %r13, 16(%rsp)

    # %rbx = callback
    mov %rdx, %rbx
    # %r12 = ctx
    mov %r8, %r12
    # %rcx = %rcx[0]
    movq (%rcx), %rcx

    L.process_next_item.1:
    # $if (%rcx == NULL) goto L.done.1
    testq %rcx, %rcx
    je L.done.1
    # callback(%rcx + 16, %rcx->item_size, ctx)
    mov %rcx, %r13
    mov 8(%rcx), %rdx
    add $16, %rcx
    mov %r12, %r8
    sub $32, %rsp
    callq *%rbx
    add $32, %rsp
    # %rcx = %rcx->next
    mov (%r13), %rcx
    # goto L.process_next_item.1
    jmp L.process_next_item.1

    L.done.1:
    # return
    mov (%rsp), %rbx
    mov 8(%rsp), %r12
    mov 16(%rsp), %r13
    add $24, %rsp
    repz ret

    .global list_drop
# void list_drop(linked_list *list)
list_drop:
    # prologue
    sub $8, %rsp
    mov %rbx, (%rsp)

    # %rcx = list->head
    mov (%rcx), %rcx
    L.process_next_item.2:
    # $if (%rcx == NULL) goto L.done.2
    testq %rcx, %rcx
    je L.done.2
    # %rbx = %rcx->next
    movq (%rcx), %rbx
    # free(%rcx)
    call free
    # %rcx = %rbx
    movq %rbx, %rcx
    # goto L.process_next_item.2
    jmp L.process_next_item.2

    L.done.2:
    # return
    mov (%rsp), %rbx
    add $8, %rsp
    repz ret
