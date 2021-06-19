SECTION "Error Correction Coding",ROM0

correctionCoding:
push af 		;The purpose of this part of code is to perform each step of the long polynomial division (whose remainders are the error correction codewords)
				;Each stage of 1 step is described here :
push bc 		;1-Find the value of the first rem coefficient in galois field power of 2 (aka P) (Aim to delete the first term of rem, cf while1)
push de 		;2-Multiply α power P with α power "list Generator" : The output is in tmplist (cf for) (It means add the powers together)
push hl 		;2b-If added powers are >255 we apply modulo 255 (cf for)
 				;3-Obtain the exact value of each α power "anything" by seeking into Powers2 list (the result is stored in tmplist) (cf for 1 and 2)
ld hl,Powers2 	;4-Substract the two lists (rem and tmplist) : we're working in GF(2^8) so addition = subtraction = xor (cf while2)
ld de,MSG_REMAINDER
.whilePNotFind 		;Stage 1
ld a,[hl+] 			;Each number is represented one time in powers2 list :
ld b,a 				;Any number between 0 and 255 for index have another number between 0 and 255 in the list
ld a,[de]
cp b
jr nz,.endif1
ld a,l
dec a
ld [P],a
jr .endPFind
.endif1
jr .whilePNotFind 	;Since each number is represented, no need to have a counter for this while (maybe prevent bugs ?)
.endPFind

ld b,8
ld hl,Generator ;Stage 2
ld de,TMP_LIST		;tmplist
.for
ld a,[P]
ld c,a
ld a,[hl+]
add c
jr nc,.lessThan255 ;Stage 2-b
sub 255 			
cp 255
jr nz,.lessThan255
sub 255
.lessThan255
ld [de],a
inc de
dec b
jr nz,.for

ld bc,TMP_LIST 	;Stage 3
.for1
ld hl,Powers2
.for2
ld a,[bc]
ld d,a
ld a,l
cp d
jr nz,.endiffor2false
ld a,[hl]
ld [bc],a
jr .endiffor2true
.endiffor2false
inc l
ld a,l
cp 0
jr nz,.for2
.endiffor2true
inc bc
dec e
jr nz,.for1

ld hl,TMP_LIST 	;Stage 4
ld bc,MSG_REMAINDER
.while2
ld a,[hl+]
ld d,a
ld a,[bc]
xor d
ld [bc],a
inc bc
ld a,l
cp 8
jr nz,.while2

pop hl
pop de
pop bc
pop af

ret