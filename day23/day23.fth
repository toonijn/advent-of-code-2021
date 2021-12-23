needs ../util/string.fth
needs ../util/io.fth
needs ../util/custom-stack.fth
needs ../util/switch.fth
needs ../util/vector.fth

: pos-init ( -- addr )
    19 CHARS ALLOCATE THROW
    DUP 19 CHARS 0 FILL
    ( 0123456789a )
    (   b c d e   )
    (   f g h i   )
;

: .pos { addr -- }
    11 0 DO
        addr I CHARS + c@ DUP 0 =
        IF drop [char] . ELSE [char] A + 1 - THEN EMIT
    LOOP
    CR space
    15 11 DO
        space addr I CHARS + c@ DUP 0 =
        IF drop [char] . ELSE [char] A + 1 - THEN EMIT
    LOOP
    CR space
    19 15 DO
        space addr I CHARS + c@ DUP 0 =
        IF drop [char] . ELSE [char] A + 1 - THEN EMIT
    LOOP
;

: pos-set-room { pos row col type -- }
    type pos 11 row 4 * col + + CHARS + c!
;

: pos-is-not-free ( pos room -- if-free )
    CHARS + c@ 0 <>
;

: pos-can-reach ( pos from to -- )
    ROT { pos } 
    DUP pos SWAP pos-is-not-free IF 2DROP false EXIT THEN

    BEGIN
        2DUP > IF SWAP THEN
        DUP 10 >
    WHILE
        2DUP = IF 2DROP true EXIT THEN
        DUP pos SWAP pos-is-not-free IF 2DROP false EXIT THEN
    REPEAT
    2DUP = IF 2DROP true EXIT THEN
    2DUP < IF SWAP THEN
    1 + DO
        pos I pos-is-not-free IF false exit THEN
    LOOP
    true
;

: pos-neighbors { addr }
    15 0 DO

    LOOP
;


: solve
depth 0 = IF

    pos-init { pos }
    202 CHARS ALLOCATE THROW { line }
    line 200 stdin read-line 2DROP assert( 13 = )
    line 200 stdin read-line 2DROP assert( 13 = )
    line 200 stdin read-line 2DROP assert( 13 = )
    pos 0 0 line 3 CHARS + c@ [char] A - 1 + pos-set-room
    pos 0 1 line 5 CHARS + c@ [char] A - 1 + pos-set-room
    pos 0 2 line 7 CHARS + c@ [char] A - 1 + pos-set-room
    pos 0 3 line 9 CHARS + c@ [char] A - 1 + pos-set-room
    line 200 stdin read-line 2DROP assert( 11 = )
    pos 1 0 line 3 CHARS + c@ [char] A - 1 + pos-set-room
    pos 1 1 line 5 CHARS + c@ [char] A - 1 + pos-set-room
    pos 1 2 line 7 CHARS + c@ [char] A - 1 + pos-set-room
    pos 1 3 line 9 CHARS + c@ [char] A - 1 + pos-set-room

    pos .pos CR

bye
    THEN
;

solve
