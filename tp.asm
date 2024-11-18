global main
extern printf, puts, gets, fwrite, fread, fopen, fclose

section .data
    modoEscritura db "wb", 0
    modoLectura db "rb", 0
    nombreArchivo db "partidas.dat",0
    cSoldados db "X", 0
    cOficiales db "O", 0
    msgPersonalizar db "¿Desea personalizar la partida? (S/N): ", 0
    msgPersonalizarSoldados db "¿Que simbolo usaran los soldados?: ", 0
    msgPersonalizarOficiales db "¿Que simbolo usaran los oficiales?: ", 0
    msgErrorIngreso db "¡Ingreso inválido, intente nuevamente!", 0
    msgEstadoTablero db "Estado actual del tablero:", 0
    msgGanador db "El ganador es %c ¡Felicidades!",0
    msgErrorCargaPartida db "Todavia no hay una partida cargada. Por favor inicie una partida o termine", 0
    msgErrorApertura db "Ocurrio un error al abrir un archivo", 0
    msgCargandoArchivo db "Cargando partida anterior...", 0
    msgGuardadoPartida db "Guardando datos de la partida....", 0
    msgPreguntaCargaArchivo db "¿Desea cargar la partida anterior? (S/N): ", 0
    msgPreguntaGuardadoArchivo db "¿Desea guardar la partida anterior? (S/N): ", 0
    msgSaludoFinal db "¡Gracias por jugar! ¡Hasta la próxima!", 0
    saltoLinea db 0

    msgPedirMovimiento db "Ingrese el movimiento de %s a realizar: ", 0x0a, 0
    msgFicha db "   Ubicación actual de la ficha a mover (formato: FilCol, ej. '34'): ", 0
    msgDestino db "   Ubicación destino de la ficha a mover (formato: FilCol, ej. '35'): ", 0
    formato db "%hhi", 0

    rojo db 0x1B, '[1;31m', 0
    blanco db 0x1B, '[0m', 0
    gris db 0x1B, '[1;90m', 0

    columnas db " | 1234567", 0
    f1 db "1|   XXX  ", 0x0A
    f2 db "2|   XXX  ", 0x0A
    f3 db "3| XXXXXXX", 0x0A
    f4 db "4| XXXXXXX", 0
    f5 db "5| XX   XX", 0
    f6 db "6|     O  ", 0
    f7 db "7|   O    ", 0

    ; ****** Tablero a imprimirse ********;
    columnasImp db " | 1234567", 0
    f1Imp db "1|   XXX  ", 0x0A
    f2Imp db "2|   XXX  ", 0x0A
    f3Imp db "3| XXXXXXX", 0x0A
    f4Imp db "4| XXXXXXX", 0
    f5Imp db "5| XX   XX", 0
    f6Imp db "6|     O  ", 0
    f7Imp db "7|   O    ", 0

    registroMatriz:
        fichaSoldado db ' '
        fichaOficial db ' '
        jugadaActual db ' '
        f1A times 10 db ' '
        f2A times 10 db ' '
        f3A times 10 db ' '
        f4A times 10 db ' '
        f5A times 10 db ' '
        f6A times 10 db ' '
        f7A times 10 db ' '

    ; Casillas válidas: 13 14 15
    ;                   23 24 25
    ;             31 32 33 34 35 36 37
    ;             41 42 43 44 45 46 47
    ;             51 52 53 54 55 56 57
    ;                   63 64 65
    ;                   73 74 75

    ;Variables de estado
    rotaciones db 0
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

    idArchivo resq 1

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

%macro mAbrirArchivo 2 
    mov rdi, %1
    mov rsi, %2
    sub rsp,8
    call fopen
    add rsp,8
%endmacro

%macro mCerrarArchivo 1
    mov rdi, [%1]
    sub rsp,8
    call fclose
    add rsp,8
%endmacro

%macro mLeerArchivo 3 
    mov rdi, %1
    mov rsi, %2
    mov rdx,1
    mov rcx,[%3]
    sub rsp,8
    call fread
    add rsp,8
%endmacro

%macro mEscribirArchivo 3 
    mov rdi, %1
    mov rsi, %2
    mov rdx,1
    mov rcx,[%3]
    sub rsp,8
    call fwrite
    add rsp,8
%endmacro

%macro mRecuperarDato 3
   mov rcx,%1
   mov rsi,%2
   mov rdi,%3
   rep movsb
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
    sub  rsp, 8
    call cargarInfoArchivo
    add rsp,8
    cmp byte[archivoCargadoCorrectamente], 'N'
    je personalizar
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
%macro mCambiarColor 1
    ; Cambia el color de la terminal, macro utilizada en 'mostrarTablero'
    push rbx
    mImprimirPrintf %1, 0
    pop rbx
%endmacro

%macro mImprimirFilasGrises 1
    ; Imprime las filas grises del tablero, macro utilizada en 'mostrarTablero'
    mov ax, [%1]
    mov [buffer], ax
    mov byte [buffer + 2], 0
    sub rsp, 8
    mImprimirPrintf buffer, 0
    add rsp, 8
    mCambiarColor gris
    mImprimirPuts %1 + 2
    mCambiarColor blanco
%endmacro

mostrarTablero:
    ; Muestra el tablero en la terminal
    sub rsp, 16
    call pasarTableroImpresion
    mImprimirPuts msgEstadoTablero
    mImprimirPuts columnasImp
    mImprimirPuts f1Imp
    add rsp, 16

    mov rbx, 0
imprimirTableroCiclo:
    cmp rbx, 3 ; Los primeros 3 caracteres son si o si blancos
    jl imprimirCaracter

    mov al, byte[f5Imp + rbx]
    cmp al, [cOficiales]
    je cambiarBlanco ; Si la celda está dentro de las 'posiciones rojas' pero es un oficial, lo imprime en blanco
    mCambiarColor rojo ; Si no, pasa a rojo
    jmp contImprimirCaracter

cambiarBlanco:
    mCambiarColor blanco
    jmp contImprimirCaracter

contImprimirCaracter:
    cmp rbx, 8
    jge imprimirCaracter
verificarGris:
    cmp rbx, 5
    jl imprimirCaracter
    mCambiarColor gris ; Las columnas entre 5 y 7 son grises, sin importar el contenido

imprimirCaracter:
    mov al, byte[f5Imp + rbx]
    mov [buffer], al
    mov byte [buffer + 1], 0
    push rbx
    mImprimirPrintf buffer, 0
    pop rbx
    
    inc rbx
    cmp rbx, 10
    jl imprimirTableroCiclo

    mImprimirPuts blanco
    mImprimirFilasGrises f6Imp
    mImprimirFilasGrises f7Imp
    ret


;pasarTableroImpresion pasa el contenido de la matrix interna a la matriz que se imprime por terminal, rotando a derecha
;ese contenido
pasarTableroImpresion:
    ; Rota todo el tablero (cuadrado de 7x7)
    mov r8b, 0
    mov r9b, 0
copiarFila:
    ; Cada vez que voy a copiar un valor inicializo otra vez mis valores de referencia (la celda 11)
    mov byte[columna], 1
    mov byte[fila], 1
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
    cmp r8b, 7
    jl copiarFila
finCopiarFila:
    mov r8b, 0
    inc r9b
    cmp r9b, 7
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
    call convertirFilaColumna

    mov rcx, 0
    mov cl, [rotaciones]
    cmp cl, 0
    je finRotarIngreso
rotarIngreso:           ; Se rotan las coordenadas a izquierda para trabajar internamente con coordenadas "normales"
    call rotarCoordenadasIzq
    loop rotarIngreso
finRotarIngreso:
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

    mov dl, byte[filaDestino]
    mov dh, byte[columnaDestino]

    mov al, byte[filaActual]
    mov ah, byte[columnaActual]
    mov bx, word[posOficial1]
    cmp bx, ax
    jne guardarPosOficial2

    mov byte[posOficial1], dl ; OPTIMIZAR?
    mov byte[posOficial1 + 1], dh
    jmp gurdarPosActualOficialesFinalizo

guardarPosOficial2:
    mov byte[posOficial2], dl
    mov byte[posOficial2 + 1], dh

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

convertirFilaColumna:
    ; Convierte la fila y columna ingresadas a números
    sub ah, 48
    mov [fila], ah
    sub al, 48
    mov [columna], al
    ret


chequearJuegoTerminado:
    mov al, byte[cSoldados]
    cmp al, byte[personajeMov]
    je chequearJuegoTerminadoSoldados

    ; Chequear si el juego terminó para los oficiales
    cmp byte[cantidadSoldados], 9 ; Si la cantidad de soldados es 9, el juego terminó
    jge juegoNoTermino
    jmp juegoTermino

chequearJuegoTerminadoSoldados:
    ; Chequear si el juego terminó para los soldados
    call chequearOficialesEncerrados
    cmp rax, 0 ; Devuelve 1 si los oficiales no están encerrados, 0 si lo están
    je juegoTermino

    mov cl, 5
    mov ch, 3
cicloVerificacionTermino:
    ; Verifica si la fortaleza se encuentra totalmente ocupada por soldados
    mov byte[fila], cl
    mov byte[columna], ch
    mov rbx, f1
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

%macro mOficialABuffer 1
    ; Macro que chequea si un oficial está encerrado
    mov al, byte[%1]
    add al, 48 ; Lo paso a ASCII, para que funcione correctamente la función de validación
    mov byte[buffer], al ; Fila
    mov al, byte[%1 + 1]
    add al, 48
    mov byte[buffer + 1], al ; Columna

    call chequearOficialEncerrado
    cmp rax, 1 ; Devuelve 1 si el oficial no está encerrado, 0 si lo está
    je oficialNoEncerrado
%endmacro

chequearOficialesEncerrados:
    ; Chequea si los oficiales están encerrados
    mOficialABuffer posOficial1
    mOficialABuffer posOficial2
    jmp oficialEstaEncerrado

%macro mChequeoRepetitivoDeAdyacentes 0
    call chequearAdyacente
    cmp rax, 1
    je oficialNoEncerrado
%endmacro

chequearOficialEncerrado:
    ; Chequea si un oficial está encerrado
    inc byte[buffer]
    mChequeoRepetitivoDeAdyacentes
    inc byte[buffer + 1]
    mChequeoRepetitivoDeAdyacentes
    dec byte[buffer]
    mChequeoRepetitivoDeAdyacentes
    dec byte[buffer]
    mChequeoRepetitivoDeAdyacentes
    dec byte[buffer + 1]
    mChequeoRepetitivoDeAdyacentes
    dec byte[buffer + 1]
    mChequeoRepetitivoDeAdyacentes
    inc byte[buffer]
    mChequeoRepetitivoDeAdyacentes
    inc byte[buffer]
    mChequeoRepetitivoDeAdyacentes
oficialEstaEncerrado:
    mov rax, 0
    ret
oficialNoEncerrado:
    mov rax, 1
    ret

chequearAdyacente:
    ; Chequea si un adyacente es soldado o celda no válida
    call validarEntradaCeldaInterna
    cmp rdx, 1
    je siguienteAdyacente

    call convertirFilaColumna
    mov rbx, f1
    call encontrarDireccionCelda
    mov al, [rbx]
    cmp al, byte[cSoldados]
    jne oficialNoEncerrado

siguienteAdyacente:
    jmp oficialEstaEncerrado ; Si por este lado se encuentra un soldado o la celda no pertenece al tablero


;********* Funciones de guardado/carga de partida ***********
cargarInfoArchivo:

    mImprimirPuts msgCargandoArchivo

    abrirArchivoLectura:
        mAbrirArchivo nombreArchivo, modoLectura
        cmp rax,0
        jle errorAperturaArchivoLectura
        mov qword[idArchivo],rax

    leerArchivo:

        mLeerArchivo registroMatriz, 73, idArchivo

        cmp rax, 0
        jle cerrarArchivo
        
        ; Coloco en las variables originales los datos extraidos del archivo
        mRecuperarDato 1, fichaSoldado, cSoldados
        mRecuperarDato 1, fichaOficial, cOficiales
        mRecuperarDato 1, jugadaActual, personajeMov
        mRecuperarDato 10, f1A, f1
        mRecuperarDato 10, f2A, f2
        mRecuperarDato 10, f3A, f3
        mRecuperarDato 10, f4A, f4
        mRecuperarDato 10, f5A, f5
        mRecuperarDato 10, f6A, f6
        mRecuperarDato 10, f7A, f7

        jmp leerArchivo

guardarProgreso:

    mImprimirPuts msgGuardadoPartida
    ;Muevo toda la info a los registros correspondientes 

   abrirArchivoEscritura:
        mAbrirArchivo nombreArchivo, modoEscritura
        cmp rax,0
        jle errorAperturaArchivoEscritura
        mov qword[idArchivo],rax

    ; Coloco en los registros (a escribir) los datos de la partida actual
    mRecuperarDato 1, cSoldados, fichaSoldado
    mRecuperarDato 1, cOficiales, fichaOficial
    mRecuperarDato 1, personajeMov, jugadaActual
    mRecuperarDato 10, f1, f1A
    mRecuperarDato 10, f2, f2A
    mRecuperarDato 10, f3, f3A
    mRecuperarDato 10, f4, f4A
    mRecuperarDato 10, f5, f5A
    mRecuperarDato 10, f6, f6A
    mRecuperarDato 10, f7, f7A
  
    mEscribirArchivo registroMatriz, 73, idArchivo ;Cargo en el archivo todo los necesario para reiniciar la partida
    jmp cerrarArchivo
    

cerrarArchivo:
    mCerrarArchivo idArchivo
    ret

;********* Funciones de error **********
errorIngreso:
    mov rdi, msgErrorIngreso
    sub rsp, 8
    call puts
    add rsp, 8
    mov rax, 1
    ret
errorAperturaArchivoLectura:
    mImprimirPuts msgErrorCargaPartida
    mov byte[archivoCargadoCorrectamente], "N"
    ret

errorAperturaArchivoEscritura:
    mImprimirPuts msgErrorApertura
    mov byte[archivoGuardadoCorrectamente], "N"
    ret