import fisicas.*
import cuerpos.*
import wollok.game.*

class Puntito{
	var property x
	var property y
	method position() = game.at(x,y)
	method image() = "circle_10x10.png"
}
class Punto{
	var property x
	var property y
	method position() = game.at(x,y)
	method image() = "circle_32x32.png"
}

class Particula{
	var property x
	var property y
	var property position = game.at(x,y)
	var property cinetica
	var property rebote = 0
	var property colisionar = {}
	var property image = "circle_32x32.png"
	
	method estaChocandoX() = x == juego.x0() || x == juego.w()-1 || game.getObjectsIn(position).size() > 1
	method estaChocandoY() = self.estaEnElPiso() || y == juego.h()-1
	method estaEnElPiso() = y == juego.y0()
	method posicionOcupada(i,j) = game.getObjectsIn(game.at(i,j)).size() > 0
	
	method hacerBlanca(){
		image = "circle_32x32.png" 
	}
	method hacerAzul(){
		image = "circle_blue_32x32.png" 
	}
	
	method moverse(){
		self.evaluarChoques()
		x = cinetica.actualizarX(x)
		y = cinetica.actualizarY(y)
		position = game.at(x,y)
	}
	method moverse(vx,vy){
		x = juego.limitarX(x+vx)
		y = juego.limitarY(y+vy)
		position = game.at(x,y)
	}
	
	method evaluarChoques(){
		if 		(x+cinetica.vx() < juego.x0()) 			cinetica.vx(-x)
		else if (x+cinetica.vx() > juego.w()) 	cinetica.vx(juego.w() - x)
		if 		(y+cinetica.vy() < juego.y0()) 			cinetica.vy(-y)
		else if	(y+cinetica.vy() > juego.h())	cinetica.vy(juego.h()-y)
	}
}

//pelotas
object pelota{
	var property cuerpoCollider = new Cuerpo()
	var property position = game.at(8,15)
	var property radio = 64
	var property size = radio / juego.cellSize()
	
	method inicializarPelota(){
		cuerpoCollider.agregarSegmentoFy(10,15,10,18)
		cuerpoCollider.agregarSegmentoFy(9,15,9,18)
		cuerpoCollider.agregarSegmentoFy(8,16,8,17)
		cuerpoCollider.agregarSegmentoFy(11,16,11,17)
		cuerpoCollider.dibujar()
		game.addVisual(self)
	}
	//method image() = "soccer_ball_128x128.png"
	method moverse(){
		position = position.up(cuerpoCollider.dyPartLider())
		position = position.right(cuerpoCollider.dxPartLider())
	}
}

object pelotita inherits Particula(cinetica = new Cinetica(), x = 15, y = 15, rebote = 0.8){
	override method evaluarChoques(){
		super()
		var vy = cinetica.vy()
		var vx = cinetica.vx()
		if(vx.abs() > 1 || vy.abs() > 1){
			var signoY = 1
			if(vy < 0)
				signoY = -1
			var noSeEncontroChoque = true
			if(vx == 0){
				vy.abs().times({i =>
					const nuevaY = y+i*signoY
					if(noSeEncontroChoque && self.posicionOcupada(x,nuevaY)){
						cinetica.vy(nuevaY) 
						noSeEncontroChoque = false
					}
				})
			}
			else{
				
				var signoX = 1
				if(vx < 0)
					signoX = -1
				const m = vy / vx
				const expr = {t => m*(t-x) + y}
				vx.abs().times({i =>
					const dx = i*signoX
					const nuevaX = x+dx
					const nuevaY = expr.apply(nuevaX)
					if(noSeEncontroChoque && self.posicionOcupada(nuevaX,nuevaY)){
						cinetica.vx(dx)
						cinetica.vy(nuevaY - y)
						noSeEncontroChoque = false
					}
				})
				
			}
			
		}
	}
	
	override method estaChocandoY() = super() || game.getObjectsIn(position).size() > 1
}

//jugadores
class Jugador{
	var property vx = 2
	var property vy = 0
	var property x = 3
	var property y = 0
	var property position = game.at(x,y)
	var property partLider = null
	var property cuerpo = new Cuerpo()
	method image() = "jugador.png"
	
	method inicializarJugador(){
		cuerpo.agregarSegmentoFy(x,y,x,y+2)
		cuerpo.agregarSegmentoFy(x+1,y,x+1,y+2)
		cuerpo.dibujar()
		partLider = game.getObjectsIn(position).first()
	}
	
	method moverse(){
		x += cuerpo.dxPartLider()
		y += cuerpo.dyPartLider()
	}
	
	method empujarDer(){
		const obj = game.getObjectsIn(position.right(1)) + game.getObjectsIn(position)
		if(obj.contains(pelotita)){
			pelotita.cinetica().modificarVelocidad(vx, vy)
		}
	}
	
	method empujarIzq(){
		const obj = game.getObjectsIn(position.right(1)) + game.getObjectsIn(position)
		if(obj.contains(pelotita)){
			pelotita.cinetica().modificarVelocidad(-vx, vy)
		}
	}
	
	method izq(){
		cuerpo.moverse(-1,0)
		position = game.at(partLider.x(),partLider.y())
	}
	method der(){
		cuerpo.moverse(1,0)
		position = game.at(partLider.x(), partLider.y())
	}
	method up(){
		if(cuerpo.estaEnElPiso())
			cuerpo.cinetica().nuevaVy(2)
	}
}

object jugador1 inherits Jugador{
	method patear(){
		const obj = game.getObjectsIn(position.right(1)) + game.getObjectsIn(position.right(2))
		if (obj.contains(pelotita)) pelotita.cinetica().nuevaVelocidad(2*vx, 4+vy)
	}	
}

object jugador2 inherits Jugador(vx = -2, x = 25){
	method patear(){
		const obj = game.getObjectsIn(position.left(1)) + game.getObjectsIn(position)
		if (obj.contains(pelotita)) pelotita.cinetica().nuevaVelocidad(2*vx, 4+vy)
	}	
}