.code

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

end