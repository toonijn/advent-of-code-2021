needs vector.fth

: hashset-init ( initial-size eq hash -- addr )
    ( size max-size eq hash data )
    5 CELLS ALLOCATE THROW { set }
    0 set !
    set 3 CELLS + !
    set 2 CELLS + !
    DUP set 1 CELLS + !
    CELLS DUP ALLOCATE THROW DUP set 4 CELLS + !
    SWAP 0 FILL
    set
;

: hashset-size ( hashset -- size )
    @
;

: hashset-maxsize ( hashset -- maxsize )
    1 CELLS + @
;

: hashset-eq ( hashset -- eq )
    2 CELLS + @
;

: hashset-hash ( hashset -- hash )
    3 CELLS + @
;

: hashset-data ( hashset -- addr )
    4 CELLS + @
;

: hashset-data-addr { set val -- addr } 
    val set hashset-hash EXECUTE set hashset-maxsize MOD
    CELLS set hashset-data +
;

: hashset-internal-add { set val assure-different -- }
    set val hashset-data-addr { data }
    data @ 0= IF
        3 vector-init data ! 
    THEN

    assure-different
    DUP INVERT IF
        DROP data @ val set hashset-eq vector-find 0<
    THEN
    IF
        1 set +!
        data @ val vector-add
    THEN
;

: hashset-grow { set }
    set hashset-maxsize DUP { oldsize } 2 * 3 + { newsize }
    set hashset-data { olddata }
    0 set !
    newsize set 1 CELLS + !
    newsize CELLS ALLOCATE THROW DUP set 4 CELLS + !
    newsize CELLS 0 FILL
    oldsize 0 DO
        olddata I cells + @ { vec }
        vec 0<> IF
            vec vector-FOREACH
                @ set swap true hashset-internal-add 
            vector-FOREACH-END
            vec vector-free
        THEN
    LOOP
    olddata free throw
;

: hashset-add { set val -- }
    set hashset-size 1 + 5 * set hashset-maxsize 4 * > IF
        set hashset-grow
    THEN
    set val false hashset-internal-add
;

: hashset-contains { set val -- }
    set val hashset-data-addr { data }
    data @ 0= IF false ELSE
        data @ val set hashset-eq vector-find 0 >=
    THEN
;

: hashset-test
    13 ['] = ['] noop hashset-init { set }

    assert( set hashset-size 0= )

    set 16 hashset-add

    assert( set hashset-size 1 = )
    assert( set 16 hashset-contains )
    assert( set 3 hashset-contains INVERT )

    set 16 hashset-add

    assert( set hashset-size 1 = )
    
    101 1 DO
        set I I * hashset-add

        assert( set I I * hashset-contains )
        assert( set I I * 1 + hashset-contains INVERT )
    LOOP
    assert( set hashset-size 100 = )
    101 1 DO
        set I I * hashset-add
    LOOP
    assert( set hashset-size 100 = )
;

