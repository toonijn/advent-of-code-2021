needs ../util/string.fth
needs ../util/io.fth
needs ../util/switch.fth
needs ../util/grid.fth

1000 CHARS ALLOCATE THROW CONSTANT enhancer

: read-image { image rows cols addr u -- image rows cols }
    image rows 1 +
    cols 0 <> IF
        assert( cols u = )
    THEN u
    assert( u 0 > )

    u 0 DO
        addr I CHARS + c@ [char] # =
        image rows I grid-addr !
    LOOP
;

: print-image { image }
    image grid-shape { rows cols }
    rows 0 DO
        cols 0 DO
            image J I grid-addr @ IF ." #" ELSE ." ." THEN
        LOOP
        CR
    LOOP
;

: enhanced-pixel { block3x3 -- pxl }
    block3x3 grid-shape assert( 3 = SWAP 3 = AND )
    0
    3 0 DO 3 0 DO
        2 *
        block3x3 J I grid-addr @ IF 1 + THEN    
    LOOP LOOP 
    CHARS enhancer + c@ [char] # = 
;

: grow-input { input fill-with -- output }
    input grid-shape { rows cols }
    rows 4 + cols 4 + grid-init { output }
    output fill-with grid-fill
    output 2 2 rows cols grid-block-view { block }
    input block grid-copy
    block FREE THROW
    output
;

: enhance-image ( input border-lit -- output border-lit )
    { border-lit } border-lit grow-input { input  }
    input grid-shape { rows cols }
    enhancer border-lit IF 511 ELSE 0 THEN CHARS + c@ [char] # = { next-border }
    rows cols grid-init { output }
    output next-border grid-fill

    rows 2 - 0 DO
        cols 2 - 0 DO
            input J I 3 3 grid-block-view
            DUP enhanced-pixel SWAP FREE THROW
            output J 1 + I 1 + grid-addr !
        LOOP
    LOOP
    output next-border    
;

: count-lit { image border-lit -- count }
    assert( border-lit INVERT )
    image grid-shape { rows cols }

    0
    rows 0 DO
        cols 0 DO
            image J I grid-addr @ IF
                1 +
            THEN
        LOOP
    LOOP

;

: solve 
depth 0 = IF

    enhancer 1000 stdin read-line THROW DROP
    assert( 512 = )
    enhancer 512 stdin read-line THROW DROP
    assert( 0 = )

    
    500 500 grid-init 0 0
    1000 ['] read-image read-lines
    0 0 2swap grid-block-view
    \ DUP print-image

    false
    2 0 DO
        enhance-image 
        \ OVER print-image CR
    LOOP

    ." After 2: " 2DUP count-lit . CR
    
    48 0 DO
        enhance-image 
        \ OVER print-image CR
    LOOP
    ." After 50: " 2DUP count-lit . CR

bye
    THEN
;

solve
