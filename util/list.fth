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

: contains { addr u needle -- if-contains }
    FALSE
    u 0 > IF
        u 0 DO
            addr I CELLS + @ needle = OR
        LOOP
    THEN
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
