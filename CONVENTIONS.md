# Tonbow Engine Conventions
This is list of all conventions maintained throughout the Tonbow Engine in order to make code more understandable. CONVENTIONS.md is not required reading. Most of the patterns of conventions should be easy to pick up. This document exists simply as a place to establish and check on conventions.

| Item | Convention | Exceptions | Notes |
| -------- | ------- | ------- | ------- |
| Labels/Addresses | ```StartingCapsCamelCase:``` | ```RAM_JumpToCorrectGameState``` | This exception has code run in RAM |
| Parent Labels | ```ParentLabel:``` | - | Parent Labels are left aligned|
| Child Labels |``` @ChildLabel:``` | - | Child Labels are tabbed to the right once per @|
| Local Labels | ```--:```, ```-:```, ```+:```, ```++:``` | ```DJNZ -``` | Avoided at almost all costs. Descriptive Child Labels will **always** make debugging easier. Used for ```DJNZ``` because it only ever uses a single local label |
| ```PUSH```/```POP``` | - | - | Code following a ```PUSH``` is tabbed to the right once until the accompanying ```POP```. A dummy ```POP``` that can't be reached will be added in cases where one is not needed to preserve syntax coloring and make the code easier to read |
| ```.STRUCT```, ```.ENUM```, ```.RAMSECTION```  | - | - | Data following these directives is tabbed to the right once |
| ```.SECTION```  | - | - | Code following .SECTION is left aligned, unless led with a Child Label |
| Constants | ```ALL_CAPS_WITH_UNDERSCORE``` | - | - |
| Variables/RAM | ```lowerCaseStartingCamelCase``` | - | - |
| Pointer | ```pointerNameLo```, ```pointerNameHi``` | - | Pointers are broken into Low and High bytes for easy debugging |
| Instructions | ```neg ; NEG``` | - | Instructions are always lowercase in code but capitalized in comments |
| Registers | ```ld a, $01 ; A = $01``` | - | Registers are always lowercase in code but capitalized in comments |
| - | - | - | - |


## Comments

### Routines
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

### Descriptive comments
Parent and Child Labels are given a comment above them to denote why they exist.

This comment is tabbed left of the Label in order to make important sections stand out more, unless the Label is already Left aligned, in which case, so will the comment. This style of commenting is also used to denote the high-level function of the proceeding code

In addition to the left tabbed high-level comments, lower-level comments are also included and share the same tabbing as the code they describe.

Line specific comments are located to the right of the specific Instruction they describe. 

Below is an example of how comments are used:
```
; Acts as an example for the CONVENTIONS.md file
    @ExampleChildLabelRoutine:
    ; Set up the example
        ld a, EXAMPLE_VALUE            ; A = EXAMPLE_VALUE
        ; Apply an example offset
        ld hl, example.offsetValue     ; HL -> example.offsetValue
        sub a, (hl)                    ; A = EXAMPLE_VALUE - example.offsetValue
        ret
        ...
```

Register values are used in the following way for commented code:
```
16BitRegister -> someVariable        ; A 16-bit register points to a value in RAM or ROM ie) HL -> variableValue.anotherValue

16BitRegister = SOME_VALUE           ; A 16-bit register is equal to a 16-bit value in RAM or ROM ie) HL = SOME_VALUE 

8BitRegister = SOME_VALUE            ; An 8-bit register is equal to an 8-bit value in RAM ie) A = variableValue.anotherValue 
```

## Classes			

### Structure
Classes are set up via folders in order to keep files from getting too long. The properties of the class are named in the *____EntityClass.asm* file. At a minimum, a class will be made up of at least this file. Any other files related to the entity are added via a WLA DX ``` .INCLUDE ``` directive within *____EntityClass.asm*. Files may contain a single routine, or several depending on their scope. For example **TBD**. 

The *____EntityClass.asm* file always follows this pattern:
```
; ================================================================================
;  Example Entity Class Structure
; ================================================================================
.STRUCT exampleEntityStructure
    INSTANCEOF entitySkeleton
; ---------------------------------------------------------------------------------------------------
 ; Unique Entity traits down here
    ...

.ENDST

.SECTION "Example Entity Class"
; ================================================================================
;  Example Entity Class
; ================================================================================
; Example Entity Class description
ExampleEntityClass:
; ================================================================================
;  Example Entity Class Constants
; ================================================================================
; Entity States
.DEFINE        	EXAMPLE_VALUE			$00
...

    @ExampleRoutine:
        ...

ExampleEntityClassEnd:
.ENDS
```

With any necessary ```.INCLUDE```'s added between ```ExampleEntityClass:``` and ```ExampleEntityClassEND:```

### Inheritance
While inheritance isn't something natively supported in Z80, we can fake it by creating entities in the same form as others. All entities share the same attributes as the *BaseEntity*. This means that the routines in the *BaseEntity* folder can be used for any given entity so long as the parameters of the routine are satisfied. Any other Entity Types are built off of this foundation. 

## Tips

### Programming
Any ```CALL``` that needs to be made within strict timings (such as HBlank palette swapping, scroll updating or SAT updating) can be done faster by dedicating a space in the Zeropage for an ```RST``` instead.
