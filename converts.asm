        NAME    CONVERTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   CONVERTS                                 ;
;                             Conversion Functions                           ;
;                                   EE/CS 51                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; file description including table of contents
;
; Revision History:
;     10/18/15  Ashwin Hari      revision
;     10/17/15  Ashwin Hari      revision
;     10/16/15  Ashwin Hari      initial revision
;     10/12/15  Ashwin Hari      pseudo code
$ include       (CONST.inc) 


CGROUP  GROUP   CODE


CODE	SEGMENT PUBLIC 'CODE'


        ASSUME  CS:CGROUP




; Dec2String
;
; Description: This function converts a 16-bit signed value (n) to decimal value 
; and stores the ASCII representation of this decimal value in a user-defined   
; memory location (passed in by SI). The strill will be null terminated. The 
; string format will be 5 ascii characters, maybe a sign, and the null 
; terminator. Leading zeroes and non-leading zeroes will appear.
;
; Operation: The function starts with checking if the MSB is set to 1 or not. IT
; does this by computing the bitwise AND between the value n and a mask set to
; have a binary representation 1 followed by 15 0's. If the MSB is found to be
; 1, the 2'complement of value n is found. This is done by setting n= -n + 1. 
; The 2's complement is converted to decimal by following a loop where the 
; complement is first divided by the largest power of 10 possible (10k), mapping
; the quotient to its ASCII representatrion, equating the complement to the 
; modulo, and dividing the power of 10 by 10. We loop this until the power of 10
; is 0. A null terminator is added, and the string is saved. A negative value
; is appended to the beginning of the string. If the MSB is not set to 1, the
; decimal conversion process and null nermination are conducted on the binary
; value of n (not the 2's complement). Also, a negative sign is not placed in
; the string.
;
; Arguments: n - binary value to convert to decimal, a - memory location to save
; string.
; Return Value: None.
;
; Local Variables: binary value to convert(ax), buffer of value to convert (si),
; memory byte counter (bx), power of 10 (cx)
; Shared Variables: None.
; Global Variables: None.
;
; Input: None.
; Output: None.
;
; Error Handling: None.
;
; Algorithms: To check if MSB is set: n AND 0x1000. To find 2's complement: 
; n = -n + 1. To find decimal digiits: Repeatedly divide by powers of 10 and
; get the quotients.
; Data Structures: None.
;
; Registers Changed: flags, ax, si, bx, cx, dx.
; Stack Depth: 0 words.
;
; Author: Ashwin Hari
; Last Modified: 10/18/15

Dec2String      PROC        NEAR
                PUBLIC      Dec2String

Dec2StringInit:                             ;initialization    
        MOV     BX, SI                      ;copy memory address to bx.
        MOV     SI, AX                      ;copy n to si (si is a buffer)
        MOV     CX, PWR_10_SIGNED_16_BIT    ; power of 10 - start with 10^4
    
        JMP     Dec2StringMSBTest           ;now proceed to check MSB               

Dec2StringMSBTest:                          ;examines MSB.
        AND AX, MSB_MASK_16_BIT             ;ax AND 0x8000
        MOV AX, SI                          ;restore ax value                       
        JZ Dec2StringConvertAbsValue        ;if AND sets ZF, just convert.
        JNZ  Dec2String2Comp                ;if ZF not set, find 2's comp.
        
Dec2String2Comp:                            ;find 2's comp/save neg sign
        NOT AX                              ;flip all bits of n
        ADD AX, 1                           ;add 1 to !n
        MOV BYTE PTR [BX], '-'              ;save neg sign to memory.
        INC BX                              ;increment memory offset 1 byte.              
        MOV SI, AX                          ;update si with new ax value.
        JMP Dec2StringConvertAbsValue       ;now convert to dec

Dec2StringConvertAbsValue:                  ;check status of conversion.
        CMP CX, 0                           ;see if pwr 10 = 0.
        JZ Dec2StringEND                    ;if so, done.
        JNZ Dec2StringNextDigit             ;else, find next digit.

Dec2StringNextDigit:
        XOR DX, DX                          ; make sure dx is 0.
        MOV AX, SI                          ; move remainder in si to ax.
        DIV CX                              ; divide ax by cx to get digit.
        ADD AX, ASCII_DECIMAL_OFFSET        ; 48 + quotient to get ASCII.
        MOV DS:[BX], AL                     ; save digit in al to memory.
        MOV SI, DX                          ; move modulo to si.
        MOV DX, 0                           ; set dx back to 0.
        MOV AX, CX                          ; copy value of pwr 10 into ax. 
        MOV CX, DECIMAL_BASE                ; move 10 into cx to divide ax.
        DIV CX                              ; obtain new pwr10.
        MOV CX, AX                          ; save new pwr10 in cx.
        MOV AX, SI                          ; replace quotient with si value.
        INC BX                              ; increment bx after byte is saved.
        JMP Dec2StringConvertAbsValue       ; repeat from this label.


Dec2StringEND:                                  ; save null terminator at end.
        mov BYTE PTR DS:[BX], ASCII_NULL_CHAR   ; added ASCII null to memory bx.
        INC BX                                  ; increment bx after byte saved.
        RET                                     ; go back to called function.

	

Dec2String	ENDP

; Hex2String
;
; Description: This function converts a 16-bit unsigned value (n) to hex value
; and stores the ASCII representation of this hex value in a user defined memory
; location (si). The string will be null terminated and will have 4 digits. 
; Leading and non-leading zeroes will appear in the string.
;
; Operation: The function starts by following a loop where the n value is 
; first divided by the largest power of 16 possible (16^3), mapping the quotient
; to its ascii representation, saving the value inm memory, updating the power
; of 16, and repeating this process with the modulo of that division. This loop
; will proceed until the cx = 0. A null terminator is then saved to the memory.
;
; Arguments: n - binary value to convert, a - memory location to save string.
; Return Value: None.
;
; Local Variables: binary value to convert and digit to save(ax), 
; copy of n (si) - buffer, pwr
; of 16 (cx), memory byte counter (bx). 
; Shared Variables: None.
; Global Variables: None.
;
; Input: None.
; Output: None.
;
; Error Handling: None.
; 
; Algorithms: None.                         
; Data Structures: None.
;
; Registers Changed: flags, ax, bx, cx, dx, si.
; Stack Depth: 0 words.
;
; Author: Ashwin Hari
; Last Modified: 10/18/15


Hex2String      PROC        NEAR
                PUBLIC      Hex2String  
                
Hex2StringInit:                                 ; initialization 
        MOV     BX, SI                          ;copy memory loc to bx.
        MOV     SI, AX                          ;copy n val to si.
        MOV     CX, PWR_16_UNSIGNED_16_BIT      ;set pwr 16 to 16^3.
        
        JMP     Hex2StringConvertAbsValue   ;immediately convert to hex.
        
Hex2StringConvertAbsValue:                  ;check status of cx.
        CMP CX, 0                           ;cx val = 0 means all digits have 
                                            ;been processed. 
        JZ  Hex2StringEND                   ;add null term./exit if ZF set.
        JNZ Hex2StringNextDigit             ;else, convert for next digit.

Hex2StringNextDigit:                        ;obtain next hex digit.
        XOR DX, DX                          ;ensure dx = 0, used in DIV
        MOV AX, SI                          ;update ax with modulo in si.
        DIV CX                              ;div by pwr10 - quotient
                                            ;will be digit
        CMP AX, 9                           ;see if digit is alphabetical or 
                                            ;numerical.
        JLE Hex2StringWriteSmall            ;if less than/equal --> #
        JNLE Hex2StringWriteBig             ;else, alpha
       
Hex2StringWriteSmall:                       ;save digits 0-9
        ADD AX, ASCII_HEX_SMALL_OFFSET      ;map to ASCII 
        MOV DS:[BX], AL                     ;save at memory offset - 1 byte. 
        JMP Hex2StringResetForNextDigit     ;reset used registers.
        
Hex2StringWriteBig:                         ;save digits A-F
        ADD AX, ASCII_HEX_BIG_OFFSET        ;map to ASCII
        MOV DS:[BX], AL                     ;save to memory offset.
        JMP Hex2StringResetForNextDigit 
        
Hex2StringResetForNextDigit:        
        MOV SI, DX                          ;save remainder to si.    
        MOV DX, 0                           ;reset DX - used in DIV
        MOV AX, CX                          ;move pwr16 to ax (Dividend)
        MOV CX, HEX_BASE                    ;move 16 to cx (Divisor)
        DIV CX                              ;divide for new pwr16
        MOV CX, AX                          ;move quotient to cx
        MOV AX, SI                          ;move remainder to ax.
        INC BX                              ;increment mem offset after byte is 
                                            ;saved.
        JMP Hex2StringConvertAbsValue       ;repeat from this label.


Hex2StringEND:                                      ;add null terminator.
        mov BYTE PTR DS:[BX], ASCII_NULL_CHAR       ;save ASCII null to memory
        INC BX                                      ;set mem offset after byte
                                                    ; written
        RET                                         ;return to function that 
                                                    ;called.
           
Hex2String	ENDP



CODE    ENDS



        END