; ================================================================================
;  Class Template
; ================================================================================
; Change the following throughout the entire class
; Class Template:       Used in description using a space (Class Example)
; ClassTemplate: 		Captial letter of the class (ClassExample)
; CLASS_TEMPLATE:		Constant values (CLASS_EXAMPLE)
; classCamelTemplate: 	Lower case letter of the entity (classCamelExample)

.SECTION "Class Template Constants and Structures"
; ==============================================================
;  ClassTemplate Constants
; ==============================================================
; Init Values
    .DEFINE     CLASS_TEMPLATE_BANK     $00     ; The ROM Bank where the Class lives 

; VRAM Absolute Data
	.DEFINE     CLASS_TEMPLATE_VRAM     $8000   ; The absolute VRAM location where the
                                                ; Entity's graphical data typically lives
                                                ; (This may have to be different in some
                                                ; instances where there are many common
                                                ; and level-specific entities present)

; ==============================================================
;  Class Template Structure
; ==============================================================
    .STRUCT classCamelTemplateStructure
        INSTANCEOF entitySkeleton               ; An entity structure framing
    ; ---------------------------------------------------------------------------------------------------
	; Unique Entity traits down here 
        frameAddressLo                  DB      ; \
        frameAddressHi                  DB      ; / Address of the frame to be rendered
        frameTimer                      DB      ; Time until we move to the next frame
        frameAddressOffset              DB      ; Finding the new address in the animation table(s)
        
    .ENDST
.ENDS

.SECTION "Class Template Entity Class" APPENDTO "Class Template Constants and Structures"
; ================================================================================
;  Class Template
; ================================================================================
; The Class Template Class
ClassTemplateClass:
; ==============================================================
;  Updates the ClassTemplate
; ==============================================================
; Parameters: HL -> classCamelTemplate.currentState (Should be coming from EntityList@UpdateEntities)
; Returns: None
; Affects: TBD
	@Update:

    ret

; ================================================================================
;  Initializes Class Template
; ================================================================================
; Parameters: 	HL -> classCamelTemplate.updateRoutinePointerLo 
;				IY = yFracPos
; 				IX = xFracPos
; Affects: A, HL, DE
	@Initialize:
	; Basic Entity Initialization
		; HL ->  classCamelTemplate.updateRoutinePointerLo
		ld de, ClassTemplateClass@Update
        ld b, CLASS_TEMPLATE_BANK                   ; B = Class Bank
		ld a, $FF									; A = Entity Type
		call BaseEntityClass@Initialize				; HL -> classCamelTemplate.cc

		ret


; ==============================================================
;  Updates ClassTemplate sprite and writes to SATBuffer
; ==============================================================
ClassTemplateTiles:
    .INCLUDE "CommonEntities/ClassTemplate/buildClassTemplateMetasprite.asm"
ClassTemplateTilesEnd:

; ================================================================================
;  ClassTemplate Tile Data
; ================================================================================

; Separated by animation cycles
    @Tiles:
    ; ===============================================
    ;   FrameData
    ; ===============================================
        @@FrameData:
        ; ----------------
        ; Raw Data
        ; ----------------
        ; Raw Data to be loaded into VRAM
            @@@RawData:
                @@@@RawDataFrame0:
                    .INCLUDE "Assets/TestRoom/Sprites/FrameData/frame0Tiles.inc"
                @@@@RawDataFrame1:
                    .INCLUDE "Assets/TestRoom/Sprites/FrameData/frame1Tiles.inc"
            @@@RawDataEnd:


.ENDS