global main
extern printf, puts, gets, sscanf

section .data
    cSoldados db "X", 0
    cOficiales db "O", 0
    msgPersonalizar db "¿Desea personalizar la partida? (S/N): ", 0
    msgErrorIngreso db "¡Ingreso inválido, intente nuevamente!", 0
    msgEstadoTablero db "Estado actual del tablero:", 0
    msgGanador db "El ganador es %c ¡Felicidades!",0
    msgCargandoArchivo db "Cargando partida anterior", 0
    msgPreguntaCargaArchivo db "¿Desea cargar la partida anterior? (S/N): ", 0
    msgPreguntaGuardadoArchivo db "¿Desea guardar la partida anterior? (S/N): ", 0
    msgSaludoFinal db "¡Gracias por jugar! ¡Hasta la próxima!", 0
    saltoLinea db 0

    msgPedirMovimiento db "Ingrese el movimiento de %s a realizar: ", 0x0a, 0
    msgFicha db "   Ubicación actual de la ficha a mover (formato: FilCol, ej. '34'): ", 0
    msgDestino db "   Ubicación destino de la ficha a mover (formato: FilCol, ej. '35'): ", 0
    formato db "%hhi", 0

   columnas db " | 1234567", 0
    f1 db "1|   XXX  ", 0x0A
    f2 db "2|   XXX  ", 0x0A
    f3 db "3| XXXXXXX", 0x0A
    f4 db "4| XXXXXXX", 0x0A
    f5 db "5| XX   XX", 0x0A
    f6 db "6|     O  ", 0x0A
    f7 db "7|   O    ", 0

    ; ****** Tablero a imprimirse ********;
    columnasImp db " | 1234567", 0
    f1Imp db "1|   XXX  ", 0x0A
    f2Imp db "2|   XXX  ", 0x0A
    f3Imp db "3| XXXXXXX", 0x0A
    f4Imp db "4| XXXXXXX", 0x0A
    f5Imp db "5| XX   XX", 0x0A
    f6Imp db "6|     O  ", 0x0A
    f7Imp db "7|   O    ", 0


    ; Casillas válidas: 13 14 15
    ;                   23 24 25
    ;             31 32 33 34 35 36 37
    ;             41 42 43 44 45 46 47
    ;             51 52 53 54 55 56 57
    ;                   63 64 65
    ;                   73 74 75

    ;Variables de estado
    rotaciones db 1
    juegoTerminado db 'N'
    fichaGanador db 'X' ; Este valor va a ser pisado luego de terminada la partida
    archivoCargadoCorrectamente db 'S'
    archivoGuardadoCorrectamente db 'S'
    personajeMov db 'X', 0
    cantidadSoldados db 24
    posOficial1 db 6, 5
    posOficial2 db 7, 3

section .bss
    fila resb 1
    columna resb 1

    filaActual resb 1
    columnaActual resb 1
    filaDestino resb 1
    columnaDestino resb 1

    filaOriginal resb 1
    columnaOriginal resb 1
    auxCopia resb 1

    buffer resb 101
    qAux resq 1

%macro mImprimirPrintf 2
    mov rdi, %1
    mov rsi, %2
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

%macro mLeer 0 ; Almacena una repuesta ingresada por stdin del usuario (límite de 100 bytes para que no sobreescriba por accidente otras cosas)
    mov rdi, buffer
    sub rsp, 8
    call gets
    add rsp, 8
%endmacro


;********* Programa principal **********
section .text
main:
cargarPartida:
    mImprimirPrintf msgPreguntaCargaArchivo, 0
    call recibirSiNo
    cmp byte[buffer], 'S'
    jne personalizar ;  Si se quiere comenzar una partida de cero, se lleva a personalizar la misma
cargarPartidaDesdeArchivo:
    call cargarInfoArchivo
    cmp byte[archivoCargadoCorrectamente], 'N'
    je cargarPartida
    jmp cicloJuego

personalizar:
    ; Mostrar mensaje de personalización
    mImprimirPrintf msgPersonalizar, 0
    call recibirSiNo
    cmp byte[buffer], 'N'
    je cicloJuego

    ; Validar respuesta
    call validarEntradaPersonalizacion ; Desarrolar al final!

cicloJuego:
    ; Mostrar tablero
    call mostrarTablero

    ; Pedir movimiento
    mImprimirPrintf msgPedirMovimiento, personajeMov
actual:
    mImprimirPrintf msgFicha, 0
    mLeer
    call validarEntradaCelda
    cmp rax, 1
    je actual ; Error en la entrada


    mov al, [fila]
    mov [filaActual], al
    mov al, [columna]
    mov [columnaActual], al

    mov rbx, f1
    call encontrarDireccionCelda
    mov al, [rbx]
    cmp al, byte[personajeMov]
    je continuarIngresoActual
    call errorIngreso ; La ficha a mover no es la correcta
    jmp actual
continuarIngresoActual: ; No me gusta mucho esta parte del código, pero no encuentro otra forma de hacer un 'call condicional'  a errorIngreso
    mov [qAux], rbx
    
destino:
    mImprimirPrintf msgDestino, 0
    mLeer
    mov rcx, 0
    mov cl, byte[rotaciones]
    cmp rcx, 0
    je validarCelda
validarCelda:
    call validarEntradaCelda
    cmp rax, 1
    je destino ; Error en la entrada
    mov al, [fila]
    mov [filaDestino], al
    mov al, [columna]
    mov [columnaDestino], al

    mov rbx, f1
    call encontrarDireccionCelda
    cmp byte[rbx], ' '
    je continuarIngresoDestino
    call errorIngreso ; La celda destino no está vacía
    jmp actual
continuarIngresoDestino:

    call chequearMovimientoCorrecto ; Chequear si el movimiento es correcto
    cmp rax, 1
    je actual ; No se movió a una celda dentro del rango permitido 

    ; Realizar movimiento:
    mov rcx, [qAux]
    mov byte[rcx], ' '
    mov al, byte[personajeMov]
    mov [rbx], al

    ; Actualizar posición guardada de oficiales (el chequeo de si se está moviendo un oficial se hace dentro de la función)
    call guardarPosActualOficiales

    ; Chequear si el juego terminó ->  modificar variable juegoTerminado
    call chequearJuegoTerminado
    cmp byte[juegoTerminado], 'S'
    je  terminarJuego

    ; Cambiar de personaje y/o actualizar posición guardada de oficiales
    mov al, byte[cSoldados]
    cmp al, byte[personajeMov]
    je  cambiarAOficiales
    mov byte[personajeMov], al
    jmp finCambio
cambiarAOficiales:
    mov al, byte[cOficiales]
    mov byte[personajeMov], al
finCambio:

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
    call recibirSiNo ;Ya se ocupa de recibir un si o no en buffer
    cmp byte[buffer], 'N' ;Si el usuario no quiere guardar el progreso, el programa termina directamente
    je fin

    call guardarProgreso
    cmp byte[archivoGuardadoCorrectamente], 'N'
    je guardarProgreso
fin:
    ; Sale con una syscall para poder finalizar el programa incluso desde un llamado a función
    mImprimirPuts msgSaludoFinal
    mov rax, 60
    syscall ; Salir del programa

;*********Funciones de muestreo**********
mostrarTablero:
    sub rsp, 16
    call pasarTableroImpresion
    mImprimirPuts msgEstadoTablero
    mImprimirPuts columnasImp
    mImprimirPuts f1Imp
    add rsp, 16
    ret
;*********Funciones de muestreo**********

pasarTableroImpresion:
    mov byte[fila], 3 ; Rota la fila central
    mov byte[columna], 1
    mov r12b, 7
    mov r13b, 3
    call pasarSector
    mov byte[fila], 6 ; Rota la parte de abajo
    mov byte[columna], 3
    mov r12b, 3
    mov r13b, 2
    call pasarSector
    mov byte[fila], 1 ; Rota la parte de arriba
    mov byte[columna], 3
    mov r12b, 3
    mov r13b, 2
    call pasarSector
    ret

pasarSector: ; en r12b (ancho), r11b (alto)
    mov r8b, byte[columna]
    mov [columnaOriginal], r8b
    mov r9b, byte[fila]
    mov [filaOriginal], r9b

    mov r8b, 0
    mov r9b, 0
copiarFila:
    mov r10b, [columnaOriginal] ; Cada vez que voy a copiar un valor inicializo otra vez mis valores de referencia
    mov r11b, [filaOriginal]
    mov [columna], r10b
    mov [fila], r11b
    add [columna], r8b
    add [fila], r9b

    mov rbx, f1
    call encontrarDireccionCelda
    mov r10b, [rbx]
    mov [auxCopia], r10b

    mov rcx, 0
    mov cl, byte[rotaciones]
    cmp cl, 0
    je finRotarVeces
rotarVeces:
    call rotarCoordenadasDer
    loop rotarVeces
finRotarVeces:
    mov rbx, f1Imp
    call encontrarDireccionCelda

    mov r10b, [auxCopia]
    mov byte[rbx], r10b
    inc r8b
    cmp r8b, r12b
    jl copiarFila
finCopiarFila:
    mov r8b, 0
    inc r9b
    cmp r9b, r13b
    jl copiarFila
    ret



validarEntradaCelda:
    ; Valida que la celda ingresada sea válida (que pertenezca al tablero):
    call reescribirBufferAMayusculas ; Si se ingresa 'q', se termina el juego
    cmp byte [buffer], 'Q' 
    je terminarJuego

    cmp byte [buffer + 2], 0
    jne errorIngreso ; No se ingresaron 2 caracteres

    call validarEntradaCeldaInterna
    cmp rdx, 1
    je errorIngreso ; Error en la entrada

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

    mov rax, 0
    ret

validarEntradaCeldaInterna:
    mov ah, [buffer] ; Fila
    mov al, [buffer + 1] ; Columna

    mov dh, '3' ; Col 3
    mov dl, '5' ; Col 5
    cmp ah, '1' ; Fila 1
    je validarEntradaCeldaCol
    jl entradaCeldaInvalida ; Fila < 1, error
    cmp ah, '2' ; Fila 2
    je validarEntradaCeldaCol
    cmp ah, '6' ; Fila 6
    je validarEntradaCeldaCol
    cmp ah, '7' ; Fila 7
    je validarEntradaCeldaCol
    jg entradaCeldaInvalida ; Fila > 7, error

    mov dh, '1' ; Col 1
    mov dl, '7' ; Col 7
    cmp ah, '3' ; Fila 3
    je validarEntradaCeldaCol
    cmp ah, '4' ; Fila 4
    je validarEntradaCeldaCol

validarEntradaCeldaCol:
    cmp al, dh
    jl entradaCeldaInvalida
    cmp al, dl
    jg entradaCeldaInvalida
    
    mov rdx, 0
    ret
entradaCeldaInvalida:
    mov rdx, 1
    ret

encontrarDireccionCelda:
    ; en rbx está la posicion de la primera celda en memoria del tablero
    ; Ya teniendo guardada la fila y columna, busca la dirección de memoria de la celda
    ; 3 + (columna-1) + 11 * (fila-1)

    movzx rax, byte [columna]
    dec rax
    add rax, 3

    add rbx, rax

    movzx rax, byte [fila]
    dec rax
    imul rax, 11

    add rbx, rax ; Finalmente, queda en rbx la dirección de memoria de la celda buscada
    ret

chequearMovimientoCorrecto:
    ; Chequea si el movimiento es correcto, es decir, si el movimiento está dentro del rango de movimientos válidos
    mov al, byte[personajeMov]
    cmp al, byte[cSoldados]
    jne chequearMovimientoCorrectoOficiales

    ; Chequear si el movimiento es correcto para los soldados
    cmp byte[filaActual], 5
    je movimientoFilaRojaSoldados

movimientoAdelanteDiagonalSoldados:
    ; Chequear si el movimiento es correcto para los soldados en las filas 'no rojas'
    mov al, byte[filaDestino]
    sub al, byte[filaActual]
    cmp al, 1
    jl errorIngreso
    jmp chequeoColumnasMovSoldados

movimientoFilaRojaSoldados:
    ; Chequear si el movimiento es correcto para los soldados en la fila 5
    cmp byte[columnaActual], 5
    jg esFilaRojaMovCostado
    cmp byte[columnaActual], 3
    jge movimientoAdelanteDiagonalSoldados

esFilaRojaMovCostado:
    cmp byte[filaDestino], 5
    jne errorIngreso

chequeoColumnasMovSoldados:
    mov al, byte[columnaDestino]
    sub al, byte[columnaActual]
    cmp al, 1
    jg errorIngreso
    cmp al, -1
    jl errorIngreso

    mov rax, 0
    ret

chequearMovimientoCorrectoOficiales:
    ; Chequea si el movimiento es correcto para los oficiales
    mov al, byte[filaDestino]
    sub al, byte[filaActual]
    cmp al, 1
    jg errorIngreso
    cmp al, -1
    jl errorIngreso

    mov al, byte[columnaDestino]
    sub al, byte[columnaActual]
    cmp al, 1
    jg errorIngreso
    cmp al, -1
    jl errorIngreso

    mov rax, 0
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
    call reescribirBufferAMayusculas
    mov ax, [buffer]
    cmp ax, 83 ; S
    je personalizacion

    cmp ax, 78 ; N
    je retornoPersonalizacion
    ret;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call errorIngreso
    ;jmp personalizar Volver a preguntar???

; ********* Funciones de rotacion **********
rotarCoordenadasDer:
    mov rsi, fila        ; FilNueva = ColVieja
    mov rdi, columna          ; ColNueva = abs(FilVieja - 7) + 1
    call rotarCoordenadas
    ret
rotarCoordenadasIzq:
    mov rsi, columna        ; ColNueva = FilaVieja
    mov rdi, fila     ; FilNueva = abs(ColVieja - 7) + 1
    call rotarCoordenadas
    ret
rotarCoordenadas: ; En rsi y rdi cuentan con punteros a las dos coordenadas que se esperan
                  ;rdi solo cambia de lugar, rsi cambia de lugar y se le hacen ciertas operaciones para eefctuar la rotación
rotar:
    mov al, [rsi] 
    mov ah, [rdi]
    mov [rsi], ah 
    sub al, 7
    cmp al, 0
    jge esPositivo
    neg al
esPositivo:
    add al, 1
    mov byte[rdi], al
    ret



;*********Funciones auxiliares**********
retornoPersonalizacion:
    ret
personalizacion:
    ret

guardarPosActualOficiales:
    ; Guarda la posición actual de los oficiales
    mov al, byte[cOficiales]
    cmp al, byte[personajeMov]
    jne gurdarPosActualOficialesFinalizo

    mov al, byte[filaActual]
    mov ah, byte[columnaActual]
    mov bx, word[posOficial1]
    cmp bx, ax
    jne guardarPosOficial2

    mov byte[posOficial1], al ; OPTIMIZAR?
    mov byte[posOficial1 + 1], ah
    jmp gurdarPosActualOficialesFinalizo

guardarPosOficial2:
    mov byte[posOficial2], al
    mov byte[posOficial2 + 1], ah

gurdarPosActualOficialesFinalizo:
    ret


;La funcion pide al usuario que ingrese una respuesta valida (S/s/N/n) hasta que lo hace. Si
;el usuario ingresa minusculas se encarga de pasarlo a mayusculas
recibirSiNo:  
    mLeer
    cmp byte[buffer + 1], 0
    jne siNoInvalido

    call reescribirBufferAMayusculas

    cmp byte[buffer], 'S'
    je recibirSiNoValido

    cmp byte[buffer], 'N'
    je recibirSiNoValido
siNoInvalido:    
    ;No es una respuesta válida, vuelvo a pedir nuevo ingreso
    mImprimirPuts msgErrorIngreso
    jmp recibirSiNo
recibirSiNoValidoMin:
    call reescribirBufferAMayusculas
recibirSiNoValido:
    ret

;Asume que hay un caracter en el buffer y si es minúscula lo pasa a mayúsculas
reescribirBufferAMayusculas:
    cmp byte [buffer], 97
    jl  terminarReescribirBufferAMayusculas ;Se asume ya está en mayúsculas
    sub byte [buffer], 32
terminarReescribirBufferAMayusculas:
    ret


chequearJuegoTerminado:
    mov al, byte[cSoldados]
    cmp al, byte[personajeMov]
    je chequearJuegoTerminadoSoldados

    ; Chequear si el juego terminó para los oficiales
    cmp byte[cantidadSoldados], 9
    jge juegoNoTermino
    jmp juegoTermino

chequearJuegoTerminadoSoldados:
    mov cl, 5
    mov ch, 3
cicloVerificacionTermino: ; Creo que no funciona correctamente
    mov byte[fila], cl
    mov byte[columna], ch
    call encontrarDireccionCelda
    mov al, [rbx]
    cmp al, byte[cSoldados]
    jne juegoNoTermino

    inc ch
    cmp ch, 6
    jl cicloVerificacionTermino
    mov ch, 3
    inc cl
    cmp cl, 8
    jl cicloVerificacionTermino

juegoTermino:
    mov byte[juegoTerminado], 'S'

juegoNoTermino:
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
    mov rax, 1
    ret