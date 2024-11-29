global main
extern printf, puts, gets, fwrite, fread, fopen, fclose

section .data

    ; Mensajes a imprimir ----------
    modoEscritura db "wb", 0
    modoLectura db "rb", 0
    cSoldados db "X", 0
    cOficiales db "O", 0
    msgPersonalizar db "¿Desea personalizar la partida? (S/N): ", 0
    msgPersonalizarSoldados db "    ● ¿Que simbolo usaran los soldados?: ", 0
    msgPersonalizarOficiales db "    ● ¿Que simbolo usaran los oficiales?: ", 0
    msgPrimeraJugada db "    ● ¿Quien quiere que comience la partida %s o %s ?: ", 0

    msgRotacion db "    ● Ingrese un comando para rotar el tablero", 0
    msgIngresoComando db "    > ", 0

    comandosRotacion:
        sinRotacion db "      0 - Sin rotacion", 0
        derecha db "      1 - Rotar a derecha", 0
        arriba db "      2 - Rotar arriba", 0
        izquierda db "      3 - Rotar a izquierda", 0

    msgErrorIngreso db 0x1B,'[31m',"    ¡Ingreso inválido, intente nuevamente!",0x1B,'[0m', 0
    msgEstadoTablero db "Estado actual del tablero:", 0x0a, 0
    msgGanador db 0x1B,'[33m',"El ganador es %c ¡Felicidades!", 0x1B, '[0m', 0
    msgPreguntaNombreArchivo db "¿Como quiere que se llame el archivo?: ", 0
    msgPreguntaNombreArchivoCarga db "¿Como se llama el archivo que quiere cargar?: ", 0
    msgErrorCargaPartida db "Todavia no hay una partida cargada con ese nombre. Por favor inicie una partida o termine", 0
    msgErrorApertura db 0x1B, '[1;31m',"Ocurrio un error al abrir un archivo", 0
    msgCargandoArchivo db 0x1B,'[32m',"Cargando partida anterior...", 0x1B, '[0m', 0
    msgGuardadoPartida db "Guardando datos de la partida....", 0
    
    msgEstadisticas db 0x1B,'[32m',"-> Estadísticas del juego:", 0x1B, '[0m', 0
        msjCantidadMovTotales       db "    ● Total de movimientos: %hhi", 0x0a, 0
        
        msjCantidadMovOficiales             db "    ● Movimientos totales de los oficiales: %hhi", 0x0a, 0
        msjCantidadMovOficialesDetalleAI    db "            > Hacia diagonal superior izquierda:    %li", 0x0a, 0
        msjCantidadMovOficialesDetalleAC    db "            > Hacia arriba:                         %li", 0x0a, 0
        msjCantidadMovOficialesDetalleAD    db "            > Hacia diagonal superior derecha:      %li", 0x0a, 0
        msjCantidadMovOficialesDetalleCI    db "            > Hacia izquierda:                      %li", 0x0a, 0
        msjCantidadMovOficialesDetalleCD    db "            > Hacia derecha:                        %li", 0x0a, 0
        msjCantidadMovOficialesDetalleBI    db "            > Hacia diagonal inferior izquierda:    %li", 0x0a, 0
        msjCantidadMovOficialesDetalleBC    db "            > Hacia abajo:                          %li", 0x0a, 0
        msjCantidadMovOficialesDetalleBD    db "            > Hacia diagonal inferior derecha:      %li", 0x0a, 0
        
        msjCantidadMovSoldados              db "    ● Movimientos totales de los soldados: %hhi", 0x0a, 0
        msjCantidadMovSoldadosDetalleAI     db "            > Hacia diagonal superior izquierda:    %li", 0x0a, 0
        msjCantidadMovSoldadosDetalleAC     db "            > Hacia arriba:                         %li", 0x0a, 0
        msjCantidadMovSoldadosDetalleAD     db "            > Hacia diagonal superior derecha:      %li", 0x0a, 0
        msjCantidadMovSoldadosDetalleCI     db "            > Hacia izquierda:                      %li", 0x0a, 0
        msjCantidadMovSoldadosDetalleCD     db "            > Hacia derecha:                        %li", 0x0a, 0
        msjCantidadMovSoldadosDetalleBI     db "            > Hacia diagonal inferior izquierda:    %li", 0x0a, 0
        msjCantidadMovSoldadosDetalleBC     db "            > Hacia abajo:                          %li", 0x0a, 0
        msjCantidadMovSoldadosDetalleBD     db "            > Hacia diagonal inferior derecha:      %li", 0x0a, 0
        
        msjCantSoldadosCapturados   db "    ● Capturas de soldados: %hhi", 0x0a, 0
        msjCantOficialesEliminados  db "    ● Oficiales eliminados: %hhi", 0x0a, 0

    msgPreguntaCargaArchivo db "¿Desea cargar la partida anterior? (S/N): ", 0
    msgPreguntaGuardadoArchivo db "¿Desea guardar la partida anterior? (S/N): ", 0
    msgSaludoFinal db 0x1B,'[33m',"¡Gracias por jugar! ¡Hasta la próxima!", 0x1B, '[0m', 0
    saltoLinea db 0
    msgDebeComer db 0x1B, '[1;31m',"¡Cuidado, si uno de sus soldados omite una captura será retirado!", 0x1B, '[0m', 0
    msgPerdioOficial  db 0x1B, '[1;31m',"¡Omitiste una captura, perdiste un oficial!", 0x1B, '[0m', 0
    msgSoldadoCapturado db 0x1B,'[32m',"¡Soldado capturado!", 0x1B, '[0m', 0

    msgPedirMovimiento db "Ingrese el movimiento de %s a realizar: ", 0x0a, 0
    msgFicha db "    ● Ubicación actual de la ficha a mover (formato: FilCol, ej. '34'): ", 0
    msgDestino db "    ● Ubicación destino de la ficha a mover (formato: FilCol, ej. '35'): ", 0

    ; Auxiliares de impresión ----------
    formato db "%hhi", 0

    rojo db 0x1B, '[1;31m', 0
    blanco db 0x1B, '[0m', 0
    gris db 0x1B, '[1;90m', 0

    ; ****** Tablero interno ********

    columnas    db " | 1234567", 0
    f1          db "1|   XXX  ", 0x0A
    f2          db "2|   XXX  ", 0x0A
    f3          db "3| XXXXXXX", 0x0A
    f4          db "4| XXXXXXX", 0
    f5          db "5| XX   XX", 0
    f6          db "6|     O  ", 0
    f7          db "7|   O    ", 0

    ; ****** Tablero a imprimirse ********
    columnasImp db " | 1234567", 0    ; Casillas válidas:
    f1Imp       db "1|   XXX  ", 0x0A ;                   13 14 15
    f2Imp       db "2|   XXX  ", 0x0A ;                   23 24 25
    f3Imp       db "3| XXXXXXX", 0x0A ;             31 32 33 34 35 36 37
    f4Imp       db "4| XXXXXXX", 0    ;             41 42 43 44 45 46 47
    f5Imp       db "5| XX   XX", 0    ;             51 52 53 54 55 56 57
    f6Imp       db "6|     O  ", 0    ;                  63 64 65
    f7Imp       db "7|   O    ", 0    ;                   73 74 75



    ; Auxiliares de guardado ----------
    registroMatriz:
        fichaSoldado db ' '
        fichaOficial db ' '
        jugadaActual db ' '
        rotacionesArchivo db ' '
        posOficial1A times 2 db ' '
        posOficial2A times 2 db ' '
        oficialesVivosA db ' '
        soldadosLibresA db ' '
        f1A times 10 db ' '
        f2A times 10 db ' '
        f3A times 10 db ' '
        f4A times 10 db ' '
        f5A times 10 db ' '
        f6A times 10 db ' '
        f7A times 10 db ' '
        movimientosOficialesArchivo   times 8 db ' '        
        movimientosOficialesAIArchivo times 8 db ' '   
        movimientosOficialesACArchivo times 8 db ' '      
        movimientosOficialesADArchivo times 8 db ' '               
        movimientosOficialesCIArchivo times 8 db ' '    
        movimientosOficialesCDArchivo times 8 db ' '    
        movimientosOficialesBIArchivo times 8 db ' '    
        movimientosOficialesBCArchivo times 8 db ' ' 
        movimientosOficialesBDArchivo times 8 db ' '
        movimientosSoldadosArchivo    times 8 db ' '                  
        movimientosSoldadosAIArchivo  times 8 db ' '    
        movimientosSoldadosACArchivo  times 8 db ' '       
        movimientosSoldadosADArchivo  times 8 db ' '              
        movimientosSoldadosCIArchivo  times 8 db ' '   
        movimientosSoldadosCDArchivo  times 8 db ' '    
        movimientosSoldadosBIArchivo  times 8 db ' '    
        movimientosSoldadosBCArchivo  times 8 db ' ' 
        movimientosSoldadosBDArchivo  times 8 db ' '

    ;Variables de estado ---------
    
    rotaciones db 0
    juegoTerminado db 'N'
    fichaGanador db 'X' ; Este valor va a ser pisado luego de terminada la partida
    archivoCargadoCorrectamente db 'S'
    archivoGuardadoCorrectamente db 'S'
    entradaValidaPersonalizacion db 'S'
    entradaValidaArchivo db 'S'
    personajeMov db 'X', 0
    cantidadSoldados db 24
    posOficial1 db 6, 5
    posOficial2 db 7, 3
    debeCapturar db 'N'
    ambosComen db 'N'
    oficialesVivos db 2
    oficialEliminado db 0


    ;Contadores de movimientos ---
    filInicioOriginal      db 0
    filDestinoOriginal      db 0
    colInicioOriginal      db 0
    colDestinoOriginal      db 0
    desplazamiento          db '**'
    movimientosPosibles     db 'AI','AC','AD','CI','CD','BI','BC','BD'
      
    movimientosOficiales   dq 0    ;   AI|AC|AD     
    movimientosOficialesAI dq 0    ;   CI|X |CD
    movimientosOficialesAC dq 0    ;   BI|BC|BD     
    movimientosOficialesAD dq 0    ;            
    movimientosOficialesCI dq 0    ;   A: Arriba      B: Bajo
    movimientosOficialesCD dq 0    ;   C: Centro      I: Izquierda    
    movimientosOficialesBI dq 0    ;   D: Derecha     (X punto de referencia)
    movimientosOficialesBC dq 0 
    movimientosOficialesBD dq 0

    movimientosSoldados   dq 0                  
    movimientosSoldadosAI dq 0    
    movimientosSoldadosAC dq 0       
    movimientosSoldadosAD dq 0              
    movimientosSoldadosCI dq 0   
    movimientosSoldadosCD dq 0    
    movimientosSoldadosBI dq 0    
    movimientosSoldadosBC dq 0 
    movimientosSoldadosBD dq 0 


section .bss
    fila resb 1
    columna resb 1
    direccionSalto resq 1 ; Dirección de celda a la que se debe saltar
    direccionSalto2 resq 1 ; Dirección de celda alternativa a la que se puede saltar si los dos oficiales pueden comer
    direccionComida resq 1 ; Dirección de celda con soldado a ser eliminado
    direccionComida2 resq 1; Dirección de celda alternativa con soldado a ser eliminado si los dos oficiales pueden comer
    direccionOficial resq 1 ; Dirección de celda con oficial que debe capturar
    potencialEliminado resb 1 ; Número de oficial que se eliminará si omite la captura

    filaActual resb 1
    columnaActual resb 1
    filaDestino resb 1
    columnaDestino resb 1

    auxCopia resb 1

    buffer resb 101
    qAux resq 1

    idArchivo resq 1
    nombreArchivo resb 100

    totalMovimientos resw 1
    soldadosCapturados resb 1
    oficialesEliminados resb 1

; ************ Macros ************ ;
%macro mImprimirPrintf 2
    mov rdi, %1
    mov rsi, %2
    sub rsp, 8
    call printf
    add rsp, 8
%endmacro

%macro mImprimirPrintfModificado 3
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    sub rsp, 16
    call printf
    add rsp, 16
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

%macro mComparar 3
   mov rcx,%1
   lea rsi,[%2]
   lea rdi,[%3]
   repe cmpsb
%endmacro

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

;********* Programa principal **********
section .text
main:
cargarPartida:
    mImprimirPrintf msgPreguntaCargaArchivo, 0
    call recibirSiNo
    cmp byte[buffer], 'S'
    jne personalizar ;  Si se quiere comenzar una partida de cero, se lleva a personalizar la misma
cargarPartidaDesdeArchivo:
    mImprimirPrintf msgPreguntaNombreArchivoCarga, 0
    mLeer
    call validarEntradaNombreArchivo
    cmp byte[entradaValidaArchivo], 'N'
    je entradaErroneaCarga
    call almacenarNombre ; Almacena el nombre ingresado por el usuario en una variable para poder ser utilizado 
    sub  rsp, 8
    call cargarInfoArchivo
    add rsp, 8
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
    call validarEntradaPersonalizacion

cicloJuego:
    ; Mostrar tablero
    call mostrarTablero
    ; Pedir movimiento
    mImprimirPrintf msgPedirMovimiento, personajeMov
    mov al, byte[cOficiales]
    cmp byte[personajeMov], al
    jne actual
    call verificarSiOficialPuedeComer

actual:
    mImprimirPrintf msgFicha, 0
    mLeer
    
    mov ah, [buffer] ; Supuesta fila
    mov al, [buffer + 1] ; Supuesta columna
    mov [filInicioOriginal], ah ;Para el posterior conteo de movimientos
    mov [colInicioOriginal], al

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
    mov ah, [buffer] ; Supuesta fila
    mov al, [buffer + 1] ; Supuesta columna
    mov [filDestinoOriginal], ah ;Para el posterior conteo de movimientos
    mov [colDestinoOriginal], al
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
    cmp byte[debeCapturar], 'S'
    jne movimientoNormal
    cmp byte[ambosComen], 'S'
    je saltoDobleOpcion
    cmp rbx, [direccionSalto]
    jne omitioCaptura
    mov rcx, [direccionOficial]
    cmp rcx, [qAux]
    jne omitioCaptura
    jmp captura

saltoDobleOpcion: ; Si ambos oficiales pueden comer, se le da la opción al jugador de elegir con cuál comer
    cmp rbx, [direccionSalto]
    jne  segundaOpcion
    mov rcx, [direccionOficial]
    cmp rcx, [qAux]
    je omitioCapturaAux
    jmp captura
segundaOpcion:
    cmp rbx, [direccionSalto2]
    jne omitioCapturaAux
    mov rcx, [direccionOficial]
    cmp rcx, [qAux]
    jne omitioCapturaAux
    mov rcx, [direccionComida2]
    mov [direccionComida], rcx

captura:
    ; Si se llega a este punto, se come al soldado:
    mov rcx, [direccionComida]
    mov byte[rcx], ' '
    dec byte[cantidadSoldados]
    mImprimirPuts msgSoldadoCapturado

movimientoNormal:
    mov rcx, [qAux]
    mov byte[rcx], ' '
    mov al, byte[personajeMov]
    mov [rbx], al

    ; Actualizar posición guardada de oficiales (el chequeo de si se está moviendo un oficial se hace dentro de la función)
    call guardarPosActualOficiales
    call actualizarCantidadMovimientos
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
    mov byte[ambosComen], 'N' ; Por si quedó en 'S' durante la jugada anterior
    mov byte[debeCapturar], 'N' ; Por si se eliminó un soldado/oficial en la jugada anterior
    jmp cicloJuego
    ret

terminarJuego:
    cmp byte[juegoTerminado], 'N'
    je  ofrecerGuardado
saltoTJ:
    sub rsp, 8
    call mostrarEstadisticas
    add rsp, 8
    sub rsp, 8
    call mostrarGanador
    add rsp, 8
    jmp fin
ofrecerGuardado:
    call mostrarEstadisticas
    mImprimirPrintfModificado msgPreguntaGuardadoArchivo, 0, 0
    call recibirSiNo ;Ya se ocupa de recibir un si o no en buffer
    cmp byte[buffer], 'N' ;Si el usuario no quiere guardar el progreso, el programa termina directamente
    je fin
    preguntarNombre:
        mImprimirPrintfModificado msgPreguntaNombreArchivo, 0, 0
        mLeer
        call validarEntradaNombreArchivo
        cmp byte[entradaValidaArchivo], 'N'
        je entradaErroneaGuardado ; Si el nombre ingresado por el usuario no es valido vuelve a preguntar
        call almacenarNombre
        call guardarProgreso
        cmp byte[archivoGuardadoCorrectamente], 'N'
        je guardarProgreso

fin:
    ; Sale con una syscall para poder finalizar el programa incluso desde un llamado a función
    mImprimirPuts msgSaludoFinal
    mov rax, 60
    syscall ; Salir del programa

omitioCaptura:
    call actualizarCantidadMovimientos
    mImprimirPuts msgPerdioOficial
    mov rcx, [direccionOficial]
    mov byte[rcx], ' ' ; Se quita al oficial
    mov r13b, byte[potencialEliminado]
    mov byte[oficialEliminado], r13b

    dec byte[oficialesVivos]
    mov byte[juegoTerminado], 'S'
    cmp byte[oficialesVivos], 0
    jne  seguirOmision
    jmp saltoTJ

seguirOmision:
    mov byte[juegoTerminado], 'N'
    mov al, byte[cSoldados]
    mov byte[personajeMov], al
    call chequearJuegoTerminado
    cmp byte[juegoTerminado], 'S'
    je  terminarJuego
    jmp finCambio 

omitioCapturaAux:
    mov rcx, [qAux]
    mov [direccionOficial], rcx

    mov r13b, byte[posOficial1]
    mov byte[fila], r13b
    mov r13b, byte[posOficial1 + 1]
    mov byte[columna], r13b

    mov rbx, f1
    call encontrarDireccionCelda
    cmp [direccionOficial], rbx
    jne omitioCapturaAux2
    mov byte[potencialEliminado], 1
    jmp omitioCaptura
omitioCapturaAux2:
    mov byte[potencialEliminado], 2
    jmp omitioCaptura

;*********Funciones de muestreo**********
mostrarTablero:
    ; Muestra el tablero en la terminal
    mImprimirPuts saltoLinea
    sub rsp, 16
    call pasarTableroImpresion
    mImprimirPuts msgEstadoTablero
    mImprimirPuts columnasImp
    mImprimirPuts f1Imp ; Imprime hasta la fila 4 inclusive
    add rsp, 16
    cmp byte[rotaciones], 0
    jne imprimirTableroSinColores

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

imprimirTableroSinColores:
    ; Imprime las filas restantes del tablero sin realizar ningún cambio de color (para el caso de rotaciones)
    mImprimirPuts f5Imp
    mImprimirPuts f6Imp
    mImprimirPuts f7Imp
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


mostrarEstadisticas:
    mov word[totalMovimientos], 0
    mov al, [movimientosOficiales]
    add [totalMovimientos], al
    mov al, [movimientosSoldados]
    add [totalMovimientos], al

    mov al, [cantidadSoldados]
    sub al, 24
    neg al
    mov byte[soldadosCapturados], al 

    mov al, byte[oficialesVivos]
    sub al, 2
    neg al
    mov byte[oficialesEliminados], al
    mImprimirPuts saltoLinea
    mImprimirPuts msgEstadisticas
    mImprimirPrintf msjCantidadMovTotales, [totalMovimientos]

    mImprimirPrintf msjCantidadMovOficiales, [movimientosOficiales]
    mImprimirPrintf msjCantidadMovOficialesDetalleAI, qword[movimientosOficialesAI]
    mImprimirPrintf msjCantidadMovOficialesDetalleAC, qword[movimientosOficialesAC]
    mImprimirPrintf msjCantidadMovOficialesDetalleAD, qword[movimientosOficialesAD]
    mImprimirPrintf msjCantidadMovOficialesDetalleCI, qword[movimientosOficialesCI]
    mImprimirPrintf msjCantidadMovOficialesDetalleCD, qword[movimientosOficialesCD]
    mImprimirPrintf msjCantidadMovOficialesDetalleBI, qword[movimientosOficialesBI]
    mImprimirPrintf msjCantidadMovOficialesDetalleBC, qword[movimientosOficialesBC]
    mImprimirPrintf msjCantidadMovOficialesDetalleBD, qword[movimientosOficialesBD]
    mImprimirPrintf msjCantidadMovSoldados, [movimientosSoldados]
    mImprimirPrintf msjCantidadMovSoldadosDetalleAI, qword[movimientosSoldadosAI]
    mImprimirPrintf msjCantidadMovSoldadosDetalleAC, qword[movimientosSoldadosAC]
    mImprimirPrintf msjCantidadMovSoldadosDetalleAD, qword[movimientosSoldadosAD]
    mImprimirPrintf msjCantidadMovSoldadosDetalleCI, qword[movimientosSoldadosCI]
    mImprimirPrintf msjCantidadMovSoldadosDetalleCD, qword[movimientosSoldadosCD]
    mImprimirPrintf msjCantidadMovSoldadosDetalleBI, qword[movimientosSoldadosBI]
    mImprimirPrintf msjCantidadMovSoldadosDetalleBC, qword[movimientosSoldadosBC]
    mImprimirPrintf msjCantidadMovSoldadosDetalleBD, qword[movimientosSoldadosBD]
    mImprimirPrintf msjCantSoldadosCapturados, [soldadosCapturados]
    mImprimirPrintf msjCantOficialesEliminados, [oficialesEliminados]
    mImprimirPuts saltoLinea
    ret

mostrarGanador:
    mov rdi, msgGanador
    mov rsi, [fichaGanador]
    sub rsp, 8
    call printf
    add rsp, 8

;********* Funciones de movimiento y chequeo de movimiento **********
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

chequearMovimientoCorrecto: ; MEJORAR FUNCIÓN USANDO MACROS
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
    jne errorIngreso
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
    cmp byte[debeCapturar], 'S'
    je chequearMovimientoCorrectoOficialesDebeComer

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
chequearMovimientoCorrectoOficialesDebeComer:
    mov al, byte[filaDestino]
    sub al, byte[filaActual]
    cmp al, 2
    jg errorIngreso
    cmp al, -2
    jl errorIngreso

    mov al, byte[columnaDestino]
    sub al, byte[columnaActual]
    cmp al, 2
    jg errorIngreso
    cmp al, -2
    jl errorIngreso

    mov rax, 0
    ret


chequearJuegoTerminado:
    mov al, byte[cSoldados]
    cmp al, byte[personajeMov]
    je chequearJuegoTerminadoSoldados

    ; Chequear si el juego terminó para los oficiales
    cmp byte[cantidadSoldados], 9 ; Si la cantidad de soldados es < a 9, el juego terminó
    jge juegoNoTermino
    mov al, byte[cOficiales]
    mov byte[fichaGanador], al
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
%endmacro

%macro mOficialEncerrado 1
    mOficialABuffer %1
    call chequearOficialEncerrado
    cmp rax, 1 ; Devuelve 1 si el oficial no está encerrado, 0 si lo está
    je oficialNoEncerrado
%endmacro

chequearOficialesEncerrados:
    ; Chequea si los oficiales están encerrados
    cmp byte[oficialEliminado], 1
    je omitirEncierro1
    mOficialEncerrado posOficial1
    cmp byte[oficialEliminado], 2
    je oficialEstaEncerrado

omitirEncierro1:
    mOficialEncerrado posOficial2
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
    mov r8b, [cSoldados]
    call chequearAdyacenteGenerico

chequearAdyacenteGenerico:
    ; Chequea si un adyacente es igual a un valor dado
    call validarEntradaCeldaInterna
    cmp rdx, 1
    je devolverDos

    call convertirFilaColumna
    mov rbx, f1
    call encontrarDireccionCelda
    mov al, [rbx]
    cmp al, r8b
    jne oficialNoEncerrado ; Si no es igual, no está encerrado (devuelve 1)
    jmp oficialEstaEncerrado ; Si por este lado se encuentra lo buscado (devuelve 0)
    devolverDos: ; Si la celda no pertence al tablero
        mov rax, 2
        ret

verificarSiOficialPuedeComer:
    cmp byte[oficialEliminado], 1
    je bpOficial1YaEliminado
    mOficialABuffer posOficial1
    call puedeComer
    mov r13b, 1
    mov bx, [posOficial1]
    cmp rax, 0
    je debeMorfar
bpOficial1YaEliminado:
    call verificarPuedeComerOf2
    cmp rax, 0
    je debeMorfar
    ret

verificarPuedeComerOf2:
    cmp byte[oficialEliminado], 2
    je bpOficial2YaEliminado
    mOficialABuffer posOficial2
    call puedeComer
    mov r13b, 2
    mov bx, [posOficial2]
    ret
    bpOficial2YaEliminado:
    mov rax, 1
    ret

debeMorfar:
    mImprimirPuts msgDebeComer
    mov byte[debeCapturar], 'S'
    mov byte[potencialEliminado], r13b
    mov byte[fila], bl
    mov byte[columna], bh
    mov rbx, f1
    call encontrarDireccionCelda
    mov qword[direccionOficial], rbx
    cmp r13b, 1
    je verificarSiAmbosPuedenComer
    ret

verificarSiAmbosPuedenComer:
    mov rax, qword[direccionSalto]
    mov qword[direccionSalto2], rax
    mov rax, [direccionComida]
    mov qword[direccionComida2], rax
    call verificarPuedeComerOf2
    cmp rax, 0
    jne soloCome1
    mov byte[ambosComen], 'S'
    ret
    soloCome1:
        mov rax, qword[direccionSalto2]
        mov qword[direccionSalto], rax
        mov rax, 0
        ret

%macro mComerRepetitivo 0
    call puedeComerAux
    cmp rax, 0
    je seLoMorfa
%endmacro

puedeComer:
    inc byte[buffer]
    mov r10b, 1
    mov r11b, 0
    mComerRepetitivo

    inc byte[buffer + 1]
    mov r11b, 1
    mComerRepetitivo

    dec byte[buffer]
    mov r10b, 0
    mComerRepetitivo

    dec byte[buffer]
    mov r10b, -1
    mComerRepetitivo

    dec byte[buffer + 1]
    mov r11b, 0
    mComerRepetitivo

    dec byte[buffer + 1]
    mov r11b, -1
    mComerRepetitivo

    inc byte[buffer]
    mov r10b, 0
    mComerRepetitivo

    inc byte[buffer]
    mov r10b, 1
    mComerRepetitivo

    seLoMorfa:
        ret

puedeComerAux:
    call chequearAdyacente
    cmp rax, 1
    jge noPuedeComer
    mov qword[direccionComida], rbx

    add byte[buffer], r10b
    add byte[buffer + 1], r11b
    mov r8b, ' '
    call chequearAdyacenteGenerico
    cmp rax, 1
    jge decNoPuedeComer
    mov qword[direccionSalto], rbx
    ret

    decNoPuedeComer:
        sub byte[buffer], r10b
        sub byte[buffer + 1], r11b
    noPuedeComer:
        mov rax, 1
        ret



;********* Funciones de validacion **********
; Código que escribí pelotudeando, seguramente haya que cambiarlo:
validarEntradaCelda:
    ; Valida que la celda ingresada sea válida (que pertenezca al tablero):
    call reescribirBufferAMayusculas ; Si se ingresa 'q' o 'Q', se termina el juego
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


validarEntradaNombreArchivo:
    cmp byte[buffer], 0
    je  entradaInvalida
    call contarLargoEntrada
    validacionExtension:
        mov rax, 0
        loopValidacion:
            cmp rax, rbx
            jge entradaValidaNombreArchivo
            cmp byte[buffer + rax], "."
            je entradaInvalida
            inc rax
            jmp loopValidacion

entradaInvalida:
    mov byte[entradaValidaArchivo], "N"
    ret

entradaValidaNombreArchivo:
    mov byte[entradaValidaArchivo], "S"
    ret

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
rotarCoordenadas: ; En rsi y rdi cuentan con "punteros" a las dos coordenadas que se esperan
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



;********* Funciones de personalización **********
retornoPersonalizacion:
    ret
personalizacion:
    ; elegirFichas:
    ;     soldado:
    ;         mImprimirPrintfModificado msgPersonalizarSoldados, 0, 0
    ;         mLeer
    ;         call validarEntradaFicha
    ;         cmp byte[entradaValidaPersonalizacion], "N"
    ;         je soldado
    ;         mRecuperarDato 1, buffer, cSoldados
    ;     oficial:
    ;         mImprimirPrintfModificado msgPersonalizarOficiales, 0, 0
    ;         mLeer
    ;         call validarEntradaFicha
    ;         cmp byte[entradaValidaPersonalizacion], "N"
    ;         je oficial
    ;         mRecuperarDato 1, buffer, cOficiales
    elegirJugador:
        mImprimirPrintfModificado msgPrimeraJugada, cSoldados, cOficiales
        mLeer
        cmp byte[buffer], "Q"
        je fin
        call validarEntradaJugador
        cmp byte[entradaValidaPersonalizacion], "N"
        je elegirJugador
        mRecuperarDato 1, buffer, personajeMov
    rotacion:
        mImprimirPuts msgRotacion
        mImprimirPuts sinRotacion
        mImprimirPuts derecha
        mImprimirPuts arriba
        mImprimirPuts izquierda
        ingresoComando:
        mImprimirPrintfModificado msgIngresoComando, 0, 0
        mLeer
        cmp byte[buffer], "Q"
        je fin

        call validarEntradaRotacion
        cmp byte[entradaValidaPersonalizacion], "N"
        je ingresoComando

    realizarRotacion:
        mov al, byte[buffer]
        sub al, '0'
        mov byte[rotaciones], al
    ret
validarEntradaJugador:
    cmp byte[buffer + 1], 0
    jne errorEntrada
    mComparar 1, buffer, cSoldados 
    je entradaValida

    mComparar 1, buffer, cOficiales 
    je entradaValida

    jmp errorEntrada

validarEntradaRotacion:
    cmp byte[buffer + 1], 0
    jne errorEntrada
    cmp byte[buffer], '0'
    jl  errorEntrada
    cmp byte[buffer], '3'
    jg  errorEntrada
    jmp entradaValida

validarEntradaFicha:
    ret
errorEntrada:
    mImprimirPuts msgErrorIngreso
    mov byte[entradaValidaPersonalizacion], 'N'
    ret
entradaValida:
    mov byte[entradaValidaPersonalizacion], 'S'
    ret


;********* Funciones de estadísticas **********

actualizarCantidadMovimientos:
        call guardarDesplazamiento
        push rax
        push rdx
        mov rdx, 0
        mov al, byte[cOficiales]
        cmp byte[personajeMov], al
        je actualizarOficiales
        inc byte[movimientosSoldados]
        add rdx, 72
        jmp finActualizarCantidadMovimientos
        actualizarOficiales:
            inc byte[movimientosOficiales]
    finActualizarCantidadMovimientos:
        call actualizarContadoresMovimientosDirecciones
        pop rdx
        pop rax
        ret


actualizarContadoresMovimientosDirecciones:
    push rdi
    push rsi
    push rcx
    push rbx
    lea rdi, [movimientosPosibles]
    mov r10, 0
    mov rbx, 0
    recorrerPosiblesDirecciones:
        lea rsi, [desplazamiento]
        lea rdi, [movimientosPosibles]
        add rdi, r10
        mov rcx, 2
        repe cmpsb
        je finActualizarContadoresMovimientosDirecciones
        add rbx, 8
        add r10, 2
        cmp r10, 18
        jge finActualizarContadoresMovimientosDirecciones
        jmp recorrerPosiblesDirecciones
    finActualizarContadoresMovimientosDirecciones:
        add rbx, rdx
        inc qword[movimientosOficialesAI + rbx]
        pop rbx
        pop rcx
        pop rsi
        pop rdi
        ret



guardarDesplazamiento: ; Guarda en movimiento dos caracteres dependiendo de cómo fue el desplazamiento
        mov al, byte[filDestinoOriginal]
        sub al, byte[filInicioOriginal]

        cmp al, 0
        jl  guardarMovimientoFilArriba
        jg  guardarMovimientoFilAbajo
        mov byte[desplazamiento], 'C'
        jmp moverColumna
            guardarMovimientoFilArriba:
                mov byte[desplazamiento], 'A'
                jmp moverColumna
            guardarMovimientoFilAbajo:
                mov byte[desplazamiento], 'B'
    moverColumna:
        mov al, byte[colDestinoOriginal]
        sub al, byte[colInicioOriginal]
        cmp al, 0
        mov byte[desplazamiento + 1], 'C'
        jl guardarMovimientoColAIz
        jg guardarMovimientoColADe
        jmp finMoverColumna
            guardarMovimientoColADe:
                mov byte[desplazamiento + 1], 'D'
                jmp finMoverColumna
            guardarMovimientoColAIz:
                mov byte[desplazamiento + 1], 'I'
        finMoverColumna:
        ret 

;********* Funciones auxiliares **********
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



recibirSiNo:  
    ;La funcion pide al usuario que ingrese una respuesta valida (S/s/N/n) hasta que lo hace. Si
    ;el usuario ingresa minusculas se encarga de pasarlo a mayusculas
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

    recibirSiNoValido:
        ret

reescribirBufferAMayusculas:
    ;Asume que hay un caracter en el buffer y si es minúscula lo pasa a mayúsculas
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


almacenarNombre:
    call contarLargoEntrada
    mRecuperarDato rbx, buffer, nombreArchivo
    mov byte[nombreArchivo + rbx], "."
    mov byte[nombreArchivo + rbx + 1], "d"
    mov byte[nombreArchivo + rbx + 2], "a"
    mov byte[nombreArchivo + rbx + 3], "t"
    mov byte[nombreArchivo + rbx + 4], 0
    ret

contarLargoEntrada:
    mov rbx, 0
    mov r9b, [buffer]
    contarLargo:
        cmp r9b, 0
        je finLoop
        mov r9b, [buffer + rbx + 1]
        inc rbx
        jmp contarLargo


entradaErroneaGuardado:
    mImprimirPuts msgErrorIngreso
    jmp preguntarNombre


entradaErroneaCarga:
    mImprimirPuts msgErrorIngreso
    jmp cargarPartidaDesdeArchivo

finLoop:
    ret


;********* Funciones de guardado/carga de partida ***********
cargarInfoArchivo:

    mImprimirPuts msgCargandoArchivo

    abrirArchivoLectura:
        mAbrirArchivo nombreArchivo, modoLectura
        cmp rax,0
        jle errorAperturaArchivoLectura
        mov qword[idArchivo],rax

    leerArchivo:

        mLeerArchivo registroMatriz, 226, idArchivo

        cmp rax, 0
        jle cerrarArchivo
        
        ; Coloco en las variables originales los datos extraidos del archivo
        mRecuperarDato 1, fichaSoldado, cSoldados
        mRecuperarDato 1, fichaOficial, cOficiales
        mRecuperarDato 1, jugadaActual, personajeMov
        mRecuperarDato 1, rotacionesArchivo, rotaciones
        mRecuperarDato 1, movimientosOficialesArchivo, movimientosOficiales
        mRecuperarDato 1, movimientosSoldadosArchivo, movimientosSoldados
        mRecuperarDato 2, posOficial1A, posOficial1
        mRecuperarDato 2, posOficial2A, posOficial2
        mRecuperarDato 1, oficialesVivosA, oficialesVivos
        mRecuperarDato 1, soldadosLibresA, cantidadSoldados
        mRecuperarDato 10, f1A, f1
        mRecuperarDato 10, f2A, f2
        mRecuperarDato 10, f3A, f3
        mRecuperarDato 10, f4A, f4
        mRecuperarDato 10, f5A, f5
        mRecuperarDato 10, f6A, f6
        mRecuperarDato 10, f7A, f7
        mRecuperarDato  8, movimientosOficialesArchivo,   movimientosOficiales 
        mRecuperarDato  8, movimientosOficialesAIArchivo, movimientosOficialesAI
        mRecuperarDato  8, movimientosOficialesACArchivo, movimientosOficialesAC
        mRecuperarDato  8, movimientosOficialesADArchivo, movimientosOficialesAD
        mRecuperarDato  8, movimientosOficialesCIArchivo, movimientosOficialesCI
        mRecuperarDato  8, movimientosOficialesCDArchivo, movimientosOficialesCD
        mRecuperarDato  8, movimientosOficialesBIArchivo, movimientosOficialesBI
        mRecuperarDato  8, movimientosOficialesBCArchivo, movimientosOficialesBC
        mRecuperarDato  8, movimientosOficialesBDArchivo, movimientosOficialesBD
        mRecuperarDato  8, movimientosSoldadosArchivo,   movimientosSoldados 
        mRecuperarDato  8, movimientosSoldadosAIArchivo, movimientosSoldadosAI
        mRecuperarDato  8, movimientosSoldadosACArchivo, movimientosSoldadosAC
        mRecuperarDato  8, movimientosSoldadosADArchivo, movimientosSoldadosAD
        mRecuperarDato  8, movimientosSoldadosCIArchivo, movimientosSoldadosCI
        mRecuperarDato  8, movimientosSoldadosCDArchivo, movimientosSoldadosCD
        mRecuperarDato  8, movimientosSoldadosBIArchivo, movimientosSoldadosBI
        mRecuperarDato  8, movimientosSoldadosBCArchivo, movimientosSoldadosBC
        mRecuperarDato  8, movimientosSoldadosBDArchivo, movimientosSoldadosBD

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
    mRecuperarDato 1, rotaciones, rotacionesArchivo
    mRecuperarDato 1, movimientosOficiales, movimientosOficialesArchivo
    mRecuperarDato 1, movimientosSoldados, movimientosSoldadosArchivo
    mRecuperarDato 2, posOficial1, posOficial1A
    mRecuperarDato 2, posOficial2, posOficial2A
    mRecuperarDato 1, oficialesVivos, oficialesVivosA
    mRecuperarDato 1, cantidadSoldados, soldadosLibresA
    mRecuperarDato 10, f1, f1A
    mRecuperarDato 10, f2, f2A
    mRecuperarDato 10, f3, f3A
    mRecuperarDato 10, f4, f4A
    mRecuperarDato 10, f5, f5A
    mRecuperarDato 10, f6, f6A
    mRecuperarDato 10, f7, f7A
    mRecuperarDato  8, movimientosOficiales,   movimientosOficialesArchivo 
    mRecuperarDato  8, movimientosOficialesAI, movimientosOficialesAIArchivo
    mRecuperarDato  8, movimientosOficialesAC, movimientosOficialesACArchivo
    mRecuperarDato  8, movimientosOficialesAD, movimientosOficialesADArchivo
    mRecuperarDato  8, movimientosOficialesCI, movimientosOficialesCIArchivo
    mRecuperarDato  8, movimientosOficialesCD, movimientosOficialesCDArchivo
    mRecuperarDato  8, movimientosOficialesBI, movimientosOficialesBIArchivo
    mRecuperarDato  8, movimientosOficialesBC, movimientosOficialesBCArchivo
    mRecuperarDato  8, movimientosOficialesBD, movimientosOficialesBDArchivo
    mRecuperarDato  8, movimientosSoldados,   movimientosSoldadosArchivo 
    mRecuperarDato  8, movimientosSoldadosAI, movimientosSoldadosAIArchivo
    mRecuperarDato  8, movimientosSoldadosAC, movimientosSoldadosACArchivo
    mRecuperarDato  8, movimientosSoldadosAD, movimientosSoldadosADArchivo
    mRecuperarDato  8, movimientosSoldadosCI, movimientosSoldadosCIArchivo
    mRecuperarDato  8, movimientosSoldadosCD, movimientosSoldadosCDArchivo
    mRecuperarDato  8, movimientosSoldadosBI, movimientosSoldadosBIArchivo
    mRecuperarDato  8, movimientosSoldadosBC, movimientosSoldadosBCArchivo
    mRecuperarDato  8, movimientosSoldadosBD, movimientosSoldadosBDArchivo
  
    mEscribirArchivo registroMatriz, 226, idArchivo ;Cargo en el archivo todo los necesario para reiniciar la partida
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