import wollok.game.*

object soundMock {
	
	method pause(){}
	
	method paused() = true
	
	method play(){}
	
	method played() = false
	
	method resume(){}
	
	method shouldLoop(looping){}
	
	method shouldLoop() = false
	
	method stop(){}
	
	method volume(newVolume){}
	
	method volume() = 0
}



object soundProducer {
	
	var provider = game
	
	method provider(_provider){
		provider = _provider
	}
	
	method sound(audioFile) = provider.sound(audioFile)
	
}

object soundProviderMock {
	
	method sound(audioFile) = soundMock
	
}


object sonidoPartido{
	var cancha
	method gol(){
		soundProducer.sound("gol.mp3").play()
	}
	method final(){
		soundProducer.sound("silbatoFinal.mp3").play()
	}
	method silbato(){
		soundProducer.sound("silbato.mp3").play()
	}
	method cancha(){
		cancha = soundProducer.sound("cancha.mp3")
		cancha.shouldLoop(true)
		cancha.play()
	}
	method detenerCancha(){
		cancha.shouldLoop(false)
		cancha.stop()
	}
}


object sonidoPelota{
	method play(){
		soundProducer.sound("pelota.mp3").play()
		
	}
}
object sinSonido{
	method play(){}
}
