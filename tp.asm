global main
extern printf, puts, gets

section .data
    cSoldados db "X", 0
    cOficiales db "O", 0
    msgPersonalizar db "¿Desea personalizar la partida? (S/N): ", 0
    msgErrorIngreso db "Ingreso inválido, intente nuevamente.", 0
    msgEstadoTablero db "Estado actual del tablero:", 0

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

section .bss
    buffer resw 1

%macro mImprimirPuts 1
    mov rdi, %1
    sub rsp, 8
    call puts
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

    ret

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
