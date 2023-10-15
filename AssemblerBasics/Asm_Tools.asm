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
	mov r11, rdx
	shr r11, 32 ; R11 = pos
	movzx r11, r11w ; R11 = R11W = pos.Screen_width
	dec r11
	shl r11, 2 ; R11 = pos.Screen_width * 4 = Ширина экрана в байтах

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
	mov r11, rdx
	shr r11, 32 ; R11 = pos
	movzx r11, r11w ; R11 = R11W = pos.Screen_width
	shl r11, 2 ; R11 = pos.Screen_width * 4 = Ширина экрана в байтах

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

end