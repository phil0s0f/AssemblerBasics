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
;���������:
;RCX - screen_buffer
;RDX - pos
;return RDI

	;1. ��������� ����� ������: address_offset =  (pos.Y * pos.Screen_Width + pos.X) * 4
	;1.1.pos.Y * pos.Screen_Width

	mov rax, rdx
	shr rax, 16 ;SHift Right (����� ������ �� 16 ���) AX = pos.Y_Pos
	movzx rax, ax ;RAX = AX = pos.Y_Pos

	mov rbx, rdx
	shr rbx, 32 ;SHift Right (����� ������ �� 32 ����) BX = pos.Screen_Width
	movzx rbx, bx ;RBX = BX = pos.Screen_Width

	imul rax, rbx ; RAX = RAX * RBX = pos.Y * pos.Screen_Width

	;1.2. RAX + pos.X_Pos

	movzx rbx, dx ; RBX = DX = pos.X_Pos
	add rax, rbx ; RAX = pos.Y * pos.Screen_Width + pos.X

	;1.3. RAX �������� �������� ������ � ��������, � ���� � ������.
	;�.�. ������ ������ �������� 4 �����, ���� �������� ��� �������� �� 4

	shl rax, 2 ; RAX = RAX * 4 = address_offset
	mov rdi, rcx ; RDI = screen_buffer
	add rdi, rax ; RDI = screen_buffer + address_offset

	ret

Get_Pos_Address endp
;-----------------------------------------------------------------------------------------------------------------
Draw_Start_Symbol proc
;������� ��������� ������
;���������:
;R8 - symbol
;RDI - ������� ����� � ������ ����
;return ���

	push rax
	push rbx

	mov eax, r8d ; �������� start � end symbol
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
;������� �������� ������
;���������:
;EAX - { symbol.Attribute, symbol.Main_Symbol }
;R8 - symbol
;RDI - ������� ����� � ������ ����
;return ���
	
	mov rbx, r8
	shr rbx, 48 ; RBX = BX = symbol.End_Symbol
	mov ax, bx ; EAX = { symbol.Attribute, symbol.End_Symbol }

	stosd


	ret

Draw_End_Symbol endp
;-----------------------------------------------------------------------------------------------------------------
Draw_Line_Horizontal proc
;extern "C" void Draw_Line_Horizontal(CHAR_INFO *screen_buffer, SPos pos, ASymbol symbol)
;���������:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return ���

	push rax
	push rbx
	push rcx
	push rdi

	;1. ��������� ����� ������
	call Get_Pos_Address ; RDI = ������� ������� � ������ screen_buffer � ������� pos

	;2. ������� ��������� ������
	call Draw_Start_Symbol

	;3. ������� ������� symbol.Main_Symbol
	mov eax, r8d
	mov rcx, rdx
	shr rcx, 48 ; RCX = CX = pos.Len

	rep stosd ;STOre String Dword
	;rep - ������� ����������� �� ���������� ���, ������� ������� � �������� rcx

	;4. ������� �������� ������
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
;���������:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return ���

	push rax
	push rcx
	push rdi
	push r11

	;1. ��������� ����� ������
	call Get_Pos_Address ; RDI = ������� ������� � ������ screen_buffer � ������� pos
	
	;2. ���������� ��������� ������� ������
	call Get_Screen_Width_Size ; R11 = pos.Screen_width * 4 = ������ ������ � ������
	sub r11, 4

	;3. ������� ��������� ������
	call Draw_Start_Symbol

	add rdi, r11

	;4. ������� ������� �����
	mov rcx, rdx ;�������� RDX � RCX ��� ������������� ����� LOOP
	shr rcx, 48 ; RCX = CX = pos.Len

	mov eax, r8d ; eax = symbol

_1:
	stosd ; ������� ������
	add rdi, r11 ; ��������� �� ��������� ������

	loop _1 ; ���� ����������� ������� ��� ������� ������� � RCX 

	;5. ������� �������� ������
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
;���������:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return ���

	push rax
	push rbx
	push rcx
	push rdi
	push r10
	push r11


	;1. ��������� ����� ������
	call Get_Pos_Address ; RDI = ������� ������� � ������ screen_buffer � ������� pos

	mov r10, rdi

	;2. ���������� ��������� ������� ������
	call Get_Screen_Width_Size ; R11 = pos.Screen_width * 4 = ������ ������ � ������


	;3. ������� ����
	mov rax, r8 ; RAX = EAX = symbol

	and rax, 0ffffh ;�������� ��� ����� RAX, ����� 0 � 1
	mov rbx, 16
	xor rcx, rcx ; RCX = 0

	_0:
		mov cl, 16

		_1:
			stosd ; ������ �������� ����� � ������
			add rax, 010000h ; �������, ��������� �� 16 �������� �����

		loop _1

		add r10, r11 ; �������
		mov rdi, r10 ; �� ����� ������

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
; ��������� ������ ������ � ������
;RDX - SPos pos ��� SArea_pos pos
;return R11 =  pos.Screen_width * 4

	mov r11, rdx
	shr r11, 32 ; R11 = pos
	movzx r11, r11w ; R11 = R11W = pos.Screen_width
	shl r11, 2 ; R11 = pos.Screen_width * 4 = ������ ������ � ������
	ret

Get_Screen_Width_Size endp
;-----------------------------------------------------------------------------------------------------------------
Clear_Area proc
;extern "C" void Clear_Area(CHAR_INFO * screen_buffer,SArea_Pos area_pos, ASymbol symbol)
;���������:
;RCX - screen_buffer
;RDX - area_pos
;R8 - symbol
;return ���

	push rax
	push rbx
	push rcx
	push rdi
	push r10
	push r11


;1. ��������� ����� ������
	call Get_Pos_Address ; RDI = ������� ������� � ������ screen_buffer � ������� pos

	mov r10, rdi

;2. ���������� ��������� ������� ������
	call Get_Screen_Width_Size ; R11 = pos.Screen_width * 4 = ������ ������ � ������

;3. ������� ����
	mov rax, r8 ; RAX = EAX = symbol

	mov rbx, rdx
	shr rbx, 48 ; BH = area_pos.Height, BL = area_pos.Width

	xor rcx, rcx ; RCX = 0

	_0:
		mov cl, bl; CL = BL = area_pos.Width

		rep stosd ; ������ �������� ����� � ������


		add r10, r11 ; �������
		mov rdi, r10 ; �� ����� ������

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
;���������:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return RAX - ����� ������ str

	push rbx
	push rdi
	push r8

;1. ��������� ����� ������
	call Get_Pos_Address ; RDI = ������� ������� � ������ screen_buffer � ������� pos

	mov rax, rdx
	shr rax, 32 ; EAX = pos.Attribute

	xor rbx, rbx ; RBX = 0
_1:
	mov ax, [r8] ; AL = ��������� ������ �� ������
	
	cmp ax, 0 ;
	je _exit

	add r8, 2; ��������� ��������� �� ��������� ������ ������

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
;���������:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;R9 - limit
;return RAX - ����� ������ str

	push rax
	push rcx
	push rdi
	push r8
	push r9

;1. ��������� ����� ������
	call Get_Pos_Address ; RDI = ������� ������� � ������ screen_buffer � ������� pos

	mov rax, rdx
	shr rax, 32 ; EAX = pos.Attribute

_1:
	mov ax, [r8] ; AL = ��������� ������ �� ������
	
	cmp ax, 0 ;
	je _fill_spaces

	add r8, 2; ��������� ��������� �� ��������� ������ ������

	stosd

	dec r9
	cmp r9, 0
	je _exit ; ���������� �����, ���� ������ �������� ������ limit

	jmp _1

_fill_spaces:
	mov ax, 020h ; AX = ������ �������
	mov rcx, r9 ; ���������� ���������� ��������

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
; ���������
; RCX - int *key
; �������: RAX - 1 / 0 : True / False

	mov ebx, 0
	mov edx, 1


	mov eax, 1
	xchg eax, [ rcx ] ; ����� ��������� ���������� ������ ������� � ��������, ������� ���������� � ���� ����������

	; ���� EAX = 0, �� ������ 1, ����� 0
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

	; CMOVcc - ������� ��������� �����������
	cmove dx, bx ; move if equal
	cmovne dx, cx ; move if not equal
	
	xor eax, eax
	xor ecx, ecx

	; EXCHANGE
	mov eax, 1
	mov ecx, 2
	xchg eax, ecx ;exchange - ������ ������� 2 ��������

	; BYTE SWAP
	mov eax, 012345678h
	bswap eax ; ������������ (�����������) ������� ����� ��������

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
	movzx ebx, ax ; ��������� ��� ����� (��������� ������)
	movsx ecx, ax ; ��������� �� ������ (��������� F)

	; ADC
	; ���������� � ��������� (���������� ��� �������� � ���� CF(CY � Visual Studio))
	xor eax, eax
	xor ebx, ebx

	mov al, 0ffh
	mov bl, 1

	add al, 10
	adc bl, 0

	; DIV - ������� ��� �����
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

	; NEG - ����������� ����� ��������

	mov rax, 5

	neg rax

	; AND - ��������� �� �����
	mov al, 11111010b
	mov bl, 00001111b

	and al, bl

	; OR - �������������� ���������� ����������
	mov al, 11000000b
	mov bl, 00001100b

	or al, bl

	; XOR - ��������� ����� �� ����� (����������� � ����������), ��������� ��������
	mov al, 00000011b
	mov bl, 00000110b

	xor al, bl
	xor al, bl
	
	xor rax, rax

	; NOT - ����������� ����
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