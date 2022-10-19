import fisicas.particulas.*
import jugador.*
import juego.*
import wollok.game.*

class PowerUp inherits Particula(image = "powerUp1.png", rebote = 0.8){
	
	var property duracion = 10000
	
	override method resetear(){
		position.goTo(0.randomUpTo(juego.w()-1), 3.randomUpTo(juego.h()-1-6))
		velocidad.nuevaVelocidad(1.randomUpTo(4), 1.randomUpTo(4))
	}
	override method moverse(){
		gravedad = -0.3
		super()
		
		jugadores.activarPowerUp(position,self)
	}
	
	method activar(jugador){
		partido.quitarElemento(self)
		game.removeVisual(self)
		self.efecto(jugador)
		game.schedule(duracion,{self.deshacerEfecto(jugador)})
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
