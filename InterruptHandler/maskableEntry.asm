;  ==============================================================
;   Interrupt Handler
;  ==============================================================
.RAMSECTION "Interrupt Variables" BANK 0 SLOT "RAM_SLOT"
    interruptHandler.VDPStatus                  DB  ; Holds VDP Status from the interrupt
                                                    ; Bit 7:     1 = VBlank
                                                    ; Bit 6:     1 = >=9 sprites on raster
                                                    ; Bit 5:     1 = Sprite collision
                                                    ; Bit 4-0:   No function
    interruptHandler.nextHBlankStepPointer      DW  ; Variable that tells where to go for next HBlank
.ENDS


.SECTION "Interrupt Handler"
; Determines whether we are at VBlank or HBlank
InterruptHandler:
    push af
        in a,(PORT_VDP_ADDRESS)     ; Get status of VDP
                                    ; Bit 7:     1 = VBlank 0 = HBlank
                                    ; Bit 6:     1 = >=9 sprites on raster
                                    ; Bit 5:     1 = Sprite collision
                                    ; Bit 4-0:   No function
        ld (interruptHandler.VDPStatus), a           ; Save to check if we are at VBLANK
        or a                        
        jp m, VBlank                ; Check if POS or NEG (Bit 7 OFF or ON)
        jp HBlank                   ; If POS, then HBlank
ReturnFromMaskableInterrupt:
    pop af
    ei
    reti

.ENDS


; =========================================================
;  HBlank
; =========================================================
.SECTION "HBlank Handler"
HBlank:
    nop
HBlankEnd:
    jp ReturnFromMaskableInterrupt

.ENDS


; =========================================================
;  VBlank
; =========================================================
.SECTION "VBlank Handler"
; We finished drawing the screen, its time for VBlank
VBlank:
    push hl
    ; Add one each frame
        ld hl, universalTimer           ; Update frame count
        inc (hl)                        ; Otherwise, increase
VBlankEnd:
    pop hl
    jp ReturnFromMaskableInterrupt
.ENDS