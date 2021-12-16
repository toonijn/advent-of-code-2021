needs ../util/string.fth
needs ../util/io.fth
needs ../util/grid.fth
needs ../util/heap.fth

: read-grid-line { grid line width addr u -- grid width line }
    width 0 <> IF
        assert( width u = )
    THEN

    u 0 DO
        addr I CHARS + c@ [char] 0 - grid line I grid-addr !
    LOOP

    grid line 1 + u
;

: dijkstra-encode { row col val -- encoded }
    val 32 LSHIFT col 16 LSHIFT row OR OR
;

: dijkstra-decode { encoded -- row col val }
    encoded $FFFF AND
    encoded 16 RSHIFT $FFFF AND
    encoded 32 RSHIFT
;

: dijkstra-less-than ( a b -- a<b )
    dijkstra-decode { v2 } 2DROP
    dijkstra-decode { v1 } 2DROP
    v1 v2 <
;

: dijkstra { grid }
    grid grid-shape grid-init { best }
    best 0 grid-fill
    100000 ['] dijkstra-less-than heap-init { queue }
    queue 0 0 0
    dijkstra-encode heap-add
    BEGIN
        queue heap-is-empty INVERT
    WHILE
        queue heap-pop dijkstra-decode { row col val }
        best row col grid-addr @ 0 = IF
            val best row col grid-addr !
            
            4 0 DO
                row I 1 AND I 2 AND 1 - * + { r }
                col 1 I 1 AND - I 2 AND 1 - * + { c }
                best r c grid-is-valid-position IF
                best r c grid-addr @ 0 = IF
                    queue r c val grid r c grid-addr @ + dijkstra-encode heap-add
                THEN THEN
            LOOP
        THEN
    REPEAT

    best best grid-shape 1 - SWAP 1 - SWAP grid-addr @
    best grid-data FREE THROW
    best FREE THROW
;

: solve 
    depth 0 = IF

    1000 1000 grid-init 0 0

    1000 ['] read-grid-line read-lines

    0 0 2SWAP grid-block-view { grid }

    grid dijkstra

    . CR

bye


    THEN
;

solve
