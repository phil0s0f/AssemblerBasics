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
	mov r11, rdx
	shr r11, 32 ; R11 = pos
	movzx r11, r11w ; R11 = R11W = pos.Screen_width
	dec r11
	shl r11, 2 ; R11 = pos.Screen_width * 4 = ������ ������ � ������

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
	mov r11, rdx
	shr r11, 32 ; R11 = pos
	movzx r11, r11w ; R11 = R11W = pos.Screen_width
	shl r11, 2 ; R11 = pos.Screen_width * 4 = ������ ������ � ������

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

end