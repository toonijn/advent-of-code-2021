needs ../util/string.fth
needs ../util/io.fth
needs ../util/list.fth


: is-open ( bracket )
    1 + 4 MOD 2 <
;

256 CELLS ALLOCATE THROW CONSTANT error-scores
3 error-scores 42 CELLS + !
57 error-scores 93 CELLS + !
1197 error-scores 125 CELLS + !
25137 error-scores 62 CELLS + !

: error-score ( bracket )
    CELLS error-scores + @
;

256 CELLS ALLOCATE THROW CONSTANT autocomplete-scores
1 autocomplete-scores 42 CELLS + !
2 autocomplete-scores 93 CELLS + !
3 autocomplete-scores 125 CELLS + !
4 autocomplete-scores 62 CELLS + !

: autocomplete-score ( bracket )
    CELLS autocomplete-scores + @
;

: DROPN 
    0 DO DROP LOOP
;

: parse-chunck { addr u -- error-points auto-points }
    depth { start-depth }
    addr u 41 42 c-replace ( ascii-hack )

    0
    u 0 DO
        DROP
        addr I CHARS + C@ { p }
        p is-open IF
            p 2 +
        ELSE
            0 I = IF 0 THEN
            p <> IF
                ." Found: " p . p emit CR
                p error-score
                LEAVE
            THEN
        THEN
        0
    LOOP
    { points }
    depth start-depth - { incomplete }
    incomplete 0 = points 0 = AND IF
        ." Correct" CR
        0 0
    ELSE points 0 = IF
        ( incomplete )
        0
        incomplete 0 DO
            5 *
            SWAP
            autocomplete-score +
        LOOP
        ." Incomplete: " DUP . CR
        0 SWAP
    ELSE
        ( wrong )
        incomplete DROPN
        points 0
    THEN THEN
;

1000 CELLS ALLOCATE THROW CONSTANT autocomplete

: process-line ( error-score auto-length addr u -- error-score auto-score )
    parse-chunck { es as }
    as 0 > IF
        DUP CELLS autocomplete + as SWAP ! 1 +
    THEN
    SWAP es + SWAP
;

: solve 
    depth 0 = IF


0 0 4096 ['] process-line read-lines { error-points auto-length }
autocomplete auto-length ['] < sort
CR
."        Error score: " error-points . CR
." Autocomplete score: " autocomplete auto-length 2 / CELLS + @ . CR


bye


    THEN
;

solve
