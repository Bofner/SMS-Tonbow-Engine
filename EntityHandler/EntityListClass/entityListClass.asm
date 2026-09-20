.SECTION "Entity List Structures Class Constants and Structures"
; ================================================================================
;  Constants for the Entity List and Entity List Structures
; ================================================================================
; Entity List related constants
	.DEFINE		NOT_IN_LIST						$FF
	.DEFINE		ENTITY_LIST_MAX_SIZE			$40
	.DEFINE		ENTITY_SIZE						$40
	.DEFINE		BIT_COUNTER						8
;	.DEFINE	 	FIRST_ENTITY					entityList.entity.0.eventID
	.DEFINE		ACTIVE_ENTITY_SEARCH_MASK		%00000001
	.DEFINE		ACTIVE_ENTITY_BYTE_MASK			%00110000
	.DEFINE		BYTE_MASK_OFFSET				%00000011
	.DEFINE		ACTIVE_ENTITY_BIT_MASK			%00000111
	.DEFINE		ACTIVE_ENTITY_SET_MASK			%00000001
	.DEFINE		ACTIVE_ENTITY_RES_MASK			%00000001			; Must be CPL'd
	.DEFINE		ACTIVE_ENTITY_INC_BYTE			%00010000
	.DEFINE		BITMAP_FULL						$FF
	.DEFINE		ENTITY_BITMAP_START				$00
	.DEFINE		ENTITY_BITMAP_START_INDEX		$00
	.DEFINE		LAST_BITMAP						$04
	.DEFINE		NEXT_BITMAP						$10

; Initialization constants
	.DEFINE		PLAYER_ONE_ENTITY				$01
	.DEFINE		PLAYER_TWO_ENTITY				$02
	.DEFINE		NOT_PLAYER_ENTITY				$FF

; High Priority entities
	.DEFINE		HI_ENTITY						$00
	.DEFINE		LO_ENTITY						$FF
	.DEFINE		HI_ENTITY_NUMBER_0				$30
	.DEFINE		HI_ENTITY_MAX					$08

; Entity States
	.DEFINE		INACTIVE_ENTITY					$EF
	.DEFINE		DEACTIVATE_ENTITY				$DE
	.DEFINE		ACTIVATE_SUCCESS				$EF
	.DEFINE		ACTIVATE_FAILURE				$00

; ==============================================================
;  Entity List's Entity Structure
; ==============================================================
; Used for labeling when debugging so we know when we are at Entity-Specific bytes in the Entity List
	.STRUCT specificStructure
		specific                                DB      ; Specific structure 
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
		bitmap                      			DB
	.ENDST

; ==============================================================
;  Entity List
; ==============================================================
	.STRUCT entityListStructure
		numEntities                           	DB      ; Number of Entities in the list
		entity.0    INSTANCEOF entityStructure          ; WLA-DX doesn't start enumerating from 0
	; Here are the rest of the Entities 
		entity      INSTANCEOF entityStructure  (ENTITY_LIST_MAX_SIZE - 1)
	; The extra data we need to shuffle to enable sprite flicker and manage our list
		numStartEntities                        DB      ; Keep track of how many entities we started with
		currentBitmapLocation                   DB      ; Where we are in the Active Entity Bitmap
		; $BitmapNumber,BitPosition    $0-3,0-7
		entitiesUpdated                         DB      ; Number of entities we've updated
		bitmap.0                                DB      ; WLA-DX doesn't start enumerating from 0
		bitmap      INSTANCEOF bitmapStructure  4       ; Active Entity Bitmap
		firstRenderEntityPointerLo				DB
		firstRenderEntityPointerHi				DB		; Points to the entity to be rendered first
		firstRenderEntityBitmapKey				DB		; Key for the bitmaps $BitmapNumber,BitPosition
		; BYTE = 0, 1, 2, 3
		; BIT  = 0, 1, 2, 3, 4, 5, 6, 7		
		findNewFirstRenderEntityBitmapKeyOffset	DB		; Used insetad of currentBitmapLocation when shuffling
	.ENDST

; ==============================================================
;  High Priority Entity List
; ==============================================================
	.STRUCT highPriorityEntityListStructure
		highPriorityEntityBitmap                DB      ; Active Entity Bitmap
		entity.0    	INSTANCEOF entityStructure      ; WLA-DX doesn't start enumerating from 0
	; Here are the rest of the Entities 
		entity      	INSTANCEOF entityStructure  7
	.ENDST

.ENDS

.RAMSECTION "Entity List Data" BANK 0 SLOT "RAM_SLOT" 
; Entity List related data and structures, starting fromt he beginning of WRAM
	entityList 			INSTANCEOF 	entityListStructure					; The list itself
	entityListHi		INSTANCEOF	highPriorityEntityListStructure		; High Priority Entity List
	entity.dummy		INSTANCEOF	entityStructure						; For fail safes
	player1Entity.pointer						DW						; Points at Player 1 Entity in list
	player2Entity.pointer						DW						; Points at Player 2 Entity in list
.ENDS


.SECTION "Entity List Class" APPENDTO "Entity List Structures Class Constants and Structures"
; ==============================================================
;  The list of all active entities
; ==============================================================
; EntityListClass
EntityListClass:

; ==============================================================
;  Initialize Entity List
; ==============================================================
.INCLUDE "EntityHandler/EntityListClass/initializeEntityList.asm"

; ==============================================================
;  Activate and entity in the Entity List
; ==============================================================
.INCLUDE "EntityHandler/EntityListClass/activateEntity.asm"

; ==============================================================
;  Deactivate and entity in the Entity List
; ==============================================================
.INCLUDE "EntityHandler/EntityListClass/deactivateEntity.asm"

; ==============================================================
;  Update all entities in the Entity List
; ==============================================================
.INCLUDE "EntityHandler/EntityListClass/updateEntities.asm"


EntityListClassEnd:


.ENDS