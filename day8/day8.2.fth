needs ../util/string.fth
needs ../util/io.fth
needs ../util/itertools.fth

256 CONSTANT segment-mapping-size
segment-mapping-size CELLS ALLOCATE THROW CONSTANT segment-mapping
segment-mapping segment-mapping-size CELLS -1 FILL

(  gfedcba )
0 %1110111 CELLS segment-mapping + !
1 %0100100 CELLS segment-mapping + !
2 %1011101 CELLS segment-mapping + !
3 %1101101 CELLS segment-mapping + !
4 %0101110 CELLS segment-mapping + !
5 %1101011 CELLS segment-mapping + !
6 %1111011 CELLS segment-mapping + !
7 %0100101 CELLS segment-mapping + !
8 %1111111 CELLS segment-mapping + !
9 %1101111 CELLS segment-mapping + !
(  gfedcba )

: parse-7-segment { addr l -- bitstring }
    0
    l 0 DO
        1 addr I CHARS + c@ 97 ( a ) - LSHIFT OR
    LOOP
;

: apply-permutation { permutation n u -- v ( with the bits permuted ) }
    0
    n 0 DO
        u I RSHIFT 1 AND
        permutation I CELLS + @ LSHIFT
        OR
    LOOP
;

: per-permutation { ( total-sum ) found unknown-displays seen-displays permutation n -- found unknown-displays seen-displays }
    found IF
        TRUE
    ELSE
        0
        10 0 DO
            permutation n seen-displays I CELLS + @ apply-permutation CELLS segment-mapping + @
            -1 <> IF
                1 +
            THEN
        LOOP
        10 = DUP IF
            SWAP
            0
            4 0 DO
                10 *
                permutation n unknown-displays 3 I - CELLS + @ apply-permutation CELLS segment-mapping + @
                assert( DUP -1 <> ) +
            LOOP
            + SWAP
        THEN
    THEN
    unknown-displays seen-displays
;

: process-line
    124 ( | ) split assert( 2 = )
    4 CELLS ALLOCATE THROW { unknown-displays }
    10 CELLS ALLOCATE THROW { seen-displays }

    SWAP 1 CHARS + SWAP 1 CHARS -
    32 ( ) split assert( 4 = )
    4 0 DO
        parse-7-segment unknown-displays I CELLS + !
    LOOP

    1 -
    32 ( ) split assert( 10 = )
    10 0 DO
        parse-7-segment seen-displays I CELLS + !
    LOOP

    FALSE unknown-displays seen-displays 7 ['] per-permutation permutations
    FREE THROW FREE THROW
    ASSERT( TRUE = )
;

: solve 
    depth 0 = IF


0 4096 ['] process-line read-lines
. CR

bye


    THEN
;

solve
