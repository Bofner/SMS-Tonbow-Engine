.SECTION "Entity List Structures"
; ================================================================================
;  Constants for the Entity List and Entity List Structures
; ================================================================================
; Entity List related constants
	.DEF	NOT_IN_LIST						$FF
	.DEF	ENTITY_LIST_MAX_SIZE			$40
	.DEF	ENTITY_SIZE						$40
	.DEF	BIT_COUNTER						8
;	.DEF 	FIRST_ENTITY					entityList.entity.0.eventID
	.DEF	ACTIVE_ENTITY_SEARCH_MASK		%00000001
	.DEF	ACTIVE_ENTITY_BYTE_MASK			%00110000
	.DEF	BYTE_MASK_OFFSET				%00000011
	.DEF	ACTIVE_ENTITY_BIT_MASK			%00000111
	.DEF	ACTIVE_ENTITY_SET_MASK			%00000001
	.DEF	ACTIVE_ENTITY_RES_MASK			%00000001			; Must be CPL'd
	.DEF	ACTIVE_ENTITY_INC_BYTE			%00010000
	.DEF	BITMAP_FULL						$FF
	.DEF	ENTITY_BITMAP_START				$00
	.DEF	ENTITY_BITMAP_START_INDEX		$00
	.DEF	LAST_BITMAP						$04
	.DEF	NEXT_BITMAP						$10

; Initialization constants
	.DEF	PLAYER_ONE_ENTITY				$01
	.DEF	PLAYER_TWO_ENTITY				$02
	.DEF	NOT_PLAYER_ENTITY				$FF

; High Priority entities
	.DEF	HI_ENTITY						$00
	.DEF	LO_ENTITY						$FF
	.DEF	HI_ENTITY_NUMBER_0				$30
	.DEF	HI_ENTITY_MAX					$08

; Entity States
	.DEF	INACTIVE_ENTITY					$EF
	.DEF	DEACTIVATE_ENTITY				$DE
	.DEF	ACTIVATE_SUCCESS				$EF
	.DEF	ACTIVATE_FAILURE				$00

; ==============================================================
;  Entity List's Entity Structure
; ==============================================================
; Used for labeling when debugging so we know when we are at Entity-Specific bytes in the Entity List
	.STRUCT specificStructure
		specific                                db      ; Specific structure 
	.ENDST
; General purpose, full size entity
	.STRUCT entityStructure SIZE $40
		instanceof entitySkeleton
		specific.0 instanceof specificStructure
		specific   instanceof specificStructure $40 - _sizeof_entitySkeleton - 1
	.ENDST

; ==============================================================
;  Active Entity Bitmap
; ==============================================================
	.STRUCT bitmapStructure
		bitmap                      db
	.ENDST

; ==============================================================
;  Entity List
; ==============================================================
	.STRUCT entityListStructure
		numEntities                           	db      ; Number of Entities in the list
		entity.0    INSTANCEOF entityStructure          ; WLA-DX doesn't start enumerating from 0
	; Here are the rest of the Entities 
		entity      INSTANCEOF entityStructure  (ENTITY_LIST_MAX_SIZE - 1)
	; The extra data we need to shuffle to enable sprite flicker and manage our list
		numStartEntities                        db      ; Keep track of how many entities we started with
		currentBitmapLocation                   db      ; Where we are in the Active Entity Bitmap
		; $BitmapNumber,BitPosition    $0-3,0-7
		entitiesUpdated                         db      ; Number of entities we've updated
		bitmap.0                                db      ; WLA-DX doesn't start enumerating from 0
		bitmap      INSTANCEOF bitmapStructure  4       ; Active Entity Bitmap
		firstRenderEntityPointerLo				db
		firstRenderEntityPointerHi				db		; Points to the entity to be rendered first
		firstRenderEntityBitmapKey				db		; Key for the bitmaps $BitmapNumber,BitPosition
		; BYTE = 0, 1, 2, 3
		; BIT  = 0, 1, 2, 3, 4, 5, 6, 7		
		findNewFirstRenderEntityBitmapKeyOffset	db		; Used insetad of currentBitmapLocation when shuffling
	.ENDST

; ==============================================================
;  High Priority Entity List
; ==============================================================
	.STRUCT highPriorityEntityListStructure
		highPriorityEntityBitmap                db      ; Active Entity Bitmap
		entity.0    INSTANCEOF entityStructure          ; WLA-DX doesn't start enumerating from 0
	; Here are the rest of the Entities 
		entity      INSTANCEOF entityStructure  7
	.ENDST

.ENDS

.RAMSECTION "Entity List Data" BANK 0 SLOT "RAM_SLOT" 
; Entity List related data and structures, starting fromt he beginning of WRAM
	entityList 			INSTANCEOF 	entityListStructure					; The list itself
	entityListHi		INSTANCEOF	highPriorityEntityListStructure		; High Priority Entity List
	entity.dummy		INSTANCEOF	entityStructure						; For fail safes
	player1Entity.pointer			dw									; Points at Player 1 Entity in list
	player2Entity.pointer			dw									; Points at Player 2 Entity in list

.ENDS


.SECTION "Entity List Class"
; ==============================================================
;  The list of all active entities
; ==============================================================
; EntityListClass
EntityListClass:

; ==============================================================
;  Initialize Entity List
; ==============================================================
.INCLUDE "../EntityHandler/EntityListClass/initializeEntityList.asm"

; ==============================================================
;  Activate and entity in the Entity List
; ==============================================================
.INCLUDE "../EntityHandler/EntityListClass/activateEntity.asm"

; ==============================================================
;  Deactivate and entity in the Entity List
; ==============================================================
.INCLUDE "../EntityHandler/EntityListClass/deactivateEntity.asm"

; ==============================================================
;  Update all entities in the Entity List
; ==============================================================
.INCLUDE "../EntityHandler/EntityListClass/updateEntities.asm"


EntityListClassEnd:


.ENDS