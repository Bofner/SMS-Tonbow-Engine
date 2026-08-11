
; ================================================================================


; ================================================================================
; Non-RST VDP Routines
; ================================================================================

.SECTION "Non-RST VDP Routines"
; Copies data to the VRAM quickly, and only 127-bytes
; Parameters: HL = data address, B = data length
; Affects: HL, BC
FastCopyToVDP:
    ld c, VDP_DATA                       ; We want to write data
    otir                                ; Write contents of HL to C with B bytes
    ret

; ================================================================================


; Copies font data to the VRAM
; Parameters: HL = data address, BC = data length
; Affects: A, HL, BC
WriteTextToBackground:
    
-:  ld a, (hl)                  ; Get data byte from location @ HL
    out (VDP_DATA), a           ; Send font character tile data
    xor a
    out (VDP_DATA), a           ; Send 0 (font will use BG color w/ no attributes)
    inc hl                      ; Point to next data byte
    dec bc                      ; Decrease our counter
    ld a, b
    or c
    jr nz, -
    ret

; ================================================================================


; Sets one or more VDP Registers (Each one contains a byte)
; Parameters: HL = data address, B = # of registers to update 
;             C = Which VDP regiseter $8(register#)
; Affects: A, B, C, HL
SetVDPRegisters:
-:  ld a,(hl)                            ; load one byte of data into A.
    out (PORT_VDP_ADDRESS),a             ; output data to VDP command port.
    ld a,c                               ; load the command byte.
    out (PORT_VDP_ADDRESS),a             ; output it to the VDP command port.
    inc hl                               ; inc. pointer to next byte of data.
    inc c                                ; inc. command byte to next register.
    djnz -                               ; jump back to '-' if b > 0.   
    ret

; ================================================================================


; Updates a single VDP Register 
; Parameters: A = register data (one byte) C = Which VDP regiseter $8(register#)
; Affects: A, C, B
UpdateVDPRegister:
    out (PORT_VDP_ADDRESS), a                 ; Load data into CDP
    ld a, c
    out (PORT_VDP_ADDRESS), a                 ; Tell it which register to put it to
    ret


; ================================================================================
; Visual Effects
; ================================================================================

; Clears VRAM
; Parameters: 
; Affects: A, B, C, HL
ClearVRAM:  
    ; First, let's set the VRAM write address to $0000
    ld hl, $0000 | VRAM_WRITE
    rst SetVDPAddress
    ; Next, let's clear the VRAM with a bunch of zeros
    ld bc, $4000        ; Counter for our zeros in VRAM
-:  xor a
    out (VDP_DATA), a    ; Output data in A to VRAM address (which auto increments)
    dec bc              ; Adjust the counter
    ld a, b             
    or c                ; Check if we are at zero
    jr nz,-             ; If not, loop back up
    ret 


; ================================================================================


; Disables the display
; Parameters: 
; Affects: A, B, C, HL
BlankScreen:
        ; Turn on screen (Maxim's explanation is too good not to use)
    ld a, %00100000
;            ||||||`- Zoomed sprites -> 16x16 pixels
;            |||||`-- Not doubled sprites -> 1 tile per sprite, 8x8
;            ||||`--- Mega Drive mode 5 enable
;            |||`---- 30 row/240 line mode
;            ||`----- 28 row/224 line mode
;            |`------ VBlank interrupts
;             `------- Enable display    
    ld c, $81
    call UpdateVDPRegister
    ret


; ================================================================================
; Palette Related 
; ================================================================================


; Data for an all black palette
FadedPalette:
    .db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
FadedPaletteEnd:


; ================================================================================


; Updates the BG Palette from the buffer
; Parameters: 
; Affects: A, HL, BC
LoadBackgroundPalette:
; Load Background Palette in VRAM
    ld hl, $C000 | CRAM_WRITE
    rst SetVDPAddress
    ld hl, currentBGPal.color0
    ld bc, $10
    rst CopyToVDP

    ret


; ================================================================================


; Updates the SPR Palette from the buffer
; Parameters: 
; Affects: A, BC, HL
LoadSpritePalette:
; Load Sprite Palette in VRAM
    ld hl, $C010 | CRAM_WRITE
    rst SetVDPAddress
    ld hl, currentSPRPal.color0
    ld bc, $10
    rst CopyToVDP

    ret


; ================================================================================


; Writes a palette to the buffer
; Parameters: HL = currentPalette.color0, DE = Palette address, B = size of palette
; Affects: A, HL, DE, B
PalBufferWrite:  
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    djnz PalBufferWrite

    ret

.ENDS