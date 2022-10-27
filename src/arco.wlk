import fisicas.graficos.*
import juego.*
import marcador.*
import wollok.game.*

class Arco{
	var property altura
	var property largo
	var property marcador = null
	var property inicioX = null
	var property finX = null
	var puntos = []
	var yaSeContoElGol = false
	
	method dibujarALaIzquierda(){
		const inicio = juego.w()-1-2
		inicioX = inicio+1
		self.dibujar(juego.x0(),juego.x0()+largo)
		marcador = new Contador(x =inicio, y = juego.h()-1-3, haciaDerecha = true)
	}
	
	method dibujarALaDerecha(){
		const inicio = juego.x0()+2
		inicioX = inicio-1
		self.dibujar(juego.w()-1-largo, juego.w()-1)
		marcador = new Contador(x = inicio, y = juego.h()-1-3, haciaDerecha = false)
	}
	
	method dibujar(inicio,fin){
		inicioX = inicio
		finX = fin
		puntos =  lineDrawer.dibujarImagenes(inicioX,altura,finX,altura,"arco.jpg")
	}
	
	method esGol(pelota){
		const esGol = pelota.position().x().between(inicioX,finX) && pelota.position().y().between(0,altura-1)
		if(esGol){
			if(!yaSeContoElGol){
				marcador.aumentar() 
				yaSeContoElGol = true
			}
		}
		else
			yaSeContoElGol = false
		return esGol
	}
	
	method reiniciarMarcador(){
		marcador.reiniciar()
	}
	
	method reDibujarIzquierda(nuevoAlto, nuevoLargo){
		puntos.forEach({p => game.removeVisual(p)})
		altura = nuevoAlto
		largo = nuevoLargo
		self.dibujar(juego.x0(), juego.x0()+largo)
	}
	
	method reDibujarDerecha(nuevoAlto, nuevoLargo){
		puntos.forEach({p => game.removeVisual(p)})
		altura = nuevoAlto
		largo = nuevoLargo
		self.dibujar(juego.w()-1-largo, juego.w()-1)
	}
}