: split-simple { buffer length -- p1 p2 .. pn n }
    buffer
    1
    length 0 DO
        buffer I + C@ BL = IF 
            1+
            buffer I + 1+ SWAP
        THEN
    LOOP
;

: split { buffer length chr -- p1 n1 p2 n2 .. pi ni i }
    buffer
    1
    length 0 DO
        ( last-position count )
        buffer I CHARS + C@ chr = IF 
            1+
            OVER buffer I + SWAP - SWAP
            buffer I + 1+ SWAP
        THEN
    LOOP
    OVER
    buffer length + SWAP - SWAP
;

: c-replace { ( addr u ) from to }
    0 DO
        ( addr )
        DUP I CHARS + DUP C@ from = IF 
            to SWAP C!
        ELSE
            DROP
        THEN
    LOOP
    DROP
;

: replace { ( addr u ) from to }
    0 DO
        ( addr )
        DUP I CELLS + DUP @ from = IF 
            to SWAP !
        ELSE
            DROP
        THEN
    LOOP
    DROP
;

: swap! { addr1 addr2 }
    addr1 @ addr2 @ addr1 ! addr2 !
;

: sum { addr u }
    0
    u 0 DO
        addr I CELLS + @ +
    LOOP
;

: print-cells
    0 DO
        space DUP I CELLS + @ .
    LOOP
    DROP
;

: sort { addr u less-than }
    u 1 > IF
        addr @ { pivot }
        addr u CELLS + addr 1 CELLS + 
        ( end start )
        u 1 DO
            DUP @ pivot SWAP less-than EXECUTE IF ( pivot < start @ )
                SWAP 1 CELLS - SWAP
                2dup swap!
            ELSE
                1 CELLS +
            THEN
        LOOP
        assert( OVER = ) DUP 1 CELLS - addr swap! { mid }

        mid addr - 1 - 1 CELLS / { n1 }
        addr n1 less-than RECURSE
        mid u n1 - 1 - less-than RECURSE
    THEN
;

: starts-with { haystack_addr haystack_length needle_addr needle_length }
    needle_length haystack_length > IF
        false
    ELSE
        true
        needle_length 0 DO
            haystack_addr I + C@ needle_addr I + C@ <> IF
                DROP false
            THEN
        LOOP
    THEN
;

: parse-number ( addr length )
    0 0 2SWAP >NUMBER 2DROP DROP
;

: read-lines { max-line-size line-processor }
    max-line-size 2 + ALLOCATE THROW
    { buffer }
    BEGIN
        buffer max-line-size stdin READ-LINE THROW
    WHILE
        buffer SWAP
        line-processor EXECUTE
    REPEAT
    DROP
    buffer FREE THROW
;
