import wollok.game.*
import fisicas.particulas.*
import fisicas.graficos.*
import jugador.*
import mutablePosition.*
import arco.*
import marcador.*
import powerUp.*
import menu.*

object juego { //juego principal
	const property w = 30 //ancho
	const property h = 20 //alto
<<<<<<< HEAD
=======
	
	const property medioX = w.div(2)
	const property medioY = h.div(2)
	
>>>>>>> branch 'master' of https://github.com/pdepjm/2022-tpgame-loschinchus.git
	const property y0 = 0 //suelo
	const property x0 = 0 //pared izq
	const property cellSize = 32
	const property g = -0.5 //valor de  gravedad
	
	
	
	method iniciar(){
		self.inicializar()
		game.start()
		//partido.iniciar()
		
		menu.iniciar()
	}
	
	method inicializar() {
		
		game.width(w)
		game.height(h)
		game.cellSize(cellSize)
		game.ground("grid.png")
		game.title("Juego")
		game.boardGround("background.png")
		menu.inicializar()
		
	}
	
	method limitarX(x){//previene que el parametro se salga de los limites X
		return x.limitBetween(x0,w-1)
	}
	method limitarY(y){//previene que el parametro se salga de los limites Y
		return y.limitBetween(y0,h-1)
	}
	
}

object partido{
	const property elementos = #{}
	
	var property posJIzq = new Pair(x = 8, y = 0)
	var property posJDer = new Pair(x = juego.w()-8, y = 0)
	var property posPelota = new Pair(x = 15, y = 15)
	var property powerUps = [superPique, arcoMasGrande, pisoResbaloso, superFuerza, superSalto, gravedadCero]
	var property alturaArcos = 6
	var property largoArcos = 3
	var property duracionPartido = 1
	
	var property noEsGol = true
	
	var property gravedad = juego.g()
	
	var contadorPelotaTrabada = 0
	
	method iniciar(){
		game.clear()
		temporizador.inicializar()
		jugadores.inicializar()
		jugadores.posicionesIniciales(posJIzq,posJDer)
		pelota.position().posicionInicial(posPelota.key(), posPelota.value())
		
		self.agregarElemento(pelota)
		self.agregarElemento(jugadores)
		game.addVisual(pelota)
		
		game.onTick(30,"Movimiento",{self.moverElementos()})
		game.onTick(1000,"Temporizador",{temporizador.actualizar()})
		game.onTick(10000.randomUpTo(40000),"PowerUp",{self.agregarPowerUp()} )
		game.onTick(500, "Chequear pelota trabada", {self.chequearSiSeTraboLaPelota()})
		self.reiniciar()
	}
	method agregarPowerUp(){
		const powerUp = powerUps.get(0.randomUpTo(powerUps.size()-1))
		powerUp.resetear()
		if(!elementos.contains(powerUp))
			game.addVisual(powerUp)
		self.agregarElemento(powerUp)
		
		game.schedule(20000 ,{powerUp.quitarSiNoEsta()} )
		game.removeTickEvent("PowerUp")
		game.onTick(10000.randomUpTo(40000),"PowerUp",{self.agregarPowerUp()} )
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
			e.gravedad(gravedad)
			e.moverse()
			if(noEsGol)
				self.chequearGol()
			if(temporizador.seAcaboElTiempo())
				game.schedule(1000,{self.terminar()})
		})
	}
	method agregarElemento(e){
		elementos.add(e)
	}
	method quitarElemento(e){
		elementos.remove(e)
	}
	method resetearElementos(){
		elementos.forEach({e => 
			e.resetear()
		})
	}
	method reiniciar(){
		self.saqueDelMedio()
		jugadores.reiniciarMarcador()
		temporizador.resetear(duracionPartido)
	}
	method saqueDelMedio(){
		noEsGol = true
		self.resetearElementos()
	}
	method chequearGol(){
		const posicionPelota = pelota.position()
		if(jugadores.esGol(posicionPelota)){
			noEsGol = false
			game.schedule(2000, {self.saqueDelMedio()})
		}
	}
	method terminar(){
		game.removeTickEvent("Movimiento")
		game.removeTickEvent("Temporizador")
		game.removeTickEvent("PowerUp")
		game.removeTickEvent("Chequear pelota trabada")
		
		menu.iniciar()
	}
}

