import fisicas.particulas.*
import fisicas.graficos.*
import juego.*
import wollok.game.*
import mutablePosition.*

class Jugador{
	var property pateaHaciaDerecha = true
	var property pelota 
	var property position = new MutablePosition(x = 8, y = 0)
	var property velocidad = new Velocidad()
	var property puntos = self.devolverPuntos()
	var property gravedad = juego.g()
	var property rozamiento = 0
	
	var property hayRozamiento = true
	
	var property fuerzaX = 2 //fuerza con que patea
	var property fuerzaY = 3
	
	var property velX = 1 //Velocidad de empuje
	
	var property posicionParaEvaluar = new MutablePosition()

	
	method estaEnElPiso() = position.y() == juego.y0()
	
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
	method devolverPuntos() = lineDrawer.line(position.x(),position.y(),position.x(),position.y()+2) + lineDrawer.line(position.x()+1,position.y(),position.x()+1,position.y()+2)
	method izquierda(){
		hayRozamiento = false
		self.empujar(-1)
		velocidad.agregarVelocidad(-velX,0)
	}
	method derecha(){
		hayRozamiento = false
		self.empujar(1)
		velocidad.agregarVelocidad(velX,0)
	}
	method saltar(){
		if(self.estaEnElPiso())
			velocidad.agregarVelocidad(0,1.5)
	}

	method estaLaPelota(posicion) = game.getObjectsIn(posicion).contains(pelota)
	
	method empujar(signo){
		posicionParaEvaluar.goTo(position.x(), position.y())
		
		if(signo < 0)
			posicionParaEvaluar.goLeft(1)
		else
			posicionParaEvaluar.goRight(2)
			
		if(self.estaLaPelota(posicionParaEvaluar))
			pelota.velocidad().agregarVelocidad(signo*fuerzaX + velocidad.vx(), 0)
		
	}
	method patear(){
		posicionParaEvaluar.goTo(position.x(), position.y())
			
		if(pateaHaciaDerecha){
			posicionParaEvaluar.goRight(1)
			if(self.estaLaPelota(posicionParaEvaluar) || self.estaLaPelota(posicionParaEvaluar.right(1)))
				pelota.patear(2*fuerzaX, fuerzaY, 1)
		}
		else{
			
			if(self.estaLaPelota(posicionParaEvaluar) || self.estaLaPelota(posicionParaEvaluar.left(1)) )
				pelota.patear(2*fuerzaX, fuerzaY, -1)
		}
	}
	
}
