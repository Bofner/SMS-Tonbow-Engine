; ==============================================================
;  Initilizes Entity List
; ==============================================================
; Parameters: None
; Returns: None
; Affects: A, BC, DE, HL
	@InitializeEntityList:
	; Set our initial values for the Entity List
		ld hl, entityList
		xor a
	; Set all entities to be inactive
		ld (hl), a	
		inc hl											; HL -> entity.0
		ld de, entityStructure.state - entityStructure.updateRoutinePointerLo
		add hl, de										; HL -> entity.0.state
		ld b, ENTITY_LIST_MAX_SIZE						; B = Entity Counter (ENTITY_LIST_MAX_SIZE)
		ld de, ENTITY_SIZE								; DE = ENTITY_SIZE
	-:
		ld a, INACTIVE_ENTITY
		ld (hl), a	
		add hl, de										; HL -> entity.NEXT
		xor a								
		djnz -
	; Make sure our activationFailure is set
		ld hl, entityList.numStartEntities				; HL -> numStartEntities
		ld (hl), $00
		inc hl											; HL -> currentBitmapLocation
		; swap a
		ld (hl), a
		inc hl											; HL -> EntitiesUpdated
		xor a
		ld (hl), a
		inc hl											; HL -> bitmap.0
		ld (hl), a
		inc hl											; HL -> bitmap.1
		ld (hl), a
		inc hl											; HL -> bitmap.2
		ld (hl), a
		inc hl											; HL -> bitmap.3
		ld (hl), a
		inc hl											; HL -> bitmap.4
		ld (hl), a
		inc hl											; HL -> firstRenderEntityPointerLo
		ld de, entityList.entity.0
		ld a, e
		ld (hl), a
		inc hl											; HL -> firstRenderEntityPointerHi
		ld a, d
		ld (hl), a										; firstRenderEntityPointer = address of entity.0
		inc hl											; HL -> firstRenderEntityBitmapKey
		ld (hl), $00									; First entity is in 0th byte 0th bit

		
	; And the High Priority List too
		@@@InitializeentityListHi:
		; Set our initial values for the Entity List
			ld hl, entityListHi
			xor a
		; Set all entities to be inactive
			ld (hl), a	
			inc hl											; HL -> entity.0
			ld de, entityStructure.state - entityStructure.updateRoutinePointerLo
			add hl, de										; HL -> entity.0.state
			ld b, HI_ENTITY_MAX 							; B = Entity Counter (ENTITY_LIST_MAX_SIZE)
			ld de, ENTITY_SIZE								; DE = ENTITY_SIZE
		-:
			ld a, INACTIVE_ENTITY
			ld (hl), a	
			add hl, de										; HL -> entity.NEXT
			xor a								
			djnz -
		; Make sure our activationFailure is set
			ld hl, entityListHi.highPriorityEntityBitmap	; HL -> numStartEntities
			ld (hl), $00

			ret
		@InitializeEntityListEnd:
