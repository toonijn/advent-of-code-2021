: read-lines { max-line-size line-processor }
    max-line-size 2 + ALLOCATE THROW
    { buffer }
    BEGIN
        buffer max-line-size stdin READ-LINE THROW
    WHILE
        buffer SWAP
        line-processor EXECUTE
    REPEAT
    DROP
    buffer FREE THROW
;

: print-cells
    0 DO
        space DUP I CELLS + @ .
    LOOP
    DROP
;
