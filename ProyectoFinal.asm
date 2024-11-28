#Configuración de pantalla:
# Pixel Width = 8
# Pixel Height = 8
# Display Width = 512
# Display Height = 512


.data

display: .space 0x10010000 # Dirección base del display

.text

main:
	# Colores
	li $t0, 0x76F5BB   # Color celeste
	li $t1, 0x000000   # Color negro
	
	# Variables de coordenadas y resolución
	li $t2, 32		   # Posicion en x
	li $t3, 32		   # Posición en y
	li $t4, 64		   # Ancho de pantalla
	
	# Teclado
	li $t5, 0xFFFF0000 # Estado del teclado (1 si hay entrada)
	li $t6, 0xFFFF0004 # Leer el carácter ingrasado
	
	jal calculoCoordenadas
	jal imprimirPixel
	jal esperandoEntrada
	

#Recibe: $t2 = x, $t3 = y, $t4 = Ancho de pantalla
#Devuelve: $t7 = posición en memoria(pantalla) correspondiente a las coordenadas
calculoCoordenadas:
	# Cálculo de coordenadas para imprimir píxel
	mul $t7, $t3, $t4  # $t7 = Y * Ancho de pantalla
	add $t7, $t7, $t2  # $t7 = Y * Ancho de pantalla + X
	mul $t7, $t7, 4	   # Se multiplica por 4 (Tamaño de píxeles en bytes)

	la $t8, display    # $t8 = dirección base de la pantalla
	add $t7, $t7, $t8  # $t7 = Coordenadas a imprimir el pixel
	jr $ra
	
#Imprime un píxel del color $t0 en la posición de memoria $t7	
imprimirPixel:
	sw $t0, 0($t7)
	jr $ra
		
esperandoEntrada:
	lw $t8, 0($t5)
	beqz $t8, esperandoEntrada # Si la entrada = 0, seguir esperando entrada.
	
leerEntrada:
	lw $s0, 0($t6) #leer carácter ingresado.
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
	sw $t1, 0($t7)
	
	subi $t2, $t2, 1 # Resta 1 en la coordenada X del pixel
	
	beqz $t2, exit # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j esperandoEntrada

moverDerecha:
	sw $t1, 0($t7) # Borra el píxel actual
	
	addi $t2, $t2, 1 # Agrega 1 en la coordenada X del pixel
	
	bge $t2, 64, exit # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j esperandoEntrada
	
moverArriba:
	sw $t1, 0($t7) # Borra el píxel actual
	
	subi $t3, $t3, 1 # Resta 1 en la coordenada Y del pixel
	
	beqz $t2, exit # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j esperandoEntrada
	
moverAbajo:
	sw $t1, 0($t7) # Borra el píxel actual
	
	addi $t3, $t3, 1 # Agrega 1 en la coordenada Y del pixel
	
	beq $t2, 64, exit # Si el pixel llega al final de la pantalla, se termina el programa
	
	jal calculoCoordenadas
	jal imprimirPixel
	j esperandoEntrada
	
reiniciarX:
	li $t2, 0
	j calculoCoordenadas

exit:
	li $v0, 10
	syscall
