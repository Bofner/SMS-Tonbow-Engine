# SMS-Tonbow-Engine

The official Steelfinger Studios engine for creating Master System games in Z80 assembly.

The purpose of the SMS Tonbow Engine is for getting a Sega Master System assembly game up and running faster than starting from scratch. It is best thought of as an example template. It has many starter files that should be used to keep structure consistent throughout a project. It also has several commented out sections for alternate settings and handling, such as the ROM size and memory layout. 

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

## How to use

### Comments
You will likely need to read through and understand each component of the Tonbow Engine in order to actually build anything from this, which is why I have included verbose comments around every corner to clue the reader into what is supposed to be happening at both a high level, and a low level. Comments such as:

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
are meant to be useful when debugging by allowing the programmer to see what value, for instance, HL is *supposed* to be pointing at, while they can check in the debugger what value HL is *actually* pointing at. 

### Structure

The Tonbow Engine was designed to make reading through assembly code as painless as possible. Large concepts are broken into many folders and subfolders with files never taking up more space than they need to. There's nothing worse than forgetting where a certain subroutine lives, so folders are treated like individual components of the Engine, and depending on the size and scope, routines are often broken down across several files living within the same Class folder. 

### Helpful tools

- SMS/GG Graphics Exporter: https://steelfinger-studios.itch.io/master-system-game-gear-graphics-exporter-for-aseprite
- Emulicious: https://emulicious.net/
- Furnace Tracker: https://tildearrow.org/furnace/

## TODO

This is still a work-in-progress, so there's still a lot to get done, but it will all be worth it. 
- Fade to black
- Fade in
- Collision handling
- Compression
- Animation Handling
- Decompression
- Example Splash Screen
- Test Room (Example controllable screen)
