needs ../util/string.fth
needs ../util/io.fth
needs ../util/grid.fth

100000 CONSTANT polymer-size
256 256 * CHARS ALLOCATE THROW CONSTANT rules
rules 256 256 * CHARS 0 FILL

: read-rule { addr u -- }
    assert( u 7 = )
    addr 6 CHARS + c@
    addr c@
    addr 1 CHARS + c@ 
    ( c a b ) 256 * + CHARS rules + c!
;

: get-rule ( a b -- c )
    256 * + CHARS rules + c@
;

: apply-rules { src src-u dst -- dst-u }
    1 ( dst-ptr )
    src c@  ( prev )
    DUP dst c!
    src-u 1 DO
        src I CHARS + c@ { v }
        v get-rule { r }
        r 0 <> IF
            dst OVER CHARS + r SWAP c!
            1 +
        THEN
        dst OVER CHARS + v SWAP c!
        1 + v
    LOOP
    DROP
;

: frequencies { addr u -- table }
    256 CELLS ALLOCATE THROW
    DUP 256 CELLS 0 FILL
    u 0 DO
        1 OVER addr I CHARS + c@ CELLS + +!
    LOOP
;

: highest { freq }
    0
    256 0 DO
        freq I CELLS + @ MAX
    LOOP
;

: lowest { freq }
    100000000000
    256 0 DO
        freq I CELLS + @ DUP 0 <> IF
            MIN
        ELSE DROP THEN
    LOOP
;

: solve 
    depth 0 = IF

    polymer-size 2 + CHARS ALLOCATE THROW
    polymer-size 2 + CHARS ALLOCATE THROW
    
    DUP polymer-size stdin READ-LINE THROW assert( TRUE = )

    2 PICK polymer-size stdin READ-LINE THROW assert( TRUE = ) assert( 0 = )

    10 ['] read-rule read-lines

    ( dst src src-u )
        .S CR
    10 0 DO
        I . ." : (" DUP . ." )  " 
        DUP 100 < IF
            2DUP TYPE
        THEN
        CR
        { u }
        2DUP SWAP u SWAP apply-rules { nu }
        SWAP nu
    LOOP

    frequencies
    DUP highest SWAP lowest - . CR

bye


    THEN
;

solve
