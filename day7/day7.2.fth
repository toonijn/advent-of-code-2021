needs ../util.fth
FALSE needs day7.1.fth DROP


: distance-1 ( a b )
    - ABS
;

: distance-2 ( a b )
    - ABS DUP 1 + * 2 /
;

: total-distance { crab-count a }
    0
    crab-count 0 DO
        crabs I CELLS + @ a distance-2 +
    LOOP
;

: best-distance { crab-count }
    0 1000000000
    ( position  best-distance )
    10000 0 DO
        crab-count I total-distance { current-distance }
        DUP current-distance > IF
            2DROP I current-distance
        THEN
    LOOP
;


: solve-2
    depth 0 = IF


0 4096 ['] process-line read-lines { crab-count }
crabs crab-count print-cells CR
crab-count best-distance
. . CR

bye


    THEN
;

solve-2
