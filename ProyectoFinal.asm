#Configuraci�n de pantalla:
# Pixel Width = 16
# Pixel Height = 16
# Display Width = 512
# Display Height = 512

.data

serpienteX:		   		.space 28		# Tama�o m�ximo que tendr� la serpiente, contiene la ubicacion en X de cada p�xel de la serpiente (28/4 = 7 p�xeles de longitud)
serpienteY:				.space 28		# Tama�o m�ximo que tendr� la serpiente, contiene la ubicaci�n en Y de cada pixel de la serpiente (28/4 = 7 p�xeles de longitud)

longitudSerpiente: 		.word 3			# Longitud inicial en bytes que tendr� la serpiente

coordenadaX:			.word 16		# Posici�n en pantalla/memoria donde estar� el pixel en x
coordenadaY:			.word 16		# Posici�n en pantalla/memoria donde estar� el pixel en y
posicionActual:			.word 0			# Contiene la posici�n actual en memoria/pantalla del p�xel

anchoPantalla:			.word 32		# Ancho de pantalla utilizable
cicloJuegoIniciado:		.word 0 		# Contiene un 0 hasta que el usuario presione una tecla
	
cabezaDireccionActual: 	.word 0			# Contiene la direcci�n de la funci�n de movimiendo a la que se dirige el p�xel (arriba/abajo/izquierda/derecha)
colorSerpiente:			.word 0x76F5BB	# Color de la serpiente
colorNegro:				.word 0x000000 	# Color negro

.text

main:


	jal inicializarSerpiente
	jal imprimirSerpiente
	jal movimientoInicial
	j exit
	
inicializarSerpiente:
    # Cargar posici�n inicial de la cabeza
    lw $t0, coordenadaX				# Posicion inicial en 'x'de la cabeza de la serpiente
    lw $t1,	coordenadaY				# Posicion inicial en 'y' de la cabeza de la serpiente
    
    lw $t2, longitudSerpiente		# Longitud actual de la serpiente en p�xeles (3)
    li $t3, 0						# Indice para el ciclo
    
	cicloInicializarSerpiente:
		sw $t0, serpienteX($t3) # Se carga en memoria la posici�n de 'x'
		sw $t1, serpienteY($t3)	# Se carga en memoria la posicion de 'y'
	
		subi $t0, $t0, 1		# Se resta 1 a la posici�n en 'x'
		addi $t3, $t3, 4		# Se avanza al siguiente pixel de la serpiente
		subi $t2, $t2, 1		# Se resta 1 a los p�xeles restantes
		
			
		bnez $t2, cicloInicializarSerpiente
	    jr $ra                        # Retornar
	
imprimirSerpiente:
	li $s2, 0					# Indice para el ciclo
	lw $s3, longitudSerpiente	# $t1 = longutid m�xima de serpiente
	move $s7, $ra
	
	cicloImprimirSerpiente:
		
	
		lw $s0, serpienteX($s2)	# $s0 = posici�n en 'x' del pixel actual de la serpiente
		lw $s1, serpienteY($s2) # $s1 = posicion en 'y' del pixel actual de la serpiente
		
		sw $s0, coordenadaX		# Actualiza en memoria la coordenadaX
		sw $s1, coordenadaY		# Actualiza en memoria la coordenadaY
		
		jal calculoCoordenadas	# Posicion en memoria/pantalla correspondientes al x/y anteriores en 'posicionActual'
		jal imprimirPixel		# Imprime un p�xel en la posicion de pantalla guardada en $s0
		
		addi $s2, $s2, 4		# Avanza al siguiente p�xel a imprimir
		subi $s3, $s3, 1		# Resta 1 a la cantidad de p�xeles a imprimir
		
		bnez $s3, cicloImprimirSerpiente	# Si la cantidad de p�xeles a imprimir no es 0, seguir en bucle
		jr $s7
		
movimientoInicial:

	
#Utiliza: Posici�n del p�xel 'x' y 'y' guardados en memoria, y resoluci�n de pantalla.
#Devuelve: Posici�n actual del p�xel en memoria/pantalla (.word posicionActual)
calculoCoordenadas:

	# Preparaci�n de variables
	lw $t2, coordenadaX
	lw $t3, coordenadaY
	lw $t4, anchoPantalla

	
	# C�lculo de coordenadas para imprimir p�xel
	mul $t7, $t3, $t4  # $t7 = Y * Ancho de pantalla
	add $t7, $t7, $t2  # $t7 = Y * Ancho de pantalla + X
	mul $t7, $t7, 4	   # Se multiplica por 4 (Tama�o de p�xeles en bytes)

	la $t8, 0x10008000  # $t8 = direcci�n base de la pantalla
	add $t7, $t7, $t8	# $t7 = Coordenadas a imprimir el pixel
	
	sw $t7, posicionActual # Guarda la posici�n actual en memoria/pantalla del pixel
	jr $ra
	
	
# Imprime un p�xel del color $t0 en la posici�n de memoria guardada en 'posicionActual'
imprimirPixel:
	lw $t2, posicionActual
	lw $t0, colorSerpiente
	
	sw $t0, 0($t2)
	jr $ra
		


exit:
	li $v0, 10
	syscall