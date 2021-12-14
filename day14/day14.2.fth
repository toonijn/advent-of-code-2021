needs ../util/string.fth
needs ../util/io.fth
needs ../util/grid.fth

26 26 * CHARS ALLOCATE THROW CONSTANT rules
rules 26 26 * CHARS 0 FILL

( left right depth frequency-table )
26 26 * 100 * 26 * CONSTANT cache-size
cache-size CELLS ALLOCATE THROW CONSTANT cache
cache cache-size CELLS -1 FILL

: cache-addr ( a b d -- freq-table )
    26 * + 26 * + 26 * CELLS cache +
;

: read-rule { addr u -- }
    assert( u 7 = )
    addr 6 CHARS + c@ [char] A -
    addr c@ [char] A -
    addr 1 CHARS + c@ [char] A -
    ( c a b ) 26 * + CHARS rules + c!
;

: get-rule ( a b -- c )
    26 * + CHARS rules + c@
;

: add-frequencies { src dst -- }
    26 0 DO
        src I CELLS + @ dst I CELLS + +! 
    LOOP
;

: get-count { a b d -- addr }
    a b d cache-addr { addr }
    addr @ -1 = IF
        addr 26 CELLS 0 FILL
        d 0 = IF
            1 addr a CELLS + +!
            1 addr b CELLS + +!
        ELSE
            a b get-rule { c }
            c -1 = IF
                a b d 1 - RECURSE
            ELSE
                a c d 1 - RECURSE
                c b d 1 - RECURSE
            THEN
            addr 26 CELLS MOVE
            c -1 <> IF
                addr add-frequencies
                -1 addr c CELLS + +! 
            THEN
        THEN
    THEN
    addr
;

: get-count-str { addr u depth -- freq }
    26 CELLS ALLOCATE THROW { freq }
    freq 26 CELLS 0 FILL
    1 freq addr c@ [char] A - CELLS + +!
    u 1 DO
        addr I 1 - CHARS + c@ [char] A -  { prev } prev
        addr I CHARS + c@ [char] A -
        depth get-count freq add-frequencies 
        -1 freq prev CELLS + +!
    LOOP
    freq
;

: highest { freq }
    0
    26 0 DO
        freq I CELLS + @ MAX
    LOOP
;

: lowest { freq }
    100000000000000
    26 0 DO
        freq I CELLS + @ DUP 0 <> IF
            MIN
        ELSE DROP THEN
    LOOP
;

: solve 
    depth 0 = IF

    102 CHARS ALLOCATE THROW
    
    DUP 100 stdin READ-LINE THROW assert( TRUE = )

    0 1 stdin READ-LINE THROW assert( TRUE = ) assert( 0 = )

    10 ['] read-rule read-lines
    
    40 get-count-str

    DUP 26 print-cells CR

    DUP highest SWAP lowest - . CR

bye


    THEN
;

solve
