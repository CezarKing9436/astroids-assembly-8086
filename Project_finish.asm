IDEAL
MODEL small
STACK 200h
DATASEG
	;start of file names that i print
			;file names here bmp files
			filename1 db 'alien.bmp',0
			filename2 db 'blackscr.bmp',0
			filename3 db 'ship.bmp',0
			filename4 db 'bullet.bmp',0				
			filename5 db 'Main.bmp',0
			filename6 db 'mini.bmp',0
			filename18 db 'win.bmp',0
			;file name background
			filename7 db 'spac.bmp',0				
			filename8 db 'space1.bmp',0
			filename9 db 'space2.bmp',0
			filename10 db 'space3.bmp',0
			filename11 db 'space4.bmp',0
			filename12 db 'space5.bmp',0
			filename13 db 'space6.bmp',0
			filename14 db 'space7.bmp',0
			filename15 db 'space8.bmp',0
			filename16 db 'space9.bmp',0
			filename17 db 'space9.bmp',0
	
	
	; endingig  of file names that i print
	
	; this  holds the offsets of backgrounds that ill print then needed
	
	num_saver_space db offset filename7,offset filename8,offset filename9,offset filename10,offset filename11,offset filename12,offset filename13,offset filename14,offset filename15 ,offset filename16,offset filename17
	
	;this is the ending of background holders
	
	;varriables that needed to help keep in order of the code
	
	counter dw	0
	counter_destroy dw 0
	;stop varriables that needed to help keep in order of the code
	
	
	; x and y postion and the conditions of printing
			
			num_saver dw 50 dup(?)
			print_condition_1 dw 50 dup(1) 
			num_saver1 dw -320
			num_saver2 dw 0,20,30,40,50,60,70,80,90,100,110
			pos_ship dw 41747d
			pos_bullet dw 20 dup (?)
			print_condition_2 dw 20 dup(0)
			
	; ending of positions and conditions
	
	
	;diffrences between varriables
	
	diffrence_between_ship dw ?
	diffrence_between_bullet dw ?
	diffrence_between_space db ?
	
	; ending of diffrences
	;game condition * if game condition is 1, game is on if game condition is 0
	
	game_condition dw 1d
	
	;ending of game condition
	;size of object
	
	sizex dw ?
	sizey dw ?
	
	;ending of size object
	;name of file name to print
	
	filenameforgraphics db ?,0
	
	;no touch
	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
	ErrorMsg db 'before', 13, 10 ,'$'
	ErrorMsg2 db 'after', 13, 10 ,'$'
	Clock equ es:6Ch
	EndMessage db 'Done',13,10,'$'
	divisorTable db 10,1,0
;stop no touch

; make 1 more alien
	ifdivide4 dw 0d
	amount_to_print dw 1d  ;(ships)
;stop make 1 more	

	amount_to_print_bull dw 0 ;bullets
	
	
	note dw 10h ; 1193180 / 131 -> (hex)
note1 dw 800h ; 1193180 / 131 -> (hex)
note20 dw 010D1h ; DO diaz
note21 dw 0EFBh ; RE diaz
note22 dw 0CA6h ;Fa diaz
note23 dw 0B39h ;Sol diaz
note24 dw 0A00h ;La dia
	
CODESEG
;----------------------------------- movement no touch
proc changexypos
		add [word si],960d ; it makes the item who i just printed go down by 5 pixels
	ret
endp changexypos
;-------------------------------------- ending of movementbullets

proc changexypos_down
		sub [word si],960d ; it makes the item who i just printed go up by 5 pixels
	ret
endp changexypos_down



;--------------------------------------------- start graphics
proc graphics123
	call OpenFiles
	call ReadHeader
	call ReadPalette
	call CopyPal
	pop ax
	pop si               ; the main proc that calls all the valueable proc's that are needed for the graphics
	push si
	push ax
	call CopyBitmap
	call closefile	
	ret
endp graphics123

proc OpenFiles
; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, [word ptr filenameforgraphics]
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
	openerror :
		mov dx, offset ErrorMsg
		mov ah, 9h
		int 21h
	ret
endp OpenFiles

proc ReadHeader
; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader

proc ReadPalette
; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette

proc CopyPal
; Copy the colors palette to the video memory
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
	PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB .
		mov al,[si+2] ; Get red value .
		shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
		out dx,al ; Send it .
		mov al,[si+1] ; Get green value .
		shr al,2
		out dx,al ; Send it .
		mov al,[si] ; Get blue value .
		shr al,2
		out dx,al ; Send it .
		add si,4 ; Point to next color .
	; (There is a null chr. after every color.)
		loop PalLoop
	ret
endp CopyPal

proc CopyBitmap
; BMP graphics are saved upside-down .
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
	
	mov ax, 0A000h
	mov es, ax
	mov cx , [sizex]
	PrintBMPLoop :
		
		mov dx, [si]
		push cx
		push si
		; di = cx*320, point to the correct screen line
		mov di,cx
		shl cx,6
		shl di,8
		
		add di,dx
		add di,cx
		; Read one line
		mov ah,3fh
		mov cx,[sizey]
		mov dx,offset ScrLine
		int 21h
		; Copy one line into video memory
		cld ; Clear direction flag, for movsb
		mov cx,[sizey]
		mov si,offset ScrLine
		rep movsb ; Copy line to the screen
		 ;rep movsb is same as the following code :
		 ;mov es:di, ds:si
		 ;inc si
		 ;inc di
		 ;dec cx
		 ;loop until cx=0
		pop si
		pop cx
		loop PrintBMPLoop
	
	ret
endp CopyBitmap
proc closefile 
     mov bx, [word ptr filehandle]
     mov ah,3eh
     int 21h
     jc error_closefil_12
     ret
     error_closefil_12:
	 stc
	 ret
endp
;------------------------------------------------- end grphics



;---------------------------------------------------start random
proc random
	mov si, offset num_saver
	mov cx,50
	RandLoop:
		;generate random number, cx number of times
		mov ax, [Clock] ; read timer counter
		mov ah, [byte cs:bx] ; read one byte from memory
		xor al, ah ;xor memory and counter
		and al, 00001111b ; leave result between 0-15
		mov bl, al
		mov al,21							 ;this  random proc makes me n amount of random positions on the screen for me to print on			;copied from the book
		mul bl
		mov [si] , ax
		add si, 2
		inc bx
		loop RandLoop
		ret
endp random


;-------------------------------------------------------------------- ending of creating random numbers



;-------------------------------------------------------------------- start timer
proc frameclock ;timer
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]
	FirstTick :
		cmp ax, [Clock]
		je FirstTick
		; count 0.5 sec
		mov cx, 1 ; 3x0.055sec = ~0.275sec
	DelayLoop:											; this is a timer i haven't made a timer for each proc yet
		mov ax, [Clock]
		Tick :
			cmp ax, [Clock]
			je Tick
			loop DelayLoop
	ret
endp frameclock
;------------------------------------------------------------------------ end timer


;---------------------------------------------   choosing the alien ship
proc choose_Ship
	                
	
agine:
	cmp [word si],1d
	je finish
					; choose ship is a function that checks what is the ship that i can print in other words which ship haven't been destroyed yet	
	add si,2d
	jmp agine

finish:
	sub si ,[diffrence_between_ship]
ret_no_more_1:
	ret
endp choose_Ship




proc first_choose_ship
	mov si, offset print_condition_1
agine1:
	cmp [word si],1d
	je finish1
	
						; choose ship first is a function that checks what is the first ship that i can print

	add si,2d
	jmp agine1
finish_and_ending_game1:   
finish1:
	sub si ,[diffrence_between_ship]
	ret
endp first_choose_ship
;----------------------------------------------- ending of choosing alien ship



;----------------------------------------------- checks if there was any kind of collision and if yes remove both of the bullte and the ship


proc check_what_bull_touch
	add si ,[diffrence_between_bullet]
	mov [word si] , 0
	sub si , [diffrence_between_bullet]
	dec [amount_to_print_bull]
	call make_sound
	ret
endp check_what_bull_touch


proc make_sound

	in al, 61h
	or al, 00000011b
	out 61h, al
	mov cx, 15000
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 131Hz
	loop23:
	mov ax, [note]

	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	mov ax, [note1]

	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	loop loop23

	; close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret
endp make_sound
;----------------------------------------------- proc that checks if the bullet and the alien ship have touched


proc check_alship_touch_bull
	mov di  ,  si
	mov cx, [amount_to_print_bull]
	cmp cx , 0
	je ending5
	mov bx, [si]
	call first_choose_bullet
	loop1:
	cmp cx,[amount_to_print_bull]
	je skip_si6					
	call choose_bull
skip_si6:
	mov ax, [si]
	mov dx , bx
	sub [si] ,dx
	mov dx, [si]
	mov [si] ,ax
	cmp dx , 0
	je check_row
	
	cmp dx , 320
	je check_row
	
	cmp dx , 640
	je check_row
	
	cmp dx , 960
	je check_row
	
	cmp dx , 1280
	je check_row
	
	cmp dx , 1600
	je check_row
	
	cmp dx , 1920
	je check_row
	
	cmp dx , 2240
	je check_row
	
	cmp dx , 2560
	je check_row
	
	cmp dx , 2880
	je check_row
	
	cmp dx , 3200
	je check_row
	
	add si ,2	
	add si, [diffrence_between_bullet]
	loop loop1
	jmp ending5
check_row:
	call check_what_bull_touch
	inc [counter_destroy]
	mov si , di
	add si ,[diffrence_between_ship]
	mov [word si] , 0
	sub si , [diffrence_between_ship]
	dec [amount_to_print]
	
ending5:
	ret
endp check_alship_touch_bull



;properites of objects  and printing them:


;--------------------- alien ship props


proc print_black_screen
	mov [sizex], 12
	mov [sizey] ,12
	mov [filenameforgraphics] ,offset filename6
	mov cx, [amount_to_print]
	call first_choose_ship
	;mov si , offset num_saver2
	loop32:
		cmp cx,[amount_to_print]
		je skip_si5					
		call choose_Ship
skip_si5:
		push cx
		push si								; prints the ship to the screen
		call graphics123				
		pop si		
		add si,2
		add si, [diffrence_between_ship]
		pop cx
		loop loop32
		
		
		
	mov cx, [amount_to_print_bull]
	call first_choose_bullet
	cmp cx , 0
	je ending_bull3
	loop33:
		cmp cx,[amount_to_print]
		je skip_si8				
		call choose_bull
skip_si8: 
		;mov [si] , 41440d
		push cx
		push si								; prints the ship to the screen57
		call graphics123				
		pop si
		
		add si,2
		add si, [diffrence_between_bullet]
		pop cx
		loop loop33
ending_bull3:
	mov si  , offset pos_ship
	push si
	call graphics123
	pop si
	ret
endp print_black_screen


;--------------------- black screen props


proc print_alienship
	mov [sizex], 12
	mov [sizey] ,12
	mov [filenameforgraphics] ,offset filename1
	mov cx, [amount_to_print]
	call first_choose_ship
	loop27:
		cmp cx,[amount_to_print]
		je skip_si					
		call choose_Ship
skip_si:
		push cx
		push si								; prints the ship to the screen
		call graphics123				
		pop si
		
		push si
		pop si
		

		
		
		
		add si,2
		add si, [diffrence_between_ship]
		pop cx
		loop loop27
	ret
endp print_alienship
;---------------------------------- how many ships on screen	
proc ifdivide4proc
;jmp ending2
	cmp [ifdivide4] ,7
	je print1more
	jmp skip_print_1_more
print1more:
	mov	[ifdivide4],1
	inc [amount_to_print]
	jmp ending
skip_print_1_more:
	inc [ifdivide4]
	jmp ending2
ending:
	cmp [amount_to_print],5
	jae set_amount
	jmp ending2
set_amount:
	mov [amount_to_print],5
ending2:
	ret
endp ifdivide4proc
;----------------------------------------------- ending of amount of ships on screen





;------------------------------------- PRINT SHip
proc print_ship
	mov [sizex], 12
	mov [sizey] ,12
	mov [filenameforgraphics] ,offset filename3
	mov si , offset pos_ship
		push si
		call graphics123				
		pop si
	ret
endp print_ship


;----------------------------------------------- uslees proc that checks the diffrence between num_saver and print_condition_1
proc get_sub_from_random_number_and_conditi_num
	mov ax ,offset print_condition_1
	mov bx , offset num_saver
	sub ax,bx
	mov [diffrence_between_ship],ax
	ret
endp get_sub_from_random_number_and_conditi_num	

;----------------------------------------------- uslees proc that checks the diffrence between pos_bullet and print_condition_2
proc get_sub_from_pos_bull_and_print_con_2
	mov ax ,offset print_condition_2
	mov bx , offset pos_bullet
	sub ax,bx
	mov [diffrence_between_bullet],ax
	ret
endp get_sub_from_pos_bull_and_print_con_2	




proc make_slot_for_bullet
	mov si, offset print_condition_2
agine7:
	cmp [word si],0d
	je set_1
	add si,2d
					; opens slot for another bullet
	jmp agine7
set_1:
	mov [word si],1
finish2:
	ret
endp make_slot_for_bullet



proc make_bullet
	mov bx, [pos_ship]
	sub si ,[diffrence_between_bullet]
	mov [word si] , bx
	ret	
endp make_bullet



proc first_choose_bullet
	mov si, offset print_condition_2
	mov dx ,offset print_condition_2
	add dx, 40d
agine15:
	cmp [word si],1d
	je finish16
	add si,2d
	cmp si,dx						; choose ship first is a function that checks what is the first ship that i can print
	je finish16
	jmp agine15
finish16:
	sub si ,[diffrence_between_bullet]
	ret
endp first_choose_bullet

proc choose_bull
	mov dx ,offset print_condition_2
	add dx, 42d
agine14:
	cmp [word si],1d
	je finish14
	add si,2d
	cmp si,dx
	je finish14				; choose ship is a function that checks what is the ship that i can print in other words which ship haven't been destroyed yet
	jmp agine14
finish14:
	sub si ,[diffrence_between_bullet]
	ret
endp choose_bull




proc change_pos_ship_and_bullet
	mov cx, [amount_to_print]
	call first_choose_ship

	loop30:
		cmp cx,[amount_to_print]
		je skip_si4					
		call choose_Ship
skip_si4:
		cmp [word si] , 41600
		jae set_0_ship
		call changexypos
		jmp skip_stop_game
set_0_ship:
		add si, [diffrence_between_ship]
		mov si, 0
		sub si , [diffrence_between_ship]
		mov [game_condition] , 0
skip_stop_game:
		add si,2
		add si, [diffrence_between_ship]
		loop loop30
		;---------------------
	mov cx, [amount_to_print_bull]
	call first_choose_bullet
	cmp cx , 0
	je ending_bull1
	loop31:
		cmp cx,[amount_to_print]
		je skip_si10				
		call choose_bull
skip_si10: 
		
		cmp [word si] , 1280
		jbe set_0_bull
		call changexypos_down
		jmp skip_stop_bull
set_0_bull:
		add si, [diffrence_between_bullet]
		mov [word si], 0
		sub si , [diffrence_between_bullet]
		dec [amount_to_print_bull]
skip_stop_bull:
		
		
										; prints the ship to the screen57
		
		
		
		add si,2
		add si, [diffrence_between_bullet]
		
		loop loop31
ending_bull1:
	

	ret
endp change_pos_ship_and_bullet




proc print_bull
	mov [sizex], 12
	mov [sizey] ,12
	mov [filenameforgraphics] ,offset filename4
	mov cx, [amount_to_print_bull]
	call first_choose_bullet
	cmp cx , 0
	je ending_bull
	loop28:
		cmp cx,[amount_to_print]
		je skip_si1					
		call choose_bull
skip_si1: 
		
		push cx
		push si								; prints the ship to the screen57
		call graphics123				
		pop si
		
		add si,2
		add si, [diffrence_between_bullet]
		pop cx
		loop loop28
ending_bull:
	ret
endp print_bull

proc printMain
	mov [sizex], 200
	mov [sizey] ,320
	mov [filenameforgraphics] ,offset filename5
	mov si , offset num_saver1
	push si												; clearing the screen *** i think 320x200 isn't right
	call graphics123			
	pop si
	ret
endp printMain





proc print_black_screen_Main
	mov [sizex], 200
	mov [sizey] ,320
	mov [filenameforgraphics] ,offset filename2
	mov si , offset num_saver1
	push si												; clearing the screen *** i think 320x200 isn't right
	call graphics123			
	pop si
	ret
endp print_black_screen_Main






proc check_collision
	mov cx, [amount_to_print]
	call first_choose_ship
	loop34:
		cmp cx,[amount_to_print]
		je skip_si7					
		call choose_Ship
skip_si7:
		push cx
		
		push si
		call check_alship_touch_bull
		pop si
		

		
		
		
		add si,2
		add si, [diffrence_between_ship]
		pop cx
		loop loop34
	
	ret
endp check_collision




proc print_background
	mov [sizex], 200
	mov [sizey] ,320
	cmp [counter] , 8
	je set_0_saver
	jmp skip_set_0_saver
set_0_saver:
mov [counter] ,0
skip_set_0_saver:
	mov si , offset num_saver_space
	add si  , [counter]
	mov bl , [byte ptr si]
	mov [filenameforgraphics] , bl
	mov si , offset num_saver1
	push si												;
	call graphics123			
	pop si
	inc [counter]
	ret
endp print_background
	
	
proc reset_game
	call random			;num_saver dw 50 dup(?)
	mov si , offset print_condition_1
	mov cx, 50 ;print_condition_1 dw 50 dup(1)   
	condition_1_reset:
	mov [word ptr si],1
	add si ,2
	loop condition_1_reset
	mov [pos_ship] , 41747d
	
	mov si , offset pos_bullet
	mov cx, 20 ;pos_bullet dw 20 dup (?) 
	pos_bullet_reset:
	mov [word si],0
	add si ,2
	loop pos_bullet_reset
	
	mov si ,offset print_condition_1
	mov cx, 50 ;print_condition_1 dw 50 dup(1)   
	print_condition_1_reset:
	mov [word si],1
	add si ,2
	loop print_condition_1_reset
	
	mov si ,offset print_condition_2
	mov cx, 50 ;print_condition_2 dw 20 dup(1)   
	print_condition_2_reset:
	mov [word si],0
	add si ,2
	loop print_condition_2_reset
	
	mov [game_condition] ,1
	
	
	mov [ifdivide4] , 0d
	
	mov [amount_to_print] , 1d  
	

	mov [amount_to_print_bull] , 0
	
	mov [counter] ,0
	mov [counter_destroy],0

	ret
endp reset_game
	
	
	
proc print_all	

		call print_background
				
		
		call print_ship
		
		
		call print_alienship
		
		
		call print_bull
		
		ret
		
endp print_all



proc game_changer

		call check_collision
		
		call print_black_screen
		
		call change_pos_ship_and_bullet
		
		call ifdivide4proc
		
		
		
		ret
endp game_changer
	
	
	
proc print_Win

	mov [sizex], 200
	mov [sizey] ,320
	mov [filenameforgraphics] ,offset filename18
	mov si , offset num_saver1
	push si												
	call graphics123			
	pop si
	
	mov ah,1
	int 21h
	ret
endp print_Win
;start game here!!!!!!!!!!!!!!!!!!!


start:
	mov ax, @data
	mov ds, ax
	


	

;--------------------- game controls that u dont see :D
	

	
 ;Graphic mode
	mov ax, 13h
	int 10h
	jmp here_start
here_start_with_win:
		call print_Win
;print Main
here_start:
	call printMain
	call reset_game
press_agine:
	mov ah ,0
	int 16h
	cmp al,101
	
	je endgame
	cmp al ,112
	je start_game
	jmp press_agine
start_game:	
	call print_black_screen_Main
	call random
	call get_sub_from_random_number_and_conditi_num
	call get_sub_from_pos_bull_and_print_con_2
; Process BMP file
	game:
	
	WaitForData:
		
		call print_all
		
		call frameclock
		
		call game_changer
		
		
		
		
		
		
		cmp [game_condition],0
		

		je here_start
		cmp [counter_destroy],40
		

		je here_start_with_win
		
		
		
		; mouse 
		cmp [amount_to_print_bull], 2
		jae go_move
		mov ax,0h
		int 33h
		
		mov ax,3h
		int 33h
		cmp bx, 01h ; check left mouse click
		jne go_move
		inc [amount_to_print_bull]
		call make_slot_for_bullet
		call make_bullet
		
		jmp game
		
		;movement
		go_move:
			
			mov ah, 1
            Int 16h
            jz WaitForData
            mov ah, 0
            int 16h
            cmp ah, 1Eh
            je press_a
            cmp ah, 20h
            je press_b
			jmp game
            press_b:
			cmp [pos_ship],41920
			jae game
            add [pos_ship] , 21d
            jmp game
            press_a:
			cmp [pos_ship],41600
			jbe game
            sub [pos_ship] , 21d
            jmp game
			
			
	
    
	

	
	; Wait for key press
endgame:
	
	; Back to text mode
	mov al, 2
	int 10h
	
exit :
mov ax, 4c00h
int 21h
END start