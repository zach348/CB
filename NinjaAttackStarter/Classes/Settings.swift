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

struct Settings {
  let phase:Int
  let phaseDuration:Double
  let pauseDelay:Double
  let pauseError:Double
  let pauseDuration:Double
  let frequency:Double
  let targetMeanSpeed:CGFloat
  let targetSpeedSD:CGFloat
  let shiftDelay:Double
  let shiftError:Double
  let numTargets:Int
  let targetTexture:SKTexture
  let distractorTexture:SKTexture
  let flashTexture:SKTexture
  let minSpeed:CGFloat = 300
  let maxSpeed:CGFloat = 1200
  
  init(phase:Int, phaseDuration:Double, pauseDelay:Double, pauseError:Double, pauseDuration:Double, frequency:Double, targetMeanSpeed:CGFloat, targetSpeedSD:CGFloat, shiftDelay:Double, shiftError:Double,numTargets:Int, targetTexture:String, distractorTexture:String, flashTexture:String){
    self.phase = phase
    self.phaseDuration = phaseDuration
    self.pauseDelay = pauseDelay
    self.pauseError = pauseError
    self.pauseDuration = pauseDuration
    self.frequency = frequency
    self.targetMeanSpeed = targetMeanSpeed
    self.targetSpeedSD = targetSpeedSD
    self.shiftDelay = shiftDelay
    self.shiftError = shiftError
    self.numTargets = numTargets
    self.targetTexture = SKTexture(imageNamed: targetTexture)
    self.distractorTexture = SKTexture(imageNamed: distractorTexture)
    self.flashTexture = SKTexture(imageNamed: flashTexture)
  }
}
