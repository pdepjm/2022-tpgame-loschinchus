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
	
	var property posJIzq = new Pair(x = 8, y = 0)
	var property posJDer = new Pair(x = juego.w()-8, y = 0)
	var property posPelota = new Pair(x = 15, y = 15)
	var property powerUps = [superPique, arcoMasGrande, pisoResbaloso, superFuerza, superSalto, gravedadCero]
	const cantidadPowerUps = powerUps.size()
	
	var property alturaArcos = 6
	var property largoArcos = 3
	var property duracionPartido = 1
	
	var property noEsGol = true
	
	var property gravedad = juego.g()
	
	var contadorPelotaTrabada = 0
	
	method iniciar(){
		
		temporizador.inicializar()
		jugadores.inicializar()
		jugadores.posicionesIniciales(posJIzq,posJDer)
		pelota.position().posicionInicial(posPelota.key(), posPelota.value())
		
		self.agregarElemento(pelota)
		self.agregarElemento(jugadores)
		
		game.addVisual(pelota)
		
		game.onTick(30,"Movimiento",{self.moverElementos()})
		game.onTick(1000,"Temporizador",{temporizador.actualizar()})
		game.schedule(10000.randomUpTo(40000) ,{self.agregarPowerUp()} )
		game.onTick(500, "Chequear pelota trabada", {self.chequearSiSeTraboLaPelota()})
		self.reiniciar()
	}
	method agregarPowerUp(){
		const powerUp = powerUps.get(0.randomUpTo(cantidadPowerUps-1))
		self.agregarElemento(powerUp)
		game.addVisual(powerUp)
		game.schedule(10000.randomUpTo(40000) ,{self.agregarPowerUp()} )
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
				self.reiniciar()
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
}
object jugadores{
	
	var property velEmpujeNormal = 1
	var property fuerzaXNormal = 2
	var property fuerzaYNormal = 3
	var property saltoNormal = 1.5
	
	method esGol(posicion) = jugadorIzq.arco().esGol(posicion) || jugadorDer.arco().esGol(posicion)
	method reiniciarMarcador(){
		jugadorIzq.arco().reiniciarMarcador()
		jugadorDer.arco().reiniciarMarcador()
	}
	method moverse() {
		jugadorIzq.moverse()
		jugadorDer.moverse()
		
	}
	method inicializar(){
		jugadorIzq.inicializar()
		jugadorDer.inicializar()
	} 
	method resetear(){
		jugadorIzq.resetear()
		jugadorDer.resetear()
	}
	method gravedad(g){
		jugadorIzq.gravedad(g)
		jugadorDer.gravedad(g)
	}
	method posicionesIniciales(p1,p2){
		jugadorIzq.position().posicionInicial(p1.key(),p2.value())
		jugadorDer.position().posicionInicial(p2.key(),p2.value())
	}
	method activarPowerUp(posicion, powerUp){
		if(jugadorIzq.estaEn(posicion))
			powerUp.activar(jugadorIzq)
		else if(jugadorDer.estaEn(posicion))
			powerUp.activar(jugadorDer)
	}
	method cambiarVelEmpuje(vel){
		jugadorIzq.velX(vel)
		jugadorDer.velX(vel)
	}
	method cambiarRozamiento(roz){
		jugadorIzq.rozamiento(roz)
		jugadorDer.rozamiento(roz)
	}
	
}