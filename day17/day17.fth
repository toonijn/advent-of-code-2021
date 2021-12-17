needs ../util/string.fth
needs ../util/io.fth
needs ../util/switch.fth


( target area: x=20..30, y=-10..-5 )
: parse-region ( addr u )
    4 CELLS ALLOCATE THROW { region }
    [char] = split assert( 3 = )
    [char] . split assert( 3 = )
    parse-number { y-max }
    2DROP
    parse-number { y-min }
    [char] . split assert( 3 = )
    parse-number { x-max }
    2DROP
    parse-number { x-min }
    2DROP
    x-min x-max y-min y-max
;


: solve 
depth 0 = IF

    200 { line-size }
    line-size 2 + CHARS ALLOCATE THROW { line }
    line line-size stdin read-line THROW DROP
    line SWAP parse-region 
    line free throw
    { x-min x-max y-min y-max }
    x-max 1 + 0 DO I { x }
    y-min -1 * 1 + 0 DO I { y }


    .S CR




bye


    THEN
;

solve
