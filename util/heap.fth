: heap-init { max-size less-than -- heap }
    max-size 2 + CELLS ALLOCATE THROW
    DUP 0 SWAP !
    DUP 1 CELLS + less-than SWAP !
;

: heap-size { heap -- size }
    heap @
;

: heap-compare ( heap a b -- a<b )
    ROT 1 CELLS + @ EXECUTE
;

: heap-addr { heap index -- addr }
    heap heap-size { size }
    assert( index 0 > index size 1 + < AND )
    heap index 1 + cells +
;

: heap-swap-with-parent? { heap child -- if-swapped}
    assert( child 1 > )
    heap child heap-addr { a }
    heap child 2 / heap-addr { b }
    a @ b @ 2DUP heap rot rot heap-compare IF
        a ! b !
        TRUE
    ELSE
        2DROP
        FALSE
    THEN
;

: heap-bubble-up { heap index -- }
    index 1 > IF
        heap index heap-swap-with-parent? IF
            heap index 2 / RECURSE
        THEN
    THEN
;

: heap-add { heap v --  }
    1 heap +!
    heap @ { size }
    v heap size heap-addr !
    heap size heap-bubble-up
;

: heap-bubble-down { heap index -- }
    heap heap-size { size }
    index 2 * size = IF
        heap index 2 * heap-swap-with-parent?
    ELSE
        index 2 * size < IF
            heap index 2 * heap
                heap index 2 * 1 + heap-addr @
                heap index 2 * heap-addr @
            heap-compare IF
                1 +
            THEN
            2DUP heap-swap-with-parent? IF
                RECURSE
            ELSE 2DROP THEN
        THEN
    THEN
;

: heap-pop { heap -- v }
    heap 1 heap-addr DUP @ { v }
    heap heap @ heap-addr @ SWAP !
    -1 heap +!
    heap 1 heap-bubble-down
    v
;

: heap-peek { heap -- v }
    heap 1 heap-addr @
;

: heap-is-empty { heap -- is-empty }
    heap heap-size 0 =
;

: heap-test
    100 ['] < heap-init { heap }

    assert( heap heap-is-empty )

    heap 5 heap-add

    heap 7 print-cells CR

    assert( heap heap-is-empty INVERT )
    assert( heap heap-size 1 = )
    assert( heap heap-peek 5 = )

    heap 3 heap-add
    heap 2 heap-add

    heap 7 print-cells CR

    assert( heap heap-size 3 = )
    assert( heap heap-peek 2 = )

    heap 4 heap-add

    heap 7 print-cells CR

    assert( heap heap-size 4 = )
    assert( heap heap-peek 2 = )

    heap heap-pop assert( 2 = )

    heap 7 print-cells CR

    assert( heap heap-size 3 = )
    assert( heap heap-peek 3 = )

    heap 6 heap-add
    heap 2 heap-add

    assert( heap heap-size 5 = )
    assert( heap heap-peek 2 = )


    heap heap-pop assert( 2 = )
    heap heap-pop assert( 3 = )
    heap heap-pop assert( 4 = )
    heap heap-pop assert( 5 = )
    heap heap-pop assert( 6 = )

    assert( heap heap-is-empty )
;
