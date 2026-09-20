; ==============================================================
;  Column Structure
; ==============================================================
.STRUCT columnStructure
    xPos                                    DB      ; Column position
    width                                   DB      ; Width of the Column
    activePointersBitmap                    DB      ; Bitmap of active pointers
    entity.atkHitboxPointer.0               DW      ; 0th pointer to entity atkHitbox
    entity.atkHitboxPointer INSTANCEOF pointerStructure 7

.ENDST

; ==============================================================
;  Overflow Column Structure
; ==============================================================
.STRUCT overflowColumnStructure
    numEntities                             DB      ; Number of entities in the Column
    activePointersBitmap.0                  DB      ; Bitmap of active pointers
    activePointersBitmap.1                  DB      ; Bitmap of active pointers
    activePointersBitmap.2                  DB      ; Bitmap of active pointers
    activePointersBitmap.3                  DB      ; Bitmap of active pointers
    entity.atkHitboxPointer.0               DW      ; 0th pointer to entity atkHitbox
    entity.atkHitboxPointer INSTANCEOF pointerStructure 31

.ENDST