needs ../util/io.fth
needs ../util/heap.fth
needs ../util/hashset.fth

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

( 15 )   11 , 19 , -1 ,
( 16 )   12 , 20 , -1 ,
( 17 )   13 , 21 , -1 ,
( 18 )   14 , 22 , -1 ,

( 19 )   15 , 23 , -1 ,
( 20 )   16 , 24 , -1 ,
( 21 )   17 , 25 , -1 ,
( 22 )   18 , 26 , -1 ,

( 23 )   19 , -1 , -1 ,
( 24 )   20 , -1 , -1 ,
( 25 )   21 , -1 , -1 ,
( 26 )   22 , -1 , -1 ,

CREATE COST
0 , 1 , 10 , 100 , 1000 ,



: pos-init ( -- addr )
    2 cells ALLOCATE THROW { addr }
    27 CHARS ALLOCATE THROW
    DUP 27 CHARS 0 FILL
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
    src @ dst @ 27 CHARS MOVE 
    dst
;

: pos-get-room { pos room -- char }
    assert( room 27 < )
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
    CR space
    23 19 DO
        space addr I pos-get-room DUP 0 =
        IF drop [char] . ELSE [char] A + 1 - THEN EMIT
    LOOP
    CR space
    27 23 DO
        space addr I pos-get-room DUP 0 =
        IF drop [char] . ELSE [char] A + 1 - THEN EMIT
    LOOP
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

: chamber-correct { pos start -- if-correct }
    assert( start 11 >= )
    true
    start 27 < IF
        26 start - 4 / 1 + 0 DO
            start pos start 4 I * + pos-get-room right-chamber AND
        LOOP
    THEN
;

: may-enter { pos start to -- if-may }
    pos start pos-get-room { type }
    to 11 < start 11 < AND to 2 = to 4 = to 6 = to 8 = OR OR OR OR IF FALSE
    ELSE
        start 11 < IF
            to type right-chamber
            pos to 4 + chamber-correct AND
        ELSE to 11 < THEN
    THEN
;

: may-exit { pos start }
    start 11 < IF true ELSE
        pos start chamber-correct INVERT
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
    pos 11 chamber-correct
    pos 12 chamber-correct AND
    pos 13 chamber-correct AND
    pos 14 chamber-correct AND
;

: pos-hash { pos -- key }
    0
    27 0 DO
        7919 *
        pos I pos-get-room +
    LOOP
;

: dijkstra-callback { todo pos start to length -- todo pos start  }
    pos pos-clone { new }
    pos start pos-get-room { type }
    new start 0 pos-set-room
    new to type pos-set-room
    COST type CELLS + @ length * new CELL+ +!
    \ start . ." -> " to . CR
    todo new heap-add
    todo pos start
;

: pos-eq { a b }
    TRUE
    27 0 DO
        a I pos-get-room b I pos-get-room <> IF
            DROP FALSE LEAVE
        THEN
    LOOP
;

: dijkstra ( pos -- )
    1007 ['] pos-eq ['] pos-hash hashset-init { seen } 
    10000000 ['] pos-< heap-init { todo }
    todo SWAP heap-add
    0
    BEGIN
    todo heap-is-empty INVERT IF
        todo heap-pop
        DUP pos-has-won INVERT
    ELSE 0 FALSE THEN
    WHILE { pos }
        depth { d }
        seen pos hashset-contains INVERT IF
            seen pos hashset-add
            \ pos .pos CR
            todo pos
            27 0 DO
                I
                \ ." Next start" CR
                pos I ['] dijkstra-callback find-moves
                DROP
            LOOP
            2DROP
            1 + DUP 10000 MOD 0= IF
               pos CELL+ @ . CR pos .pos CR CR
            THEN
        THEN
        depth d <> IF
            ." An issue " CR
            .S CR
            1 throw
        THEN
        \ DUP 5 > IF 1 THROW THEN
    REPEAT
    { pos } DROP
    pos 0 = IF
        ." empty ??? " CR
    ELSE
        pos .pos CR
        pos CELL+ @ . CR 
    THEN
;

: parse-star-1 { -- pos }
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

    pos 19 1 pos-set-room
    pos 20 2 pos-set-room
    pos 21 3 pos-set-room
    pos 22 4 pos-set-room
    
    pos 23 1 pos-set-room
    pos 24 2 pos-set-room
    pos 25 3 pos-set-room
    pos 26 4 pos-set-room

    line free throw
    pos
;

: parse-star-2 { -- pos }
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
    pos 23 line 3 CHARS + c@ [char] A - 1 + pos-set-room
    pos 24 line 5 CHARS + c@ [char] A - 1 + pos-set-room
    pos 25 line 7 CHARS + c@ [char] A - 1 + pos-set-room
    pos 26 line 9 CHARS + c@ [char] A - 1 + pos-set-room

    pos 15 4 pos-set-room
    pos 16 3 pos-set-room
    pos 17 2 pos-set-room
    pos 18 1 pos-set-room
    pos 19 4 pos-set-room
    pos 20 2 pos-set-room
    pos 21 1 pos-set-room
    pos 22 3 pos-set-room

    line free throw
    pos
;

: solve
depth 0 = IF

    parse-star-2 { pos }

    pos .pos CR

    pos dijkstra

bye
    THEN
;

solve
