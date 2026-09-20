; ==============================================================
;  Initializes the Entity
; ==============================================================
; Parameters:  	HL = entity.updateRoutinePointerLo 
; 			  	DE = EntityClass@UpdateEntity
; 				IY = INITIAL_Y_FRAC_POS
; 				IX = INITIAL_X_FRAC_POS
;               B  = BANK
;               A  = TYPE
; Returns: HL -> entity.specific.0
; Affects: A, HL, DE, BC, IX
; EntityListClass 
@Initialize:
; Initialize our General Entity's properties
	; HL -> entity.updateRoutinePointerLo									
	ld (hl), e
    inc hl                          ; HL -> entity.updateRoutinePointerHi	
	ld (hl), d						; Updated entityUpdateRoutinePointer
    inc hl                          ; HL -> entity.classBank
    ld (hl), b                      ; entity.classBank = BANK
    inc hl                          ; HL -> entity.state			
	ld (hl), INITIALIZED            ; entity.state = INITIALIZED
    inc hl                          ; HL -> entity.prevState
    ld (hl), INITIALIZED            ; entity.prevState = INITIALIZED
	inc hl                          ; HL -> entity.type
    ld (hl), a                      ; Updated entity.type
    inc hl                          ; HL -> entity.timer
    xor a                           ; A = 0
    ld (hl), a                      ; Updated entity.timer
    inc hl                          ; HL -> entity.yVel
    ld (hl), a                      ; Updated entity.yVel
    inc hl                          ; HL -> entity.yFracPosLo
    ld a, iyl
    ld (hl), a
    inc hl                          ; HL -> entity.yFracPosHi
    ld a, iyh
    ld (hl), a                      ; Updated entity.yFracPos
    xor a                           ; A = 0
    inc hl                          ; HL -> entity.yPos
    ld (hl), a                      ; Updated entity.yPos
    inc hl                          ; HL -> entity.xVel
    ld (hl), a                      ; Updated entity.xVel
    inc hl                          ; HL -> entity.xFracPosLo
    ld a, ixl
    ld (hl), a
    inc hl                          ; HL -> entity.xFracPosHi
    ld a, ixh
    ld (hl), a                      ; Updated entity.xFracPos
    inc hl                          ; HL -> entity.xPos
    ld (hl), $00                    ; Updated entity.xPos
    inc hl                          ; HL -> entity.specific.0	

	ret