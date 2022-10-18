import wollok.game.*
import fisicas.particulas.*
import fisicas.graficos.*
import jugador.*
import mutablePosition.*
import arco.*
import marcador.*
import powerUp.*

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
	
	var property alturaArcos = 6
	var property largoArcos = 3
	var property duracionPartido = 1
	
	var property noEsGol = true
	
	var contadorPelotaTrabada = 0
	
	method iniciar(){
		arco1 = new Arco(altura = alturaArcos, largo = largoArcos)
		arco2 = new Arco(altura = alturaArcos, largo = largoArcos)
		
		arco1.dibujarALaIzquierda()
		arco2.dibujarALaDerecha()
		
		temporizador.inicializar()
		
		pelota.position().posicionInicial(posPelota.key(), posPelota.value())
		jugadorIzq.position().posicionInicial(posJ1.key(), posJ1.value())
		jugadorDer.position().posicionInicial(posJ2.key(), posJ2.value())
		
		const powerUp = new PowerUp()
		powerUp.position().posicionInicial(14,15)
		
		elementos.addAll([pelota,jugadorIzq,jugadorDer, powerUp])
		
		game.addVisual(pelota)
		game.addVisual(powerUp)
		
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
		game.onTick(500, "Chequear pelota trabada", {self.chequearSiSeTraboLaPelota()})
		self.reiniciar()
	}
	method chequearSiSeTraboLaPelota(){
		if(pelota.velocidad().vy().truncate(0) == 0 && !pelota.estaEnElPiso()){
			contadorPelotaTrabada++
		}
		else
			contadorPelotaTrabada = 0
		
		if(contadorPelotaTrabada >= 3)
			self.saqueDelMedio()
		
	}
	method moverElementos(){
		elementos.forEach({
			e =>
			e.gravedad(juego.g())
			e.moverse()
			if(noEsGol)
				self.chequearGol()
			if(temporizador.seAcaboElTiempo())
				self.reiniciar()
		})
	}
	method resetearElementos(){
		elementos.forEach({e => 
			e.resetear()
		})
	}
	method reiniciar(){
		self.saqueDelMedio()
		arco1.reiniciarMarcador()
		arco2.reiniciarMarcador()
		temporizador.resetear(duracionPartido)
	}
	method saqueDelMedio(){
		noEsGol = true
		self.resetearElementos()
	}
	method chequearGol(){
		const posicionPelota = pelota.position()
		if((arco1.esGol(posicionPelota) || arco2.esGol(posicionPelota))){
			noEsGol = false
			game.schedule(2000, {self.saqueDelMedio()})
		}
	}
}