INCLUDE ../util.fth

: process-line { buffer length }
    buffer length split-simple
    assert( 2 = )
    DUP length SWAP buffer - - parse-number
    { instr amount }
    instr length s" forward" starts-with IF
        { x y aim }
        x amount +
        y aim amount * +
        aim
    ELSE
        instr length s" down" starts-with IF
            amount +
        ELSE
            instr length s" up" starts-with IF
                amount -
            THEN
        THEN
    THEN
;

0 0 0 ( x y aim )
256 ' process-line read-lines 
DROP * . CR

bye
