  processor 6502
  seg Code        ; Define a new segment named Code
  org $F000       ; Define the origin of the ROM Code at address $F000
Start:
   lda #1 ; Initialize the A register with the decimal value 1
   clc
Loop:
  ; Increment A
  
  adc #1
  ; Compare the value in A with the decimal value 10
  cmp #10
  bne Loop; Branch back to loop if the comparison was not equals (to zero)



  org $FFFC       ; End the ROM by adding required values to memory
  .word Start     ; Put 2 bytes with the reset address
  .word Start     ; Put 2 bytes with the break address
