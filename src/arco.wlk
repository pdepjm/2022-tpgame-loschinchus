import fisicas.graficos.*
import juego.*

class Arco{
	var property altura
	var property largo
	var property arcoDerecho
	
	var property inicioX = null
	var property finX = null
	var signoX = 1
	
	const puntos = self.dibujarArco()
	
	method dibujarArco(){
		if(arcoDerecho){
			inicioX = juego.x0()
			finX = inicioX+largo
			lineDrawer.imagen("arco.jpg")
			const listaPuntos =  lineDrawer.line(inicioX,altura,finX,altura)
			lineDrawer.imagen("circle_32x32.png")
			return listaPuntos
		}
		else{
			signoX = -1
			finX = juego.w()-1
			inicioX = finX-largo
			lineDrawer.imagen("arco.jpg")
			const listaPuntos =  lineDrawer.line(inicioX,altura,finX,altura)
			lineDrawer.imagen("circle_32x32.png")
			return listaPuntos
		}
	}
	
	method estaAdentro(posicion) = posicion.x().between(inicioX,finX-signoX) && posicion.y().between(0,altura-1)
	
}