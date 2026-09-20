.SECTION "Pause Handler"
;  ==============================================================
; Handle the NMI for the Pause Button
;  ==============================================================
PauseHandler:
    nop
    nop
    nop
PauseHandlerEnd:
    ei
    retn
.ENDS