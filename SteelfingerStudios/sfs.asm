.SECTION "Steelfinger Studios"
; ============================================================================================
;  STEELFINGER STUDIOS Splash Screen
; ============================================================================================
; .BANK SFSBankSMS
; .ORG $0000

InitSFS:
    di
; ==============================================================
;  Scene beginning
; ==============================================================
    ld hl, sceneComplete
    ld (hl), $00

    inc hl                                  ; ld hl, sceneID
    ld (hl), $00


; ==============================================================
;  Clear Video RAM
; ==============================================================
    @ClearData:
    ; Reset VRAM and SAT
        call ClearVRAM
        call ClearSATBuff
    ; Reset scroll values
        xor a
        out (PORT_VDP_ADDRESS), a
        ld a, $88
        out (PORT_VDP_ADDRESS), a		; Set BG X-Scroll to 0

        xor a
        out (PORT_VDP_ADDRESS), a
        ld a, $89
        out (PORT_VDP_ADDRESS), a		; Set BG Y-Scroll to 0


; ==============================================================
;  Load SFS Palettes
; ==============================================================
    @Palette:
    ; Write current BG palette to currentPalette struct
        ld hl, currentBGPal.color0
        ld de, SteelFingerBGPaletteSMS
        ld b, $10
        call PalBufferWrite

    ; Write current SPR palette to currentPalette struct
        ld hl, currentSPRPal.color0
        ld de, FadedPalette
        ld b, $10
        call PalBufferWrite

    ; Write target BG palette to targetPalette struct
        ld hl, targetBGPal.color0
        ld de, SteelFingerBGPaletteSMS
        ld b, $10
        call PalBufferWrite

    ; Write target SPR palette to targetPalette struct
        ld hl, targetSPRPal.color0
        ld de, FadedPalette
        ld b, $10
        call PalBufferWrite

    ; Actually update the palettes in VRAM
        call LoadBackgroundPalette
        call LoadSpritePalette

; ==============================================================
;  Load SFS Tiles
; ==============================================================
    @VideoRAM:
    ; Load SteelFinger Studios Screen
        ld hl, $0000 | VRAM_WRITE
        call SetVDPAddress
        ld hl, SteelFingerTilesSMS
        ld bc, SteelFingerTilesSMSEnd-SteelFingerTilesSMS
        call CopyToVDP
    /*     
    ; Load SteelFginer Studios Sprites
        ld hl, $2000 | VRAM_WRITE
        call SetVDPAddress
        ld hl, SteelFingerShimmer
        ld bc, SteelFingerShimmerEnd-SteelFingerShimmer
        call CopyToVDP  */
        
    ; Load Map
        ld hl, $3800 | VRAM_WRITE
        call SetVDPAddress
        ld hl, SteelFingerStudiosMapSMS
        ld bc, SteelFingerStudiosMapSMSEnd-SteelFingerStudiosMapSMS
        call CopyToVDP


; ==============================================================
;  Memory (Structures, Variables & Constants) 
; ==============================================================
    @Sprites:
    ;  We need to build one BIG shimmer out of 6 smaller shimmer bits
/*         .DEF    BIG_SHIMMER_WIDTH   $06
        .DEF    BIG_SHIMMER_HEIGHT  $06
        .DEF    BIG_SHIMMER_CC      $00
        .DEF    BIG_SHIMMER_Y       $70
        .DEF    BIG_SHIMMER_X       $30
        .DEF    BIG_SHIMMER_LENGTH  $09
        .DEF    BIG_SHIMMER_XY_VEL  $01
        .enum $DFFF - $FF export
            shimmerParts.0 instanceof spriteStruct
            shimmerParts instanceof spriteStruct BIG_SHIMMER_LENGTH - 1
            bigShimmer.yPos         db
            bigShimmer.xPos         db
        .ende

    ;  Initialize our bigShimmer coordinates
        ld hl, bigShimmer.yPos
        ld (hl), BIG_SHIMMER_Y
        ld hl, bigShimmer.xPos
        ld (hl), BIG_SHIMMER_X */

; ==============================================================
;  Set up screen
; ==============================================================
    @UpdateGameState:
    ; Update Game State
        ld hl, MainLoopSFS
        call UpdateGameState
    ; Turn on screen 
        ld a, %11100000 ; reg. 1
                        ; Always set to 1
                        ; Enable display
                        ; VBlank interrupts
                        ; 224 line mode
                        ; 240 line mode
                        ; Mega Drive mode 5 enable
                        ; 8x16 Sprites
                        ; Low Res, 16x16 Sprites 
        ld c, $81
        call UpdateVDPRegister
    ; Turn on Screen
        ei

MainLoopSFS:
    nop
    nop
    nop

    ret





; ========================================================
;  Background
; ========================================================
; ----------------
;  BG Maps
; ----------------
SteelFingerStudiosMapSMS:
    .INCLUDE "../Assets/SteelfingerStudios/Backgrounds/SteelfingerStudiosSMSMap.inc"
SteelFingerStudiosMapSMSEnd:
; ----------------
;  BG Palettes
; ----------------
SteelFingerBGPaletteSMS:
    .INCLUDE "../Assets/SteelfingerStudios/Backgrounds/SteelfingerStudiosSMSPal.inc"
SteelFingerBGPaletteSMSEnd:
; ----------------
;  BG Tiles
; ----------------
SteelFingerTilesSMS:
    .INCLUDE "../Assets/SteelfingerStudios/Backgrounds/SteelfingerStudiosSMSTiles.inc"
SteelFingerTilesSMSEnd:




; ========================================================
;  Sprites
; ========================================================
; ----------------
;  Shadow
; ----------------

SteelFingerSPRPalette:
    ; .include "../assets/test/Steelfinger Studios SMS-1000SPRPal.inc"
SteelFingerSPRPaletteEnd:

SteelFingerShimmer:
    ; .include "../assets/test/sfsShimmer_tiles.inc"
SteelFingerShimmerEnd:

.ENDS