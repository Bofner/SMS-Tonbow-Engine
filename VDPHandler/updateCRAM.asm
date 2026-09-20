.SECTION "VDP CRAM Constants"
; Palette constants
    .DEFINE     CRAM_WRITE      $C000
    .DEFINE     PALETTE_SIZE    $10

; Palette structure
    .STRUCT paletteStruct
        color0      DB
        color1      DB
        color2      DB
        color3      DB
        color4      DB
        color5      DB
        color6      DB
        color7      DB
        color8      DB
        color9      DB
        colorA      DB
        colorB      DB
        colorC      DB
        colorD      DB
        colorE      DB
        colorF      DB
    .ENDST

.ENDS


.RAMSECTION "Palette Buffers" BANK 0 SLOT "RAM_SLOT"
; Background
	targetBGPal     INSTANCEOF paletteStruct	; Target BG palette for a fade in	                    
    currentBGPal    INSTANCEOF paletteStruct	; Current BG palette for a fade in

; Sprites
    targetSPRPal    INSTANCEOF paletteStruct	; Target SPR palette for a fade in                          
    currentSPRPal   INSTANCEOF paletteStruct	; Current SPR palette for a fade in
                                
.ENDS


.SECTION "Update VDP CRAM" APPENDTO "VDP CRAM Constants"
; ================================================================================
; Updates the entire palette with the palette stored in currentBGPal buffer
; ================================================================================
; Updates the BG Palette from the buffer
; Parameters: None
; Affects: A, HL, BC
LoadBackgroundPalette:
; Load Background Palette in VRAM
    ld hl, $C000 | CRAM_WRITE
    rst SetVDPAddress
    ld hl, currentBGPal.color0
    ld b, $10
    rst FastCopyToVRAM

    ret


; ================================================================================
; Updates the entire palette with the palette stored in currentSPRPal buffer
; ================================================================================
; Parameters: None
; Affects: A, BC, HL
LoadSpritePalette:
; Load Sprite Palette in VRAM
    ld hl, $C010 | CRAM_WRITE
    rst SetVDPAddress
    ld hl, currentSPRPal.color0
    ld b, $10
    rst FastCopyToVRAM

    ret


; ================================================================================
; Write a palette to the currentPalette buffer
; ================================================================================
; Parameters: HL = currentPalette.color0, DE = Palette address, B = size of palette
; Affects: A, HL, DE, B
PalBufferWrite:  
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    djnz PalBufferWrite

    ret


; ================================================================================
; Data for an all black palette
; ================================================================================
FadedPalette:
    .DB $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
FadedPaletteEnd:
.ENDS