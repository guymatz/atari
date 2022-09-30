  processor 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include required files with register mapping and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  include "vcs.h"
  include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start an uninitialized segment at $80 for var declaration.
;; We have memory from $80 to $FF to work with, minus a few at
;; the end if we use the stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  seg.u Variables
  org $80
JetXPos   byte    ; player0 x-position
JetYPos   byte    ; player0 y-position
BomberXPos   byte    ; player1 x-position
BomberYPos   byte    ; player1 y-position
JetSpritePtr  word    ; pointer to player0 sprite lookup table
JetColorPtr  word    ; pointer to player0 color lookup table
BomberSpritePtr  word    ; pointer to player0 sprite lookup table
BomberColorPtr  word    ; pointer to player0 color lookup table
JetAnimOffset   byte    ; player0 sprite frame offset for animation

; CONSTANTS
JET_HEIGHT = 9  ; player0 sprite height
BOMBER_HEIGHT = 9  ; player1 sprite height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start our ROM code segment starting at $F000.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  seg code
  org $F000   ; defines the origin of the ROM at $F000

Reset:
  CLEAN_START   ; macro to safely clear the memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ldx #10           ; a = 50
  sta JetYPos
  ldx #60           ; a = 50
  sta JetXPos
  lda #83
  sta BomberYPos  ; init bomber position
  lda #54
  sta BomberXPos

  ; init pointers
  lda #<JetSprite
  sta JetSpritePtr  ; lo-byte pointer for jet sprite lookup table
  lda #>JetSprite
  sta JetSpritePtr+1

  lda #<JetColor
  sta JetColorPtr  ; lo-byte pointer for jet sprite color table
  lda #>JetColor
  sta JetColorPtr+1

  lda #<BomberSprite
  sta BomberSpritePtr  ; lo-byte pointer for bomber sprite lookup table
  lda #>BomberSprite
  sta BomberSpritePtr+1

  lda #<BomberColor
  sta BomberColorPtr  ; lo-byte pointer for bomber color lookup table
  lda #>BomberColor
  sta BomberColorPtr+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start the main display loop and frame rendering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:

  ; Calculations and tasks performed in the pre-VBLANK
  lda JetXPos
  ldy #0
  jsr SetObjectXPos   ; set player X position

  lda BomberXPos
  ldy #1
  jsr SetObjectXPos   ; set player X position

  sta WSYNC
  sta HMOVE           ; apply the horizontal offsets  previously set

  ; Display VSYNC and VBLANK
  lda #2
  sta VBLANK
  sta VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display VSYNC & VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  REPEAT 3
    sta WSYNC
  REPEND
  lda #0
  sta VSYNC
  REPEAT 37
    sta WSYNC
  REPEND
  sta VBLANK

GameVisibleLine:
  lda #$84
  sta COLUBK

  lda #$C2
  sta COLUPF

  lda #%00000001
  sta CTRLPF

  lda #$F0
  sta PF0
  lda #$FC
  sta PF1
  lda #0
  sta PF2

  ldx #96  ; num of remaiing scanlines (with 2 line kernel)
.GameLineLoop:
.AreWeInsideJetSprite:
  txa     ; current scanline
  sec
  sbc JetYPos
  cmp JET_HEIGHT
  bcc .DrawSpriteP0
  lda #0

.DrawSpriteP0
  clc                   ; clear carry flag before addition
  adc JetAnimOffset     ; jump to correct sprite frfame address in memory
  tay                   ; load Y so we can work with pointer
  lda (JetSpritePtr),Y    ; load player0 bitmap data from lookup tables
  sta WSYNC
  sta GRP0
  lda (JetColorPtr),Y    ; load player0 bitmap data from lookup tables
  sta COLUP0

.AreWeInsideBomberSprite:
  txa     ; current scanline
  sec
  sbc BomberYPos
  cmp BOMBER_HEIGHT
  bcc .DrawSpriteP1
  lda #0

.DrawSpriteP1
  tay                   ; load Y so we can work with pointer
  lda #%00000101
  sta NUSIZ1
  lda (BomberSpritePtr),Y    ; load player0 bitmap data from lookup tables
  sta WSYNC
  sta GRP1
  lda (BomberColorPtr),Y    ; load player0 bitmap data from lookup tables
  sta COLUP1
  
  dex                   ; X--
  bne .GameLineLoop     ; repeat next game scanline until finished

  ; reset jet sprite offset
  lda #0
  sta JetAnimOffset

; OVERSCAN
  lda #2
  sta VBLANK
  REPEAT 30
    sta WSYNC
  REPEND
  lda #0
  sta VBLANK


  ; Process joystick ffor Player0
CheckP0Up:
  lda #%00010000
  bit SWCHA
  bne CheckP0Down   ; if bit pattern does not match
  inc JetYPos
  lda #0
  sta JetAnimOffset

CheckP0Down:
  lda #%00100000
  bit SWCHA
  bne CheckP0Left   ; if bit pattern does not match
  dec JetYPos
  lda #0
  sta JetAnimOffset

CheckP0Left:
  lda #%01000000
  bit SWCHA
  bne CheckP0Right   ; if bit pattern does not match
  dec JetXPos
  lda JET_HEIGHT
  sta JetAnimOffset

CheckP0Right:
  lda #%10000000
  bit SWCHA
  bne EndInput   ; if bit pattern does not match
  inc JetXPos
  lda JET_HEIGHT
  sta JetAnimOffset

EndInput:
  ; Calculations to update positions for next frame
UpdateBomberPosition:
  lda BomberYPos
  clc
  cmp #0
  bmi .ResetBomberPosition
  dec BomberYPos
  jmp EndPositionUpdate
.ResetBomberPosition
  lda #96
  sta BomberYPos
                      ; TODO set bomber X position to random
                      ; fallback for the position update code

EndPositionUpdate:

; Loop back to start of brand new fframe
  jmp StartFrame

; Subroutine to handle object horizontal position with fine offset
; A is the target x-coordinate
; Y is the object type
SetObjectXPos subroutine
  sta WSYNC   ; start a new scanline1
  sec
.Div15Loop
  sbc #15
  bcs .Div15Loop
  eor #7
  asl
  asl
  asl
  asl
  sta HMP0,Y      ; store the fine offfset to the correct HMxx
  sta RESP0,Y     ; fix object position in 15 step incrments
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare ROM lookup tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JetSprite:
    .byte #%00000000         ;
    .byte #%00010100         ;   # #
    .byte #%01111111         ; #######
    .byte #%00111110         ;  #####
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #

; JET_HEIGHT = . - JetSprite

JetSpriteTurn:
    .byte #%00000000         ;
    .byte #%00001000         ;    #
    .byte #%00111110         ;  #####
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #

BomberSprite:
    .byte #%00000000         ;
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00101010         ;  # # #
    .byte #%00111110         ;  #####
    .byte #%01111111         ; #######
    .byte #%00101010         ;  # # #
    .byte #%00001000         ;    #
    .byte #%00011100         ;   ###

JetColor:
    .byte #$00
    .byte #$FE
    .byte #$0C
    .byte #$0E
    .byte #$0E
    .byte #$04
    .byte #$BA
    .byte #$0E
    .byte #$08

JetColorTurn:
    .byte #$00
    .byte #$FE
    .byte #$0C
    .byte #$0E
    .byte #$0E
    .byte #$04
    .byte #$0E
    .byte #$0E
    .byte #$08

BomberColor:
    .byte #$00
    .byte #$32
    .byte #$32
    .byte #$0E
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40

; complete ROM size with 4Kb
  org $FFFC
  word Reset
  word Reset
