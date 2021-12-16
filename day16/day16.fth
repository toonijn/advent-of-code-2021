needs ../util/string.fth
needs ../util/io.fth
needs ../util/switch.fth


10000 CONSTANT line-size

1 CELLS ALLOCATE THROW CONSTANT version-sum

: to-bits { src u -- bits l }
    u 4 * CHARS ALLOCATE THROW { bits }
    u 0 DO
        src I CHARS + c@
        DUP [CHAR] A < IF
            [CHAR] 0 -
        ELSE
            [CHAR] A - 10 +
        THEN
        ( v )
        4 0 DO
            DUP 1 AND bits J 4 * 3 I - + CHARS + c!
            1 RSHIFT
        LOOP
        assert( 0 = )
    LOOP
    bits u 4 *
;

: next-number { bits length -- next-bits number}
    0
    length 0 DO
        2 *
        bits I CHARS + c@ +
    LOOP
    bits length CHARS + SWAP
;

: convert-bool
    IF 1 ELSE 0 THEN
;

: op< < convert-bool ;
: op> > convert-bool ;
: op= = convert-bool ;

: parse-packet ( bits -- bits value )
    3 next-number { version }
    version version-sum +!
    3 next-number { type }
    ." type: " type . ." , version: " version . CR
    SWITCH type ['] =
    S-CASE 4 S-IF 
        0 SWAP
        BEGIN
            1 next-number { continue }
            4 next-number { v }
            SWAP 16 * v + SWAP
        continue 1 = WHILE REPEAT
        SWAP
        ."  Literal: " DUP . CR
    S-DEFAULT
        SWITCH type ['] =
        S-CASE 0 S-IF ['] +
        S-CASE 1 S-IF ['] *
        S-CASE 2 S-IF ['] min
        S-CASE 3 S-IF ['] max
        S-CASE 5 S-IF ['] op>
        S-CASE 6 S-IF ['] op<
        S-CASE 7 S-IF ['] op=
        S-END { operator }


        ( bits )
        1 next-number 0 = IF
            15 next-number
            ."  Operator 0: " DUP . CR
            CHARS OVER + { end }
            RECURSE

            BEGIN
            OVER end <> WHILE
                SWAP RECURSE ROT SWAP .S CR operator EXECUTE
            REPEAT
        ELSE
            11 next-number { count }
            ."  Operator 1: " count . CR
            RECURSE
            count 1 > IF
                count 1 DO
                    ( bits v )
                    SWAP RECURSE ROT SWAP .S CR operator EXECUTE
                LOOP
            THEN
        THEN
    S-END
    ." end:" .S CR
;

: solve 
    depth 0 = IF
    
    line-size 2 + CHARS ALLOCATE THROW { line }
    line line-size stdin read-line DROP DROP
    line SWAP to-bits DROP
    line free throw

    ( bits )
    parse-packet { result }

    version-sum @ . CR
    result . CR




bye


    THEN
;

solve
