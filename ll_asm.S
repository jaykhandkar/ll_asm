.global main 

.section .data

        LOCATION   = 0
        ON_CHAR    = 2
        OFF_CHAR   = 3
        ON_LENGTH  = 4
        OFF_LENGTH = 6
        COUNTDOWN  = 8
        STATUS     = 10
        NEXT       = 12

        STRUCT_SIZE = 24

head:
    .quad 0

message:
    .asciz "Hello, world here is an integer: 0x%x\n"

malloc_err_str:
    .asciz "error: malloc\n"

fmt_str:
    .asciz "return from malloc: %p\n"

add_node_err_str:
    .asciz "couldn't add node to list \n"

print_str:
    .asciz "NODE location = %d -> "

head_null_str:
    .asciz "list is null"

.section .text

main:
    push %rbp
    mov %rsp, %rbp

    lea message(%rip), %rdi # address of string to output
    mov $0xdeadbeef, %rsi
    xor %eax, %eax
    call printf

    mov $STRUCT_SIZE, %rdi
    call malloc
    cmp $0, %rax
    je malloc_err_str

    lea fmt_str(%rip), %rdi
    mov %rax, %rsi
    xor %rax, %rax
    push %rsi
    sub $8, %rsp
    call printf
    add $8, %rsp
    pop %rsi

    /* rsi = ptr to allocated node */
    movw $83, LOCATION(%rsi)
    movw $100, ON_LENGTH(%rsi)

    mov %rsi, %rdi
    call add_node
    cmp $0, %rax
    jl add_node_err

    mov $STRUCT_SIZE, %rdi
    call malloc
    cmp $0, %rax
    je malloc_err_str

    lea fmt_str(%rip), %rdi
    mov %rax, %rsi
    xor %rax, %rax
    push %rsi
    sub $8, %rsp
    call printf
    add $8, %rsp
    pop %rsi

    /* rsi = ptr to allocated node */
    movw $126, LOCATION(%rsi)
    movw $100, ON_LENGTH(%rsi)

    mov %rsi, %rdi
    call add_node
    cmp $0, %rax
    jl add_node_err

    call print_list

    xor %rax, %rax
    jmp main_success
add_node_err:
    lea add_node_err_str(%rip), %rdi
    xor %rax, %rax
    call printf
    mov $-1, %rax
    leave
    ret

malloc_err:
    lea malloc_err_str(%rip), %rdi
    call printf
    mov $-1, %rax

main_success:
    leave
    ret

/* C - style parameters: add_node(ptr)
 * ptr - pointer to node
 * adds the node at the head of the list
 * returns 0 on success, -1 otherwise */
add_node:
    push %rbp
    mov %rsp, %rbp

    cmp $0, %rdi
    je invalid_ptr

    movq head(%rip), %rax
    movq %rax, NEXT(%rdi)
    movq %rdi, head(%rip)

    mov $0, %rax
    jmp return_success
invalid_ptr:
    mov $-1, %eax

return_success:
    leave
    ret

/* iterate through the list and print LOCATION for each node */
print_list:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %rsi
    push %rdi
    push %r12

    movq head(%rip), %r12
    cmpq $0, %r12
    je head_null

    mov %r12, %rbx
print_loop:
    movzwq LOCATION(%rbx), %rsi
    lea print_str(%rip), %rdi
    call printf
    movq NEXT(%rbx), %rbx
    cmp $0, %rbx
    jne print_loop

    mov $'\n', %di
    call putchar
    jmp normal_return
head_null:
    lea head_null_str(%rip), %rdi //test
    xor %rax, %rax
    call printf
normal_return:
    pop %rbx
    pop %rsi
    pop %rdi
    pop %r12
    leave
    ret
