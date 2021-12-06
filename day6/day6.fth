needs ../util.fth

10 CONSTANT fish-counts-size
fish-counts-size CELLS ALLOCATE THROW CONSTANT fish-counts
fish-counts fish-counts-size CELLS 0 FILL

: process-line
    44 ( , ) split
    0 DO
        parse-number CELLS fish-counts + DUP @ 1 + SWAP !
    LOOP
;

: next-day
    fish-counts @ { procreate }
    fish-counts-size 1 DO
        fish-counts I CELLS + DUP @ SWAP 1 CELLS - !
    LOOP
    fish-counts 8 CELLS + DUP @ procreate + SWAP !
    fish-counts 6 CELLS + DUP @ procreate + SWAP !
;

: count-fishes
    0
    fish-counts-size 0 DO
        fish-counts I CELLS + @ +
    LOOP
;

: solve 
    depth 0 = IF


2048 ['] process-line read-lines

80 0 DO
    next-day
LOOP

." 80 days: " count-fishes . CR

256 80 - 0 DO
    next-day
LOOP

." 256 days: " count-fishes . CR

bye


    THEN
;

solve
