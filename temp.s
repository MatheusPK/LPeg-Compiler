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
	.globl	_criaMatriz                     ; -- Begin function criaMatriz
	.p2align	2
_criaMatriz:                            ; @criaMatriz
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	lsl	w8, w0, #3
	stp	w1, w0, [sp, #24]
	sxtw	x8, w8
	mov	x0, x8
	bl	_malloc
	str	wzr, [sp, #12]
	str	x0, [sp, #16]
LBB2_1:                                 ; %L10
                                        ; =>This Inner Loop Header: Depth=1
	ldr	w8, [sp, #12]
	ldr	w9, [sp, #28]
	ldr	x19, [sp, #16]
	cmp	w8, w9
	b.ge	LBB2_3
; %bb.2:                                ; %L11
                                        ;   in Loop: Header=BB2_1 Depth=1
	ldr	w8, [sp, #24]
	ldrsw	x20, [sp, #12]
	lsl	w8, w8, #2
	sxtw	x0, w8
	bl	_malloc
	ldr	w8, [sp, #12]
	str	x0, [x19, x20, lsl #3]
	add	w8, w8, #1
	str	w8, [sp, #12]
	b	LBB2_1
LBB2_3:                                 ; %L12
	mov	x0, x19
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_printaMatriz                   ; -- Begin function printaMatriz
	.p2align	2
_printaMatriz:                          ; @printaMatriz
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	sub	sp, sp, #32
	stp	wzr, w2, [x29, #-36]
	stur	w1, [x29, #-28]
	stur	x0, [x29, #-24]
	b	LBB3_2
LBB3_1:                                 ; %L48
                                        ;   in Loop: Header=BB3_2 Depth=1
	ldur	w8, [x29, #-36]
	add	w8, w8, #1
	stur	w8, [x29, #-36]
LBB3_2:                                 ; %L37
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB3_4 Depth 2
	ldur	w8, [x29, #-36]
	ldur	w9, [x29, #-28]
	cmp	w8, w9
	b.ge	LBB3_6
; %bb.3:                                ; %L38
                                        ;   in Loop: Header=BB3_2 Depth=1
	mov	x8, sp
	sub	x19, x8, #16
	mov	sp, x19
	stur	wzr, [x8, #-16]
LBB3_4:                                 ; %L46
                                        ;   Parent Loop BB3_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w8, [x19]
	ldur	w9, [x29, #-32]
	cmp	w8, w9
	b.ge	LBB3_1
; %bb.5:                                ; %L47
                                        ;   in Loop: Header=BB3_4 Depth=2
	ldursw	x8, [x29, #-36]
	ldur	x9, [x29, #-24]
	ldr	x8, [x9, x8, lsl #3]
	ldrsw	x9, [x19]
	ldr	w0, [x8, x9, lsl #2]
	bl	_printI
	ldr	w8, [x19]
	add	w8, w8, #1
	str	w8, [x19]
	b	LBB3_4
LBB3_6:                                 ; %L39
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w0, #2
	mov	w1, #2
	bl	_criaMatriz
	mov	w8, #1
	ldr	x9, [x0]
	mov	w1, #2
	mov	w2, #2
	str	x0, [sp, #8]
	str	w8, [x9]
	ldr	x9, [x0]
	str	wzr, [x9, #4]
	ldr	x9, [x0, #8]
	str	wzr, [x9]
	ldr	x9, [x0, #8]
	str	w8, [x9, #4]
	bl	_printaMatriz
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	mov	w0, wzr
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"%d\n"

l_.strD:                                ; @.strD
	.asciz	"%.16g\n"

.subsections_via_symbols
