GAME_NAME EQUS "QRCODE"

;Disclaimer : I don't know how bad I am at english, comments may be unclear, I'm doing my best
;May contain some esoteric info about qr codes generation, for further info, see https://www.thonky.com/qr-code-tutorial/
;Here are generated size 1 correction L qr codes with an ascii message

MSG_ENCODED EQU $C500
MSG_REMAINDER EQU $C400
P EQU $C3DF     ;P means to link powers of 2 and their values (in GF)
TMP_LIST EQU $C3E0
TILES_LOAD EQU $C600
MESSAGE EQU $C200
MESSAGE_DISPLAY EQU $9C60
NB_DIVISION_STEP EQU 19
GENERATOR_LENGTH EQU 8
ASCII_MODE EQU 4
FILL_QR1 EQU 236
FILL_QR2 EQU 17
P1F_NONE     EQU $30
P1F_BUTTONS  EQU $10
P1F_DPAD     EQU $20

INCLUDE "input.asm"

INCLUDE "begin.asm"

SECTION "Message",ROM0
Message:
INCLUDE "message.txt"

INCLUDE "correctioncoding.asm"
INCLUDE "tilesgenerator.asm"
INCLUDE "subfunctions.asm"
INCLUDE "variables.asm"
INCLUDE "gingerbread.asm"
