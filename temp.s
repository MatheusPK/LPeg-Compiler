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
	.globl	_fat                            ; -- Begin function fat
	.p2align	2
_fat:                                   ; @fat
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
	str	w0, [sp, #12]
	cbnz	w0, LBB1_2
; %bb.1:
	mov	w0, #1
	b	LBB1_3
LBB1_2:                                 ; %L4
	ldr	w19, [sp, #12]
	sub	w0, w19, #1
	bl	_fat
	mul	w0, w19, w0
LBB1_3:                                 ; %common.ret
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fatWhile                       ; -- Begin function fatWhile
	.p2align	2
_fatWhile:                              ; @fatWhile
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	sub	sp, sp, #16
	mov	w8, w0
	mov	w0, #1
	stur	w8, [x29, #-4]
	cbnz	w8, LBB2_2
LBB2_1:                                 ; %common.ret
	mov	sp, x29
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
LBB2_2:                                 ; %L17
	mov	x9, sp
	sub	x8, x9, #16
	mov	sp, x8
	stur	w0, [x9, #-16]
LBB2_3:                                 ; %L24
                                        ; =>This Inner Loop Header: Depth=1
	ldur	w9, [x29, #-4]
	ldr	w0, [x8]
	cmp	w9, #1
	b.lt	LBB2_1
; %bb.4:                                ; %L25
                                        ;   in Loop: Header=BB2_3 Depth=1
	ldur	w9, [x29, #-4]
	mul	w10, w0, w9
	sub	w9, w9, #1
	stur	w9, [x29, #-4]
	str	w10, [x8]
	b	LBB2_3
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	w0, #5
	bl	_fat
	mov	w19, w0
	mov	w0, #4
	bl	_fat
	add	w0, w19, w0
	bl	_printI
	mov	w0, #5
	bl	_fatWhile
	mov	w19, w0
	mov	w0, #4
	bl	_fatWhile
	add	w0, w19, w0
	bl	_printI
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	mov	w0, wzr
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"%d\n"

.subsections_via_symbols
