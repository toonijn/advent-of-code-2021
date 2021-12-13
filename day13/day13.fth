needs ../util/string.fth
needs ../util/io.fth
needs ../util/grid.fth

200 CONSTANT line-size
line-size 2 + CELLS ALLOCATE THROW CONSTANT line-buffer

0 CONSTANT offset-size ( kleine hack om overfold toe te laten, maak het rooster groter naar links en boven )
4000 CONSTANT max-size

: print-sheet { sheet }
    sheet grid-shape { rows cols }
    rows 0 DO
        cols 0 DO
            sheet J I grid-addr @ IF
                ." #"
            ELSE
                ." ."
            THEN
        LOOP
        CR
    LOOP
;

: merge-sheets { grid1 grid2 -- result }
    grid1 grid-shape { rows1 cols1 }
    grid2 grid-shape { rows2 cols2 }
    
    assert( rows1 rows2 < cols1 cols2 < OR INVERT )
    rows2 0 DO
    cols2 0 DO
        grid1 rows1 rows2 - J + cols1 cols2 - I + grid-addr DUP @
        grid2 J I grid-addr @
        OR SWAP !
    LOOP
    LOOP
;

: count-sheets { grid }
    0
    grid grid-shape { rows cols }
    rows 0 DO
    cols 0 DO
        grid J I grid-addr @ IF 1 + THEN
    LOOP
    LOOP
;

: read-sheet ( --  grid )
    offset-size max-size + DUP grid-init { grid }

    0 0 ( rows cols )
    BEGIN
        line-buffer line-size stdin READ-LINE THROW drop DUP
    WHILE
        line-buffer SWAP [CHAR] , split assert( 2 = )
        parse-number offset-size + { y }
        parse-number offset-size + { x }
        TRUE grid y x grid-addr !
        SWAP y 1 + MAX SWAP x 1 + MAX
    REPEAT DROP
    { rows cols }
    grid 0 0 rows cols grid-block-view
    grid free THROW
;

: solve 
    depth 0 = IF
    
    read-sheet
    DUP grid-shape * 100 < IF
        DUP print-sheet
    THEN


    BEGIN
        line-buffer line-size stdin READ-LINE THROW
    WHILE
        line-buffer SWAP [char] = split assert( 2 = )
        parse-number offset-size + { l }
        1 - CHARS + c@
        OVER grid-shape { rows cols }
        SWAP { sheet }
        [char] y = IF
            ." Fold vertical: " l . CR
            sheet 0 0 l cols grid-block-view
            sheet l 1 + 0 rows l 1 + - cols grid-block-view
            DUP grid-flip-vertical
        ELSE
            ." Fold horizontal: " l . CR
            sheet 0 0 rows l grid-block-view
            sheet 0 l 1 + rows cols l 1 + - grid-block-view
            DUP grid-flip-horizontal
        THEN
        2DUP merge-sheets
        FREE THROW
        sheet free throw
        ." Dots: " DUP count-sheets . CR
    REPEAT DROP
    
    DUP print-sheet

bye


    THEN
;

solve
