needs ../util/string.fth
needs ../util/io.fth
needs ../util/custom-stack.fth

10000000 CONSTANT MAX-SIZE

: cube-x-set { cube ( xmin xmax ) -- }
    cube 1 CELLS + !
    cube 0 CELLS + !
;

: cube-y-set { cube ( ymin ymax ) -- }
    cube 3 CELLS + !
    cube 2 CELLS + !
;

: cube-z-set { cube ( zmin zmax ) -- }
    cube 5 CELLS + !
    cube 4 CELLS + !
;

: cube-init-empty ( -- cube )
    6 CELLS ALLOCATE THROW
;

: cube-init ( xmin xmax ymin ymax zmin zmax -- cube )
    cube-init-empty { cube }
    cube 5 CELLS + !
    cube 4 CELLS + !
    cube 3 CELLS + !
    cube 2 CELLS + !
    cube 1 CELLS + !
    cube 0 CELLS + !
    cube
;

: cube-x { cube -- xmin xmax }
    cube 0 CELLS + @
    cube 1 CELLS + @
;

: cube-y { cube -- ymin ymax }
    cube 2 CELLS + @
    cube 3 CELLS + @
;

: cube-z { cube -- zmin zmax }
    cube 4 CELLS + @
    cube 5 CELLS + @
;

: interval-disjoint { 1min 1max 2min 2max -- if-disjoint }
    2max 1min < 1max 2min < OR
;

: interval-intersection { 1min 1max 2min 2max -- 3min 3max}
    1min 2min MAX
    1max 2max MIN
;


: cube-y-set { cube ( ymin ymax ) -- }
    cube 3 CELLS + @
    cube 2 CELLS + @
;
: cube-disjoint { c1 c2 -- if-disjoint }
    c1 cube-x c2 cube-x interval-disjoint
    c1 cube-y c2 cube-y interval-disjoint
    c1 cube-z c2 cube-z interval-disjoint
    OR OR
;

: cube-intersection { c1 c2 -- c3 }
    c1 cube-x c2 cube-x interval-intersection
    c1 cube-y c2 cube-y interval-intersection
    c1 cube-z c2 cube-z interval-intersection
    cube-init
;

: cube-neighbors-internal-set { axis offset -- }
    custom-stack> { src }
    custom-stack> { dst }
    SWITCH offset ['] =
    S-CASE -1 S-IF
        MAX-SIZE src offset 2 * @
    S-CASE 0 S-IF
        src offset 2 * @
        src offset 2 * 1 + @
    S-CASE 1 S-IF
        src offset 2 * 1 + @ MAX-SIZE
    S-END

    dst offset 2 * 1 + CELLS + !
    dst offset 2 * CELLS + !
;

: cube-neighbors-foreach ( cube -- )
    POSTPONE cube-init-empty POSTPONE >custom-stack
    POSTPONE >custom-stack
    2 - 1 POSTPONE LITERAL POSTPONE LITERAL POSTPONE DO 
    0 POSTPONE LITERAL POSTPONE I POSTPONE cube-neighbors-internal-set
    2 - 1 POSTPONE LITERAL POSTPONE LITERAL POSTPONE DO
    1 POSTPONE LITERAL POSTPONE I POSTPONE cube-neighbors-internal-set
    2 - 1 POSTPONE LITERAL POSTPONE LITERAL POSTPONE DO
    2 POSTPONE LITERAL POSTPONE I POSTPONE cube-neighbors-internal-set

;

: cube-neighbors-foreach-end
    POSTPONE LOOP POSTPONE LOOP POSTPONE LOOP
    POSTPONE custom-stack-drop POSTPONE custom-stack-drop
;

: solve
depth 0 = IF

    200 ['] parse-line read-lines

    BEGIN
    DUP 1000 < WHILE
    2SWAP
    make-move
    REPEAT

    2 PICK  die-roll-count * . CR

bye
    THEN
;

solve
