.SECTION "Structure Definitions"
; ==============================================================
; Standard no parallax screen scroll
; ==============================================================
.STRUCT stdScreenScrollStructure
; Y-coordinate info  
    vel                        db      ; Velocity in subpixels $WHOLELSB,FRAC 
    fracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    pos                        db      ; Scroll position value written to register
.ENDST


; ==============================================================
;  Pointers
; ==============================================================
.STRUCT pointerStructure
    loByte                                  db
    hiByte                                  db
.ENDST

; --------------------------------

.STRUCT addressPointer
    pointer                     dw      ; Used to point to an address in memory
.ENDST


; ==============================================================
;  Linear Feedback Shift Register
; ==============================================================
.STRUCT lfsrStructure
    currentValue	    		db				;  Current value of our LFSR
	tapsBitmap					db				;  Which bits are set as our taps
	sizeFour					db				;  Random numbers 0-3
	sizeEight					db				;  Random numbers 0-7
	sizeSixteen					db				;  Random numbers 0-15
.ENDST

;==============================================================
; Palette structure
;==============================================================
.struct paletteStruct
    color0      db
    color1      db
    color2      db
    color3      db
    color4      db
    color5      db
    color6      db
    color7      db
    color8      db
    color9      db
    colorA      db
    colorB      db
    colorC      db
    colorD      db
    colorE      db
    colorF      db
.endst

.ENDS

