SECTION "Game code", ROM0

initiateArg: MACRO 	;initiate arguments for function in spritegenerator
	ld a,\1
	ld [row],a
	ld a,\2
	ld [column],a
	ld a,\3
	ld [offsetXstart],a
	ld a,\4
	ld [offsetYstart],a
	ld a,\5
	ld [offsetXend],a
	ld a,\6
	ld [offsetYend],a
	ld a,\7
	ld [bitLocation],a
ENDM

begin:
ld hl,Message 		;The address of the message (which is in ascii)
ld de,MSG_ENCODED			;Will contain the encoded message
ld a,4
call stringSize		;Calculate size of message. Return that value in c (takes the label "Message" as message start)
ld b,c
call encodeRightLeft	;Since the message starts and ends with 4 bits (%0100 and %0000), we need to shift the further bits.
ld [de],a 				;Takes a for MSB and b for LSB. Returns a
ld a,[hl]
ld b,a
call stringSize
ld a,c
call encodeRightLeft
inc de
ld [de],a
.loopEncode
inc de
ld a,[hl+]
ld c,a
ld a,[hl]
ld b,a
ld a,c
call encodeRightLeft
ld [de],a
cp 0
jr nz,.loopEncode

;The message must be 152 bits long (1-L qr code) so we add 236 and 17
dec e
ld a,e
cp 18
jr z,.tailleMax
.whileNot151
inc de
ld a,236
ld [de],a
ld a,e
cp 18
jr z,.tailleMax
inc de
ld a,17
ld [de],a
ld a,e
cp 18
jr z,.tailleMax
jr .whileNot151
.tailleMax

ld d,19 	;Number of division steps (For 1-L version there is 19 steps)
ld bc,MSG_REMAINDER ;"rem" Future remainder of RS division
ld hl,MSG_ENCODED	;Message String
.while 		;Remainder <= Message String
ld a,[hl+]
ld [bc],a
inc bc
cp 0
jr nz,.while
.stepECcoding
call correctionCoding
ld hl,MSG_REMAINDER+1
ld bc,MSG_REMAINDER
.offsetRemainder 		;discard the first term of remainder
ld a,[hl+]
ld [bc],a
inc bc
cp 0
jr nz,.offsetRemainder
dec d
jr nz,.stepECcoding

ld hl,MSG_ENCODED+19
ld bc,MSG_REMAINDER
.loadECcodes
ld a,[bc]
inc bc
ld [hl+],a
cp 0
jr nz,.loadECcodes

ld a,%10000010
ld [$FF40],a

ld bc,SPRITE_LOAD 	;start address of generated tiles

	initiateArg 14,14,0,0,6,6,82
	call createSpriteQR

	initiateArg 0,7,2,0,5,5,137
	call createSpriteQR

	initiateArg 7,14,0,2,6,6,72
	call createSpriteQR

	initiateArg 14,7,2,0,6,6,163
	call createSpriteQR

	initiateArg 7,0,0,2,5,5,201
	call createSpriteQR

	initiateArg 7,7,2,0,5,6,149
	call createSpriteQR

	initiateArg 7,7,6,2,6,6,73
	call createSpriteQR

	initiateArg 7,7,0,2,1,5,183
	call createSpriteQR


;The part below needs to be improved a lot (it loads tiles VRAM and tiles info into OAM)
.wait:
ld a,[$FF44]
cp 145
jr nz, .wait

ld d,$60
ld hl,Tiles
ld bc,$8000
.loopvram
ld a,[hl+]
ld [bc],a
inc bc
dec d
jr nz,.loopvram

.wait2:
ld a,[$FF44]
cp 145
jr nz, .wait2

ld d,$60
ld hl,SPRITE_LOAD
ld bc,$8060
.loopvram2
ld a,[hl+]
ld [bc],a
inc bc
dec d
jr nz,.loopvram2

.wait3:
ld a,[$FF44]
cp 145
jr nz, .wait3

ld d,$20
.loopvram3
ld a,[hl+]
ld [bc],a
inc bc
dec d
jr nz,.loopvram3

ld hl,$C100
ld b,$19 ;y
ld c,$19 ;x
ld d,0   ;tile index
ld e,0   ;loop index
.loopOAM2
ld a,c
add 7
ld c,a
.loopOAM1
ld a,b
add 7
ld b,a
ld a,b
ld [hl+],a
ld a,c
ld [hl+],a
ld a,d
ld [hl+],a
xor a
ld [hl+],a

inc d
inc e
ld a,e


cp 6
jr z,.notd
cp 1
jr z,.notd
ld d,e
cp 6
jr c,.notinc
dec d
.notinc
dec d
.notd

cp 2
jr nz,.not0
ld d,0
.not0

cp 6
jr nz,.not0_1
ld d,0
.not0_1

ld a,b
cp $2E
jr c,.loopOAM1
ld b,$19
ld a,c
cp $2E
jr c,.loopOAM2

ld e,7
ld b,$20
ld c,$27
.loopOAMbis
ld a,b
ld [hl+],a
ld a,c
ld [hl+],a
ld a,d
ld [hl+],a
xor a
ld [hl+],a

ld a,b
add e
ld b,a
ld a,c
cp $2E
jr nz,.not_7
ld e,$F9
.not_7
ld a,c
add e
ld c,a

inc d

cp $19
jr nz,.loopOAMbis


ld b,$27
ld c,$27
.loopOAMtroisiemeedition
ld a,b
ld [hl+],a
ld a,c
ld [hl+],a
ld a,d
ld [hl+],a
xor a
ld [hl+],a
inc d
ld a,d
cp 14
jr nz,.loopOAMtroisiemeedition
