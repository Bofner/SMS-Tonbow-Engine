.SECTION "Bank Switch Handler Constants"
; ================================================================================
;  Everything involving bank switching
; ================================================================================

	.DEFINE     BANK_SWITCH_RAM_MAPPING     $FFFC       ; 7: ROM Write enable
                                                        ; 6: ???
                                                        ; 5: ???
                                                        ; 4: RAM enable ($c000-$ffff)
                                                        ; 3: RAM enable ($8000-$bfff)
                                                        ; 2: RAM bank select
                                                        ; 1: Bank shift (offset) MSb
                                                        ; 0: Bank shift (offset) LSb
	.DEFINE     BANK_SWITCH_ROM_SLOT_0      $FFFD       ; Bank number for address $0000-$3FFF
    .DEFINE     BANK_SWITCH_ROM_SLOT_1      $FFFE       ; Bank number for address $4000-$7FFF
    .DEFINE     BANK_SWITCH_ROM_SLOT_2      $FFFF       ; Bank number for address $8000-$BFFF
.ENDS


.RAMSECTION "Bank Switch Handler Variables" BANK 0 SLOT "RAM_SLOT"
; Current Slot 2 ($8000-$BFFF) bank
	currentBank                 DB      ; The current SWAPABLE_BANK
.ENDS


.SECTION "Bank Switch Handler" ORGA $0028 FORCE
; ================================================================================
; Bank switching. Swaps out the SWAPABLE_BANK for a targetBank
; ================================================================================
; Parameters:   HL -> target bank
;               DE -> currentBank
;               A  = currentBank
; Affects: A, HL, currentBank
HandleBankSwitch:
; Check if SWAPABLE_BANK is already set to the target bank
    cp (hl)
    ret z
; Execute Bank Switch
    ld a, (hl)                  ; A = targetBank
    ld (BANK_SWITCH_ROM_SLOT_2), a
; Update currentBank
    ld (de), a
    ret



TestBankSwitching:

.ENDS