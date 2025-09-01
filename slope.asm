
format PE console
entry start
include 'win32a.inc' 

struct PNT
    x   dd  ?       ; X coordinate.
    y   dd  ?       ; Y coordinate.
ends

section '.bss' readable writeable
    point1 PNT
    point2 PNT

    slope PNT

section '.data' data readable writeable
    x1 db "Enter 1st x coordinate: 0x", 0
    y1 db "Enter 1st y coordinate: 0x", 0
    x2 db "Enter 2nd x coordinate: 0x", 0
    y2 db "Enter 2nd y coordinate: 0x", 0

    output_negative_two db "Slope is: -%d/%d", 0
    output_negative_one db "Slope is: -%d", 0
    output_positive_two db "Slope is: %d/%d", 0
    output_positive_one db "Slope is: %d", 0

    is_positive dd 0


section '.text' code readable executable
    start:
        push x1
        call [printf]
        call read_hex
        mov dword [point1 + PNT.x], eax
        push y1
        call [printf]
        call read_hex
        mov dword [point1 + PNT.y], eax
        push x2
        call [printf]
        call read_hex
        mov dword [point2 + PNT.x], eax
        push y2
        call [printf]
        call read_hex
        mov dword [point2 + PNT.y], eax

        ; Calculate slope
        mov eax, [point2 + PNT.y]
        sub eax, [point1 + PNT.y]
        mov ecx, [point2 + PNT.x]
        sub ecx, [point1 + PNT.x]

        mov dword[slope + PNT.y], eax  ; Store numerator (y difference) in y
        mov dword[slope + PNT.x], ecx  ; Store denominator (x difference) in x

        ; Check sign of slope (both eax and ecx should have same sign for positive slope)
        mov ebx, eax  ; Save eax value
        xor ebx, ecx  ; If signs are different, result will be negative
        cmp ebx, 0
        jl negative_slope
        jge positive_slope
        negative_slope:
            mov dword [is_positive], 0
            jmp end_slope
        positive_slope:
            mov dword [is_positive], 1
        end_slope:

        mov esi, dword[slope + PNT.x]
        mov ecx, dword[slope + PNT.y]
        ; make both values |x| and |y|
        mov eax, esi
        cdq
        xor eax, edx
        sub eax, edx
        mov esi, eax

        mov eax, ecx
        cdq
        xor eax, edx
        sub eax, edx
        mov ecx, eax

        mov dword[slope + PNT.x], esi
        mov dword[slope + PNT.y], ecx

        cmp esi, ecx
        jge x_greater
        jl y_greater
        x_greater:
            mov ecx, esi
            inc ecx
            jmp simplify
        y_greater:
            ; ecx already contains the y value which is greater
            inc ecx
            jmp simplify
    print_slope:

        cmp dword [is_positive], 0
        je print_negative
        jne print_positive

        print_positive:
            cmp dword [slope + PNT.x], 1
            je print_positive_one
            jne print_positive_two

        print_positive_one:
            push dword[slope + PNT.y]
            push output_positive_one
            jmp print

        print_positive_two:
            push dword[slope + PNT.x] ; prinf is reversed stack
            push dword[slope + PNT.y]
            push output_positive_two
            jmp print

        print_negative:
            cmp dword [slope + PNT.x], 1
            je print_negative_one
            jne print_negative_two
        
        print_negative_one:
            push dword[slope + PNT.y]
            push output_negative_one
            jmp print

        print_negative_two:
            push dword[slope + PNT.x] ; printf is reversed
            push dword[slope + PNT.y]
            push output_negative_two
            jmp print

        print:
            call [printf]
            jmp exit


        exit:
        push 0
        call [ExitProcess]

    simplify:
        dec ecx
        cmp ecx, 0
        je print_slope
        xor edx, edx

        mov eax, dword[slope + PNT.y]
        div ecx
        cmp edx, 0
        jne simplify 

        mov eax, dword[slope + PNT.x]
        div ecx
        cmp edx, 0
        jne simplify

        mov dword[slope + PNT.x], eax

        mov eax, dword[slope + PNT.y]
        div ecx
        mov dword[slope + PNT.y], eax

        jmp print_slope

include 'training.inc'
    