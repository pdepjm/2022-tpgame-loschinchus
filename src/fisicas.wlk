import wollok.game.*
import particulas.*
import cuerpos.*
import marcador.*

//Para correr: "juego.iniciar()"
object juego {
	const property w = 30
	const property h = 20
	const property proporcionArco = 1/6
	const property y0 = 0
	const property x0 = 0
	const property cellSize = 32
	
	method iniciar() {
		//var cuerpoPrueba = new Cuerpo()
		//cuerpoPrueba.agregarPunto(10,15)
		//cuerpoPrueba.dibujar()
		//var particulaPrueba = new Particula(cinetica = new Cinetica(), x = 15, y = 15)
		
		//teclas jugador1
		keyboard.left().onPressDo({jugador2.izq() jugador2.empujarIzq()})
		keyboard.right().onPressDo({jugador2.der() jugador2.empujarDer()})
		keyboard.up().onPressDo({jugador2.up()})
		keyboard.enter().onPressDo({jugador2.patear()})
		jugador1.inicializarJugador()
		
		//teclas jugador2
		keyboard.a().onPressDo({jugador1.izq() jugador1.empujarDer()})
		keyboard.d().onPressDo({jugador1.der() jugador1.empujarIzq()})
		keyboard.w().onPressDo({jugador1.up()})
		keyboard.space().onPressDo({jugador1.patear()})
		jugador2.inicializarJugador()
		
		//arcos
		arco1.dibujar()
		arco2.dibujar()
		
		//caracteristicas
		game.width(w)
		game.height(h)
		game.cellSize(cellSize)
		game.ground("grid.png")
		game.title("Juego")
		game.addVisual(pelotita)
		//game.addVisual(jugador)
		game.onTick(10, "Fisicas", {motorDeFisicas.actualizar()}) //Cada 10ms se invoca al metodo que actualiza las particulas
		game.start()
		
		motorDeFisicas.agregarCuerpo(pelotita)
		motorDeFisicas.agregarCuerpo(jugador1.cuerpo())
		motorDeFisicas.agregarCuerpo(jugador2.cuerpo())
		
		
		contMin.iniciarContador()
	}
	method limitarX(x){
		return x.limitBetween(x0,w-1)
	}
	method limitarY(y){
		return y.limitBetween(y0,h-1)
	}
}

//El motor de fisicas es basicamente la ley que le dice a las particulas cuando moverse
// y ademas tiene permitido modificar sus cinematicas y cambiar su estado.
// El motor de fisicas tiene un array de particulas a traves del cual, llegado el momento
// las modificara y les ordenara moverse

object motorDeFisicas{
	var property cuerpos = []
	var property hayRozamiento = false
	var property puedePicar = true
	var property rozamiento = 0.8
	const g = -0.5
	
	method agregarCuerpo(cuerpo){cuerpos.add(cuerpo)}
	method actualizar(){
		if(cuerpos.size() > 0){
			cuerpos.forEach({ c => 
					const cineticaActual = c.cinetica()
					if(c.estaChocandoX()){//c choca una "pared", la velocidad va hacia el otro lado y es menor
						cineticaActual.nuevaVx(cineticaActual.energ_x()*(-c.rebote()))
					}
			       
		        	if(c.estaChocandoY()){	//c choca el "techo" o el "piso", la velocidad va hacia el otro lado y es menor
		        		if(cineticaActual.puedePicar()){
		        			cineticaActual.nuevaVy(cineticaActual.energ_y()*(-c.rebote()))
		        			cineticaActual.puedePicar(false)
		        		}
		        		else{
		        			cineticaActual.ay(0)
		        		}
						if(c.estaEnElPiso()){ //si choca el piso y hay rozamiento disminuye vx
							if(hayRozamiento)		
								cineticaActual.nuevaVx(cineticaActual.energ_x()*rozamiento)
								
							hayRozamiento = true //porque está en el piso
						}
					}
					else{
					//Esta en el aire, no hay rozamiento con el piso
					hayRozamiento = false
					cineticaActual.puedePicar(true)
					cineticaActual.ay(g)
					}
					
					
					cineticaActual.aplicarAceleracion()
					c.moverse()
					jugador1.moverse()
					jugador2.moverse()
						})
	   	}
	}
}
//Cada particula tiene su propia cinetica, que describe sus velocidades y aceleraciones 
//y nos proporciona metodos para modificarlas.
// El motor de fisicas se encargara de modificar la cinetica de
// las particulas y luego hacer que se muevan.
// El motor de fisicas solo modifica y ordena a las
// particulas moverse, pero el movimiento queda a cargo de
// la propia particula, quedando definido unicamente por el estado
// en que su cinetica se encuentre a la hora de moverse

class Cinetica{
	var property vx = 0
	var property vy = 0
	var property ax = 0
	var property ay = 0
	var property puedePicar = false
	var property energ_x = 0
	var property energ_y = 0
	
	//posicion
	method actualizarX(x) = juego.limitarX(x+vx) 
	method actualizarY(y) = juego.limitarY(y+vy)
	
	//velocidad
	method nuevaVelocidad(nuevaVx, nuevaVy){ 
		self.nuevaVx(nuevaVx)
		self.nuevaVy(nuevaVy)
	}
	method nuevaVx(nuevaVx){
		vx = nuevaVx
		energ_x = vx
	}
	method nuevaVy(nuevaVy){
		vy = nuevaVy
		energ_y = vy
	}
	method modificarVelocidad(aumentoX, aumentoY){ 
		vx += aumentoX
		vy += aumentoY
		energ_x = vx
		energ_y = vy
	}
	method factorVelocidad(factorx, factory){
		vx *= factorx
		vy *= factory
		energ_x = vx
		energ_y = vy
	}
	method frenar(){
		vx = 0
		vy = 0
	}
	
	//aceleracion
	method nuevaAceleracion(nuevaAx, nuevaAy){ 
		ax = nuevaAx
		ay = nuevaAy
	}
	method modificarAceleracion(aumentoX, aumentoY){ 
		ax += aumentoX
		ay += aumentoY
	}
	method factorAceleracion(factorX, factorY){
		ax *= factorX
		ay *= factorY
	}
	method aplicarAceleracion() {
		self.modificarVelocidad(ax,ay)
	}
}
