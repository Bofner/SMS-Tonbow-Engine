; ==============================================================
;  Adds an Entity to the Entity List
; ==============================================================
; @ActivateEntity:
; Parameters:  IXl = Player Number (0 -> NOT Player), A = HI_ENTITY or LO_ENTITY
; Returns: HL -> eventID
; Affects: A, BC, DE, HL, aux8BitVar
@ActivateEntity:
; Check if High Priority Entity
		cp HI_ENTITY
		jp z, @ActivateHighPriorityEntity
		ld hl, entityList.numEntities
		ld a, (hl)
		ld hl, entity.dummy									; If list is full, dummy will be "initialized" instead of overwriting critical data
		cp ENTITY_LIST_MAX_SIZE
		ret nc												; Don't add it if we have too many Entities
	; If we are good, bump that counter up
		ld hl, entityList.numEntities
		inc a
		ld (hl), a											
		dec a												; But we still need to actually add the Entity
		ld hl, entityList.entity.0.updateRoutinePointerLo	; The first entity in the list
		ld de, entityList.bitmap.0
		ld c, ENTITY_BITMAP_START							; C will act like our currentBitmapLocation ($BYTE,$BIT --> $0-3,0-7)
															; In this case, we are starting at BYTE $00, BIT %0
		ld hl, aux8BitVar									; Use as a counter
		ld (hl), ENTITY_BITMAP_START						; Start at $00
	
	@@ActivateFirstInactiveEntity:
		ld b, ACTIVE_ENTITY_SEARCH_MASK
		ld a, (de)
		cp BITMAP_FULL
		jr z, @@@SetupNextBitmap
	; Start our search
		jr @@@CheckForInactiveEntity
		@@@SetupNextBitmap:
		; If we didn't find one here, check the next 8 Entities in the list
			ld b, ACTIVE_ENTITY_SEARCH_MASK
			ld a, c						; \
			and ACTIVE_ENTITY_BYTE_MASK	;  } Increase the BYTE position and
			add ACTIVE_ENTITY_INC_BYTE	;  } reset the BIT position
			ld c, a						; /
			inc de
			ld a, (aux8BitVar)
			add a, 8
			ld (aux8BitVar), a		; Update Entity Counter
		@@@CheckForInactiveEntity:
		; Search through the list for the first inactive Entity
			ld a, (de)					; A = (bitmap.n)
			cp $FF						; Check if full
			jr z, @@@SetupNextBitmap
			and b
			jr z, @@ActivateInActiveEntityList
				
		; We did not find an Inactive Entity, so check if we need to move to the next byte
			sla b
			inc (hl)									; increase our counter
			inc c										; Increase BIT position
			jr @@@CheckForInactiveEntity	

; We shouldn't get to this part of the code
	ret

	@@ActivateInActiveEntityList:
	; Activate our Entity in the Entity List and Active Entity List
	; Start by getting to the correct BYTE in the bitmap
		ld a, c
		and ACTIVE_ENTITY_BYTE_MASK				; Only going from 0-3
		
		;swap a										
		rlca
		rlca
		rlca
		rlca									; BYTE counter now in LSNibble
								
		ld d, 0
		ld e, a
		ld hl, entityList.bitmap.0
		add hl, de								; HL -> bitmap.inactiveEntityByte
	; Now get to the corret BIT in the bitmap
		ld a, c
		and ACTIVE_ENTITY_BIT_MASK				; A = The BIT we want to SET
		ld b, a									; B becomes our counter
		ld c, ACTIVE_ENTITY_SET_MASK			; C is our mask which we will use to SET
		xor a
		cp b									; Check if we are to SET BIT 0
		jr z, +
	-:
		sla c									; Move ahead one BIT
		dec b
		jr nz, -
	+:
		ld a, (hl)								; Grab our bitmap
		or c
		ld (hl), a								; Bit has been activated
	@@ActivateInEntityList:
	; Get to the correct location in the Entity List
		ld de, entityList.entity.0.state
		ld a, (aux8BitVar)						; A = Entity List Position Counter
		ld h, $00
		ld l, a									; HL = Entity List Position Counter
		add hl, hl								; x2
		add hl, hl								; x4
		add hl, hl								; x8
		add hl, hl								; x16
		add hl, hl								; x32 Since our Entity is 32 bytes
		add hl, hl								; x64 Since our Entity is 64 bytes								
		add hl, de								; HL -> entity.NEXTINACTIVE.state
	; Set value to be deactivated just incase the entity doesnt get initialized 
		ld (hl), ACTIVATE_SUCCESS 				; Same as DEACTIVE_ENTITY
	; Point to Update Routine Pointer
		ld de, entityStructure.updateRoutinePointerLo - entityStructure.state
		add hl, de								; HL -> entity.NEXTFREE.updateRoutinePointerLo
	@@CheckIfEntityIsPlayer:
	; Check if we need to set Player Pointer
		ld a, ixl								; A = Player(?) Number
		cp $00
		jr z, @@ReturnFromActivation			; \
		cp PLAYER_TWO_ENTITY					;  } If 0 or too big, don't set pointer
		jr nc, @@ReturnFromActivation			; /
	; If we get here, then set pointer
		push hl
			ld hl, player1Entity.pointer - 2		; Set up our offset
			sla a								; Double a (because pointers are WORDS)
			ld d, $00
			ld e, a
			add hl, de							; HL -> Player Pointer
			ex de, hl							; DE -> Player Pointer
		pop hl									; HL -> entity.NEXTFREE.updateRoutinePointerLo
		ld a, l
		ld (de), a
		inc de								; DE = hibyte(Player Pointer)
		ld a, h
		ld (de), a							; Player Pointer is set
	; Reset Pointer parameter
		xor a
		ld ixl, a								; Reset IXl so we don't overwrite our pointer by accident
		

	@@ReturnFromActivation:			
	; Set entity to deactivate itself upon update unless properly initialized
		; HL -> entity.updateRoutinePointerLo
		ld a, lobyte(@DeactivateUninitializedEntity)
		ld (hl), a		
		inc hl									; HL -> entity.NEXTFREE.updateRoutinePointerHi
		ld a, hibyte(@DeactivateUninitializedEntity)
		ld (hl), a
		dec hl									; HL -> entity.NEXTFREE.updateRoutinePointerLo
	; Return with HL -> entity.NEXTFREE.updateRoutinePointerLo
		
	ret
@ActivateEntityEnd:

; ==============================================================
;  Adds an Entity to the High PriorityEntity List
; ==============================================================
; @ActivateHighPriorityEntity
; Parameters:  (Coming from ActivateEntity) ixl = Player Number (0 -> NOT Player)
; Returns: HL -> eventID
; Affects: A, BC, DE, HL, aux8BitVar
	@ActivateHighPriorityEntity:
	; Check if we can add the entity to the list
		ld hl, entityListHi.highPriorityEntityBitmap
		ld a, (hl)								
		ld hl, entity.dummy							; If list is full, dummy will be "initialized" instead of overwriting critical data
		cp BITMAP_FULL										
		ret nc										; Don't add it if we have too many Entities								
	; We can add the entity
		ld hl, entityListHi.entity.0
		ld de, ENTITY_SIZE
		ld c, $00									; Counter for Position in list
		@@FindFreeSpace:
		; A = highPriorityEntityBitmap
			srl a										; Bit shift to check if current spot is free
			jr nc, @@AddEntity							; If free, then add it to the list
			add hl, de									; HL -> entityListHi.entity.NEXT
			inc c										; Increase counter for list position
			jr @@FindFreeSpace

		@@AddEntity:
		; Add entity to the list and set value to be deactivated just incase the entity doesnt get initialized 
			ld (hl), ACTIVATE_SUCCESS 				; Same as DEACTIVE_ENTITY
		; Set entity value
			ld a, HI_ENTITY_NUMBER_0
			add a, c
		; Check if we are adding the first entity
			xor a
			cp c
			ld a, ACTIVE_ENTITY_SET_MASK
			jr z, @@@SetBitmap
			@@@BitmapSetLoop:
		; Find the map location for the entity we want
				sla a
				dec c
				jr nz, @@@BitmapSetLoop
			@@@SetBitmap:
		; Set Bitmap to be active
				ld c, a
				ld a, (entityListHi.highPriorityEntityBitmap)
				or c
				ld (entityListHi.highPriorityEntityBitmap), a

		; Check if it's a player
		jp EntityListClass@ActivateEntity@CheckIfEntityIsPlayer

		ret

