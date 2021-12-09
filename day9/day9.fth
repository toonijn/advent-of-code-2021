needs ../util/string.fth
needs ../util/io.fth
needs ../util/list.fth

100000 CONSTANT heightmap-size
heightmap-size CELLS ALLOCATE THROW CONSTANT heightmap

: process-line ( width depth addr u -- width depth)
    { width depth addr u }
    width 0 = IF u ELSE assert( width u = ) width THEN
    u 0 DO
        addr I CHARS + c@ 48 ( 0 ) - heightmap I CELLS + u depth * CELLS + !
    LOOP
    
    depth 1 +
;

: get-index { width depth i j -- height }
    i width < i -1 > j depth < j -1 > AND AND AND IF
        width j * i +
    ELSE
        -1
    THEN
;

: get-value { width depth i j -- height }
    width depth i j get-index { index }
    index -1 > IF
        heightmap width j * i + CELLS +  @
    ELSE
        10
    THEN
;

: is-lowest-point { width depth x y }
    width depth x y get-value { v }
    width depth x 1 + y get-value v >
    width depth x 1 - y get-value v >
    width depth x y 1 + get-value v >
    width depth x y 1 - get-value v >
    AND AND AND
;

: first-star { width depth }

0 ( risk-level )
depth 0 DO
    I { y }
    width 0 DO
        I { x }
        width depth x y is-lowest-point IF
            width depth x y get-value + 1 +
        THEN
    LOOP
LOOP
. CR

;

heightmap-size CELLS ALLOCATE THROW CONSTANT marked-heightmap

: is-marked { width depth x y }
    width depth x y get-index { index }
    index -1 > IF
        marked-heightmap index CELLS + @
    ELSE
        TRUE
    THEN
;

: basin-size-internal { width depth x y -- size }
    1
    TRUE marked-heightmap width depth x y get-index CELLS + !
    width depth x y get-value { v }

    2 0 DO
    2 0 DO I 2 * 1 - DUP J * { dx } 1 J - * { dy }
        x dx + { nx } y dy + { ny }
        width depth nx ny get-value { nv }
        nv 9 <  width depth nx ny is-marked INVERT AND IF
            width depth nx ny RECURSE +
        THEN
    LOOP LOOP
;


: basin-size ( width depth x y -- size )
    marked-heightmap heightmap-size CELLS 0 FILL
    basin-size-internal
;

: second-star { width depth }
heightmap-size CELLS ALLOCATE THROW { basins }

0
depth 0 DO
    I { y }
    width 0 DO
        I { x }
        width depth x y is-lowest-point IF
            width depth x y basin-size
            OVER CELLS basins + !
            1 +
        THEN
    LOOP
LOOP

{ basin-count }
basins basin-count ['] > sort

1
3 0 DO
    basins I CELLS + @ *
LOOP
. CR
;

: solve 
    depth 0 = IF


0 0 4096 ['] process-line read-lines
( width depth )
." first: " 2DUP first-star
." second: "  2DUP second-star

bye


    THEN
;

solve
