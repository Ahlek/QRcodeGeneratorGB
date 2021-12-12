SECTION "Game code", ROM0

initiateArg: MACRO 	;initiate arguments for function in Tilesgenerator
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

generationStart:

		ld hl, $9800	;remove keyboard tiles from background
		ld bc, $1FFF
		xor a
		call mSetVRAM




;ENCODING

ld hl,MESSAGE 		;The address of the message (which is in ascii)
ld de,MSG_ENCODED			;Will contain the encoded message
ld a,ASCII_MODE
call stringSize		;Calculate size of message. Return that value in c (takes the label "Message" as message start)
ld b,c
call encodeRightLeft	;Since the message starts and ends with 4 bits (%0100 and %0000), we need to shift the further bits.
ld [de],a 				;Takes a for MSB and b for LSB. Returns a
ld a,[hl]
ld b,a
call stringSize
ld a,c
ld [offsetMsg],a
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
ld a,[offsetMsg]
dec a
ld [offsetMsg],a
cp $FF
jr z,.endLoop
jr .loopEncode
.endLoop

;The message must be 152 bits long (1-L qr code) so we fill with 236 and 17
dec e
ld a,e
cp 18
jr z,.tailleMax
.whileNot151
inc de
ld a,FILL_QR1
ld [de],a
ld a,e
cp 18
jr z,.tailleMax
inc de
ld a,FILL_QR2
ld [de],a
ld a,e
cp 18
jr z,.tailleMax
jr .whileNot151
.tailleMax

;ERROR CORRECTION CODING

ld d,NB_DIVISION_STEP 						;length of MSG_ENCODED
ld bc,MSG_REMAINDER ;dividend, future remainder of RS division
ld hl,MSG_ENCODED	;Message String
.while 		;MSG_REMAINDER <= MESSAGE_ENCODED
ld a,[hl+]
ld [bc],a
inc bc
dec d
jr nz,.while
ld d,NB_DIVISION_STEP				;Number of division steps (For 1-L version there is 19 steps)
.stepECcoding
call correctionCoding ;perform 1 division step

jr .skip
.moreThan1
ld a,d
cp 1 				;some of QRcode ECC starts by $00, so $00 is never discard at last step
jr z,.itsatrap
dec d
.skip
ld hl,MSG_REMAINDER+1
ld bc,MSG_REMAINDER
ld e,20
.offsetRemainder 		;discard the each term=$00 of dividend
ld a,[hl+]
ld [bc],a
inc bc
dec e
jr nz,.offsetRemainder
ld a,[MSG_REMAINDER]
and a
jr z,.moreThan1
.itsatrap
dec d
jr nz,.stepECcoding

ld hl,MSG_ENCODED+NB_DIVISION_STEP 	;load the ECC next to MSG_ENCODED, in bigger QRcode(>3-Q) they are interleaved into blocks
ld bc,MSG_REMAINDER
ld d,9
.loadECcodes
ld a,[bc]
inc bc
ld [hl+],a
dec d
jr nz,.loadECcodes

;TILES GENERATION

;ld a,%10000010
;ld [$FF40],a 		;was useful for testing ECCoding (without the keyboard)

ld bc,TILES_LOAD 	;start address of generated tiles

	initiateArg 14,14,0,0,6,6,82
	call createTilesQR

	initiateArg 0,7,2,0,5,5,137
	call createTilesQR

	initiateArg 7,14,0,2,6,6,72
	call createTilesQR

	initiateArg 14,7,2,0,6,6,163
	call createTilesQR

	initiateArg 7,0,0,2,5,5,201
	call createTilesQR

	initiateArg 7,7,2,0,5,6,149
	call createTilesQR

	initiateArg 7,7,6,2,6,6,73
	call createTilesQR

	initiateArg 7,7,0,2,1,5,183
	call createTilesQR

;PLACEMENT OF TILES IN OAM

;The part below needs to be improved a lot (it loads tiles VRAM and tiles info into OAM)
.wait:
ld a,[$FF44]
cp 145
jr nz, .wait

ld d,$60
ld hl,ConstantTiles
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
ld hl,TILES_LOAD
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

.lockup
;call read_pad
;ld a,[cur_keys]
;bit 3,a
;jr z,.noStart
;ld bc,$2000
;.waitVRAM1
;    ldh a, [$FF41]
;    and %00000010
;    jr nz, .waitVRAM1
;dec bc
;ld a,b
;or c
;jr nz,.waitVRAM1
;ld hl,$8000
;ld bc, $1FFF
;xor a
;call mSetVRAM
;jp begin
;.noStart
jr .lockup
