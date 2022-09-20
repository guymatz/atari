    processor 6502

    seg code
    org $F000    ; Define the code origin at $F000

Start:
    sei          ; Disable interrupts
    cld          ; Disab;e the BCD decimal math mode
    ldx #$FF     ; Loads the X register with #$FF
    txs          ; tramsfer the X register to the (S)tack pointer

;;;;;;
; Clear the Page Zero region ($00 to $FF)
; Meaning the entire RAM and TIA registers
;;;;;;

    lda #0  ; A = 0
    ldx #$FF    ; X = #$FF
    sta $0,X  ; Stor the value of A inside (memory address + X)

MemLoop:
    dex     ; X--
    sta $0,X  ; Stor the value of A inside (memory address + X)
    bne MemLoop ; Loop until X==0 (z-flag is set)

;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;
    org $FFFC
    .word Start ; Reset vector at $FFFC (where the program starts)
    .word Start ; Interrupt vector at $FFFE (unused in VCS)
