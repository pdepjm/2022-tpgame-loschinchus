import wollok.game.*

class MutablePosition {//Posiciones de game pero mutables (codigo copiado)
  var property x = 0
  var property y = 0
  
  var property xInicial = 0
  var property yInicial = 0
  
  method posicionInicial(_x,_y){
	  xInicial = _x
	  yInicial = _y
  }
  
  method reestablecer(){
  		x = xInicial
  		y = yInicial 
  }
 
  method right(n) = new MutablePosition(x = x + n, y = y)
     
  method left(n) = new MutablePosition(x = x - n, y = y)
    
  method up(n) = new MutablePosition(x = x, y = y + n)
     
  method down(n) = new MutablePosition(x = x, y = y - n) 
  
  method goRight(n){
      x += n
  }
  
  method goLeft(n){
      x -= n
  }
  
  method goUp(n){
   y = (y + n)
  }
  
  method goDown(n){
      y -= n
  }
  
  method goTo(position)
  {
  	x= position.x()
  	y = position.y()
  }
  
  method goTo(_x,_y)
  {
  	x = _x
  	y = _y
  }
  
  method drawElement(element) { game.addVisualIn(element, self) }
  
  method drawCharacter(element) { game.addVisualCharacterIn(element, self) }
 
  method say(element, message) { game.say(element, message) }
 
  method allElements() = game.getObjectsIn(self)
   
  method clone() = new MutablePosition(x = x, y = y)
 
  method distance(position) {
    self.checkNotNull(position, "distance")
    const deltaX = x - position.x()
    const deltaY = y - position.y()
    return (deltaX.square() + deltaY.square()).squareRoot() 
  }
  
  method goToRandom(height)
  {
  	self.goTo(0.randomUpTo(game.width()),height)
  }

  method clear() {
    self.allElements().forEach{it => game.removeVisual(it)}
  }
  
  override method ==(other) = x == other.x() && y == other.y()
  
  override method toString() = x.toString() + "@" + y.toString()

} 
