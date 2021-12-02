INCLUDE ../util.fth

: process-line { buffer length }
    buffer length split
    assert( 2 = )
    DUP length SWAP buffer - - parse-number
    { instr amount }
    instr length s" forward" starts-with IF
        SWAP amount + SWAP
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

0 0 ( x y )
256 ' process-line read-lines 
* . CR

bye
