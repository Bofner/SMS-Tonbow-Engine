.SECTION "Collidable Entity Structure Definitions"

; ==============================================================
;  Hitbox Structure
; ==============================================================
    .STRUCT hitboxStructure
        columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
        width                       db      ; How far across Hitbox stretches in pixels, if 0, then invincible
        height                      db      ; How far down the Hitbox stretches in pixels
        y1                          db      ; Top left corner of Hitbox yPos
        x1                          db      ; Top left corner of Hitbox xPos
    .ENDST


.ENDS