;Sets one or more VDP Registers (Each one contains a byte)
;Parameters: HL = data address, B = # of registers to update 
;            C = Which VDP regiseter $8(register#)
;Affects: A, B, C, HL
SetVDPRegisters:
-:  ld a,(hl)                            ; load one byte of data into A.
    out (PORT_VDP_ADDRESS),a                   ; output data to VDP command port.
    ld a,c                               ; load the command byte.
    out (PORT_VDP_ADDRESS),a                   ; output it to the VDP command port.
    inc hl                               ; inc. pointer to next byte of data.
    inc c                                ; inc. command byte to next register.
    djnz -                               ; jump back to '-' if b > 0.   
    ret

;================================================================================


;Updates a single VDP Register 
;Parameters: A = register data (one byte) C = Which VDP regiseter $8(register#)
;Affects: A, C, B
UpdateVDPRegister:
    out (PORT_VDP_ADDRESS), a                 ;Load data into CDP
    ld a, c
    out (PORT_VDP_ADDRESS), a                 ;Tell it which register to put it to
    ret