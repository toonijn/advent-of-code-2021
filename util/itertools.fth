needs list.fth

: permutation-internal { n offset permutation callback }
    offset n = IF
        permutation n callback EXECUTE
    ELSE
        n 0 DO
            permutation offset I contains INVERT IF
                I permutation offset CELLS + !
                n offset 1 + permutation callback RECURSE
            THEN
        LOOP
    THEN
;

: permutations { n callback }
    n CELLS ALLOCATE THROW { permutation }

    n 0 permutation callback permutation-internal

    permutation FREE THROW
;
