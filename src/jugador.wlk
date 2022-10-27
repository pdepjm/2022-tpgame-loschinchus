import fisicas.particulas.*
import fisicas.graficos.*
import juego.*
import arco.*
import wollok.game.*
import mutablePosition.*

class Pie inherits Imagen{
	method patear(){
		const imagen = image
		image = imagen.replace(".png", "Patear.png")
		game.schedule(30,{self.cambiarImagen(imagen)})
	}
}

class Jugador{
	var property pateaHaciaDerecha = true
	var property position = new MutablePosition(x = 8, y = 0)
	var property velocidad = new Velocidad()
	var property puntos = self.devolverPuntos()
	var property gravedad = juego.g()
	var property rozamiento = 0
	
	var property imagenCabeza
	var property imagenPie
	
	var property hayRozamiento = true
	
	var property fuerzaX = 2 //fuerza con que patea
	var property fuerzaY = 1.8
	var property salto = 1.5
	
	var property arco = new Arco(altura = partido.alturaArcos(), largo = partido.largoArcos())
	
	var property velX = 1 //Velocidad de empuje
	
	const posicionParaEvaluar = new MutablePosition()
	
	const cabeza = new Imagen(position = position, image = imagenCabeza)
	const pie = new Pie(position = position, image = imagenPie)
	
	method estaEn(posicion) = puntos.any({p => p.position() == posicion})
	
	method actualizarImagenes(){
		cabeza.actualizar()
		pie.actualizar()
	}
	
	method cambiarCabeza(imagen){
		cabeza.cambiarImagen(imagen)
	}
	method cambiarPie(imagen){
		pie.cambiarImagen(imagen)
	}
	
	method estaEnElPiso() = position.y() == juego.y0()
	
	method resetear(){
		velocidad.nuevaVelocidad(0,0)
		self.moverse(position.xInicial(),position.yInicial())
	}
	
	method moverse(){
		if(self.estaEnElPiso() && hayRozamiento)
			velocidad.factorVx(rozamiento)
		else
			velocidad.acelerarY(gravedad)
			
		self.limitarVelocidad()
		position.goRight(velocidad.vx())
		position.goUp(velocidad.vy())
		self.moverPuntos()
		hayRozamiento = true
	}
	
	method moverse(x,y){
		puntos.forEach({p => if(game.hasVisual(p)) game.removeVisual(p)})
		position.goTo(x,y)
		puntos = self.devolverPuntos()
	}
	
	method limitarVelocidad(){
		const nuevaX = position.x() + velocidad.vx()
		const nuevaX2 = nuevaX+1
		const nuevaY = position.y()+velocidad.vy()
		const vx1 = juego.limitarX(nuevaX) - position.x()
		const vx2 = juego.limitarX(nuevaX2) - (position.x()+1)
		
		if(vx1.abs() >= vx2.abs())
			velocidad.vx(vx2)
		else
			velocidad.vx(vx1)
	
		velocidad.vy(juego.limitarY(nuevaY) - position.y())
	}
	
	method moverPuntos(){
		puntos.forEach({p => p.moverse(velocidad)})
	}
	
	method devolverPuntos() = lineDrawer.dibujarPuntosInvisibles(position.x(),position.y(),position.x(),position.y()+2) + lineDrawer.dibujarPuntosInvisibles(position.x()+1,position.y(),position.x()+1,position.y()+2)
	
	method izquierda(){
		hayRozamiento = false
		self.evaluarEmpuje(-1)
		velocidad.nuevaVelocidad(-velX,0)
	}
	
	method derecha(){
		hayRozamiento = false
		self.evaluarEmpuje(1)
		velocidad.nuevaVelocidad(velX,0)
	}
	
	method saltar(){
		if(self.estaEnElPiso())
			velocidad.agregarVelocidad(0,salto)
	}

	method estaLaPelota(posicion) = game.getObjectsIn(posicion).contains(pelota)
	
	method acomodarPelota(signo, posicion){ //Un jugador
		if(self.estaLaPelota(posicionParaEvaluar))
				pelota.moverse(posicion.x()+signo, posicion.y())
	}
	
	method evaluarEmpuje(signo){
		const xActual = position.x()
		const yActual = position.y()
		posicionParaEvaluar.goTo(xActual, yActual)
		
		if(signo < 0){
			self.acomodarPelota(signo,posicionParaEvaluar)
			posicionParaEvaluar.goLeft(1)
			self.empujarPelota(signo,posicionParaEvaluar)
		}
		else{
			posicionParaEvaluar.goRight(1)
			self.acomodarPelota(signo,posicionParaEvaluar)
			posicionParaEvaluar.goRight(1)
			self.empujarPelota(signo,posicionParaEvaluar)
		}		
	}
	
	method empujarPelota(signo,posicion){
		if(self.estaLaPelota(posicion))
			pelota.velocidad().agregarVelocidad(signo*fuerzaX + velocidad.vx(), 0)
	}
	
	method inicializar(){
		game.addVisual(cabeza)
		game.addVisual(pie)
	}
	
	method goles() = arco.marcador().valor()
	
	method cambiarArco(altura,largo)
	method patear()
	method dibujarArco()
	method rival()
}

object jugadorIzq inherits Jugador(imagenCabeza = "messiIzq.png", imagenPie = "botinDer1.png"){
	
	override method rival() = jugadorDer
	
	override method cambiarArco(altura,largo){
		arco.reDibujarIzquierda(altura,largo)
	}
	
	override method patear(){
		posicionParaEvaluar.goTo(position.x(), position.y())
		posicionParaEvaluar.goRight(1)
		
		pie.patear()
		
		self.acomodarPelota(1,posicionParaEvaluar)
		posicionParaEvaluar.goRight(1)
		if(self.estaLaPelota(posicionParaEvaluar))
			pelota.patear(2*fuerzaX, fuerzaY, 1)
	}
	
	override method dibujarArco(){
		arco.dibujarALaIzquierda()
	}
	
	override method inicializar(){
		super()
		keyboard.d().onPressDo({self.derecha()})
		keyboard.a().onPressDo({self.izquierda()})
		keyboard.w().onPressDo({self.saltar()})
		keyboard.space().onPressDo({self.patear()})
		self.dibujarArco()
	}
}

object jugadorDer inherits Jugador(imagenCabeza = "messiDer.png", imagenPie = "botinIzq1.png"){
	
	override method rival() = jugadorIzq
	
	override method cambiarArco(altura,largo){
		arco.reDibujarDerecha(altura,largo)
	}
	
	override method patear(){
		posicionParaEvaluar.goTo(position.x(), position.y())
				
		pie.patear()
		
		self.acomodarPelota(-1,posicionParaEvaluar)
		posicionParaEvaluar.goLeft(1)
		if(self.estaLaPelota(posicionParaEvaluar))
			pelota.patear(2*fuerzaX, fuerzaY, -1)
	}
	
	override method dibujarArco(){
		arco.dibujarALaDerecha()
	}
	
	override method inicializar(){
		super()
		keyboard.right().onPressDo({self.derecha()})
		keyboard.left().onPressDo({self.izquierda()})
		keyboard.up().onPressDo({self.saltar()})
		keyboard.enter().onPressDo({self.patear()})
		self.dibujarArco()
	}
}

object jugadores{
	var property velEmpujeNormal = 1
	var property fuerzaXNormal = 2
	var property fuerzaYNormal = 3
	var property saltoNormal = 1.5
	
	method esGol(laPelota) = jugadorIzq.arco().esGol(laPelota) || jugadorDer.arco().esGol(laPelota)
	
	method quienGana() = if (jugadorIzq.goles() > jugadorDer.goles()) jugadorDer else if(jugadorDer.goles() > jugadorIzq.goles()) jugadorIzq
	
	method reiniciarMarcador(){
		jugadorIzq.arco().reiniciarMarcador()
		jugadorDer.arco().reiniciarMarcador()
	}
	
	method moverse() {
		jugadorIzq.moverse()
		jugadorDer.moverse()
	}
	
	method inicializar(){
		jugadorIzq.inicializar()
		jugadorDer.inicializar()
	} 
	
	method resetear(){
		jugadorIzq.resetear()
		jugadorDer.resetear()
	}
	
	method gravedad(g){
		jugadorIzq.gravedad(g)
		jugadorDer.gravedad(g)
	}
	
	method posicionesIniciales(p1,p2){
		jugadorIzq.position().posicionInicial(p1.key(),p2.value())
		jugadorDer.position().posicionInicial(p2.key(),p2.value())
	}
	
	method activarPowerUp(posicion, powerUp){
		if(jugadorIzq.estaEn(posicion))
			powerUp.activar(jugadorIzq)
		else if(jugadorDer.estaEn(posicion))
			powerUp.activar(jugadorDer)
	}
	
	method cambiarVelEmpuje(vel){
		jugadorIzq.velX(vel)
		jugadorDer.velX(vel)
	}
	
	method cambiarRozamiento(roz){
		jugadorIzq.rozamiento(roz)
		jugadorDer.rozamiento(roz)
	}
}