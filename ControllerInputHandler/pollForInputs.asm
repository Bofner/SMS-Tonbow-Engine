.SECTION "Controller Input Handler Constants and Structure"
; ================================================================================
;  Controller Input Handler Class Structs and Constants
; ================================================================================
; Controller Input Handler Ports
    .DEFINE 	JOYSTICK_PORT_A					$DC
    .DEFINE 	JOYSTICK_PORT_B					$DD
    .DEFINE 	JOYSTICK_PORT_CONTROL			$3F
    .DEFINE 	GUN_SPOT_VERTICAL				$7E
    .DEFINE 	GUN_SPOT_HORIZONTAL				$7F

; MD Config
; 7	Port B TH pin output level      (1=high, 0=low)
; 6	Port B TR pin output level      (1=high, 0=low)
; 5	Port A TH pin output level      (1=high, 0=low)
; 4	Port A TR pin output level      (1=high, 0=low)
; 3	Port B TH pin direction         (1=input, 0=output)
; 2	Port B TR pin direction         (1=input, 0=output)
; 1	Port A TH pin direction         (1=input, 0=output)
; 0	Port A TR pin direction         (1=input, 0=output)

    .DEFINE     SET_TH_LO_PORT_A                %00001101
    .DEFINE     SET_TH_LO_PORT_B                %00000111
    .DEFINE     SET_TH_HI                       %00101101

    ; Controller bit manipulation masks
    .DEFINE     FLIP_CONTROLLER_BITS            $FF
    .DEFINE     PLAYER_1_PORT_A                 %00111111
    .DEFINE     JOYSTICK_PORT_A_START           %00100000
    .DEFINE     PLAYER_2_PORT_A                 %11000000
    .DEFINE     PLAYER_2_PORT_B                 %00001111
    .DEFINE     JOYSTICK_PORT_B_START           %00001000
    .DEFINE     MD_PAD_START_TRIGGER            $2C

; ==============================================================
;  Controller Input Handler Structure
; ==============================================================
    .STRUCT controllerInputHandlerStructure
    ; Inputs are saved as %-S21RLDU
        playerOneInput                      DB      ; Inputs from Player 1
        playerTwoInput                      DB      ; Inputs from Player 2
    .ENDST

.ENDS

.RAMSECTION "Controller Input Handler Data" BANK 0 SLOT "RAM_SLOT" 
; Neccessary variables for keeping track of player inputs
	controllerInputHandler 			INSTANCEOF 	controllerInputHandlerStructure					; The list itself
.ENDS


.SECTION "Controller Input Handler" APPENDTO "Controller Input Handler Constants and Structure"
; ================================================================================
;  Controller Input Handler
; ================================================================================
; Handles anything to do with getting input from the controller ports
ControllerInputHandlerClass:
; ==============================================================
;  Checks for controller inputs
; ==============================================================
; Parameters:   None
; Returns:      Updates controllerInputHandler.playerOneInput 
;               and controllerInputHandler.playerTwoInput
; Affects: A, B, HL
    @PollForInputs:
    ; Clear inputs
        xor a 
        ld (controllerInputHandler.playerOneInput), a
        ld (controllerInputHandler.playerTwoInput), a
        ld hl, controllerInputHandler.playerOneInput    ; HL -> controllerInputHandler.playerOneInput

    ; Check for MD Start Button press and add to Player 1 Input
        ld a, SET_TH_LO_PORT_A
        out (JOYSTICK_PORT_CONTROL), a                  ; Sets TH LO to pole for MD START  
        nop
        nop                                             ; Waits for the port to update        
        in a, (JOYSTICK_PORT_A)
        xor FLIP_CONTROLLER_BITS                        ; Inputs become 1's
        cp MD_PAD_START_TRIGGER                         ; Safety b/c SMS pad and MD work differently
        jr nz, +
        and JOYSTICK_PORT_A_START                       ; Remove everything except MD START
        rlca                                            ; Move START bit left
        ld (hl), a                                      ; playerOneInput = %-S------
    +:
    ; Poll Port A
        ld a, SET_TH_HI
        out (JOYSTICK_PORT_CONTROL), a                  ; Sets TH HI to pole for SMS Inputs  
        nop
        nop                                             ; Waits for the port to update        
        in a, (JOYSTICK_PORT_A)                         
        xor FLIP_CONTROLLER_BITS                        ; Inputs become 1's
        ld c, a                                         ; C = %DU??????
        and PLAYER_1_PORT_A                             ; Remove P2's inputs
        ld b, (hl)                                      ; B = %-S------
        or b                                            ; A = %-S21RLDU
        ld (hl), a                                      ; Update P1 Inputs
    
    ; Poll Port B START
        inc hl                                          ; HL -> controllerInputHandler.playerTwoInput
    ; Check for MD Start Button press and add to Player 2 Input
        ld a, SET_TH_LO_PORT_B
        out (JOYSTICK_PORT_CONTROL), a                  ; Sets TH LO to pole for MD START  
        nop
        nop                                             ; Waits for the port to update        
        in a, (JOYSTICK_PORT_B)
        xor FLIP_CONTROLLER_BITS                        ; Inputs become 1's
        and JOYSTICK_PORT_B_START                       ; Remove everything except MD START
        rlca                                            
        rlca
        rlca                                            ; Move START bit left
        ld (hl), a                                      ; playerTwoInput = %-S------
    ; Get the input for Joystick Port 2
        ld a, PLAYER_2_PORT_A                           ; Start by removing P1 inputs
        and c                                           ; A = %DU------
        ld c, a                                         ; C = %DU------
        rlc c
        rlc c                                           ; C = %------DU
        ld a, SET_TH_HI
        out (JOYSTICK_PORT_CONTROL), a                  ; Sets TH HI to pole for SMS Inputs  
        nop
        nop                                             ; Waits for the port to update        
        in a, (JOYSTICK_PORT_B)                         ; A = %----21RL
        xor FLIP_CONTROLLER_BITS                        ; Inputs become 1's
        rlca
        rlca                                            ; A = %--21RL--
        or c                                            ; A = %--21RLDU
        ld b, (hl)
        or b                                            ; A = %-S21RLDU
        ld (hl), a                                      ; Update P2 Inputs

        ret

ControllerInputHandlerClassEnd:


.ENDS