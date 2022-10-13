import wollok.game.*
import fisicas.particulas.*
import fisicas.graficos.*
import jugador.*
import mutablePosition.*
import arco.*
import marcador.*

object juego { //juego principal
	const property w = 30 //ancho
	const property h = 20 //alto
	const property proporcionArco = 1/6
	const property y0 = 0 //suelo
	const property x0 = 0 //pared izq
	const property cellSize = 32
	const property g = -0.5 //valor de  gravedad
	
	
	
	method iniciar(){
		self.inicializar()
		partido.iniciar()
		game.start()
	}
	
	method inicializar() {
		
		game.width(w)
		game.height(h)
		game.cellSize(cellSize)
		game.ground("grid.png")
		game.title("Juego")
		game.boardGround("playa.jpg")
		
	}
	
	method limitarX(x){//previene que el parametro se salga de los limites X
		return x.limitBetween(x0,w-1)
	}
	method limitarY(y){//previene que el parametro se salga de los limites Y
		return y.limitBetween(y0,h-1)
	}
	
}

object partido{
	const property elementos = []
	var property jugador1
	var property jugador2
	var property marcador1
	var property marcador2
	var property arco1
	var property arco2
	var property pelota
	
	var property posJ1 = new Pair(x = 8, y = 0)
	var property posJ2 = new Pair(x = juego.w()-8, y = 0)
	var property posPelota = new Pair(x = 15, y = 15)
	
	method iniciar(){
		arco1 = new Arco(altura = 6, largo = 3, arcoDerecho = true)
		arco2 = new Arco(altura = 6, largo = 3, arcoDerecho = false)
		
		temporizador.inicializar()
		
		pelota = new Pelota()
		pelota.position().goTo(posPelota.key(), posPelota.value())

		jugador1 = new Jugador(position = new MutablePosition(x = posJ1.key(), y = posJ1.value()), pelota = pelota)
		jugador2 = new Jugador(position = new MutablePosition(x = posJ2.key(), y = posJ2.value()), pateaHaciaDerecha = false, pelota = pelota)
		
		marcador1 = new Contador(x = 3, y = 15)
		marcador2 = new Contador(x = juego.w()-1-3, y = 15)
		
		elementos.addAll([pelota,jugador1,jugador2])
		
		game.addVisual(pelota)
		
		keyboard.d().onPressDo({jugador1.derecha()})
		keyboard.a().onPressDo({jugador1.izquierda()})
		keyboard.w().onPressDo({jugador1.saltar()})
		keyboard.space().onPressDo({jugador1.patear()})
		
		keyboard.right().onPressDo({jugador2.derecha()})
		keyboard.left().onPressDo({jugador2.izquierda()})
		keyboard.up().onPressDo({jugador2.saltar()})
		keyboard.enter().onPressDo({jugador2.patear()})
		
		game.onTick(30,"Movimiento",{self.moverElementos()})
		game.onTick(1000,"Temporizador",{temporizador.actualizar()})
		self.reiniciar()
	}
	method moverElementos(){
		elementos.forEach({
			e =>
			e.gravedad(juego.g())
			e.moverse()
			self.chequearGol()
			if(temporizador.seAcaboElTiempo())
				self.reiniciar()
		})
	}
	method resetearElemento(objeto, posicionInicial){
		objeto.velocidad().nuevaVelocidad(0,0)
		objeto.moverse(posicionInicial.key(), posicionInicial.value())
	}
	method reiniciar(){
		self.saqueDelMedio()
		marcador1.reiniciar()
		marcador2.reiniciar()
		temporizador.resetear(1)
	}
	method saqueDelMedio(){
		self.resetearElemento(pelota,posPelota)
		self.resetearElemento(jugador1,posJ1)
		self.resetearElemento(jugador2,posJ2)
	}
	method chequearGol(){
		if(arco1.estaAdentro(pelota.position())){
			marcador1.aumentar()
			self.saqueDelMedio()
		}
		else if(arco2.estaAdentro(pelota.position())){
			marcador2.aumentar()
			self.saqueDelMedio()
		}
	}
}