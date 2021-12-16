200 CELLS ALLOCATE THROW CONSTANT switch-stack
switch-stack switch-stack !


: >switch-stack ( v -- )
    1 CELLS switch-stack +!
    switch-stack @ !
;

: switch-stack-DROP ( -- )
    -1 CELLS switch-stack +!
;

: .switch-stack
    ." switch-stack <" switch-stack @ switch-stack - 1 CELLS / DUP [char] 0 + emit ." > "
    DUP 0 > IF
        0 DO
            switch-stack I 1 + CELLS + @ .
        LOOP
    ELSE DROP THEN
;

: switch-stack> ( -- v )
    switch-stack @ @
    switch-stack-drop 
;

: switch-stack-DROPN ( N -- )
    0 DO
        switch-stack-DROP
    LOOP
;

: switch-stack-PICK ( N -- )
    switch-stack @ SWAP CELLS - @
;

: N>switch-stack-copy { ( x1 .. xn ) N -- x1 .. xn }
    N 0 DO
        I PICK >switch-stack
    LOOP
;

: Nswitch-stack>-copy { N -- x1 .. xn }
    N 0 DO
        I switch-stack-PICK
    LOOP
;

: switch-internal-prepare
    depth >switch-stack
;

: switch-internal-store
    depth switch-stack> - { size }
    size N>switch-stack-copy
    size 0 DO DROP LOOP
    size >switch-stack
;

: switch-internal-drop
    switch-stack> switch-stack-DROPN
;

: switch-internal-execute
    switch-stack> { size }
    size Nswitch-stack>-copy
    size >switch-stack
    EXECUTE
;

: SWITCH 
    POSTPONE switch-internal-prepare 0
; immediate

: S-CASE
    { switch-size }
    switch-size 0 = IF
        POSTPONE switch-internal-store
    ELSE
        POSTPONE ELSE 
    THEN
    switch-size
; immediate

: S-DEFAULT POSTPONE S-CASE ; immediate

: S-IF
    { switch-size }
    POSTPONE switch-internal-execute POSTPONE IF
    switch-size 1 +
; immediate

: S-END assert( DUP 0 > ) 0 DO POSTPONE THEN LOOP POSTPONE switch-internal-drop ; immediate

: =str ( addr1 u1 addr2 u2 -- if-equal )
    COMPARE 0 =
;

: switch-test-internal ( addr u )
    SWITCH 2DUP ['] =str 
        S-CASE s" 123" S-IF ." it was 123" CR
        S-CASE s" 456" S-IF ." it was 456" CR
        S-CASE s" 789" S-IF ." it was 789" CR
        S-DEFAULT ." it was unknown" CR
    S-END
    2DROP
;

: switch-test
    see switch-test-internal CR

    100 { max-line-size }
    max-line-size 2 + CHARS ALLOCATE THROW { line-buffer }
    line-buffer max-line-size stdin READ-LINE THROW DROP
    line-buffer SWAP switch-test-internal 

    bye
;
