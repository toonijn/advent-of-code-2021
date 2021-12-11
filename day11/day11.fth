needs ../util/string.fth
needs ../util/io.fth
needs ../util/list.fth


100 CELLS ALLOCATE THROW CONSTANT octopusses

: print-octopusses
    10 0 DO
        octopusses I 10 * CELLS + 10 print-cells CR
    LOOP
;

: process-line { ( octopus-count ) addr u -- octopus-count }
    u 0 DO
        addr I CHARS + C@ 48 ( 0 ) - 
        SWAP 1 + SWAP OVER CELLS octopusses + !
    LOOP
;

: octopus-addr ( i j )
    10 * + CELLS octopusses +
;

: FOR-NEIGHBORS-internal
    2 POSTPONE LITERAL -1 POSTPONE LITERAL POSTPONE DO
; immediate

: FOR-NEIGHBORS 
    POSTPONE FOR-NEIGHBORS-internal
    POSTPONE FOR-NEIGHBORS-internal
    POSTPONE I POSTPONE 0<> POSTPONE J POSTPONE 0<>
    POSTPONE OR POSTPONE IF
; immediate

: END-NEIGHBORS
    POSTPONE THEN POSTPONE LOOP POSTPONE LOOP
; immediate

: is-valid-position { x y }
    x 10 < y 10 < x -1 > y -1 > AND AND AND
;

: inc-octopus { ( flashes ) x y -- ( flashes ) }
    x y octopus-addr
    1 OVER +! @ 10 = IF
        1 +
        FOR-NEIGHBORS 
            x I + y J + 2DUP is-valid-position IF
                RECURSE
            ELSE
                2DROP
            THEN
        END-NEIGHBORS
    THEN
;

: inc-octopusses ( flashes -- flashes )
    10 0 DO
    10 0 DO
        I J inc-octopus
    LOOP
    LOOP
;

: reset-octopusses
    100 0 DO
        octopusses I CELLS + { addr }
        addr @ 9 > IF
            0 addr !
        THEN
    LOOP
;

: next-step ( -- flashes )
    0
    inc-octopusses
    reset-octopusses
;

: solve 
    depth 0 = IF


-1 4096 ['] process-line read-lines DROP
print-octopusses CR
octopusses 100 CELLS CLONE { cloned-octopusses }

0 ( flashes )
100 0 DO 
    next-step +
LOOP
."  First star: " . CR

cloned-octopusses octopusses 100 CELLS MOVE
cloned-octopusses FREE THROW

0
BEGIN
1 +
next-step
100 = UNTIL
." Second star: " . CR

bye


    THEN
;

solve
