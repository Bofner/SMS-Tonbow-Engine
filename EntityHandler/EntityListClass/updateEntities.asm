; ==============================================================
;  Updates all Entities in the Entity List
; ==============================================================
; 
; Parameters: None
; Returns: None
; Affects: A, BC, DE, HL
	@UpdateAllEntities:
	; UPDATE HIGH PRIORITY ENTITIES FIRST
		ld a, (entityListHi.highPriorityEntityBitmap)
		cp $00
		call nz, @@UpdateHighPriorityEntities
	; Reset our Entities Updated Count
		ld a, (entityList.numEntities)
		cp $00
		ret z										; If no Entities, then don't do anything
		ld hl, entityList.numStartEntities
		ld (hl), a									; Save how many entities we had before updating
		xor a
		ld hl, entityList.entitiesUpdated
		ld (hl), a									; entityList.entitiesUpdated = 0
	; Find out where in the bitmap our First Render Entity is
		; Find the proper Bitmap
		inc hl                                      ; HL -> entityList.bitmap.0
		ld a, (entityList.firstRenderEntityBitmapKey)	; A = $BitmapNumber,BitPosition
		and ACTIVE_ENTITY_BYTE_MASK					; A = $BitmapNumber,0
		ld (entityList.currentBitmapLocation), a	; currentBitmapLocation = $BitmapNumber,0
		rlca
		rlca
		rlca
		rlca										; A = $BitmapNumber
		ld d, $00
		ld e, a										; DE = $BitmapNumber (How many bytes away from bitmap.0)
		add hl, de									; HL -> entityList.bitmap.$BitmapNumber
		ld c, (hl)									; C = bitmap.CURRENT
		; Find the proper BIT in the Bitmap
		ld a, (entityList.firstRenderEntityBitmapKey)			; A = $BitmapNumber,BitPosition
		and ACTIVE_ENTITY_BIT_MASK					; A = $BitPosition
		ld b, a										; B = BitPosition (Counter)
		ld a, (entityList.currentBitmapLocation)
		or b
		ld (entityList.currentBitmapLocation), a	; currentBitmapLocation = $BitmapNumber,BitPostion
		xor a										; A = 0
		cp b										; Check if it is at bit 0
		jr z, @@UpdateFirstRenderEntity				; If it is, then just update the First Render Entity
		-:
			srl c									; Push the entity our of our bitmap
			djnz -
		; C = bitmap.CurrentEntity

	; Update the First Render Entity for the NEXT frame
		@@UpdateFirstRenderEntity:
			ld a, (entityList.currentBitmapLocation)
			and ACTIVE_ENTITY_BIT_MASK				; A = $BitPosition
			inc a
			; Check if this was the last entity in the bitmap
			cp ACTIVE_ENTITY_BIT_MASK + 1			
			jr nc, @@@NewFirstRenderEntityInNewByte
			; Check if there is actually an entity located here
			ld a, c									; A = bitmap.CURRENT (and specifically pointint at firstRenderEntity)
			; Go through the bitmap one entity bit at a time
			ld hl, entityList.findNewFirstRenderEntityBitmapKeyOffset
			ld (hl), $00							; findNewFirstRenderEntityBitmapKeyOffset = 0
			-:
				inc (hl)							; findNewFirstRenderEntityBitmapKeyOffset += 1
				srl a								; Push NEXT entity bit into CY
				jr nz, @@@PointToAdjacentEntity		; Check if there is an active entity here
				cp $00
				jr nz, -							; Check if the byte is now full
				jr @@@NewFirstRenderEntityInNewByte

			@@@PointToAdjacentEntity:
				; Point to the entity that is adjacent in the bitmap to the current
				; Update Bitmap Key
				ld a, (entityList.firstRenderEntityBitmapKey)
				add a, (hl)							; A += (findNewFirstRenderEntityBitmapKeyOffset) 
				ld b, (hl)							; B = findNewFirstRenderEntityBitmapKeyOffset
				ld (entityList.firstRenderEntityBitmapKey), a	
				; Update First Render Entity Pointer
				ld a, (entityList.firstRenderEntityPointerLo)
				ld l, a
				ld a, (entityList.firstRenderEntityPointerHi)
				ld h, a									; HL -> entityList.entity.CURRENT
				push hl
				; Jump to next Entity (within the same bitmap byte, at LEAST +1 away)
					ld de, ENTITY_SIZE					; DE = ENTITY_SIZE
					-:
						add hl, de							; HL -> entityList.entity.NEXT
						djnz -
					ld a, l								; A = entityPointerLo
					ld (entityList.firstRenderEntityPointerLo), a
					ld a, h								; A = entityPointerHi
					ld (entityList.firstRenderEntityPointerHi), a
				pop hl									; HL -> entityList.entity.CURRENT
					jr @@LoadFirstRenderEntity

			@@@NewFirstRenderEntityInNewByte:
			; Find the next Bitmap with active entities 
				ld a, (entityList.currentBitmapLocation)	; A = $BitmapNumber, BitPosition
				add a, NEXT_BITMAP
				and ACTIVE_ENTITY_BYTE_MASK					; A = bitmap.NEXT
				rlca
				rlca
				rlca
				rlca										; A = $BitmapNumber
				ld (entityList.findNewFirstRenderEntityBitmapKeyOffset), a	; Save BitmapNumber
				; Make sure there are active entities in this bitmap
				@@@@CheckForActiveBitmap:
					ld a, (entityList.findNewFirstRenderEntityBitmapKeyOffset) ; Redundancy for Loop
					ld d, $00
					ld e, a										; DE = $BitmapNumber
					ld hl, entityList.bitmap.0
					add hl, de									; HL -> entityList.bitmap.NEXT
					ld d, (hl)									; D = bitmap.NEXT
					; Set up in case we need to check another byte
					ld a, (entityList.findNewFirstRenderEntityBitmapKeyOffset)
					inc a
					and BYTE_MASK_OFFSET						; A = $0,BitmapNum.NEXT 
					; [The nibbles are reversed because this is an offset, so use the BITmask instead of BYTEmask]
					; Check if the Bitmap is empty
					@@@@@CheckForEmptyBitmap:
						ld (entityList.findNewFirstRenderEntityBitmapKeyOffset), a ; Save $BitmapNum,0
						; Check if this bitmap is empty
						xor a
						cp d			
						jr z, @@@@CheckForActiveBitmap		
						; Update the new Bitmap Key
						ld a, (entityList.findNewFirstRenderEntityBitmapKeyOffset)
						; $0, BitmapNum.NEXT
						dec a									; $0, BitmapNum.CURRENT
						ld (entityList.findNewFirstRenderEntityBitmapKeyOffset), a
						rlca
						rlca
						rlca
						rlca									; A = $BitmapNum,0									
						ld (entityList.firstRenderEntityBitmapKey), a
	
				; Point at the new entity
				@@@@PointToNewEntity:
				ld a, (entityList.firstRenderEntityPointerLo)
				ld l, a
				ld a, (entityList.firstRenderEntityPointerHi)
				ld h, a									; HL -> entityList.entity.CURRENT
				push hl
					ld hl, entityList.entity.0
					ld de, ENTITY_SIZE	* 8				; DE = ENTITY_SIZE * (8 Bits per Bitmap)
					ld a, (entityList.findNewFirstRenderEntityBitmapKeyOffset)	; A = $BitmapNumber
					; Check if the Bitmap is the 0th Bitmap
					cp $00 
					jr z, @@@@@SetUpPointer
					; Point to the proper entity by jumping in 8-entity increments
					@@@@@Multiplier:
						add hl, de							; HL -> entityList.entity.NEXT
						dec a
						cp $00
						jr nz, @@@@@Multiplier
					@@@@@SetUpPointer:
						ld a, l								; A = entityPointerLo
						ld (entityList.firstRenderEntityPointerLo), a
						ld a, h								; A = entityPointerHi
						ld (entityList.firstRenderEntityPointerHi), a
					pop hl									; HL -> entityList.entity.CURRENT

	; Load the First Render Entity for THIS frame
		@@LoadFirstRenderEntity:
			

	; Update the bitmap and our location in it
		@@CycleThroughBitmap:
		; Begin our Entity Render Shuffle Loop
		; C = bitmap.CurrentEntity, HL -> entityList.entityCurrent
			xor a
			cp c									; Check if we have active entities
		; If there are no more active entities in this bitmap byte, then leave
			jp z, EntityListClass@UpdateAllEntities@ByteFinish
			ld a, (entityList.currentBitmapLocation)
			inc a
			ld (entityList.currentBitmapLocation), a	; Update our current Bitmap Location
			srl c
			jr nc, @@UpdateSingleEntityEnd				; Check if the current entity is active or not
	; Update a single entity from the bitmap
		@@UpdateSingleEntity:
			push bc
			push hl
			push de
				; Jump/call the Entitiy's Event Handler
					; HL -> entity.CURRENT.updateRoutinePointerLo
					ex de, hl					; Swap HL and DE, DE = entity.CURRENT.updateRoutinePointerLo
					ld a, (de)
					ld l, a
					inc de                      ; DE -> entity.CURRENT.updateRoutinePointerHi
					ld a, (de)
					ld h, a						; HL -> EntityClass@EventHandler
					inc de                      ; DE -> entity.CURRENT.state
				ld bc, @@ReturnFromEntityUpdate
				push bc						; Make our JP HL function as a CALL HL
				jp hl						; call EntityClass@EventHandler
				pop bc						; Never reached
			@@ReturnFromEntityUpdate:
				ld hl, entityList.entitiesUpdated
				inc (hl)
			pop de
			pop hl
			pop bc
	; Check if we are at the end of the Entity List		
		@@UpdateSingleEntityEnd:	
			xor a
			cp c
			jp nz, @@CheckAllEntitiesUpdated

	; Load the next byte that has entities
		@@ByteFinish:
			ld a, (entityList.currentBitmapLocation)	; A = $BitmapNumber,BitPosition
			and ACTIVE_ENTITY_BYTE_MASK					; A = $BitmapNumber,0
			add a, NEXT_BITMAP							; A = $MAYBEBitmapNumber.NEXT,0
			; Check if we are overshot the last bitmap
			cp LAST_BITMAP + 1
			jr nc, @@@UpdateCurrentBitmapLocation
			; Reset to the 0th Bitmap, 0th BitPosition
			xor a
		; Update our location in the bitmap, grab the actual bitmap, and point to the proper entity
			@@@UpdateCurrentBitmapLocation:
			ld (entityList.currentBitmapLocation), a	; currentBitmapLocation = bitmap.NEXT
			; Grab the actual Bitmap
			ld hl, entityList.bitmap.0					; HL -> bitmap.0
			and ACTIVE_ENTITY_BYTE_MASK
			rlca
			rlca
			rlca
			rlca										; A = $BitmapNumber
			ld d, $00
			ld e, a
			add hl, de									; HL -> bitmap.Next
			; Prep if we need to check the next byte
			ld a, (entityList.currentBitmapLocation)
			add a, NEXT_BITMAP
			and ACTIVE_ENTITY_BYTE_MASK
			ld c, a										; C = $BitmapNumber.NEXT,0
			; Check if we have any entities left, just in case they got deactivated:
			ld a, (entityList.numEntities)
			cp $00
			ret z
			; Check if this bitmap is empty
			xor a
			cp (hl)
			ld a, c										; A = $BitmapNumber.NEXT
			jr z, @@@UpdateCurrentBitmapLocation		; If it is, check out the next one
			ld c, (hl)									; C = bitmap.NEXT
			; Point to proper entity
			ld hl, entityList.entity.0					; HL -> entity.0
			ld b, e										; B = $BitmapNumber 
			ld de, ENTITY_SIZE * 8						; DE = ENTITY_SIZE * (8 bits per byte)
			; Check if B is zero
			xor a
			cp b		
			jr z, @@SkipJumpToNextEntity				; If so, then we are at entity.0
			-:
				add hl, de								; HL -> entity.FIRST_IN_NEXT_BITMAP
				djnz -
			; HL -> entity.Bitmap.NEXT.0
			jr @@SkipJumpToNextEntity

		@@CheckAllEntitiesUpdated:
			ld de, ENTITY_SIZE	
			add hl, de									; HL -> entity.NEXT
	; Check if we have updated all entities		
		@@SkipJumpToNextEntity:
			ld a, (entityList.entitiesUpdated)			; A = entitiesUpdated
			ld d, a										; D = entitiesUpdated
			ld a, (entityList.numStartEntities)			; A = numStartEntities
			cp d
			jr nz, @@CycleThroughBitmap					; If we haven't updated everything, then update more

			ret

	; ----------------------------------------------------------------------------------

		@@UpdateHighPriorityEntities:
		; Cycle through our 8 potential entities and update the if need be
			ld b, HI_ENTITY_MAX								; B = Counter
			ld a, (entityListHi.highPriorityEntityBitmap)	
			ld c, a											; C = Bitmap
			ld hl, entityListHi.entity.0					; HL -> entity.current.updateRoutinePointerLo
			ld de, ENTITY_SIZE
			xor a											; A = 0
			@@@CheckForActiveEntity:
				cp c                                        
				ret z										; If not more High Priority Entities, then finish
				srl c
				call c, @@@UpdateEntity                     ; Pull out next bit from bitmap and check for entity
				add hl, de									; HL -> entity.next
				djnz  @@@CheckForActiveEntity				; If no more to update, then return

			ret 											

			@@@UpdateEntity:
				push bc
				push hl
				push de	
					; Jump/call the Entitiy's Event Handler
					; HL -> entity.CURRENT.updateRoutinePointerLo
					ex de, hl					; Swap HL and DE, DE -> entity.CURRENT.entityUpdatePointerLo
					ld a, (de)
					ld l, a
					inc de                      ; DE -> entity.CURRENT.entityUpdatePointerHi
					ld a, (de)
					ld h, a						; HL -> EntityClass@UpdateRoutineAddress
					inc de                      ; DE -> entity.CURRENT.state
					ld bc, @@@@ReturnFromEntityUpdate
					push bc						; Make our JP HL function as a CALL HL
					jp hl						; call EntityClass@EventHandler
					pop bc						; Never reached, just for PUSH/POP color consistency
				@@@@ReturnFromEntityUpdate:
					xor a
				pop de
				pop hl
				pop bc

				ret

@UpdateAllEntitiesEnd: