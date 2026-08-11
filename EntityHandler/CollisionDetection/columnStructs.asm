; ==============================================================
;  Column Structure
; ==============================================================
.STRUCT columnStructure
    xPos                                    db      ; Column position
    width                                   db      ; Width of the Column
    activePointersBitmap                    db      ; Bitmap of active pointers
    entity.atkHitboxPointer.0               dw      ; 0th pointer to entity atkHitbox
    entity.atkHitboxPointer INSTANCEOF pointerStructure 7

.ENDST
; ==============================================================
;  Overflow Column Structure
; ==============================================================
.STRUCT overflowColumnStructure
    numEntities                             db      ; Number of entities in the Column
    activePointersBitmap.0                  db      ; Bitmap of active pointers
    activePointersBitmap.1                  db      ; Bitmap of active pointers
    activePointersBitmap.2                  db      ; Bitmap of active pointers
    activePointersBitmap.3                  db      ; Bitmap of active pointers
    entity.atkHitboxPointer.0               dw      ; 0th pointer to entity atkHitbox
    entity.atkHitboxPointer INSTANCEOF pointerStructure 31

.ENDST