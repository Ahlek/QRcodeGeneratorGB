SECTION "SubFunctions",ROM0

waitVblank:
ld a,[$FF44]
cp 145
jr nz, waitVblank
ret

stringSize:
push af
push hl

ld hl,MESSAGE
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

lowbeep:
  call   setsnd
  ld     a,%00000000
  ldh    [$13],a
  ld     a,%11000111
  ldh    [$14],a
  ret


hibeep:
  call   setsnd
  ld     a,%11000000
  ldh    [$13],a
  ld     a,%11000111
  ldh    [$14],a
  ret

setsnd:
  ld     a,%10000000
  ldh    [$26],a

  ld     a,%01110111
  ldh    [$24],a
  ld     a,%00010001
  ldh    [$25],a

  ld     a,%10111000
  ldh    [$11],a
  ld     a,%11110000
  ldh    [$12],a
  ret
