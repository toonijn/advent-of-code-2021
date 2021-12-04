needs ../util.fth
FALSE needs day4.1.fth DROP

: call-number-2 { boards board-count number -- has-won }
    board-count 0 DO
        boards I CELLS + @ { board }
        board @ -2 <> IF
            board 25 number -1 replace
            board has-won IF
                board score-board ." Won: " number * . CR
                -2 board !
            then
        THEN
    LOOP
;

: play-game -2
    read-next-line assert( TRUE = ) process-numbers { numbers numbers-count }
    read-boards { boards board-count }

    boards board-count print-cells CR

    numbers-count 0 DO 
        boards board-count numbers I CELLS + @  call-number-2
    LOOP
;

: solve-2
    depth 0 = IF
        play-game  
        bye
    THEN
;

solve-2
