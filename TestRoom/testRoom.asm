; ================================================================================
;  Test Room Variables
; ================================================================================
.RAMSECTION "Cycle CC" BANK 0 SLOT "RAM_SLOT"
	tonbowCC			DB
.ENDS

; ================================================================================
;  Test Room 
; ================================================================================
; .BANK SFSBankSMS
; .ORG $0000
.SECTION "Test Room"
InitTestRoom:
    di
; ================================================================================
;  Scene beginning
; ================================================================================
    xor a
    ld hl, sceneComplete
    ld (hl), a
    inc hl                                  ; HL -> frameFinish
    ld (hl), a


; ================================================================================
;  Clear Video RAM
; ================================================================================
    @ClearData:
    ; Reset VRAM and SAT
        call ClearVRAM
        call SpriteHandlerClass@ClearSATBuff
    ; Reset background scroll values
        ; X-scroll
        xor a
        out (PORT_VDP_ADDRESS), a
        ld a, REGISTER_8
        out (PORT_VDP_ADDRESS), a		; Set BG X-Scroll to 0
        ; Y-scroll
        xor a
        out (PORT_VDP_ADDRESS), a
        ld a, REGISTER_9
        out (PORT_VDP_ADDRESS), a		; Set BG Y-Scroll to 0

; ================================================================================
;  Init Variables
; ================================================================================
    @InitVariables:
        ld a, (FirstSpriteTextCC)
        ld (tonbowCC), a                ; ASCII "1" for the first sprite

; ================================================================================
;  Load Test Room Palettes
; ================================================================================
    @Palette:
    ; Write current BG palette to currentPalette struct
        ld hl, currentBGPal.color0
        ld de, TonbowFontPal
        ld b, PALETTE_SIZE
        call PalBufferWrite

    ; Write current SPR palette to currentPalette struct
        ld hl, currentSPRPal.color0
        ld de, TonbowFontPal
        ld b, PALETTE_SIZE
        call PalBufferWrite

    ; Write target BG palette to targetPalette struct
        ld hl, targetBGPal.color0
        ld de, TonbowFontPal
        ld b, PALETTE_SIZE
        call PalBufferWrite

    ; Write target SPR palette to targetPalette struct
        ld hl, targetSPRPal.color0
        ld de, TonbowFontPal
        ld b, PALETTE_SIZE
        call PalBufferWrite

    ; Actually update the palettes in VRAM
        call LoadBackgroundPalette
        call LoadSpritePalette

; ================================================================================
;  Load SFS Tiles
; ================================================================================
    @VideoRAM:
    ; Load TestRoom Studios Screen
        ld hl, VRAM_START | VRAM_WRITE
        rst SetVDPAddress
        ld hl, TestRoomTilesSMS
        ld bc, TestRoomTilesSMSEnd-TestRoomTilesSMS
        rst CopyToVRAM

    ; Load Tonbow Font
        ld hl, FONT_VRAM_ADDRESS | VRAM_WRITE
        rst SetVDPAddress
        ld hl, TonbowFontTiles
        ld bc, TonbowFontTilesEnd-TonbowFontTiles
        rst CopyToVRAM

        
    
/*     ; Load SteelFginer Studios Sprites
        ld hl, $2000 | VRAM_WRITE
        rst SetVDPAddress
        ld hl, TestRoomTilesSMS
        ld bc, TestRoomTilesSMSEnd-TestRoomTilesSMS
        call CopyToVRAM  */
        
    ; Load Map
        ld hl, VRAM_MAP_START_3800 | VRAM_WRITE
        rst SetVDPAddress
        ld hl, TestRoomMapSMS
        ld bc, TestRoomMapSMSEnd-TestRoomMapSMS
        rst CopyToVRAM

    ; Load Hello World Message
        ld hl, VRAM_MAP_START_3800 | VRAM_WRITE
        rst SetVDPAddress
        ld hl, HelloASCIIWorld
        ld bc, HelloASCIIWorldEnd-HelloASCIIWorld
        call WriteTextToBackground


; ================================================================================
;  Memory (Structures, Variables & Constants) 
; ================================================================================
    @Sprites:


; ================================================================================
;  Entities
; ================================================================================
    @Entities:
    ; Test Activate Entity (No Sprites)
        @NoSpriteEntity:
            @Activate:
                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0110
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0220
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0330
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0440
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0550
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, LO_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0660
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, HI_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0770
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, HI_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0880
                call TestRoomTonbowEntityClass@Initialize
                pop hl

                ld ixl, NOT_PLAYER_ENTITY
                ld a, HI_ENTITY
                call EntityListClass@ActivateEntity     ; HL -> entity.ACTIVE.updateRoutinePointerLo
                push hl
                ld iy, $0110
		        ld ix, $0990
                call TestRoomTonbowEntityClass@Initialize
                pop hl
                

; ================================================================================
;  Set up screen
; ================================================================================
    @UpdateGameState:
    ; Update Game State
        ld hl, MainLoopTest
        call UpdateGameState
    ; Turn on screen 
        ld a, %11100000 ; Register 1
                        ; b7: ????
                        ; b6: Enable display
                        ; b5: VBlank interrupts
                        ; b4: 224 line mode
                        ; b3: 240 line mode
                        ; b2: Mega Drive mode 5 enable
                        ; b1: 8x16 Sprites
                        ; b0: Low Res, 16x16 Sprites 
        ld c, REGISTER_1
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
    .INCLUDE "Assets/TestRoom/Backgrounds/testRoomMap.inc"
TestRoomMapSMSEnd:
; ----------------
;  BG Palettes
; ----------------
TestRoomBGPaletteSMS:
    .INCLUDE "Assets/TestRoom/Backgrounds/testRoomPal.inc"
TestRoomBGPaletteSMSEnd:
; ----------------
;  BG Tiles
; ----------------
TestRoomTilesSMS:
    .INCLUDE "Assets/TestRoom/Backgrounds/testRoomTiles.inc"
TestRoomTilesSMSEnd:


; ========================================================
;  Font Tiles
; ========================================================
; ----------------
;  BG Maps
; ----------------
TonbowFontTiles:
    .INCLUDE "Assets/Fonts/tonbowFontTiles.inc"
TonbowFontTilesEnd:
; ----------------
;  BG Palettes
; ----------------
TonbowFontPal:
    .INCLUDE "Assets/Fonts/tonbowFontPal.inc"
TonbowFontPalEnd:

; Test Message 
HelloASCIIWorld:
    .ASC "   WELCOME TO THE TEST ROOM!"
HelloASCIIWorldEnd:

FirstSpriteTextCC:
    .ASC "1"
FirstSpriteTextCCEnd:


; ========================================================
;  Sprites
; ========================================================
TestRoomSPRPalette:
    ; .include "assets/test/TestRoom Studios SMS-1000SPRPal.inc"
TestRoomSPRPaletteEnd:

TestRoomShimmer:
    ; .include "assets/test/sfsShimmer_tiles.inc"
TestRoomShimmerEnd:

.ENDS

; ========================================================
;  Level Specific Entities (Have their own .SECTION)
; ========================================================
.INCLUDE "TestRoom/testRoomTonbow.asm"