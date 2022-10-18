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
	var property imagenPie
	
	var property hayRozamiento = true
	
	var property fuerzaX = 2 //fuerza con que patea
	var property fuerzaY = 3
	
	var property velX = 1 //Velocidad de empuje
	
	const posicionParaEvaluar = new MutablePosition()
	
	const cabeza = {const img = new Imagen(position = position, image = imagenCabeza) game.addVisual(img) return img}.apply()
	const pie = {const img = new Imagen(position = position, image = imagenPie) game.addVisual(img) return img}.apply()

	
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
		puntos.forEach( {
			p =>
			game.removeVisual(p)
		}
		)
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


object jugadorIzq inherits Jugador(imagenCabeza = "messiIzq.png", imagenPie = "botinDer1.png"){

	method estaLaPelotaAlLado() = self.estaLaPelota(posicionParaEvaluar) || self.estaLaPelota(posicionParaEvaluar.right(1))
	
	override method patear(){
		posicionParaEvaluar.goTo(position.x(), position.y())
		posicionParaEvaluar.goRight(1)
		
		self.cambiarPie("botinDer1Patear.png")
		game.schedule(30,{self.cambiarPie(imagenPie)})
		
		if(self.estaLaPelotaAlLado())
			pelota.patear(2*fuerzaX, fuerzaY, 1)
	
	}
}
object jugadorDer inherits Jugador(imagenCabeza = "messiDer.png", imagenPie = "botinIzq1.png"){
	method estaLaPelotaAlLado() = self.estaLaPelota(posicionParaEvaluar) || self.estaLaPelota(posicionParaEvaluar.left(1))
	
	override method patear(){
		posicionParaEvaluar.goTo(position.x(), position.y())
		self.cambiarPie("botinIzq1Patear.png")
		game.schedule(30,{self.cambiarPie(imagenPie)})
		if(self.estaLaPelotaAlLado())
			pelota.patear(2*fuerzaX, fuerzaY, -1)
	}
}