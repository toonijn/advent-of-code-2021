needs ../util.fth
FALSE needs day5.1.fth DROP

: signum 
    DUP 0 < IF DROP -1 else 0 > IF 1 ELSE 0 THEN THEN 
;

: draw-line-2 { x1 y1 x2 y2 -- } 
    x2 x1 - signum { dx }
    y2 y1 - signum { dy }
    x2 x1 - ABS y2 y1 - ABS MAX 1 + 0 DO
        x1 dx I * + y1 dy I * + draw-point
    LOOP
;


' draw-line-2 IS draw-line

solve
