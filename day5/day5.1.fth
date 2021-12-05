needs ../util.fth

1000 CONSTANT grid-side
grid-side DUP * CONSTANT grid-size
grid-size CELLS ALLOCATE THROW CONSTANT grid
grid grid-size CELLS 0 FILL

Defer draw-line

: draw-point { x y -- }
    grid y grid-side * x + CELLS + DUP @ 1 + SWAP !
;

: draw-line-1 { x1 y1 x2 y2 -- } 
( x1 . y1 . x2 . y2 . CR )
x1 x2 = IF
    y2 y1 2DUP > IF SWAP THEN 1 + SWAP DO
        x1 I draw-point
    LOOP
ELSE y1 y2 = IF
    x2 x1 2DUP > IF SWAP THEN 1 + SWAP DO
        I y1 draw-point
    LOOP
THEN THEN
;

' draw-line-1 IS draw-line

: process-line
    62 ( > ) split assert( 2 = ) 44 split assert( 2 = )
    parse-number { y2 }
    SWAP 1 + SWAP parse-number { x2 }
    44 split assert( 2 = )
    parse-number { y1 }
    parse-number { x1 }
    x1 y1 x2 y2 draw-line
;

: count-dangerous { -- count }
    0
    grid-size 0 DO
        grid I CELLS + @ 1 > IF
        1 +
        THEN
    LOOP
;

: print-grid
    grid-side 0 DO
        grid I grid-side * CELLS + grid-side print-cells CR
    LOOP
;

: solve 
    depth 0 = IF


256 ['] process-line read-lines 
grid-side 20 < IF print-grid THEN
count-dangerous . CR
bye


    THEN
;

solve
