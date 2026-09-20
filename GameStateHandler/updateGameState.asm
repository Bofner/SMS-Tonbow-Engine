.SECTION "Game State Routines"
; ================================================================================
;  Routines involving the Game State
; ================================================================================
; The location of our Current Game State Address must be placed right after our CALL
; The CALL opcode is $CD $NN $NN, where $NN $NN is the address we want, which is 1 byte after $CD
; NOTE, we probably need to take BANK SWITCHING into account for this. 
	.DEFINE		GAME_STATE_RAM_ADDRESS		RAM_JumpToCorrectGameState + 1
	.DEFINE	    INITIAL_GAME_STATE          InitTestRoom  

; ================================================================================
;  Updates the Game State
; ================================================================================
; Parameters: 	HL -> New Game State Address
; Returns: None
; Affects: A, HL, GAME_STATE_RAM_ADDRESS
UpdateGameState:
; Make sure we are in the correct ROM Bank for this new Game State
	ld de, currentBank
	ld a, (de)
	rst HandleBankSwitch
; Point to the address in the CALL opcode in RAM
	ld a, l
	ld (GAME_STATE_RAM_ADDRESS), a
	ld a, h
	ld (GAME_STATE_RAM_ADDRESS + 1), a

	ret


; ================================================================================
;  Holds onto the Current Game State address for temporary Game State changes
; ================================================================================
;  Parameters: None
;  Returns: None
;  Affects: HL, holdGameState
HoldCurrentGameState:
	ld hl, GAME_STATE_RAM_ADDRESS
	ld (holdGameState), hl
	ret



; ================================================================================
;  Initializes GAME_STATE_RAM_ADDRESS to contain our routine to run in RAM
; ================================================================================
;  Parameters: None, Only called once at the beginning of the program
;  Returns: RAM_JumpToCorrectGameState contains the code at address JumpToCorrectGameStateRoutine
;  Affects: A, HL, RAM_JumpToCorrectGameState
GameStateRoutineToRAM:
	;  Copy call
	ld a, (JumpToCorrectGameStateRoutine)		; A = CALL
	ld (RAM_JumpToCorrectGameState), a			; RAM_JumpToCorrectGameState = CALL
	;  Copy Address
	ld hl, INITIAL_GAME_STATE					; HL -> GAME_STATE_RAM_ADDRESS
	ld (RAM_JumpToCorrectGameState + 1), hl		; RAM_JumpToCorrectGameState + 1 = LOBYTE(GAME_STATE_RAM_ADDRESS)
												; RAM_JumpToCorrectGameState + 2 = HIBYTE(GAME_STATE_RAM_ADDRESS) 
	;  Copy return
	ld a, (JumpToCorrectGameStateRoutine + 3)	; A = RET
	ld (RAM_JumpToCorrectGameState + 3), a		; RAM_JumpToCorrectGameState + 3 = RET 

	ret

; ================================================================================
;  Initializes GAME_STATE_RAM_ADDRESS to contain our routine to run in RAM
; ================================================================================
JumpToCorrectGameStateRoutine:
	call INITIAL_GAME_STATE
	ret
JumpToCorrectGameStateRoutineEnd:

.ENDS