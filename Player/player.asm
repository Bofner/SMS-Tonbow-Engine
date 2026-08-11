; .BANK 0 SLOT 0
; ================================================================================
;  Test Room Tonbow's Structure
; ================================================================================
.STRUCT playerEntityClassStruct SIZE $40
	instanceof entitySkeleton
	cc							db			; The character code for the tile
    flickerState                db          ; Keeps track of if flicker is ON or OFF
.ENDST


.SECTION "Player Entity Class"
PlayerEntityClass:
; ================================================================================
;  All subroutines and data related to the PlayerEntityClass Class
; ================================================================================
; Change the following throughout the entire class
; PlayerEntityClass: 		Captial letter of the entity (EntityExample)
; PLAYER_ENTITY:		Constant values (ENTITY_EXAMPLE)
; playerEntityClass: 			Lower case letter of the entity (entityExample)


; ==============================================================
;  Constants
; ==============================================================
; Init Values
	.DEF 	PLAYER_ENTITY_START_Y						$0600 		; 96 = $60.0 
	.DEF	PLAYER_ENTITY_START_X	 					$0280 		; 40 = $28.0 
	.DEF	PLAYER_ENTITY_SPEED							$10			; $LSB,FRAC
	.DEF	PLAYER_ENTITY_TIMER_INIT_VALUE				$00
	.DEF	PLAYER_ENTITY_CC							$04

; Toggle
    .DEF    FLICKER_TOGGLE                              LO_ENTITY   ; ($FF)
	.DEF	TOGGLE_TIMER								$1E

; MASKS
	.DEF	DPAD_MASK									%00001111

; VRAM Absolute Data
	.DEF 	PLAYER_ENTITY_VRAM							$0000

; Player values
	.DEF	PLAYER_UD_VELOCITY							$08
	.DEF	PLAYER_LR_VELOCITY							$08
	.DEF	PLAYER_DIAG_UNNORMALIZED_VELOCITY			sqrt(((PLAYER_UD_VELOCITY ^2) + (PLAYER_LR_VELOCITY ^2)))
	.DEF	PLAYER_DIAG_UD_COMPONENT_VELOCITY			round((PLAYER_UD_VELOCITY ^2) / PLAYER_DIAG_UNNORMALIZED_VELOCITY)
	.DEF	PLAYER_DIAG_LR_COMPONENT_VELOCITY			round((PLAYER_LR_VELOCITY ^2) / PLAYER_DIAG_UNNORMALIZED_VELOCITY)


; ==============================================================
;  Updates the PlayerEntityClass
; ==============================================================
; 
; 
; Parameters: DE = PlayerEntityClass.state (Should be coming from EntityList@UpdateEntities)
; Returns: None
; Affects: DE
	@Update:
		ex de, hl									; HL -> PlayerEntityClass.state
	; Choose what to do based off state

    ; Check controls
    call @CheckControllerInputs

	; Update Position
		ld de, playerEntityClassStruct.yVel - playerEntityClassStruct.state
		add hl, de									; HL -> PlayerEntityClassStruct.yVel
		push hl
			call BaseEntityClass@UpdateEntityPosition	; HL -> playerEntityClassStruct.cc
		pop hl										; HL -> PlayerEntityClassStruct.yVel
		; Reset velocity to 0
		xor a
		ld (hl), a									; entity.yVel = 0
		ld de, playerEntityClassStruct.xVel - playerEntityClassStruct.yVel
		add hl, de									; HL -> PlayerEntityClass.xVel
		ld (hl), a

	; Update in SAT Buffer
		ld de, playerEntityClassStruct.yPos - playerEntityClassStruct.xVel
		add hl, de									; HL -> PlayerEntityClass.yPos
	; yPos
		ld a, (hl)
		ld iyl, a									; IYL = yPos
		ld de, playerEntityClassStruct.xPos - playerEntityClassStruct.yPos
		add hl, de									; HL -> PlayerEntityClass.xPos
	; xPos
		ld a, (hl)
		ld ixl, a									; IXL = xPos
	; cc
		inc hl 										; HL -> PlayerEntityClass.cc
		ld c, (hl)									; C = PlayerEntityClass.cc
	; Update the SAT Buffer
		push hl
			call SpriteHandlerClass@UpdateSATBufferSingleEntry
		pop hl								; Preserve entity address pointer


	
		ret

; ==============================================================
;  Adjust what frame of animation PlayerEntityClass is on
; ==============================================================
	@CheckControllerInputs:
	; Check DPad input
		ld a, (controllerInputHandler.playerOneInput)  ;Recall Joypad 1 input data
		and DPAD_MASK                   ;Make a mask to only look at the D-Pad
	; 3 * N + DPadJumpTable
		ld c, a
		add a, c
		add a, c                           ; 3 * N 
		ex de, hl						; DE -> entity.state
		ld h, 0
		ld l, a
		ld bc, @@DPadJumpTable
		add hl, bc                      ; 3 * N + DPadJumpTable
		jp hl                           ; Jump to specific input subroutine

		@@ReturnFromDPadCheck:
			ex de, hl					; HL -> entity.state
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
			ld de, playerEntityClassStruct.flickerState - playerEntityClassStruct.updateRoutinePointerLo
			add hl, de                                  ; HL -> playerEntityClassStruct.flickerToggle
			ld a, (hl)                                  ; A = Flicker ON/OFF
			xor FLICKER_TOGGLE                          ; A = Flicker OFF/ON
			ld (hl), a                                  ; Update playerEntityClassStruct.flickerState
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
			ex de, hl					; HL -> entity.state
			ld de, playerEntityClassStruct.yVel - playerEntityClassStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, -PLAYER_UD_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.state - playerEntityClassStruct.yVel
			add hl, de					; HL -> entity.state
			ex de, hl					; DE -> entity.state
			jp @@ReturnFromDPadCheck

		@@DPadDown:
			ex de, hl					; HL -> entity.state
			ld de, playerEntityClassStruct.yVel - playerEntityClassStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, PLAYER_UD_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.state - playerEntityClassStruct.yVel
			add hl, de					; HL -> entity.state
			ex de, hl					; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadLeft:
			ex de, hl					; HL -> entity.state
			ld de, playerEntityClassStruct.xVel - playerEntityClassStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, -PLAYER_LR_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.state - playerEntityClassStruct.xVel
			add hl, de					; HL -> entity.state
			ex de, hl					; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadRight:
			ex de, hl					; HL -> entity.state
			ld de, playerEntityClassStruct.xVel - playerEntityClassStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, PLAYER_LR_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.state - playerEntityClassStruct.xVel
			add hl, de					; HL -> entity.state
			ex de, hl					; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadUpLeft:
			ex de, hl					; HL -> entity.state
			ld de, playerEntityClassStruct.yVel - playerEntityClassStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, -PLAYER_DIAG_UD_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.xVel - playerEntityClassStruct.yVel
			add hl, de					; HL -> entity.state
			; Decrease xVel to move left
			ld a, -PLAYER_DIAG_LR_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.state - playerEntityClassStruct.xVel
			add hl, de					; HL -> entity.state
			ex de, hl					; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadDownLeft:
			ex de, hl					; HL -> entity.state
			ld de, playerEntityClassStruct.yVel - playerEntityClassStruct.state
			add hl, de					; HL -> entity.yVel
			; Increase yVel to move down
			ld a, PLAYER_DIAG_UD_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.xVel - playerEntityClassStruct.yVel
			add hl, de					; HL -> entity.state
			; Decrease yVel to move up
			ld a, -PLAYER_DIAG_LR_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.state - playerEntityClassStruct.xVel
			add hl, de					; HL -> entity.state
			ex de, hl					; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadUpRight:
			ex de, hl					; HL -> entity.state
			ld de, playerEntityClassStruct.yVel - playerEntityClassStruct.state
			add hl, de					; HL -> entity.yVel
			; Decrease yVel to move up
			ld a, -PLAYER_DIAG_UD_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.xVel - playerEntityClassStruct.yVel
			add hl, de					; HL -> entity.state
			; Increase yVel to move right
			ld a, PLAYER_DIAG_LR_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.state - playerEntityClassStruct.xVel
			add hl, de					; HL -> entity.state
			ex de, hl					; DE -> entity.state

			jp @@ReturnFromDPadCheck

		@@DPadDownRight:
			ex de, hl					; HL -> entity.state
			ld de, playerEntityClassStruct.yVel - playerEntityClassStruct.state
			add hl, de					; HL -> entity.yVel
			; Increase yVel to move down
			ld a, PLAYER_DIAG_UD_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.xVel - playerEntityClassStruct.yVel
			add hl, de					; HL -> entity.state
			; Increase yVel to move right
			ld a, PLAYER_DIAG_LR_COMPONENT_VELOCITY
			ld (hl), a
			ld de, playerEntityClassStruct.state - playerEntityClassStruct.xVel
			add hl, de					; HL -> entity.state
			ex de, hl					; DE -> entity.state
			jp @@ReturnFromDPadCheck

; ==============================================================
;  Adjust what frame of animation PlayerEntityClass is on
; ==============================================================
	@AdjustFrame:

	ret


; ==============================================================
;  Update PlayerEntityClass animation based off current state
; ==============================================================
	@UpdateEntityAnimation:

	ret

; ==============================================================
;  Update PlayerEntityClass Position and Hitbox positions
; ==============================================================
	@UpdatePositions:
		
		ret


; ==============================================================
;  Initializes the PlayerEntityClass
; ==============================================================
; 
; Parameters: 	HL = PlayerEntityClass.updateRoutinePointerLo 
;				BC = yPos
; 				IX = xPos
; Affects: A, HL, DE
	@Initialize:
	; Basic Entity Initialization
		; HL ->  PlayerEntityClass.updateRoutinePointerLo
		ld de, PlayerEntityClass@Update
		ld a, $FF									; A = Entity Type
		call BaseEntityClass@Initialize				; HL -> PlayerEntityClass.cc
		ld de, tonbowCC
		ld a, (de)
		ld (hl), a									; Updated PlayerEntityClass.cc
		inc a
		ld (de), a
        inc hl                                      ; HL -> player.flickerState
        ld (hl), $00                                ; Updated player.flickerState

		ret


@Tiles:
; Just the one set
	@@First:
		; .INCLUDE "..\\assets\\FixedBankEntities\\PlayerEntityClass\\PlayerEntityClassFirstTiles.inc"
	@@FirstEnd:
	@@Second:
		; .INCLUDE "..\\assets\\FixedBankEntities\\PlayerEntityClass\\PlayerEntityClassSecondTiles.inc"
	@@SecondEnd:

.ENDS