needs ../util/string.fth
needs ../util/io.fth
needs ../util/list.fth
needs ../util/graph.fth

200 CONSTANT max-nodes
max-nodes CELLS ALLOCATE THROW CONSTANT labels
0 labels !
max-nodes CELLS ALLOCATE THROW CONSTANT large-caves

: clone-to-cstr { addr u -- cstr-addr }
    addr u 1 + CHARS CLONE
    0 OVER u CHARS + C!
;

: label-to-index { addr u }
    labels @ { label-count }
    0 ( found-position )
    label-count 0 > IF
    label-count 1 + 1 DO
        labels I CELLS + @ { cstr }
        cstr cstr-length { cstr-u }
        cstr cstr-u addr u COMPARE 0 = IF
            DROP I LEAVE
        THEN
    LOOP
    THEN
    DUP 0 = IF
        DROP
        label-count 1 + DUP labels !
        ( last-label )
        CELLS labels + 
        addr u clone-to-cstr SWAP !
        label-count 1 + { index }
        addr C@ 97 ( a ) < large-caves index CELLS + !
        index
    THEN
;

: is-large-cave { cave -- if_large }
    large-caves cave CELLS + @
;

: process-line { graph addr u -- graph }
    addr u 45 ( - ) split assert( 2 = )
    label-to-index { dst }
    label-to-index { src }
    graph src dst graph-add-edge
    graph dst src graph-add-edge
    graph
;


max-nodes CELLS ALLOCATE THROW CONSTANT visited
visited max-nodes CELLS 0 FILL


: count-paths-to { ( count ) graph goal start revisited -- count }
    start goal = IF
        1+
    ELSE
        visited start CELLS + { v-pos }
        v-pos @ 1 < start is-large-cave OR ( not yet visited )
        DUP INVERT revisited INVERT AND IF
            DROP true true
        ELSE
            revisited
        THEN { with-revisit }
        IF
            1 v-pos +!
            graph start graph-get-neighbors { addr u }
            u 0 DO
                addr I CELLS + @ { neighbor }
                neighbor 1 <> IF
                    graph goal neighbor with-revisit RECURSE
                THEN
            LOOP
            -1 v-pos +!
        THEN
    THEN
;

: solve 
    depth 0 = IF
s" start" label-to-index assert( 1 = )
s" end" label-to-index assert( 2 = )


100 graph-init
4096 ['] process-line read-lines
{ graph }

0 graph 2 1 true count-paths-to
."  First star: " . CR

0 graph 2 1 false count-paths-to
." Second star: " . CR


bye


    THEN
;

solve
