;*****************************************************************
;       Técnicas Digitales II - Trabajo Práctico N1
;       Actividad II: Lectura de teclado/Escritura de displys
;       FERRER, Ezequiel
;*****************************************************************
; Requiere (simulacion):
;   - Teclado desde puerto 20h
;   - Display 7seg desde puerto 10h
;   - Display 15seg desde puerto 20h

;*****************************************************************
;       Definición de Etiquetas
;*****************************************************************
.define
	BootAddr	0000h
	StackAddr   FFFFh
	DataROM		AAAAh
    
    Teclado     20h    ; Puerto teclado

    Tecl0       30h    ; Valores numericos ASCII del teclado
    Tecl1       31h
    Tecl2       32h
    Tecl3       33h
    Tecl4       34h
    Tecl5       35h
    Tecl6       36h
    Tecl7       37h
    Tecl8       38h
    Tecl9       39h
    TeclNULL    00h

    Disp7seg    17h     ; Puerto 8vo digito 7seg
    
    Disp15segUb 2Fh     ; Puertos a y b primeros 4 digitos 15seg
    Disp15segUa 2Eh
    Disp15segDb 2Dh
    Disp15segDa 2Ch
    Disp15segCb 2Bh
    Disp15segCa 2Ah
    Disp15segMb 29h
    Disp15segMa 28h

;*****************************************************************
;       Datos en ROM
;*****************************************************************
.data       DataROM
    D7s0:   dB  77h     ; Valores HEX de numeros para 7seg
    D7s1:   dB  44h
    D7s2:   dB  3Eh
    D7s3:   dB  6Eh
    D7s4:   dB  4Dh
    D7s5:   dB  6Bh
    D7s6:   dB  7Bh
    D7s7:   dB  46h
    D7s8:   dB  7Fh
    D7s9:   dB  4Fh
    D7sE:   dB  3Bh
    
    ContU:  dB 00h      ; Valores DEC de cada digito del contador
    ContD:  dB 00h
    ContC:  dB 00h
    ContM:  dB 00h

;*****************************************************************
;       Arranque del 8085
;*****************************************************************
.org        BootAddr
    JMP     Boot

;*****************************************************************
;       PROGRAMA PRINCIPAL
;*****************************************************************
Boot:
	LXI    SP, StackAddr
    
    MVI     A, 24h
    OUT     26h
    OUT     24h
    OUT     22h
    OUT     20h
    MVI     A, 77h
    OUT     27h
    OUT     25h
    OUT     23h
    OUT     21h
    CALL    PrintCounter
    MVI     A, 00h
	
Main:
    IN      Teclado
    
    CPI     00h     ;  Valor nuevo identico o NULL no es
    JZ      Main    ; recibido para evitar el conteo
    CMP     E       ; sucesivo del dato durante
    JZ      Main    ; el pulso (mejorar con interupcion?)
    MOV     E, A
    
    CALL    EsNumero
    OUT     Disp7seg
    MVI     A, 00h  ; A retoma el valor de teclado para CMP
    JNZ     Main
    
    CALL    UpCounter
    CALL    PrintCounter

    JMP     Main
	HLT

;*****************************************************************
;       Funcion EsNumero
;*****************************************************************
;  Carga en A el valor del numero ingresado acorde a un display
; 7seg, si no es un numero graba "E"
EsNumero:
    CPI     Tecl0   ; Si son iguales Z=1
    JNZ     EsUno   ; Si no compara el siguiente
    LDA     D7s0    ; Carga el valor de 0 para display 7s en A
    RET             ; Retorno con A para 7s y Z=1
EsUno:
    CPI     Tecl1
    JNZ     EsDos
    LDA     D7s1
    RET
EsDos:
    CPI     Tecl2
    JNZ     EsTres
    LDA     D7s2
    RET
EsTres:
    CPI     Tecl3
    JNZ     EsCuatro
    LDA     D7s3
    RET
EsCuatro:
    CPI     Tecl4
    JNZ     EsCinco
    LDA     D7s4
    RET
EsCinco:
    CPI     Tecl5
    JNZ     EsSeis
    LDA     D7s5
    RET
EsSeis:
    CPI     Tecl6
    JNZ     EsSiete
    LDA     D7s6
    RET
EsSiete:
    CPI     Tecl7
    JNZ     EsOcho
    LDA     D7s7
    RET
EsOcho:
    CPI     Tecl8
    JNZ     EsNueve
    LDA     D7s8
    RET
EsNueve:
    CPI     Tecl9
    JNZ     EsLetra
    LDA     D7s9
    RET
EsLetra:
    LDA     D7sE
    RET             ; Retorno con A para 7s en "E" y Z=0

;*****************************************************************
;	Funcion UpCounter
;*****************************************************************
; Aumenta el valor del contador decimal
UpCounter:
    LDA     ContU   ; UnitCont -> A
    CPI     09h     ; Comparo con máximo numero posible
    JZ      UpCounterD
    ADI     01h     ; Si no es maximo incremento
    STA     ContU   ; Guardo numero incrementado en UnitCont 
    RET
UpCounterD:
    MVI     A, 00h
    STA     ContU   ; Si era maximo UnitCont= 0 y evaluo DecCont
    LDA     ContD   ; DecCont -> A y repito proceso
    CPI     09h
    JZ      UpCounterC
    ADI     01h
    STA     ContD
    RET
UpCounterC:
    MVI     A, 00h
    STA     ContD
    LDA     ContC
    CPI     09h
    JZ      UpCounterM
    ADI     01h
    STA     ContC
    RET
UpCounterM:
    MVI     A, 00h
    STA     ContC
    LDA     ContM
    CPI     00h
    JZ      YaSonMil
    ADI     01h
    STA     ContM
    RET
YaSonMil:
    MVI     A, 00h
    STA     ContM
    RET             ; Cuenta el ingreso de hasta mil valores

;*****************************************************************
;	Funcion PrintCounter
;*****************************************************************
;  Imprime el contador (4 digitos) en displays 15seg
PrintCounter:
    LDA     ContU       ; UnitCont -> A
    CALL    CodifTo15s  ; A codificados se cargan en C y B 
    MOV     A, C
    OUT     Disp15segUa ; Cargo 1er Byte de UnitCont
    MOV     A, B
    OUT     Disp15segUb ; Cargo 2do Byte de UnitCont

    LDA     ContD
    CALL    CodifTo15s
    MOV     A, C
    OUT     Disp15segDa
    MOV     A, B
    OUT     Disp15segDb

    LDA     ContC
    CALL    CodifTo15s
    MOV     A, C
    OUT     Disp15segCa
    MOV     A, B
    OUT     Disp15segCb

    LDA     ContM
    CALL    CodifTo15s
    MOV     A, C
    OUT     Disp15segMa
    MOV     A, B
    OUT     Disp15segMb
    
    RET

;*****************************************************************
;	Funcion CodifTo15s
;*****************************************************************
;  Traduce el valor DEC de A a 15seg en los Bytes C(24h) y B(77h),
; inicializados para reducir cantidad de instrucciones
CodifTo15s:
    MVI     C, 24h      ; Utilizo los valores de
    MVI     B, 77h      ; cero como predeterminados
    
    CPI     00h
    JNZ     CodUno
    RET
CodUno:
    CPI     01h
    JNZ     CodDos
    MVI     C, 04h
    MVI     B, 44h
    RET
CodDos:
    CPI     02h
    MVI     C, 00h
    JNZ     CodTres
    MVI     B, 3Eh
    RET
CodTres:
    CPI     03h
    JNZ     CodCuatro
    MVI     B, 6Eh
    RET
CodCuatro:
    CPI     04h
    JNZ     CodCinco
    MVI     B, 4Dh
    RET
CodCinco:
    CPI     05h
    JNZ     CodSeis
    MVI     B, 6Bh
    RET
CodSeis:
    CPI     06h
    JNZ     CodSiete
    MVI     B, 7Bh
    RET
CodSiete:
    CPI     07h
    JNZ     CodOcho
    MVI     C, 24h
    MVI     B, 0Ah
    RET
CodOcho:
    CPI     08h
    JNZ     CodNueve
    MVI     B, 7Fh
    RET
CodNueve:
    CPI     09h
    MVI     B, 6Fh
    RET
