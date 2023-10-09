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
Draw_Line proc
;extern "C" void Draw_Line(CHAR_INFO *screen_buffer, SPos pos, int len, CHAR_INFO symbol);
;параметры:
;RCX - screen_buffer
;RDX - pos
;R8 - len
;R9 - symbol
;return RAX

	push rax
	push rcx
	push rdi

	mov rdi, rcx
	mov eax, r9d
	mov rcx, r8

	rep stosd ;STOre String Dword
	;rep - Команда выполняется то количество раз, которое указано в регистре rcx

	pop rdi
	pop rcx
	pop rax

	ret

Draw_Line endp
;-----------------------------------------------------------------------------------------------------------------
end
