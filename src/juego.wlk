import wollok.game.*
import fisicas.particulas.*
import fisicas.graficos.*
import jugador.*
import mutablePosition.*
import arco.*
import marcador.*
import powerUp.*
import menu.*
import sonidos.*

object juego { //juego principal
	const property w = 30 //ancho
	const property h = 20 //alto
	const property medioX = w.div(2)
	const property medioY = h.div(2)
	const property y0 = 0 //suelo
	const property x0 = 0 //pared izq
	const property cellSize = 32
	const property g = -0.5 //valor de  gravedad
	
	method iniciar(){
		self.inicializar()
		menu.iniciar()
		game.start()
		
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
	
	var property posJIzq = new Pair(x = juego.w()/3.75, y = 0)
	var property posJDer = new Pair(x = juego.w()-juego.w().div(3.75)-1, y = 0)
	var property posPelota = new Pair(x = juego.medioX(), y = juego.medioY())
	var property powerUps = [superPique, arcoMasGrande, pisoResbaloso, superFuerza, superSalto, gravedadCero]
	var property alturaArcos = 6
	var property largoArcos = juego.w().div(10)
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
		
		sonidoPartido.cancha()
		
		game.onTick(30,"MoverElementos",{self.moverElementos()})
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
		if(pelota.velocidad().vy().truncate(0) == 0 && !pelota.estaEnElPiso()) 
			contadorPelotaTrabada++
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
		})
		if(temporizador.seAcaboElTiempo())
				self.terminar()		
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
		sonidoPartido.silbato()
		noEsGol = true
		self.resetearElementos()
	}
	
	method chequearGol(){
		if(jugadores.esGol(pelota)){
			noEsGol = false
			sonidoPartido.gol()
			game.schedule(2000, {self.saqueDelMedio()})
		}
	}
	
	method terminar(){
		sonidoPartido.final()
		sonidoPartido.detenerCancha()
		
		game.removeTickEvent("Temporizador")
		game.removeTickEvent("PowerUp")
		game.removeTickEvent("Chequear pelota trabada")
		game.removeTickEvent("MoverElementos")
		pantallaGanador.iniciar()
	}
}

object pantallaGanador{
	const ganadorImg = new Imagen(image = "ganador.png", position = new MutablePosition(x = juego.medioX()-8,y = juego.medioY() ))
	const banderinImg = new Imagen(image = "winner.png",position = new MutablePosition(x = juego.medioX()-3,y = juego.medioY()+2) )
	const fondoNegro = new Imagen (image = "fondoNegro.png")
	const empateI = new Imagen(image = "empate.png", position = new MutablePosition(x = juego.medioX()-8,y = juego.medioY() ))
	const zzz = new Imagen(image = "zzz.png", position = new MutablePosition(x = juego.medioX()-8,y = juego.medioY()-4 ))
	const presionaParaContinuar = new Imagen(image = "presioneF.png", position = new MutablePosition(x = juego.medioX()-12, y = juego.y0() ))
	var musica
	
	method ganador() = jugadores.quienGana()
	
	method iniciar(){
		keyboard.f().onPressDo({musica.stop() menu.iniciar()})
		game.addVisual(fondoNegro)
		game.schedule(50,{game.addVisual(presionaParaContinuar)})
		if (self.ganador() == null)
			self.empate()
		else
			self.ganador(self.ganador())
	}
	
	method empate(){
		musica = soundProducer.sound("rickroll.mp3")
		musica.play()
		game.schedule(50,{game.addVisual(empateI) game.addVisual(zzz)})
	}
	
	method ganador(jugador){
		musica = soundProducer.sound("ganador.mp3")
		musica.play()
		jugador.position().goTo(juego.medioX()-1, juego.medioY()-3)
		jugador.actualizarImagenes()
		game.schedule(50,{game.addVisual(ganadorImg) game.addVisual(banderinImg)})
	}
	
}

