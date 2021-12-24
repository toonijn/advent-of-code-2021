needs ../util/io.fth
needs ../util/heap.fth

CREATE REACHABLE
\         d    d    d 
(  0 )    1 , -1 , -1 ,
(  1 )    0 ,  2 , -1 ,
(  2 )    1 ,  3 , 11 ,
(  3 )    2 ,  4 , -1 ,
(  4 )    3 ,  5 , 12 ,
(  5 )    4 ,  6 , -1 ,
(  6 )    5 ,  7 , 13 ,
(  7 )    6 ,  8 , -1 ,
(  8 )    7 ,  9 , 14 ,
(  9 )    8 , 10 , -1 ,
( 10 )    9 , -1 , -1 ,

( 11 )    2 , 15 , -1 ,
( 12 )    4 , 16 , -1 ,
( 13 )    6 , 17 , -1 ,
( 14 )    8 , 18 , -1 ,

( 15 )   11 , -1 , -1 ,
( 16 )   12 , -1 , -1 ,
( 17 )   13 , -1 , -1 ,
( 18 )   14 , -1 , -1 ,

CREATE COST
0 , 1 , 10 , 100 , 1000 ,



: pos-init ( -- addr )
    2 cells ALLOCATE THROW { addr }
    19 CHARS ALLOCATE THROW
    DUP 19 CHARS 0 FILL
    ( 0123456789a )
    (   b c d e   )
    (   f g h i   )
    addr !
    0 addr 1 CELLS + !
    addr
;

: pos-free { pos -- } 
    pos @ FREE THROW
    pos FREE THROW
;

: pos-clone { src -- dst }
    pos-init { dst }
    src CELL+ @ dst CELL+ !
    src @ dst @ 19 CHARS MOVE 
    dst
;

: pos-get-room { pos room -- char }
    pos @ room CHARS + c@
;

: pos-set-room { pos room type -- }
    type pos @ room CHARS + c!
;

: .pos { addr -- }
    11 0 DO
        addr I pos-get-room DUP 0 =
        IF drop [char] . ELSE [char] A + 1 - THEN EMIT
    LOOP
    CR space
    15 11 DO
        space addr I pos-get-room DUP 0 =
        IF drop [char] . ELSE [char] A + 1 - THEN EMIT
    LOOP
    CR space
    19 15 DO
        space addr I pos-get-room DUP 0 =
        IF drop [char] . ELSE [char] A + 1 - THEN EMIT
    LOOP
;

: pos-can-reach ( pos from to -- )
    ROT { pos } 
    DUP pos SWAP pos-get-room 0<> IF 2DROP false EXIT THEN

    BEGIN
        2DUP > IF SWAP THEN
        DUP 10 >
    WHILE
        2DUP = IF 2DROP true EXIT THEN
        DUP pos SWAP pos-get-room 0<> IF 2DROP false EXIT THEN
    REPEAT
    2DUP = IF 2DROP true EXIT THEN
    2DUP < IF SWAP THEN
    1 + DO
        pos I pos-get-room 0<> IF false exit THEN
    LOOP
    true
;

: find-reachables { pos from last length callback -- }
    3 0 DO
        REACHABLE from 3 * I + CELLS + @ { to }
        to 0 >= to last <> AND pos to pos-get-room 0= AND IF
            to length 1 + callback EXECUTE
            pos to from length 1 + callback RECURSE
        THEN
    LOOP
;

: right-chamber { loc type -- is-right }
    loc 11 < IF false ELSE
        loc 11 - 4 MOD 1 + type = 
    THEN
;

: may-enter { pos start to -- if-may }
    pos start pos-get-room { type }
    to 11 < start 11 < AND to 2 = to 4 = to 6 = to 8 = OR OR OR OR IF FALSE
    ELSE
        start 11 < IF
            to type right-chamber
            to 15 < IF
                type pos to 4 + pos-get-room = AND
            THEN
        ELSE to 11 < THEN
    THEN
;

: may-exit { pos start }
    start 11 < IF true ELSE
        pos start pos-get-room { type }
        start type right-chamber IF
            start 15 < IF
                pos start 4 + pos-get-room type <>  
            ELSE false THEN
        ELSE true THEN
    THEN
;

: find-moves-internal { pos start callback to length -- pos start callback }
    pos start to may-enter IF
        to length callback EXECUTE
    THEN
    pos start callback
;

: find-moves { pos start callback -- }
    pos start pos-get-room { type }
    type 0 > IF pos start may-exit IF
        pos start callback 
        pos start -1 0 ['] find-moves-internal find-reachables
        2drop drop
    THEN THEN
;

: print-move { to length }
    to . length . CR
;

: pos-< { a b }
    a CELL+ @ b CELL+ @ <
;

: pos-has-won { pos -- }
    true 5 1 DO
    pos 10 I + pos-get-room I = 
    pos 14 I + pos-get-room I = AND INVERT IF
        drop false leave
    THEN LOOP
;

: dijkstra-callback { todo pos start to length -- todo pos start  }
    pos pos-clone { new }
    pos start pos-get-room { type }
    new start 0 pos-set-room
    new to type pos-set-room
    COST type CELLS + @ length * new CELL+ +!
    \ start . ." -> " to . CR
    new pos-has-won IF
        new .pos CR
        new CELL+ @ . CR
        1 throw
    THEN 
    todo new heap-add
    todo pos start
;

: dijkstra { pos -- }
    100000000 ['] pos-< heap-init { todo }
    todo pos heap-add
    0
    BEGIN todo heap-is-empty INVERT WHILE
        todo heap-pop { pos }
        todo pos
        19 0 DO
            I
            \ ." Next start" CR
            pos I ['] dijkstra-callback find-moves
            DROP
        LOOP
        2DROP
        \ pos .pos
        1 + DUP 10000 MOD 0= IF
        pos CELL+ @ . CR pos .pos CR CR
        THEN
        pos pos-free
    REPEAT
;

: solve
depth 0 = IF

    pos-init { pos }
    202 CHARS ALLOCATE THROW { line }
    line 200 stdin read-line 2DROP assert( 13 = )
    line 200 stdin read-line 2DROP assert( 13 = )
    line 200 stdin read-line 2DROP assert( 13 = )
    pos 11 line 3 CHARS + c@ [char] A - 1 + pos-set-room
    pos 12 line 5 CHARS + c@ [char] A - 1 + pos-set-room
    pos 13 line 7 CHARS + c@ [char] A - 1 + pos-set-room
    pos 14 line 9 CHARS + c@ [char] A - 1 + pos-set-room
    line 200 stdin read-line 2DROP assert( 11 = )
    pos 15 line 3 CHARS + c@ [char] A - 1 + pos-set-room
    pos 16 line 5 CHARS + c@ [char] A - 1 + pos-set-room
    pos 17 line 7 CHARS + c@ [char] A - 1 + pos-set-room
    pos 18 line 9 CHARS + c@ [char] A - 1 + pos-set-room


    pos 11 ['] print-move find-moves

    pos .pos CR

    pos dijkstra

bye
    THEN
;

solve
