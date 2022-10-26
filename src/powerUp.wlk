import fisicas.particulas.*
import jugador.*
import juego.*
import wollok.game.*
import sonidos.*

class PowerUp inherits Particula(image = "powerUp1.png", rebote = 0.8){
	
	
	var property duracion = 10000
	const sonido = "powerUp.mp3"
	
	
	override method resetear(){
		position.goTo(0.randomUpTo(juego.w()-1), 3.randomUpTo(juego.h()-1-6))
		velocidad.nuevaVelocidad((-2).randomUpTo(2), (-2).randomUpTo(2))
	}
	override method moverse(){
		gravedad = -0.3
		jugadores.activarPowerUp(position,self)
		
		
		var x = juego.limitarX(position.x()+velocidad.vx())
		var y = juego.limitarY(position.y()+velocidad.vy())
		
		
		
		if(x == juego.w()-1 || x == juego.x0())
			self.rebotarX()
		
		if(self.estaEnElPiso() || (y == juego.h()-1 && velocidad.vy().abs() >= 1))
			self.rebotarY()
		
		self.moverse(x.truncate(0),y.truncate(0))
		
	}
	
	method quitar(){
		partido.quitarElemento(self)
		game.removeVisual(self)
	}
	method quitarSiNoEsta(){
		if(game.hasVisual(self))
			self.quitar()
	}
	
	method activar(jugador){
		soundProducer.sound(sonido).play()
		self.quitar()
		self.efecto(jugador)
		game.schedule(duracion,{self.desactivar(jugador)})
	}
	method desactivar(jugador){
		self.deshacerEfecto(jugador)
	}
	method efecto(jugador)
	method deshacerEfecto(jugador)
}
object superPique inherits PowerUp{
	
	override method efecto(jugador){
		pelota.rebote(0.9)
	}
	override method deshacerEfecto(jugador){
		pelota.rebote(pelota.reboteNormal())
	}
}
object arcoMasGrande inherits PowerUp{
	override method efecto(jugador){
		jugador.rival().cambiarArco(partido.alturaArcos()*2, partido.largoArcos())
	}
	override method deshacerEfecto(jugador){
		jugador.rival().cambiarArco(partido.alturaArcos(), partido.largoArcos())
	}
}
object pisoResbaloso inherits PowerUp{
	override method efecto(jugador){
		jugadores.cambiarRozamiento(0.95)
		pelota.rozamiento(0.95)
	}
	override method deshacerEfecto(jugador){
		jugadores.cambiarRozamiento(0)
		pelota.rozamiento(pelota.rozamientoNormal())
	}
}

object superFuerza inherits PowerUp{
	override method efecto(jugador){
		jugador.fuerzaX(jugador.fuerzaX()*3)
		jugador.fuerzaY(jugador.fuerzaY()*2)
	}
	override method deshacerEfecto(jugador){
		jugador.fuerzaX(jugadores.fuerzaXNormal())
		jugador.fuerzaY(jugadores.fuerzaYNormal())
	}
}
object superSalto inherits PowerUp{
	override method efecto(jugador){
		jugador.salto(jugador.salto()*2)
	}
	override method deshacerEfecto(jugador){
		jugador.salto(jugadores.saltoNormal())
	}
}
object gravedadCero inherits PowerUp{
	override method efecto(jugador){
		partido.gravedad(-0.3)
	}
	override method deshacerEfecto(jugador){
		partido.gravedad(juego.g())
	}
}
