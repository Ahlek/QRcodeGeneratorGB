GAME_NAME equs "QRCODE"

MSG_ENCODED equ $C500
MSG_REMAINDER equ $C400
P equ $C250
TMP_LIST equ $C300
SPRITE_LOAD equ $CB00

INCLUDE "begin.asm"

.lockup
jr .lockup

SECTION "Message", ROM0
Message:
INCLUDE "message.txt"

INCLUDE "correctioncoding.asm"
INCLUDE "spritegenerator.asm"
INCLUDE "subfunctions.asm"
INCLUDE "variables.asm"
INCLUDE "gingerbread.asm"