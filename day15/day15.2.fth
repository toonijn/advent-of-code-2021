FALSE needs day15.1.fth DROP

: grid-copy-inc 9 MOD { src dst inc -- }
    src grid-shape { row col }
    assert( dst grid-shape col = SWAP row = AND )
    col 0 DO
    row 0 DO
        src I J grid-addr @ inc +
        DUP 9 > IF 9 - THEN
        dst I J grid-addr !
    LOOP LOOP
;

: solve-2
    depth 0 = IF

    1000 1000 grid-init { full-grid } full-grid 0 0

    1000 ['] read-grid-line read-lines

    0 0 2SWAP grid-block-view { base }
    base grid-shape { r c }
    5 0 DO
    5 0 I 0 = IF 1 + THEN DO
        full-grid r I * c J * r c grid-block-view
        base OVER I J + grid-copy-inc
        FREE THROW
    LOOP
    LOOP

    full-grid 0 0 r 5 * c 5 * grid-block-view { grid }

    grid dijkstra
    
    . CR
bye


    THEN
;

solve-2
