SECTION "SubFunctions",ROM0

stringSize:
push af
push hl

ld hl,Message
ld c,0
.while
inc c
ld a,[hl+]
cp 0
jr nz,.while
dec c

pop hl
pop af

ret

encodeRightLeft:
sla a
sla a
sla a
sla a
srl b
srl b
srl b
srl b
or b

ret

isEven: ;takes a as an input and check if a is even
cp 2
jr c,.endif
.mod2
sub 2
cp 2
jr c,.endif
jr .mod2
.endif
cp 0

ret

moduloE: ;similar to isEven, but takes also e as modulo
cp e
jr c,.endifmod
.mod
sub e
cp e
jr c,.endifmod
jr .mod
.endifmod

ret 
