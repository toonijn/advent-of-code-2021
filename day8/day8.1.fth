needs ../util/string.fth
needs ../util/io.fth

: process-line
    124 ( | ) split assert( 2 = )
    SWAP 1 CHARS + SWAP 1 CHARS -
    32 ( ) split assert( 4 = )
    0
    4 0 DO
        ( addr length count )
        SWAP DUP 2 =
        SWAP DUP 3 =
        SWAP DUP 4 =
        SWAP 7 =
        OR OR OR IF 
            1 +
        THEN
        SWAP DROP
    LOOP
    ROT ROT 2DROP +
;

: solve 
    depth 0 = IF


0 4096 ['] process-line read-lines
. CR

bye


    THEN
;

solve
