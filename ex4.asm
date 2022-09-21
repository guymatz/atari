  processor 6502
  seg Code        ; Define a new segment named Code
  org $F000       ; Define the origin of the ROM Code at address $F000
Start:

  clc               ; clear carry flag for addition
  lda #100    ; Load the A register with the literal decimal value 100
  adc #5      ; Add the decimal value 5 to the accumulator
  sec               ; set carry flag for subtraction
  sbc #10     ; Subtract the decimal value 10 from the accumulator
 ; Register A should now contain the decimal 95 (or $5F in hexadecimal)

  jmp Start


  org $FFFC       ; End the ROM by adding required values to memory
  .word Start     ; Put 2 bytes with the reset address
  .word Start     ; Put 2 bytes with the break address
