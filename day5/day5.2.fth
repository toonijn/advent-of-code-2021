needs ../util.fth
FALSE needs day5.1.fth DROP

: draw-line-2 { x1 y1 x2 y2 -- } 
    x2 x1 - sgn { dx }
    y2 y1 - sgn { dy }
    x2 x1 - ABS y2 y1 - ABS MAX 1 + 0 DO
        x1 dx I * + y1 dy I * + draw-point
    LOOP
;


' draw-line-2 IS draw-line

solve
