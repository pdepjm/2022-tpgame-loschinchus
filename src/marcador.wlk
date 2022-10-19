import wollok.game.*
import mutablePosition.*
import juego.*

class Numero{
	var property n
	var x
	var y
	var property position = new MutablePosition(x = x, y = y)
	
	method image() = n.toString()+".png"
	method aumentar(){
		if(n == 9)
			n = 0
		else
			n++
	}
	method descontar(){
		if(n == 0)
			n = 9
		else
			n--
	}
	override method toString() = "numero"
}

class Contador{
	
	var x
	var y
	var cantDigitos = 1
	var property haciaDerecha = true
	var property valor = 0
	var property numeros = []
	
	
	method reiniciar(){
		numeros.forEach({num =>
			game.removeVisual(num)
			
		}
		)
		const nuevoNumero = new Numero(n = 0, x = x, y = y)
		game.addVisual(nuevoNumero)
		numeros = [nuevoNumero]
	}
	method agregarNumero(){
		
		const nuevoNumero = new Numero(n = 1, x = x, y = y)
		if(haciaDerecha)
			numeros.forEach({n =>
					n.position().goRight(2)
				}
			)
		else{
			nuevoNumero.position().goLeft(2*cantDigitos)
		}
		numeros.add(nuevoNumero)
		game.addVisual(nuevoNumero)
		cantDigitos++
	}
	method aumentar(){
		valor++
		var seAumento = true
		numeros.forEach({ num =>
				if(seAumento){
					num.aumentar()
					if(num.n() > 0)
						seAumento  = false
				}
				
		})
		if(seAumento)
			self.agregarNumero()
	}
	
}

object contMin {
	var property minutos = 0
	
	method image() = minutos.toString()+".png"
	
	method descontarMinuto(){
		minutos = (minutos-1).max(0)
	}
}

object contSeg {
	var property segundos = 0
	
	
	method decenas() = segundos.div(10)
	method unidades() = segundos.rem(10)
	method descontarSegundo(){
		segundos -= 1
	}
	method hayQueDescontarMinuto(minutosRestantes){
		if(segundos < 0){
			if(minutosRestantes > 0){
				segundos = 59
				return true
			
			}
			else
				segundos = 0
		}
		return false
	}
}
object temporizador{
	
	var property position = new MutablePosition(x = 12, y = juego.h()-1-2)
	
	var property seAcaboElTiempo = false
	
	var property visualMinuto = new Numero(n = contMin.minutos(), x = position.x(), y = position.y())
	var property visualDecSegundo = new Numero(n = contSeg.decenas(), x = position.x()+3, y = position.y())
	var property visualUnidSeguno= new Numero(n = contSeg.unidades(), x = position.x()+5, y = position.y())
	
	
	method resetear(minutos){
		seAcaboElTiempo = false
		contMin.minutos(minutos)
		contSeg.segundos(0)
		self.actualizarVisuales()
	}
	method actualizar(){
		if(!seAcaboElTiempo){
			
			contSeg.descontarSegundo()
			if(contSeg.hayQueDescontarMinuto( contMin.minutos() ) )
				contMin.descontarMinuto()
			
			if (contSeg.segundos() == 0 &&  contMin.minutos() == 0)
				seAcaboElTiempo = true
			
			self.actualizarVisuales()
			
				
		}
	}
	method inicializar(){
		game.addVisual(visualMinuto)
		game.addVisual(visualDecSegundo)
		game.addVisual(visualUnidSeguno)
		self.resetear(5)
	}
	method actualizarVisuales(){
		visualMinuto.n(contMin.minutos())
		visualDecSegundo.n(contSeg.decenas())
		visualUnidSeguno.n(contSeg.unidades())
	}
	
}

