#Configuración de pantalla:
# Pixel Width = 16
# Pixel Height = 16
# Display Width = 512
# Display Height = 512

.data

serpienteX:		   		.space 28		# Tamaño máximo que tendrá la serpiente, contiene la ubicacion en X de cada píxel de la serpiente (28/4 = 7 píxeles de longitud)
serpienteY:				.space 28		# Tamaño máximo que tendrá la serpiente, contiene la ubicación en Y de cada pixel de la serpiente (28/4 = 7 píxeles de longitud)

longitudSerpiente: 		.word 3			# Longitud inicial en bytes que tendrá la serpiente

coordenadaX:			.word 16		# Posición en pantalla/memoria donde estará el pixel en x
coordenadaY:			.word 16		# Posición en pantalla/memoria donde estará el pixel en y
posicionActual:			.word 0			# Contiene la posición actual en memoria/pantalla del píxel

anchoPantalla:			.word 32		# Ancho de pantalla utilizable
cicloJuegoIniciado:		.word 0 		# Contiene un 0 hasta que el usuario presione una tecla
	
cabezaDireccionActual: 	.word 0			# Contiene la dirección de la función de movimiendo a la que se dirige el píxel (arriba/abajo/izquierda/derecha)
colorSerpiente:			.word 0x76F5BB	# Color de la serpiente
colorNegro:				.word 0x000000 	# Color negro

.text

main:


	jal inicializarSerpiente
	jal imprimirSerpiente
	jal movimientoInicial
	j exit
	
inicializarSerpiente:
    # Cargar posición inicial de la cabeza
    lw $t0, coordenadaX				# Posicion inicial en 'x'de la cabeza de la serpiente
    lw $t1,	coordenadaY				# Posicion inicial en 'y' de la cabeza de la serpiente
    
    lw $t2, longitudSerpiente		# Longitud actual de la serpiente en píxeles (3)
    li $t3, 0						# Indice para el ciclo
    
	cicloInicializarSerpiente:
		sw $t0, serpienteX($t3) # Se carga en memoria la posición de 'x'
		sw $t1, serpienteY($t3)	# Se carga en memoria la posicion de 'y'
	
		subi $t0, $t0, 1		# Se resta 1 a la posición en 'x'
		addi $t3, $t3, 4		# Se avanza al siguiente pixel de la serpiente
		subi $t2, $t2, 1		# Se resta 1 a los píxeles restantes
		
			
		bnez $t2, cicloInicializarSerpiente
	    jr $ra                        # Retornar
	
imprimirSerpiente:
	li $s2, 0					# Indice para el ciclo
	lw $s3, longitudSerpiente	# $t1 = longutid máxima de serpiente
	move $s7, $ra
	
	cicloImprimirSerpiente:
		
	
		lw $s0, serpienteX($s2)	# $s0 = posición en 'x' del pixel actual de la serpiente
		lw $s1, serpienteY($s2) # $s1 = posicion en 'y' del pixel actual de la serpiente
		
		sw $s0, coordenadaX		# Actualiza en memoria la coordenadaX
		sw $s1, coordenadaY		# Actualiza en memoria la coordenadaY
		
		jal calculoCoordenadas	# Posicion en memoria/pantalla correspondientes al x/y anteriores en 'posicionActual'
		jal imprimirPixel		# Imprime un píxel en la posicion de pantalla guardada en $s0
		
		addi $s2, $s2, 4		# Avanza al siguiente píxel a imprimir
		subi $s3, $s3, 1		# Resta 1 a la cantidad de píxeles a imprimir
		
		bnez $s3, cicloImprimirSerpiente	# Si la cantidad de píxeles a imprimir no es 0, seguir en bucle
		jr $s7
		
movimientoInicial:

	
#Utiliza: Posición del píxel 'x' y 'y' guardados en memoria, y resolución de pantalla.
#Devuelve: Posición actual del píxel en memoria/pantalla (.word posicionActual)
calculoCoordenadas:

	# Preparación de variables
	lw $t2, coordenadaX
	lw $t3, coordenadaY
	lw $t4, anchoPantalla

	
	# Cálculo de coordenadas para imprimir píxel
	mul $t7, $t3, $t4  # $t7 = Y * Ancho de pantalla
	add $t7, $t7, $t2  # $t7 = Y * Ancho de pantalla + X
	mul $t7, $t7, 4	   # Se multiplica por 4 (Tamaño de píxeles en bytes)

	la $t8, 0x10008000  # $t8 = dirección base de la pantalla
	add $t7, $t7, $t8	# $t7 = Coordenadas a imprimir el pixel
	
	sw $t7, posicionActual # Guarda la posición actual en memoria/pantalla del pixel
	jr $ra
	
	
# Imprime un píxel del color $t0 en la posición de memoria guardada en 'posicionActual'
imprimirPixel:
	lw $t2, posicionActual
	lw $t0, colorSerpiente
	
	sw $t0, 0($t2)
	jr $ra
		


exit:
	li $v0, 10
	syscall