# Tonbow Engine Conventions
This is list of all conventions maintained throughout the Tonbow Engine in order to make code more understandable.


| Item    | Convention | Exceptions |
| -------- | ------- | ------- |
| Labels/Addresses | StartingCapsCamelCase | RAM_JumpToCorrectGameState |
| Constants | ALL_CAPS_WITH_UNDERSCORE | - |
| Variables/RAM | lowerCaseStartingCamelCase | - |

All routines start with following comment:
`````
; ==============================================================
;  Short description of routine
; ==============================================================       
; Parameters:         ; ie) HL = exampleEntity.input, A = SOME_VALUE ---- "None" is also a valid parameter
; Returns:            ; ie )HL -> exampleEntity.output
; Affects:            ; ie) A, BC, DE, HL, temp8Bit
    @RoutineLabel:    ; NOTE: Label could be a Parent Label (ParentLabel:) or a Child Label (@ChildLabel:) 
`````
 
 
