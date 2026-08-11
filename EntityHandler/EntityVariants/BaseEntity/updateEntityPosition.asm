; ==============================================================
;  Update Position 
; ==============================================================
; Parameters: HL = entity.yVel
; Returns: None
; Affects: TBD
; Convert the xFracPos and yFracPos into xPos and yPos
	@UpdateEntityPosition:
	; Use velocity to update the yPosition
		ld a, (hl)						; A = yVel
		inc hl							; HL -> yFracPos
		ld b, a							; B = yVel
		ld a, (hl)						; A = yFracPos
		ld c, a							; C = prevYFracPos
		add a, b						; A = newYFracPos
		ld (hl), a						; Updated yFracPos
	; Check if we need to carry into the MSB
	; Find out if it was a negative or positive carry
		bit 7, b
		jr nz, +
		call c, @@HandleCarry
		jr ++
	+:
		call nc, @@HandleCarry@NegativeCarry
	++:
		call @@ConvertNFracPosToNPos
	; Use velocity to update the xPosition
		; HL -> entity.xVel
		ld a, (hl)						; A = xVel
		inc hl							; HL -> xFracPos
		ld b, a							; B = xVel
		ld a, (hl)						; A = xFracPos
		ld c, a							; C = prevXFracPos
		add a, b						; A = newXFracPos
		ld (hl), a						; XFracPos updated
	; Check if we need to carry into the MSB
	; Find out if it was a negative or positive carry
		bit 7, b
		jr nz, +
		call c, @@HandleCarry
		jr ++
	+:
		call nc, @@HandleCarry@NegativeCarry
	++:
		call @@ConvertNFracPosToNPos

		ret

		; Parameters: A = (entity.nVel), HL = entity.nFracPosLo
		@@HandleCarry:		
			@@@PositiveCarry:
			; Carry was positive, so add value to Whole.MSB
				inc hl						; HL -> entity.nFracPos.MSB(Hi)
			; Carry into MSB without affecting the UNUSED bits
				ld a, (hl)
				inc a
				and $0F
				ld (hl), a					; Update Whole.MSB	
				dec hl						; HL -> entity.nFracPos.LSB(Lo)						
				; end	
			ret
			@@@NegativeCarry:
			; Carry was negative, so subtract value from the MSB
				inc hl						; HL -> entity.nFracPos.MSB(Hi)
			; Carry into MSB without affecting the UNUSED bits
				ld a, (hl)
				dec a

				ld (hl), a					; Update Whole.MSB
				dec hl						; HL -> entity.nFracPos.LSB(Li)
				; end	
			ret


		; Parameters: HL = entity.nFracPosLo
		@@ConvertNFracPosToNPos:
		; Converts the fractional WORD into a whole BYTE
			ld a, (hl)						; A = $LSB,FRAC
			inc hl							; HL -> entity.nFracPosHi
			and $F0							; A = $LSB,0
			ld b, a							; B = $LSB,0
			ld a, (hl)						; A = $0,MSB
			inc hl							; HL -> entity.nPos
			or b							; A = $LSB,MSB
			; swap a						
			rlca
			rlca
			rlca
			rlca							; A = $WHOLE.MSB,WHOLE.LSB
			ld (hl), a						
			inc hl							; HL -> entity.xVel/specific.0

			ret

    @UpdateEntityPositionEnd: