.SECTION "Linear Feedback Shift Register Constants and Structures"
; LFSR Constants
	.DEFINE		LFSR_DEFAULT_SEED		%00000001
	.DEFINE		LFSR_DEFAULT_TAPS		%01110001
	.DEFINE		LFSR_SIZE_0_TO_127		$7F
	.DEFINE		LFSR_SIZE_0_TO_63		$3F
	.DEFINE		LFSR_SIZE_0_TO_31		$1F
	.DEFINE		LFSR_SIZE_0_TO_15		$0F
	.DEFINE		LFSR_SIZE_0_TO_7		$07
	.DEFINE		LFSR_SIZE_0_TO_3		$03

;LFSR Structure
	.STRUCT lfsrStructure
		currentValue	    		DB				;  Current value of our LFSR
		tapsBitmap					DB				;  Which bits are set as our taps
	.ENDST

.ENDS





.RAMSECTION "LFSR Variables" BANK 0 SLOT "RAM_SLOT"
; LFSR Instance
	lfsr INSTANCEOF lfsrStructure
.ENDS


.SECTION "Linear Feedback Shift Register" APPENDTO "Linear Feedback Shift Register Constants and Structures"
LFSRClass:
; ==============================================================
;  Runs one cycles of the LFSR
; ==============================================================
; Parameters:  LFSR has been initialized once before
; Returns: Updated lfsr.currentValue
; Affects: A, BC, DE, lfsr.currentValue
	@RunOnce:
	; Set up our tap checking loop
		ld a, (lfsr.tapsBitmap)						
		ld b, a									; B = Bitmap of our taps
		ld a, (lfsr.currentValue)				
		ld c, a									; C = current LFSR state
		ld d, 8									; D is our counter or timer for the loop
		xor a									; A = 0
	; The loop
		@@LoopStart:
		; Check if this bit is a tap
			srl b									; Check the bit
			jr nc, @@NoTap
		; This bit is a tap
			srl c									; CF = Tap Value
			adc $00									; Add carry bit to A (XOR)
			jr @@LoopCheck

		@@NoTap:
		; We are not at a tap
			srl c

		@@LoopCheck:
		; If we have gone through all 8 bits, then stop looping
			dec d
			jr nz, @@LoopStart

		@@UpdateLFSR:
		; LFSR cycle complete, so update the currentValue
			srl a
			ld a, (lfsr.currentValue)
			rra									; Put XOR'd value into our current LFSR value and shift
			ld (lfsr.currentValue), a

			ret

	; ==============================================================
	;  Initialized the LFSR
	; ==============================================================
	; Parameters:  	A = Initial value
	;				B = Taps Bitmap
	; Returns: Initialized LFSR
	; Affects: None
	@Initialize:
		ld (lfsr.currentValue), a
		ld a, b
		ld (lfsr.tapsBitmap), a

		ret
	
.ENDS