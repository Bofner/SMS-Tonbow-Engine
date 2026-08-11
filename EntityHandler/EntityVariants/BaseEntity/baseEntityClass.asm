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
	updateRoutinePointerLo		DB		; \ Pointer split into HI and LO for convenience
	updateRoutinePointerHi		DB		; /
	state                       DB      ; Current condition of Entity. DEAD, AI_1, DYING, SPAWING etc.
	prevState					DB		; State of entity on the previous frame
	type                        DB      ; Projectile, Player, Enemy etc.
	timer                       DB      ; Basic all-purpose timer. Animation, AI routine
; Y-coordinate info  
	yVel                        DB      ; Velocity %0YYYFFFF 
	yFracPosLo                	DB      ; \ Fractional position $UNUSED.MSB,WHOLE.MSB $WHOLE.LSB,FRAC.LSB
	yFracPosHi					DB		; /
	yPos                        DB      ; The Y coord of the Entity's top left corner.
; X-coordinate info  
	xVel                        DB      ; Velocity %0XXXFFFF 
	xFracPosLo                	DB      ; \ Fractional position $UNUSED.MSB,WHOLE.MSB $WHOLE.LSB,FRAC.LSB
	xFracPosHi					DB		; /
	xPos                        DB      ; The X coord of the Entity's top left corner. 
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