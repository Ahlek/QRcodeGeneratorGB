GAME_NAME EQUS "QRCODE"

;Disclaimer : may contain some esoteric info about qr codes generation, for further info, see https://www.thonky.com/qr-code-tutorial/
;Here are generated size 1 correction L qr codes with an ascii message (in message.txt)

MSG_ENCODED EQU $C500
MSG_REMAINDER EQU $C400
P EQU $C3DF
TMP_LIST EQU $C300
SPRITE_LOAD EQU $C600
MSG_TMP EQU $C700
MESSAGE EQU $C200
P1F_NONE     EQU $30
P1F_BUTTONS  EQU $10
P1F_DPAD     EQU $20

INCLUDE "input.asm"

INCLUDE "begin.asm"

SECTION "Message",ROM0
Message:
INCLUDE "message.txt"

INCLUDE "correctioncoding.asm"
INCLUDE "spritegenerator.asm"
INCLUDE "subfunctions.asm"
INCLUDE "variables.asm"
INCLUDE "gingerbread.asm"
