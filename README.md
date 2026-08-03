# SMS-Tonbow-Engine
The official Steelfinger Studios engine for creating Master System games in Z80 assembly.

## Features
- Background graphics support
- Sprite handling
  - Flicker
  - Metasprites
- Entity handling
  - High priority entities
  - Low priority entities
- Game State Handling
- Controller Handling
  - MD Start button support

## Description
This is a basic engine for getting a game up and running faster than starting from scratch. It is best thought of as an example template. It has many starter files that should be used to keep structure consistent throughout a project. It also has several commented out sections for alternative settings and handling, such as the ROM size and memory layout. 

You will likely need to read through and understand the systems in play in order to actually build anything from this, which is why I have included verbose comments around every corner to clue the reader into what is supposed to be happening at both a high level, and a low level. Comments such as:

`````
; ==============================================================
;  Updates the TestRoomTonbow
; ==============================================================
; Parameters: HL = testRoomTonbow.state (Should be coming from EntityList@UpdateEntities)
; Returns: None
; Affects: A, BC, DE, HL
	@Update:
	; Choose what to do based off state
		ld a, DEACTIVATE_ENTITY
		cp (hl)
		jr z, @Deactivate
		
	; Update Position
		ld de, testRoomTonbowStruct.yVel - testRoomTonbowStruct.state
		add hl, de									; HL -> testRoomTonbowStruct.yVel
    call BaseEntityClass@UpdateEntityPosition	; HL -> testRoomTonbowStruct.cc
`````
are meant to be useful when debugging by allowing the programmer to see what value HL is supposed to be pointing at, while they can check in the debugger what value HL is actually pointing at. 


## TODO
- Fade to black
- Fade in
- Collision handling
- Compression
- Animation Handling
- Decompression
- Example Splash Screen
- Test Room (Example controllable screen)
