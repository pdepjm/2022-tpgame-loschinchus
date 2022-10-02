import fisicas.*
import wollok.game.*
import particulas.*

class Funcion{
	var property expresion = {x => x}
	var var_ind = "x"
	var min = 0
	var max = 0
	
	method devolverPuntos(){
		const puntos = []
		const cantidadPuntos = max - min + 1
		cantidadPuntos.times({ vez =>
			if(var_ind == "x")
				puntos.add(new Pair(x = min, y = expresion.apply(min)) )
			else
				puntos.add(new Pair(x = expresion.apply(min), y = min) )
			min += 1                   })
		return puntos
	}
}

class Cuerpo{
	var property funciones = []
	var property puntos = []
	var property particulas = []
	var property particulaLider = null
	var property dxPartLider = 0
	var property dyPartLider = 0
	var property rebote = 0
	
	var property cinetica = new Cinetica()
	
	method agregarFuncionFx(exp, mn, mx){
		funciones.add(new Funcion(expresion = exp, min = mn, max = mx))
	}
	method agregarFuncionFy(exp, mn, mx){
		funciones.add(new Funcion(expresion = exp, min = mn, max = mx, var_ind="y"))
	}
	
	method agregarCirculo(r, centroX, centroY){
		self.agregarFuncionFx({x => (r**2 - (x-centroX)**2).squareRoot() + centroY}, 0.max(centroX-r), juego.w().min(centroX+r))
		self.agregarFuncionFx({x => -(r**2 - (x-centroX)**2).squareRoot() + centroY}, 0.max(centroX-r), juego.w().min(centroX+r))
	}
	method agregarRecta(m,b){
		self.agregarFuncionFx({x => m*x + b }, 0, juego.w())
	}
	method agregarSegmentoFx(x1,y1,x2,y2){
		self.agregarFuncionFx({x => ( (y2-y1)/(x2-x1) )*(x-x1) + y1 }, x1, x2)
	}
	method agregarSegmentoFy(x1,y1,x2,y2){
		self.agregarFuncionFy({y => ( (x2-x1)/(y2-y1) )*(y-y1) + x1 }, y1, y2)
	}
	method agregarPunto(x,y){
		puntos.add(new Pair(x=x, y=y))
	}
	
	method dibujar(){
		if(funciones.size() > 0)
			funciones.forEach({f => puntos = puntos + f.devolverPuntos()})
		if(puntos.size() > 0)
			puntos.forEach({par =>
				const p = new Particula(x = par.key(), y = par.value(), cinetica = cinetica)
				particulas.add(p)
				game.addVisual(p)   })
		particulaLider = particulas.first()
	}
	
	method moverse(){
		cinetica.aplicarAceleracion()
		dxPartLider = -particulaLider.x()
		dyPartLider = -particulaLider.y()
		particulaLider.moverse()
		dxPartLider += particulaLider.x()
		dyPartLider += particulaLider.y()
		
		particulas.forEach({p => if(!(p == particulaLider)) p.moverse(dxPartLider, dyPartLider)})
	}
	
	method moverse(dx,dy){
		particulaLider.moverse(dx,dy)
		particulas.forEach({p => if(!(p == particulaLider)) p.moverse(dx, dy)})
	}
	
	method estaChocandoX(){
		const chocanX = particulas.filter({p => p.estaChocandoX()})
		if(chocanX.size() > 0){ //alguna particula choca
			if(self.estaEnElPiso())
				self.estaChocandoY()
			else
				particulaLider = chocanX.first()
			
			return true
		}
		return false
	}
	
	method estaChocandoY() {
		const chocanY = particulas.filter({p => p.estaChocandoY()})
		if(chocanY.size() > 0){ //alguna particula choca
			if(!chocanY.contains(pelotita)) 
				particulaLider = chocanY.first() 
			return true
		}
		return false
	}
	
	method estaEnElPiso() = particulas.any({p => p.estaEnElPiso()})
}
class Arco{
	var property cuerpo = new Cuerpo()
	var property alto = 6
	var property ancho = juego.w()*juego.proporcionArco()
}
object arco1 inherits Arco{
	method dibujar(){
		cuerpo.agregarSegmentoFx(juego.x0(),alto,juego.x0()+ancho,alto)
		cuerpo.dibujar()
	}
}
object arco2 inherits Arco{
	method dibujar(){
		cuerpo.agregarSegmentoFx(juego.w()-ancho,alto,juego.w(),alto)
		cuerpo.dibujar()
	}
}
