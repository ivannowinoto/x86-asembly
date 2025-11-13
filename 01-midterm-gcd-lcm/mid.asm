pString macro para1
	 push ax 	        
	 push dx		
	 mov  dx, offset para1	
	 mov  ah, 09h		
	 int  21h		
	 pop  dx		
	 pop  ax		
	 endm

getKey macro			
 	mov ah, 01h	
    int 21h	
	endm

.model small

.data
x db 0                      ; first input
y db 0                      ; second input
result_hex dw 0             ; to store x*y (must be 2-byte)
result_decimal db 4 dup(0)

welcome_mes db 'Please input 2 numbers or press ESC to exit.$'
input1_mes db 'Enter first number: $'
input2_mes db 'Enter second number: $'
error_mes db 'Please enter a 2-digit decimal number!$'

new_line db 10, 13, '$'
output_gcd_mes db 'GCD is $'
output_lcm_mes db 'LCM is $'

.stack

.code
main proc
    mov ax, @data
    mov ds, ax

input1_digit1:
    pString welcome_mes     ; print the meesages first
    pString new_line
    pString input1_mes
    getKey                  ; getting user input
    cmp al, 1bh             ; check whether input is ESC or not
    jne cont_input1_digit1
    mov ax, 4c00h           ; if yes, immediately end program
    int 21h

cont_input1_digit1:
    sub al, 30h
    cmp al, 09h
    jbe input1_digit2       ; check whether input is a number
    jmp input_error         

input_error:
    mov ax, 0
    mov bx, 0
    pString new_line
    pString error_mes       ; error message when user input is not number or ESC
    pString new_line        
    pString new_line
    jmp input1_digit1              ; when error, restart input from beginning

input1_digit2:
    mov bh, al
    getKey                  ; get user input
    cmp al, 1bh             ; check whether input is ESC or not
    jne cont_input1_digit2
    mov ax, 4c00h           ; if yes, immediately end program
    int 21h

cont_input1_digit2:
    sub al, 30h
    cmp al, 09h             ; check whether input is a number
    jbe input2_digit1
    jmp input_error

input2_digit1:
    mov bl, al              ; store the first number in x
    mov cl, 04h
    rol bh, cl
    add bl, bh
    mov [x], bl             ; first number is now in x
    mov bx, 0

    pString new_line
    pString input2_mes
    getKey                  ; the logic from here is the same as input for first number
    cmp al, 1bh
    jne cont_input2_digit1
    mov ax, 4c00h
    int 21h

cont_input2_digit1:
    sub al, 30h
    cmp al, 09h
    jbe input2_digit2
    jmp input_error

input2_digit2:
    mov bh, al
    getKey
    cmp al, 1bh
    jne cont_input2_digit2
    mov ax, 4c00h
    int 21h

cont_input2_digit2:
    sub al, 30h
    cmp al, 09h
    jbe calculate_gcd   ; if input is done, calculate GCD
    jmp input_error 

calculate_gcd:
    mov bl, al          ; store the second number in y
    mov cl, 04h
    rol bh, cl
    add bl, bh
    mov [y], bl         ; second number is now in y
    mov ax, 0           ; reset ax, bx, and cx
    mov bx, 0
    mov cx, 0

    mov al, [x]         ; converting x into hexadecimal
    mov bl, al          ; why? because input from user is always decimal,
    mov cl, 0fh         ; but computer calculates using hexadecimal.
    and al, cl
    mov [x], al
    mov al, bl
    mov cl, 0f0h
    and al, cl
    mov cl, 04h
    shr al, cl
    mov cl, 0ah
    mul cl
    add [x], al

    mov al, [y]         ; converting y into hexadecimal
    mov bl, al
    mov cl, 0fh
    and al, cl
    mov [y], al
    mov al, bl
    mov cl, 0f0h
    and al, cl
    mov cl, 04h
    shr al, cl
    mov cl, 0ah
    mul cl
    add [y], al

    mov al, [x]         ; calculating x*y and store in result_hex
    mov bl, [y]
    mul bl
    mov [result_hex], ax

    mov ah, 0           ; start calculating for GCD
    mov al, [x]
    mov bl, [y]

while_loop:
    cmp al, 0           ; if al = 0, exit loop
    je exit_loop

    cmp al, bl          ; make sure al is bigger than bl
    ja modulo           ; if yes, jump to modulo 
    mov cl, al          ; if not, swap al and bl
    mov al, bl
    mov bl, cl
    mov cl, 0

modulo:
    mov ah, 0
    div bl              ; div bl = al/bl (remainder goes to ah, result goes to al)
    mov al, ah          
    mov ah, 0
    mov [x], al
    mov [y], bl         ; the GCD result is in y

    jmp while_loop

exit_loop:

    pString new_line        
    pString output_gcd_mes

    mov ax, [result_hex]    ; LCM is result_hex divided by y
    mov ch, 0
    mov cl, [y]
    mov dx, 0
    div cx
    mov [result_hex], ax    ; LCM is now in result_hex

    mov ax, 0               ; converting y back into decimal
    mov bx, 0
    mov cx, 0
    mov al, [y]
    mov cl, 0ah
    div cl
    mov cl, 04h
    rol al, cl
    add al, ah
    mov [y], al

    mov ax, 0               ; converting result_hex into decimal
    mov bx, 0
    mov cx, 0
    mov ax, [result_hex]
    mov cx, 0ah
    mov si, offset result_decimal

up:
    mov dx, 0               ; put each digit of result_hex into result_decimal
    div cx                  ; (result_decimal is an empty 4-bit array)
    mov [si], dl
    inc si
    cmp ax, cx
    jae up
    mov [si], al            

    mov ah, 02h
    mov dl, [y]             ; print the first digit of GCD
    mov cl, 4
    shr dl, cl
    add dl, 30h             ; if first digit is 0, no need to print
    cmp dl, 30h
    je gcd_digit2
    int 21h

gcd_digit2:
    mov dl, [y]             ; print the second digit of GCD
    shl dl, cl
    shr dl, cl
    add dl, 30h
    int 21h

    pString new_line
    pString output_lcm_mes  ; prepare to print LCM
    
    mov si, 03h         ; because memory is little-endian, print from index 3 2 1 to 0
    mov ah, 02h

    mov dl, result_decimal[si]
    add dl, 30h         ; if first digit of LCM is 0, no need to print
    cmp dl, 30h
    je lcm_3digit
    int 21h

    dec si
    mov dl, result_decimal[si]
    add dl, 30h
    int 21h

    dec si
    mov dl, result_decimal[si]
    add dl, 30h
    int 21h

    dec si
    mov dl, result_decimal[si]
    add dl, 30h
    int 21h
    jmp exit_code

lcm_3digit:
    dec si
    mov dl, result_decimal[si]
    add dl, 30h         ; if second digit of LCM is 0, no need to print
    cmp dl, 30h
    je lcm_2digit
    int 21h

    dec si
    mov dl, result_decimal[si]
    add dl, 30h
    int 21h

    dec si
    mov dl, result_decimal[si]
    add dl, 30h
    int 21h
    jmp exit_code

lcm_2digit:
    dec si
    mov dl, result_decimal[si]
    add dl, 30h         ; if third digit of LCM is 0, no need to print
    cmp dl, 30h
    je lcm_1digit
    int 21h
    
    dec si
    mov dl, result_decimal[si]
    add dl, 30h
    int 21h
    jmp exit_code

lcm_1digit:
    dec si
    mov dl, result_decimal[si]
    add dl, 30h         ; print last digit of LCM
    int 21h

exit_code:
    mov ax, 4c00h       ; code is done
    int 21h
main endp
end main