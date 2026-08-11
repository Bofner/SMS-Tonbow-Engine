; Updates the Sprite Attribute table with the SAT Buffer
; Parameters: None
; Affects: B, C, HL
    @UpdateSAT:
    ; Set vPositions
        ld hl, VPOS_VRAM | VRAM_WRITE           ; Telling the VDP where to write this data
        rst SetVDPAddress                  
        ld a, (spriteHandler.spriteCount)
        ld b, a                             ; Load the SAT with only the sprites' vPos that exist
        inc b                               ; As well as the terminator byte
        ld c, VDP_DATA                      ; We want to write data
        ld hl, spriteHandler.vBuffer.0      ; We are writing the contents of the SAT buffer
        otir                                ; Write contents of HL to C with B bytes
    ; Set xPos and CC
        ld hl, HPOS_CC_VRAM | VRAM_WRITE    ; Telling the VDP where to write this data
        rst SetVDPAddress                  ; \
        ld a, (spriteHandler.spriteCount)   ;  }
        add a, a                            ;  } Load the SAT with only the sprites' xPos and cc that exist
        ld b, a                             ;  } And the terminator byte
        inc b                               ; /
        ld c, VDP_DATA                      ; We want to write data
        ld hl, spriteHandler.hcBuffer.0     ; We are writing the contents of the SAT buffer
        otir                                ; Write contents of HL to C with B bytes
        ; This will always be the first thing to happen at after VBLANK
        ; So we will use this opportunity to reset the spriteUpdateCount
        ld hl, spriteHandler.spriteCount
        ld (hl), 0

        ret
