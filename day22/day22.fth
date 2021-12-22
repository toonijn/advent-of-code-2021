needs ../util/string.fth
needs ../util/io.fth
needs ../util/custom-stack.fth
needs ../util/switch.fth
needs ../util/vector.fth

100000 CONSTANT MAX-SIZE


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

: cube-clone ( cube -- cube )
    cube-init-empty
    SWAP OVER 6 CELLS MOVE
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

: cube-lit { cube -- lit }
    cube cube-x SWAP - 1 +
    cube cube-y SWAP - 1 + 
    cube cube-z SWAP - 1 + 
    * *
;

: .cube { cube -- }
    ." [( " cube cube-x SWAP . . ." )"
    ." ( " cube cube-y SWAP . . ." )"
    ." ( " cube cube-z SWAP . . ." )]"  
;

: interval-disjoint { 1min 1max 2min 2max -- if-disjoint }
    2max 1min < 1max 2min < OR
;

: interval-intersection { 1min 1max 2min 2max -- 3min 3max}
    1min 2min MAX
    1max 2max MIN
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
    custom-stack> { dst }
    custom-stack> { src }
    SWITCH offset ['] =
    S-CASE -1 S-IF
        MAX-SIZE NEGATE src axis 2 * CELLS + @ 1 -
    S-CASE 0 S-IF
        src axis 2 * CELLS + @
        src axis 2 * 1 + CELLS + @
    S-CASE 1 S-IF
        src axis 2 * 1 + CELLS + @ 1 + MAX-SIZE
    S-END
    dst axis 2 * 1 + CELLS + !
    dst axis 2 * CELLS + !
    src >custom-stack
    dst >custom-stack
;

: cube-neighbors-internal-set-full { k }
    0 k 3 MOD 1 - cube-neighbors-internal-set
    1 k 3 / 3 MOD 1 - cube-neighbors-internal-set
    2 k 9 / 3 MOD 1 - cube-neighbors-internal-set
;

: cube-neighbors-foreach ( cube -- )
    POSTPONE >custom-stack
    POSTPONE cube-init-empty POSTPONE >custom-stack
    0 27 POSTPONE LITERAL POSTPONE LITERAL POSTPONE DO 
    POSTPONE I 13 POSTPONE LITERAL POSTPONE <> POSTPONE IF 
    POSTPONE I POSTPONE cube-neighbors-internal-set-full
    POSTPONE custom-stack-peek
; immediate

: cube-neighbors-foreach-end
    POSTPONE THEN
    POSTPONE LOOP
    POSTPONE custom-stack> POSTPONE free POSTPONE THROW POSTPONE custom-stack-drop
; immediate

: add-cube { cubes cube is-on }
    cubes vector-size 27 + vector-init { new-cubes }
    is-on IF
        new-cubes cube vector-add
    THEN
    cubes vector-foreach
        @ { existing }
        existing cube cube-disjoint IF
            new-cubes existing vector-add
        ELSE
            cube cube-neighbors-foreach
                { n }
                \ n .cube ."  <?> " existing .cube CR
                existing n cube-disjoint INVERT IF
                    \ n .cube ."  <-> " existing .cube CR
                    existing n cube-intersection { r }
                    new-cubes r vector-add
                THEN
            cube-neighbors-foreach-end
            existing FREE THROW
        THEN
    vector-foreach-end
    cubes vector-clear
    new-cubes vector-foreach
        @ cubes SWAP vector-add
    vector-foreach-end
;

: interval-contains { lmin lmax smin smax -- if-contains }
    lmin smin <= smax lmax <= AND
;

: cube-contains { large small -- if-contains }
    large cube-x small cube-x interval-contains
    large cube-y small cube-y interval-contains
    large cube-z small cube-z interval-contains
    AND AND
;

-50 50 2DUP 2DUP cube-init CONSTANT max-cube

: total-lit { cubes }
    0
    cubes vector-foreach
        @ cube-lit +
    vector-foreach-end
;

: parse-line { cubes1 cubes2 addr u -- cubes1 cubes2 }
    addr u bl split assert( 2 = )
    [char] , split assert( 3 = )
    [char] . split assert( 3 = )
    parse-number { zmax }
    2DROP
    2 - SWAP 2 CHARS + SWAP
    parse-number { zmin }
    [char] . split assert( 3 = )
    parse-number { ymax }
    2DROP
    2 - SWAP 2 CHARS + SWAP
    parse-number { ymin }
    [char] . split assert( 3 = )
    parse-number { xmax }
    2DROP
    2 - SWAP 2 CHARS + SWAP
    parse-number { xmin }
    DROP 1 CHARS + c@ [char] n = { is-on }
    xmin xmax ymin ymax zmin zmax
    cube-init { cube }

    cubes2 cube cube-clone is-on add-cube
    max-cube cube cube-contains if
        cubes1 cube is-on add-cube
    THEN

    cubes1 cubes2
;

: solve
depth 0 = IF

    101 vector-init
    101 vector-init
    200 ['] parse-line read-lines

    SWAP
    ." star1: " total-lit . CR
    ." star2: " total-lit . CR


bye
    THEN
;

solve
