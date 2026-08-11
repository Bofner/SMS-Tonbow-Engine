; ================================================================================
;  Base Entity Class
; ================================================================================
; Any routines that can be shared by any entity, no matter the sub-class

; ================================================================================
;  Base Entity Class Structs
; ================================================================================
; Entity States
.DEF	INITIALIZED					$01

; ==============================================================
;  Entity Skeleton
; ==============================================================
.STRUCT entitySkeleton
; General Entity info (13 Bytes)
	; updateRoutinePointer      dw      ; A Pointer to the Entity's Update Subroutine
	updateRoutinePointerLo		db		; \ Pointer split into HI and LO for convenience
	updateRoutinePointerHi		db		; /
	state                       db      ; Current condition of Entity. DEAD, AI_1, DYING, SPAWING etc.
	type                        db      ; Projectile, Player, Enemy etc.
	timer                       db      ; Basic all-purpose timer. Animation, AI routine
; Y-coordinate info  
	yVel                        db      ; Velocity %0YYYFFFF 
	yFracPosLo                	db      ; \ Fractional position $UNUSED.MSB,WHOLE.MSB $WHOLE.LSB,FRAC.LSB
	yFracPosHi					db		; /
	yPos                        db      ; The Y coord of the Entity's top left corner.
; X-coordinate info  
	xVel                        db      ; Velocity %0XXXFFFF 
	xFracPosLo                	db      ; \ Fractional position $UNUSED.MSB,WHOLE.MSB $WHOLE.LSB,FRAC.LSB
	xFracPosHi					db		; /
	xPos                        db      ; The X coord of the Entity's top left corner. 
; ---------------------------------------------------------------------------------------------------
; Unique Entity traits down here 
	
.ENDST


.SECTION "Base Entity"
BaseEntityClass:

; ================================================================================
;  Initialize Entity
; ================================================================================
.INCLUDE "../EntityHandler/EntityVariants/BaseEntity/initializeEntity.asm"

; ================================================================================
;  Update Entity Position
; ================================================================================
.INCLUDE "../EntityHandler/EntityVariants/BaseEntity/updateEntityPosition.asm"

BaseEntityClassEnd:


.ENDS