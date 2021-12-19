needs ../util/string.fth
needs ../util/io.fth
needs ../util/vector.fth
needs ../util/itertools.fth
needs ../util/switch.fth



: point-pack { x y z -- p }
    x 1048576 + 21 LSHIFT y 1048576 + OR 21 LSHIFT z 1048576 + OR
;

: point-unpack { p -- x y z }
    p 42 RSHIFT 2097151 AND 1048576 - 
    p 21 RSHIFT 2097151 AND 1048576 - 
    p 0 RSHIFT 2097151 AND 1048576 - 
;

: .point 
    point-unpack { x y z }
    ." (" x . ." ," y . ." ," z . ." )"
;

: apply-permutation { p perm -- p }
    p point-unpack
    perm 3 > IF SWAP THEN
    SWITCH perm 3 MOD ['] =
    S-CASE 1 S-IF ROT
    S-CASE 2 S-IF ROT ROT
    S-END
    point-pack
;


: transform { p permutation -- p }
    \ permutation . CR
    p permutation 4 / apply-permutation point-unpack
    permutation 4 MOD { sign }
    sign 1 AND 0<> IF
        NEGATE
    THEN ROT
    sign 2 AND 0<> IF
        NEGATE
    THEN ROT
    permutation 11 > sign 3 = sign 0 = OR = IF
        NEGATE
    THEN ROT
    point-pack
;

: point*s { p s -- p }
    p point-unpack s * ROT s * ROT s * ROT point-pack
;

: point+ { a b -- p }
    a point-unpack { x1 y1 z1 }
    b point-unpack { x2 y2 z2 }
    x1 x2 + y1 y2 + z1 z2 + point-pack
;

: parse-point
    [char] , split assert( 3 = )
    parse-number { z }
    parse-number { y }
    parse-number { x }
    x y z point-pack
;

: transform-points { points permutation }
    points vector-FOREACH
        DUP @
        permutation transform
        SWAP !
    vector-FOREACH-END
;

: scanned-init
    2 CELLS ALLOCATE THROW { scanned }
    3 vector-init DUP scanned ! ( centers )
    0 0 0 point-pack vector-add
    11 vector-init scanned 1 CELLS + ! ( beacons )
    scanned
;
: scanned-centers ( scanned -- center ) @ ;
: scanned-beacons ( scanned -- beacons ) 1 CELLS + @ ;

: scanned-copy { orig }
    2 CELLS ALLOCATE THROW { scanned }
    orig scanned-centers vector-copy scanned ! ( centers )
    orig scanned-beacons vector-copy scanned 1 CELLS + ! ( beacons )
    scanned
;

: scanned-free { scanned }
    scanned scanned-centers vector-free
    scanned scanned-beacons vector-free
    scanned free THROW
;

: scanned-transform { scanned permutation }
    scanned scanned-centers permutation transform-points
    scanned scanned-beacons permutation transform-points
;

: scanned-shift { scanned shift -- }
    scanned scanned-centers vector-FOREACH
        DUP @ shift point+ SWAP !
    vector-FOREACH-END
    scanned scanned-beacons vector-FOREACH
        DUP @ shift point+ SWAP !
    vector-FOREACH-END
;

: scanned-unshift ( scanned shift -- )
    -1 point*s scanned-shift
;

: process-line { ( scanners ) addr u -- scanners }
    u 0 > IF
        addr 1 CHARS + C@ [char] - = IF
            DUP 
            scanned-init vector-add
        ELSE
            DUP vector-last @ scanned-beacons addr u parse-point vector-add
        THEN
    THEN
;

: distance-oo ( p1 p2 -- d )
    -1 point*s point+ point-unpack
    ABS SWAP ABS MAX SWAP ABS MAX
;

: scanned-in-range { scanned point }
    FALSE
    scanned scanned-centers vector-FOREACH
        @ point distance-oo 1000 < OR
        DUP IF LEAVE THEN
    vector-FOREACH-END
;

: scanned-are-compatible-single { s1 s2 -- overlap }
    0 ( overlap )
    s2 scanned-beacons vector-FOREACH
        @ DUP s1 SWAP scanned-in-range IF
            s1 scanned-beacons SWAP ['] = vector-find -1 = IF
                DROP 0 LEAVE
            ELSE
                1 +
            THEN
        ELSE
            DROP
        THEN
    vector-FOREACH-END
;

: scanned-are-compatible { s1 s2 }
    s1 s2 scanned-are-compatible-single { overlap }
    overlap 11 > IF
        s2 s1 scanned-are-compatible-single 11 >
    ELSE
        FALSE
    THEN
;

: scanned-extend { s1 s2 }
    s1 scanned-centers { centers }
    s1 scanned-beacons { beacons }

    s2 scanned-centers vector-FOREACH
        @ DUP centers SWAP ['] = vector-find -1 = IF
            centers SWAP vector-add
        ELSE
            DROP
        THEN
    vector-FOREACH-END
    s2 scanned-beacons vector-FOREACH
        @ DUP beacons SWAP ['] = vector-find -1 = IF
            beacons SWAP vector-add
        ELSE
            \ ." Skip beacon: " DUP .point CR
            DROP
        THEN
    vector-FOREACH-END
;

: extend-try-shifts { scanned to-add -- did-extend }
    FALSE
    \ ." Size 1: " scanned scanned-beacons vector-size . CR
    \ ." Size 2: " to-add scanned-beacons vector-size . CR
    scanned scanned-beacons vector-FOREACH @ { to }
        to-add scanned-beacons vector-FOREACH @ { from }
            to from -1 point*s point+ { shift }
            \ ." shift: " shift .point CR
            \ ." center: " to-add scanned-centers 0 vector-addr @ .point CR
            to-add shift scanned-shift
            scanned to-add scanned-are-compatible IF
                scanned to-add scanned-extend
                DROP TRUE
                to-add shift scanned-unshift
                LEAVE
            THEN
            \ to-add shift scanned-unshift
        vector-FOREACH-END
        DUP IF LEAVE THEN
    vector-FOREACH-END
;

: extend-try-all { scanned to-add -- did-extend }
    FALSE
    \ ." center: " to-add scanned-centers 0 vector-addr @ .point CR
    24 0 DO
        to-add scanned-copy { copy }
        copy I scanned-transform
        \ ." beacon: " copy scanned-beacons vector-last @ .point CR
        scanned copy extend-try-shifts IF
            ." Permutation: " I . CR
            DROP TRUE
            copy scanned-free
            LEAVE
        THEN
        copy scanned-free
    LOOP
;

: solve 
depth 0 = IF


    11 vector-init
    1000 ['] process-line read-lines
    { scanners }

    scanners 0 vector-addr @ { connected }
    BEGIN
    scanners vector-size 1 >
    WHILE
    scanners vector-size
    DUP 1 DO
        ." Checking " I . CR
        connected scanners I vector-addr @ extend-try-all IF
            scanners vector-last @ scanners I vector-addr !
            scanners vector-pop DROP
            ." Added: " I . CR 
            ." To do: " scanners vector-size 1 - . CR
            LEAVE
        THEN
    LOOP
    \ scanners 1 vector-addr @ scanned-beacons vector-FOREACH
    \     @ .point ." , "
    \ vector-FOREACH-end CR

    assert( scanners vector-size > )
    REPEAT
    .S CR
    

bye
    THEN
;

solve
