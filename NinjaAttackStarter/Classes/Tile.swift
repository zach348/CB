/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
