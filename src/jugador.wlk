import fisicas.particulas.*
import fisicas.graficos.*
import juego.*
import wollok.game.*
import mutablePosition.*



class Jugador{
	var property pateaHaciaDerecha = true
	var property position = new MutablePosition(x = 8, y = 0)
	var property velocidad = new Velocidad()
	var property puntos = self.devolverPuntos()
	var property gravedad = juego.g()
	var property rozamiento = 0
	
	var property imagenCabeza
	//var property imagenPie
	
	var property hayRozamiento = true
	
	var property fuerzaX = 2 //fuerza con que patea
	var property fuerzaY = 3
	
	var property velX = 1 //Velocidad de empuje
	
	const posicionParaEvaluar = new MutablePosition()
	
	const posicionCabeza = new MutablePosition(x = position.x(), y = position.y()+1)
	
	const cabeza = {const img = new Imagen(position = posicionCabeza, image = imagenCabeza) game.addVisual(img) return img}.apply()
	//const pie = self.inicializarImagen(imagenPie, position)

	
	method cambiarCabeza(imagen){
		cabeza.cambiarImagen(imagen)
	}
	method cambiarPie(imagen){
		//pie.cambiarImagen(imagen)
	}

	method moverVisuales(){
		cabeza.moverse(velocidad)
		//imagenPie.moverse(velocidad)
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
		self.moverVisuales()
		
		hayRozamiento = true
		
	}
	method moverse(x,y){
		puntos.forEach( {
			p =>
			game.removeVisual(p)
		}
		)
		position.goTo(x,y)
		posicionCabeza.goTo(x,y+1)
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
		self.empujarPelota(-1)
		velocidad.nuevaVelocidad(-velX,0)
	}
	method derecha(){
		hayRozamiento = false
		self.empujarPelota(1)
		velocidad.nuevaVelocidad(velX,0)
	}
	method saltar(){
		if(self.estaEnElPiso())
			velocidad.agregarVelocidad(0,1.5)
	}

	method estaLaPelota(posicion) = game.getObjectsIn(posicion).contains(pelota)
	
	method empujarPelota(signo){
		posicionParaEvaluar.goTo(position.x(), position.y())
		
		if(signo < 0)
			posicionParaEvaluar.goLeft(1)
		else
			posicionParaEvaluar.goRight(2)
			
		if(self.estaLaPelota(posicionParaEvaluar))
			pelota.velocidad().agregarVelocidad(signo*fuerzaX + velocidad.vx(), 0)
		
	}
	method patear()
	
}


object jugadorIzq inherits Jugador(imagenCabeza = "Messi.png"){

	method estaLaPelotaAlLado() = self.estaLaPelota(posicionParaEvaluar) || self.estaLaPelota(posicionParaEvaluar.right(1))
	
	override method patear(){
		posicionParaEvaluar.goTo(position.x(), position.y())
		posicionParaEvaluar.goRight(1)
		
		if(self.estaLaPelotaAlLado())
			pelota.patear(2*fuerzaX, fuerzaY, 1)
	
	}
}
object jugadorDer inherits Jugador(imagenCabeza = "Messi.png"){
	method estaLaPelotaAlLado() = self.estaLaPelota(posicionParaEvaluar) || self.estaLaPelota(posicionParaEvaluar.left(1))
	
	override method patear(){
		posicionParaEvaluar.goTo(position.x(), position.y())

		if(self.estaLaPelotaAlLado())
			pelota.patear(2*fuerzaX, fuerzaY, -1)
	}
}