.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
vector dd 1,3,5,4,11,-16,2,15,7,12,8,10,9,6,14,13
window_title DB "Puzzle",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

x dd ?
y dd ?

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code
;arg1 sa fie aria , arg2 e x , arg3 e y, arg4 e dimensiunea
desenare_linie_orizontala proc
	push ebp
	mov ebp, esp
	pusha
	mov esi, [ebp+arg1]
	mov eax ,[ebp+arg3]
	mov ebx , area_width
	mul ebx
	mov ebx , [ebp+arg2]
	add eax , ebx
	shl eax , 2
	add esi, eax
	mov ecx, [ebp+arg4]
	dhl:
	mov dword ptr [esi] , 0 
	add esi , 4
	loop dhl
	popa
	mov esp, ebp
	pop ebp
	ret
desenare_linie_orizontala endp

desenare_linie_verticala proc
	push ebp
	mov ebp, esp
	pusha
	mov esi, [ebp+arg1]
	mov eax ,[ebp+arg3]
	mov ebx , area_width
	mul ebx
	mov ebx , [ebp+arg2]
	add eax , ebx
	shl eax , 2
	add esi, eax
	mov ecx, [ebp+arg4]
	dvl:
	mov dword ptr [esi] , 0
	add esi , area_width
	add esi , area_width
	add esi , area_width
	add esi , area_width
	loop dvl
	popa
	mov esp, ebp
	pop ebp
	ret
desenare_linie_verticala endp

;arg1 -x matrice
;arg2 -y matrice

make_move proc 
	push ebp
	mov ebp, esp
	pusha
	
	mov eax,[ebp + arg2]
	mov ebx,4
	mul ebx
	mov ebx,[ebp + arg1]
	add eax,ebx
	
	mov ebx,eax
	sub ebx,4
	cmp ebx,0
	jl  continue1 
	cmp vector[ebx*4],-16
	jne continue1
	mov ecx,vector[eax*4]
	mov edx,vector[ebx*4]
	mov vector[eax*4],edx
	mov vector[ebx*4],ecx
	
	jmp final
	
	continue1:
	
	mov eax,[ebp + arg2]
	mov ebx,4
	mul ebx
	mov ebx,[ebp + arg1]
	add eax,ebx
	
	mov ebx,eax
	add ebx,4
	cmp ebx,15
	jg  continue2 

	cmp vector[ebx*4],-16
	jne continue2
	mov ecx,vector[eax*4]
	mov edx,vector[ebx*4]
	mov vector[eax*4],edx
	mov vector[ebx*4],ecx
	jmp final 
	continue2:
	
	
	mov eax,[ebp + arg2]
	mov ebx,4
	mul ebx
	mov ebx,[ebp + arg1]
	add eax,ebx
	
	mov ebx,eax
	sub ebx,1
	cmp ebx,0
	jl  continue3 
	cmp vector[ebx*4] ,-16
	jne continue3
	mov ecx,vector[eax*4]
	mov edx,vector[ebx*4]
	mov vector[eax*4],edx
	mov vector[ebx*4],ecx
	jmp final 
	continue3:
	
	mov eax,[ebp + arg2]
	mov ebx,4
	mul ebx
	mov ebx,[ebp + arg1]
	add eax,ebx
	
	mov ebx,eax
	add ebx,1
	cmp ebx,15
	jg  continue4 
	cmp vector[ebx*4] ,-16
	jne continue4
	mov ecx,vector[eax*4]
	mov edx,vector[ebx*4]
	mov vector[eax*4],edx
	mov vector[ebx*4],ecx
	jmp final 
	continue4:
	final :
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_move endp

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp


make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
;arg1 x fereastra(pixel)
;arg2 y fereastra (pixel)
transform proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax ,[ebp +arg1]
	xor edx,edx
	mov ebx,80
	div ebx
	dec eax
	mov x,eax
	
	mov eax ,[ebp +arg2]
	xor edx,edx
	mov ebx,80
	div ebx
	dec eax
	mov y,eax
	
	
	popa
	mov esp, ebp
	pop ebp
	ret
transform endp	

 pune_cifre proc
	push ebp
	mov ebp, esp
	pusha
	
	mov esi , offset vector
	
	mov eax , dword ptr [esi]
	add eax, '0'

	
	
	cmp eax , '9'
	jg greater_than_10_1
	
	push esi 
	make_text_macro ' ',area,105,115
	make_text_macro eax , area, 115 , 115
	make_text_macro ' ',area,125,115
	pop esi
	
	jmp continue1
	
	greater_than_10_1:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	push esi
	make_text_macro '1' , area , 110 , 115
	make_text_macro edx , area , 120 , 115
	pop esi
	
	continue1:
		
	add esi , 4
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_2
	
	push esi 
	make_text_macro ' ',area,185,115
	make_text_macro eax , area , 195 , 115
	make_text_macro ' ',area,205,115
	pop esi
	jmp continue2
	greater_than_10_2:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 190 , 115
	make_text_macro edx , area , 200 , 115
		
		 continue2:
	add esi , 4
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_3
	
	push esi 
	make_text_macro ' ',area,265,115
	make_text_macro eax , area , 275 , 115
	make_text_macro ' ',area,285,115
	pop esi
	jmp continue3
	greater_than_10_3:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 270 , 115
	make_text_macro edx , area , 280 , 115
		continue3:
		
	add esi , 4
	
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_4
	
	push esi 
	make_text_macro ' ',area,345,115
	make_text_macro eax , area , 355 , 115
	make_text_macro ' ',area,365,115
	pop esi
	jmp continue4
	greater_than_10_4:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 350 , 115
	make_text_macro edx , area , 360 , 115
		
		continue4:
	add esi , 4
	
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_5
	
	push esi 
	make_text_macro ' ',area,105,195
	make_text_macro eax , area , 115 , 195
	make_text_macro ' ',area,125,195
	pop esi
	
	jmp continue5
	greater_than_10_5:
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 110 , 195
	make_text_macro edx , area , 120 , 195
		
	continue5:	
	
	add esi , 4
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_16
	
	push esi 
	make_text_macro ' ',area,185,195
	make_text_macro eax , area , 195 , 195
	make_text_macro ' ',area,205,195
	pop esi
	jmp continue6
	greater_than_10_16:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 190 , 195
	make_text_macro edx , area , 200 , 195
	continue6:	
		
	add esi , 4
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_6
	
	push esi 
	make_text_macro ' ',area,265,195
	make_text_macro eax , area , 275 , 195
	make_text_macro ' ',area,285,195
	pop esi
	jmp continue61
	greater_than_10_6:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 270 , 195
	make_text_macro edx , area , 280 , 195
		continue61:
	add esi , 4
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_7
	
	push esi 
	make_text_macro ' ',area,345,195
	make_text_macro eax , area , 355 , 195
	make_text_macro ' ',area,365,195
	pop esi
	jmp continue7
	greater_than_10_7:
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 350 , 195
	make_text_macro edx , area , 360 , 195
	continue7:	
	add esi , 4
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_8
	
	push esi 
	make_text_macro ' ',area,105,275
	make_text_macro eax , area , 115 , 275
	make_text_macro ' ',area,125,275
	pop esi
	jmp continue8
	greater_than_10_8:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 110 , 275
	make_text_macro edx , area , 120 , 275
		continue8:
	add esi , 4
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_9
	
	push esi 
	make_text_macro ' ',area,185,275
	make_text_macro eax , area , 195 , 275
	make_text_macro ' ',area,205,275
	pop esi
	jmp continue9
	greater_than_10_9:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 190 , 275
	make_text_macro edx , area , 200 , 275
		continue9:
	add esi , 4
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_10
	
	push esi 
	make_text_macro ' ',area,265,275
	make_text_macro eax , area , 275 , 275
	make_text_macro ' ',area,285,275
	pop esi
	jmp continue10
	
	greater_than_10_10:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 270 , 275
	make_text_macro edx , area , 280 , 275
	continue10:	
	add esi , 4
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_11
	
	push esi
make_text_macro ' ',area,345,275	
	make_text_macro eax , area , 355 , 275
	make_text_macro ' ',area,365,275
	pop esi
	jmp continue11
	
	greater_than_10_11:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 350 , 275
	make_text_macro edx , area , 360 , 275
	continue11:	
	add esi , 4
	
	

	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_12
	
	push esi
	make_text_macro ' ',area,105,355	
	make_text_macro eax , area , 115 , 355
	make_text_macro ' ',area,125,355
	pop esi
	jmp continue12
	greater_than_10_12:
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 110 , 355
	make_text_macro edx , area , 120 , 355
	continue12:
	add esi , 4
	
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_13
	
	push esi 
	make_text_macro ' ',area,185,355
	make_text_macro eax , area , 195 , 355
	make_text_macro ' ',area,205,355
	pop esi
	jmp continue13
	greater_than_10_13:
	
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 190 , 355
	make_text_macro edx , area , 200 , 355
	continue13:	
	add esi , 4
	
	
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_14
	
	push esi 
	make_text_macro ' ',area,265,355
	make_text_macro eax , area , 275 , 355
	make_text_macro ' ',area,285,355
	pop esi
	jmp continue14
	greater_than_10_14:
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 270 , 355
	make_text_macro edx , area , 280 , 355
	continue14:	
	add esi , 4
	
	
	
	
	mov eax , dword ptr [esi]
	add eax , '0'
	
	cmp eax , '9'
	jg greater_than_10_15
	
	push esi 
	make_text_macro ' ',area,345,355
	make_text_macro eax , area , 355 , 355
	make_text_macro ' ',area,365,355
	pop esi
	jmp continue15
	greater_than_10_15:
	sub eax , '0'
	xor edx , edx
	mov ebx , 10
	div ebx
	add edx , '0'
	
	make_text_macro '1' , area , 350 , 355
	make_text_macro edx , area , 360 , 355
	continue15:	
	add esi , 4
	

	
	
	mov esp, ebp
	pop ebp
	ret
pune_cifre endp	


verificare proc
	mov ecx,15
	etfor:
	mov eax,16
	sub eax,ecx
	cmp eax,vector[eax*4-4]
	jne nowin
	loop etfor
	mov eax,15
	cmp vector[eax*4],-16
	jne nowin
	mov eax,1
	ret
	nowin:
	mov eax,0
	ret 
verificare endp



victorie proc
make_text_macro 'Y',area,200,420
make_text_macro 'O',area,210,420
make_text_macro 'U',area,220,420
make_text_macro ' ',area,230,420
make_text_macro 'W',area,240,420
make_text_macro 'O',area,250,420
make_text_macro 'N',area,260,420

ret
victorie endp

draw proc 
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
			
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	
	
	mov ecx, 5
	mov eax, 80
	
	linie_or:
	push 320
	push eax
	add eax,80
	push 80
	push area
	call desenare_linie_orizontala
	add esp,16
	loop linie_or
	
			;distanta pe orizontala 80 pixeli 
	
	
	mov ecx, 5
	mov eax, 80
	vgrid:
	push 320
	push 80
	push eax 
	add eax , 80
	push area
	call desenare_linie_verticala
	add esp , 16
	loop vgrid
	
	
	
	call pune_cifre
	jmp final_draw
	
evt_click:
	mov eax,[ebp +arg2]
	mov ebx,[ebp +arg3]
	push ebx
	push eax
	call transform
	add esp,8
	push y
	push x
	call make_move
	add esp,8
	call pune_cifre
	
	call verificare
	cmp eax,0
	je final_draw
	call victorie
	

evt_timer:
	inc counter
 
	
	final_draw:
	
	popa
	mov esp, ebp
	pop ebp
	ret
	
draw endp	



start:
	call verificare
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start