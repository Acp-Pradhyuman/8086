data segment
    msg1 db 0dh, 0ah, "enter the number: $"  ; 0ah is for new line and 0dh is for carriage return
    msg2 db 0dh, 0ah, 0dh, 0ah, "factorial: $"
    msg3 db 0dh, 0ah, "This program works from 0 to 12! $"
    msg4 db 0dh, 0ah, "Results are in hexadecimal $"
    msg5 db 0dh, 0ah, "$"
    msg6 db 0dh, 0ah, "Enter the numbers in hexadecimal as well i.e 00 to 0C! $"
    msg7 db 0dh, 0ah, "-------------------------------------------------------$"
    msg8 db 0dh, 0ah, "The entered number is greater than 0C (12 in decimal)  $"

    a   db  ?
    fact dd  ?
data ends

code segment
    assume cs:code, ds:data
start:
    mov ax, data
    mov ds, ax

    mov ah, 09h     ; used to display string
    lea dx, msg3
    int 21h

    ; mov ah, 09h     ; used to display string
    lea dx, msg4
    int 21h

    lea dx, msg6
    int 21h

    lea dx, msg7
    int 21h

    lea dx, msg5
    int 21h

    ; mov ah, 09h     ; used to display string
    lea dx, msg1
    int 21h
    call get

    cmp al, 0dh
    jc main

    mov ah, 09h
    lea dx, msg8
    int 21h
    ; jmp exit
    jmp lable


main:
    mov a, al

    mov ah, 00h     ; so that ax contains only al
    mov bx, ax
    mov ax, 01h
    call factorial
    lea si, fact
    mov ds:[si], ax
    mov ds:[si+2], dx

    mov ah, 09h
    lea dx, msg2
    int 21h

    lea si, fact
    add si, 03h
    call put
    dec si
    call put
    dec si
    call put
    dec si
    call put

lable:
    mov ah, 02h     ; to print the value in dl onto the screen
    mov dl, 0dh     ; 0dh brings cursor to the first position
    int 21h

    mov ah, 02h     ; to print the value in dl onto the screen
    mov dl, 0ah
    int 21h

    mov ah, 01h
    int 21h

exit:
    mov ah, 4ch     ; end the program go back to DOS
    int 21h


proc get
    push cx
    mov ah, 01h     ; to get a single character and the character is placed into "al", this is for higher nibble
    int 21h

    sub al, 30h
    cmp al, 09h
    jle gdecimal1    ; jle stands for jump if less than or equal
    sub al, 07h     ; for 0ah to 0fh since for 0ah we have 41h - 30h = 11h, so 11h - 07 = 0ah

gdecimal1:
    mov cl, 04h
    rol al, cl
    mov ch, al

    mov ah, 01h     ; once more for lower nibble
    int 21h

    sub al, 30h
    cmp al, 09h
    jle gdecimal2    ; jle stands for jump if less than or equal
    sub al, 07h

gdecimal2:
    add al, ch
    pop cx

    ret
endp get

proc put
    push cx
    mov al, [si]
    and al, 0f0h    ; get the higher nibble first
    mov cl, 04h
    rol al, cl
    add al, 30h     ; get back the keyboard's ascii value
    cmp al, 39h
    jle pdecimal1
    add al, 07h

pdecimal1:
    mov ah, 02h
    mov dl, al
    int 21h

    mov al, [si]
    and al, 0fh     ; get the lower nibble first
    add al, 30h     ; get back the keyboard's ascii value
    cmp al, 39h
    jle pdecimal2
    add al, 07h

pdecimal2:
    mov ah, 02h
    mov dl, al
    int 21h

    pop cx
    ret
endp put

proc factorial
    cmp bx, 01h
    jle return

    push bx
    dec bx
    call factorial
    pop bx

    cmp dx, 00h
    jz skip

    ;16*5 = 80
    ;bx=5
    ;dx-ax = 1-6
    mov cx, dx	; cx = 1

    mul bx		; ax = ax*bx = 0, dx=3, we need dx=3+5
    mov si, ax	; si = 0
    mov di, dx	; di = 3

    mov ax, cx	; ax = 1
    mul bx		; ax = 5, what if dx also fills?

    mov dx, ax	; dx = 5
    add dx, di	; dx = 5 + 3
    mov ax, si	; ax = 0
    jmp return

skip:
    mul bx

return:
    ret
endp factorial

code ends
end start