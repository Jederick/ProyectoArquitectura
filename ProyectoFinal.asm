#Configuraci�n de pantalla:
# Pixel Width = 8
# Pixel Height = 8
# Display Width = 512
# Display Height = 512

.data

coordenadaX: .word 32		# Posici�n en pantalla/memoria donde estar� el pixel en x
coordenadaY: .word 32		# Posici�n en pantalla/memoria donde estar� el pixel en y

posicionActual: .word 0		# Contiene la posici�n actual en memoria/pantalla del p�xel

anchoPantalla: .word 64		# Ancho de pantalla utilizable
altoPantalla:  .word 64		# Largo de pantalla utilizable

.text

main:
	# Colores
	li $t0, 0x76F5BB   # Color celeste
	li $t1, 0x000000   # Color negro
	
	# Variables de coordenadas y resoluci�n
	#li $t2, 32		   # Posicion en x
	#li $t3, 32		   # Posici�n en y
	#li $t4, 64		   # Ancho de pantalla
	
	# Se almacena las coordenadas en "x" y "y" en memoria
	#lw $t2, coordenadaX     
	#lw $t3, coordenadaY 
	
	# Teclado
	li $t5, 0xFFFF0000 # Estado del teclado (1 si hay entrada)
	li $t6, 0xFFFF0004 # Leer el car�cter ingrasado
	
	jal calculoCoordenadas
	jal imprimirPixel
	jal esperandoEntrada
	

#Utiliza: Posici�n del p�xel "x" y "y" guardados en memoria, y resoluci�n de pantalla.
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

	la $t8, 0x10010000  # $t8 = direcci�n base de la pantalla
	add $t7, $t7, $t8	# $t7 = Coordenadas a imprimir el pixel
	
	sw $t7, posicionActual # Guarda la posici�n actual en memoria/pantalla del pixel
	jr $ra
	
	
# Imprime un p�xel del color $t0 en la posici�n de memoria guardada en 'posicionActual'
imprimirPixel:
	lw $t2, posicionActual
	sw $t0, 0($t2)
	jr $ra
		
esperandoEntrada:
	lw $t8, 0($t5)
	beqz $t8, esperandoEntrada # Si la entrada = 0, seguir esperando entrada.
	
leerEntrada:
	lw $s0, 0($t6) #leer car�cter ingresado.
	beq $s0, 'd', moverDerecha	     # Si la tecla ingresada es "d", ir a moverDerecha
	beq $s0, 'D', moverDerecha	     # Si la tecla ingresada es "D", ir a moverDerecha
	
	beq $s0, 'a', moverIzquierda	 # Si la tecla ingresada es "a", ir a moverIzquierda
	beq $s0, 'A', moverIzquierda	 # Si la tecla ingresada es "A", ir a moverIzquierda
	
	beq $s0, 'w', moverArriba	 # Si la tecla ingresada es "w", ir a moverArriba
	beq $s0, 'W', moverArriba	 # Si la tecla ingresada es "W", ir a moverArriba
	
	beq $s0, 's', moverAbajo	 # Si la tecla ingresada es "w", ir a moverAbajo
	beq $s0, 'S', moverAbajo	 # Si la tecla ingresada es "W", ir a moverAbajo
	j esperandoEntrada


moverIzquierda:
	lw $t2, posicionActual
	sw $t1, 0($t2)		#Borra el pixel actual	

	lw $t2, coordenadaX # Guarda la coordenada 'x' del p�xel en $t2
	subi $t2, $t2, 1	# Resta 1 en la coordenada 'x' del pixel
	sw $t2, coordenadaX # Guarda el nuevo valor de la coordenada 'x' en memoria
	
	beqz $t2, exit # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j esperandoEntrada

moverDerecha:
	lw $t2, posicionActual	
	sw $t1, 0($t2) 			# Borra el p�xel actual	
	
	lw $t2, coordenadaX		# Guarda la coordenada 'x' del p�xel en $t2
	addi $t2, $t2, 1   		# Agrega 1 en la coordenada X del pixel
	sw $t2, coordenadaX		# Guarda el nuevo valor de la coordenada 'x' en memoria
		
	bge $t2, 64, exit		# Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j esperandoEntrada
	
moverArriba:
	lw $t2, posicionActual
	sw $t1, 0($t2)			 # Borra el p�xel actual
	
	lw $t2, coordenadaY		 # Guarda la coordenada 'y' del p�xel en $t2
	subi $t2, $t2, 1		 # Resta 1 en la coordenada Y del pixel
	sw $t2, coordenadaY		 # Guarda el nuevo valor de la coordenada 'y' en memoria
	
	beqz $t2, exit			 # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j esperandoEntrada
	
moverAbajo:
	lw $t2, posicionActual
	sw $t1, 0($t2) 			 # Borra el p�xel actual

	
	lw $t2, coordenadaY		 # Guarda la coordenada 'y' del p�xel en $t2	
	addi $t2, $t2, 1		 # Agrega 1 en la coordenada Y del pixel
	sw $t2, coordenadaY		 # Guarda el nuevo valor de la coordenada 'y' en memoria
	
	beq $t2, 64, exit		 # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j esperandoEntrada
	
reiniciarX:
	li $t2, 0
	j calculoCoordenadas

exit:
	li $v0, 10
	syscall
