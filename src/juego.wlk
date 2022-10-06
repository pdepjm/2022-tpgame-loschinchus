import wollok.game.*
import fisicas.particulas.*
import fisicas.graficos.*
import jugador.*
import mutablePosition.*
import arco.*

object juego { //juego principal
	const property w = 30 //ancho
	const property h = 20 //alto
	const property proporcionArco = 1/6
	const property y0 = 0 //suelo
	const property x0 = 0 //pared izq
	const property cellSize = 32
	const property g = -0.5 //valor de  gravedad
	const property elementos = []
	var property jugador1
	var property jugador2
	var property arco1
	var property arco2
	var property pelota
	
	method iniciar() {
		
		game.width(w)
		game.height(h)
		game.cellSize(cellSize)
		game.ground("grid.png")
		game.title("Juego")
		
		
		arco1 = new Arco(altura = 6, largo = 6, arcoDerecho = true)
		arco2 = new Arco(altura = 6, largo = 6, arcoDerecho = false)
		
		
		pelota = new Particula(image = "soccer_ball_32x32.png")
		game.addVisual(pelota)
		jugador1 = new Jugador(position = new MutablePosition(x = 8, y = 0), pelota = pelota)
		jugador2 = new Jugador(position = new MutablePosition(x = w-8, y = 0), pateaHaciaDerecha = false, pelota = pelota)
		
		elementos.addAll([pelota,jugador1,jugador2])
		
		keyboard.d().onPressDo({jugador1.derecha()})
		keyboard.a().onPressDo({jugador1.izquierda()})
		keyboard.w().onPressDo({jugador1.saltar()})
		keyboard.space().onPressDo({jugador1.patear()})
		
		keyboard.right().onPressDo({jugador2.derecha()})
		keyboard.left().onPressDo({jugador2.izquierda()})
		keyboard.up().onPressDo({jugador2.saltar()})
		keyboard.enter().onPressDo({jugador2.patear()})
		
		game.onTick(30,"Movimiento",{self.moverElementos()})
		
		game.start()
		
	}
	method moverElementos(){
		elementos.forEach({
			e =>
			e.gravedad(g)
			e.moverse()
		})
	}
	method limitarX(x){//previene que el parametro se salga de los limites X
		return x.limitBetween(x0,w-1)
	}
	method limitarY(y){//previene que el parametro se salga de los limites Y
		return y.limitBetween(y0,h-1)
	}
	
}

object partido{
	
}