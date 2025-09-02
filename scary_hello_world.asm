format PE console
entry start
include 'win32a.inc'
section '.data' data readable writeable
    hello_message db 48h, 65h, 6Ch, 6Fh, 2Ch, 20h, 57h, 6Fh, 72h, 6Ch, 64h, 21h, 0

section '.text' code readable executable
    start:
        push hello_message
        call [printf]
        jmp exit

    exit:
        push 0
        call [ExitProcess]

section '.idata' import data readable
 
library kernel,'kernel32.dll',\
        msvcrt,'msvcrt.dll'
 
import  kernel,\
        ExitProcess,'ExitProcess'

import  msvcrt,\
        printf, 'printf'