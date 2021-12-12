: graph-init { n -- addr }
    n n * 1 + CELLS ALLOCATE THROW { graph }
    n graph !
    n 0 DO
        0 graph 1 n I * + CELLS + !
    LOOP
    graph
;

: graph-add-edge { graph src dst }
    graph @ { n }
    1 src n * + CELLS graph + ( node-addr )
    1 OVER +! DUP @ CELLS + dst SWAP !
;

: graph-get-neighbors { graph node -- addr u }
    graph @ { n }
    graph 1 node n * + CELLS +
    DUP @ SWAP 1 CELLS + SWAP
;

: graph-print { graph }
    graph @ { n }
    n 0 DO
        graph I graph-get-neighbors
        DUP 0 > IF 
            space I . ." :" print-cells CR
        ELSE
            2DROP
        THEN
    LOOP
;
