.SECTION "VDP VRAM Constants"
; VRAM I/O
    .DEFINE     VRAM_WRITE              $4000
    .DEFINE     VRAM_READ               $0000

; VRAM Addresses
    .DEFINE     VRAM_START              $0000

; VRAM Screen Map Addresses
    .DEFINE     VRAM_MAP_START_3800     $3800       ; Register 2 value: $FF
    .DEFINE     VRAM_MAP_START_3000     $3000       ; Register 2 value: $FD
    .DEFINE     VRAM_MAP_START_2800     $2800       ; Register 2 value: $FB
    .DEFINE     VRAM_MAP_START_2000     $2000       ; Register 2 value: $F9
    .DEFINE     VRAM_MAP_START_1800     $1800       ; Register 2 value: $F7
    .DEFINE     VRAM_MAP_START_1000     $1000       ; Register 2 value: $F5
    .DEFINE     VRAM_MAP_START_0800     $0800       ; Register 2 value: $F3
    .DEFINE     VRAM_MAP_START_0000     $0000       ; Register 2 value: $F1

; Font VRAM constants
    .DEFINE     FONT_VRAM_ADDRESS       $1AA0
    .DEFINE     PUNC_VRAM_CHAR_ADDRESS  $D5
    .DEFINE     NUM_VRAM_CHAR_ADDRESS   PUNC_VRAM_CHAR_ADDRESS + 6
    .DEFINE     FONT_VRAM_CHAR_ADDRESS  $E6
    .ASCIITABLE
        map " " to "!"  = PUNC_VRAM_CHAR_ADDRESS
        map "?"         = PUNC_VRAM_CHAR_ADDRESS + 2
        map "," to "."  = PUNC_VRAM_CHAR_ADDRESS + 3
        map "0" to ":"  = NUM_VRAM_CHAR_ADDRESS
        map "A" to "Z"  = FONT_VRAM_CHAR_ADDRESS  
    .ENDA
    
.ENDS

.ORGA $0008
; ================================================================================
; Tells VDP where it should be writing/reading data from in VRAM
; ================================================================================
; Parameters:   HL = VDP address | VRAM_WRITE
; Affects: A
SetVDPAddress:
    ld a, l                 ; Little endian
    out (PORT_VDP_ADDRESS), a     
    ld a, h
    out (PORT_VDP_ADDRESS), a
    ret


.ORGA $0010
; ================================================================================
; Copies data to the VRAM
; ================================================================================
; Parameters:   Prior call to SetVDPAddress
;               HL = data address 
;               BC = data length
; Affects: A, HL, BC
CopyToVRAM:
-:  
    ld a, (hl)                  ; Get data byte from location @ HL
    out (VDP_DATA), a
    inc hl                      ; Point to next data byte
    dec bc                      ; Decrease our counter
    ld a, b
    or c
    jr nz, -
    ret


.ORGA $0020
; ================================================================================
; Copies data to the VRAM quickly, and only 127-bytes
; ================================================================================
; Parameters:   Prior call to SetVDPAddress
;               HL = data address 
;               B = data length
; Affects: HL, BC
FastCopyToVRAM:
    ld c, VDP_DATA                      ; We want to write data
    otir                                ; Write contents of HL to C with B bytes
    ret


.SECTION "Update VDP VRAM" APPENDTO "VDP VRAM Constants"
; ================================================================================
; Clears VRAM
; ================================================================================
; Parameters: None
; Affects: A, B, C, HL
ClearVRAM:  
    ; First, let's set the VRAM write address to $0000
    ld hl, $0000 | VRAM_WRITE
    rst SetVDPAddress
    ; Next, let's clear the VRAM with a bunch of zeros
    ld bc, $4000            ; Counter for our zeros in VRAM
-:  
    xor a
    out (VDP_DATA), a       ; Output data in A to VRAM address (which auto increments)
    dec bc                  ; Adjust the counter
    ld a, b             
    or c                    ; Check if we are at zero
    jr nz,-                 ; If not, loop back up
    ret 


; ================================================================================
; Copies font data to the VRAM
; ================================================================================
; Parameters:   HL = data address
;               BC = data length
; Affects: A, HL, BC
WriteTextToBackground:
-:  
    ld a, (hl)                  ; Get data byte from location @ HL
    out (VDP_DATA), a           ; Send font character tile data
    xor a
    out (VDP_DATA), a           ; Send 0 (font will use BG color w/ no attributes)
    inc hl                      ; Point to next data byte
    dec bc                      ; Decrease our counter
    ld a, b
    or c
    jr nz, -
    ret

.ENDS