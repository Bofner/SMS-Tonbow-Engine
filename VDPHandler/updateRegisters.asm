.SECTION "VDP Register Constants"
; Hardware Constants
    .DEFINE     PORT_VDP_ADDRESS    $BF 
    .DEFINE     VDP_DATA            $BE
; Registers
    .DEFINE     REGISTER_0          $80
    .DEFINE     REGISTER_1          $81
    .DEFINE     REGISTER_2          $82
    .DEFINE     REGISTER_3          $83
    .DEFINE     REGISTER_4          $84
    .DEFINE     REGISTER_5          $85
    .DEFINE     REGISTER_6          $86
    .DEFINE     REGISTER_7          $87
    .DEFINE     REGISTER_8          $88
    .DEFINE     REGISTER_9          $89
    .DEFINE     REGISTER_10         $8A
    .DEFINE     REGISTER_11         $8B
.ENDS

.SECTION "Update VDP Registers" APPENDTO "VDP Register Constants"
; Initialization parameters for the 11 registers on SMS
VDPInitDataSMS:
    .DB %00010110       ; Register 0
                        ; b7: Vertical Scroll Inhibit
                        ; b6: Horizontal Scroll Inhibit
                        ; b5: Left Column Blank
                        ; b4: Enable Interrupts
                        ; b3: Sprite Shift
                        ; b2: Always 1
                        ; b1: Always 1 
                        ; b0: External Sync (Always 0)

    .DB %10100000       ; Register 1
                        ; b7: ????
                        ; b6: Enable display
                        ; b5: VBlank interrupts
                        ; b4: 224 line mode
                        ; b3: 240 line mode
                        ; b2: Mega Drive mode 5 enable
                        ; b1: 8x16 Sprites
                        ; b0: Low Res, 16x16 Sprites 

    .DB $FF             ; Register 2
                        ; Name table at $3800

    .DB $FF             ; Register 3
                        ; Always set to $FF

    .DB $FF             ; Register 4
                        ; Always set to $FF

    .DB $FF             ; Register 5 
                        ; Address for SAT, 
                        ; $FF = SAT at $3F00 

    .DB $FB             ; Register 6
                        ; Base address for sprite patterns
                        ; $FB -> First half of VRAM
                        ; $FF -> Second half of VRAM

    .DB $F0             ; Register 7
                        ; Overrscan Color at Sprite Palette 1  

    .DB $00             ; Register 8
                        ; Horizontal Scroll

    .DB $00             ; Register 9
                        ; Vertical Scroll

    .DB $FF             ; Register 10 ($0A)
                        ; Raster line interrupt off 
VDPInitDataSMSEnd:

; ================================================================================
; Sets one or more VDP Registers (Each one contains a byte)
; ================================================================================
; Parameters:   HL = data address
;               B = # of registers to update 
;               C = Which VDP regiseter $8(register#)
; Affects: A, B, C, HL
SetVDPRegisters:
-:  
    ld a,(hl)                            ; load one byte of data into A.
    out (PORT_VDP_ADDRESS),a             ; output data to VDP command port.
    ld a,c                               ; load the command byte.
    out (PORT_VDP_ADDRESS),a             ; output it to the VDP command port.
    inc hl                               ; inc. pointer to next byte of data.
    inc c                                ; inc. command byte to next register.
    djnz -                               ; jump back to '-' if b > 0.   
    ret


; ================================================================================
; Updates a single VDP Register 
; ================================================================================
; Parameters:   A = register data (one byte)
;               C = Which VDP regiseter $8(register#)
; Affects: A, C, B
UpdateVDPRegister:
    out (PORT_VDP_ADDRESS), a                 ; Load data into CDP
    ld a, c
    out (PORT_VDP_ADDRESS), a                 ; Tell it which register to put it to
    ret


; ================================================================================
; Disables the display
; ================================================================================
; Parameters: None
; Affects: A, B, C, HL
BlankScreen:
    ld a, %00100000
                        ; Reg 1
                        ; b7: ????
                        ; b6: Enable display
                        ; b5: VBlank interrupts
                        ; b4: 224 line mode
                        ; b3: 240 line mode
                        ; b2: Mega Drive mode 5 enable
                        ; b1: 8x16 Sprites
                        ; b0: Low Res, 16x16 Sprites 
    ld c, $81
    call UpdateVDPRegister
    ret

.ENDS