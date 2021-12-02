INCLUDE ../util.fth

: count-increasing { length }
    length 
    0
    length 1 + 2
    DO
        I PICK I 2 + PICK 
        > IF
          1+
        THEN
    LOOP
;

: count-increasing-3
    DUP { length }
    0
    length 1 - 2
    DO
        I PICK I 4 + PICK 
        > IF
          1+
        THEN
    LOOP
;

: sliding-sum { length window }
    length
    length 1 + window
    DO
        0
        window 0
        DO
            length I - 1 +
            PICK +
        LOOP
    LOOP
    length 2 -
;


: process-line
    parse-number
    SWAP 1+
;

0 ( number of items in list )
256 ' process-line read-lines
count-increasing ."  1: " . CR
count-increasing-3 ."  2: " . CR
3 sliding-sum count-increasing ." 2': " . CR

bye
