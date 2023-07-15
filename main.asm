#include <xc.inc>   

; PIC16F877A Configuration Bit Settings
  CONFIG  FOSC = HS          ; Oscillator Selection bits (HS oscillator)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable bit (BOR disabled)
  CONFIG  LVP = OFF             ; Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3 is digital I/O, HV on MCLR must be used for programming)
  CONFIG  CPD = OFF             ; Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
  CONFIG  WRT = OFF             ; Flash Program Memory Write Enable bits (Write protection off; all program memory may be written to by EECON control)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

psect   barfunc,local,class=CODE,delta=2 ; PIC10/12/

;CONSTANTS DECLARATIONS
  
R_A equ 0   ; RB0 is Row 1
R_B equ 1   ; RB1 is Row 2
R_C equ 2   ; RB2 is Row 3
R_D equ 3   ; RB3 is Row 4
C_1 equ 4   ; RB4 is Column 1
C_2 equ 5   ; RB5 is Column 2
C_3 equ 6   ; RB6 is Column 3
C_4 equ 7   ; RB7 is Column 4
 
RS  equ 0   ;Register select pin
RW  equ 1   ;Read/Write control pin
E   equ 2   ;Enable pin
   
;VARIABLE DECLARATIONS
   
delay_counter	equ 20h	    ; value for the delay
transfer_byte	equ 21h	    ; data transfered to the LCD drivers
first_digit	equ 22h	    ; the first entered by user (single or double digit)
temp		equ 23h	    ; temporary variable
result		equ 25h	    ; multiplied value by 10
value		equ 26h	    ; value which is subjected to multiplication
key_counter	equ 28h	    ; number of keypress
num		equ 29h     ; three-digit number to be broken into digits
quotient	equ 31h     ; quotient used for division
hundreds	equ 32h     ; hundreds digit
tens		equ 33h     ; tens digit
ones		equ 34h     ; ones digit
		
;===============================================================================		
MAIN:			    ; main routine
;===============================================================================

lcd_pin_config:
    bcf STATUS,6  
    bsf STATUS,5	    ; Register bank 1 selected 
    
    movlw 0x00		    ; moving 0 to W register
    movwf TRISC		    ; PORT C all pins configured as output
    movwf TRISD		    ; PORT D all pins configured as output
    
    bcf STATUS, 5           ; Register bank 0 selected 
    
    movlw 0		    
    movwf PORTC		    ; setting all pins of PORT C to LOW
    movwf PORTD		    ; setting all pins of PORT D to LOW
    
keypad_pin_config:
    bsf STATUS,5	    ; Register bank 1 selected 
    
    bsf TRISB, C_1	    ; Setting column 1 as an input
    bsf TRISB, C_2	    ; Setting column 2 as an input
    bsf TRISB, C_3	    ; Setting column 3 as an input
    bsf TRISB, C_4	    ; Setting column 4 as an input
    bcf TRISB, R_A	    ; Setting row A as an output
    bcf TRISB, R_B	    ; Setting row B as an output
    bcf TRISB, R_C	    ; Setting row C as an output
    bcf TRISB, R_D	    ; Setting row D as an output
    
    bcf STATUS,5	    ; Register bank 0 selected 
    
    movlw 0x00
    movwf PORTB		    ; setting all pins of PORT B to LOW
    
    movlw 0xFF
    movwf delay_counter     ; assigning 255 to the delay counter
    
    call LCD_INIT	    ; sub-routine call
    
loop:			    ; infinity loop
    call KEYPAD_SCAN	    ; sub-routine call
    goto loop
    
;Sub-routine to scan the each key of the key-pad for possible key press
KEYPAD_SCAN:   
    bsf	PORTB, R_A	    ; Setting row A HIGH    
	
    btfsc PORTB, C_1	    ; Checking coloumn 1 for HIGH
    call CHAR_7		    ; sub-routine call to key digit 7
wait_key7_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_1
    goto wait_key7_release    
    
    btfsc PORTB, C_2	    ; Checking coloumn 2 for HIGH
    call CHAR_8		    ; sub-routine call to key digit 8   
wait_key8_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_2
    goto wait_key8_release    
    
    btfsc PORTB, C_3	    ; Checking coloumn 3 for HIGH
    call CHAR_9		    ; sub-routine call to key digit 9    
wait_key9_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_3
    goto wait_key9_release
    
    bcf	PORTB, R_A	    ; Setting row A LOW

    
    bsf	PORTB, R_B	    ; Setting row B HIGH  
  
    btfsc PORTB, C_1	    ; Checking coloumn 1 for HIGH
    call CHAR_4		    ; sub-routine call to key digit 4
wait_key4_release:	    ;loop created to wait untill key is released
    btfsc PORTB, C_1
    goto wait_key4_release
    
    btfsc PORTB, C_2	    ; Checking coloumn 2 for HIGH
    call CHAR_5		    ; sub-routine call to key digit 5 
wait_key5_release:	    ;loop created to wait untill key is released
    btfsc PORTB, C_2
    goto wait_key5_release
    
    btfsc PORTB, C_3	    ; Checking coloumn 3 for HIGH
    call CHAR_6		    ; sub-routine call to key digit 6  
wait_key6_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_3
    goto wait_key6_release
    
    bcf	PORTB, R_B	    ; Setting row B LOW
 

     
    bsf	PORTB, R_C	    ; Setting row C HIGH    
 
    btfsc PORTB, C_1	    ; Checking coloumn 1 for HIGH
    call CHAR_1		    ; sub-routine call to key digit 1    
wait_key1_release:	    ; loop created to wait untill key is released 
    btfsc PORTB, C_1
    goto wait_key1_release
    
    btfsc PORTB, C_2	    ; Checking coloumn 2 for HIGH
    call CHAR_2		    ; sub-routine call to key digit 2  
wait_key2_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_2
    goto wait_key2_release
    
    btfsc PORTB, C_3	    ; Checking coloumn 3 for HIGH
    call CHAR_3		    ; sub-routine call to key digit 3   
 wait_key3_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_3
    goto wait_key3_release

    bcf	PORTB, R_C	    ; Setting row C LOW
    
    bsf	PORTB, R_D	    ; Setting row D HIGH  
  
    btfsc PORTB, C_1	    ; Checking coloumn 1 for HIGH
    call CLEAR		    ; sub-routine call to clear display and reset
 wait_clr_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_1
    goto wait_clr_release
    
    btfsc PORTB, C_2	    ; Checking coloumn 2 for HIGH
    call CHAR_0             ; sub-routine call to key digit 9 
 wait_key0_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_2
    goto wait_key0_release
    
    btfsc PORTB, C_3	    ; Checking coloumn 3 for HIGH
    call CHAR_equal	    ; sub-routine call to key equal character
 wait_equal_release:	    ; loop created to wait untill key is released
    btfsc PORTB, C_3
    goto wait_equal_release 
    
    btfsc PORTB, C_4	    ; Checking coloumn 4 for HIGH
    call CHAR_plus	    ; sub-routine call to key plus character   
 wait_plus_release:	    ; loop created to wait untill key is released 
    btfsc PORTB, C_4
    goto wait_plus_release
    
    bcf	PORTB, R_D	    ; Setting row D LOW
    
    return		    ; return to the caller
   
; sub-routine to perform tasks when key digit 0 is pressed   
CHAR_0:
    movlw 48		    ; ascii value of digit zero
    call LCD_WRITE	    ; print '0'
    
    movlw 0
    incf key_counter,f      ; increment key counter by 1
    addwf temp,f	    ; add 0 to the temp variable
    return
    
; sub-routine to perform tasks when key digit 1 is pressed 
CHAR_1:
    movlw 49		    ; ascii value of digit one
    call LCD_WRITE	    ; print '1'
    
    movlw 1
    incf key_counter,f	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop			    ; no operation
    btfss key_counter, 0 
    addwf temp,f	    ; even presses cosidered as the digit in 1s place
    return
    
; sub-routine to perform tasks when key digit 2 is pressed 
CHAR_2:
    movlw 50		    ; ascii value of digit two
    call LCD_WRITE	    ; print '2'
    
    movlw 2
    incf key_counter,1	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop
    btfss key_counter, 0 
    addwf temp,1	    ; even presses cosidered as the digit in 1s place
    return

; sub-routine to perform tasks when key digit 3 is pressed 
CHAR_3:
    movlw 51		    ; ascii value of digit three
    call LCD_WRITE	    ; print '3'
    
    movlw 3
    incf key_counter,1	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop
    btfss key_counter, 0 
    addwf temp,1	    ; even presses cosidered as the digit in 1s place
    return
    
; sub-routine to perform tasks when key digit 4 is pressed 
CHAR_4:
    movlw 52		    ; ascii value of digit four
    call LCD_WRITE	    ; print '4'
    
    movlw 4
    incf key_counter,1	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop
    btfss key_counter , 0 
    addwf temp,1	    ; even presses cosidered as the digit in 1s place
     return
     
; sub-routine to perform tasks when key digit 5 is pressed 
CHAR_5:
    movlw 53		    ; ascii value of digit five
    call LCD_WRITE	    ; print '5'

    movlw 5
    incf key_counter,1	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop
    btfss key_counter , 0 
    addwf temp,1	    ; even presses cosidered as the digit in 1s place
    return
    
; sub-routine to perform tasks when key digit 6 is pressed     
CHAR_6:
    movlw 54		    ; ascii value of digit six
    call LCD_WRITE	    ; print '6'
    
    movlw 6
    incf key_counter,1	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop
    btfss key_counter , 0 
    addwf temp,1	    ; even presses cosidered as the digit in 1s place   
    return 
    
; sub-routine to perform tasks when key digit 7 is pressed 
CHAR_7:
    movlw 55		    ; ascii value of digit seven
    call LCD_WRITE	    ; print '7'
    
    movlw 7    
    incf key_counter,1	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop
    btfss key_counter , 0 
    addwf temp,1	    ; even presses cosidered as the digit in 1s place 
    return
    
; sub-routine to perform tasks when key digit 8 is pressed 
CHAR_8:
    movlw 56		    ; ascii value of digit eight
    call LCD_WRITE	    ; print '8'
    
    movlw 8    
    incf key_counter,1	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop
    btfss key_counter , 0 
    addwf temp,1	    ; even presses cosidered as the digit in 1s place  
    return 
    
; sub-routine to perform tasks when key digit 9 is pressed     
CHAR_9:
    movlw 57		    ; ascii value of digit nine
    call LCD_WRITE	    ; print '9'
    
    movlw 9
    incf key_counter,1	    ; increment key counter by 1
    btfsc key_counter, 0    ; check whether odd or even press
    call MULTIPLY_BY_10	    ; odd presses cosidered as the digit in 10s place
    nop
    btfss key_counter , 0 
    addwf temp,1	    ; even presses cosidered as the digit in 1s place
    return 
    
; sub-routine to perform tasks when key character equal is pressed 
CHAR_equal:
    movlw 61		    ; ascii value of character equal
    call LCD_WRITE	    ; print '='
    
    movf temp, W	    ; move second digit to W register
    addwf first_digit,w	    ; add first and second digits
    
    movwf num		    ; move the addition the sum register
    call SPLIT_DIGIT	    ; sub-routine call to seperate the digits
    call PRINT_DIGIT	    ; print answer
    clrf key_counter	    ; clear registers
    clrf temp    
    return 
    
; sub-routine to perform tasks when key character plus is pressed 
CHAR_plus:
    movlw 43		    ; ascii value of character plus
    call LCD_WRITE	    ; print '+'
    
    movf temp, W	    ; move the first digit to a variable
    movwf first_digit 
    clrf temp		    ; clear temp register to get input on second digit
    clrf key_counter	    ; clear register
    return 
    
; sub-routine to perform tasks when key ON is pressed 
CLEAR:    
    call LCD_CLEAR	    ; sub-routine call to clear diplay
    clrf temp		    ; clear registers
    clrf key_counter
    clrf first_digit
    clrf hundreds
    clrf tens
    clrf ones
    clrf num
    movlw 0
    return 

; sub-routine to print the answer digit by digit
PRINT_DIGIT:
    movf hundreds,w	    ; move the hundredth place digit to W register
    addlw 0x30		    ; add the ascii offset - 48
    call LCD_WRITE	    ; sub-routine call to print character
    movf tens,w		    ; move the tenth place digit to W register
    addlw 0x30
    call LCD_WRITE
    movf ones,w		    ; move the oneth place digit to W register
    addlw 0x30
    call LCD_WRITE

;short delay routine  
SHORT_DELAY:		 
    decfsz delay_counter    ; decrement the register value by one unitll zero
    goto SHORT_DELAY	    ; loop back
    movlw 0xFF		    ; reload the delay value
    movwf delay_counter
    return
;short delay routine     
LONG_DELAY:
    call SHORT_DELAY
    call SHORT_DELAY
    return

; Sub-routine to configure the LCD   
LCD_INIT:    
    bcf PORTC, RS	    ; instruction register selected
    bcf PORTC, RW	    ; write mode selected
    
    movlw 0x02
    call LCD_WRITE	    ; Send 0x02 to initialize 4-bit mode    
    movlw 0x28
    call LCD_WRITE	    ; Send 0x28 to configure 2 lines and 5x8 dots  
    movlw 0x0E
    call LCD_WRITE	    ; Send 0x0E to turn on display and cursor
    movlw 0x01
    call LCD_WRITE	    ; Send 0x01 to clear display
    movlw 0x80
    call LCD_WRITE	    ; Send 0x80 to set cursor to the start of the first line
    
    bsf PORTC, RS	    ; data register selected   
    return
 
; Sub-routine to write data to the LCD
LCD_WRITE:
    movwf transfer_byte	    ; Save the value of data in a temporary register  
    
    movlw 0b11110000	    ; Bit mask to clear the lower nibble
    andwf transfer_byte, W  ; Clear the lower nibble of data
    movwf PORTD		    ; Set upper 4 bits of the data
    
    bsf PORTC, E	    ; pulse enable
    call SHORT_DELAY	    ; Delay
    bcf PORTC, E
    
    call LONG_DELAY  
    
    swapf transfer_byte, W  ; swap the nibbles of the data
    andlw 0b11110000	    ; mask to clear the lower nibble
    movwf PORTD		    ; set lower 4 bits of the data
    
    bsf PORTC, E	    ; pulse enable
    call SHORT_DELAY	    ; Delay 
    bcf PORTC, E      
    
    call LONG_DELAY
    return	

; Sub-routine to clear display
LCD_CLEAR:
    bcf PORTC, RS	    ; instruction register selected
    movlw 0x01
    call LCD_WRITE          ; Send 0x01 to clear display
    bsf PORTC, RS	      
    return  

; Sub-routine to split a 3 digit number to individual digits
SPLIT_DIGIT:
    clrf quotient	    ; clear register
    movlw 100		    ; load the divisor
    call DIVIDE		    ; divide number by 100 to find the hundreth place
    movf quotient,w	    ; save in seperate register
    movwf hundreds
    
    movlw 0xff		    
    addwf num,w		    ; if 10th place digit is zero return from function
    btfsc STATUS,2
    return    

    clrf quotient
    movlw 100	
    addwf num,f		    ; extract the remaining 2 digit portion

    movlw 10		    ; load the divisor
    call DIVIDE		    ; divide number by 10 to find the tenth place
    movf quotient,w	    ; save in seperate register
    movwf tens
    
    movlw 0xff		    
    addwf num,w
    btfsc STATUS,2	    ; if 1th place digit is zero return from function
    return

    clrf quotient	    ; extract the remaning one digit
    movlw 10	
    addwf num,f

    movf num, w		    ; save it in seperate register
    movwf ones    
    return

;sub-routine to divide by hundred and ten
DIVIDE: 	
divide_sub_loop:
    subwf num, F	    ; subtract divisor from num
    btfss STATUS, 0	    ; if carry bit is set, skip next line
    return
    incf quotient, F	    ; increment quotient 
    goto divide_sub_loop    ; loop back
    
;sub-routine to multiply a number by 10
MULTIPLY_BY_10:   
    movwf value		    ; the number to be multiplied
    addwf value, f	    ; add the value by itself
    addwf value, f	    ; add the value by itself
    addwf value, f	    ; add the value by itself
    addwf value, f	    ; add the value by itself   
    rlf value,w		    ; shift left one bit to multiply by 2
    movwf result
    addwf temp,f
    return 
	

