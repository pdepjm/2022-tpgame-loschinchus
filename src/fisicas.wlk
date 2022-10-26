import mutablePosition.*
import juego.*
import wollok.game.*
import sonidos.*


package particulas{
	class Particula{
		var property image = "pelota0.png"
		var property position = new MutablePosition()
		var property velocidad= new Velocidad()
		var property gravedad = juego.g() // valor por defecto de gravedad
		
		
		var property rebote = 0.6 //velocidad que queda despues de rebotar
		var property rozamiento = 0.8 //velocidad que queda al rozar con una superficie
		
		var property rozamientoNormal = 0.8
		var property reboteNormal = 0.6
		
		const sonidoRebote = soundMock
		
		method resetear(){
			position.reestablecer()
			velocidad.nuevaVelocidad(0,0)
		}
		
		method rebotarX(){ //si la velocidad en x es lo suficientemente grande se puede rebotar
			if(velocidad.vx().abs() > 1){
				velocidad.factorVx(-rebote)
				sonidoRebote.play()
			}
		}
		method rebotarY(){  //si la velocidad en y es lo suficientemente grande se puede rebotar
			if(velocidad.vy().abs() > 1){
				velocidad.factorVy(-rebote)
				sonidoRebote.play()
			}
		}
		method estaEnElPiso() = position.y() == juego.y0()
		
		method moverse(x,y){
			position.goTo(x,y)
		}
		method moverse(nuevaPosicion){
			position = nuevaPosicion
		}
		
		method moverse()
		
	}
	object pelota inherits Particula(image = "pelota0.png", sonidoRebote = sonidoPelota){
		
		var property choque = new Choque() //objeto choque
		
		
		override method moverse(){
			
			choque.analizarEstadoActual(position, velocidad) //analiza la posicion actual y se fija que tipos de choque se esta produciendo
			
			if(!self.estaEnElPiso()){
				velocidad.acelerarY(gravedad.randomUpTo(gravedad-0.1)) //si no esta en el piso, actua la gravedad
			}
			else if(velocidad.vy().abs() < 1)
				velocidad.factorVx(rozamiento) // si por el contrario esta en el piso y ademas casi no se mueve verticalmente entonces el roce comienza a actuar
			
			if(choque.chocaConParticula()){ //si choca con otra particula
				
				self.rebotarY() //rebota verticalmente
				if(velocidad.vy() < 0 && velocidad.vy() > -1){ 	//si la velocidad vertical es pequeña y esta en una particula significa que
					gravedad = 0								//se apoya sobre ella y por lo tanto la gravedad no actua
					velocidad.factorVx(rozamiento)				// y ademas actua el rozamiento	y no se permite colision horizontal			
					}											// para no trabarse con las particulas
				else	
					self.rebotarX()								//sino se puede rebotar sin problemas	
			}
			
			
			
			if(choque.chocaConTecho() || choque.chocaConPiso()){ //si choca con el piso o con el techo rebota
				self.rebotarY()
				}
				
			if(choque.chocaConPared()){
				self.rebotarX()
		
			} //si choca con alguna pared rebota
				
			
			choque = new Choque()//el choque anterior se pierde y se genera uno nuevo
			choque.irAlProximoChoque(position,velocidad) //si a la velocidad actual chocamos contra algo, ni bien ocura el presunto choque guardamos esa pocision
														// sino nada
			var x
			var y                                                           
			if(choque.hayProximoChoqueX())//Si se encontro un choque horizontal proximo vamos hasta alla
				x = juego.limitarX(choque.choqueX())
			else
				x = juego.limitarX(position.x()+velocidad.vx().truncate(0)) //sino continuamos con nuestra velocidad normal
				
					
			if(choque.hayProximoChoqueY()) //Si se encontro un choque vertical proximo vamos hasta alla
				y = juego.limitarY(choque.choqueY()) 
			else
				y = juego.limitarY(position.y()+velocidad.vy().truncate(0))	//sino continuamos con nuestra velocidad normal
			position.goTo(x,y)
			
		}
		
		method patear(fuerzaX,fuerzaY, signo){
			velocidad.nuevaVelocidad( (fuerzaX + velocidad.vx().abs())*signo , fuerzaY + velocidad.vy().abs()  ) 
			sonidoRebote.play()
		}
	}
	
	class Velocidad{ //La pelota tiene su propia velocidad
	var property vx = 0
	var property vy = 0
	
	method nuevaVelocidad(nvx,nvy){
		vx = nvx
		vy = nvy
	}
	method agregarVelocidad(avx, avy){
		vx += avx
		vy += avy
	}
	
	method factorVy(factor){
		vy = vy*factor
	}
	method factorVx(factor){
		vx = vx*factor
	}
	method acelerarY(a){
		vy += a
	}
	method modulo() = 4*vx + vy

	
	override method toString() = vx.toString().concat(" -> ".concat(vy.toString()))
}
}
class Choque{ //Este es el objeto jugoso
	
	//pueden existir 4 tipos de choque y la pelota se comportara diferente segun el tipo de choque
	var property chocaConPiso = false 
	var property chocaConTecho = false
	var property chocaConPared = false
	var property chocaConParticula = false
	
	//estos mensajes sirven para que la pelota sepa si el choque se produjo o no
	var property hayProximoChoqueY = false
	var property hayProximoChoqueX = false
	
	//Una posicion auxiliar que se usa en hayAlguienEn() para fijarnos si en esa posicion hay alguna particula 
	var property posicionBuscarParticulas = new MutablePosition()
	
	//Las posiciones en si del presunto choque
	var property choqueX = null
	var property choqueY = null
	
	override method toString() = choqueX.toString()+" -> "+choqueY.toString()+" : "+"["+chocaConPiso.toString()+", "+chocaConTecho.toString()+", "+chocaConPared.toString()+", "+chocaConParticula.toString()+"]"
	
	
	method irAlProximoChoque(posicion, velocidad){
		choqueX = posicion.x()						//nos pasan la posicion y la velocidad y analizamos la trayectoria que llevamos para buscar choques
		choqueY = posicion.y()
		self.analizarTrayectoria(velocidad)
		//if(esNecesarioAnalizar)
	}
	
	method hayAlguienEn(x,y,n){ //Busca n particulas en la posicion (x,y)
		posicionBuscarParticulas.goTo(x,y)
		const objetosEnPosicion = game.getObjectsIn(posicionBuscarParticulas)
		return objetosEnPosicion.size() > n && !(objetosEnPosicion.any({o => o.toString() == "numero"})) //para no chocar con los marcadores
	}
	
	method analizarEstadoActual(posicion, velocidad){ //Ocurre al principio del movimiento de la pelota
		choqueX = posicion.x()
		choqueY = posicion.y()
		
		if(hayProximoChoqueX || hayProximoChoqueY || self.estaEnElLimite(choqueX, choqueY)){ //Si venimos de un choque o estamos en una posicion limite
			
			const posibleX = velocidad.vx()+choqueX //la posicion a donde nuestra velocidad nos quiere llevar
			const posibleY = velocidad.vy()+choqueY
			
			chocaConPiso = posibleY <= juego.y0() //choca con el piso traspasa el piso
			chocaConTecho = posibleY >= juego.h()-1 // si traspasa el techo
			chocaConPared = posibleX <= juego.y0() || posibleX >= juego.w()-1 // si traspasa una pared
			chocaConParticula = self.hayAlguienEn(choqueX,choqueY,1) // si choca con alguien en la posicion actual
		
		}
		
		
	}
	method estaEnElLimite(x,y) = self.estaEnLimiteX(x) || self.estaEnLimiteY(y)
	method estaEnLimiteX(x) = x == juego.x0() || x == juego.w()-1 
	method estaEnLimiteY(y) = y == juego.x0() || y == juego.h()-1  
	method analizarSiHayProximoChoque(x,y){//analiza una posicion y si puede existir un choque en ella
	
		if(self.hayAlguienEn(x,y,0)){ //si hay una particula choca en ambas direcciones
			hayProximoChoqueX = true
			hayProximoChoqueY = true
			choqueX = x
			choqueY = y
		}	
			
		if(!hayProximoChoqueX){ //una vez que se determina la x del choque no se vuelve a tocar mas
			hayProximoChoqueX = self.estaEnLimiteX(x)
			if(hayProximoChoqueX)
				choqueX = x
		}
		
		if(!hayProximoChoqueY){ //una vez que se determina la y del choque no se vuelve a tocar mas
			hayProximoChoqueY = self.estaEnLimiteY(y)
			if(hayProximoChoqueY)
				choqueY = y
		}
		
		
		
		
	}
	method analizarTrayectoria(velocidad){//Metodo complejo pero es donde esta el juguito dela carne y lo que hace a los choques posibles
		
		//A grandes rasgos lo que hace es dada una velocidad y la posicion actual, "dibuja" la recta que representaria la trayectoria desde
		//la posicion actual hacia la nueva posicion, a la cual al velocidad nos lleva. Por dibujar se refiere a que obtiene cada punto de la recta
		//desde el punto actual hacia el siguiente y evalua los choques de cada uno con el metodo analizarSiHayProximoChoque(). Esto lo hace 
		//unicamente para el primero que encuentre
		
		//En realidad es una version modificada del algoritmo de Bresenham para decidir que pixeles dibujar de una recta dados su punto incial y final.
		//El punto final solo sirve para calcular los deltas pero como ya tenemos las velocidades que son, en si, los deltas, no hace falta
		//la posicion final
		//Para que sea lo mas rapido posible primero calculamos todas las variables que necesitamos de entrada y despues ponemos a correr el algoritmo
		
		const deltaX = velocidad.vx().truncate(0)
		const deltaXABS = deltaX.abs()
		
		const deltaY = velocidad.vy().truncate(0)
		const deltaYABS = deltaY.abs()
		
		var signoX = 1
		var signoY = 1
		if(deltaX < 0)
			signoX = -1
		if(deltaY < 0)
			signoY = -1
		
		const deltaX2 = 2*deltaX
		const deltaX2ABS = deltaX2.abs()
		
		const deltaY2 = 2*deltaY
		const deltaY2ABS = deltaY2.abs()
		
		
		var xk = choqueX
		var yk = choqueY
		
		
		const pintarLinea = { deltaD2ABS, deltaIABS, deltaI2ABS, xEsIndependiente =>
			 var p = deltaD2ABS - deltaIABS
			 deltaIABS.times({ i =>
			
			if(p < 0){
				if(xEsIndependiente)
			 		xk += signoX
			 	else
			 		yk += signoY
			 		
			 	self.analizarSiHayProximoChoque(xk,yk)
			 	p = p + deltaD2ABS
				 }
			else{
			 	xk += signoX
			 	yk += signoY
			 	self.analizarSiHayProximoChoque(xk,yk)
			 	p = p + deltaD2ABS - deltaI2ABS
			 }
				 
				 })
		}
		
		//self.analizarSiHayChoque(xk,yk)
		
		if(deltaYABS <= deltaXABS) //es decir |m| <= 1 -> conviene pensarlo como y = f(x)
			pintarLinea.apply(deltaY2ABS, deltaXABS, deltaX2ABS, true)
		else //es decir |m| > 1 -> conviene pensarlo como x = f(y)
			pintarLinea.apply(deltaX2ABS, deltaYABS, deltaY2ABS, false)
		
	}
}

package graficos{
	class PuntoInvisible{ //Hace un punto invisible
		var property position = new MutablePosition()
		
		method moverse(velocidad){
			position.goRight(velocidad.vx())
			position.goUp(velocidad.vy())
		}
	}
	class Punto inherits PuntoInvisible{ //Un puntito para dibujar
		var image = "circle_32x32.png"
		method image() = image
	}
	class Imagen inherits PuntoInvisible{
		var image
		method cambiarImagen(nuevaImagen){
			image = nuevaImagen
		}
		method actualizar(){
			game.removeVisual(self)
			game.schedule(50,{game.addVisual(self)})
		}
		method image() = image
	}
	
	object lineDrawer{//Basicame el algoritmo de bresenham pero ahora dibuja de verdad una linea desde (x1,y1) hasta (x2,y2) y devuelve los puntos en forma de array
	method line(x1,y1,x2,y2, efecto){
		const deltaX = x2-x1
		const deltaXABS = deltaX.abs()
		
		const puntos = []
		
		const deltaY = y2-y1
		const deltaYABS = deltaY.abs()
		
		var signoX = 1
		var signoY = 1
		if(deltaX < 0)
			signoX = -1
		if(deltaY < 0)
			signoY = -1
		
		const deltaX2 = 2*deltaX
		const deltaX2ABS = deltaX2.abs()
		
		const deltaY2 = 2*deltaY
		const deltaY2ABS = deltaY2.abs()
		
		
		var xk = x1
		var yk = y1
		
		
		const pintarLinea = { deltaD2ABS, deltaIABS, deltaI2ABS, xEsIndependiente =>
			 var p = deltaD2ABS - deltaIABS
			 deltaIABS.times({ i =>
			
			if(p < 0){
				if(xEsIndependiente)
			 		xk += signoX
			 	else
			 		yk += signoY
			 		
			 	puntos.add(efecto.apply(xk,yk))
			 	p = p + deltaD2ABS
				 }
			else{
			 	xk += signoX
			 	yk += signoY
			 	puntos.add(efecto.apply(xk,yk))
			 	p = p + deltaD2ABS - deltaI2ABS
			 }
				 
				 })
		}
		
		puntos.add(efecto.apply(xk,yk))
		//puntos.add(self.paint(xk,yk))
		
		if(deltaYABS <= deltaXABS) //es decir |m| <= 1 -> conviene pensarlo como y = f(x)
			pintarLinea.apply(deltaY2ABS, deltaXABS, deltaX2ABS, true)
		else //es decir |m| > 1 -> conviene pensarlo como x = f(y)
			pintarLinea.apply(deltaX2ABS, deltaYABS, deltaY2ABS, false)
		
		return puntos
	}
	method dibujarPuntosInvisibles(x1,y1,x2,y2) = self.line(x1,y1,x2,y2,{x,y => const punto = new PuntoInvisible(position = new MutablePosition(x = x, y = y)) game.addVisual(punto) return punto })
	method dibujarPuntos(x1,y1,x2,y2) = self.line(x1,y1,x2,y2,{x,y => const punto = new Punto(position = new MutablePosition(x = x, y = y)) game.addVisual(punto) return punto})
	method dibujarImagenes(x1,y1,x2,y2,imagen) = self.line(x1,y1,x2,y2,{x,y => const img = new Imagen(position = new MutablePosition(x = x, y = y), image = imagen) game.addVisual(img) return img})
	
}
}