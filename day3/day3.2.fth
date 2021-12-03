INCLUDE ../util.fth

: zero 48 ;
: one 49 ;

: process-line { buffer length }
    ( width output )
    SWAP DUP 0 = IF DROP length THEN
    assert( DUP length = ) SWAP
    length 0 DO
        DUP buffer I + C@ SWAP C!
        1+
    LOOP
;

: print-cells
    0 DO
        space DUP I CELLS + @ .
    LOOP
    DROP
;

: all-words-size 20000 ;

: most-common { words width count }
    0
    count 0 DO
        1 words width I * + C@ zero = IF - else + then
    LOOP
    0 < if zero else one then
;

: least-common most-common 97 SWAP - ; 

: filter { words width word-count index correct }
    words words
    ( to from )
    word-count 0
    DO
        DUP index + C@ correct = IF 

            SWAP 2DUP width CMOVE
            width + SWAP
            ( DUP width TYPE space )
        THEN
        width +
    LOOP
    ( CR )
    DROP words - width /
;

: parse-bin { addr length }
    ( addr length TYPE )
    0
    length 0 DO
        2 * addr I CHARS + C@ one = if 1 + then
    LOOP
;


: solve { words width word-count commonness }
    word-count
    width 0
    DO
        DUP 1 > IF
            words width 2 PICK I 
                words I CHARS + width 3 PICK commonness EXECUTE
            filter
            SWAP DROP
        THEN
    LOOP
    assert( 1 = )
    words width parse-bin
;


: solve-all
    all-words-size ALLOCATE THROW DUP all-words-size 0 FILL ( buffer )
    { filtered-words }
    all-words-size ALLOCATE THROW DUP all-words-size 0 FILL ( buffer )
    0 OVER
    ( all-words  width  all-words-offset)
    1024 ['] process-line read-lines 2 PICK - OVER /
    { all-words width  word-count }
    all-words filtered-words all-words-size  CMOVE
    filtered-words width word-count ['] most-common solve

    all-words filtered-words all-words-size  CMOVE
    filtered-words width word-count ['] least-common solve


    all-words FREE THROW filtered-words FREE THROW 
;


solve-all 
* .
bye
