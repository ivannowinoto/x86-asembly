.model small

.stack

.data
    window_height   dw 0c8h     ;視窗高度
    window_width    dw 140h     ;視窗寬度
    window_temp     dw 04h      ; used to make the window 'smaller' and making the ball does not go off the screen when bounces
    
    ball_start_xpos dw 0a0h     ;球體起始x座標
    ball_start_ypos dw 64h      ;球體起始y座標
    ball_color      db 0        ;球體顏色
    
    ball_xpos    dw 0a0h        ;球體此時x座標
    ball_ypos    dw 64h         ;球體此時y座標
    ball_size    dw 04h

    ball_speed_x dw 04h
    ball_speed_y dw 04h

    paddle1_xpos dw 0ah
    paddle1_ypos dw 0ah

    paddle2_xpos dw 130h
    paddle2_ypos dw 0ah

    paddle_width    dw 04h
    paddle_height   dw 16h
    paddle_border   dw 06h
    paddle_speed    dw 06h

    player_points   db 0
    ai_points       db 0

    player_points_mes   db 'Score: 0$'

    menu_welcome_mes    db '------- WELCOME TO PONG! -------$'
    menu_rule_mes       db 'Reach 10 points to win!$'
    menu_choose_mes     db 'Choose your difficulty:$'
    menu_easy_mes       db 'Easy   - Press 1$'
    menu_medium_mes     db 'Medium - Press 2$'
    menu_hard_mes       db 'Hard   - Press 3$'
    menu_exit_mes       db 'Press ESC to exit$'
    menu_border_mes     db '--------------------------------$'

    game_over_mes       db '--------- GAME OVER ---------$'
    game_win_mes        db 'YOU WON!$'
    game_lose_mes       db 'YOU LOSE!$'
    game_restart_mes    db 'Press R to play again$'
    game_ends_mes       db 'Press E to exit to main menu$'
    game_border_mes     db '-----------------------------$'

    game_easy_mes   db '  Easy$'
    game_medium_mes db 'Medium$'
    game_hard_mes   db '  Hard$'

    sys_time        db 0
    activeness      db 1    
    winner          db 0    ; 1: Player wins, 2: AI wins
    menu            db 0    ; 0: Main menu, 1: Game
    difficulty      db 0    ; 1: Easy, 2: Medium, 3: Hard
    ai_precision    dw 0

.code
main proc
    mov ax, @data
	mov ds, ax
    
    call clear_screen
    check_difficulty:           ;檢查難度  
        cmp difficulty, 01h
        je easy_difficulty

        cmp difficulty, 02h
        je medium_difficulty

        cmp difficulty, 03h
        je hard_difficulty
        jmp start_game

    easy_difficulty:
        mov ball_speed_x, 03h
        mov ball_speed_y, 03h
        mov paddle_height, 28h
        mov ai_precision, 14h
        jmp start_game

    medium_difficulty:
        mov ball_speed_x, 04h
        mov ball_speed_y, 04h  
        mov paddle_height, 20h
        mov ai_precision, 10h
        jmp start_game

    hard_difficulty:
        mov ball_speed_x, 05h
        mov ball_speed_y, 05h
        mov paddle_height, 18h
        mov ai_precision, 0ch
        jmp start_game

    start_game:
        cmp menu, 0
        je display_start_menu
        
        cmp activeness, 0
        je draw_game_over

        mov ah, 2ch     ; get the system time
        int 21h

        cmp dl, sys_time    ; check if time has already passed
        je start_game       ; if time is still the same, then check again
                            ; if not, then move and draw the ball
        mov sys_time, dl    ; update time

        call clear_screen

        call draw_ball
        call move_ball

        call draw_paddles
        call move_paddles
        
        call draw_ui

        jmp start_game

        draw_game_over:
            call display_game_over
            jmp start_game

        display_start_menu:
            call display_main_menu
            jmp check_difficulty
    
main endp

draw_ball proc
    mov cx, ball_xpos  ; set the x-position of ball
    mov dx, ball_ypos  ; set the y-position of ball

    draw_ball_xpos:
        mov ah, 0ch
        mov al, 01h         ; choose the pixel color for the ball
        add al, ball_color  ;改變球的顏色
        mov bh, 00h
        int 10h

        inc cx                  ; to the next pixel location
        mov ax, cx
        sub ax, ball_xpos
        cmp ax, ball_size       ; check if already reaches ball_size horizontally
        jng draw_ball_xpos      ; if not, then print pixel horizontally again

    draw_ball_ypos:
        mov cx, ball_xpos
        inc dx                  ; go to the next line

        mov ax, dx      
        sub ax, ball_ypos
        cmp ax, ball_size       ; check if alrady reaches ball_size vertically
        jng draw_ball_xpos      ; if not, then print pixel horizontally (to the next line)    
        ret

draw_ball endp

draw_paddles proc 
    mov cx, paddle1_xpos
    mov dx, paddle1_ypos

    draw_paddle1_horizontal:
        mov ah, 0ch     ; set config to write a pixel
        mov al, 0fh     ; choose white as color
        mov bh, 0       ; set the page number
        int 10h

        inc cx
        mov ax, cx
        sub ax, paddle1_xpos
        cmp ax, paddle_width
        jng draw_paddle1_horizontal

    draw_paddle1_vertical:
        mov cx, paddle1_xpos
        inc dx

        mov ax, dx
        sub ax, paddle1_ypos
        cmp ax, paddle_height
        jng draw_paddle1_horizontal

        mov cx, paddle2_xpos    ; to draw the right paddle
        mov dx, paddle2_ypos

    draw_paddle2_horizontal:
        mov ah, 0ch
        mov al, 0fh
        mov bh, 0
        int 10h

        inc cx
        mov ax, cx
        sub ax, paddle2_xpos
        cmp ax, paddle_width
        jng draw_paddle2_horizontal

    draw_paddle2_vertical:
        mov cx, paddle2_xpos
        inc dx

        mov ax, dx
        sub ax, paddle2_ypos
        cmp ax, paddle_height
        jng draw_paddle2_horizontal

    ret
draw_paddles endp 

clear_screen proc         
    mov ah, 0       ; 清除畫面  by restarting the video mode
    mov al, 13h     ; choose video mode
    int 10h

    mov ah, 0bh
    mov bh, 0       ; points to the background color
    mov bl, 0       ; choose bg color
    int 10h

    ret
clear_screen endp

move_ball proc
    cmp player_points, 0ah  ; if the player reaches 10 points, they win
    jge game_over
    
    mov ax, ball_speed_x   
    add ball_xpos, ax       ; move the ball horizontally  加上位移量

    mov ax, window_temp
    cmp ball_xpos, ax
    jl game_over            ; if ball_xpos < 0 then game over
    jmp move_ball_vertically

    game_over:    
        mov ball_color, 0       ;重置顏色
        cmp player_points, 0ah
        jnl player_wins
        jmp ai_wins

        player_wins:
            mov winner, 01h     ;存取勝利者
            jmp continue_move_ball

        ai_wins:
            mov winner, 02h
            jmp continue_move_ball

        continue_move_ball:    
            mov activeness, 0           ; stops the game
            mov player_points, 0        ; reset player point
            ret

    move_ball_vertically:
        mov ax, ball_speed_y
        add ball_ypos, ax       ; move the ball vertically

        mov ax, window_temp
        cmp ball_ypos, ax
        jl reset_position_y     ; if ball_ypos < 0 then ball collides with bottom border

        mov ax, window_height
        sub ax, ball_size
        sub ax, window_temp
        cmp ball_ypos, ax
        jg reset_position_y     ; if ball_ypos > 0 then ball collides with top border
        jmp check_collision_paddle2

    reset_position_y:
        neg ball_speed_y
        ret
    
    ; check if the ball is colliding with the right paddle
    check_collision_paddle2:
        mov ax, ball_xpos       ; condition 1 of ball colliding w/ right paddle
        add ax, ball_size       ;碰撞條件:ball_max_x > paddle_min_x
        cmp ax, paddle2_xpos
        jng check_collision_paddle1  ;jmp if not greater

        mov ax, paddle2_xpos    ; condition 2 of ball colliding w/ right paddle
        add ax, paddle_width    ;碰撞條件:ball_min_x < paddle_max_x
        cmp ball_xpos, ax
        jnl check_collision_paddle1  ;jump if not less

        mov ax, ball_ypos       ; condition 3 of ball colliding w/ right paddle
        add ax, ball_size       ;碰撞條件:ball_max_y > paddle_min_y
        cmp ax, paddle2_ypos
        jng check_collision_paddle1

        mov ax, paddle2_ypos    ; condition 4 of ball colliding w/ right paddle
        add ax, paddle_height   ;碰撞條件:ball_min_y < paddle_max_y
        cmp ball_ypos, ax
        jnl check_collision_paddle1
    ;上述四個條件必須同時達成才算碰撞，因此有一個不符合就會直接去檢查另一邊
    ; if the program reaches this point, the ball is colliding with the right paddle
        neg ball_speed_x  ;反彈==速度反向
        ret

    ; check if the ball is colliding with the left paddle
    check_collision_paddle1:
        mov ax, ball_xpos       ; condition 1 of ball colliding w/ left paddle
        add ax, ball_size
        cmp ax, paddle1_xpos
        jng exit

        mov ax, paddle1_xpos    ; condition 2 of ball colliding w/ left paddle
        add ax, paddle_width
        cmp ball_xpos, ax
        jnl exit

        mov ax, ball_ypos       ; condition 3 of ball colliding w/ left paddle
        add ax, ball_size
        cmp ax, paddle1_ypos
        jng exit

        mov ax, paddle1_ypos    ; condition 4 of ball colliding w/ left paddle
        add ax, paddle_height
        cmp ball_ypos, ax
        jnl exit 

        ; if the program reaches this point, the ball is colliding with the left paddle
        neg ball_speed_x  ;反彈
        jmp give_player_point ;玩家得分
        ret

    give_player_point:
        inc player_points ;加分
        add ball_color, 01h ;每得分一次就改變顏色
        call update_player_points

    exit:
        ret

move_ball endp

move_paddles proc
    mov ah, 01h                     ; Set the function number 01h for keyboard input
    int 16h                         ; Call interrupt 16h to check for keyboard input
    jz check_paddle2_movement       ; Jump if the Zero Flag (ZF) is set (no key pressed)

    mov ah, 0
    int 16h

    cmp al, 77h     ; 'w'
    je move_paddle1_up
    cmp al, 57h     ; 'W'
    je move_paddle1_up

    cmp al, 73h     ; 's'
    je move_paddle1_down
    cmp al, 53h     ; 'S'
    je move_paddle1_down
    jmp check_paddle2_movement

    move_paddle1_up:
        mov ax, paddle_speed
        sub paddle1_ypos, ax

        mov ax, paddle_border
        cmp paddle1_ypos, ax        ;判斷有沒有到最上端
        jl fix_paddle1_up
        jmp check_paddle2_movement

        fix_paddle1_up: 
            mov ax, paddle_border 
            mov paddle1_ypos, ax    ;讓paddle停在最上面
            jmp check_paddle2_movement

    move_paddle1_down:
        mov ax, paddle_speed
        add paddle1_ypos, ax
        
        mov ax, window_height
        sub ax, paddle_border
        sub ax, paddle_height
        cmp paddle1_ypos, ax
        jg fix_paddle1_down
        jmp check_paddle2_movement

        fix_paddle1_down:
            mov paddle1_ypos, ax
            jmp check_paddle2_movement
    
    check_paddle2_movement: ;paddle2 要自動去追球
        mov ax, ball_ypos
        add ax, ball_size
        sub ax, ai_precision
        cmp ax, paddle2_ypos
        jl move_paddle2_up

        mov ax, paddle2_ypos
        add ax, paddle_height
        sub ax, ai_precision
        cmp ax, ball_ypos
        jl move_paddle2_down
        ret

        move_paddle2_up:
            mov ax, paddle_speed
            sub paddle2_ypos, ax

            mov ax, paddle_border
            cmp paddle2_ypos, ax
            jl fix_paddle2_up
            ret

            fix_paddle2_up:
                mov ax, paddle_border
                mov paddle2_ypos, ax
                ret

        move_paddle2_down:
            mov ax, paddle_speed
            add paddle2_ypos, ax

            mov ax, window_height
            sub ax, paddle_border
            sub ax, paddle_height
            cmp paddle2_ypos, ax
            jg fix_paddle2_down
            ret

            fix_paddle2_down:
                mov paddle2_ypos, ax
                ret
                
move_paddles endp

reset_ball proc
    mov ax, ball_start_xpos
    mov ball_xpos, ax

    mov ax, ball_start_ypos
    mov ball_ypos, ax

    neg ball_speed_x
    neg ball_speed_y

    ret
reset_ball endp

draw_ui proc
    mov ah, 02h     ; cursor position
    mov bh, 00h     ; page number
    mov dh, 01h     ; set row
    mov dl, 04h     ; set column
    int 10h

    mov ah, 09h
    lea dx, player_points_mes
    int 21h
    
    mov ah, 02h     ; cursor position
    mov bh, 00h     ; page number
    mov dh, 01h     ; set row
    mov dl, 1dh     ; set column
    int 10h

    cmp difficulty, 01h
    je display_easy_mes
    cmp difficulty, 02h
    je display_medium_mes
    cmp difficulty, 03h
    je display_hard_mes
    ret

    display_easy_mes:
        mov ah, 09h
        lea dx, game_easy_mes
        int 21h
        ret

    display_medium_mes:
        mov ah, 09h
        lea dx, game_medium_mes
        int 21h
        ret

    display_hard_mes:
        mov ah, 09h
        lea dx, game_hard_mes
        int 21h
        ret

    ret
draw_ui endp

update_player_points proc
    xor ax, ax      ; set ax into 0 (faster using xor)
    mov al, player_points

    add al, 30h
    mov [player_points_mes][07h], al
    
    ret
update_player_points endp

display_game_over proc
    call clear_screen
    
    mov ah, 02h     ; display the game over title
    mov bh, 00h
    mov dh, 06h
    mov dl, 05h
    int 10h

    mov ah, 09h
    lea dx, game_over_mes
    int 21h

    mov ah, 02h     ; display the winner title
    mov bh, 00h
    mov dh, 09h
    mov dl, 05h
    int 10h

    cmp winner, 01h
    je winner_is_player
    jmp winner_is_ai

    winner_is_player:
        mov ah, 09h
        lea dx, game_win_mes
        int 21h
        jmp display_restart

    winner_is_ai:
        mov ah, 09h
        lea dx, game_lose_mes
        int 21h
        jmp display_restart

    display_restart:
        mov ah, 02h     ; display the play again title
        mov bh, 00h
        mov dh, 0ch
        mov dl, 05h
        int 10h

        mov ah, 09h
        lea dx, game_restart_mes
        int 21h

    display_back_to_menu:
        mov ah, 02h     ; display the back to menu title
        mov bh, 00h
        mov dh, 0eh
        mov dl, 05h
        int 10h

        mov ah, 09h
        lea dx, game_ends_mes
        int 21h

    mov ah, 02h     ; display the game over border
    mov bh, 00h
    mov dh, 12h
    mov dl, 05h
    int 10h

    mov ah, 09h
    lea dx, game_border_mes
    int 21h

    mov ah, 0       ; waiting for user input
    int 16h

    cmp al, 'R'
    je restart_game
    cmp al, 'r'
    je restart_game

    cmp al, 'E'
    je back_to_main
    cmp al, 'e'
    je back_to_main
    ret

    restart_game:
        mov activeness, 01h
        call update_player_points
        call reset_ball        
        ret

    back_to_main:
        mov menu, 0
        mov player_points, 0
        call reset_ball
        call update_player_points
        mov paddle1_ypos, 0ah
        mov paddle2_ypos, 0ah
        ret
            
display_game_over endp

display_main_menu proc
    call clear_screen
    
    mov ah, 02h     ; display the welcome title
    mov bh, 00h
    mov dh, 04h
    mov dl, 04h
    int 10h

    mov ah, 09h
    lea dx, menu_welcome_mes
    int 21h

    mov ah, 02h     ; display the rule title 
    mov bh, 00h
    mov dh, 07h
    mov dl, 04h
    int 10h

    mov ah, 09h
    lea dx, menu_rule_mes
    int 21h

    mov ah, 02h     ; display the choose difficulty title
    mov bh, 00h
    mov dh, 0ah
    mov dl, 04h
    int 10h
    
    mov ah, 09h
    lea dx, menu_choose_mes
    int 21h
    
    mov ah, 02h     ; display the easy title
    mov bh, 00h
    mov dh, 0ch
    mov dl, 04h
    int 10h
    
    mov ah, 09h
    lea dx, menu_easy_mes
    int 21h

    mov ah, 02h     ; display the medium title
    mov bh, 00h
    mov dh, 0eh
    mov dl, 04h
    int 10h
    
    mov ah, 09h
    lea dx, menu_medium_mes
    int 21h

    mov ah, 02h     ; display the hard title
    mov bh, 00h
    mov dh, 10h
    mov dl, 04h
    int 10h
    
    mov ah, 09h
    lea dx, menu_hard_mes
    int 21h

    mov ah, 02h     ; display the esc title
    mov bh, 00h
    mov dh, 13h
    mov dl, 04h
    int 10h
    
    mov ah, 09h
    lea dx, menu_exit_mes
    int 21h

    mov ah, 02h     ; display the bottom border
    mov bh, 00h
    mov dh, 15h
    mov dl, 04h
    int 10h
    
    mov ah, 09h
    lea dx, menu_border_mes
    int 21h

    mov ah, 0       ; waiting for user input
    int 16h

    cmp al, '1'
    je game_is_easy
    cmp al, '2'
    je game_is_medium
    cmp al, '3'
    je game_is_hard
    cmp al, 1bh
    je exit_program
    ret

    game_is_easy:
        mov difficulty, 01h
        mov activeness, 01h
        mov menu, 01h
        ret
    
    game_is_medium:
        mov difficulty, 02h
        mov activeness, 01h
        mov menu, 01h
        ret
    
    game_is_hard:
        mov difficulty, 03h
        mov activeness, 01h
        mov menu, 01h
        ret

    exit_program:
        mov ax, 4c00h
	    int 21h

display_main_menu endp

end main