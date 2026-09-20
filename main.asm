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
; ROM Slots
    SLOTSIZE $7FF0	    
    SLOT 0 $0000	    "FIXED_BANK_0"	
    SLOTSIZE $10	    
    SLOT 1 $7FF0	    "FIXED_BANK_1"
    SLOTSIZE $4000	
    SLOT 2      $8000   "SWAPABLE_BANK"     ; $4000 of swapable ROM
; RAM Slots
    SLOTSIZE    $2000	
    SLOT 3      $C000   "RAM_SLOT"			; RAM starts here
	SLOT 4      $E000   "ECHO_RAM_SLOT"		; Echo RAM starts here
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
; ROM Slots
    SLOTSIZE    $4000	
    SLOT 0      $0000   "FIXED_BANK_0"	    ; $4000 of fixed ROM       
    SLOT 1      $4000   "FIXED_BANK_1"	    ; $4000 of fixed ROM   
    SLOT 2      $8000   "SWAPABLE_BANK"     ; $4000 of swapable ROM
; RAM Slots
    SLOTSIZE    $2000	
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
;  Global Constants
; ==============================================================
; System variants
    .DEFINE     SG_HARDWARE             $01
    .DEFINE     SC_HARDWARE             $03
    .DEFINE     SMS_HARDWARE            $08

; System constrol
    .DEFINE     NEXT_FRAME_NOT_READY    $00
    .DEFINE     NEXT_FRAME_READY        $11

; Screen constants
    .DEFINE     UP_BOUNDS               $02
    .DEFINE     DOWN_BOUNDS             $BD
    .DEFINE     LEFT_BOUNDS             $05
    .DEFINE     RIGHT_BOUNDS            $FD


; ================================================================================
;  Global Variables 
; ================================================================================ 
.RAMSECTION "Global Variables" BANK 0 SLOT "RAM_SLOT"
; Hardware
    systemHardware              DB      ; Are we running SMS or an SG-1000 variant?

; Game State
    RAM_JumpToCorrectGameState  DSB $04 ; Address in RAM that is used to 
                                        ; call ${currentGameState}
                                        ; ret
    changeGameStateFlag         DB      ; Do we need to change Game state?
	holdGameState				DW		; Game State Held for Fades or some other future reason
	holdGameStateBank			DB		; Game State Bank Held for Fades or some other future reason
	nextGameState				DW		; The Game State we want to switch to
	nextGameStateBank			DB		; The bank data for the next game state

; Universal variables
    universalTimer              DB      ; A universal timer to synchronize events
    sceneComplete               DB      ; Is the current scene finished?
    frameFinish			        DB      ; $00 = NO_FINISH, 
                                        ; $01 = WRITE_FINISH, 
                                        ; $11 = VBLANK_FINISH

; 8-Bit Variables
	temp8Bit					DB		; Temporary 8-bit data storage

; 16-Bit Variables
	temp16Bit 					DW		; Temporary 16-bit data storage or used to point to a 16 bit address

.ENDS


; ================================================================================
;  SDSC tag and ROM header
; ================================================================================

.SDSCTAG 0.1, "Template", "Hope this helps ya","Steelfinger Studios"

.BANK 0 SLOT 0
.ORG $0000
; ================================================================================
;  Boot Section
; ================================================================================

    di                          ; Disable interrupts
    im 1                        ; Interrupt mode 1
    jp MainInit                 ; Jump to the initialization program

.BANK 0 SLOT 0
.ORG $0008
; SetVDPAddress

.BANK 0 SLOT 0
.ORG $0010
; CopyToVRAM

.BANK 0 SLOT 0
.ORG $0018
; Last bytes of CopyToVRAM

.BANK 0 SLOT 0
.ORG $0020
; FastCopyToVRAM

.BANK 0 SLOT 0
.ORG $0028
; HandleBankSwitch

.BANK 0 SLOT 0
.ORG $0030
; FREE (Probably H-Scroll?)

; ================================================================================
;  Interrupt Handlers Section
; ================================================================================

; Interrupts
.BANK 0 SLOT 0
.ORG $0038
	jp InterruptHandler

; NMI (Pause)
.BANK 0 SLOT 0
.ORG $0066
    jp PauseHandler


; ================================================================================
;  Include Interrupt Handler
; ================================================================================
.INCLUDE "InterruptHandler/maskableEntry.asm"
.INCLUDE "InterruptHandler/nonmaskableEntry.asm"

; ================================================================================
;  Include VDP Handler
; ================================================================================
.INCLUDE "VDPHandler/updateCRAM.asm"
.INCLUDE "VDPHandler/updateRegisters.asm"
.INCLUDE "VDPHandler/updateVRAM.asm"

; ================================================================================
;  Include Sprite Handler
; ================================================================================
.INCLUDE "SpriteHandler/spriteHandlerClass.asm"

; ================================================================================
;  Include Controller Input Handler
; ================================================================================
.INCLUDE "ControllerInputHandler/pollForInputs.asm"

; ================================================================================
;  Include Bank Switch Handler
; ================================================================================
.INCLUDE "BankSwitchHandler/handleBankSwitch.asm"

; ================================================================================
;  Include Game State Handler
; ================================================================================
.INCLUDE "GameStateHandler/updateGameState.asm"

; ================================================================================
;  Include Entities and Handlers
; ================================================================================
.INCLUDE "EntityHandler/EntityVariants/BaseEntity/baseEntityClass.asm"
.INCLUDE "EntityHandler/EntityListClass/entityListClass.asm"

; ================================================================================
;  Include RNG
; ================================================================================
.INCLUDE "RandomNumberHandler/linearFeedbackShiftRegister.asm"


; ================================================================================
;  Start up/Initialization
; ================================================================================
.SECTION "Outer Framework"
MainInit: 
    ld sp, $DFF0

; ================================================================================
;  Set up VDP Registers
; ================================================================================
    @Registers::
        ld hl,VDPInitDataSMS                        ;  Point to register init data.
        ld b,VDPInitDataSMSEnd - VDPInitDataSMS     ;  8 bytes of register data.
        ld c, REGISTER_0                            ;  VDP register command byte.                      
        call SetVDPRegisters
    
; ================================================================================
;  Clear VRAM
; ================================================================================
    @ClearVRAM:
    ; Set VRAM to all be $00
        call ClearVRAM

; ================================================================================
;  Setup universal variables
; ================================================================================
    @Variables:
        xor a
        ld hl, universalTimer
        ld (hl), a
        inc hl                  ; HL -> sceneComplete
        ld (hl), a
        inc hl                  ; HL -> frameFinish
        ld a, NEXT_FRAME_READY
        ld (hl), a
        inc hl                  ; HL -> currentBank
        ld (hl), $00   

; ================================================================================
;  Setup RNG
; ================================================================================
    @LFSR:
        ld a, LFSR_DEFAULT_SEED
        ld b, LFSR_DEFAULT_TAPS
        call LFSRClass@Initialize

; ================================================================================
;  Setup Entity List
; ================================================================================
    @InitializeEntityList:
    ; Initialize the Entity List
        call EntityListClass@InitializeEntityList

; ================================================================================
;  Setup Sprite Handler
; ================================================================================
    InitializeSpriteHander:
    ; Initialize the Entity List
        call SpriteHandlerClass@InitializeSpriteHandler

; ================================================================================
;  Setup Game State
; ================================================================================
    @GameState:
        call GameStateRoutineToRAM

; ================================================================================
;  Game sequence
; ================================================================================
    @Interrupts:
        ei


; The main game loop. Completes all logic needed for any given part of the game
MainLoop:
    halt
; Check if the next frame is ready to be drawn
    @CheckSlowdown:
        ld hl, frameFinish
        ld a, (hl)
        cp NEXT_FRAME_READY
        jr nz, MainLoop                 ; If no, then don't update VDP or game logic
    
; The actual logic needed for the game to function as intended
    @MainGameLogic:
        ld (hl), NEXT_FRAME_NOT_READY   ; We are not ready to draw the next frame yet

    ; Run important VDP and graphics updates first
        call SpriteHandlerClass@UpdateSAT

    ; Poll for controller inputs
        call ControllerInputHandlerClass@PollForInputs

        call RAM_JumpToCorrectGameState

    ; Update the Entity List
        call EntityListClass@UpdateAllEntities

    ; Update our Random number
	    call LFSRClass@RunOnce

    ; Update frameFinish so we can draw the next frame after VBlank
        ld a, NEXT_FRAME_READY
        ld (frameFinish), a

    jr MainLoop

.ENDS


; ================================================================================
;  Include Level Files
; ================================================================================
.INCLUDE "SteelfingerStudios/sfs.asm"
.INCLUDE "TestRoom/testRoom.asm"





