.code
;-----------------------------------------------------------------------------------------------------------------
Make_Sum proc
;extern "C" int Make_Sum(int one_value, int another_value)
;RCX - one_value
;RDX - another_value
;R8
;R9
;return RAX

	mov eax, ecx
	add eax, edx

	ret

Make_Sum endp
;-----------------------------------------------------------------------------------------------------------------
Get_Pos_Address proc
;параметры:
;RCX - screen_buffer
;RDX - pos
;return RDI

	;1. Вычисляем адрес вывода: address_offset =  (pos.Y * pos.Screen_Width + pos.X) * 4
	;1.1.pos.Y * pos.Screen_Width

	mov rax, rdx
	shr rax, 16 ;SHift Right (сдвиг вправо на 16 бит) AX = pos.Y_Pos
	movzx rax, ax ;RAX = AX = pos.Y_Pos

	mov rbx, rdx
	shr rbx, 32 ;SHift Right (сдвиг вправо на 32 бита) BX = pos.Screen_Width
	movzx rbx, bx ;RBX = BX = pos.Screen_Width

	imul rax, rbx ; RAX = RAX * RBX = pos.Y * pos.Screen_Width

	;1.2. RAX + pos.X_Pos

	movzx rbx, dx ; RBX = DX = pos.X_Pos
	add rax, rbx ; RAX = pos.Y * pos.Screen_Width + pos.X

	;1.3. RAX содержит смещение строки в символах, а надо в байтах.
	;т.к. каждый символ занимает 4 байта, надо умножить это смещение на 4

	shl rax, 2 ; RAX = RAX * 4 = address_offset
	mov rdi, rcx ; RDI = screen_buffer
	add rdi, rax ; RDI = screen_buffer + address_offset

	ret

Get_Pos_Address endp
;-----------------------------------------------------------------------------------------------------------------
Draw_Start_Symbol proc
;Выводим стартовый символ
;параметры:
;R8 - symbol
;RDI - текущий адрес в буфере окна
;return нет

	push rax
	push rbx

	mov eax, r8d ; получаем start и end symbol
	mov rbx, r8
	shr rbx, 32 ; RBX = EBX = { symbol.Start_Symbol, symbol.End_Symbol }
	mov ax, bx ; EAX = { symbol.Attribute, symbol.Start_Symbol }

	stosd
	
	pop rbx
	pop rax

	ret

Draw_Start_Symbol endp
;-----------------------------------------------------------------------------------------------------------------
Draw_End_Symbol proc
;Выводим конечный символ
;параметры:
;EAX - { symbol.Attribute, symbol.Main_Symbol }
;R8 - symbol
;RDI - текущий адрес в буфере окна
;return нет
	
	mov rbx, r8
	shr rbx, 48 ; RBX = BX = symbol.End_Symbol
	mov ax, bx ; EAX = { symbol.Attribute, symbol.End_Symbol }

	stosd


	ret

Draw_End_Symbol endp
;-----------------------------------------------------------------------------------------------------------------
Draw_Line_Horizontal proc
;extern "C" void Draw_Line_Horizontal(CHAR_INFO *screen_buffer, SPos pos, ASymbol symbol)
;параметры:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return нет

	push rax
	push rbx
	push rcx
	push rdi

	;1. Вычисляем адрес вывода
	call Get_Pos_Address ; RDI = позиция символа в буфере screen_buffer в позиции pos

	;2. Выводим стартовый символ
	call Draw_Start_Symbol

	;3. Выводим символы symbol.Main_Symbol
	mov eax, r8d
	mov rcx, rdx
	shr rcx, 48 ; RCX = CX = pos.Len

	rep stosd ;STOre String Dword
	;rep - Команда выполняется то количество раз, которое указано в регистре rcx

	;4. Выводим конечный символ
	call Draw_End_Symbol

	pop rdi
	pop rcx
	pop rbx
	pop rax

	ret

Draw_Line_Horizontal endp
;-----------------------------------------------------------------------------------------------------------------
Draw_Line_Vertical proc
;extern "C" void Draw_Line_Vertical(CHAR_INFO * screen_buffer, SPos pos, ASymbol symbol);
;параметры:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return нет

	push rax
	push rcx
	push rdi
	push r11

	;1. Вычисляем адрес вывода
	call Get_Pos_Address ; RDI = позиция символа в буфере screen_buffer в позиции pos
	
	;2. Вычисление коррекции позиции вывода
	call Get_Screen_Width_Size ; R11 = pos.Screen_width * 4 = Ширина экрана в байтах
	sub r11, 4

	;3. Выводим стартовый символ
	call Draw_Start_Symbol

	add rdi, r11

	;4. Готовим счётчик цикла
	mov rcx, rdx ;Помещаем RDX в RCX для использования цикла LOOP
	shr rcx, 48 ; RCX = CX = pos.Len

	mov eax, r8d ; eax = symbol

_1:
	stosd ; выводим символ
	add rdi, r11 ; переходим на следующую строку

	loop _1 ; цикл выполняется столько раз сколько указано в RCX 

	;5. Выводим конечный символ
	call Draw_End_Symbol

	pop r11
	pop rdi
	pop rcx
	pop rax

	ret

Draw_Line_Vertical endp
;-----------------------------------------------------------------------------------------------------------------
Show_Colors proc
;extern "C" void Show_Colors(CHAR_INFO * screen_buffer, SPos pos, CHAR_INFO symbol)
;параметры:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return нет

	push rax
	push rbx
	push rcx
	push rdi
	push r10
	push r11


	;1. Вычисляем адрес вывода
	call Get_Pos_Address ; RDI = позиция символа в буфере screen_buffer в позиции pos

	mov r10, rdi

	;2. Вычисление коррекции позиции вывода
	call Get_Screen_Width_Size ; R11 = pos.Screen_width * 4 = Ширина экрана в байтах


	;3. Готовим цикл
	mov rax, r8 ; RAX = EAX = symbol

	and rax, 0ffffh ;Обнуляем все байты RAX, кроме 0 и 1
	mov rbx, 16
	xor rcx, rcx ; RCX = 0

	_0:
		mov cl, 16

		_1:
			stosd ; Запись двойного слова в строку
			add rax, 010000h ; Единица, смещенная на 16 разрядов влево

		loop _1

		add r10, r11 ; переход
		mov rdi, r10 ; на новую строку

		dec rbx
	jnz _0

	pop r11
	pop r10
	pop rdi
	pop rcx
	pop rbx
	pop rax

	ret

Show_Colors endp
;-----------------------------------------------------------------------------------------------------------------
Get_Screen_Width_Size proc
; Вычисляет ширину экрана в байтах
;RDX - SPos pos ИЛИ SArea_pos pos
;return R11 =  pos.Screen_width * 4

	mov r11, rdx
	shr r11, 32 ; R11 = pos
	movzx r11, r11w ; R11 = R11W = pos.Screen_width
	shl r11, 2 ; R11 = pos.Screen_width * 4 = Ширина экрана в байтах
	ret

Get_Screen_Width_Size endp
;-----------------------------------------------------------------------------------------------------------------
Clear_Area proc
;extern "C" void Clear_Area(CHAR_INFO * screen_buffer,SArea_Pos area_pos, ASymbol symbol)
;параметры:
;RCX - screen_buffer
;RDX - area_pos
;R8 - symbol
;return нет

	push rax
	push rbx
	push rcx
	push rdi
	push r10
	push r11


;1. Вычисляем адрес вывода
	call Get_Pos_Address ; RDI = позиция символа в буфере screen_buffer в позиции pos

	mov r10, rdi

;2. Вычисление коррекции позиции вывода
	call Get_Screen_Width_Size ; R11 = pos.Screen_width * 4 = Ширина экрана в байтах

;3. Готовим цикл
	mov rax, r8 ; RAX = EAX = symbol

	mov rbx, rdx
	shr rbx, 48 ; BH = area_pos.Height, BL = area_pos.Width

	xor rcx, rcx ; RCX = 0

	_0:
		mov cl, bl; CL = BL = area_pos.Width

		rep stosd ; Запись двойного слова в строку


		add r10, r11 ; переход
		mov rdi, r10 ; на новую строку

		dec bh
	jnz _0

	pop r11
	pop r10
	pop rdi
	pop rcx
	pop rbx
	pop rax

	ret

Clear_Area endp
;-----------------------------------------------------------------------------------------------------------------
Draw_Text proc
;extern "C" int Draw_Text(CHAR_INFO * screen_buffer, SText_Pos pos, const wchar_t str)
;параметры:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return RAX - длина строки str

	push rbx
	push rdi
	push r8

;1. Вычисляем адрес вывода
	call Get_Pos_Address ; RDI = позиция символа в буфере screen_buffer в позиции pos

	mov rax, rdx
	shr rax, 32 ; EAX = pos.Attribute

	xor rbx, rbx ; RBX = 0
_1:
	mov ax, [r8] ; AL = очередной символ из строки
	
	cmp ax, 0 ;
	je _exit

	add r8, 2; переводим указатель на следующий символ строки

	stosd
	inc rbx
	jmp _1

_exit:
	mov rax, rbx

	pop r8
	pop rdi
	pop rbx

	ret

Draw_Text endp
;-----------------------------------------------------------------------------------------------------------------
Draw_Limited_Text proc
; extern "C" void Draw_Limited_Text(CHAR_INFO * screen_buffer, SText_Pos pos, const wchar_t* str, unsigned short limit);
;параметры:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;R9 - limit
;return RAX - длина строки str

	push rax
	push rcx
	push rdi
	push r8
	push r9

;1. Вычисляем адрес вывода
	call Get_Pos_Address ; RDI = позиция символа в буфере screen_buffer в позиции pos

	mov rax, rdx
	shr rax, 32 ; EAX = pos.Attribute

_1:
	mov ax, [r8] ; AL = очередной символ из строки
	
	cmp ax, 0 ;
	je _fill_spaces

	add r8, 2; переводим указатель на следующий символ строки

	stosd

	dec r9
	cmp r9, 0
	je _exit ; Прекращаем вывод, если строка достигла лимита limit

	jmp _1

_fill_spaces:
	mov ax, 020h ; AX = символ пробела
	mov rcx, r9 ; количество оставшихся пробелов

	rep stosd

_exit:
	pop r9
	pop r8
	pop rdi
	pop rcx
	pop rax

	ret

Draw_Limited_Text endp
;-----------------------------------------------------------------------------------------------------------------
Try_Lock proc
; Параметры
; RCX - int *key
; Возврат: RAX - 1 / 0 : True / False

	mov ebx, 0
	mov edx, 1


	mov eax, 1
	xchg eax, [ rcx ] ; Также блокирует выполнение других потоков и программ, которые обращаются к этой переменной

	; Если EAX = 0, то вернем 1, иначе 0
	cmp eax, 0
	cmove eax, edx
	cmovne eax, ebx

	ret

Try_Lock endp
;-----------------------------------------------------------------------------------------------------------------
Test_Command proc

	mov bx, 5
	mov cx, 7
	mov al, 1
	cmp al, 1

	; CMOVcc - команды условного перемещения
	cmove dx, bx ; move if equal
	cmovne dx, cx ; move if not equal
	
	xor eax, eax
	xor ecx, ecx

	; EXCHANGE
	mov eax, 1
	mov ecx, 2
	xchg eax, ecx ;exchange - меняет местами 2 значения

	; BYTE SWAP
	mov eax, 012345678h
	bswap eax ; перемешивает (инвертирует) местами байты регистра

	xor eax, eax
	xor ecx, ecx
	xor edx, edx

	; EXCHANGE ADD
	; XADD
	mov eax, 3
	mov ecx, 1
	xadd eax, edx

	xor eax, eax
	xor ecx, ecx
	xor edx, edx

	; COMPARE AND EXCHANGE
	; CMPXCHG
	mov eax, 3
	mov ecx, 4
	mov edx, 5
	cmpxchg ecx, edx

	; MOVE with Sign-Extension
	; MOVSX
	xor eax, eax
	xor ecx, ecx
	xor ebx, ebx
	mov ax, -1
	movzx ebx, ax ; расширяет без знака (заполняет нулями)
	movsx ecx, ax ; расширяет со знаком (заполняет F)

	; ADC
	; Добавление с переносом (складывает два операнда и флаг CF(CY в Visual Studio))
	xor eax, eax
	xor ebx, ebx

	mov al, 0ffh
	mov bl, 1

	add al, 10
	adc bl, 0

	; DIV - деление без знака
	xor eax, eax
	xor ebx, ebx

	mov ax, 25 ; AH:AL = 25
	mov bl, 6
	div bl

	;IDIV
	xor eax, eax
	xor ebx, ebx
	xor edx, edx
	
	mov eax, 0d4a51000h
	mov edx, 0e8h
	mov ebx, 555
	idiv ebx

	; NEG - инвертирует целое значение

	mov rax, 5

	neg rax

	; AND - вырезание по маске
	mov al, 11111010b
	mov bl, 00001111b

	and al, bl

	; OR - комбинирование нескольких переменных
	mov al, 11000000b
	mov bl, 00001100b

	or al, bl

	; XOR - вырезание битов по ключу (применяется в шифрование), обнуление значений
	mov al, 00000011b
	mov bl, 00000110b

	xor al, bl
	xor al, bl
	
	xor rax, rax

	; NOT - инвертирует биты
	mov al, 00000011b

	not al

	mov bl, -3
	neg bl
	mov bl, -3
	not bl
	inc bl


	ret

Test_Command endp

;-----------------------------------------------------------------------------------------------------------------

end