;************************************************************
;       Técnicas Digitales II - Trabajo Práctico N1
;       Actividad Ia: Lectura/Escritura de puertos
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

;************************************************************
;	Sector de Arranque del 8085
;************************************************************
.org	BootAddr
    JMP	Boot

;************************************************************
;	Sector del Programa Principal
;************************************************************
Boot:
	
Main:
    IN  0Ah
    OUT A0h
    
    IN  0Bh
    OUT A1h
    
    IN  0Ch
    OUT A2h
    
    IN  0Dh
    OUT A3h
    
    IN  0Eh
    OUT A4h
    
    IN  0Fh
    OUT A5h
    
    IN  10h
    OUT A6h
    
    IN  11h
    OUT A7h

    JMP Main
	HLT