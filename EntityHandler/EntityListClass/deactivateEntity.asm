; ==============================================================
;  Removes Entity from the Entity List if it wasn't initialized
; ==============================================================
; Parameters: Called from UpdateAllEntities, so HL -> entity.currentState
; Returns: None
; Affects: A, BC, DE, HL
	@DeactivateUninitializedEntity:
; ==============================================================
;  Removes entity from the Entity List
; ==============================================================
; Parameters: HL -> entity.currentState
; Returns: None
; Affects: A, BC, DE, HL
	@DeactivateEntity:
	; Deactivate Entity
		ld a, INACTIVE_ENTITY
		cp (hl)								; Check if already Inactive
		ret z								; If yes, then return
		ld (hl), a
	; Check if our entity is HI or LO Priority
		ld de, entityListHi.entity.0
		ld a, l
		sub e
		; Compare entity.state address with the highPriorityEntity.0
		; If entity.state > highPriorityEntity.0 then it's high
		jr c, @@DeactivateLowPriorityEntity
		ld a, h
		sub d
		jr nc, @@DeactivateHighPriorityEntity

		@@DeactivateLowPriorityEntity:
		; Set Entity as Inactive in our Active Entity List
		; Get the difference between the current entity.current and entity.0
			ex de, hl							; DE -> entity.CURRENT.state
			ld hl, entityList.entity.0.state	; HL -> entity.0.state
			ld a, e
			sub a, l
			ld l, a
			ld a, d
			sbc a, h
			ld h, a
		; Find the state difference
			srl h								; /2
			rr l
			srl h								; /4
			rr l
			srl h								; /8
			rr l
			srl h								; /16
			rr l
			srl h								; /32
			rr l
			srl h								; /64
			rr l
		; Decrease numEntities
			ld de, entityList.numEntities
			ld a, (de)
			dec a
			ld (de), a
		; Find the Position in the bitmap
			xor a
			srl l								; /2
			rra
			srl l								; /4
			rra
			srl l								; /8
			rra
			srl a								; Move over one more time to make the proper nibble
			; L = BYTE, A = BIT
			; or l								; Put em together						
			;swap a								; And put them in the correct order of $BYTE,BIT	
			rlca
			rlca
			rlca
			rlca
			ld de, entityList.bitmap.0
			add hl, de							; HL -> bitmap.currentLocation
			ld b, a
			ld c, ACTIVE_ENTITY_RES_MASK
		; Make the RESET MASK for the bit we want deactivated
			xor a
			cp b
			jr z, +
		-:
			sla c
			dec b
			jr nz, -
		+:
			ld a, c
			cpl
			ld c, a
		; Deactivate the Entity
			ld a, (hl)
			and c
			ld (hl), a
			; end
		ret
	@@DeactivateLowPriorityEntityEnd:


; ==============================================================
;  Removes entity from the Entity List
; ==============================================================
; Parameters: (Coming from @DeactiveEntity)
; Returns: None
; Affects: A, BC, DE, HL
	@@DeactivateHighPriorityEntity:
	; Deactivate Entity
		ld a, INACTIVE_ENTITY
		ld (hl), a
	; Set Entity as Inactive in our Active Entity List
	; Get the difference between the current entity.current and entity.0
		ex de, hl							; DE -> entity.CURRENT.state
		ld hl, entityListHi.entity.0.state	; HL -> entity.0.state
		ld a, e
		sub a, l
		ld l, a
		ld a, d
		sbc a, h
		ld h, a
	; Find the state difference
		srl h								; /2
		rr l
		srl h								; /4
		rr l
		srl h								; /8
		rr l
		srl h								; /16
		rr l
		srl h								; /32
		rr l
		srl h								; /64
		rr l
	; Find the Position in the bitmap
		xor a
		srl l								; /2
		rra
		srl l								; /4
		rra
		srl l								; /8
		rra
		srl a								; Move over one more time to make the proper nibble
		; L = BYTE, A = BIT
		; or l								; Put em together						
		;swap a								; And put them in the correct order of $BYTE,BIT	
		rlca
		rlca
		rlca
		rlca
		ld de, entityListHi.highPriorityEntityBitmap
		add hl, de							; HL -> bitmap.currentLocation
		ld b, a
		ld c, ACTIVE_ENTITY_RES_MASK
	; Make the RESET MASK for the bit we want deactivated
		xor a
		cp b
		jr z, +
	-:
		sla c
		dec b
		jr nz, -
	+:
		ld a, c
		cpl
		ld c, a
	; Deactivate the Entity
		ld a, (hl)
		and c
		ld (hl), a
		ret
	@@DeactivateHighPriorityEntityEnd: