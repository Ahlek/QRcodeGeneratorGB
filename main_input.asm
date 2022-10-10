SECTION "Input",ROM0

copyFontM: MACRO
.copyFont\@
  ld a, [de]
  ld [hl+], a
  inc de
  dec bc
  ld a, b
  or c
  jr nz, .copyFont\@
ENDM

begin:

;LOAD TILES INTO VRAM (screen is off)
  ld a,7
  ld [$FF4B],a ;place window x
  ld a,103
  ld [$FF4A],a ;place window y

  ld a, %11100100 ;load palette
  ld [$FF47], a

  ld a, %11100011 ;starts screen
  ld [$FF40], a
restart:

ld hl, $9200
ld de, FontTiles+$200
.loopFont ;loads font.chr
call waitVblank
  ld bc, $40
  .copyFont
    ld a, [de]
    ld [hl+], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copyFont

  ld a,h
  cp $98
  jr nz,.loopFont

call waitVblank

  ld hl, $8000  ;loads the last character of font.chr (cursor)
  ld de, FontTilesEnd-16
  ld b,16
.copyFontBis
  ld a, [de]
  ld [hl+], a
  inc de
  dec b
  jr nz, .copyFontBis

call waitVblank

  ld hl,$9010   ;loads tiny squares strip that frame keyboard
  ld de,keyboardTile
  ld b,16
.copySquare
  ld a,[de]
  inc de
  ld [hl+],a
  dec b
  jr nz,.copySquare

;LOAD PARTS OF KEYBOARD

call waitVblank

  ld hl,$9800   ;loading top squares strip
  ld a,$01
  ld b,$20
.squareLine1
  ld [hl+],a
  dec b
  jr nz,.squareLine1

  ld hl,$9C40 ;loading the bottom squares strip
  ld a,$01
  ld b,$20
.squareLine2
  ld [hl+],a
  dec b
  jr nz,.squareLine2

call waitVblank

  ld bc,0   ;loading keyboard's letters (column by column)
  ld d,0
.tileBG1  ;makes each lines
  call waitVblank
  ld e,$20  ;tiles indicator
  ld a,d    ;go to the next letter to start column
  add e
  ld e,a
  ld hl,$9841 ;place of first keyboard character (space)
  add hl,bc   ;go to the start of next column
  push bc   ;outlandish push (saves lines count)
  ld c,0
.tileBG2  ;makes each column
  ld a,e
  ld [hl],a
  ld a,e
  add $10
  ld e,a
  push bc   ;quaint push (saves column count)
  ld bc,$40
  add hl,bc
  pop bc    ;quaint pop (restore column count)
  inc c
  ld a,c
  cp 6
  jr nz,.tileBG2
  pop bc  ;outlandish pop (restore line count)
  inc bc
  inc bc
  inc d
  ld a,c
  cp 32
  jr nz,.tileBG1

  ld hl,$C100 ;ensure sprites starting addresses are empty
  ld bc,65
  xor a
  call mSet

  ld hl,MESSAGE ;ensure message starting addresses are empty
  ld bc,33
  xor a
  call mSet

  ld hl,$C100 ;load keyboard cursor parameters
  ld a,$40
  ld [cursorAddrY],a
  ld [hl+],a
  ld a,$38
  ld [cursorAddrX],a
  ld [hl+],a
  xor a
  ld [hl+],a
  ld [hl+],a
  ld [offsetMsg],a
  ld [countCursor],a

  ld a,$7E ;load bottom left cursor parameters
  ld [hl+],a
  ld a,$08
  ld [hl+],a
  xor a
  ld [hl+],a
  ld a,%00100000
  ld [hl+],a

  ld a,$7E ;load bottom right cursor parameters
  ld [hl+],a
  ld a,$A0
  ld [hl+],a
  xor a
  ld [hl+],a
  ld [hl+],a

  call EnableAudio

.lockup
  call callCursor ;make bottom cursors move
  call joypad     ;handle input
  jr .lockup


joypad:

  call read_pad

  ld a,[cur_keys]
  bit 0,a
  jr z,.noA
  ld a,[offsetMsg]
  cp 17
  jr z,.noA
  ld a,[cursorAddrX]
  sub 8
  ld b,a
  ld a,[$FF43]
  add b
  swap a
  ld b,a
  ld a,[cursorAddrY]
  add b
  ld hl,MESSAGE
  ld b,0
  ld [lastcharacter],a
  ld a,[offsetMsg]
  ld c,a
  add hl,bc
  ld a,[lastcharacter]
  ld [hl],a
  ld a,c
  inc a
  ld [offsetMsg],a
  call hibeep
  ld hl,MESSAGE_DISPLAY
  ld b,0
  ld a,[offsetMsg]
  ld c,a
  add hl,bc
.waitVRAM1
  ldh a, [$FF41]
  and %00000010
  jr nz, .waitVRAM1
  ld a,[lastcharacter]
  ld [hl],a
  jp .waitBeforeNextInput
.noA

  ld a,[cur_keys]
  bit 1,a
  jr z,.noB
  ld a,[offsetMsg]
  and a
  jr z,.noB
  dec a
  ld [offsetMsg],a
  ld hl,MESSAGE
  ld c,a
  ld b,0
  add hl,bc
  xor a
  ld [hl],a
  call lowbeep
  ld hl,MESSAGE_DISPLAY+1
  ld b,0
  ld a,[offsetMsg]
  ld c,a
  add hl,bc
.waitVRAM2
  ldh a, [$FF41]
  and %00000010
  jr nz, .waitVRAM2
  ld a,$20
  ld [hl],a
  jp .waitBeforeNextInput
.noB

  ld a,[cur_keys]
  bit 3,a
  jr z,.noStart
  ld a,[offsetMsg]
  and a
  jr nz,.noTroll
  ld hl,MESSAGE
  ld bc,Message
.loop
  ld a,[bc]
  inc bc
  ld [hl+],a
  and a
  jr nz,.loop
  ld a,17
  ld [offsetMsg],a
.noTroll
  ld hl,$C100
  ld bc,12
  xor a
  call mSet
  jp generationStart
.noStart

  ld a,[cur_keys]
  bit 6,a
  jr z,.noUp
  ld a,[cursorAddrY]
  sub 16
  cp 16+8
  jr c,.noUp
  ld [cursorAddrY],a
  call updateOBJ
  jr .waitBeforeNextInput
.noUp

  ld a,[cur_keys]
  bit 7,a
  jr z,.noDown
  ld a,[cursorAddrY]
  add 16
  cp 144+8-24
  jr nc,.noDown
  ld [cursorAddrY],a
  call updateOBJ
  jr .waitBeforeNextInput
.noDown

  ld a,[cur_keys]
  bit 5,a
  jr z,.noLeft
  ld a,[cursorAddrX]
  cp 8
  jr z,.scrollLeft
  sub 16
  ld [cursorAddrX],a
  call updateOBJ
  jr .waitBeforeNextInput
.scrollLeft
  ld hl,$FF43
  ld a,[hl]
  sub 16
  ld [hl],a
  jr .waitBeforeNextInput
.noLeft

  ld a,[cur_keys]
  bit 4,a
  jr z,.noRight
  ld a,[cursorAddrX]
  cp $98
  jr z,.scrollRight
  add 16
  ld [cursorAddrX],a
  call updateOBJ
  jr .waitBeforeNextInput
.scrollRight
  ld hl,$FF43
  ld a,[hl]
  add 16
  ld [hl],a
.waitBeforeNextInput
  ld bc,$2000
.waitVRAM
  ldh a, [$FF41]
  and %00000010
  jr nz, .waitVRAM
  dec bc
  ld a,b
  or c
jr nz,.waitVRAM
.noRight
.noInput

  ret

updateOBJ:
  ld hl,$C100
  ld a,[cursorAddrY]
  ld [hl+],a
  ld a,[cursorAddrX]
  ld [hl+],a
  xor a
  ld [hl+],a
  ld [hl+],a

  ret

callCursor:
  ld a,[countCursor]
  cp 0
  jr nz,.noMove
  call moveCursors
  ld a,$FF
  ld [countCursor],a
  jr .endMove
.noMove
  dec a
  ld [countCursor],a
.endMove

  ret

moveCursors:
  ld a,[$C105]
  cp 12
  jr nc,.moveRight
.moveLeft
  inc a
  ld [$C105],a
  jr .endOBJ1
.moveRight
  sub 4
  ld [$C105],a
.endOBJ1

  ld a,[$C109]
  cp $9C
  jr z,.moveRight1
.moveLeft1
  dec a
  ld [$C109],a
  jr .endOBJ2
.moveRight1
  add 4
  ld [$C109],a
.endOBJ2

  ret
; Copyright 2018, 2020 Damian Yerrick
;
; This software is provided 'as-is', without any express or implied
; warranty.  In no event will the authors be held liable for any damages
; arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.

; Controller reading ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This controller reading routine is optimized for size.
; It stores currently pressed keys in cur_keys (1=pressed) and
; keys newly pressed since last read in new_keys, with the same
; nibble ordering as the Game Boy Advance.
; 76543210
; |||||||+- A
; ||||||+-- B
; |||||+--- Select
; ||||+---- Start
; |||+----- Right
; ||+------ Left
; |+------- Up
; +-------- Down
;           R
;           L (just kidding)

read_pad::
  ; Poll half the controller
  ld a,P1F_BUTTONS
  call .onenibble
  ld b,a  ; B7-4 = 1; B3-0 = unpressed buttons

  ; Poll the other half
  ld a,P1F_DPAD
  call .onenibble
  swap a   ; A3-0 = unpressed directions; A7-4 = 1
  xor b    ; A = pressed buttons + directions
  ld b,a   ; B = pressed buttons + directions

  ; And release the controller
  ld a,P1F_NONE
  ld [$FF00],a

  ; Combine with previous cur_keys to make new_keys
  ld a,[cur_keys]
  xor b    ; A = keys that changed state
  and b    ; A = keys that changed to pressed
  ld [new_keys],a
  ld a,b
  ld [cur_keys],a
  ret

.onenibble:
  ldh [$FF00],a     ; switch the key matrix
  call .knownret  ; burn 10 cycles calling a known ret
  ldh a,[$FF00]     ; ignore value while waiting for the key matrix to settle
  ldh a,[$FF00]
  ldh a,[$FF00]     ; this read counts
  or $F0   ; A7-4 = 1; A3-0 = unpressed keys
.knownret:
  ret
