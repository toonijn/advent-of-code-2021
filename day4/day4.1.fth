needs ../util.fth

20000 CONSTANT line-buffer-size
line-buffer-size 2 + ALLOCATE THROW CONSTANT line-buffer

: read-next-line ( -- addr u flag )
    line-buffer line-buffer-size stdin READ-LINE THROW
    { error }
    line-buffer SWAP error
;

: 2PICK { n }
    n PICK n PICK
;

: DROP-N 0 DO DROP LOOP ;

: process-numbers { addr length }
    addr length 44 ( , ) SPLIT { number-count }
    number-count CELLS ALLOCATE THROW { numbers }
    number-count 0 DO
        number-count I - 2 * 1 - 2PICK parse-number numbers I CELLS + !
    LOOP
    number-count 2 * DROP-N
    numbers number-count
;

: parse-board-line { write-to -- }
    read-next-line assert( TRUE = ) 2DUP 32 48 c-replace
    assert( 14 = )
    5 0 DO
        DUP I 3 * CHARS + 2 
        parse-number write-to I CELLS + !
    LOOP
    DROP
;

: print-board ( addr -- )
    25 print-cells
;

: parse-board ( -- addr )
    25 CELLS ALLOCATE THROW
    5 0 DO
        DUP I 5 * CELLS + parse-board-line
    LOOP
    dup print-board CR
;

: read-boards
    300 CELLS ALLOCATE THROW { boards }
    0
    BEGIN
        read-next-line
        WHILE
        2DROP
        parse-board
        boards 2 PICK CELLS + !
        1+
    REPEAT
    2DROP
    boards SWAP
;

: sum-board { board }
    0 ( sum )
    25 0 DO
        board I CELLS + @ DUP -1 > IF
            +
        ELSE
            DROP
        THEN
    LOOP
;

: row-full { addr step -- if-row-full } 
    TRUE
    5 0 DO
        addr I step * CELLS + @ -1 = AND
    LOOP
;

: has-won { board -- if-won }
    FALSE
    5 0 DO
        board I CELLS + 5 row-full OR
        board I 5 * CELLS + 1 row-full OR
    LOOP
;

: score-board { board -- sum }
    0
    25 0 DO
        board I CELLS + @ DUP -1 <> IF
            +
        ELSE
            DROP
        THEN
    LOOP
;

: call-number { boards board-count number -- has-won }
    FALSE
    board-count 0 DO
        boards I CELLS + @ ( board )
        DUP 25 number -1 replace
        DUP has-won IF
            score-board ." Won: " number * . CR
            TRUE OR
        else
            DROP
        then
    LOOP
;

: play-game 
    read-next-line assert( TRUE = ) process-numbers { numbers numbers-count }
    read-boards { boards board-count }

    boards board-count print-cells CR

    FALSE
    numbers-count 0 DO 
        DUP FALSE = IF
            boards board-count numbers I CELLS + @  call-number OR
        THEN
    LOOP
;

: solve 
    depth 0 = IF
        play-game  
        bye
    THEN
;

solve
