needs ../util/string.fth
needs ../util/io.fth
needs ../util/switch.fth

-2 CONSTANT EMPTY
-1 CONSTANT PAIR

: snailfish-new ( -- addr )
    64 cells ALLOCATE THROW
    65 0 DO
        EMPTY OVER I CELLS + !
    LOOP
;

: snailfish-copy { src src-offset dst dst-offset -- }
    assert( dst-offset 64 < src-offset 64 < AND )
    src src-offset CELLS + @
    assert( DUP EMPTY <> )
    DUP dst dst-offset CELLS + !
    PAIR = IF
        src src-offset 2 * dst dst-offset 2 * RECURSE
        src src-offset 2 * 1 + dst dst-offset 2 * 1 + RECURSE 
    THEN
;

: snailfish-print-internal { a offset }
    a offset CELLS + @
    assert( DUP EMPTY <> )
    DUP PAIR = IF
        DROP
        [char] [ emit
        a offset 2 * RECURSE
        [char] , emit
        a offset 2 * 1 + RECURSE
        [char] ] emit
    ELSE
        \ assert( DUP -1 > OVER 10 < AND )
        [char] 0 + emit
    THEN
;

: snailfish-print 1 snailfish-print-internal ;

: snailfish-next-index ( n offset direction -- index )
    { direction ( left = 0, right = 1) } SWAP { n }
    ( offset )
    BEGIN
    DUP 1 AND direction = OVER 1 <> AND
    WHILE
        2/
    REPEAT
    DUP 1 > IF
        1 XOR
        BEGIN
            n OVER CELLS + @ PAIR =
        WHILE 
           2 * 1 direction - +
        REPEAT
    ELSE
        DROP 0
    THEN
;

: snailfish-explode { n offset depth -- if-changed }
    n offset CELLS + @
    assert( DUP EMPTY <> )
    PAIR = IF
        depth 0 = IF
            n @ { n0 }
            n offset 2 * CELLS + @ 
            ( left ) n offset 0 snailfish-next-index
            CELLS n + +!

            n offset 2 * 1 + CELLS + @
            ( right ) n offset 1 snailfish-next-index
            CELLS n + +!

            0 n offset CELLS + !
            n0 n !
            TRUE
        ELSE
            n offset 2 * depth 1 - RECURSE
            DUP INVERT IF
                DROP n offset 2 * 1 + depth 1 - RECURSE
            THEN
        THEN
    ELSE
        FALSE
    THEN
;

: snailfish-split { n offset -- if-changed }
    n offset CELLS + @ { v }
    v PAIR = IF
        n offset 2 * RECURSE
        DUP INVERT IF
            DROP n offset 2 * 1 + RECURSE
        THEN
    ELSE
        v 9 > DUP IF
            PAIR n offset CELLS + !
            v 2 / n offset 2 * CELLS + !
            v 1 + 2 / n offset 2 * 1 + CELLS + !
        THEN
    THEN
;

: snailfish-reduce { n }
    BEGIN
        BEGIN
            n 1 4 snailfish-explode
        WHILE
        REPEAT
        n 1 snailfish-split
    WHILE
    REPEAT
;

: snailfish-add { a b -- a+b }
    snailfish-new { new }
    PAIR new 1 CELLS + !
    a 1 new 2 snailfish-copy
    b 1 new 3 snailfish-copy
    new snailfish-reduce
    new
;

: snailfish-magnitude-internal { n offset -- mag }
    n offset CELLS + @
    DUP PAIR = IF
        DROP
        n offset 2 * RECURSE 3 *
        n offset 2 * 1 + RECURSE 2 *
        +
    THEN
;

: snailfish-magnitude 1  snailfish-magnitude-internal ;

: snailfish-parse { addr u -- snailfish }
    snailfish-new { n }
    1 ( offset )
    u 0 DO
        SWITCH addr I CHARS + c@ ['] =
        S-CASE [char] [ S-IF
            PAIR OVER CELLS n + !
            2 *
        S-CASE [char] ] S-IF
            2/
        S-CASE [char] , S-IF
            1 +
        S-DEFAULT
            addr I CHARS + c@ [char] 0 - OVER CELLS n + !
        S-END
    LOOP
    DROP
    n
;

1000 CONSTANT snailfish-numbers-count
snailfish-numbers-count CELLS ALLOCATE THROW CONSTANT snailfish-numbers

: process-line ( count addr u -- count+1 )
    snailfish-parse
    OVER CELLS snailfish-numbers + !
    1 +
;

: solve 
depth 0 = IF
    0
    1000 ['] process-line read-lines
    { count }
    
    snailfish-numbers @ snailfish-numbers 1 CELLS + @
    snailfish-add
    count 2 DO
        DUP snailfish-numbers I CELLS + @
        snailfish-add
        SWAP FREE THROW
    LOOP 
    ." Total sum: " DUP snailfish-magnitude . CR
    FREE THROW


    0 ( max-add )
    count 0 DO
    count 0 DO
        snailfish-numbers I CELLS + @
        snailfish-numbers J CELLS + @
        snailfish-add
        DUP snailfish-magnitude
        SWAP FREE THROW
        MAX
    LOOP 
    LOOP
    ."   Max sum: " . CR

bye
    THEN
;

solve
