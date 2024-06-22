data segment
    msg1 db 0dh, 0ah, "enter the 1st number: $"  ; 0ah is for new line and 0dh is for carriage return
    msg2 db 0dh, 0ah, "enter the 2nd number: $"     
    msg3 db 0dh, 0ah, 0dh, 0ah, "sum: $" 
    msg4 db 0dh, 0ah, "carry: $"
    
    a   db  ?
    b   db  ?
    sum db  ?
    carry db 00h
data ends

code segment
    assume cs:code, ds:data
start:
    mov ax, data
    mov ds, ax
    
    mov ah, 09h     ; used to display string
    lea dx, msg1
    int 21h  
    call get
    mov a, al
    
    mov ah, 09h
    lea dx, msg2
    int 21h 
    call get
    mov b, al   
    
    mov al, a
    add al, b
    mov sum, al
    jnc skip  
    ;mov carry, 01h
    inc carry
    
skip:   
    mov ah, 09h
    lea dx, msg3
    int 21h  
    lea si, sum
    call put
    
    mov ah, 09h
    lea dx, msg4
    int 21h 
    lea si, carry
    call put
    
    
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
    
code ends
end start