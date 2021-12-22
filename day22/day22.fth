needs ../util/string.fth
needs ../util/io.fth

: interval-pack ( start end -- v )
    2147483648 + 32 LSHIFT SWAP 2147483648 + OR 
;

: interval-unpack { v -- start end }
    v 4294967295 AND 2147483648 - v 32 RSHIFT 2147483648 - 
;

: interval-disjoint { v1 v2 }
    v1 interval-unpack { s1 e1 }
    v2 interval-unpack { s2 e2 }
    e1 s2 < s1 e2 < OR
;

: inverval-union-init { -- addr }
    3 vector-init
;

: inverval-union-add { addr interval -- }
    addr interval vector-add
    addr ['] < vector-sort
    1 ( index )
    BEGIN DUP addr vector-size < WHILE
        addr OVER vector-addr
        DUP 1 CELLS - @ swap @ interval
        1 + 
    REPEAT
;

: solve
depth 0 = IF

    200 ['] parse-line read-lines

    BEGIN
    DUP 1000 < WHILE
    2SWAP
    make-move
    REPEAT

    2 PICK  die-roll-count * . CR

bye
    THEN
;

solve
