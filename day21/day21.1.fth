needs ../util/string.fth
needs ../util/io.fth

2 CELLS ALLOCATE THROW CONSTANT die
( last-roll count )
0 die !
0 die 1 CELLS + !

: roll-die
    1 die 1 CELLS + +!
    1 die +!
    die @ 100 > IF 1 die ! THEN
    die @
;

: die-roll-count
    die 1 CELLS + @
;

: roll-dice
    roll-die roll-die + roll-die +
;

: parse-line ( addr u -- pos score )
    [char] : split assert( 2 = )
    2swap 2drop
    1 - SWAP 1 CHARS + SWAP
    parse-number 0
;

: make-move { pos score -- pos score }
    pos roll-dice +
    1 - 10 MOD 1 + DUP score +
;

: solve
depth 0 = IF

    200 ['] parse-line read-lines

    BEGIN
    DUP 1000 < WHILE
    2SWAP
    make-move
    REPEAT

    2 PICK  die-roll-count * . CR

bye
    THEN
;

solve
