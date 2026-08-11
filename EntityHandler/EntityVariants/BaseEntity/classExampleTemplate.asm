; ================================================================================
;  ClassExampleTemplate
; ================================================================================
; Change the following throughout the entire class
; ClassTemplate: 		Captial letter of the class (ClassExample)
; CLASS_TEMPLATE:		Constant values (CLASS_EXAMPLE)
; classCamelTemplate: 	Lower case letter of the entity (classCamelExample)

; ==============================================================
;  ClassExampleTemplate Skeleton
; ==============================================================
.STRUCT classCamelTemplateStructure
    instanceof entitySkeleton               ; An entity structure framing
    someByte                        db      ; UsedForSomething
	
.ENDST


; ================================================================================
;  Start ClassTemplate Class
; ================================================================================

.SECTION "ClassTemplate Entity Class"
ClassTemplateClass:
; ==============================================================
;  Constants
; ==============================================================
; Init Values
.DEF	SOMETHING					$01


; ==============================================================
;  Updates the ClassTemplate
; ==============================================================
; 
; 
; Parameters: DE = classCamelTemplate.state (Should be coming from EntityList@UpdateEntities)
; Returns: None
; Affects: TBD
	@Update:
    ; Make HL our main pointer for the entity
        ex de, hl									; HL -> classCamelTemplate.state

    ret

; ================================================================================
;  Initialize ClassExampleTemplate
; ================================================================================
; Parameters: 	HL = classCamelTemplate.updateRoutinePointerLo 
;				BC = yPos
; 				IX = xPos
; Affects: A, HL, DE
	@Initialize:
	; Basic Entity Initialization
		; HL ->  classCamelTemplate.updateRoutinePointerLo
		ld de, ClassTemplateClass@Update
		ld a, $FF									; A = Entity Type
		call BaseEntityClass@Initialize				; HL -> classCamelTemplate.cc

		ret


; ================================================================================
;  ClassExampleTemplate Tile Data
; ================================================================================
; Separated by animation cycles
    @Tiles:
    ; ===============================================
    ;   ExampleAnimationCycle0
    ; ===============================================
        @@ExampleAnimationCycle0:
        ; ----------------
        ; Raw Data
        ; ----------------
        ; Raw Data to be loaded into VRAM
            @@@RawData:
                @@@@Frame0:
                .INCLUDE "../"
                @@@@Frame0End:
                @@@@Frame1:
                .INCLUDE "../"
                @@@@Frame1End:
            @@@RawDataEnd:
        ; ----------------
        ; VRAM Indexes
        ; ----------------    
        ; Tile indexes in VRAM to be used by Animation Handler    
            @@@Frame0TileIndexes:
                ; .DB $00, $00, $00, $00
            @@@Frame0TileIndexesEnd:  
            @@@Frame1TileIndexes:
                ; .DB $00, $00, $00, $00
            @@@Frame1TileIndexesEnd:
        @@ExampleAnimationCycle0End:


    ; ===============================================
    ;   ExampleAnimationCycle1
    ; ===============================================
        @@ExampleAnimationCycle1:
        ; ----------------
        ; Raw Data
        ; ----------------
        ; Raw Data to be loaded into VRAM
            @@@RawData:
                @@@@Frame0:
                .INCLUDE "../"
                @@@@Frame0End:
                @@@@Frame1:
                .INCLUDE "../"
                @@@@Frame1End:
            @@@RawDataEnd:
        ; ----------------
        ; VRAM Indexes
        ; ----------------    
        ; Tile indexes in VRAM to be used by Animation Handler    
            @@@Frame0TileIndexes:
                ; .DB $00, $00, $00, $00
            @@@Frame0TileIndexesEnd:  
            @@@Frame1TileIndexes:
                ; .DB $00, $00, $00, $00
            @@@Frame1TileIndexesEnd:
        @@ExampleAnimationCycle0End:

        @@ExampleAnimationCycle1End:


.ENDS