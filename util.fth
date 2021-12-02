: split { buffer length -- p1 p2 .. pn n }
    buffer
    1
    length 0 DO
        buffer I + C@ BL = IF 
            1+
            buffer I + 1+ SWAP
        THEN
    LOOP
;

: starts-with { haystack_addr haystack_length needle_addr needle_length }
    needle_length haystack_length > IF
        false
    ELSE
        true
        needle_length 0 DO
            haystack_addr I + C@ needle_addr I + C@ <> IF
                DROP false
            THEN
        LOOP
    THEN
;

: parse-number
    0 0 2SWAP >NUMBER 2DROP DROP
;

: read-lines { max-line-size line-processor }
    max-line-size 2 + ALLOCATE THROW
    { buffer }
    BEGIN
        buffer
        max-line-size
        stdin READ-LINE THROW
    WHILE
        buffer SWAP
        line-processor EXECUTE
    REPEAT
    DROP
    buffer FREE THROW
;
