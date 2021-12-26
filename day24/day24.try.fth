needs ../util/io.fth
needs ../util/string.fth
needs ../util/switch.fth
needs ../util/vector.fth

: v-w ( vars -- addr ) 0 CELLS + ;
: v-x ( vars -- addr ) 1 CELLS + ;
: v-y ( vars -- addr ) 2 CELLS + ;
: v-z ( vars -- addr ) 3 CELLS + ;
: v-input ( vars -- vec ) 4 cells + @ ;
: v-get ( vars index -- addr ) CELLS + ;

CREATE bounds
10 , 1 ,
2 , 0 ,
30 , 0 ,
1 , 0 ,

: get-bounds ( v -- max min )
    2 * CELLS bounds + 2@ SWAP
;

: get-bounds-eql ( v -- max min )
    DROP 53 -26
;

: div-trunc { a b }
    a 0 > b 0 > = a b MOD 0= OR IF a b /
    ELSE a b / 1 + THEN ;

: v-init 
    5 CELLS ALLOCATE throw { v }
    v 5 CELLS 0 FILL
    14 vector-init v 4 CELLS + !
    v
;

: v-copy { src -- dst }
    5 CELLS ALLOCATE throw { dst }
    src dst 5 CELLS MOVE
    dst 4 CELLS + DUP @ vector-copy SWAP !
    dst
;

: .v { vars }
    ."  w: " vars v-w @ .
    ."  x: " vars v-x @ .
    ."  y: " vars v-y @ .
    ."  z: " vars v-z @ .
;

: instruction-init ( transform apply left right right-const -- addr )
    ( transform left right right-const )
    5 CELLS ALLOCATE THROW { addr }
    addr 3 CELLS + !
    addr 2 CELLS + !
    addr 1 CELLS + !
    addr 4 CELLS + !
    addr 0 CELLS + !
    addr
;

: instruction-execute { instr vars -- }
    instr 1 CELLS + @
    instr 3 CELLS + @ IF ( right-const )
        instr 2 CELLS + @
    ELSE
        vars instr 2 CELLS + @ v-get @
    THEN
    vars instr @ EXECUTE
;

: instruction-apply { instr vars -- }
    vars vars instr 1 CELLS + @ v-get @
    instr 3 CELLS + @ IF ( right-const )
        instr 2 CELLS + @
    ELSE
        vars instr 2 CELLS + @ v-get @
    THEN
    instr 4 CELLS + @ EXECUTE
    vars instr 1 CELLS + @ v-get ! DROP
;

200 vector-init CONSTANT instructions
1 CELLS ALLOCATE THROW CONSTANT instruction_ptr

: check-vars v-copy  { vars -- }
    \ vars .v CR
    instructions vector-size instruction_ptr @ 1 + 2DUP > IF DO
        instructions I vector-addr @ vars instruction-apply
    LOOP ELSE 2DROP THEN
    \ vars .v CR
    assert( vars v-z @ 0 = )
    assert( vars v-input vector-size 0 = )

    vars free throw
;

1 CELLS ALLOCATE THROW CONSTANT last-seen

: find-solutions { vars -- }
    \ vars check-vars 
    instruction_ptr @ DUP 40 MOD 0= SWAP last-seen @ <> AND IF
        instruction_ptr @ DUP last-seen ! . CR THEN
    \ instruction_ptr @ 235 = IF instruction_ptr @ . CR vars .v  CR THEN
    instruction_ptr @ 0< IF
        ." found: " vars v-input .vector CR
    ELSE
        instructions instruction_ptr @ vector-addr @ { instr }
        -1 instruction_ptr +!
        instr vars instruction-execute
        1 instruction_ptr +!
    THEN
;

( vars x y -- vars r )
: apply-add + ;
: apply-mul * ;
: apply-div div-trunc ;
: apply-mod mod ;
: apply-eql = IF 1 ELSE 0 THEN ;
: apply-inp { vars x y -- }
    vars vars v-input vector-pop assert( DUP DUP 0 > SWAP < 10 AND )
;

: transform-add { x y vars -- valid }
    \ ." add " x . CR
    vars x v-get { l } l @ { v }
    v y - l !
    vars find-solutions
    v l !
;

: transform-mul { x y vars -- }
    \ ." mul " CR
    vars x v-get { l } l @ { v }
    y 0 = IF
        v 0 = IF
            x get-bounds DO
                I l !
                vars find-solutions
            LOOP
            v l !
        THEN
    ELSE
        v y MOD 0= IF
            v y / l !
            vars find-solutions
            v l !
        THEN
    THEN
;

: transform-div { x y vars -- }
    \ ." div " CR
    y 0 <> IF
        vars x v-get { l } l @ { v }
        v 0= IF
            y y NEGATE 2DUP < IF SWAP THEN 1 + DO
                I l !
                vars find-solutions
            LOOP
        ELSE
            y 0 < IF v NEGATE y NEGATE ELSE v y THEN
            { v' y' }
            y' 0 DO
                v' y' * I v' 0< IF - ELSE + THEN l !
                vars find-solutions
            LOOP
        THEN
        v l !
    THEN
;

: transform-mod { x y vars -- }
    \ ." mod " CR
    vars x v-get { l } l @ { v }
    v 0 >= v y < AND y 0 > AND IF
        5 0 DO
            v y I * + assert( dup y MOD v = ) l !
            vars find-solutions
        LOOP
        v l !
    THEN
;

: transform-inp { x _ vars -- }
    \ ." input " CR
    \ ." input " vars v-input .vector CR
    \ assert( x 0 = ( w ) )
    vars x v-get { l } l @ { v }
    v 0 > v 10 < AND IF
        vars v-input v vector-add
        x get-bounds DO
            I l !
            vars find-solutions
        LOOP
        vars v-input vector-pop DROP
        v l !
    THEN
;

: transform-eql { x y vars -- }
    \ ." eql "
    y 0= IF
    vars x v-get { l } l @ { v }
    v 0 = v 1 = OR IF
        1 v - l !
        vars find-solutions
        v l !
    THEN
    ELSE 
    vars x v-get { l } l @ { v }
    v 1 = IF
        y l !
        vars find-solutions
        v l !
    ELSE
        v 0 = IF
            x get-bounds-eql DO
                I y <> IF
                    I l !
                    vars find-solutions
                THEN
            LOOP
            v l !
        THEN
    THEN
    THEN
;

: parse-line
    2dup type CR
    bl split
    2 = IF
        assert( 1 = ) c@ [char] w - { left }
        2DROP
        ['] transform-inp ['] apply-inp left 0 true
    ELSE
        OVER c@ [char] w < IF parse-number true ELSE DROP c@ [char] w - false THEN
        { right right-const }
        assert( 1 = ) c@ [char] w - { left }
        { addr u } SWITCH addr u ['] str=
            S-CASE s" add" S-IF ['] transform-add ['] apply-add
            S-CASE s" mul" S-IF ['] transform-mul ['] apply-mul
            S-CASE s" mod" S-IF ['] transform-mod ['] apply-mod
            S-CASE s" div" S-IF ['] transform-div ['] apply-div
            S-CASE s" eql" S-IF ['] transform-eql ['] apply-eql
            S-DEFAULT 1 THROW
        S-END
        left right right-const
    THEN
    instruction-init instructions SWAP vector-add
;

: solve
depth 0 = IF

    200 ['] parse-line read-lines

    instructions vector-size 1 - instruction_ptr !

    v-init { vars }
    0 vars v-z !
    0 get-bounds DO 10 I - vars v-w !
    1 get-bounds DO I vars v-x !
    2 get-bounds DO I vars v-y !
        vars find-solutions
    LOOP LOOP LOOP

bye
    THEN
;

solve
