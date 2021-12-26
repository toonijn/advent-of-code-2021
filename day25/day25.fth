needs ../util/io.fth
needs ../util/switch.fth
needs ../util/grid.fth

: parse-line { grid rows cols addr u -- grid rows cols }
    grid rows 1 +
    cols 0 <> IF assert( u cols = ) THEN
    u
    u 0 DO
        SWITCH addr I CHARS + c@ ['] =
        S-CASE [char] . S-IF 0
        S-CASE [char] > S-IF 1
        S-CASE [char] v S-IF 2
        S-END
        grid rows I grid-addr ! 
    LOOP
;

: move-right { grid -- moved }
    grid grid-shape { rows cols }
    rows cols grid-init { copy }
    grid copy grid-copy

    0
    cols 0 DO rows 0 DO
        J 1 + cols MOD { J' }
        copy I J grid-addr @ 1 =
        copy I J' grid-addr @ 0 = AND IF
            0 grid I J grid-addr !
            1 grid I J' grid-addr !
            1 +
        THEN
    LOOP LOOP 

    copy grid-data free throw
    copy free throw
;

: move-down { grid -- moved }
    grid grid-shape { rows cols }
    rows cols grid-init { copy }
    grid copy grid-copy

    0
    cols 0 DO rows 0 DO
        I 1 + rows MOD { I' }
        copy I J grid-addr @ 2 =
        copy I' J grid-addr @ 0 = AND IF
            0 grid I J grid-addr !
            2 grid I' J grid-addr !
            1 +
        THEN
    LOOP LOOP 

    copy grid-data free throw
    copy free throw
;

: next-step { grid -- moved }
    grid move-right
    grid move-down +
;

: solve
depth 0 = IF

    1000 1000 grid-init 0 0
    1000 ['] parse-line read-lines
    0 0 2SWAP grid-block-view { grid }

    0
    BEGIN
        1 +
        grid next-step 0 <>
    WHILE REPEAT
    . CR

bye
    THEN
;

solve
