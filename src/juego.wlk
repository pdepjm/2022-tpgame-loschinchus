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
		game.boardGround("background.png")
		
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
	var property arco1
	var property arco2	
	var property posJ1 = new Pair(x = 8, y = 0)
	var property posJ2 = new Pair(x = juego.w()-8, y = 0)
	var property posPelota = new Pair(x = 15, y = 15)
	
	method iniciar(){
		arco1 = new Arco(altura = 6, largo = 3)
		arco2 = new Arco(altura = 6, largo = 3)
		
		arco1.dibujarALaIzquierda()
		arco2.dibujarALaDerecha()
		
		temporizador.inicializar()
		
		pelota.position().goTo(posPelota.key(), posPelota.value())
		elementos.addAll([pelota,jugadorIzq,jugadorDer])
		
		game.addVisual(pelota)
		
		keyboard.d().onPressDo({jugadorIzq.derecha()})
		keyboard.a().onPressDo({jugadorIzq.izquierda()})
		keyboard.w().onPressDo({jugadorIzq.saltar()})
		keyboard.space().onPressDo({jugadorIzq.patear()})
		
		keyboard.right().onPressDo({jugadorDer.derecha()})
		keyboard.left().onPressDo({jugadorDer.izquierda()})
		keyboard.up().onPressDo({jugadorDer.saltar()})
		keyboard.enter().onPressDo({jugadorDer.patear()})
		
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
		arco1.reiniciarMarcador()
		arco2.reiniciarMarcador()
		temporizador.resetear(1)
	}
	method saqueDelMedio(){
		self.resetearElemento(pelota,posPelota)
		self.resetearElemento(jugadorIzq,posJ1)
		self.resetearElemento(jugadorDer,posJ2)
	}
	method chequearGol(){
		const posicionPelota = pelota.position()
		if(arco1.esGol(posicionPelota) || arco2.esGol(posicionPelota)){
			game.removeTickEvent("Movimiento")
			game.schedule(1000, { game.onTick(30,"Movimiento",{self.moverElementos()})})
			self.saqueDelMedio()
		}
	}
}