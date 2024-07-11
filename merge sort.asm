data segment
    msg1 db 0dh, 0ah, "enter the numbers... $"  ; 0ah is for new line and 0dh is for carriage return
    msg2 db ": $"
    msg3 db 0dh, 0ah, 0dh, 0ah, "sorted array: $"
    msg4 db 0dh, 0ah, "$"
    msg5 db 0dh, 0ah, "enter the number of elements: $"
    msg6 db 0dh, 0ah, "No elements to sort, enter atleast 2 numbers $"

    ;arr db  06h DUP (?)    ; all of the 6 elements are initialized with garbage, or we could use "DUP (00h)"

    arr db  0ffh DUP (?)
    len db  06h
    len1 dw ?
    len2 dw ?
    start_index dw ?
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
    cmp len, 01h
    jle display_msg

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
    mov di, si
    mov al, len
    mov ah, 0h
    add di, ax
    dec di
    call merge_sort

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
     jmp skip1

display_msg:
     mov ah, 09h
     lea dx, msg6
     int 21h

     mov ah, 02h     ; to print the value in dl onto the screen
     mov dl, 0dh
     int 21h

skip1:
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

proc merge_sort
	push si
	push di
	push bx
	push cx
	push ax

	cmp si, di	; start >= end then return
	jge merge_sort_done

	mov bx, di	; here bx is mid
	sub bx, si
	shr bx, 1
	add bx, si	; mid = start + (end - start)/2

	mov cx, di	; cx will contain end
	mov di, bx
	call merge_sort

	mov ax, si
	mov si, bx
	inc si		; mid + 1
	mov di, cx	; end is moved back into di
	call merge_sort

	mov si, ax
	call merge

merge_sort_done:
	pop ax
	pop cx
	pop bx
	pop di
	pop si
	ret
endp merge_sort

proc merge
	push dx
	push bx
	push cx
	push ax
	push si
	push di

	mov cx, di
	sub cx, bx	; end - mid

	sub bx, si
	inc bx		; mid - start + 1

	mov di, 0h
	mov dx, 8000h	; 64KB = 2^16 is the size of a segment
			; hence max each temporary array can hold is 32KB

	mov len1, bx
	mov len2, cx
	mov start_index, si

loop_copy1:
	mov al, ds:[si]
	mov es:[di], al
	inc si
	inc di
	dec bx
	cmp bx, 0h
	jnz loop_copy1

    mov di, dx
loop_copy2:
	mov al, ds:[si]
	mov es:[di], al
	inc si
	inc di
	dec cx
	cmp cx, 0h
	jnz loop_copy2

	mov si, start_index ; reinitialize
	mov di, 0h
	mov bx, 8000h

loop_main:
	cmp di, len1
	je loop_merge1

	mov ax, bx
	sub ax, 8000h
	cmp ax, len2
	je loop_merge1

	mov al, es:[di]
	mov ah, es:[bx]
	cmp al, ah
	jge exchange		; al >= ah
	mov ds:[si], al
	inc di
	jmp skip_loop_main

exchange:
	mov ds:[si], ah
	inc bx

skip_loop_main:
	inc si
	jmp loop_main


loop_merge1:
	cmp di, len1
	je loop_merge2

	mov al, es:[di]
	mov ds:[si], al
	inc si
	inc di
	jmp loop_merge1

loop_merge2:
	mov ax, bx
	sub ax, 8000h
	cmp ax, len2
	je merge_done

	mov al, es:[bx]
	mov ds:[si], al
	inc si
	inc bx
	jmp loop_merge2

merge_done:
	pop di
	pop si
	pop ax
	pop cx
	pop bx
	pop dx
	ret
endp merge

code ends
end start