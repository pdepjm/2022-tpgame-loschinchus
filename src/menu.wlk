import wollok.game.*
import juego.*
import jugador.*
import fisicas.graficos.*
import mutablePosition.*
import marcador.ContadorCiclico


class Item inherits Imagen{
	var property elementos
	
	var property posicionParaSelector = position
	
	var property contador = new ContadorCiclico(max = self.cantidadElementos()-1)
	
	method cantidadElementos() = elementos.size()
	
	method next(){
		image = elementos.get(contador.next())
		
	}
	method prev(){
		image = elementos.get(contador.prev())
	}
	
	method quitarElemento(elemento){
		elementos.remove(elemento)
	}
	method eliminarElementos(){
		contador.valor(0)
		contador.max(0)
		elementos = []
	}
	
	method agregarElemento(nuevoElemento){
		elementos.add(nuevoElemento)
		contador.max(contador.max()+1)
	}
	method agregarElementos(muchosElementos){
		elementos.addAll(muchosElementos)
		contador.max(self.cantidadElementos()-1)
	}
}

class Listo inherits Item(image = "listoNO.png", elementos = ["listoSI.png", "listoNO.png"]){
	
	var property listo = true
	
	override method next(){
		super()
		listo = !listo
		menu.chequearListos()
	}
	override method prev(){
		super()
		listo = !listo
		menu.chequearListos()
	}
	
	
}


class Selector inherits Item(image = "selector1.png", elementos = []){
		
	var property itemActual = null
	var property activado = false
		
	override method next(){
		if(activado){
			itemActual = elementos.get(contador.next())
			self.cambiarImagen()
			self.position(itemActual.posicionParaSelector())
		}
	}
	
	override method prev(){
		if(activado){
			itemActual = elementos.get(contador.prev())
			self.cambiarImagen()
			self.position(itemActual.posicionParaSelector())
		
		}
	}
	
	method slideNext(){
		if(activado)
			itemActual.next()
	}
	
	method slidePrev(){
		if(activado)
			itemActual.prev()
	}
	
	method first(){
		itemActual = elementos.get(contador.reiniciar())
		self.cambiarImagen()
		self.position(itemActual.posicionParaSelector())
	}
	
	method cambiarImagen(){
		if(itemActual.cantidadElementos() > 1)
			image = "selector2.png"
		else
			image = "selector1.png"
	}
	
	override method agregarElemento(nuevoElemento){
		super(nuevoElemento)
		game.addVisual(nuevoElemento)
	}
	override method agregarElementos(muchosElementos){
		super(muchosElementos)
		muchosElementos.forEach({ e => game.addVisual(e)})
	}
	method reiniciar(){
		
	}
	
}

object menu{
	
	var property posicionIzq = new MutablePosition(x = juego.medioX()-4, y =  juego.medioY())
	var property posicionDer = new MutablePosition(x = juego.medioX()+4, y =  juego.medioY())
	
	var property cabezaIzq = new Item(position = posicionIzq, image = "messiIzq.png", elementos = ["messiIzq.png"])
	var property cabezaDer = new Item(position = posicionDer, image = "messiDer.png", elementos = ["messiDer.png"])
	var property pieIzq = new Item(position = posicionIzq, image = "botinDer1.png", elementos = ["botinIzq1.png","botinIzq2.png","botinIzq3.png","botinIzq4.png","botinIzq5.png", "pieIzq.png", "pantuflaIzq.png"])
	var property pieDer = new Item(position = posicionDer, image = "botinIzq1.png", elementos = ["botinDer1.png","botinDer2.png","botinDer3.png","botinDer4.png","botinDer5.png", "pieDer.png", "pantuflaDer.png"])
	
	const listoIzq = new Listo(position = posicionIzq.down(4).left(2))
	const listoDer = new Listo(position = posicionDer.down(4).left(2))
	
	var selectorIzq = new Selector(position = posicionIzq)
	var selectorDer = new Selector(position = posicionDer)
	
	method inicializar(){
		cabezaIzq.posicionParaSelector(posicionIzq.left(2).up(2))
		cabezaDer.posicionParaSelector(posicionDer.left(2).up(2))
		pieIzq.posicionParaSelector(posicionIzq.left(2))
		pieDer.posicionParaSelector(posicionDer.left(2))
	}
	method iniciar(){
		game.clear()
		
		listoIzq.next()
		listoDer.next()
		
		selectorIzq.activado(true)
		selectorDer.activado(true)
				
			
		keyboard.right().onPressDo({selectorDer.slideNext()})
		keyboard.left().onPressDo({selectorDer.slidePrev()})
		keyboard.up().onPressDo({selectorDer.prev()})
		keyboard.down().onPressDo({selectorDer.next()})
		
		keyboard.d().onPressDo({selectorIzq.slideNext()})
		keyboard.a().onPressDo({selectorIzq.slidePrev()})
		keyboard.w().onPressDo({selectorIzq.prev()})
		keyboard.s().onPressDo({selectorIzq.next()})
		
	
		selectorIzq.agregarElementos([cabezaIzq,pieIzq,listoIzq])
		selectorDer.agregarElementos([cabezaDer,pieDer,listoDer])
		
		selectorIzq.first()
		selectorDer.first()
		
		game.addVisual(selectorIzq)
		game.addVisual(selectorDer)		
	}
	
	method chequearListos(){
		if(listoIzq.listo() && listoDer.listo()){
			
			selectorIzq.activado(false)
			selectorDer.activado(false)
			
			selectorIzq.eliminarElementos()
			selectorDer.eliminarElementos()
			
			jugadorIzq.cambiarCabeza(cabezaIzq.image())
			jugadorIzq.cambiarPie(pieIzq.image())
			jugadorDer.cambiarCabeza(cabezaDer.image())
			jugadorDer.cambiarPie(pieDer.image())
			
			
			game.schedule(1500, {partido.iniciar()})
		
		}
	}
	
}
