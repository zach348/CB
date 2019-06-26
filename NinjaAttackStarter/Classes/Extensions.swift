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

import SpriteKit
import Foundation
import CoreGraphics

// MARK: Int Extension

public extension Int {
  
  /// Returns a random Int point number between 0 and Int.max.
  static var random: Int {
    return Int.random(n: Int.max)
  }
  
  /// Random integer between 0 and n-1.
  ///
  /// - Parameter n:  Interval max
  /// - Returns:      Returns a random Int point number between 0 and n max
  static func random(n: Int) -> Int {
    return Int(arc4random_uniform(UInt32(n)))
  }
  
  ///  Random integer between min and max
  ///
  /// - Parameters:
  ///   - min:    Interval minimun
  ///   - max:    Interval max
  /// - Returns:  Returns a random Int point number between 0 and n max
  static func random(min: Int, max: Int) -> Int {
    return Int.random(n: max - min + 1) + min
    
  }
}

// MARK: Double Extension

public extension Double {
  
  /// Returns a random floating point number between 0.0 and 1.0, inclusive.
  static var random: Double {
    return Double(arc4random()) / 0xFFFFFFFF
  }
  
  /// Random double between 0 and n-1.
  ///
  /// - Parameter n:  Interval max
  /// - Returns:      Returns a random double point number between 0 and n max
  static func random(min: Double, max: Double) -> Double {
    return Double.random * (max - min) + min
  }
}

// MARK: Float Extension

public extension Float {
  
  /// Returns a random floating point number between 0.0 and 1.0, inclusive.
  static var random: Float {
    return Float(arc4random()) / 0xFFFFFFFF
  }
  
  /// Random float between 0 and n-1.
  ///
  /// - Parameter n:  Interval max
  /// - Returns:      Returns a random float point number between 0 and n max
  static func random(min: Float, max: Float) -> Float {
    return Float.random * (max - min) + min
  }
}

// MARK: CGFloat Extension

public extension CGFloat {
  
  /// Randomly returns either 1.0 or -1.0.
  static var randomSign: CGFloat {
    return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
  }
  
  /// Returns a random floating point number between 0.0 and 1.0, inclusive.
  static var random: CGFloat {
    return CGFloat(Float.random)
  }
  
  /// Random CGFloat between 0 and n-1.
  ///
  /// - Parameter n:  Interval max
  /// - Returns:      Returns a random CGFloat point number between 0 and n max
  static func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat.random * (max - min) + min
  }
}



