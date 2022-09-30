import wollok.game.*
import particulas.*
import cuerpos.*
object juego {//Para correr el juego hay que poner "juego.iniciar()" y despues "motorDeFisicas.agregarParticula(pelota)"
	const property w = 20
	const property h = 20
	const property cellSize = 32
	
	
	method iniciar() {
		var cuerpoPrueba = new Cuerpo()
		cuerpoPrueba.agregarPunto(10,15)
		cuerpoPrueba.dibujar()
		game.width(w)
		game.height(h)
		game.cellSize(cellSize)
		game.ground("grid.png")
		game.title("Juego")
		//game.addVisual(pelota)
		game.onTick(10, "Fisicas", { motorDeFisicas.actualizarCuerpos() }) //Cada 25ms se invoca al metodo que actualiza las particulas
		
		//pelota.inicializarPelota()
		
		game.start()
		
		//motorDeFisicas.agregarCuerpo(pelota.cuerpoCollider())
		motorDeFisicas.agregarCuerpo(cuerpoPrueba)
		
	}
}

//El motor de fisicas es basicamente la ley que le dice a las particulas cuando moverse
// y ademas tiene permitido modificar sus cinematicas y cambiar su estado.
// El motor de fisicas tiene un array de particulas a traves del cual, llegado el momento
// las modificara y les ordenara moverse

object motorDeFisicas{
	var property particulas = []
	var property cuerpos = []
	var hay_rozamiento = false
	const g = -0.5
	method agregarParticula(particula){
		particulas.add(particula)
	}
	method agregarCuerpo(cuerpo){
		cuerpos.add(cuerpo)
	}
	method actualizarCuerpos(){
		if(cuerpos.size() > 0){
			
			cuerpos.forEach({ 
				c => 
					if(c.estaChocandoX())
							c.cinetica().cambiarVx(c.cinetica().energ_x()*(-0.8))
					else if(c.estaChocandoY()){
							c.cinetica().cambiarVy(c.cinetica().energ_y()*(-0.8))
							if(c.estaEnElPiso()){
								if(hay_rozamiento) 
									c.cinetica().cambiarVx(c.cinetica().energ_x()*(0.8))
								hay_rozamiento = true
							}
						}
	
					else{
						hay_rozamiento = false
						c.cinetica().ay(g)
					}
					c.moverse()
					pelota.moverse()
			})
		}
	}
	
}

//Cada particula tiene su propia cinetica.
//Esta describe sus velocidades y sus aceleraciones 
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
	var property energ_x = 0
	var property energ_y = 0
	

	
	method actualizarX(x) = 0.max(juego.w().min(x+vx))
	method actualizarY(y) = 0.max(juego.h().min(y+vy))
	
	method cambiarVelocidad(nuevaVx, nuevaVy){ 
		vx = nuevaVx
		vy = nuevaVy
		energ_x = vx
		energ_y = vy
	}
	method cambiarVx(nuevaVx){
		vx = nuevaVx
		energ_x = vx
	}
	method cambiarVy(nuevaVy){
		vy = nuevaVy
		energ_y = vy
	}
	method aumentarVelocidad(aumentoX, aumentoY){ 
		vx += aumentoX
		vy += aumentoY
		energ_x = vx
		energ_y = vy
	}
	method disminuirVelocidad(aumentoX, aumentoY){ 
		vx -= aumentoX
		vy -= aumentoY
		energ_x = vx
		energ_y = vy
	}
	method factorVelocidad(factor){
		vx *= factor
		vy *= factor
		energ_x = vx
		energ_y = vy
	}
	method factorVelocidad(factorx, factory){
		vx *= factorx
		vy *= factory
		energ_x = vx
		energ_y = vy
	}
	method frenar() {
		vx = 0
		vy = 0
	}
	
	method cambiarAceleracion(nuevaAx, nuevaAy){ 
		ax = nuevaAx
		ay = nuevaAy
	}
	method aumentarAceleracion(aumentoX, aumentoY){ 
		ax += aumentoX
		ay += aumentoY
	}
	method disminuirAceleracion(aumentoX, aumentoY){ 
		ax -= aumentoX
		ay -= aumentoY
	}
	method factorAceleracion(factor){
		ax *= factor
		ay *= factor
	}
	method factorAceleracion(factorX, factorY){
		ax *= factorX
		ay *= factorY
	}
	method aplicarAceleracion() {
		vx += ax
		vy += ay
		energ_x = vx
		energ_y = vy
	}
	
}
