# Tonbow Engine Conventions
This is list of all conventions maintained throughout the Tonbow Engine in order to make code more understandable. CONVENTIONS.md is not required reading. Most of the patterns of conventions should be easy to pick up. This document exists simply as a place to establish and check on conventions.

Register values are used in the following way for commented code:
```
16BitRegister -> someVariable        ; A 16-bit register points to a value in RAM or ROM ie) HL -> variableValue.anotherValue

16BitRegister = SOME_VALUE           ; A 16-bit register is equal to a 16-bit value in RAM or ROM ie) HL = SOME_VALUE 

8BitRegister = SOME_VALUE            ; An 8-bit register is equal to an 8-bit value in RAM ie) A = variableValue.anotherValue 
```

| Item | Convention | Exceptions | Notes |
| -------- | ------- | ------- | ------- |
| Labels/Addresses | StartingCapsCamelCase: | RAM_JumpToCorrectGameState | This exception has code run in RAM |
| Parent Labels | ParentLabel: | - | Parent Labels are left aligned|
| Child Labels | @ChildLabel: | - | Child Labels are tabbed to the right once per @|
| PUSH/POP | - | - | Code following a PUSH is tabbed to the right once until the accompanying POP. A dummy POP that can't be reached will be added in cases where one is not needed to preserve syntax coloring and make the code easier to read |
| Constants | ALL_CAPS_WITH_UNDERSCORE | - | - |
| Variables/RAM | lowerCaseStartingCamelCase | - | - |
| Pointer | pointerNameLo, pointerNameHi | - | Pointers are broken into Low and High bytes for easy debugging |
| - | - | - | - |

All routines start with following comment:
```
; ==============================================================
;  Short description of routine
; ==============================================================       
; Parameters:         ; ie) HL -> exampleEntity.input, A = SOME_VALUE ---- "None" is also a valid parameter
; Returns:            ; ie) HL -> exampleEntity.output
; Affects:            ; ie) A, BC, DE, HL, temp8Bit
RoutineLabel:    ; NOTE: Label could be a Parent Label (ParentLabel:) or a Child Label (@ChildLabel:)
    ld a, (hl)
    ...
    
```

Parent and Child Labels are given a comment above them denote why they exist:
```
; Acts as an example for the CONVENTIONS.md file
    @ExampleChildLabelRoutine:
        ld a, EXAMPLE_VALUE
        ...
```

			
 
 
