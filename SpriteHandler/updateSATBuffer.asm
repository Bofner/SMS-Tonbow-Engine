; ==============================================================
;  Update the SATBuffer
; ==============================================================
; Parameters:   IYL = yPos
;               IXL = xPos
;               C = cc
; Returns: None
; Affects: A, B, DE, HL
; Update a single sprite in the SAT Buffer
    @UpdateSATBufferSingleEntry:
    ; Find the next open sprite entry
        ld hl, spriteHandler.spriteCount            ; HL -> spriteHandler.spriteCount
        ld a, (hl)                                  ; A = spriteHandler.spriteCount
        cp SPRITE_MAX
        ret z                                       ; Don't add one if we are already at max
        inc (hl)                                    ; spriteHandler.spriteCount += 1
        ld b, (hl)                                  ; B = priteHandler.spriteCount
        inc hl                                      ; HL -> spriteHandler.vBuffer.0
        ld d, $00
        ld e, a                                     ; DE = spriteHandler.spriteCount
        add hl, de                                  ; HL -> spriteHandler.vBuffer.NEXTFREE
    ; Add the new yPos
        ld a, iyl
        ld (hl), a
        inc hl                                      ; HL -> spriteHandler.vBuffer.NEXTFREE + 1
        ld (hl), SAT_TERMINATOR_BYTE
    ; Find the same sprite's hcBuffer
        ; To get from V to HC it's hc = vBufferAddress + SPRITE_MAX + (spriteCount - 1)
        ld a, SPRITE_MAX - 1
        dec b
        add a, b
    ; Use DE to get to the address for the next xPos
        ld d, $00
        ld e, a                                     ; DE = distance to spriteHandler.hcBuffer.NEXTFREE
        add hl, de                                  ; HL -> spriteHandler.hcBuffer.NEXTFREE.h
    ; Add the new xPos
        ld a, ixl
        ld (hl), a
    ; And the CC
        inc hl                                      ; HL -> spriteHandler.hcBuffer.NEXTFREE.c
        ld (hl), c

        ret


