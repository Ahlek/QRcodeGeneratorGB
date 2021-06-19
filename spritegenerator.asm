SECTION "Sprite Creation",ROM0

createSpriteQR:
;This subprogram create one tile necessary for the qr code
;Basically, I divided the qr code in tiny rectangles (not necessarly a complete tile)

ld a,8 			;count of bigloop iteration (makes each line of a tile)

.bigloop 		

ld [bigcount],a

ld a,[bitLocation] 		;location of the bit in data
ld [bitLocationtmp],a

ld a,[column]
ld [columntmp],a

ld d,a 	;if the column number is too low we need to increase it (a number of times even)
cp 7
jr nc,.noException
inc d
inc d
.noException
ld a,d
srl a
call isEven
jr nz,.impair
ld a,2 			;if column/2 is even, the qr pattern goes up, so distance in data between two bits above one another in tile is 2 (we will sub this value)
ld [distanceY],a
jr .endifpair
.impair
ld a,$FE 		;if column/2 is odd, the qr pattern goes down, so we will add 2 (or sub -2 which is $FE here)
ld [distanceY],a
.endifpair
;Note : I think distanceY calculs could be performed outside bigloop


xor a
ld [tmpRow],a ;must be set it to 0 before entering loop (contain the ongoing row)

ld a,8 	;count of loop iteration (makes each column of a line)
;Note : the count starts at 8, but may be easier to start it at 0 (for some calculations)

.loop 	

ld hl,MSG_ENCODED 	;data start
ld [count],a 	;loop count

ld a,[offsetXstart] ;check if we must skip a column at the start (and jump if so)
ld d,a
ld a,[count]
ld e,a
xor a
sub e
add 8
cp d
jp c,.skipall

ld a,[offsetXend] ;check if we must skip a column at the end (and jump if so)
ld d,a
ld a,[count]
ld e,a
xor a
sub e
add 8
cp d
jp nc,.skipallspecial
.notskipall

ld a,[bitLocationtmp]
srl a 					;divide the location by 8 (the point is find in which byte is our bit)
srl a 					;(shift right logically)
srl a
cp 0
jr z,.isfirstByte
.countByteWhereOurBitIs
inc hl 					;increments the address until we find the right byte
dec a
jr nz,.countByteWhereOurBitIs
.isfirstByte

ld a,[bitLocationtmp] ;now we need to find the location of the bit in the byte (mod 8) (starting from left)
ld e,8
call moduloE

ld d,$80 			;bit 0 set

ld [bitLocationInBytetmp],a ;save the location (number from 0 to 7)
cp 0
jr z,.endBitEmplacemetnSet
.bitLocationSet
rrc d 		;rotate right circular bit postition until its right location
dec a
jr nz,.bitLocationSet
.endBitEmplacemetnSet


ld a,d
ld [tmpSetAtLocation],a ;save the location (bit set at right location)
and [hl] 	;get the right bit in right byte

ld e,a 		;this part of code is made to get the bit in its start position (in hl) to its final position (in tmpRow)
ld a,[count];the final location of bit
ld d,a
xor a
sub d
add 8
ld d,a
ld a,[tmpSetAtLocation]
ld l,a 						;l will be usefull for masking
ld a,[bitLocationInBytetmp]
sub d
cp 0
jr z,.BitDeplacementNot
.BitDeplacement 	;rotate the "data" bit position until it get to "graphic" bit position
rlc l
rlc e
dec a
jr nz,.BitDeplacement
.BitDeplacementNot


ld a,[row] ;masking (process qr code specific which requires to "invert" bits)
call isEven 	   ;we always use mask 1 (each even row is invert)
jr nz,.notMask
ld a,e
xor l
ld e,a
ld a,[tmpRow]
or e 			;or e with the precedent or reset row
ld [tmpRow],a
jr .endMask
.notMask
ld a,[tmpRow]
or e
ld [tmpRow],a
.endMask


call calculDistanceX ;measure the distance X in data between two bits side by side (details in the sub program)
ld d,a
ld a,[bitLocationtmp]
sub d
ld [bitLocationtmp],a


jr .skipall
.skipallspecial
jp z,.notskipall
.skipall

ld a,[columntmp]
inc a
ld [columntmp],a

ld a,[count]
dec a
jp nz,.loop 	;--------------------------------------------------------------------------------------------

ld a,[bigcount] ;determine if we must skip a line or not
ld d,a
xor a
sub d
add 8
ld d,a
ld a,[offsetYend]
cp d
jr c,.thenskip
ld a,[bigcount]
ld d,a
xor a
sub d
add 8
ld d,a
ld a,[offsetYstart]
cp d
jr c,.elsenotskip
jr z,.elsenotskip
.thenskip
xor a
ld [bc],a
inc bc
ld [bc],a
inc bc
jr .endifskip
.elsenotskip

ld a,[tmpRow]
ld [bc],a
inc bc
ld a,[tmpRow]
ld [bc],a
inc bc

ld a,[bitLocation]
ld [bitLocationtmp],a
ld a,[distanceY] 	;subtract the start location +-2
ld e,a
ld a,[bitLocationtmp]
sub e
ld [bitLocationtmp],a
ld [bitLocation],a
.endifskip

ld a,8
ld [count],a


ld a,[row]
inc a
ld [row],a

ld a,[bigcount]
dec a
jp nz,.bigloop 	;-----------------------------------------------------------------------------------------

ret

calculDistanceX: ;the value returned by this function will be sub to bitLocationtmp
push bc 		 ;the algorithm take this form :
push de 		 ;case 1 : column number is odd, return 1
push hl 		 ;case 2 : column number is even :
 				 ; 								 :if column number/2 is odd, distanceX is ceilingDistance*4+1
ld a,[columntmp] ;								 :if column number/2 is even, distanceX is floorDistance*4+1
ld d,a
cp 8
jr nc,.elsif
.then
ld a,4
ld [height],a
ld a,[columntmp]
cp 7
jr nc,.notInc
inc a
.notInc
ld d,a
jr .endif
.elsif
jr z,.then
cp 13
jr c,.else
ld a,12
ld [height],a
jr .endif
.else
ld a,20
ld [height],a
.endif

ld a,d
call isEven
jr nz,.else1
ld a,d
srl a
call isEven
jr nz,.else2
call floorDistance
sla a
sla a
inc a
jr .endif2
.else2
call ceilingDistance
sla a
sla a
inc a
.endif2
jr .endif1
.else1
ld a,1
.endif1

pop hl
pop de
pop bc

ret

ceilingDistance:
push bc

ld a,[height]
cp 20
jr nz,.else
ld a,[row]
cp 6
jr c,.notdec
dec a
.notdec
jr .endif
.else
ld a,[row]
ld b,9
sub b
.endif

pop bc

ret 

floorDistance:
push bc

ld a,[height]
cp 4
jr nz,.else
ld a,[row]
ld b,a
ld a,12
sub b
jr .endif
.else
ld a,[row]
ld b,a
ld a,20
sub b
.endif

pop bc

ret