SECTION "Powers of 2",ROM0
;Exponent of α in GF(256) :
Powers2:
db 1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1
;This list is made to generate error correction codewords, its size is 256 bytes long, it contains every number between 1 and 255 (1 is there twice)

SECTION "Generator Equation",ROM0
Generator:
db 0,87,229,146,149,238,102,21
;This list is the generator equation for size 1 correction L qr codes

SECTION "Variable for sprite creation",WRAM0
bitLocation: ds 1
bitLocationtmp: ds 1
height: ds 1
distanceY: ds 1
offsetXstart: ds 1
offsetXend: ds 1
offsetYstart: ds 1
offsetYend: ds 1
count: ds 1
bigcount: ds 1
column: ds 1
columntmp: ds 1
row: ds 1
tmpRow: ds 1
tamponbit: ds 1
bitLocationInBytetmp: ds 1
tmpSetAtLocation: ds 1
P2addr: ds 1
cursorAddrY: ds 1
cursorAddrX: ds 1
cur_keys: ds 1
new_keys: ds 1
offsetMsg: ds 1
lastcharacter: ds 1
countCursor: ds 1

SECTION "QR Code Tiles",ROM0
ConstantTiles:
db $FE,$FE,$82,$82,$BA,$BA,$BA,$BA,$BA,$BA,$82,$82,$FE,$FE,$00,$00 ;Finder Pattern up left
db $00,$00,$E6,$E6,$00,$00,$02,$02,$00,$00,$02,$02,$00,$00,$00,$00 ;Version string (0..6) and timing pattern left
db $40,$40,$40,$40,$00,$00,$00,$00,$40,$40,$40,$40,$54,$54,$40,$40 ;Version string (8..14) and timing pattern up
db $40,$40,$42,$42,$00,$00,$00,$00,$00,$00,$00,$00,$40,$40,$00,$00 ;Version string up left (7..8) and up right (7) and dark module
db $00,$00,$40,$40,$00,$00,$00,$00,$40,$40,$40,$40,$40,$40,$00,$00 ;Version string down left (0..6)
db $00,$00,$E6,$E6,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ;Version string up right (8..14)

SECTION "keyboard tiles",ROM0
keyboardTile:
db $00,$00,$00,$00,$CC,$33,$CC,$33,$33,$CC,$33,$CC,$00,$00,$00,$00
SECTION "Font", ROM0
FontTiles:
INCBIN "font.chr"
FontTilesEnd:
