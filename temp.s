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
	.globl	_bigger                         ; -- Begin function bigger
	.p2align	2
_bigger:                                ; @bigger
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	wzr, w1, [sp, #16]
	str	x0, [sp, #24]
	str	wzr, [sp, #12]
	b	LBB2_2
LBB2_1:                                 ; %L18
                                        ;   in Loop: Header=BB2_2 Depth=1
	ldr	w8, [sp, #16]
	add	w8, w8, #1
	str	w8, [sp, #16]
LBB2_2:                                 ; %L7
                                        ; =>This Inner Loop Header: Depth=1
	ldp	w9, w8, [sp, #16]
	sub	w8, w8, #1
	cmp	w9, w8
	b.ge	LBB2_5
; %bb.3:                                ; %L8
                                        ;   in Loop: Header=BB2_2 Depth=1
	ldp	w9, w8, [sp, #12]
                                        ; kill: def $w9 killed $w9 def $x9
	ldr	x10, [sp, #24]
	sxtw	x9, w9
	add	w8, w8, #1
	ldr	w9, [x10, x9, lsl #2]
	ldr	w8, [x10, w8, sxtw #2]
	cmp	w9, w8
	b.ge	LBB2_1
; %bb.4:                                ; %L16
                                        ;   in Loop: Header=BB2_2 Depth=1
	ldr	w8, [sp, #16]
	add	w8, w8, #1
	str	w8, [sp, #12]
	b	LBB2_1
LBB2_5:                                 ; %L9
	ldr	w0, [sp, #12]
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_arrayAoQuadrado                ; -- Begin function arrayAoQuadrado
	.p2align	2
_arrayAoQuadrado:                       ; @arrayAoQuadrado
	.cfi_startproc
; %bb.0:
	stp	wzr, w1, [sp, #-16]!
	.cfi_def_cfa_offset 16
	str	x0, [sp, #8]
LBB3_1:                                 ; %L43
                                        ; =>This Inner Loop Header: Depth=1
	ldp	w8, w9, [sp]
	cmp	w8, w9
	b.ge	LBB3_3
; %bb.2:                                ; %L44
                                        ;   in Loop: Header=BB3_1 Depth=1
	ldrsw	x8, [sp]
	ldr	x10, [sp, #8]
	lsl	x9, x8, #2
	add	w8, w8, #1
	ldr	w11, [x10, x9]
	str	w8, [sp]
	mul	w11, w11, w11
	str	w11, [x10, x9]
	b	LBB3_1
LBB3_3:                                 ; %L45
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_imprimeArray                   ; -- Begin function imprimeArray
	.p2align	2
_imprimeArray:                          ; @imprimeArray
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stp	wzr, w1, [sp]
	str	x0, [sp, #8]
LBB4_1:                                 ; %L73
                                        ; =>This Inner Loop Header: Depth=1
	ldp	w8, w9, [sp]
	cmp	w8, w9
	b.ge	LBB4_3
; %bb.2:                                ; %L74
                                        ;   in Loop: Header=BB4_1 Depth=1
	ldrsw	x8, [sp]
	ldr	x9, [sp, #8]
	ldr	w0, [x9, x8, lsl #2]
	bl	_printI
	ldr	w8, [sp]
	add	w8, w8, #1
	str	w8, [sp]
	b	LBB4_1
LBB4_3:                                 ; %L75
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
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
	mov	w0, #40
	bl	_malloc
	mov	x8, #1
	mov	x9, #3
	movk	x8, #2, lsl #32
	movk	x9, #4, lsl #32
	mov	x10, #5
	mov	x11, #7
	movk	x10, #6, lsl #32
	movk	x11, #8, lsl #32
	stp	x8, x9, [x0]
	mov	x8, #9
	movk	x8, #10, lsl #32
	mov	w1, #10
	mov	x19, x0
	str	x0, [sp, #8]
	stp	x10, x11, [x0, #16]
	str	x8, [x0, #32]
	bl	_bigger
	ldr	w0, [x19, w0, sxtw #2]
	bl	_printI
	ldr	x0, [sp, #8]
	mov	w1, #10
	bl	_imprimeArray
	ldr	x0, [sp, #8]
	mov	w1, #10
	bl	_arrayAoQuadrado
	ldr	x0, [sp, #8]
	mov	w1, #10
	bl	_imprimeArray
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
	.asciz	"%.16g\n"

.subsections_via_symbols
