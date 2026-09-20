.SECTION "Sprite Handler Structures"
; ================================================================================
;  Constants for the Sprite Handler
; ================================================================================
    .DEF    SPRITE_MAX          $40
    .DEF    SAT_TERMINATOR_BYTE $D0
    .DEF    SPRITE_HANDLER_SIZE $C1
    .DEF    SAT_VRAM            $3F00
    .DEF    VPOS_VRAM           SAT_VRAM
    .DEF    HPOS_CC_VRAM        VPOS_VRAM + (2 * SPRITE_MAX)

; ================================================================================
;  Structures for the Sprite Handler
; ================================================================================
; byte used for easy indexing of SAT Buffer addresses
    .STRUCT bufferByteStructure
        bufferByte                                      DB
    .ENDST
; All necessary components for the Sprite Handler
    .STRUCT spriteHandlerStructure
        spriteCount     				                DB                      ; How many sprites are on screen on current frame (Reset at the beginning of each frame)
        vBuffer.0                     	                DB                      ; Holds the yPos for all sprites
        vBuffer     INSTANCEOF bufferByteStructure      (SPRITE_MAX - 1)
        hcBuffer.0                                      DB                      ; Holds the xPos and CC for all sprites
        hcBuffer    INSTANCEOF bufferByteStructure      ((2* SPRITE_MAX) - 1) 
    .ENDST
.ENDS

.RAMSECTION "Sprite Handler Data" BANK 0 SLOT "RAM_SLOT" 
; Sprite Handler related data and structures
    spriteHandler instanceof spriteHandlerStructure
.ENDS


.SECTION "Sprite Handler Class"
; ==============================================================
;  A Handler to manage sprites in the SAT and its Buffer
; ==============================================================
; Sprite Handler
SpriteHandlerClass:
; ==============================================================
;  Initialize the Sprite Handler
; ==============================================================
.INCLUDE "SpriteHandler/initSpriteHandler.asm"

; ==============================================================
;  Add a sprite to the SAT Buffer
; ==============================================================
.INCLUDE "SpriteHandler/updateSATBuffer.asm"

; ==============================================================
;  Clear the SAT Buffer
; ==============================================================
.INCLUDE "SpriteHandler/clearSATBuffer.asm"

; ==============================================================
;  Update the SAT in VRAM
; ==============================================================
.INCLUDE "SpriteHandler/updateSAT.asm"

SpriteHandlerClassEnd:

.ENDS