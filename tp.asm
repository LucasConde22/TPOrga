global main
extern printf, puts, gets, sscanf

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

    msgPedirMovimiento db "Ingrese el movimiento a realizar: ", 0
    msgFicha db "   Ubicación actual de la ficha a mover (formato: FilCol, ej. '34'): ", 0
    msgDestino db "   Ubicación destino de la ficha a mover (formato: FilCol, ej. '35'): ", 0
    formato db "%hhi", 0

    columnas db " | 1234567", 0x0A
    f1 db "1|   XXX  ", 0x0A
    f2 db "2|   XXX  ", 0x0A
    f3 db "3| XXXXXXX", 0x0A
    f4 db "4| XXXXXXX", 0x0A
    f5 db "5| XX   XX", 0x0A
    f6 db "6|     O  ", 0x0A
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
    archivoGuardadoCorrectamente db 'N'

section .bss
    fila resb 1
    columna resb 1
    respuestaSN resb 101
    buffer resq 1

%macro mImprimirPrintf 1
    mov rdi, %1
    sub rsp, 8
    call printf
    add rsp, 8
%endmacro
    

%macro mImprimirPuts 1
    mov rdi, %1
    sub rsp, 8
    call puts
    add rsp, 8
%endmacro

%macro mLeer 0
    mov rdi, buffer
    sub rsp, 8
    call gets
    add rsp, 8
%endmacro

%macro recibirSiNo 0; Almacena una repuesta ingresada por stdin del usuario (límite de 100 bytes para que no sobreescriba por accidente otras cosas)
    mov rdi, respuestaSN
    sub rsp, 8
    call gets
    add rsp, 8
%endmacro


;********* Programa principal **********
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
    mLeer

    ; Validar respuesta
    call validarEntradaPersonalizacion ; Desarrolar al final!

cicloJuego:
    ; Mostrar tablero
    call mostrarTablero

    ; Pedir movimiento
    mImprimirPuts msgPedirMovimiento
    mImprimirPrintf msgFicha
    mLeer
    call validarEntradaCelda
    mImprimirPrintf msgDestino
    mLeer
    call validarEntradaCelda

    ; Chequear si el juego terminó ->  modificar variable juegoTerminado
    ;

    cmp byte[juegoTerminado], 'S'
    je  terminarJuego
    jmp cicloJuego
    ret

terminarJuego:
    cmp byte[juegoTerminado], 'N'
    je  ofrecerGuardado
    sub rsp, 8
    call mostrarGanador
    add rsp, 8 
    jmp fin
ofrecerGuardado:
    mImprimirPuts msgPreguntaGuardadoArchivo
    recibirSiNo
    cmp byte[respuestaSN], 'N'
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
    ret

validarEntradaCelda:
    ; Valida que la celda ingresada sea válida (que pertenezca al tablero):
    mov al, [buffer] ; Columna
    mov ah, [buffer + 1] ; Fila

    mov dh, 51 ; Col 3
    mov dl, 53 ; Col 5
    cmp ah, 49 ; Fila 1
    je validarEntradaCeldaCol
    jl errorIngreso ; Fila < 1, error | DEBERÍAMOS LLAMAR A OTRO LUGAR Y QUE SE BIFURQUE PARA EJECUTAR DEVUELTA EL PEDIDO
    cmp ah, 50 ; Fila 2
    je validarEntradaCeldaCol
    cmp ah, 54 ; Fila 6
    je validarEntradaCeldaCol
    cmp ah, 55 ; Fila 7
    je validarEntradaCeldaCol
    jg errorIngreso ; Fila > 7, error

    mov dh, 49 ; Col 1
    mov dl, 55 ; Col 7
    cmp ah, 51 ; Fila 3
    je validarEntradaCeldaCol
    cmp ah, 52 ; Fila 4
    je validarEntradaCeldaCol

validarEntradaCeldaCol:
    cmp al, dh
    jl errorIngreso
    cmp al, dl
    jg errorIngreso

    ; Podría hacer las conversiones antes, el manejo de errores creo que sería un poco mayor
    mov [buffer], ah
    mov byte [buffer + 1], 0
    mov [columna], al ; Aprovecho para guardar el caracter de la col, porque el llamado rompe rax
    mov rdi, buffer
    mov rsi, formato
    mov rdx, fila
    sub rsp, 16 ; Por qué 16? No sé
    call sscanf
    add rsp, 16

    mov rax, [columna]
    mov [buffer], al
    mov byte [buffer + 1], 0
    mov rdi, buffer
    mov rsi, formato
    mov rdx, columna
    sub rsp, 16
    call sscanf
    add rsp, 16
    
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
    ret;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
