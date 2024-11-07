global main
extern printf, puts, gets

section .data
    cSoldados db "X", 0
    cOficiales db "O", 0
    msgPersonalizar db "¿Desea personalizar la partida? (S/N): ", 0
    msgErrorIngreso db "Ingreso inválido, intente nuevamente.", 0
    msgEstadoTablero db "Estado actual del tablero:", 0
    msgGanador db "El ganador es %c ¡Felicidades!",0
    msgCargandoArchivo db "Cargando partida anterior", 0
    msgPreguntaCargaArchivo db "¿Desea cargar la partida anterior? (S/N): ", 0
    msgPreguntaGuardadoArchivo db "¿Desea guardar la partida anterior? (S/N): ", 0
    saltoLinea db 0

    columnas db " | 1234567", 0
    f1 db "1|   XXX  ", 0
    f2 db "2|   XXX  ", 0
    f3 db "3| XXXXXXX", 0
    f4 db "4| XXXXXXX", 0
    f5 db "5| XX   XX", 0
    f6 db "6|     O  ", 0
    f7 db "7|   O    ", 0

    ; Casillas válidas: 13 14 15
    ;                   23 24 25
    ;             31 32 33 34 35 36 37
    ;             41 42 43 44 45 46 47
    ;             51 52 53 54 55 56 57
    ;                   63 64 65
    ;                   73 74 75

    ;Variables de estado
    juegoTerminado db 'S'
    fichaGanador db 'X' ; Este valor va a ser pisado luego de terminada la partida
    archivoCargadoCorrectamente db 'S'
    archivoGuardadoCorrectamente db 'S'
section .bss
    buffer resw 1
    respuestaSN resb 101

%macro mImprimirPuts 1
    mov rdi, %1
    sub rsp, 8
    call puts
    add rsp, 8
%endmacro

%macro recibirSiNo 0; Almacena una repuesta ingresada por stdin del usuario (límite de 100 bytes para que no sobreescriba por accidente otras cosas)
    mov rdi, respuestaSN
    sub rsp, 8
    call gets
    add rsp, 8
%endmacro


;*********Funciones de muestreo**********
section .text
main:
cargarPartida:
    mImprimirPuts msgPreguntaCargaArchivo
    recibirSiNo
    cmp byte[respuestaSN], 'S'
    jne personalizar ;  Si se quiere comenzar una partida de cero, se lleva a personalizar la misma
cargarPartidaDesdeArchivo:
    call cargarInfoArchivo
    cmp byte[archivoCargadoCorrectamente], 'N'
    je cargarPartida
    jmp cicloJuego

personalizar:
    ; Mostrar mensaje de personalización
    mov rdi, msgPersonalizar
    sub rsp, 8
    call printf
    add rsp, 8

    ; Leer respuesta
    mov rdi, buffer
    sub rsp, 8
    call gets
    add rsp, 8

    ; Validar respuesta
    call validarEntradaPersonalizacion ; Desarrolar al final!

cicloJuego:
    ; Mostrar tablero
    call mostrarTablero
    ;ingresarMov o q
    ;cmp ingreso, 'Q'
    ;cmp ingreso, 'q'
    ;si q, salir
    ;efectuarMov
    ;chequearSiAlguienGano -> modifiica juegoTerminado y fichaGanador
    cmp byte[juegoTerminado], 'S'
    je  terminarJuego
    ret


terminarJuego:
    cmp byte[juegoTerminado], 'N'
    je  ofrecerGuardado
    sub rsp, 8
    call mostrarGanador
    add rsp, 8 
    jmp finDePrograma
ofrecerGuardado:
    mImprimirPuts msgPreguntaGuardadoArchivo
    recibirSN
    cmp respuestaSN, 'N'
    je fin
    call guardarProgreso
    cmp byte[archivoGuardadoCorrectamente], 'N'
    je ofrecerGuardado
fin:
    ret

;*********Funciones de muestreo**********
mostrarTablero:
    mImprimirPuts msgEstadoTablero
    mImprimirPuts columnas
    mImprimirPuts f1
    mImprimirPuts f2
    mImprimirPuts f3
    mImprimirPuts f4
    mImprimirPuts f5
    mImprimirPuts f6
    mImprimirPuts f7

    ret

mostrarGanador:
    mov rdi, msgGanador
    mov rsi, [fichaGanador]
    sub rsp, 8
    call printf
    add rsp, 8

    sub rsp, 8
    mov rdi, saltoLinea
    call puts
    add rsp, 8


;********* Funciones de validacion **********
; Código que escribí pelotudeando, seguramente haya que cambiarlo:
validarEntradaPersonalizacion:
    mov ax, [buffer]
    cmp ax, 83 ; S
    je personalizacion
    cmp ax, 115 ; s
    je personalizacion

    cmp ax, 78 ; N
    je retornoPersonalizacion
    cmp ax, 110 ; n
    je retornoPersonalizacion

    call errorIngreso
    ;jmp personalizar Volver a preguntar???

;*********Funciones auxiliares**********
retornoPersonalizacion:
    ret
personalizacion:
    ret
;********* Funciones de guardado/carga de partida ***********
cargarInfoArchivo:
    mImprimirPuts msgCargandoArchivo
    ret
guardarProgreso:
    ret
;********* Funciones de error **********
errorIngreso:
    mov rdi, msgErrorIngreso
    sub rsp, 8
    call puts
    add rsp, 8
    ret
