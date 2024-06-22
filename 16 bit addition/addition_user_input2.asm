data segment
    msg1 db 0dh, 0ah, "enter the 1st number: $"  ; 0ah is for new line and 0dh is for carriage return
    msg2 db 0dh, 0ah, "enter the 2nd number: $"
    msg3 db 0dh, 0ah, 0dh, 0ah, "sum: $"
    msg4 db 0dh, 0ah, "carry: $"

    a   dw  ?
    b   dw  ?
    sum dw  ?
    carry dw 00h
data ends

code segment
    assume cs:code, ds:data
start:
    mov ax, data
    mov ds, ax

    mov ah, 09h     ; used to display string
    lea dx, msg1
    int 21h
    ; lea si, a
    call get
    ; mov ds:[si+1], al  ; higher byte
    ; call get
    ; mov ds:[si], al    ; lower byte
    mov a, bx

    mov ah, 09h
    lea dx, msg2
    int 21h
    call get
    ; lea si, b
    ; mov ds:[si+1], al
    ; call get
    ; mov ds:[si], al
    mov b, bx

    mov ax, a
    add ax, b
    mov sum, ax
    jnc skip
    ;mov carry, 01h
    inc carry

skip:
    mov ah, 09h
    lea dx, msg3
    int 21h
    lea si, sum
    inc si          ; now si points to higher byte
    call put
    ; dec si
    ; call put

    mov ah, 09h
    lea dx, msg4
    int 21h
    lea si, carry
    inc si
    call put
    ; dec si
    ; call put


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
    mov bh, al

    mov ah, 01h     ; to get a single character and the character is placed into "al", this is for higher nibble
    int 21h

    sub al, 30h
    cmp al, 09h
    jle gdecimal3    ; jle stands for jump if less than or equal
    sub al, 07h     ; for 0ah to 0fh since for 0ah we have 41h - 30h = 11h, so 11h - 07 = 0ah

gdecimal3:
    mov cl, 04h
    rol al, cl
    mov ch, al

    mov ah, 01h     ; once more for lower nibble
    int 21h

    sub al, 30h
    cmp al, 09h
    jle gdecimal4    ; jle stands for jump if less than or equal
    sub al, 07h

gdecimal4:
    add al, ch
    mov bl, al
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

    mov al, [si-1]
    and al, 0f0h    ; get the higher nibble first
    mov cl, 04h
    rol al, cl
    add al, 30h     ; get back the keyboard's ascii value
    cmp al, 39h
    jle pdecimal3
    add al, 07h

pdecimal3:
    mov ah, 02h
    mov dl, al
    int 21h

    mov al, [si-1]
    and al, 0fh     ; get the lower nibble first
    add al, 30h     ; get back the keyboard's ascii value
    cmp al, 39h
    jle pdecimal4
    add al, 07h

pdecimal4:
    mov ah, 02h
    mov dl, al
    int 21h

    pop cx
    ret
endp put

code ends
end start