format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable
    prompt db "Enter a number to check if it's prime (in hex): ", 0
    not_prime_msg db "The number is not prime.", 0
    prime_msg db "The number is prime.", 0

section '.text' code executable readable writable

start:
    push prompt
    call [printf]

    call read_hex

    call is_prime
    cmp eax, 0
    je not_prime
    jmp prime

    not_prime:
        push not_prime_msg
        call [printf]
        jmp exit

    prime:

        push prime_msg
        call [printf]

    exit:
        push 0
        call [ExitProcess]


; Input: eax - A number to determine what is prime
; Output: eax - 1 if prime, 0 if not
is_prime:
    ; 4 bytes for num
    ; 4 bytes for i (counter)

    enter 8, 0
    ; Store the input value in local variable
    mov [ebp-4], eax
    mov dword [ebp-8], eax ; count eax times

    counter:
    ; Decrement counter
    dec dword [ebp-8]
    cmp dword [ebp-8], 1
    jle .is_prime ; If counter <= 1, number is prime
    ; Check if num is divisible by counter
    mov eax, [ebp-4]
    mov ecx, [ebp-8]
    xor edx, edx
    div ecx
    cmp edx, 0
    je .not_prime ; If remainder is 0, number is not prime
    jmp counter


    .is_prime:
        mov dword [ebp-4], 1d
        jmp .done
    .not_prime:
        mov dword [ebp-4], 0d
        jmp .done
    .done:
        ; Retrieve and return the stored value
        mov eax, [ebp-4]

        leave
        ret

include 'training.inc'