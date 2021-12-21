needs ../util/string.fth
needs ../util/io.fth

: parse-line ( addr u -- pos score )
    [char] : split assert( 2 = )
    2swap 2drop
    1 - SWAP 1 CHARS + SWAP
    parse-number 0
;

: make-move { pos score die -- pos score }
    pos die +
    1 - 10 MOD 1 + DUP score +
;


11 11 * 21 * 21 * 2 * DUP CELLS ALLOCATE THROW CONSTANT cache
cache SWAP CELLS -1 FILL

: count-wins { turn pa sa pb sb -- count }
    sa 20 > IF
        1
    ELSE sb 20 > IF
        0
    ELSE
        pa 11 * pb + 21 * sa + 21 * sb + 2 * turn IF 1 ELSE 0 THEN + { key }
        cache key CELLS + @ DUP -1 = IF DROP
            0
            4 1 DO I { d1 }
            4 1 DO I { d2 }
            4 1 DO I { d3 }
                turn INVERT pa sa pb sb
                turn IF 2SWAP THEN
                d1 d2 d3 + + make-move
                turn IF 2SWAP THEN
                RECURSE +
            LOOP
            LOOP
            LOOP
            dup cache key CELLS + !
        THEN
        \ turn IF 1 ELSE 2 THEN  . pa . sa . pb . sb . ." : " DUP . CR
    THEN THEN
;

: -ROT5 { a b c d e }
    e a b c d
;

: solve
depth 0 = IF

    200 ['] parse-line read-lines

    2OVER 2OVER TRUE -ROT5 count-wins { win1 }
    2SWAP FALSE -ROT5 count-wins { win2 }

    win1 win2 MAX . CR
bye
    THEN
;

solve
