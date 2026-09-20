; .BANK 0 SLOT 0
; ================================================================================
;  Test Room Tonbow's Structure
; ================================================================================
.STRUCT playerTemplateEntityStruct SIZE $40
	instanceof entitySkeleton
	cc							db			; The character code for the tile
    flickerState                db          ; Keeps track of if flicker is ON or OFF
.ENDST


.SECTION "Player Template Entity Class"
PlayerTemplateEntity:
; ================================================================================
;  All subroutines and data related to the PlayerTemplateEntity Class
; ================================================================================
; Change the following throughout the entire class
; PlayerTemplateEntity: 		Captial letter of the entity (EntityExample)
; PLAYER_TEMPLATE_ENTITY:				Constant values (ENTITY_EXAMPLE)
; playerTemplateEntity: 		Lower case letter of the entity (entityExample)


; ==============================================================
;  Constants
; ==============================================================
; Init Values
	.DEFINE	 	PLAYER_TEMPLATE_ENTITY_START_Y				$0600 		; 96 = $60.0 
	.DEFINE		PLAYER_TEMPLATE_ENTITY_START_X	 			$0280 		; 40 = $28.0 
	.DEFINE		PLAYER_TEMPLATE_ENTITY_SPEED				$10			; $LSB,FRAC
	.DEFINE		PLAYER_TEMPLATE_ENTITY_TIMER_INIT_VALUE		$00
	.DEFINE		PLAYER_TEMPLATE_ENTITY_CC					$04

; Toggle
    .DEFINE	    FLICKER_TOGGLE                              LO_ENTITY   ; ($FF)
	.DEFINE		TOGGLE_TIMER								$1E

; MASKS
	.DEFINE		DPAD_MASK									%00001111

; VRAM Absolute Data
	.DEFINE	 	PLAYER_TEMPLATE_ENTITY_VRAM					$0000

; Player values
	.DEFINE		PLAYER_TEMPLATE_UD_VELOCITY					$08
	.DEFINE		PLAYER_TEMPLATE_LR_VELOCITY					$08
	.DEFINE		PLAYER_TEMPLATE_DIAG_UNNORMALIZED_VELOCITY	SQRT(((PLAYER_TEMPLATE_UD_VELOCITY ^2) + (PLAYER_TEMPLATE_LR_VELOCITY ^2)))
	.DEFINE		PLAYER_TEMPLATE_DIAG_UD_COMPONENT_VELOCITY	ROUND((PLAYER_TEMPLATE_UD_VELOCITY ^2) / PLAYER_TEMPLATE_DIAG_UNNORMALIZED_VELOCITY)
	.DEFINE		PLAYER_TEMPLATE_DIAG_LR_COMPONENT_VELOCITY	ROUND((PLAYER_TEMPLATE_LR_VELOCITY ^2) / PLAYER_TEMPLATE_DIAG_UNNORMALIZED_VELOCITY)


; ==============================================================
;  Updates the PlayerTemplateEntity
; ==============================================================
; 
; 
; Parameters: HL = PlayerTemplateEntity.state (Should be coming from EntityList@UpdateEntities)
; Returns: None
; Affects: DE
	@Update:
	; Choose what to do based off state

    ; Check controls
    call @CheckControllerInputs

	; Update Position
		ld de, playerTemplateEntityStruct.yVel - playerTemplateEntityStruct.state
		add hl, de									; HL -> PlayerTemplateEntityStruct.yVel
		push hl
			call BaseEntityClass@UpdateEntityPosition	; HL -> playerTemplateEntityStruct.cc
		pop hl										; HL -> PlayerTemplateEntityStruct.yVel
		; Reset velocity to 0
		xor a
		ld (hl), a									; entity.yVel = 0
		ld de, playerTemplateEntityStruct.xVel - playerTemplateEntityStruct.yVel
		add hl, de									; HL -> PlayerTemplateEntity.xVel
		ld (hl), a

	; Update in SAT Buffer
		ld de, playerTemplateEntityStruct.yPos - playerTemplateEntityStruct.xVel
		add hl, de									; HL -> PlayerTemplateEntity.yPos
	; yPos
		ld a, (hl)
		ld iyl, a									; IYL = yPos
		ld de, playerTemplateEntityStruct.xPos - playerTemplateEntityStruct.yPos
		add hl, de									; HL -> PlayerTemplateEntity.xPos
	; xPos
		ld a, (hl)
		ld ixl, a									; IXL = xPos
	; cc
		inc hl 										; HL -> PlayerTemplateEntity.cc
		ld c, (hl)									; C = PlayerTemplateEntity.cc
	; Update the SAT Buffer
		push hl
			call SpriteHandlerClass@UpdateSATBufferSingleEntry
		pop hl								; Preserve entity address pointer


	
		ret

; ==============================================================
;  Adjust what frame of animation PlayerTemplateEntity is on
; ==============================================================
	@CheckControllerInputs:
	; Check DPad input
		ld a, (controllerInputHandler.playerOneInput)  ;Recall Joypad 1 input data
		and DPAD_MASK                   ;Make a mask to only look at the D-Pad
	; 3 * N + DPadJumpTable
		ld c, a
		add a, c
		add a, c                        ; 3 * N 
		ld ixh, 0
		ld ixl, a
		ld bc, @@DPadJumpTable
		add ix, bc                      ; 3 * N + DPadJumpTable
		jp ix                           ; Jump to specific input subroutine

		@@ReturnFromDPadCheck:
			; HL -> entity.state
		; Adjust our timer
			ld de, entityList.entity.8.timer
			ld a, (de)
			cp $00
			jr z, +						; If timer > 0, dec
			dec a
			ld (de), a
			ret
	+:
	; %-S21RLDU
    	ld a, (controllerInputHandler.playerOneInput)
    ; Check if button 2 is pressed
    	cp %00100000
    	ret nz
		push hl
        @@Button2Handler:
        
        ; Check if timer has finished resetting
			ld a, (entityList.entity.8.timer)
			cp $00
            ret nz

		; Make sure the sprites start from #1
			ld a, (FirstSpriteTextCC)
			ld (tonbowCC), a                ; ASCII "1" for the first sprite
		; Reset our timer
			ld hl, entityList.entity.8.timer		; This is a simple demo, so just hardcoding entity numbers
			ld (hl), TOGGLE_TIMER

		; Toggle the flicker
			ld hl, entityList.entity.8
			ld de, playerTemplateEntityStruct.flickerState - playerTemplateEntityStruct.updateRoutinePointerLo
			add hl, de                                  ; HL -> playerTemplateEntityStruct.flickerToggle
			ld a, (hl)                                  ; A = Flicker ON/OFF
			xor FLICKER_TOGGLE                          ; A = Flicker OFF/ON
			ld (hl), a                                  ; Update playerTemplateEntityStruct.flickerState
		;Check if HI or LO Priority entities
			cp FLICKER_TOGGLE
			jr z, @@DeactivateLoEntities
			ld hl, entityListHi.entity.0.state
			jr @@DeactivateEntities

        @@DeactivateLoEntities:
            ld hl, entityList.entity.0.state
        @@DeactivateEntities:
        ;Deactive Entities
            ld de, ENTITY_SIZE
            ld a, DEACTIVATE_ENTITY
            ld (hl), a

            add hl, de                          ; HL -> entity.1.state
            ld (hl), a

            add hl, de                          ; HL -> entity.2.state
            ld (hl), a

            add hl, de                          ; HL -> entity.3.state
            ld (hl), a

            add hl, de                          ; HL -> entity.4.state
            ld (hl), a

            add hl, de                          ; HL -> entity.5.state
            ld (hl), a

            add hl, de                          ; HL -> entity.6.state
            ld (hl), a

            add hl, de                          ; HL -> entity.7.state
            ld (hl), a
    	pop hl
        ; Swap entity priority

	ret

		@@DPadJumpTable:
		; If nothing is pressed, leave
			jp @@ReturnFromDPadCheck 
		; If a direction is pressed, then jump to do the correct action
			jp @@DPadUp					; Only UP is pressed
			jp @@DPadDown				; Only DOWN is pressed
			jp @@ReturnFromDPadCheck 	; UP and DOWN are pressed
			jp @@DPadLeft				; Only LEFT is pressed
			jp @@DPadUpLeft				; UP and LEFT are pressed
			jp @@DPadDownLeft			; LEFT & DOWN are pressed
			jp @@ReturnFromDPadCheck 	; UP, DOWN and LEFT are pressed										
			jp @@DPadRight				; Only RIGHT are pressed
			jp @@DPadUpRight			; RIGHT & UP are pressed
			jp @@DPadDownRight			; RIGHT & DOWN are pressed
			jp @@ReturnFromDPadCheck 	; RIGHT and UP and DOWN are pressed
			jp @@ReturnFromDPadCheck 	; RIGHT and LEFT are pressed
			jp @@ReturnFromDPadCheck 	; RIGHT and LEFT and UP are pressed
			jp @@ReturnFromDPadCheck 	; RIGHT and LEFT and DOWN are pressed
			jp @@ReturnFromDPadCheck 	; RIGHT and LEFT and DOWN and UP are pressed

		; DE -> entity.state
		@@DPadUp:
			; HL -> entity.state
			ld de, playerTemplateEntityStruct.yVel - playerTemplateEntityStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, -PLAYER_TEMPLATE_UD_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.state - playerTemplateEntityStruct.yVel
			add hl, de					; HL -> entity.state
			; DE -> entity.state
			jp @@ReturnFromDPadCheck

		@@DPadDown:
			; HL -> entity.state
			ld de, playerTemplateEntityStruct.yVel - playerTemplateEntityStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, PLAYER_TEMPLATE_UD_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.state - playerTemplateEntityStruct.yVel
			add hl, de					; HL -> entity.state
			; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadLeft:
			; HL -> entity.state
			ld de, playerTemplateEntityStruct.xVel - playerTemplateEntityStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, -PLAYER_TEMPLATE_LR_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.state - playerTemplateEntityStruct.xVel
			add hl, de					; HL -> entity.state
			; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadRight:
			; HL -> entity.state
			ld de, playerTemplateEntityStruct.xVel - playerTemplateEntityStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, PLAYER_TEMPLATE_LR_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.state - playerTemplateEntityStruct.xVel
			add hl, de					; HL -> entity.state
			; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadUpLeft:
			; HL -> entity.state
			ld de, playerTemplateEntityStruct.yVel - playerTemplateEntityStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, -PLAYER_TEMPLATE_DIAG_UD_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.xVel - playerTemplateEntityStruct.yVel
			add hl, de					; HL -> entity.state
			; Decrease xVel to move left
			ld a, -PLAYER_TEMPLATE_DIAG_LR_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.state - playerTemplateEntityStruct.xVel
			add hl, de					; HL -> entity.state
			; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadDownLeft:
			; HL -> entity.state
			ld de, playerTemplateEntityStruct.yVel - playerTemplateEntityStruct.state
			add hl, de					; HL -> entity.yVel
			; Increase yVel to move down
			ld a, PLAYER_TEMPLATE_DIAG_UD_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.xVel - playerTemplateEntityStruct.yVel
			add hl, de					; HL -> entity.state
			; Decrease yVel to move up
			ld a, -PLAYER_TEMPLATE_DIAG_LR_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.state - playerTemplateEntityStruct.xVel
			add hl, de					; HL -> entity.state
			; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadUpRight:
			; HL -> entity.state
			ld de, playerTemplateEntityStruct.yVel - playerTemplateEntityStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, -PLAYER_TEMPLATE_DIAG_UD_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.xVel - playerTemplateEntityStruct.yVel
			add hl, de					; HL -> entity.state
			; Increase yVel to move right
			ld a, PLAYER_TEMPLATE_DIAG_LR_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.state - playerTemplateEntityStruct.xVel
			add hl, de					; HL -> entity.state
			; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadDownRight:
			; HL -> entity.state
			ld de, playerTemplateEntityStruct.yVel - playerTemplateEntityStruct.state
			add hl, de					; HL -> entity.yVel
			; Increase yVel to move down
			ld a, PLAYER_TEMPLATE_DIAG_UD_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.xVel - playerTemplateEntityStruct.yVel
			add hl, de					; HL -> entity.state
			; Increase yVel to move right
			ld a, PLAYER_TEMPLATE_DIAG_LR_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerTemplateEntityStruct.state - playerTemplateEntityStruct.xVel
			add hl, de					; HL -> entity.state
			; DE -> entity.state
			jp @@ReturnFromDPadCheck

; ==============================================================
;  Adjust what frame of animation PlayerTemplateEntity is on
; ==============================================================
	@AdjustFrame:

	ret


; ==============================================================
;  Update PlayerTemplateEntity animation based off current state
; ==============================================================
	@UpdateEntityAnimation:

	ret

; ==============================================================
;  Update PlayerTemplateEntity Position and Hitbox positions
; ==============================================================
	@UpdatePositions:
		
		ret


; ==============================================================
;  Initializes the PlayerTemplateEntity
; ==============================================================
; 
; Parameters: 	HL = PlayerTemplateEntity.updateRoutinePointerLo 
;				BC = yPos
; 				IX = xPos
; Affects: A, HL, DE
	@Initialize:
	; Basic Entity Initialization
		; HL ->  PlayerTemplateEntity.updateRoutinePointerLo
		ld de, PlayerTemplateEntity@Update
		ld a, $FF									; A = Entity Type
		call BaseEntityClass@Initialize				; HL -> PlayerTemplateEntity.cc
		ld de, tonbowCC
		ld a, (de)
		ld (hl), a									; Updated PlayerTemplateEntity.cc
		inc a
		ld (de), a
        inc hl                                      ; HL -> player.flickerState
        ld (hl), $00                                ; Updated player.flickerState

		ret


; ==============================================================
;  Updates Player Golem sprite and writes to SATBuffer
; ==============================================================
    ;.INCLUDE "Player/buildPlayerGolemMetasprite.asm"


; ================================================================================
;  Player Template Tile Data
; ================================================================================

; Separated by animation cycles
    @Tiles:
    ; ===============================================
    ;   Golem Running Right
    ; ===============================================
        @@PlayerTemplateTiles0:
        ; ----------------
        ; Raw Data
        ; ----------------
        ; Raw Data to be loaded into VRAM
            @@@RawData:
                @@@@RawDataFrame0:
                    ;.INCLUDE "Assets/TestRoom/Sprites/Golem/papaGolemRightWalk0SpriteTiles.inc"
				@@@@RawDataFrame0End:
                @@@@RawDataFrame1:
                    ;.INCLUDE "Assets/TestRoom/Sprites/Golem/papaGolemRightWalk1SpriteTiles.inc"
				@@@@RawDataFrame1End:
				@@@@RawDataFrame2:
                    ;.INCLUDE "Assets/TestRoom/Sprites/Golem/papaGolemRightWalk2SpriteTiles.inc"
				@@@@RawDataFrame2End:
            @@@RawDataEnd:
	; ===============================================
    ;   Golem Running Left
    ; ===============================================
        @@PlayerTemplateTiles1:
        ; ----------------
        ; Raw Data
        ; ----------------
        ; Raw Data to be loaded into VRAM
            @@@RawData:
                @@@@RawDataFrame0:
                    ;.INCLUDE "Assets/TestRoom/Sprites/Golem/papaGolemLeftWalk0SpriteTiles.inc"
				@@@@RawDataFrame0End:
                @@@@RawDataFrame1:
                    ;.INCLUDE "Assets/TestRoom/Sprites/Golem/papaGolemLeftWalk1SpriteTiles.inc"
				@@@@RawDataFrame1End:
				@@@@RawDataFrame2:
                    ;.INCLUDE "Assets/TestRoom/Sprites/Golem/papaGolemLeftWalk2SpriteTiles.inc"
				@@@@RawDataFrame2End:
            @@@RawDataEnd:

.ENDS