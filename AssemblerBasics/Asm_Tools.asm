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
Draw_Line_Horizontal proc
;extern "C" void Draw_Line_Horizontal(CHAR_INFO *screen_buffer, SPos pos, CHAR_INFO symbol)
;���������:
;RCX - screen_buffer
;RDX - pos
;R8 - symbol
;return RAX

	push rax
	push rbx
	push rcx
	push rdi

	;1. ��������� ����� ������: addres_offset =  (pos.Y * pos.Screen_Width + pos.X) * 4
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

	shl rax, 2 ; RAX = RAX * 4 = addres_offset
	mov rdi, rcx ; RDI = screen_buffer
	add rdi, rax ; RDI = screen_buffer + addres_offset


	;2. ������� �������
	mov eax, r8d
	mov rcx, rdx
	shr rcx, 48 ; RCX = CX = pos.Len

	rep stosd ;STOre String Dword
	;rep - ������� ����������� �� ���������� ���, ������� ������� � �������� rcx

	pop rdi
	pop rcx
	pop rbx
	pop rax

	ret

Draw_Line_Horizontal endp
;-----------------------------------------------------------------------------------------------------------------
end