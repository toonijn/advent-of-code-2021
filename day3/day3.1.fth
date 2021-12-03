INCLUDE ../util.fth

: zero 48 ;
: one 49 ;

: process-line { buffer length } ( word-length output-buffer )
    length MAX SWAP
    length 0 DO
        DUP I CELLS + DUP
        @ 1
        I buffer + C@ zero = IF - else + THEN
        SWAP !
    LOOP
    SWAP
;

: print-cells
    0 DO
        space DUP I CELLS + @ .
    LOOP
    DROP
;

: gamma
    ( buffer width)
    0 SWAP
    0 DO
        ( buffer inc )
        2 *
        OVER I CELLS + @ 0 > IF
             1 +
        THEN
    LOOP
    SWAP DROP
;

: epsilon
    1 SWAP LSHIFT 1 - SWAP XOR
;

100 CELLS ALLOCATE THROW DUP 100 CELLS 0 FILL ( buffer )
0 ( width )
256 ' process-line read-lines
2DUP print-cells CR
( buffer width )
2DUP gamma
( buffer width gamma)
2DUP SWAP epsilon
( buffer width gamma epsilon)
* . CR
DROP FREE


bye
