

import Foundation
import SpriteKit

class Tile: SKShapeNode {
  static var members = [Tile]()
  
  class func createTile(position:CGPoint, tileName:String){
    let tile = Tile()
    tile.position = position
    tile.name = tileName
    Tile.members.append(tile)
  }
  
  class func createTiles(){
    let width = currentGame.gameScene!.frame.width
    let height = currentGame.gameScene!.frame.height
    var yVal = (0 + height/2) - (height/3)
    
    var nextPoint = CGPoint(x: 0 - (width/2), y: yVal)
    var lastPoint:CGPoint
    var tileCount = 1
    for row in 1...3 {
      for tile in 1...5 {
        self.createTile(position: nextPoint , tileName: "tile\(tileCount)")
        lastPoint = nextPoint
        nextPoint = CGPoint(x: lastPoint.x + width/5, y: lastPoint.y)
        tileCount += 1
      }
      yVal -= height/3
      nextPoint = CGPoint(x: 0 - (width/2), y: yVal)
    }
  }
  
  override init(){
    super.init()
    //    super.init(rectOf: CGSize(width: currentGame.gameScene!.frame.width/5, height: currentGame.gameScene!.frame.height/3))
    self.path = CGPath(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: currentGame.gameScene!.frame.width/5, height: currentGame.gameScene!.frame.height/3)), transform: nil)
    self.zPosition = -1
    self.fillColor = SKColor.white
    self.strokeColor = SKColor.black
    self.lineWidth = 5
    self.alpha = 0.1
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
