; ==============================================================
;  Clear SATBuffer
; ==============================================================
; Parameters:  	None
; Returns: None
; Affects: A, B, HL
    @ClearSATBuff:
        ld hl, spriteHandler.vBuffer.0
        ld b, SPRITE_MAX
        xor a
    -:
        ld (hl), a
        inc hl
        djnz -

        ld hl, spriteHandler.hcBuffer.0
        ld b, (2 * SPRITE_MAX)
        xor a
    -:
        ld (hl), a
        inc hl
        djnz -

        ret