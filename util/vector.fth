needs custom-stack.fth
needs list.fth

: vector-init ( initial-size -- addr )
    3 CELLS ALLOCATE THROW { vec }
    0 vec !
    DUP vec 1 CELLS + !
    CELLS ALLOCATE THROW vec 2 CELLS + !
    vec
;

: vector-size ( vector -- size )
    @
;

: vector-maxsize ( vector -- size )
    1 CELLS + @
;

: vector-data ( vector -- size )
    2 CELLS + @
;

: vector-addr ( vector offset -- addr )
    assert( 2DUP SWAP @ < )
    CELLS SWAP vector-data +
;

: vector-last { vec }
    vec vector-data vec vector-size 1 - CELLS +
;

: vector-grow { vec }
    vec vector-maxsize 2 * 1 + { newsize }
    newsize CELLS ALLOCATE THROW { newdata }
    vec vector-data newdata vec vector-size CELLS MOVE
    vec vector-data FREE THROW
    newsize vec 1 CELLS + !
    newdata vec 2 CELLS + !
;

: vector-add { vec val -- }
    vec vector-size vec vector-maxsize >= IF
        vec vector-grow
    THEN
    val vec vector-data vec vector-size  CELLS + !
    1 vec +! 
;

: vector-copy { vec -- addr }
    vec vector-size 3 MAX vector-init { addr }
    vec vector-data addr vector-data vec vector-size CELLS MOVE
    vec vector-size addr !
    addr
;

: vector-free { vec }
    vec vector-data FREE THROW
    vec FREE THROW
;

: vector-FOREACH
    POSTPONE DUP POSTPONE >custom-stack POSTPONE vector-size POSTPONE DUP POSTPONE 0> POSTPONE IF 0 POSTPONE LITERAL POSTPONE DO
        POSTPONE custom-stack-peek POSTPONE I POSTPONE vector-addr
; immediate

: vector-FOREACH-END
    POSTPONE LOOP
    POSTPONE ELSE POSTPONE DROP POSTPONE THEN
    POSTPONE custom-stack-drop
; immediate

: vector-find { vec val eq -- }
    -1
    vec vector-FOREACH
        @ val eq EXECUTE IF
            DROP I LEAVE
        THEN
    vector-FOREACH-END
;

: vector-pop { vec -- v }
    vec vector-last @
    -1 vec +!
;

: vector-clear { vec -- }
    0 vec !
;

: .vector { vec }
    ." [ "
    vec vector-FOREACH
        @ .
    vector-FOREACH-END
    ." ]"
;

: vector-sort  ( vec less-than -- )
    SWAP DUP vector-data SWAP vector-size ROT
    sort
;

: vector-test
    3 vector-init { vec }

    vec 1 vector-add
    vec 2 vector-add
    vec 5 vector-add
    vec 10 vector-add
    vec 17 vector-add

    assert( vec vector-size 5 = )

    vec vector-FOREACH
        vec I vector-addr
        assert( OVER = )
        assert( @ I I * 1 + = )
    vector-FOREACH-END

    assert( vec 5 ['] = vector-find 2 = )

    vec ['] > vector-sort

    vec vector-FOREACH
        assert( @ 4 I - DUP * 1 + = )
    vector-FOREACH-END
;

