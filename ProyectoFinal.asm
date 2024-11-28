#Configuraci�n de pantalla:
# Pixel Width = 16
# Pixel Height = 16
# Display Width = 512
# Display Height = 512

.data

serpiente: .space 28		# Tama�o m�ximo que tendr� la serpiente (28/4 = 7 p�xeles de largo)

coordenadaX: .word 16		# Posici�n en pantalla/memoria donde estar� el pixel en x
coordenadaY: .word 16		# Posici�n en pantalla/memoria donde estar� el pixel en y
posicionActual: .word 0		# Contiene la posici�n actual en memoria/pantalla del p�xel

anchoPantalla: .word 32		# Ancho de pantalla utilizable
altoPantalla:  .word 32		# Largo de pantalla utilizable
cicloJuegoIniciado: .word 0 # Contiene un 0 hasta que el usuario presione una tecla
	
direccionActual: .word 0	# Contiene la direcci�n de la funci�n de movimiendo a la que se dirige el p�xel (arriba/abajo/izquierda/derecha)
colorSerpiente: .word 0x76F5BB	# Color de la serpiente
colorNegro: .word 0x000000 		# Color negro

.text

main:
	# Colores
#	li $t1, 0x000000   # Color negro 
#	jal inicializarSerpiente
	jal calculoCoordenadas		# Se calcula en que parte de la pantalla estar� el pixel inicial
	
	jal imprimirPixel			# Se imprime el pixel
	
	j movimientoInicial		# Se le da un movimiento inicial al pixel  **Esta funci�n tambi�n inicia el ciclo de juego prinicipal**		


# Ciclo donde el juego se estar� ejecutando hasta que se acabe el programa

inicializarSerpiente:
	
	

	jr $ra

movimientoInicial:
	li $a0, 100
	li $v0, 32
	syscall 	
 	
 	li $t2, 0xFFFF0000			# $t2 = Direcci�n del estado del teclado (1 si hay entrada)
	lw $t3, 0($t2)				# $t3 = Contenido de la direcci�n
	
	sw $t3, cicloJuegoIniciado
	
	beq $t3, 1, leerEntrada
	
	j moverDerecha

cicloJuego:
	li $a0, 100
	li $v0, 32
	syscall
	
	jal esperandoEntrada
			
	lw $t2, direccionActual
	jr $t2
	
	j cicloJuego
	
	
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

	la $t8, 0x10010000  # $t8 = direcci�n base de la pantalla
	add $t7, $t7, $t8	# $t7 = Coordenadas a imprimir el pixel
	
	sw $t7, posicionActual # Guarda la posici�n actual en memoria/pantalla del pixel
	jr $ra
	
	
# Imprime un p�xel del color $t0 en la posici�n de memoria guardada en 'posicionActual'
imprimirPixel:
	lw $t2, posicionActual
	lw $t0, colorSerpiente
	
	sw $t0, 0($t2)
	jr $ra
		
esperandoEntrada:
	li $t2, 0xFFFF0000		# $t2 = Direcci�n del estado del teclado (1 si hay entrada)
	lw $t3, 0($t2)			# $t3 = Contenido de la direcci�n
	
	beq $t3, 1, leerEntrada	# $t3 = 0, seguir esperando entrada
	jr $ra
	
leerEntrada:	
	
	li $t2, 0xFFFF0004 # t2 = Posici�n en memoria del car�cter ingrasado
	lw $t3, 0($t2) # t3 = Car�cter ingresado.
	
	beq $t3, 'd', direccionDerecha	     # Si la tecla ingresada es "d", ir a moverDerecha
	beq $t3, 'D', direccionDerecha	     # Si la tecla ingresada es "D", ir a moverDerecha
	
	beq $t3, 'a', direccionIzquierda	 # Si la tecla ingresada es "a", ir a moverIzquierda
	beq $t3, 'A', direccionIzquierda	 # Si la tecla ingresada es "A", ir a moverIzquierda
	
	beq $t3, 'w', direccionArriba	 # Si la tecla ingresada es "w", ir a moverArriba
	beq $t3, 'W', direccionArriba	 # Si la tecla ingresada es "W", ir a moverArriba
	
	beq $t3, 's', direccionAbajo	 # Si la tecla ingresada es "w", ir a moverAbajo
	beq $t3, 'S', direccionAbajo	 # Si la tecla ingresada es "W", ir a moverAbajo
	j cicloJuego

direccionIzquierda:
	la $t2, moverIzquierda
	sw $t2, direccionActual
	j cicloJuego

direccionDerecha:
	la $t2, moverDerecha
	sw $t2, direccionActual
	j cicloJuego
	
direccionArriba:
	la $t2, moverArriba
	sw $t2, direccionActual
	j cicloJuego
		
direccionAbajo:
	la $t2, moverAbajo
	sw $t2, direccionActual
	j cicloJuego

moverIzquierda:
	lw $t1, colorNegro
	lw $t2, posicionActual
	
	sw $t1, 0($t2)		#Borra el pixel actual	

	lw $t2, coordenadaX # Guarda la coordenada 'x' del p�xel en $t2
	subi $t2, $t2, 1	# Resta 1 en la coordenada 'x' del pixel
	sw $t2, coordenadaX # Guarda el nuevo valor de la coordenada 'x' en memoria
	
	beqz $t2, exit # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j cicloJuego


# Utiliza: Las coordenadas 'x' y 'y' y resolucion almacenado en memoria,
moverDerecha:
	lw $t1, colorNegro
	lw $t2, posicionActual	# $t2 = posicion actual del pixel
	
	sw $t1, 0($t2)			# Se elimina el pixel en la posicion actual
	
	lw $t3, coordenadaX		# $t3 = Posicion actual del p�xel en el eje 'x'
	addi $t3, $t3, 1		# Se le suma 1 al eje 'x' para mover el pixel a la derecha
	sw $t3, coordenadaX		# Se guarda la nueva posicion del pixen en el eje 'x' en memoria
	
	beq $t3, 63, reiniciarX
	
	jal calculoCoordenadas	# Se actualiza la posicion actual del pixel en pantalla
	jal imprimirPixel		# Se imprime el pixel
	
	lw $t4, cicloJuegoIniciado		# $t4 = 1 cuando el juego ya inici�
	beq $t4, 1, cicloJuego		# si $t4 = 0, saltar a movimiento inicial
	j movimientoInicial
	
# Recibe: $t5 = 0, la funci�n salta a movimiento inicial, si no, salta a cicloJuego	
moverArriba:
	lw $t1, colorNegro
	lw $t2, posicionActual
	
	sw $t1, 0($t2)			 # Borra el p�xel actual
	
	lw $t2, coordenadaY		 # Guarda la coordenada 'y' del p�xel en $t2
	subi $t2, $t2, 1		 # Resta 1 en la coordenada Y del pixel
	sw $t2, coordenadaY		 # Guarda el nuevo valor de la coordenada 'y' en memoria
	
	beqz $t2, exit			 # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	
	lw $t4, cicloJuegoIniciado		# $t4 = 1 cuando el juego ya inici�
	beqz $t4, movimientoInicial		# si $t4 = 0, saltar a movimiento inicial
	
	j cicloJuego
	
moverAbajo:
	lw $t1, colorNegro
	lw $t2, posicionActual
	
	sw $t1, 0($t2) 			 # Borra el p�xel actual

	
	lw $t2, coordenadaY		 # Guarda la coordenada 'y' del p�xel en $t2	
	addi $t2, $t2, 1		 # Agrega 1 en la coordenada Y del pixel
	sw $t2, coordenadaY		 # Guarda el nuevo valor de la coordenada 'y' en memoria
	
	beq $t2, 64, exit		 # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	
	j cicloJuego
	
reiniciarX:
	li $t2, 0
	sw $t2, coordenadaX
	
	lw $t3, cicloJuegoIniciado
	beqz $t3, movimientoInicial
		
	j cicloJuego

exit:
	li $v0, 10
	syscall