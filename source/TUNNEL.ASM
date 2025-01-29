; [Fast Tunnel] for CrASH v1.3
;  by Andrew Von Dollen (Waffy on IRC)
;
; Rewritten partially for speed/space optimizations by Hideaki Omuro (CrASH)
; Ported/modified/redistributed for CrASH with permission.

.INCLUDE CRASH82.INC
.DB      "Fast Tunnel by AVD", 0

x1      = TEXT_MEM              ; X coordinate of the left side of the tunnel
x2      = TEXT_MEM+1            ; X coordinate of the right side of the tunnel
ShipX   = TEXT_MEM+2            ; X coordinate of the ship
Score   = TEXT_MEM+3            ; The score

R_ARROW = $01
L_ARROW = $02

  DI                            ; Disable interrupts, just speeds it up a bit

  LD  HL, x1                    ; Initialize Variables
  LD  (HL), 24                  ;  | x1 is 24   [Score is already 0 'cuz
  INC HL                        ;  |            [textmem is cleared in crash
  LD  (HL), 69                  ;  | x2 is 69   [graph_mem is also cleared
  INC HL                        ;  |
  LD  (HL), 42                  ; \ / ShipX is 42

keyloop:
  LD  HL, (Score)               ; Add 1 to the score each turn through the loop
  INC HL
  LD  (Score), HL

  CALL Scroll                   ; Scroll the screen down (2 lines in same routine)

  LD  E, 0                      ; Top Row

  LD  A, (x1)
  LD  B, E \ LD  C, A
  CALL BlackLine                ; Draw a line from (0, 0) to (x1, 0)
  LD  A, (x2)
  LD  B, A \ LD  C, 95
  CALL BlackLine                ; Draw a line from (x2, 0) to (95, 0)

  CALL RAND                     ; Get a 7 bit random number (0-127) (sub inside CrASH)

  LD  HL, x1
  CP  63 \ JR  C, Add           ; If rand<63 then goto 'add'
Sub:
  LD  A, (HL)
  SUB 2 \ JR  C, Add            ; Can't go off the screen
  LD  (HL), A
  INC HL
  DEC (HL)
  DEC (HL)                      ; Subtract 2 from both x1 and x2
  JR  Past_Update               ; Jump past the add part
Add:
  INC HL \ LD  A, (HL) \ DEC HL ; get x2
  CP  94 \ JR  NC, Sub          ; We don't want to go off the screen
  INC (HL)
  INC (HL)
  INC HL
  INC (HL)
  INC (HL)                      ; Add 2 to both x1 and x2

Past_Update:
  LD  HL, ShipX                 ; HL contains ShipX offset

  LD  A, %11111110
  OUT ($01), A                  ; Mask out up/down/left/right
  IN  A, ($01)
  LD  B, A

  BIT 1, B \ JR  NZ, NoLeft     ; If you get bit 1 set, Left isn't down
  LD  A, (HL)
  OR  A \ JR  Z, NoLeft         ; Ship can't go off the screen
  DEC (HL)                      ; Decrement Ship's X coordinate

NoLeft:
  BIT 2, B \ JR  NZ, NoRight    ; Right isn't down if bit 2 set
  LD  A, (HL)
  CP  88 \ JR  Z, NoRight       ; Can't go off the screen to the right either
  INC (HL)                      ; Increment Ship's X coordinate
NoRight:
  LD  A, %10111111              ; mask out Mode and Y=
  OUT ($01), A
  IN  A, ($01)
  BIT 4, A \ JP  Z, EXIT_2_TIOS ; check for Y='s Status
  BIT 6, A \ JR  Z, Exit        ; check for Mode's Status

                                ; HL already contains ShipX offset

  LD  C, 63                     ; see if the ship has hit anything
  LD  B, (HL)                   ; goes on for a while...
  INC B                         ; [
  CALL GetPixel \ JR  NZ, Exit  ; ]
  LD  A, (HL) \ ADD A, 6        ; [
  LD  B, A                      ; ]
  CALL GetPixel \ JR  NZ, Exit  ; [
  DEC C                         ; ]
  LD  B, (HL)                   ; [
  INC B \ INC B                 ; ]
  CALL GetPixel \ JR  NZ, Exit  ; [
  INC B \ INC B \ INC B         ; ]
  CALL GetPixel \ JR  NZ, Exit  ; [
  DEC C                         ; ]
  DEC B \ DEC B                 ; [
  CALL GetPixel \ JR  NZ, Exit  ; ]
  INC B                         ; [
  CALL GetPixel \ JR  NZ, Exit  ;\ /  All done checking for a hit

  CALL PutShip                  ; Put the ship onto the screen
  CALL CR_GRBCopy               ; Copy GRAPH_MEM to LCD
  JP  keyloop

Exit:
  CALL PutShip                  ; Put the ship onto the screen
  CALL CR_GRBCopy               ; Copy GRAPH_MEM to LCD
  LD  HL, $0203                 ; Set up coords (2, 3)
  LD  ($800C), HL
  LD  HL, ScoreStr
  ROM_CALL(D_ZT_STR)            ; write "Score: "
  LD  HL, (Score)
  ROM_CALL(D_HL_DECI)           ; Display Score (right next to Score:)

wait_for_key:
  CALL CR_KHAND
  CP  L_ARROW \ JR  Z, wait_for_key ; If this weren't here, you probably wouldn't see the score screen
  CP  R_ARROW \ JR  Z, wait_for_key ; Take them out to see what I mean
  RET

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Scrolls Screen Down by 2 Rows
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Scroll:
  LD  HL, GRAPH_MEM+743         ; start copying 2 rows from the bottom
  LD  DE, GRAPH_MEM+767         ; start copying to the end of GRAPH_MEM
  LD  BC, 744                   ; copy 744 bytes
  LDDR                          ; load decrement, repeat

  LD  HL, GRAPH_MEM+35          ; start copying 3 rows from the top
                                ; DE points already to 1st row
  LD  BC, 12                    ; copy 12 bytes
  LDDR                          ; load decrement, repeat

  LD  HL, GRAPH_MEM+10          ; Clear Top Row
  EX  DE, HL
  LD  BC, 11
  LD  (HL), B
  LDDR

  RET

PutShip:
DrwSpr:   ; Another great routine by Movax ** Optimized for TUNNEL (thrashed)
  LD  IX, Ship                  ; get address to ship sprite, IX -> sprite

  LD  A, (ShipX)                ; x coord is ShipX

  LD  HL, GRAPH_MEM+732         ; y coord is always 61, add Graph_mem+61*12
  LD  D, 0 \ LD  E, A           ; Do x/8
  SRL E \ SRL E \ SRL E
  ADD HL, DE
  AND %00000111                 ; Get the remainder of x/8
  JR  Z, Aligned                ; Is this sprite aligned to 8*n,y?
  LD  E, 3                      ; Line loop
  LD  B, A                      ; B=how many bits to shift each line
  LD  C, 0                      ; C=empty
LineLoop:
  PUSH BC                       ; Shift loop
  LD  A, (IX+0)                 ; Get sprite data
ShiftLoop:
  RRA \ RR  C
  DJNZ ShiftLoop

  OR  (HL) \ LD  (HL), A        ; Write line to graphbuf
  INC HL
  LD  A, C
  OR  (HL) \ LD  (HL), A
  INC IX
  LD  BC, 11                    ; Calculate next line address
  ADD HL, BC                    ; Inc spritepointer
  POP BC
  DEC E
  JR  NZ, LineLoop              ; Next line
  RET

Aligned:                        ; Blit an aligned sprite to graphbuf
  LD  B, 3
  LD  DE, 12
AlignedLoop:
  LD  A, (IX+0)
  OR  (HL)                      ; xor=erase/blit
  LD  (HL), A
  INC IX
  ADD HL, DE
  DJNZ AlignedLoop
  RET

; ** GetPixel
; Input:   Coordinates (B, C)
; Returns: Z is set if pixel is off
;          Z is cleared if pixel is on
GetPixel:
  PUSH HL
  PUSH BC
FindPix:                        ; Same as FIND_PIXEL but maybe faster
  LD  A, B                      ; Save B (real X val)
  LD  B, 0
  LD  H, B
  LD  L, C
  ADD HL, HL
  ADD HL, BC
  ADD HL, HL
  ADD HL, HL
  LD  C, A
  SRL C
  SRL C
  SRL C
  ADD HL, BC
  LD  BC, GRAPH_MEM
  ADD HL, BC
  LD  B, %10000000
  AND %00000111
  JR  Z, GetPixDone
  LD  C, A
  LD  A, B
  LD  B, C
ShloopGetPix:
  RRA
  DJNZ ShloopGetPix
  LD  B, A
GetPixDone:
  LD  A, (HL)
  AND B
  POP BC
  POP HL
  RET

; ** BlackLine       from Plain Jump by Andreas Ess ** Modified for TUNNEL
;                                                  and optimized (thrashed)
; Returns: Horizontal Line from (B,E)-(C,E)
BlackLine:
  PUSH HL
  PUSH DE
  LD  HL, GRAPH_MEM             ; ** we are always doing top line
  LD  D, 0 \ LD   E, B
  SRL E \ SRL  E \ SRL  E       ; Divide x by 8
  ADD HL, DE                    ; HL now contains video-offset (B, C)

  LD  A, C                      ; Calc # of times to repeat line loop
  SUB B
  INC A \ LD  C, A
  LD  A, B                      ; Load real x1-pos into A
  AND %00000111                 ;  and make mask
  LD  B, A                      ; Find number to shift
  LD  D, %10000000              ; Video-Mask setup
  LD  A, (HL)                   ; Get Data ready
  JR  Z, BLoop                  ; Ready for Line Plotting?
ShiftBLoop:
  SRL D
  DJNZ ShiftBLoop
BLoop:                          ; Ready-go!
  OR  D                         ; Set bit to black

  DEC C
  JR  Z, EndBlack               ; Decrement Counter - see if done and end

  RRC D                         ; Shift mask right
  JR  NC, BLoop                 ; Did the mask disappear?
  LD  (HL), A \ INC  HL \ LD   A, (HL)

  JR  BLoop
EndBlack:
  LD  (HL), A
  POP DE
  POP HL
  RET

Ship          .DB %00011000
              .DB %00100100
              .DB %01011010
ScoreStr      .DB "Score: ", 0
