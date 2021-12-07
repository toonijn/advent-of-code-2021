needs ../util.fth

10000 CONSTANT crabs-size
crabs-size CELLS ALLOCATE THROW CONSTANT crabs

: process-line
    44 ( , ) split { crab-count }
    crab-count 0 DO
        parse-number crabs I CELLS + !
    LOOP
    crab-count +
;

: find-optimal { crab-count -- position fuel }
    0 crabs crab-count sum DUP
    ( best-position best-distance distance )
    crab-count 0 DO
        .S CR
        crabs I CELLS + @ { a }
        a 2 * -

        DUP I 1 + 2 * crab-count - a * + { current-distance }
        .S CR
        OVER current-distance > IF
            { _1 _2 distance }
            a current-distance distance
        THEN
    LOOP
    DROP
;

: solve 
    depth 0 = IF


0 4096 ['] process-line read-lines { crab-count }
crabs crab-count print-cells CR
crabs crab-count ['] < sort
crabs crab-count print-cells CR
crab-count find-optimal
. . CR

bye


    THEN
;

solve
