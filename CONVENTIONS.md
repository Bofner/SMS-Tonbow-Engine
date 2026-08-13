# Tonbow Engine Conventions
This is list of all conventions maintained throughout the Tonbow Engine in order to make code more understandable.

Register values are used in the following way for commented code:
```
16BitRegister -> someVariable        ; A 16-bit register points to a value in RAM or ROM ie) HL -> variableValue.anotherValue

16BitRegister = SOME_VALUE           ; A 16-bit register is equal to a 16-bit value in RAM or ROM ie) HL = SOME_VALUE 

8BitRegister = SOME_VALUE            ; An 8-bit register is equal to an 8-bit value in RAM ie) A = variableValue.anotherValue 
```

| Item    | Convention | Exceptions | Notes |
| -------- | ------- | ------- |
| Labels/Addresses | StartingCapsCamelCase | RAM_JumpToCorrectGameState | This exception has code run in RAM |
| Constants | ALL_CAPS_WITH_UNDERSCORE | - | - |
| Variables/RAM | lowerCaseStartingCamelCase | - | - |
| Pointer | pointerNameLo, pointerNameHi | - | Pointers should be broken into Low and High bytes for easy debugging |

All routines start with following comment:
`````
; ==============================================================
;  Short description of routine
; ==============================================================       
; Parameters:         ; ie) HL -> exampleEntity.input, A = SOME_VALUE ---- "None" is also a valid parameter
; Returns:            ; ie) HL -> exampleEntity.output
; Affects:            ; ie) A, BC, DE, HL, temp8Bit
    @RoutineLabel:    ; NOTE: Label could be a Parent Label (ParentLabel:) or a Child Label (@ChildLabel:) 
`````
 
 
