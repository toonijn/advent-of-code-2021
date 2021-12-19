needs custom-stack.fth

: N>switch-stack-copy { ( x1 .. xn ) N -- x1 .. xn }
    N 0 DO
        I PICK >custom-stack
    LOOP
;

: Nswitch-stack>-copy { N -- x1 .. xn }
    N 0 DO
        I custom-stack-PICK
    LOOP
;

: switch-internal-prepare
    depth >custom-stack
;

: switch-internal-store
    depth custom-stack> - { size }
    size N>switch-stack-copy
    size 0 DO DROP LOOP
    size >custom-stack
;

: switch-internal-drop
    custom-stack> custom-stack-DROPN
;

: switch-internal-execute
    custom-stack> { size }
    size Nswitch-stack>-copy
    size >custom-stack
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

: switch-test-internal
    SWITCH 2DUP ['] =str 
        S-CASE s" 123" S-IF 321
        S-CASE s" 456" S-IF 654
        S-CASE s" 789" S-IF 987
        S-DEFAULT 0
    S-END
    SWAP DROP SWAP DROP
;

: switch-test-internal-deep { n addr u }
    SWITCH n ['] =
        S-CASE 0 S-IF addr u switch-test-internal 1000 +
        S-CASE 1 S-IF 654
        S-CASE 2 S-IF addr u switch-test-internal
        S-DEFAULT addr u switch-test-internal 2000 +
    S-END
;

: switch-test
    assert( s" 123" switch-test-internal 321 = )
    assert( s" 456" switch-test-internal 654 = )
    assert( s" 789" switch-test-internal 987 = )
    assert( s" 147" switch-test-internal 0 = )

    assert( 0 s" 123" switch-test-internal-deep 1321 = )
    assert( 0 s" 456" switch-test-internal-deep 1654 = )
    assert( 0 s" 789" switch-test-internal-deep 1987 = )
    assert( 0 s" 963" switch-test-internal-deep 1000 = )

    assert( 1 s" 123" switch-test-internal-deep 654 = )

    assert( 2 s" 123" switch-test-internal-deep 321 = )
    assert( 2 s" 456" switch-test-internal-deep 654 = )
    assert( 2 s" 789" switch-test-internal-deep 987 = )
    assert( 2 s" 963" switch-test-internal-deep 0 = )

    assert( -10 s" 123" switch-test-internal-deep 2321 = )
    assert( -6 s" 456" switch-test-internal-deep 2654 = )
    assert( 8 s" 789" switch-test-internal-deep 2987 = )
    assert( 100 s" 963" switch-test-internal-deep 2000 = )
    
;
