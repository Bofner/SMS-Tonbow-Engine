.SECTION "Collidable Entity Structure Definitions"
; ==============================================================
;  Hitbox Structure
; ==============================================================
    .STRUCT hitboxStructure
        columnsBitmap               DB      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
        width                       DB      ; How far across Hitbox stretches in pixels, if 0, then invincible
        height                      DB      ; How far down the Hitbox stretches in pixels
        y1                          DB      ; Top left corner of Hitbox yPos
        x1                          DB      ; Top left corner of Hitbox xPos
    .ENDST


.ENDS