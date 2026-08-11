; ================================================================================
;  Test Room Variables
; ================================================================================
.RAMSECTION "Cycle CC" BANK 0 SLOT "RAM_SLOT"
	tonbowCC			db
.ENDS

; ============================================================================================
;  Test Room 
; ============================================================================================
; .BANK SFSBankSMS
; .ORG $0000
.SECTION "Test Room"
InitTestRoom:
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
        call SpriteHandlerClass@ClearSATBuff
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
;  Init Variables
; ==============================================================
    @InitVariables:
        ld a, (FirstSpriteTextCC)
        ld (tonbowCC), a                ; ASCII "1" for the first sprite

; ==============================================================
;  Load Test Room Palettes
; ==============================================================
    @Palette:
    ; Write current BG palette to currentPalette struct
        ld hl, currentBGPal.color0
        ld de, TonbowFontPal
        ld b, $10
        call PalBufferWrite

    ; Write current SPR palette to currentPalette struct
        ld hl, currentSPRPal.color0
        ld de, TonbowFontPal
        ld b, $10
        call PalBufferWrite

    ; Write target BG palette to targetPalette struct
        ld hl, targetBGPal.color0
        ld de, TonbowFontPal
        ld b, $10
        call PalBufferWrite

    ; Write target SPR palette to targetPalette struct
        ld hl, targetSPRPal.color0
        ld de, TonbowFontPal
        ld b, $10
        call PalBufferWrite

    ; Actually update the palettes in VRAM
        call LoadBackgroundPalette
        call LoadSpritePalette

; ==============================================================
;  Load SFS Tiles
; ==============================================================
    @VideoRAM:
    ; Load TestRoom Studios Screen
        ld hl, $0000 | VRAM_WRITE
        rst SetVDPAddress
        ld hl, TestRoomTilesSMS
        ld bc, TestRoomTilesSMSEnd-TestRoomTilesSMS
        rst CopyToVDP

    ; Load Tonbow Font
        ld hl, FONT_VRAM_ADDRESS | VRAM_WRITE
        rst SetVDPAddress
        ld hl, TonbowFontTiles
        ld bc, TonbowFontTilesEnd-TonbowFontTiles
        rst CopyToVDP

        
    
/*     ; Load SteelFginer Studios Sprites
        ld hl, $2000 | VRAM_WRITE
        rst SetVDPAddress
        ld hl, TestRoomTilesSMS
        ld bc, TestRoomTilesSMSEnd-TestRoomTilesSMS
        call CopyToVDP  */
        
    ; Load Map
        ld hl, $3800 | VRAM_WRITE
        rst SetVDPAddress
        ld hl, TestRoomMapSMS
        ld bc, TestRoomMapSMSEnd-TestRoomMapSMS
        rst CopyToVDP

    ; Load Hello World Message
        ld hl, $3800 | VRAM_WRITE
        rst SetVDPAddress
        ld hl, HelloASCIIWorld
        ld bc, HelloASCIIWorldEnd-HelloASCIIWorld
        call WriteTextToBackground


; ==============================================================
;  Memory (Structures, Variables & Constants) 
; ==============================================================
    @Sprites:


; ==============================================================
;  Entities
; ==============================================================
    @Entities:
    ; Test Activate Entity (No Sprites)
        @NoSpriteEntity:
            @Activate:
                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0110
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0220
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0330
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0440
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0550
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0660
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, HI_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0770
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, HI_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0880
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, HI_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld bc, $0110
		        ld ix, $0990
                call TestRoomTonbowEntityClass@Initialize
                pop hl
                


/* 
    ; Test Deactivate Entity (No Sprites)
            @Deactivate:
            inc hl                                      ; HL -> entity.ACTIVE.updateRoutinePointerHi
            inc hl                                      ; HL -> entity.ACTIVE.state
            call EntityListClass@DeactivateEntity
            ld hl, entityList.entity.0.state
            call EntityListClass@DeactivateEntity
 */

; ==============================================================
;  Set up screen
; ==============================================================
    @UpdateGameState:
    ; Update Game State
        ld hl, MainLoopTest
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

MainLoopTest:
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
TestRoomMapSMS:
    .INCLUDE "../Assets/TestRoom/Backgrounds/testRoomMap.inc"
TestRoomMapSMSEnd:
; ----------------
;  BG Palettes
; ----------------
TestRoomBGPaletteSMS:
    .INCLUDE "../Assets/TestRoom/Backgrounds/testRoomPal.inc"
TestRoomBGPaletteSMSEnd:
; ----------------
;  BG Tiles
; ----------------
TestRoomTilesSMS:
    .INCLUDE "../Assets/TestRoom/Backgrounds/testRoomTiles.inc"
TestRoomTilesSMSEnd:

; ========================================================
;  Font Tiles
; ========================================================
; ----------------
;  BG Maps
; ----------------
TonbowFontTiles:
    .INCLUDE "../Assets/Fonts/tonbowFontTiles.inc"
TonbowFontTilesEnd:
; ----------------
;  BG Palettes
; ----------------
TonbowFontPal:
    .INCLUDE "../Assets/Fonts/tonbowFontPal.inc"
TonbowFontPalEnd:

; Test Message 
HelloASCIIWorld:
    .ASC "   WELCOME TO THE TEST ROOM!"
HelloASCIIWorldEnd:

FirstSpriteTextCC:
    .ASC "1"
FirstSpriteTextCCEnd:

;

; ========================================================
;  Sprites
; ========================================================
TestRoomSPRPalette:
    ; .include "../assets/test/TestRoom Studios SMS-1000SPRPal.inc"
TestRoomSPRPaletteEnd:

TestRoomShimmer:
    ; .include "../assets/test/sfsShimmer_tiles.inc"
TestRoomShimmerEnd:

.ENDS

; ========================================================
;  Entities
; ========================================================
.INCLUDE "../TestRoom/testRoomTonbow.asm"