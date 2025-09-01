
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

    output db "Slope is: %d/%d", 0


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


        mov eax, dword[slope + PNT.x]
        mov ecx, dword[slope + PNT.y]

        cmp eax, ecx

        jge x_greater
        jl y_greater
        x_greater:
            
            mov ecx, dword[slope + PNT.x]
            add ecx, 1
        y_greater:
            mov ecx, dword[slope + PNT.y]
            add ecx, 1
        jmp simplify
    print_slope:
        push dword[slope + PNT.x] ; printf is inverted
        push dword[slope + PNT.y]
        push output
        call [printf]

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
    