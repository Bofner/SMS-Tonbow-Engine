; ================================================================================
;  All subroutines and data related to the 何でも Class
; ================================================================================
; Change the following throughout the entire class
;  何でも: 		 Captial letter of the entity (Entity)
;  CONST_TEMP:	Constant values (ENTITY)
;  temp: 		Lower case letter of the entity (entity)

; ==============================================================
;  ClassExampleTemplate Skeleton
; ==============================================================
.STRUCT tempStructure
    INSTANCEOF entitySkeleton               ; All the base parts of an entity
    frameAddressLo                  DB      ; \
    frameAddressHi                  DB      ; / Address of the frame to be rendered
    frameTimer                      DB      ; Time until we move to the next frame
    frameAddressOffset              DB      ; Finding the new address in the animation table(s)

	
.ENDST

; .BANK 0 SLOT 0
.SECTION "何でも Entity Class"
何でもEntityClass:
; ==============================================================
;  Constants
; ==============================================================
; Init Values

	.DEF	CONST_TEMP_SPEED						$10				; $LSB,FRAC
	.DEF	CONST_TEMP_TIMER_INIT_VALUE				$00

; VRAM Absolute Data
	.DEF 	CONST_TEMP_VRAM							$8000

; Attack Hitbox
	.DEF	CONST_TEMP_ATK_HITBOX_WIDTH				$08		
	.DEF	CONST_TEMP_ATK_HITBOX_HEIGHT			$10	
	.DEF	CONST_TEMP_ATK_HITBOX_VERT_OFFSET		$00


; ==============================================================
;  Updates the 何でも
; ==============================================================
; Parameters: DE = temp.state (Should be coming from EntityList@UpdateEntities)
; Returns: None
; Affects: TBD
	@Update:
    ; Update Position
		ld de, tempStructure.yVel - tempStructure.state
		add hl, de									; HL -> tempStructure.yVel
		call BaseEntityClass@UpdateEntityPosition	; HL -> tempStructure.frameTimer

    ; Update Sprite appearance
        call @Build何でもMetasprite

    ret


; ================================================================================
;  Initialize 何でも
; ================================================================================
; Parameters: 	HL = temp.updateRoutinePointerLo 
;				BC = yPos
; 				IX = xPos
; Affects: A, HL, DE
	@Initialize:
	; Basic Entity Initialization
		; HL ->  temp.updateRoutinePointerLo
		ld de, @Update
		ld a, $FF									; A = Entity Type
		call BaseEntityClass@Initialize				; HL -> temp.frameAddressLo
        ld a, LOBYTE(@Build何でもMetasprite@Flapping@Frame0)
        ld (hl), a
        inc hl                                      ; HL -> temp.frameAddressHi
        ld a, HIBYTE(@Build何でもMetasprite@Flapping@Frame0)
        ld (hl), a                                  ; temp.frameAddress -> tempClass@BuildtempMetasprite@Flapping@Frame0
        inc hl                                      ; HL -> temp.frameTimer
        xor a
        ld (hl), a
        inc hl                                      ; HL -> temp.frameAddressOffset
        ld (hl), a

		ret


; ==============================================================
;  Updates 何でも sprite and writes to SATBuffer
; ==============================================================
    .INCLUDE "../CommonEntities/何でも/build何でもMetasprite.asm"


; ================================================================================
;  何でも Tile Data
; ================================================================================

; Separated by animation cycles
    @Tiles:
    ; ===============================================
    ;   何でも
    ; ===============================================
        @@何でも:
        ; ----------------
        ; Raw Data
        ; ----------------
        ; Raw Data to be loaded into VRAM
            @@@RawData:
                @@@@RawDataFrame0:
                    .INCLUDE "../Assets/TestRoom/Sprites/何でも/temp0Tiles.inc"
                @@@@RawDataFrame1:
                    .INCLUDE "../Assets/TestRoom/Sprites/何でも/temp1Tiles.inc"
            @@@RawDataEnd:

.ENDS