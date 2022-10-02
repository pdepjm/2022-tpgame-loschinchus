import wollok.game.*


object contMin {
	var property minutos = 5
	
	method position() = game.at(13, 15)
	
	method image() {
		if(minutos == 5){
			return "5.png"
		}
		if(minutos == 4){
			return "4.png"
		}
		if(minutos == 3){
			return "3.png"
		}
		if(minutos == 2){
			return "2.png"
		}
		if(minutos == 1){
			return "1.png"
		}else{
			return "0.png"
		}
	}
	
	method iniciarContador(){
		game.onTick(60000, "pasa un minuto", { self.pasaMinuto()})
	}
	
	method pasaMinuto(){
		minutos = (minutos-1)
	}
}

object contSeg {
	
}