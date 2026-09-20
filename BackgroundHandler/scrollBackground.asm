; ==============================================================
; Standard no parallax screen scroll
; ==============================================================
.STRUCT stdScreenScrollStructure
; Y-coordinate info  
    vel                        DB      ; Velocity in subpixels $WHOLELSB,FRAC 
    fracPos                    DW      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    pos                        DB      ; Scroll position value written to register
.ENDST