100 CELLS ALLOCATE THROW CONSTANT switch-stack
switch-stack switch-stack !

: switch-internal-push 1 CELLS switch-stack +! switch-stack @ ! ;

: switch-internal-drop -1 CELLS switch-stack +! ;

: switch-internal-execute switch-stack @ @ EXECUTE ;

: SWITCH 
    POSTPONE ['] POSTPONE switch-internal-push POSTPONE FALSE POSTPONE IF 
    1
; immediate

: S-CASE
    { switch-size }
    POSTPONE ELSE 
    switch-size
; immediate

: S-DEFAULT POSTPONE S-CASE ; immediate

: S-IF
    { switch-size }
    POSTPONE switch-internal-execute POSTPONE IF
    switch-size 1 +
; immediate

: S-END 0 DO POSTPONE THEN LOOP POSTPONE switch-internal-drop  ; immediate

: =str-preserve ( addr1 u1 addr2 u2 -- addr1 u1 if-equal )
    2OVER COMPARE 0 =
;

: test-switch ( addr1 u1 )
    SWITCH =str-preserve
        S-CASE s" 123" S-IF ." it was 123" CR
        S-CASE s" 456" S-IF ." it was 456" CR
        S-CASE s" 789" S-IF ." it was 789" CR
        S-DEFAULT ." it was unknown" CR
    S-END
;

see test-switch CR

100 CONSTANT max-line-size
max-line-size 2 + CHARS ALLOCATE THROW CONSTANT line-buffer
line-buffer max-line-size stdin READ-LINE THROW DROP
line-buffer SWAP test-switch

bye
