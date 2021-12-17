needs ../util/string.fth
needs ../util/io.fth
needs ../util/switch.fth


( target area: x=20..30, y=-10..-5 )
: parse-region ( addr u )
    4 CELLS ALLOCATE THROW { region }
    [char] = split assert( 3 = )
    [char] . split assert( 3 = )
    parse-number region 3 CELLS + !
    2DROP
    parse-number region 2 CELLS + !
    [char] . split assert( 3 = )
    parse-number region 1 CELLS + !
    2DROP
    parse-number region  !
    2DROP
    region
;

: x-min @ ;
: x-max 1 CELLS + @ ;
: y-min 2 CELLS + @ ;
: y-max 3 CELLS + @ ;

: can-reach { region x y dx dy -- if-can-reach }
    dx 0 > x region x-min >= OR 
    x region x-max <= AND
    region y-min y <= AND
;

: contains { region x y }
    x region x-max <=
    y region y-max <= AND
    region x-min x <= AND
    region y-min y <= AND
;

: 4PICK 3 + { N }
    N PICK
    N PICK
    N PICK
    N PICK
;

: 2PICK 1 + { N }
    N PICK
    N PICK
;

: 5ROT { a b c d e } b c d e a ;
: -5ROT { a b c d e } e a b c d ;

: SIGNUM { x } x 0 = IF x ELSE x 0 < IF -1 ELSE 1 THEN THEN ;

: shoot { region dx dy -- max-y in-target }
    0 0 0 dx dy
    ( max-y x y dx dy )
    BEGIN
    region 1 4PICK can-reach
    region 4 2PICK contains INVERT AND
    WHILE
        2SWAP
        2 PICK +
        SWAP 3 PICK + SWAP 2SWAP
        1 -
        SWAP DUP SIGNUM -1 * + SWAP
        5ROT 3 PICK MAX -5ROT
    REPEAT
    2DROP
    region ROT ROT contains
;

: test-region
    s" target area: x=20..30, y=-10..-5" parse-region { region }

    assert( region 0 0 contains INVERT )
    assert( region 19 -6 contains INVERT )
    assert( region 20 -10 contains )
    assert( region 30 -5 contains )
    assert( region 31 -5 contains INVERT )
    assert( region 30 -4 contains INVERT )

    assert( region 7 2 shoot ) DROP
    assert( region 6 3 shoot ) DROP
    assert( region 9 0 shoot ) DROP
    assert( region 17 -4 shoot INVERT ) DROP


;

: solve 
depth 0 = IF

    200 { line-size }
    line-size 2 + CHARS ALLOCATE THROW { line }
    line line-size stdin read-line THROW DROP
    line SWAP parse-region 
    line free throw { region }

    0 0 ( 0 )
    region x-max 1 + 0 DO I { x }
    region y-min 1 - DUP -1 * SWAP  DO I { y }

        region x y shoot IF
            ROT MAX SWAP
            1 +
        ELSE
            DROP
        THEN
    LOOP  LOOP

    SWAP
    ."     Max height: " . CR
    ." Possible shots: " . CR

bye
    THEN
;

solve
