; .BANK 0 SLOT 0
; ================================================================================
;  Test Room Tonbow's Structure
; ================================================================================
.STRUCT testRoomTonbowStruct SIZE $40
	instanceof entitySkeleton
	cc							db			; The character code for the tile
.ENDST


.SECTION "TestRoomTonbow Entity Class"
TestRoomTonbowEntityClass:
; ================================================================================
;  All subroutines and data related to the TestRoomTonbow Class
; ================================================================================
; Change the following throughout the entire class
; TestRoomTonbow: 		 	Captial letter of the entity (EntityExample)
; TEST_ROOM_TONBOW:		Constant values (ENTITY_EXAMPLE)
; testRoomTonbow: 			Lower case letter of the entity (entityExample)


; ==============================================================
;  Constants
; ==============================================================
; Init Values
	.DEFINE	 	TEST_ROOM_TONBOW_START_Y						$0600 		; 96 = $60.0 
	.DEFINE		TEST_ROOM_TONBOW_START_X	 					$0280 		; 40 = $28.0 
	.DEFINE		TEST_ROOM_TONBOW_SPEED							$10			; $LSB,FRAC
	.DEFINE		TEST_ROOM_TONBOW_TIMER_INIT_VALUE				$00
	.DEFINE		TEST_ROOM_TONBOW_CC								$04
	.DEFINE		TEST_ROOM_CLASS_BANK							$00

; VRAM Absolute Data
	.DEFINE	 	TEST_ROOM_TONBOW_VRAM							$0000


; ==============================================================
;  Updates the TestRoomTonbow
; ==============================================================
; Parameters: HL = testRoomTonbow.currentState (Should be coming from EntityList@UpdateEntities)
; Returns: None
; Affects: DE
	@Update:
	; Choose what to do based off state
		ld a, DEACTIVATE_ENTITY
		cp (hl)
		jr z, @Deactivate
		
	; Update Position
		ld de, testRoomTonbowStruct.yVel - testRoomTonbowStruct.state
		add hl, de									; HL -> testRoomTonbowStruct.yVel

		call BaseEntityClass@UpdateEntityPosition	; HL -> testRoomTonbowStruct.cc

	; Update in SAT Buffer
		ld de, testRoomTonbowStruct.yPos - testRoomTonbowStruct.cc
		add hl, de									; HL -> testRoomTonbow.yPos
	; yPos
		ld a, (hl)
		ld iyl, a									; IYL = yPos
		ld de, testRoomTonbowStruct.xPos - testRoomTonbowStruct.yPos
		add hl, de									; HL -> testRoomTonbow.xPos
	; xPos
		ld a, (hl)
		ld ixl, a									; IXL = xPos
	; cc
		inc hl 										; HL -> testRoomTonbow.cc
		ld c, (hl)									; C = testRoomTonbow.cc
	; Update the SAT Buffer
		push hl
			call SpriteHandlerClass@UpdateSATBufferSingleEntry
		pop hl								; Preserve entity address pointer


	
		ret

	@Deactivate:
		call EntityListClass@DeactivateEntity
		ret

; ==============================================================
;  Adjust what frame of animation TestRoomTonbow is on
; ==============================================================
	@AdjustFrame:

	ret


; ==============================================================
;  Update TestRoomTonbow animation based off current state
; ==============================================================
	@UpdateEntityAnimation:

	ret

; ==============================================================
;  Update TestRoomTonbow Position and Hitbox positions
; ==============================================================
	@UpdatePositions:
		
		ret


; ==============================================================
;  Initializes the TestRoomTonbow
; ==============================================================
; 
; Parameters: 	HL = testRoomTonbow.updateRoutinePointerLo 
;				IY = yPos
; 				IX = xPos
; Affects: A, HL, DE
	@Initialize:
	; Basic Entity Initialization
		; HL ->  testRoomTonbow.updateRoutinePointerLo
		ld de, TestRoomTonbowEntityClass@Update
		ld a, $FF									; A = Entity Type
		ld b, TEST_ROOM_CLASS_BANK					; B = Class Bank
		call BaseEntityClass@Initialize				; HL -> testRoomTonbow.cc
		ld de, tonbowCC
		ld a, (de)
		ld (hl), a									; Updated testRoomTonbow.cc
		inc a
		ld (de), a

		ret


@Tiles:
; Just the one set
	@@First:
		; .INCLUDE "..\\assets\\FixedBankEntities\\testRoomTonbow\\testRoomTonbowFirstTiles.inc"
	@@FirstEnd:
	@@Second:
		; .INCLUDE "..\\assets\\FixedBankEntities\\testRoomTonbow\\testRoomTonbowSecondTiles.inc"
	@@SecondEnd:

.ENDS