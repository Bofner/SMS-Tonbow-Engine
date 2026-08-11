; ==============================================================
;  WLA-DX banking setup
; ==============================================================

; Memory Map
;      $FFFF -----------------------------------------------------------
;            Paging registers
;      $FFFC -----------------------------------------------------------
;            Mirror of RAM at $C000-$DFFF
;      $E000 -----------------------------------------------------------
;            8k of on-board RAM (mirrored at $E000-$FFFF)
;      $C000 -----------------------------------------------------------
;            16k ROM Page 2, or one of two pages of Cartridge RAM
;      $8000 -----------------------------------------------------------
;            16k ROM Page 1
;      $4000 -----------------------------------------------------------
;            15k ROM Page 0
;      $0400 -----------------------------------------------------------
;            First 1k of ROM Bank 0, never paged out with rest of Page 0
;      $0000 -----------------------------------------------------------

; For Projects bigger than 32k
/* .MEMORYMAP	
    SLOTSIZE $7FF0	
    SLOT 0 $0000	
    SLOTSIZE $10	
    SLOT 1 $7FF0	
    SLOTSIZE $4000	
    SLOT 2 $8000	
    DEFAULTSLOT 2	
.ENDME	 
.ROMBANKMAP	
    BANKSTOTAL 4	
    BANKSIZE $7FF0	
    BANKS 1	
    BANKSIZE $10	
    BANKS 1	
    BANKSIZE $4000	
    BANKS 2	
.ENDRO	 */

; For 32k Projects
 .MEMORYMAP	
    SLOTSIZE    $4000	
    SLOT 0      $0000   "FIXED_BANK_0"	                
    SLOT 1      $4000   "FIXED_BANK_1"	
    SLOT 2      $8000   "SWAPABLE_BANK"     ; $4000 of swapable ROM
    SLOT 3      $C000   "RAM_SLOT"			; RAM starts here
	SLOT 4      $E000   "ECHO_RAM_SLOT"		; Echo RAM starts here
    DEFAULTSLOT 2	
.ENDME	 
.ROMBANKMAP	
    BANKSTOTAL  2	
    BANKSIZE    $4000	
    BANKS       2	
.ENDRO	


; ==============================================================
;  SMS defines
; ==============================================================

; Hardware constants
.DEFINE     PORT_VDP_ADDRESS        $BF 
.DEFINE     VDP_DATA                $BE
.DEFINE     VRAM_WRITE              $4000
.DEFINE     VRAM_READ               $0000
.DEFINE     CRAM_WRITE              $C000

; System variants
.DEFINE     SG_HARDWARE             $01
.DEFINE     SC_HARDWARE             $03
.DEFINE     SMS_HARDWARE            $08

; Graphics constants
.DEFINE     PALETTE_SIZE            $10
.DEFINE     FONT_VRAM_ADDRESS       $1AA0
.DEFINE     PUNC_VRAM_CHAR_ADDRESS  $D5
.DEFINE     NUM_VRAM_CHAR_ADDRESS   PUNC_VRAM_CHAR_ADDRESS + 6
.DEFINE     FONT_VRAM_CHAR_ADDRESS  $E6
.ASCIITABLE
    map " " to "!"  = PUNC_VRAM_CHAR_ADDRESS
    map "?"         = PUNC_VRAM_CHAR_ADDRESS + 2
    map "," to "."  = PUNC_VRAM_CHAR_ADDRESS + 3
    map "0" to ":"  = NUM_VRAM_CHAR_ADDRESS
    map "A" to "Z"  = FONT_VRAM_CHAR_ADDRESS  
.ENDA

; Screen constants
.DEFINE     UP_BOUNDS               $02
.DEFINE     DOWN_BOUNDS             $BD
.DEFINE     LEFT_BOUNDS             $05
.DEFINE     RIGHT_BOUNDS            $FD


; ==============================================================
;  SDSC tag and ROM header
; ==============================================================

.SDSCTAG 0.1, "Template", "Hope this helps ya","Steelfinger Studios"

.BANK 0 SLOT 0
.ORG $0000
; ==============================================================
;  Boot Section
; ==============================================================

    di                          ; Disable interrupts
    im 1                        ; Interrupt mode 1
    jp MainInit            ; Jump to the initialization program

; ==============================================================
;  Interrupt Handlers Section
; ==============================================================

; Interrupts
.BANK 0 SLOT 0
.ORG $0038
	jp InterruptHandler

; NMI (Pause)
.BANK 0 SLOT 0
.ORG $0066
    jp PauseHandler

.INCLUDE "../FixedBank/interruptHandlers.asm"

; ==============================================================
;  Include our STRUCTS so we can create them in MAIN
; ==============================================================
.INCLUDE "structs.asm"

; ==============================================================
;  Include Game Mechanic Files
; ==============================================================
.INCLUDE "../FixedBank/vdpHandlers.asm"
.INCLUDE "../FixedBank/bankSwitchAndGameState.asm"

; ==============================================================
;  Include Entities and Handlers
; ==============================================================
.INCLUDE "../EntityHandler/EntityVariants/BaseEntity/baseEntityClass.asm"
.INCLUDE "../EntityHandler/EntityListClass/entityListClass.asm"

; ==============================================================
;  Include Sprite Handler
; ==============================================================
.INCLUDE "../SpriteHandler/spriteHandlerClass.asm"

; ==============================================================
;  Include Controller Input Handler
; ==============================================================
.INCLUDE "../ControllerInputHandler/pollForInputs.asm"

; ==============================================================
;  Boiler Variables 
; ============================================================== 
.RAMSECTION "Global Variables" BANK 0 SLOT "RAM_SLOT"
    systemHardware              db      ; Are we running SMS or an SG-1000 variant?

    VDPStatus                   db      ; Holds VDP Status from the interrupt
                                        ; Bit 7:     1 = VBlank
                                        ; Bit 6:     1 = >=9 sprites on raster
                                        ; Bit 5:     1 = Sprite collision
                                        ; Bit 4-0:   No function

; Background 
; Any special parallax screen scrolling will be declared within the level file
	nextHBlankStep  	        dw      ; Variable that tells where to go for next HBlank
	frameFinish			        db		; $00 = NO_FINISH, 
                                        ; $01 = WRITE_FINISH, 
                                        ; $11 = VBLANK_FINISH
	frameCount     		        db      ; Used to count frames in intervals of 60	
	targetBGPal                 instanceof paletteStruct		
                                        ; Target BG palette for a fade in
    currentBGPal		        instanceof paletteStruct		
                                        ; Current BG palette for a fade in
    targetSPRPal		        instanceof paletteStruct		
                                        ; Target SPR palette for a fade in
    currentSPRPal		        instanceof paletteStruct		
                                        ; Current SPR palette for a fade in

; Game State
    RAM_JumpToCorrectGameState  dsb $04 ; Address in RAM that is used to 
                                        ; call ${currentGameState}
                                        ; ret
    changeGameStateFlag         db      ; Do we need to change Game state?
    sceneComplete               db      ; Is the current scene finished?
	holdGameState				dw		; Game State Held for Fades or some other future reason
	holdGameStateBank			db		; Game State Bank Held for Fades or some other future reason
	nextGameState				dw		; The Game State we want to switch to
	nextGameStateBank			db		; The bank data for the next game state

; Hardware version
	modelType					db		; Are we running on DMG ($00), SGB ($01), or CGB ($02)
	
; 8-Bit Variables
	aux8BitVar        			db		; Used for any kind of 8-bit variable we need
	temp8BitA					db		; Temporary 8-bit Data Storage
	temp8BitB					db		; Temporary 8-bit Data Storage
	temp8BitC					db		; Temporary 8-bit Data Storage
	temp8BitD					db		; Temporary 8-bit Data Storage
	temp8BitE					db		; Temporary 8-bit Data Storage
	temp8BitF					db		; Temporary 8-bit Data Storage

; 16-Bit Variables
	aux16BitVar        			dw		; Used for any kind of 16-bit variable we need
	ptrA16Bit 					dw		; Used to point to a 16 bit address
	ptrB16Bit 					dw		; Used to point to a 16 bit address
	ptrC16Bit 					dw		; Used to point to a 16 bit address
	ptrD16Bit 					dw		; Used to point to a 16 bit address
	ptrE16Bit 					dw		; Used to point to a 16 bit address
	ptrF16Bit 					dw		; Used to point to a 16 bit address
    
.ENDS

; ==============================================================
;  Game Constants
; ==============================================================



; ==============================================================
;  Start up/Initialization
; ==============================================================

; Initialization parameters for the 11 registers on SMS
VDPInitDataSMS:
    .db %00010110       ; reg. 0
                        ; Vertical Scroll Inhibit
                        ; Horizontal Scroll Inhibit
                        ; Left Column Blank
                        ; Enable Interrupts
                        ; Sprite Shift
                        ; Always 1
                        ; Always 1 
                        ; External Sync (Always 0)
    .db %10100000       ; reg. 1
                        ; Always set to 1
                        ; Enable display
                        ; VBlank interrupts
                        ; 224 line mode
                        ; 240 line mode
                        ; Mega Drive mode 5 enable
                        ; 8x16 Sprites
                        ; Low Res, 16x16 Sprites 
    .db $FF             ; reg. 2, Name table at $3800
    .db $FF             ; reg. 3 Always set to $FF
    .db $FF             ; reg. 4 Always set to $FF
    .db $FF             ; reg. 5 Address for SAT, 
                        ; $FF = SAT at $3F00 
    .db $FB             ; reg. 6 Base address for sprite patterns
                        ; $FB -> First half of VRAM
                        ; $FF -> Second half of VRAM
    .db $F0             ; reg. 7 Overrscan Color at Sprite Palette 1  
    .db $00             ; reg. 8 Horizontal Scroll
    .db $00             ; reg. 9 Vertical Scroll
    .db $FF             ; reg. 10 Raster line interrupt off 
VDPInitDataSMSEnd:

.SECTION "Outer Framework"
MainInit: 
    ld sp, $DFF0


; ==============================================================
;  Set up VDP Registers
; ==============================================================
    @Registers::
        ld hl,VDPInitDataSMS                        ;  Point to register init data.
        ld b,VDPInitDataSMSEnd - VDPInitDataSMS     ;  8 bytes of register data.
        ld c, $80                                   ;  VDP register command byte.                      
        call SetVDPRegisters
    


; ==============================================================
;  Clear VRAM
; ==============================================================
    @ClearVRAM:
    ; Set VRAM to all be $00
        call ClearVRAM

; ==============================================================
;  Setup general sprite variables
; ==============================================================
    @Variables:
    ; Start frameCount at zero
        xor a
        ld hl, frameCount
        ld (hl), a

; ==============================================================
;  Setup Entity List
; ==============================================================
    @InitializeEntityList:
    ; Initialize the Entity List
        call EntityListClass@InitializeEntityList

; ==============================================================
;  Setup Sprite Handler
; ==============================================================
    InitializeSpriteHander:
    ; Initialize the Entity List
        call SpriteHandlerClass@InitializeSpriteHandler

; ==============================================================
;  Setup Game State
; ==============================================================
    @GameState:
        call GameStateRoutineToRAM

; ==============================================================
;  Game sequence
; ==============================================================
    @Interrupts:
        ei

MainLoop:
    halt

    ; Run important VDP and graphics updates first
    call SpriteHandlerClass@UpdateSAT

    ; Poll for controller inputs
    call ControllerInputHandlerClass@PollForInputs

    call RAM_JumpToCorrectGameState

    ; Update the Entity List
    call EntityListClass@UpdateAllEntities

    jr MainLoop


/* MainGameLoop:
; Main Loop Outline
	; We want a big main loop to control the following:
	; The graphics (BG, Window and Sprites) to be updated in a predictable way
	; HBlank/Raster control (Though done in it's own ASM file)
	; Fade in and fade out the screen
	; Check for input on P1 (and maybe P2?)
	; Update Scrolling

; Fade in and out
	; Will be called for from the current state, and current state must be saved
	; We will skip doing anything with the current state and won't updated OBJs or BG Scrolling
	; Will simply fade to black (index 0b11) or fade in from black
	; On finish, it will restore the game state
	; It will be a fixed bank routine

	@WaitVBlank:
		halt
		ld a, (rLY)
		cp 144
		jr c, @WaitVBlank

; Update OAM
@UpdateOAM:
	ld a, hibyte(OAMBuffer)
	call HRAM_RunDMATransfer
@UpdateOAMEnd:

; Update Game State
@UpdateGameState:
; Check if we need to update the game state
	ld a, ($FF00 + lobyte(changeGameStateFlag))
	cp CHANGE_GAME_STATE_FLAG
	jr nz, @UpdateGameStateFinish
		call HRAM_UpdateGameState
@UpdateGameStateFinish:

; Update the current keys being pressed
	call UpdateKeys

; Update all currently active entities
	call EntityListClass@UpdateAllEntities


; Jump to logic to handle the current Game State
	call HRAM_JumpToCorrectGameState

; Update our Random number
	call LFSRClass@RunOnce

; Restart
	jr MainGameLoop

-:
	nop
	nop
	nop
	jr -
MainGameLoopEnd:

; If we somehow end up here, just reset the Software
	jp SpaceTonbowInit */



.ENDS

; ==============================================================
;  Include Level Files
; ==============================================================
.INCLUDE "../SteelfingerStudios/sfs.asm"
.INCLUDE "../TestRoom/testRoom.asm"





