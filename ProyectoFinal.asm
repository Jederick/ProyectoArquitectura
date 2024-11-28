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

cicloJuegoIniciado: .word 0 # Contiene un 0 hasta que el usuario presione una tecla

direccionActual: .word 0	# Contiene la direcci�n de la funci�n de movimiendo a la que se dirige el p�xel (arriba/abajo/izquierda/derecha)


.text

main:
	# Colores
	li $t0, 0x76F5BB   # Color celeste
	li $t1, 0x000000   # Color negro 

	
	jal calculoCoordenadas		# Se calcula en que parte de la pantalla estar� el pixel inicial
	jal imprimirPixel			# Se imprime el pixel
	
	j movimientoInicial		# Se le da un movimiento inicial al pixel  **Esta funci�n tambi�n inicia el ciclo de juego prinicipal**		


# Ciclo donde el juego se estar� ejecutando hasta que se acabe el programa

movimientoInicial:
	li $a0, 35
	li $v0, 32
	syscall 	
 	
	li $t2, 0xFFFF0000			# $t2 = Direcci�n del estado del teclado (1 si hay entrada)
	lw $t3, 0($t2)				# $t5 = Contenido de la direcci�n
	
	sw $t3, cicloJuegoIniciado
	
	j moverDerecha				# Movimiento inicial derecha (empieza el bucle de juego si el usuario presiona una tecla)

cicloJuego:
	li $a0, 100
	li $v0, 32
	syscall
	
	j leerEntrada


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
	sw $t0, 0($t2)
	jr $ra
		
esperandoEntrada:
	li $t2, 0xFFFF0000	# $t2 = Direcci�n del estado del teclado (1 si hay entrada)
	lw $t3, 0($t2)		# $t3 = Contenido de la direcci�n
	beqz $t3, cicloJuego # $t3 = 0, seguir esperando entrada
	
leerEntrada:
	li $t2, 0xFFFF0004 # t2 = Posici�n en memoria del car�cter ingrasado
	lw $t3, 0($t2) # t3 = Car�cter ingresado.
	
	beq $t3, 'd', moverDerecha	     # Si la tecla ingresada es "d", ir a moverDerecha
	beq $t3, 'D', moverDerecha	     # Si la tecla ingresada es "D", ir a moverDerecha
	
	beq $t3, 'a', moverIzquierda	 # Si la tecla ingresada es "a", ir a moverIzquierda
	beq $t3, 'A', moverIzquierda	 # Si la tecla ingresada es "A", ir a moverIzquierda
	
	beq $t3, 'w', moverArriba	 # Si la tecla ingresada es "w", ir a moverArriba
	beq $t3, 'W', moverArriba	 # Si la tecla ingresada es "W", ir a moverArriba
	
	beq $t3, 's', moverAbajo	 # Si la tecla ingresada es "w", ir a moverAbajo
	beq $t3, 'S', moverAbajo	 # Si la tecla ingresada es "W", ir a moverAbajo
	j cicloJuego


moverIzquierda:
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
	lw $t2, posicionActual	# $t2 = posicion actual del pixel
	sw $t1, 0($t2)			# Se elimina el pixel en la posicion actual
	
	lw $t3, coordenadaX		# $t3 = Posicion actual del p�xel en el eje 'x'
	addi $t3, $t3, 1		# Se le suma 1 al eje 'x' para mover el pixel a la derecha
	sw $t3, coordenadaX		# Se guarda la nueva posicion del pixen en el eje 'x' en memoria
	
	beq $t3, 63, reiniciarX
	
	jal calculoCoordenadas	# Se actualiza la posicion actual del pixel en pantalla
	jal imprimirPixel		# Se imprime el pixel
	
	lw $t4, cicloJuegoIniciado		# $t4 = 1 cuando el juego ya inici�
	beqz $t4, movimientoInicial		# si $t4 = 0, saltar a movimiento inicial
	j cicloJuego

	
# Recibe: $t5 = 0, la funci�n salta a movimiento inicial, si no, salta a cicloJuego	
moverArriba:
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