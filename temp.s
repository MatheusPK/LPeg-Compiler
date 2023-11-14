	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 14, 0
	.p2align	2                               ; -- Begin function printI
_printI:                                ; @printI
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w8, w0
Lloh0:
	adrp	x0, l_.str@PAGE
Lloh1:
	add	x0, x0, l_.str@PAGEOFF
	str	x8, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.loh AdrpAdd	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function printD
_printD:                                ; @printD
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh2:
	adrp	x0, l_.strD@PAGE
Lloh3:
	add	x0, x0, l_.strD@PAGEOFF
	str	d0, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.loh AdrpAdd	Lloh2, Lloh3
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	w0, #8
	bl	_malloc
	str	x0, [sp, #8]
	mov	w0, #4
	mov	w19, #4
	bl	_malloc
	ldr	x8, [sp, #8]
	str	x0, [x8]
	mov	w0, #4
	bl	_malloc
	ldr	x8, [sp, #8]
	mov	w9, #1
	ldr	x10, [x8]
	str	x0, [x8, #8]
	str	w9, [x10]
	mov	w9, #3
	ldr	x10, [x8]
	str	w9, [x10, #4]
	mov	w9, #2
	ldr	x10, [x8, #8]
	str	w9, [x10]
	ldr	x9, [x8, #8]
	str	w19, [x9, #4]
	ldp	x9, x8, [x8]
	ldr	w9, [x9]
	ldr	w8, [x8, #4]
	add	w0, w9, w8
	bl	_printI
	ldr	x8, [sp, #8]
	ldp	x9, x8, [x8]
	ldr	w9, [x9, #4]
	ldr	w8, [x8]
	add	w0, w9, w8
	bl	_printI
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	mov	w0, wzr
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"%d\n"

l_.strD:                                ; @.strD
	.asciz	"%.16g"

.subsections_via_symbols
