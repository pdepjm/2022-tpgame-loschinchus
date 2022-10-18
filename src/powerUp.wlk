import fisicas.particulas.*
import jugador.*
import juego.*
import wollok.game.*

class PowerUp inherits Particula(image = "powerUp1.png", rebote = 0.8){
	
	var property efecto = {aux1 = pelota.rebote() pelota.rebote(0.9)}
	var property deshacerEfecto = {pelota.rebote(aux1)}
	var property duracion = 10000
	
	var aux1 = null
	var aux2 = null
	var aux3 = null
	
	method aQuienEstaTocando(){
		const colliders = game.getObjectsIn(position)
		colliders.remove(self)
		if(colliders.isEmpty())
			return null
		if(jugadorIzq.puntos().contains(colliders.first()))
			return jugadorIzq
		if(jugadorDer.puntos().contains(colliders.first()))
			return jugadorDer
		else return null
	}
	
	override method resetear(){
		position.goTo(0.randomUpTo(juego.w()-1), 3.randomUpTo(juego.h()-1-6))
		velocidad.nuevaVelocidad(1.randomUpTo(4), 1.randomUpTo(4))
	}
	override method moverse(){
		gravedad = -0.3
		super()
		
		if(jugadorIzq.estaEn(position))
			self.activarPowerUp(jugadorIzq)
		else 
			if(jugadorDer.estaEn(position))
				self.activarPowerUp(jugadorDer)
		
	}
	
	method activarPowerUp(jugador){
		partido.elementos().remove(self)
		game.removeVisual(self)
		self.aplicarEfecto()
	}
	
	method aplicarEfecto(){
		efecto.apply()
		game.schedule(duracion,{deshacerEfecto.apply()})
	}
	
	
}
