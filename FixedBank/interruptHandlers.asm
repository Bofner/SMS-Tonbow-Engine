; ==============================================================
;  Interrupt Handler
; ==============================================================

.SECTION "Interrupt Handler"
InterruptHandler:
;Get the status of the VDP
    push af
        in a,(PORT_VDP_ADDRESS)     ;Get status of VDP
                                    ;Bit 7:     1 = VBlank 0 = HBlank
                                    ;Bit 6:     1 = >=9 sprites on raster
                                    ;Bit 5:     1 = Sprite collision
                                    ;Bit 4-0:   No function
        ld (VDPStatus), a           ;Save to check if we are at VBLANK
        or a                        ;Check if POS or NEG (Bit 7 OFF or ON)
    pop af
    ei
    reti
.ENDS


; ==============================================================
;  Pause button handler
; ==============================================================
.SECTION "Pause Handler"
PauseHandler:
    nop
    nop
    nop
    ei
    retn
.ENDS



;=========================================================
; HBlank
;=========================================================
.SECTION "HBlank Handler"
HBlank:
    ei
;Leave
    reti

.ENDS


;=========================================================
; VBlank
;=========================================================
.SECTION "VBlank Handler"
;If we are on the last scanline
VBlank:
;We are at VBlank
    ld hl, VDPStatus
    bit 7, a                        ;A = VDPStatus already
    jr z, +
    set 7, (hl)                     ;Sprite collision 
+:
;Update frame count up to 60
    ld hl, frameCount               ;Update frame count
    ld a, 60                        ;Check if we are at 60
    cp (hl)
    jr nz, +                        ;If we are, then reset
ResetFrameCount:
    ld (hl), -1
+:
    inc (hl)                        ;Otherwise, increase

EndVBlank:
    ei
;Leave
    reti
.ENDS