needs ../util/io.fth
needs ../util/string.fth
needs ../util/switch.fth
needs ../util/vector.fth

: v-a ( vars -- addr ) 0 CELLS + ;
: v-b ( vars -- addr ) 1 CELLS + ;
: v-c ( vars -- addr ) 2 CELLS + ;
: v-d ( vars -- addr ) 3 CELLS + ;
: v-e ( vars -- vec ) 4 cells + ;

: v-get { vars -- a b c d e }
    5 0 DO
        vars I CELLS + @
    LOOP
;

: v-init 
    5 CELLS ALLOCATE throw { v }
    v 5 CELLS 0 FILL
    14 vector-init v 4 CELLS + !
    v
;

: .v { vars }
    ."  a: " vars v-a @ .
    ."  b: " vars v-b @ .
    ."  c: " vars v-c @ .
    ."  d: " vars v-d @ .
    ."  e: " vars v-e @ .
;

14 vector-init CONSTANT instructions
100 vector-init CONSTANT found
1 CELLS ALLOCATE THROW CONSTANT instruction_ptr

: model-number { ws -- n }
    0
    ws vector-size { s } s 0 DO
        10 *
        ws s 1 - I - vector-addr @ + 
    LOOP
;

: find-solutions { z ws -- }
    instruction_ptr @ -1 = IF
        z 0 = IF
            ws model-number { n }
            ." found: " n .
            found n vector-add
            ."  max: " found ['] max vector-fold .
            ."  min: " found ['] min vector-fold . CR
        THEN
        exit
    THEN
    instructions instruction_ptr @ vector-addr @ v-get { a b c d e }
    -1 instruction_ptr +!
    10 1 DO 10 I - { w }
        ws w vector-add
        z d MOD 0 = IF
            z d / a * { z' }
            a 0 DO
                w z' I + 26 MOD b + = IF
                    z' I + ws RECURSE
                THEN
            LOOP
        THEN
        z w e + - { z' }
        z' c d + MOD 0 = IF
            z' c d + / a * { z'' }
            a 0 DO
                w z'' I + 26 MOD b + <> IF
                    z'' I + ws RECURSE
                THEN
            LOOP
        THEN
        ws vector-pop DROP
    LOOP
    1 instruction_ptr +!
;

102 CHARS ALLOCATE THROW CONSTANT line
: read-next { -- addr u }
    line 100 stdin read-line THROW assert( 0<> )
    line SWAP
;

: c-skip { ( addr u ) k -- addr+k u-k }
    k - SWAP k CHARS + SWAP
;

: parse-group
    v-init { v }
    read-next assert( s" inp w" str= )
    read-next assert( s" mul x 0" str= )
    read-next assert( s" add x z" str= )
    read-next assert( s" mod x 26" str= )
    read-next assert( 2dup s" div z " starts-with )
        6 c-skip parse-number v v-a ! 
    read-next assert( 2dup s" add x " starts-with )
        6 c-skip parse-number v v-b ! 
    read-next assert( s" eql x w" str= )
    read-next assert( s" eql x 0" str= )
    read-next assert( s" mul y 0" str= )
    read-next assert( 2dup s" add y " starts-with )
        6 c-skip parse-number v v-c ! 
    read-next assert( s" mul y x" str= )
    read-next assert( 2dup s" add y " starts-with )
        6 c-skip parse-number v v-d ! 
    read-next assert( s" mul z y" str= )
    read-next assert( s" mul y 0" str= )
    read-next assert( s" add y w" str= )
    read-next assert( 2dup s" add y " starts-with )
        6 c-skip parse-number v v-e ! 
    read-next assert( s" mul y x" str= )
    read-next assert( s" add z y" str= )
    instructions v vector-add
;

: solve
depth 0 = IF

    14 0 DO
        parse-group
    LOOP

    instructions vector-size 1 - instruction_ptr !

    0 14 vector-init find-solutions


    ." max-found: " found ['] max vector-fold . CR
    ." min-found: " found ['] min vector-fold . CR
bye
    THEN
;

solve
