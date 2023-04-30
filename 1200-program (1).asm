
LCDdatabus           	equ     0A0h     
LCDrs                  	equ     0A2H     
LCDen                  	equ     0A3H     

Input_SensorTemp      	equ     81H
Input_SensorLpg       	equ     83H

IR_Sensor				equ		0B3H


Buzzer                 	equ     84h
Relay               	equ     85h

Motor1_1              	equ     0B4H
Motor1_2               	equ     0B7H

Motor2_1               	equ     0B5H
Motor2_2               	equ     0B6H

eeprom_scl             	equ     86h
eeprom_sda             	equ     87h

keypad                 	equ     90h
Row1                   	equ     90h
Row2                    equ     91h
Row3                    equ     92h
Row4                    equ     93h
Col1                    equ     94h
Col2                    equ     95h
Col3                    equ     96h
Col4                    equ     97h


LCDreg                  equ     53h
Delreg1                 equ     54h
Delreg2                 equ     55h
Delreg3                 equ     56h
Reggsmdot               equ     57h

Reg_sensor_no           equ     58h
Reg_buzzer_on           equ     59h
LCDtempreg              equ     5Ah
Reg_LCD_swap1           equ     5Bh
Reg_LCD_swap2           equ     5Ch
memory_address         equ     5Dh
eeprom_data             equ     5Fh
eeprom_read_data        equ     3Eh
Bit_01H					equ		01H

                        org 0000h
						call initialisation
start:                  call Chk_Input_SensorTemp
                        call Chk_Input_SensorLpg

                        call Chk_IR_Sensor

                		call keypad_routine
                		call change_password
                        jmp start



Chk_Input_SensorTemp:    	jb Input_SensorTemp,Chk_Input_SensorTempret
                        call debounce
                        jb Input_SensorTemp,Chk_Input_SensorTempret

                        mov Reg_sensor_no,#01h
                        call Chk_temp_snsr_cmn

Chk_Input_SensorTempret:    ret

Chk_Input_SensorLpg:       jb Input_SensorLpg,Chk_Input_SensorLpgret
                        call debounce
                        jb Input_SensorLpg,Chk_Input_SensorLpgret

                        mov Reg_sensor_no,#02h
                        call Chk_temp_snsr_cmn

Chk_Input_SensorLpgret:    ret

Chk_IR_Sensor:       jb IR_Sensor,Chk_IR_Sensorret
                        call debounce
                        jb IR_Sensor,Chk_IR_Sensorret

                        mov Reg_sensor_no,#04h
                        call Chk_temp_snsr_cmn

Chk_IR_Sensorret:    ret

;=========================================================
Chk_temp_snsr_cmn:      setb Buzzer
                        setb Relay

                        call dptrcommon1
                        call LCDdisp

                        call Send_Sms_snsr_cmn
						
						call delay2sec
						call delay2sec

                        clr Buzzer
                        clr Relay

                        mov dptr,#msgwelcome
                        call LCDdisp
                        call delay1sec
                        ret
;=========================================================
dptrcommon1:			mov a,Reg_sensor_no
						cjne a,#01H,dptrcommon1_2
						mov dptr,#msgSensor11
                        ret
dptrcommon1_2:			cjne a,#02H,dptrcommon1_3
						mov dptr,#msgSensor21
                        ret
dptrcommon1_3:			cjne a,#03H,dptrcommon1_4
						mov dptr,#msgSensor31
                        ret
dptrcommon1_4:			cjne a,#04H,dptrcommon1_5
						mov dptr,#msgSensor41
                        ret
dptrcommon1_5:			cjne a,#05H,dptrcommon1_err
						mov dptr,#msgSensor51
                        ret
dptrcommon1_err:		ret
initialisation:         clr Bit_01H
                        clr Buzzer
                        clr Relay

                        setb Input_SensorTemp
                        setb Input_SensorLpg

                        setb IR_Sensor

        
                        call LCDinit
        
                        mov scon,#50h
                        mov tmod,#21h
                        mov th1,#0Fdh
                        mov tl1,#0Fdh
                        setb tr1

                        mov dptr,#msgwelcome
                        call LCDdispinit
                        call delay2sec
 
                        mov dptr,#msggsminit
                        call LCDdispinit
        
                        mov LCDtempreg,#0C4H
                        call LCDcmd
        
                        mov Reggsmdot,#11
gsm_init_dot:           call display_dot_01
                        call delayhalfsec
                        djnz Reggsmdot,gsm_init_dot

                        mov dptr,#msgwelcome
                        call LCDdispinit
                        call delay2sec
 

                        ret
;=========================================================
LCDinit:           		call delayhalf
                        mov LCDtempreg,#02h
                        call LCDcmd
                        mov LCDtempreg,#28h
                        call LCDcmd
                        mov LCDtempreg,#0Ch
                        call LCDcmd
                        mov LCDtempreg,#06h
                        call LCDcmd
                        mov LCDtempreg,#01h
                        call LCDcmd
                        ret
;========================================================================
LCDcmd:					mov Reg_LCD_swap1,LCDtempreg
						
						mov Reg_LCD_swap2,Reg_LCD_swap1
						
						mov a,Reg_LCD_swap2
						anl a,#0F0H
						mov LCDdatabus,a
						
						clr LCDrs
						setb LCDen
						nop
						nop
						clr LCDen
						call LCDdelay
						
						mov a,Reg_LCD_swap2
						swap a
						anl a,#0F0H
						mov LCDdatabus,a
						
						clr LCDrs
						setb LCDen
						nop
						nop
						clr LCDen
						call LCDdelay						
						ret               
;========================================================================
LCDdata:        		mov Reg_LCD_swap1,LCDtempreg
						mov Reg_LCD_swap2,Reg_LCD_swap1
						
						mov a,Reg_LCD_swap2
						anl a,#0F0H
						mov LCDdatabus,a
						
						setb LCDrs
						setb LCDen
						nop
						nop
						clr LCDen
						call LCDdelay
						
						mov a,Reg_LCD_swap2
						swap a
						anl a,#0F0H
						mov LCDdatabus,a
						
						setb LCDrs
						setb LCDen
						nop
						nop
						clr LCDen
						call LCDdelay						
						ret
;========================================================================
delayhalf:      		mov delreg1,#05
delayhalf1:     		mov delreg2,#200
delayhalf2:     		mov delreg3,#250
						djnz delreg3,$
						djnz delreg2,delayhalf2
						djnz delreg1,delayhalf1
						ret          
;===========================================================================
LCDdatainit:    		mov Reg_LCD_swap1,LCDtempreg
						mov Reg_LCD_swap2,Reg_LCD_swap1
						
						mov a,Reg_LCD_swap2
						anl a,#0F0H
						mov LCDdatabus,a
						
						setb LCDrs
						setb LCDen
						nop
						nop
						clr LCDen
						call LCDdelayinit
						
						mov a,Reg_LCD_swap2
						swap a
						anl a,#0F0H
						mov LCDdatabus,a
						
						setb LCDrs
						setb LCDen
						nop
						nop
						clr LCDen
						call LCDdelayinit
						
						ret
;========================================================================
LCDdelay:              	mov Delreg1,#10             ;LCD
LCDdelay1:              mov Delreg2,#250
                        djnz Delreg2,$
                        djnz Delreg1,LCDdelay1
                        ret
;=========================================================
LCDdelayinit:           mov Delreg1,#100             ;LCD
LCDdelayinit1:          mov Delreg2,#250
                        djnz Delreg2,$
                        djnz Delreg1,LCDdelayinit1
                        ret
;=========================================================
display_dot_01:         
						mov LCDtempreg,#'.'
                        call LCDdata
                        ret
;=========================================================
debounce:               mov Delreg1,#10             ;Keypad
debounce1:              mov Delreg2,#250
                        djnz Delreg2,$
                        djnz Delreg1,debounce1
                        ret   
;=========================================================
delayhalfsec:           mov Delreg1,#5
delhalf2:               mov Delreg2,#200
delhalf1:               mov Delreg3,#250
                        djnz Delreg3,$
                        djnz Delreg2,delhalf1
                        djnz Delreg1,delhalf2
                        ret
;=========================================================
delay1sec:               mov Delreg1,#10
del1sec2:                mov Delreg2,#200
del1sec1:                mov Delreg3,#250
                        djnz Delreg3,$
                        djnz Delreg2,del1sec1
                        djnz Delreg1,del1sec2
                        ret
;=========================================================
delay2sec:              call delay1sec
                        call delay1sec
                        ret
;=========================================================
delay3sec:              call delay1sec
                        call delay1sec
                        call delay1sec
                        ret
;=========================================================
LCDdisp:                mov LCDtempreg,#01h
                        call LCDcmd
                        mov LCDreg,#00h
LCDdisp2:                mov a,LCDreg
                        movc a,@a+dptr
                        cjne a,#'@',LCDdisp1
                        mov LCDtempreg,#0C0h
                        call LCDcmd
                        inc LCDreg
                        jmp LCDdisp2
LCDdisp1:                cjne a,#'$',LCDdisp3
                        ret
LCDdisp3:                mov LCDtempreg,a
                        call LCDdata
                        inc LCDreg
                        jmp LCDdisp2
;=======================================================================
LCDdispinit:        	mov LCDtempreg,#01h
                		call LCDcmd
               		 	mov LCDreg,#00h
LCDdispinit2:        	mov a,LCDreg
						movc a,@a+dptr
						cjne a,#'@',LCDdispinit1
						mov LCDtempreg,#0C0h
						call LCDcmd
						inc LCDreg
						jmp LCDdispinit2
LCDdispinit1:        	cjne a,#'$',LCDdispinit3
                		ret
LCDdispinit3:        	mov LCDtempreg,a
						call LCDdatainit
						inc LCDreg
						jmp LCDdispinit2
;=======================================================================
;       PC INTERFACING 
;=======================================================================
SMS_PC_int:             mov LCDreg,#00h
SMS_PC_int2:            mov a,LCDreg
                        movc a,@a+dptr
                        cjne a,#'$',SMS_PC_int3
                        ret
SMS_PC_int3:            mov sbuf,a
                        jnb ti,$
                        clr ti
                        inc LCDreg
                        jmp SMS_PC_int2
;=========================================================================
Send_Sms_snsr_cmn:      
           				call dptrsmscommon       					 
                        call SMS_PC_int
        				ret
;=========================================================================
dptrsmscommon:			mov a,Reg_sensor_no
						cjne a,#01H,dptrsmscommon_2
						mov dptr,#Final_txt_to_pcS1
                        ret
dptrsmscommon_2:		cjne a,#02H,dptrsmscommon_3
						mov dptr,#Final_txt_to_pcS2
                        ret
dptrsmscommon_3:		cjne a,#03H,dptrsmscommon_4
						mov dptr,#Final_txt_to_pcS3
                        ret
dptrsmscommon_4:		cjne a,#04H,dptrsmscommon_5
						mov dptr,#Final_txt_to_pcS4
                        ret
dptrsmscommon_5:		cjne a,#05H,dptrsmscommon_err
						mov dptr,#Final_txt_to_pcS5
                        ret
dptrsmscommon_err:		ret
;=========================================================
keypad_routine_ret:   ret
keypad_routine:  
                call keypad_high

;                clr Col1

                clr Col1

                jb Row4,keypad_routine_ret
                call debounce
                jb Row4,keypad_routine_ret

                mov dptr,#Msg_entpassword
                call LCDdisp

                jnb Row4,$

back_esc:       mov dptr,#Msg_entpassword
                call LCDdisp

                mov LCDtempreg,#0C0H
                call LCDcmd

                mov r0,#40h

                mov 40h,#0FFH
                mov 41H,#0FFH
                mov 42H,#0FFH
                mov 43H,#0FFH
                mov 44H,#0FFH
                mov 45H,#0FFH
                mov 46H,#0FFH

loop:
                call keypad_high

                clr Row1

                jb Col1,chkkey2
                call debounce
                jb Col1,chkkey2
                jnb Col1,$
                mov r0,#01h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

chkkey2:         jb Col2,chkkey3
                call debounce
                jb Col2,chkkey3
                jnb Col2,$
                mov r0,#02h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

chkkey3:         jb Col3,chkkey4
                call debounce
                jb Col3,chkkey4
                jnb Col3,$
                mov r0,#03h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

chkkey4:
                call keypad_high

                clr Row2

                jb Col1,chkkey5
                call debounce
                jb Col1,chkkey5
                jnb Col1,$
                mov r0,#04h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata


chkkey5:         jb Col2,chkkey6
                call debounce
                jb Col2,chkkey6
                jnb Col2,$
                mov r0,#05h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                                              
chkkey6:         jb Col3,chkkey7
                call debounce
                jb Col3,chkkey7
                jnb Col3,$
                mov r0,#06h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

chkkey7:
                call keypad_high

                clr Row3

                jb Col1,chkkey8 
                call debounce
                jb Col1,chkkey8 
                jnb Col1,$
                mov r0,#07h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

chkkey8:         jb Col2,chkkey9
                call debounce
                jb Col2,chkkey9 
                jnb Col2,$
                mov r0,#08h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                                              
chkkey9:         jb Col3,chkkey10
                call debounce
                jb Col3,chkkey10
                jnb Col3,$
                mov r0,#09h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

chkkey10:
                call keypad_high

                clr Row4

                jb Col2,chkkey11
                call debounce
                jb Col2,chkkey11
                jnb Col2,$
                mov r0,#00h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

chkkey11:        jb Col3,chkkey12
                call debounce
                jb Col3,chkkey12
                jnb Col3,$

                call clear_key_LCD_disp
                jmp back_esc
                                              
chkkey12:        jb Col1,chkkeyend
                call debounce
                jb Col1,chkkeyend
                mov dptr,#Msg_plzwait
                call LCDdisp
                call display_dot_02

                jnb Col1,$

                		call check_pw_one
                		jnb Bit_01H,pwd_two
                		jmp correct_pw

pwd_two:        		call check_pw_two
                		jnb Bit_01H,pwd_master
                		jmp correct_pw

pwd_master:     		call check_pw_master
		                jnb Bit_01H,ERROR
		                jmp correct_pw
        
chkkeyend:       		jmp loop

correct_pw:				
						clr 05H


		                call DC_motor		
		                call delay2sec
		                call delay2sec
                		call DC_motor_reverse
		

		
		                jmp Status_Proceed

Status_Proceed:			call delay2sec

						mov dptr,#msgwelcome
						call LCDdisp
						call delay2sec
						call LCD_Disp_Off
						
						mov 40h,#0FFH
						mov 41H,#0FFH
						mov 42H,#0FFH
						mov 43H,#0FFH
						mov 44H,#0FFH
						mov 45H,#0FFH
						mov 46H,#0FFH
						ret

ERROR:					
						setb buzzer
						setb Relay

		                mov dptr,#Msg_wrongpass
		                call LCDdisp
						call Send_dt_to_PCwrongpwd
						call delay2sec

		                mov dptr,#msgwelcome
		                call LCDdisp
		                clr buzzer
						clr Relay
		
		                mov 40h,#0FFH
		                mov 41H,#0FFH
		                mov 42H,#0FFH
		                mov 43H,#0FFH
		                mov 44H,#0FFH
		                mov 45H,#0FFH
		                mov 46H,#0FFH

		                ret
;==========================================================
read_pwd_eeprom:


                mov memory_address,#01H
                call read_data
                mov 30H,eeprom_read_data

                
                mov memory_address,#02H
                call read_data
                mov 31H,eeprom_read_data

                
                mov memory_address,#03H
                call read_data
                mov 32H,eeprom_read_data

                
                mov memory_address,#04H
                call read_data
                mov 33H,eeprom_read_data

                
                mov memory_address,#05H
                call read_data
                mov 34H,eeprom_read_data

                
                mov memory_address,#06H
                call read_data
                mov 35H,eeprom_read_data

                mov 36h,#0FFH
                ret
;==========================================================
read_pwd_eeprom_two:
;  mov 30h,#01   ;  mov 31h,#04   ;  mov 32h,#07
;  mov 33h,#03   ;  mov 34h,#06   ;  mov 35h,#09    ;  mov 36h,#0FFH

                
                mov memory_address,#11H
                call read_data
                mov 30H,eeprom_read_data

                
                mov memory_address,#12H
                call read_data
                mov 31H,eeprom_read_data

                
                mov memory_address,#13H
                call read_data
                mov 32H,eeprom_read_data

                
                mov memory_address,#14H
                call read_data
                mov 33H,eeprom_read_data

                
                mov memory_address,#15H
                call read_data
                mov 34H,eeprom_read_data

                
                mov memory_address,#16H
                call read_data
                mov 35H,eeprom_read_data

                mov 36h,#0FFH
                ret
;==========================================================
write_pwd_eeprom:
;  mov 30h,60H  ;  mov 31h,61H  ;  mov 32h,62H  ;  mov 33h,63H
;  mov 34h,64H  ;  mov 35h,65H  ;  mov 36h,#0FFH

                
                mov memory_address,#01H
                mov eeprom_data,60H
                call write_data
                call delhalf

                
                mov memory_address,#02H
                mov eeprom_data,61H
                call write_data
                call delhalf

                
                mov memory_address,#03H
                mov eeprom_data,62H
                call write_data
                call delhalf

                
                mov memory_address,#04H
                mov eeprom_data,63H
                call write_data
                call delhalf

                
                mov memory_address,#05H
                mov eeprom_data,64H
                call write_data
                call delhalf

                
                mov memory_address,#06H
                mov eeprom_data,65H
                call write_data
                call delhalf

                mov 36h,#0FFH

                mov dptr,#Msg_pwdchged_one
                call LCDdisp
                call delay2sec
                ret
;==========================================================
write_pwd_eeprom_two:
;  mov 30h,60H  ;  mov 31h,61H  ;  mov 32h,62H  ;  mov 33h,63H
;  mov 34h,64H  ;  mov 35h,65H  ;  mov 36h,#0FFH

                
                mov memory_address,#11H
                mov eeprom_data,60H
                call write_data
                call delhalf

                
                mov memory_address,#12H
                mov eeprom_data,61H
                call write_data
                call delhalf

                
                mov memory_address,#13H
                mov eeprom_data,62H
                call write_data
                call delhalf

                
                mov memory_address,#14H
                mov eeprom_data,63H
                call write_data
                call delhalf

                
                mov memory_address,#15H
                mov eeprom_data,64H
                call write_data
                call delhalf

                
                mov memory_address,#16H
                mov eeprom_data,65H
                call write_data
                call delhalf

                mov 36h,#0FFH
                mov dptr,#Msg_pwdchged_two
                call LCDdisp
                call delay2sec
                ret
;==========================================================
check_pw_one:
                call read_pwd_eeprom

                MOV A,40h               ;Pwd 1=147369
                CJNE A,30H,error_one
                MOV A,41H
                CJNE A,31H,error_one   
                MOV A,42H
                CJNE A,32H,error_one
                MOV A,43H
                CJNE A,33H,error_one
                MOV A,44H
                CJNE A,34H,error_one
                MOV A,45H
                CJNE A,35H,error_one
                MOV A,46H
                CJNE A,36H,error_one
                setb Bit_01H                ;set bit if correct pwd

                mov dptr,#Msg_correctpass1
                call LCDdisp

                ret
error_one:       clr Bit_01H                 ;clr bit if wrong pwd
                ret
;==========================================================
check_pw_two:
                call read_pwd_eeprom_two

                MOV A,40h               ;Pwd 1=147369
                CJNE A,30H,error_two
                MOV A,41H
                CJNE A,31H,error_two   
                MOV A,42H
                CJNE A,32H,error_two
                MOV A,43H
                CJNE A,33H,error_two
                MOV A,44H
                CJNE A,34H,error_two
                MOV A,45H
                CJNE A,35H,error_two
                MOV A,46H
                CJNE A,36H,error_two
                setb Bit_01H                ;set bit if correct pwd

                mov dptr,#Msg_correctpass2
                call LCDdisp

                ret
error_two:       clr Bit_01H                 ;clr bit if wrong pwd
                ret
;==========================================================
check_pw_master:    MOV A,40H               ;Pwd 2=147369
                CJNE A,#05,error_two_m
                MOV A,41H
                CJNE A,#03,error_two_m   
                MOV A,42H
                CJNE A,#01,error_two_m
                MOV A,43H
                CJNE A,#09,error_two_m
                MOV A,44H
                CJNE A,#08,error_two_m
                MOV A,45H
                CJNE A,#03,error_two_m
                MOV A,46H
                CJNE A,#0FFH,error_two_m
                setb Bit_01H                ;set bit if correct pwd

                mov dptr,#Msg_correctpassm
                call LCDdisp

                ret
error_two_m:       clr Bit_01H                 ;clr bit if correct pwd
                ret
;==========================================================
display_dot_02:    mov LCDtempreg,#8bh
                call LCDcmd

                mov Reggsmdot,#08h

display_dot_loop:
                call delaywait
                mov LCDtempreg,#'.'
                call LCDdata
                djnz Reggsmdot,display_dot_loop

                call delaywait
                ret
;==========================================================
display_dot_1:  
                mov LCDtempreg,#'.'
                call LCDdata
                ret
;==========================================================
clear_key_LCD_disp:
                mov R2,#0CFH
clr_key_LCDdisp1:
                mov LCDtempreg,R2
                call LCDcmd
                mov LCDtempreg,#' '
                call LCDdata
                call delay100ms
                dec R2
                cjne R2,#0BFH,clr_key_LCDdisp1

                ret
;==========================================================
keypad_high:
                setb Col1
                setb Col2
                setb Col3
;                setb Col4
                setb Row1
                setb Row2
                setb Row3
                setb Row4
                ret
;=========================================================
;==========================================================

chg_pwd_ret:
;                setb Col4
                ret
change_password:
                call keypad_high
;                setb Row4


                clr Col3
                jb Row4,chg_pwd_ret
                call debounce
                jb Row4,chg_pwd_ret

                mov dptr,#Msg_ModChngPwd
                call LCDdisp

                jnb Row4,$

                call delay2sec


Old_Pwd_back_esc:
                mov dptr,#Msg_entoldpwd
                call LCDdisp

                mov LCDtempreg,#0C0H
                call LCDcmd

                mov r0,#40h

                mov 40h,#0FFH
                mov 41h,#0FFH
                mov 42h,#0FFH
                mov 43h,#0FFH
                mov 44h,#0FFH
                mov 45h,#0FFH
                mov 46h,#0FFH

Old_Pwd_loop:   mov keypad,#0FFH
                clr Row1

                jb Col1,Old_Pwd_chkkey2
                call debounce
                jb Col1,Old_Pwd_chkkey2
                jnb Col1,$
                mov r0,#01h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

Old_Pwd_chkkey2:         jb Col2,Old_Pwd_chkkey3
                call debounce
                jb Col2,Old_Pwd_chkkey3
                jnb Col2,$
                mov r0,#02h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

Old_Pwd_chkkey3:         jb Col3,Old_Pwd_chkkey4
                call debounce
                jb Col3,Old_Pwd_chkkey4
                jnb Col3,$
                mov r0,#03h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

Old_Pwd_chkkey4:         mov keypad,#0FFH
                clr Row2

                jb Col1,Old_Pwd_chkkey5
                call debounce
                jb Col1,Old_Pwd_chkkey5
                jnb Col1,$
                mov r0,#04h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

Old_Pwd_chkkey5:         jb Col2,Old_Pwd_chkkey6
                call debounce
                jb Col2,Old_Pwd_chkkey6
                jnb Col2,$
                mov r0,#05h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                                              
Old_Pwd_chkkey6:         jb Col3,Old_Pwd_chkkey7
                call debounce
                jb Col3,Old_Pwd_chkkey7
                jnb Col3,$
                mov r0,#06h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

Old_Pwd_chkkey7:         mov keypad,#0FFH
                clr Row3

                jb Col1,Old_Pwd_chkkey8 
                call debounce
                jb Col1,Old_Pwd_chkkey8 
                jnb Col1,$
                mov r0,#07h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

Old_Pwd_chkkey8:         jb Col2,Old_Pwd_chkkey9
                call debounce
                jb Col2,Old_Pwd_chkkey9 
                jnb Col2,$
                mov r0,#08h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                                              
Old_Pwd_chkkey9:         jb Col3,Old_Pwd_chkkey10
                call debounce
                jb Col3,Old_Pwd_chkkey10
                jnb Col3,$
                mov r0,#09h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

Old_Pwd_chkkey10:
                mov keypad,#0FFH
                clr Row4

                jb Col2,Old_Pwd_chkkey11
                call debounce
                jb Col2,Old_Pwd_chkkey11
                jnb Col2,$
                mov r0,#00h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata

Old_Pwd_chkkey11:        jb Col3,Old_Pwd_chkkey12
                call debounce
                jb Col3,Old_Pwd_chkkey12
                jnb Col3,$
                jmp Old_Pwd_back_esc
                                              
Old_Pwd_chkkey12:        jb Col1,Old_Pwd_chkkeyend
                call debounce
                jb Col1,Old_Pwd_chkkeyend
                mov dptr,#Msg_plzwait
                call LCDdisp
                call display_dot_02

                jnb Col1,$

                clr 07H
                call Chng_with_master_one

                jb 07H,skip_chng_with_master
                call Chng_with_master_two

skip_chng_with_two:
                jb 07H,skip_chng_with_master
                call Chng_with_master

skip_chng_with_master:

               MOV A,R5
               CJNE A,#11H,Chk_if_22H
               jmp Chng_Pwdback_esc

Chk_if_22H:
               MOV A,R5
               CJNE A,#22H,Chk_if_M
               jmp Chng_Pwdback_esc

Chk_if_M:
               MOV A,R5
               CJNE A,#'M',Old_Pwd_wrong
               jmp Chng_Pwdback_esc

Old_Pwd_wrong:

                mov dptr,#Msg_oldpwdwrong
                call LCDdisp
                call delay2sec

                mov dptr,#msgwelcome
                call LCDdisp
                call delay2sec
                call LCD_Disp_Off

;                setb Col4
                ret

Old_Pwd_chkkeyend:  jmp Old_Pwd_loop
;============================================================
Chng_Pwdback_esc:     mov dptr,#Msg_entnewpwd
                call LCDdisp

                mov LCDtempreg,#0C0H
                call LCDcmd

                mov r0,#60h

Chng_Pwdloop:        mov keypad,#0FFH
                clr Row1

                jb Col1,Chng_Pwdchkkey2
                call debounce
                jb Col1,Chng_Pwdchkkey2
                jnb Col1,$
                mov r0,#01h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend

Chng_Pwdchkkey2:      jb Col2,Chng_Pwdchkkey3
                call debounce
                jb Col2,Chng_Pwdchkkey3
                jnb Col2,$
                mov r0,#02h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend

Chng_Pwdchkkey3:         jb Col3,Chng_Pwdchkkey4
                call debounce
                jb Col3,Chng_Pwdchkkey4
                jnb Col3,$
                mov r0,#03h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend

Chng_Pwdchkkey4:         mov keypad,#0FFH
                clr Row2

                jb Col1,Chng_Pwdchkkey5
                call debounce
                jb Col1,Chng_Pwdchkkey5
                jnb Col1,$
                mov r0,#04h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend

Chng_Pwdchkkey5:         jb Col2,Chng_Pwdchkkey6
                call debounce
                jb Col2,Chng_Pwdchkkey6
                jnb Col2,$
                mov r0,#05h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend
                                              
Chng_Pwdchkkey6:      jb Col3,Chng_Pwdchkkey7
                call debounce
                jb Col3,Chng_Pwdchkkey7
                jnb Col3,$
                mov r0,#06h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend

Chng_Pwdchkkey7:      mov keypad,#0FFH
                clr Row3

                jb Col1,Chng_Pwdchkkey8 
                call debounce
                jb Col1,Chng_Pwdchkkey8 
                jnb Col1,$
                mov r0,#07h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend

Chng_Pwdchkkey8:         jb Col2,Chng_Pwdchkkey9
                call debounce
                jb Col2,Chng_Pwdchkkey9 
                jnb Col2,$
                mov r0,#08h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend
                                              
Chng_Pwdchkkey9:         jb Col3,Chng_Pwdchkkey10
                call debounce
                jb Col3,Chng_Pwdchkkey10
                jnb Col3,$
                mov r0,#09h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend

Chng_Pwdchkkey10:     mov keypad,#0FFH
                clr Row4

                jb Col2,Chng_Pwdchkkey11
                call debounce
                jb Col2,Chng_Pwdchkkey11
                jnb Col2,$
                mov r0,#00h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_Pwdcmpend

Chng_Pwdchkkey11:        jb Col3,Chng_Pwdloop111
                call debounce
                jb Col3,Chng_Pwdloop111
                jnb Col3,$
                jmp Chng_Pwdback_esc

Chng_Pwdcmpend:       mov a,r0
                cjne a,#66h,Chng_Pwdloop111


                call enter_new_pwd_again
                call compare_both_new_pwd

                jnb 06,both_new_pwd_mismatch

                call delay1sec
                mov dptr,#Msg_plzwait
                call LCDdisp
                call display_dot_02

                mov a,R5
                cjne a,#'M',chng_old_not_master
                call confirm_which_pwd

chng_old_not_master:
                mov a,R5
                cjne a,#11H,chk_chng_two
                call write_pwd_eeprom
                jmp change_done

chk_chng_two:
                mov a,R5
                cjne a,#22H,chk_chng_error
                call write_pwd_eeprom_two
                jmp change_done

chk_chng_error:
                mov dptr,#Msg_pwdchngerror
                call LCDdisp
                call delay2sec
                jmp change_not_done
                
change_done:

;                mov dptr,#Msg_pwdchged
;                call LCDdisp
;                call delay2sec

change_not_done:
                mov dptr,#msgwelcome
                call LCDdisp
                call delay2sec
                call LCD_Disp_Off
;                setb Col4
                ret
Chng_Pwdloop111:      jmp Chng_Pwdloop

both_new_pwd_mismatch:
                mov dptr,#Msg_newpwdmismatch
                call LCDdisp
                call delay2sec

                mov dptr,#Msg_pwd_unchanged
                call LCDdisp
                call delay2sec

                mov dptr,#msgwelcome
                call LCDdisp
                call delay2sec
                call LCD_Disp_Off
;                setb Col4
                ret
;=========================================================================
Chng_with_master_one:
               call read_pwd_eeprom

               MOV A,40H
               CJNE A,30h,Old_Pwd_error
               MOV A,41H
               CJNE A,31h,Old_Pwd_error
               MOV A,42H
               CJNE A,32h,Old_Pwd_error
               MOV A,43H
               CJNE A,33h,Old_Pwd_error
               MOV A,44H
               CJNE A,34h,Old_Pwd_error
               MOV A,45H
               CJNE A,35h,Old_Pwd_error
               MOV A,46H
               CJNE A,36h,Old_Pwd_error
               mov R5,#11H
               setb 07H
               ret

Old_Pwd_error:  mov R5,#00H
                ret
;============================================================
Chng_with_master_two:
               call read_pwd_eeprom_two

               MOV A,40H
               CJNE A,30h,Old_Pwd_error_two_m
               MOV A,41H
               CJNE A,31h,Old_Pwd_error_two_m
               MOV A,42H
               CJNE A,32h,Old_Pwd_error_two_m
               MOV A,43H
               CJNE A,33h,Old_Pwd_error_two_m
               MOV A,44H
               CJNE A,34h,Old_Pwd_error_two_m
               MOV A,45H
               CJNE A,35h,Old_Pwd_error_two_m
               MOV A,46H
               CJNE A,36h,Old_Pwd_error_two_m
               mov R5,#22H
               setb 07H
               ret

Old_Pwd_error_two_m:  mov R5,#00H
                ret
;============================================================
Chng_with_master:
               MOV A,40H
               CJNE A,#05H,Old_Pwd_error_master
               MOV A,41H
               CJNE A,#03H,Old_Pwd_error_master
               MOV A,42H
               CJNE A,#01H,Old_Pwd_error_master
               MOV A,43H
               CJNE A,#09H,Old_Pwd_error_master
               MOV A,44H
               CJNE A,#08H,Old_Pwd_error_master
               MOV A,45H
               CJNE A,#03H,Old_Pwd_error_master
               MOV A,46H
               CJNE A,#0FFH,Old_Pwd_error_master
               mov R5,#'M'
               setb 07H
               ret

Old_Pwd_error_master:  mov R5,#00H
                ret
;============================================================
enter_new_pwd_again:
Chng_pwd_2_back_esc:
                mov dptr,#Msg_entnewpwdagain
                call LCDdisp

                mov LCDtempreg,#0C0H
                call LCDcmd

                mov r0,#68h

Chng_pwd_2_loop:        mov keypad,#0FFH
                clr Row1

                jb Col1,Chng_pwd_2_chkkey2
                call debounce
                jb Col1,Chng_pwd_2_chkkey2
                jnb Col1,$
                mov r0,#01h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend

Chng_pwd_2_chkkey2:      jb Col2,Chng_pwd_2_chkkey3
                call debounce
                jb Col2,Chng_pwd_2_chkkey3
                jnb Col2,$
                mov r0,#02h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend

Chng_pwd_2_chkkey3:         jb Col3,Chng_pwd_2_chkkey4
                call debounce
                jb Col3,Chng_pwd_2_chkkey4
                jnb Col3,$
                mov r0,#03h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend

Chng_pwd_2_chkkey4:         mov keypad,#0FFH
                clr Row2

                jb Col1,Chng_pwd_2_chkkey5
                call debounce
                jb Col1,Chng_pwd_2_chkkey5
                jnb Col1,$
                mov r0,#04h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend

Chng_pwd_2_chkkey5:         jb Col2,Chng_pwd_2_chkkey6
                call debounce
                jb Col2,Chng_pwd_2_chkkey6
                jnb Col2,$
                mov r0,#05h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend
                                              
Chng_pwd_2_chkkey6:      jb Col3,Chng_pwd_2_chkkey7
                call debounce
                jb Col3,Chng_pwd_2_chkkey7
                jnb Col3,$
                mov r0,#06h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend

Chng_pwd_2_chkkey7:      mov keypad,#0FFH
                clr Row3

                jb Col1,Chng_pwd_2_chkkey8 
                call debounce
                jb Col1,Chng_pwd_2_chkkey8 
                jnb Col1,$
                mov r0,#07h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend

Chng_pwd_2_chkkey8:         jb Col2,Chng_pwd_2_chkkey9
                call debounce
                jb Col2,Chng_pwd_2_chkkey9 
                jnb Col2,$
                mov r0,#08h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend
                                              
Chng_pwd_2_chkkey9:         jb Col3,Chng_pwd_2_chkkey10
                call debounce
                jb Col3,Chng_pwd_2_chkkey10
                jnb Col3,$
                mov r0,#09h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend

Chng_pwd_2_chkkey10:     mov keypad,#0FFH
                clr Row4

                jb Col2,Chng_pwd_2_chkkey11
                call debounce
                jb Col2,Chng_pwd_2_chkkey11
                jnb Col2,$
                mov r0,#00h
                inc r0
                mov LCDtempreg,#'*'
                call LCDdata
                jmp Chng_pwd_2_cmpend

Chng_pwd_2_chkkey11:        jb Col3,Chng_pwd_2_loop111
                call debounce
                jb Col3,Chng_pwd_2_loop111
                jnb Col3,$
                jmp Chng_pwd_2_back_esc

Chng_pwd_2_cmpend:       mov a,r0
                cjne a,#6Eh,Chng_pwd_2_loop111
                ret
Chng_pwd_2_loop111:      jmp Chng_pwd_2_loop
;=========================================================================
compare_both_new_pwd:
                clr 06H

                MOV A,60h         
                CJNE A,68H,compare_both_new_pwd_err
                MOV A,61H
                CJNE A,69H,compare_both_new_pwd_err
                MOV A,62H
                CJNE A,6AH,compare_both_new_pwd_err
                MOV A,63H
                CJNE A,6BH,compare_both_new_pwd_err
                MOV A,64H
                CJNE A,6CH,compare_both_new_pwd_err
                MOV A,65H
                CJNE A,6DH,compare_both_new_pwd_err
                setb 06H
                ret

compare_both_new_pwd_err:
                clr 06H
                ret
;=========================================================================
write_data:     call eeprom_start
                mov a,#0A0H          
                call send_data
                mov a,memory_address           ;location address
                call send_data
                mov a,eeprom_data               ;data to be send
                call send_data
                call eeprom_stop
                ret   
;=========================================================================
read_data:      call eeprom_start
                mov a,#0A0H
                call send_data
                mov a,memory_address           ;location address
                call send_data
                call eeprom_start
                mov a,#0A0H
                call send_data
                call get_data
                call eeprom_stop
                ret
;=========================================================================
eeprom_start:    setb eeprom_sda
                nop
                setb eeprom_scl
                nop
                nop
                clr eeprom_sda
                nop
                clr eeprom_scl
                ret
;=========================================================================
eeprom_stop:     clr eeprom_sda
                nop
                setb eeprom_scl
                nop
                nop
                setb eeprom_sda
                nop
                clr eeprom_scl
                ret
;=========================================================================
send_data:      mov r7,#00h
send:           
               mov eeprom_sda,c
               call clock
               inc r7
               cjne r7,#08,send
               setb eeprom_sda
               jb eeprom_sda,$
             ; call eeprom_delay
               call clock
               ret
;=========================================================================
get_data:      mov r7,#00h
               setb eeprom_sda
get_data1:     mov c,eeprom_sda
               call clock
               
               inc r7
               cjne r7,#08,get_data1
               setb eeprom_sda
               call clock
               mov eeprom_read_data,a
               ret
;=========================================================================
clock:           setb eeprom_scl
                nop
                nop
                clr eeprom_scl
                ret
;=========================================================================
DC_motor:
                setb Motor2_1
                clr Motor2_2

				call Send_dt_to_PCcorrectpwd
                call delay2sec

                clr Motor2_1
                clr Motor2_2
                ret
;=========================================================================
DC_motor_reverse:
                clr Motor2_1
                setb Motor2_2

                call delay2sec
                call delay2sec

                clr Motor2_1
                clr Motor2_2
                ret
;=========================================================================
confirm_which_pwd:
                mov dptr,#Msg_sel_pwd_change
                call LCDdisp
                call keypad_high
                clr Row1

Chng_m_pwd_chkkey1:
                jb Col1,Chng_m_pwd_chkkey2
                call debounce
                jb Col1,Chng_m_pwd_chkkey2
                jnb Col1,$
                mov LCDtempreg,#0CFH
                call LCDcmd
                mov LCDtempreg,#'1'
                call LCDdata
                call delay1sec
                mov R5,#11H
                ret

Chng_m_pwd_chkkey2:
                jb Col2,Chng_m_pwd_chkkey1
                call debounce
                jb Col2,Chng_m_pwd_chkkey1
                jnb Col2,$
                mov LCDtempreg,#0CFH
                call LCDcmd
                mov LCDtempreg,#'2'
                call LCDdata
                call delay1sec
                mov R5,#22H
                ret
;====================================================================
delayMotor:       mov delreg1,#2
delayMotor2:        mov delreg2,#50
delayMotor1:        mov delreg3,#250
                djnz delreg3,$
                djnz delreg2,delayMotor1
                djnz delreg1,delayMotor2
                ret
;==========================================================
delhalf:
                call delaywait
                call delaywait
                call delaywait
                call delaywait
                ret
;=========================================================
delaywait:       mov delreg1,#1
delaywait1:      mov delreg2,#50
delaywait2:      mov delreg3,#250
                djnz delreg3,$
                djnz delreg2,delaywait2
                djnz delreg1,delaywait1
                ret
;==========================================================
delay100ms:       mov delreg1,#1
delay100ms1:      mov delreg2,#50
delay100ms2:      mov delreg3,#250
                djnz delreg3,$
                djnz delreg2,delay100ms2
                djnz delreg1,delay100ms1
                ret
;==========================================================
LCD_Disp_Off:
                ret
;==========================================================
Send_dt_to_PCwrongpwd:		mov dptr,#Finalsmswrongpwd
                        call SMS_PC_int
                        ret
;=========================================================
Send_dt_to_PCcorrectpwd:		mov dptr,#Finalsmscorrectpwd
                        call SMS_PC_int
                        ret

msgwelcome:             DB "HOME AUTOMATION@&SECURITY SYSTEM"
msggsminit:             DB "Intialising Plz @wait        "
msgSensor11:             DB "TEMP. SENSOR    @INPUT DETECTED  "
msgSensor21:             DB "LPG SENSOR     @INPUT DETECTED   "
msgSensor41:             DB "INFRARED SENSOR @INPUT DETECTED   "
Final_txt_to_pcS1:			DB "ALERT: Temperature Sensor has crossed threshold value. Please take immediate action."
Final_txt_to_pcS2:			DB "ALERT: LPG Sensor has crossed threshold value. Please take immediate action."
Final_txt_to_pcS4:			DB "ALERT: Infrared Sensor has crossed threshold value. Please take immediate action."
Finalsmscorrectpwd:		DB "Correct password entered. Door opened."
Finalsmswrongpwd:		DB "ALERT: Wrong password has been entered."


Msg_entpassword:        db "ENTER PASSWORD: @                "

Msg_correctpass1:       db "   PASSWORD    1@     CORRECT    "
Msg_correctpass2:       db "   PASSWORD    2@     CORRECT    "
Msg_correctpassm:       db "   PASSWORD    M@     CORRECT    "
Msg_wrongpass:          db "WRONG PASSWORD  @PLEASE ENT AGAIN"
Msg_plzwait:            db "PLEASE WAIT     @                "
Msg_entoldpwd:          db "ENTER OLD PWD.  @                "
Msg_oldpwdwrong:        db "OLD PASSWORD    @IS WRONG....    "
Msg_entnewpwd:          db "ENTER NEW PWD   @                "
Msg_pwdchged:           db "PASSWORD CHANGED@SUCCESSFULLY    "
Msg_pwdchged_one:       db "PASSWORD CHANGED@SUCCESSFULLY  1 "
Msg_pwdchged_two:       db "PASSWORD CHANGED@SUCCESSFULLY  2 "
Msg_ModChngPwd:         db "YOU SELECTED    @CHANGE PASSWORD "

Msg_entnewpwdagain:      db "ENTER PWD AGAIN:@                "
Msg_newpwdmismatch:      db "NEW PASSWORD    @MISMATCH        "
Msg_pwd_unchanged:       db "PASSWORD NOT    @CHANGED TRYAGAIN"
Msg_sel_pwd_change:      db "CHANGE 1 OR 2 ? @PRESS KEY       "
Msg_pwdchngerror:        db "ERROR WHILE     @CHANGE PASSWORD "
Msg_DeviceOn:			DB "DEVICE           @TURNED ON       "
Msg_DeviceOFF:			DB "DEVICE           @   TURNED  OFF   "

                        END

