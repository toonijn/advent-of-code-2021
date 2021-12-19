1000 CONSTANT custom-stack-size
custom-stack-size CELLS ALLOCATE THROW CONSTANT custom-stack
custom-stack custom-stack !

: >custom-stack ( v -- )
    1 CELLS custom-stack +!
    assert( custom-stack @ custom-stack - 1 CELLS / custom-stack-size < )
    custom-stack @ !
;

: custom-stack-DROP ( -- )
    -1 CELLS custom-stack +!
;

: .custom-stack
    ." custom-stack <" custom-stack @ custom-stack - 1 CELLS / DUP [char] 0 + emit ." > "
    DUP 0 > IF
        0 DO
            custom-stack I 1 + CELLS + @ .
        LOOP
    ELSE DROP THEN
;

: custom-stack-peek ( -- v )
    custom-stack @ @
;

: custom-stack> ( -- v )
    custom-stack-peek
    custom-stack-drop 
;

: custom-stack-DROPN ( N -- )
    0 DO
        custom-stack-DROP
    LOOP
;

: custom-stack-PICK ( N -- )
    custom-stack @ SWAP CELLS - @
;

