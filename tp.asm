global main
extern printf, puts, gets

section .data
    cSoldados db "X", 0
    cOficiales db "O", 0
    msgPersonalizar db "¿Desea personalizar la partida? (S/N): ", 0
    msgErrorIngreso db "Ingreso inválido, intente nuevamente.", 0
    msgEstadoTablero db "Estado actual del tablero:", 0
    msgPedirMovimiento db "Ingrese el movimiento a realizar: ", 0
    msgFicha db "   Ubicación actual de la ficha a mover (formato: FilCol, ej. '34'): ", 0
    msgDestino db "   Ubicación destino de la ficha a mover (formato: FilCol, ej. '35'): ", 0

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

section .bss
    buffer resw 1

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

section .text
main:
    ; Mostrar mensaje de personalización
personalizar:
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

    ; Pedir movimiento
    mImprimirPuts msgPedirMovimiento
    mImprimirPrintf msgFicha
    mLeer
    mImprimirPrintf msgDestino
    mLeer

    ret

mostrarTablero:
    mImprimirPuts msgEstadoTablero
    mImprimirPuts columnas
    ret

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

retornoPersonalizacion:
    ret

personalizacion:
    ; Personalizar tablero (Hacer último!)
    ret

errorIngreso:
    mov rdi, msgErrorIngreso
    sub rsp, 8
    call puts
    add rsp, 8
    ret
