data segment
    a db 0ffh
    b db 0ffh
    sum db ?
    carry db 00h
data ends

code segment
    assume cs:code, ds:data
start:
    mov ax, data
    mov ds, ax
    
    mov al, a
    add al, b
    mov sum, al
    jnc skip  
    ;mov carry, 01h
    inc carry
    
skip:
    mov ah, 4ch
    int 21h
code ends
end start