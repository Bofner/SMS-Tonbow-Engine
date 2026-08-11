.SECTION "Game State Routines"
;================================================================================
; Routines involving the Game State
;================================================================================
;The location of our Current Game State Address must be placed right after our CALL
;The CALL opcode is $CD NN NN, where NN NN is the address we want, which is 1 byte after $CD
;NOTE, we probably need to take BANK SWITCHING into account for this. 
.DEF	GAME_STATE_RAM_ADDRESS		RAM_JumpToCorrectGameState + 1
.DEF    INITIAL_GAME_STATE          InitTestRoom  

;Parameters: HL = New Game State Address
;Returns: None
;Affects: A, HL, GAME_STATE_RAM_ADDRESS
UpdateGameState:
;Point to the address in the CALL opcode in HRAM
	ld a, l
	ld (GAME_STATE_RAM_ADDRESS), a
	ld a, h
	ld (GAME_STATE_RAM_ADDRESS + 1), a

	ret

; Parameters: HL = New Game State Address, nextGameStateBank = Address's bank
; MUST RETURN TO FIXED BANK ($00)
; Returns: None
; Affects: A, C, HL, HRAM
/* UpdateGameState:
; Check if the new Game State is in the same Bank
	ld a, (currentROMBank)
	ld b, a										; B = Current ROM Bank
	ld a, ($FF00 + lobyte(nextGameStateBank))	; A = New Game State Bank
	cp b
	jr z, @BanksOkay
	push hl
		call SwitchROMBank
	pop hl
@BanksOkay:
; Point to the address in the CALL opcode in HRAM
	ld c, lobyte(GAME_STATE_HRAM_ADDRESS)
	ld a, ($FF00 + lobyte(nextGameState))
	ld ($FF00+c), a
	inc c
	ld a, ($FF00 + lobyte(nextGameState) + 1)
	ld ($FF00+c), a
	ld a, KEEP_GAME_STATE_FLAG
	ld ($FF00 + lobyte(changeGameStateFlag)), a

	ret
UpdateGameStateEnd:

; Parameters: None
; Returns: None
; Affects: A, C, HL, HRAM
HoldCurrentGameState:
	ld c, lobyte(GAME_STATE_HRAM_ADDRESS)
	ld a, ($FF00+c)
	ld l, a
	inc c
	ld a, ($FF00+c)
	ld h, a
	ld c, lobyte(holdGameState)
	ld a, l
	ld ($FF00+c), a
	inc c
	ld a, h
	ld ($FF00+c), a

	ret
HoldCurrentGameStateEnd: */


;--------------------------------
; Initialization of Game State
;--------------------------------
;Only called once at the beginning of the program
GameStateRoutineToRAM:
	ld de, JumpToCorrectGameStateRoutine
    ld hl, RAM_JumpToCorrectGameState
    ; Copy call
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    ; Copy Address
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    ld a, (de)
    ld (hl), a
    inc hl
    inc de
    ; Copy return
    ld a, (de)
    ld (hl), a
    inc hl
    inc de

	ret

;This is the initial state that our Game State should be in. NOTE: the Game State will change 
JumpToCorrectGameStateRoutine:
	call INITIAL_GAME_STATE
	ret
JumpToCorrectGameStateRoutineEnd:

DummyGameState:

    nop
    nop
    nop

    ret

.ENDS