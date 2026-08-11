; ==============================================================
;  Initializes the Sprite Handler
; ==============================================================
; Parameters:  	None
; Returns: None
; Affects: A, B, HL
    @InitializeSpriteHandler:
    ; Initialize spriteCount and the SAT Buffer
        xor a
        ld hl, spriteHandler                    ; HL -> spriteHandler.spriteCount
        ld b, SPRITE_HANDLER_SIZE
        ld (hl), a
        inc hl                                  ; HL -> spriteHandler.vBuffer.0
        dec b                                   ; Counter - 1
        ld (hl), SAT_TERMINATOR_BYTE            ; Empty SAT
        inc hl                                  ; HL -> spriteHandler.vBuffer.1
        dec b                                   ; Counter - 1
    -:
        ld (hl), a                              ; spriteHandler.CURRENT.xxBuffer = $00
        inc hl                                  ; HL -> spriteHandler.NEXT.xxBuffer
        djnz -

        ret