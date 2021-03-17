;************************************************************
;       Técnicas Digitales II - Trabajo Práctico N1
;       Actividad Ib: Lectura/Escritura de puertos
;       FERRER, Ezequiel
;************************************************************
; Requiere (simulacion):
;   - Panel de interruptores (8) desde puerto 0Ah
;   - Panel de LEDs (8) desde puerto A0h

;************************************************************
;	Definición de Etiquetas
;************************************************************
.define
	BootAddr		0000h
	StackAddr		FFFFh

;************************************************************
;	Sector de Arranque del 8085
;************************************************************
.org	BootAddr
    JMP	Boot

;************************************************************
;	Sector del Programa Principal
;************************************************************
Boot:
	LXI	SP, StackAddr
	
Main:
    MVI C, 08h      ; contador para invertir
    
    IN  0Ah
    CALL Invert
    OUT A0h
    
    IN  0Bh
    CALL Invert
    OUT A1h
    
    IN  0Ch
    CALL Invert
    OUT A2h
    
    IN  0Dh
    CALL Invert
    OUT A3h
    
    IN  0Eh
    CALL Invert
    OUT A4h
    
    IN  0Fh
    CALL Invert
    OUT A5h
    
    IN  10h
    CALL Invert
    OUT A6h
    
    IN  11h
    CALL Invert
    OUT A7h

    JMP Main
	HLT
    
Invert:    
    RRC         ; coloco LS bit en CY 
    MOV E, A    ; cambio
    MOV A, D    ; A por D
    MOV D, E    ; sin perder sus datos | A:invertido D:original
    RAL         ; "encolo" CY
    MOV E, A    ; cambio
    MOV A, D    ; A por D
    MOV D, E    ; sin perder sus datos | A:original D:invertido
    
    DCR C       ; decremento contador x8bits | unica operacion que altera Z 
    
    JNZ Invert  ; si no se "encolaron" todos los bit, repite
    MVI C, 08h  ; ya encolados reinicio el contador para proximo uso
    MOV A, D    ; A por D | dato ya invertido
    
    RET