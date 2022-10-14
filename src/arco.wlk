import fisicas.graficos.*
import juego.*
import marcador.*
class Arco{
	var property altura
	var property largo
	
	var property marcador = null
	var property inicioX = null
	var property finX = null
	
	var puntos = []
	
	method dibujarALaIzquierda(){
		inicioX = juego.x0()
		finX = inicioX+largo
		puntos =  lineDrawer.line(inicioX,altura,finX,altura,"arco.jpg")
		marcador = new Contador(x = juego.w()-1-2, y = juego.h()-1-3, haciaDerecha = true)
		finX -= 1
	}
	method dibujarALaDerecha(){
		finX = juego.w()-1
		inicioX = finX-largo
		puntos =  lineDrawer.line(inicioX,altura,finX,altura,"arco.jpg")
		marcador = new Contador(x = juego.x0()+2, y = juego.h()-1-3, haciaDerecha = false)
		inicioX += 1
	}
	
	method esGol(posicion){
		const esGol = posicion.x().between(inicioX,finX) && posicion.y().between(0,altura-1)
		if(esGol)
			marcador.aumentar()
		return esGol
	}
	
	method reiniciarMarcador(){
		marcador.reiniciar()
	}
	
}