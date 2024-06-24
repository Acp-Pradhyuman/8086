data segment
    msg1 db 0dh, 0ah, "enter the numbers... $"  ; 0ah is for new line and 0dh is for carriage return
    msg2 db ": $"
    msg3 db 0dh, 0ah, 0dh, 0ah, "sorted array: $"
    msg4 db 0dh, 0ah, "$"
    msg5 db 0dh, 0ah, "enter the number of elements: $"

    ;arr db  06h DUP (?)    ; all of the 6 elements are initialized with garbage, or we could use "DUP (00h)"

    arr db  0ffh DUP (?)
    len db  06
    ;sum dw  0000h
data ends

code segment
    assume cs:code, ds:data
start:
    mov ax, data
    mov ds, ax

    mov ah, 09h     ; used to display string
    lea dx, msg5
    int 21h

    call get
    ;mov ah, 00h
    mov len, al

    mov ah, 09h
    lea dx, msg1
    int 21h

    lea si, arr
    ;mov cx, len
    mov cl, len
    mov ch, 00h
    mov bl, 01h

back:
    mov ah, 09h
    lea dx, msg4
    int 21h

    mov ah, 02h     ; to print the value in dl onto the screen
    daa
    mov dl, bl
    add dl, 30h
    int 21h
    inc bl

    mov ah, 09h
    lea dx, msg2
    int 21h

    call get
    mov ds:[si], al
    inc si
    loop back

reinitialize:
    lea si, arr
    lea cx, arr
    mov bx, cx
    add bl, len
    dec bx

back2:
    inc si
	mov ah, ds:[si]		; ah is the key to be compared with
				        ; key(ah) = arr[i]
	mov di, si
	dec di

back1:
    cmp di, cx		    ; di - [arr]
	jc skip
	mov al, ds:[di]		; ah <- ds:[si], al <- ds:[di]
				        ; di ranges from 2000 to si-1


	cmp al, ah		    ; al - ah, only flags are affected
	jle skip		    ; if 1st number is smaller then carry is set
	mov ds:[di+1], al
	dec di			    ; j--
	jmp back1

skip:
    mov ds:[di+1], ah	; arr[j+1] = key(ah)
	cmp si, bx		    ; si - [arr + len -1]
	jnz back2

print_result:
     mov ah, 09h
     lea dx, msg3
     int 21h

     lea si, arr
     mov cl, len
     mov ch, 00h

back3:
     call put
     inc si

     mov ah, 02h     ; to print the value in dl onto the screen
     mov dl, 2ch     ; 2chex or 44 in decimal is ascii for comma
     int 21h

     ;mov ah, 09h     ; used to display string
     mov dl, 20h     ; 20hex or 32 in decimal is ascii for space
     int 21h

     loop back3

     mov ah, 02h     ; to print the value in dl onto the screen
     mov dl, 0dh
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
    jle gdecimal1   ; jle stands for jump if less than or equal
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
    mov al, ds:[si]
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