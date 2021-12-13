: grid-init { rows cols -- grid }
    5 CELLS ALLOCATE THROW { grid }
    rows cols * CELLS DUP ALLOCATE THROW { data }
    data SWAP 0 FILL
    
    ( rows ) rows grid !
    ( cols ) cols grid 1 CELLS + !
    ( row-stride ) cols grid 2 CELLS + !
    ( col-stride ) 1 grid 3 CELLS + !
    ( data ) data grid 4 CELLS + !
    grid
;

: grid-shape { grid -- rows cols }
    grid @ grid 1 CELLS + @
;

: grid-stride { grid -- row-stride col-stride }
    grid 2 CELLS + @ grid 3 CELLS + @
;

: grid-data { grid -- data }
    grid 4 CELLS + @
;

: grid-is-valid-position { grid row col }
    grid grid-shape { rows cols }
    -1 row < -1 col < row rows < col cols < AND AND AND 
;

: grid-addr { grid row col -- addr }
    assert( grid row col grid-is-valid-position )
    grid grid-stride { r c }
    grid grid-data row r * col c * + CELLS +
;

: grid-shallow-copy { src }
    5 CELLS ALLOCATE THROW { dst }
    src dst 5 CELLS MOVE
    dst
;

: grid-block-view { src row col rows cols -- block }
    src grid-shallow-copy { grid }
    ( rows ) rows grid !
    ( cols ) cols grid 1 CELLS + !
    ( data ) src row col grid-addr grid 4 CELLS + !
    grid
;

: grid-transpose { grid -- }
    grid grid-shape { rows cols }
    grid grid-stride { rs cs }
    ( rows ) cols grid !
    ( cols ) rows grid 1 CELLS + !
    ( row-stride ) cs grid 2 CELLS + !
    ( col-stride ) rs grid 3 CELLS + !
;

: grid-flip-horizontal { grid -- }
    grid 1 CELLS + @ { cols } 
    grid 3 CELLS + @ { col-stride }
    ( col_stride ) col-stride negate grid 3 CELLS + !
    col-stride cols 1 - * CELLS grid 4 CELLS + +!
;

: grid-flip-vertical { grid -- }
    grid @ { rows } 
    grid 2 CELLS + @ { row-stride }
    ( row-stride ) row-stride negate grid 2 CELLS + !
    row-stride rows 1 - * CELLS grid 4 CELLS + +!
;

: grid-print { grid }
    grid grid-shape { rows cols }
    rows 0 DO
        cols 0 DO
            grid J I grid-addr @ .
        LOOP
        CR
    LOOP
;
