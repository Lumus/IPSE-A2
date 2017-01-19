//
//  ColourExtensions.swift
//  Trakx
//
//  Created by Matt Croxson on 23/06/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

extension UIColor {
   
   /** 
    Creates a UIColor object using 0-to-255 based RGBA values. If values passed are out of range, returns nil.
    
    - Returns: UIColor object, or nil if values out of range.
    
    - Author: Matt Croxson © 2016
    */
   static func colorWith256RGBA(red red: Int, green: Int, blue: Int, alpha: Int = 255) -> UIColor {
      // Set colour divisor
      let divisor: Int = 255
      
      // Make sure values passed are in range.
      if 0...divisor ~= red
      && 0...divisor ~= blue
      && 0...divisor ~= green
      && 0...divisor ~= alpha {
         
         // Convert 0-to-255 RGBA to 0-to-1 RGBA
         let newRed = CGFloat(red) / CGFloat(divisor)
         let newGreen = CGFloat(green) / CGFloat(divisor)
         let newBlue = CGFloat(blue) / CGFloat(divisor)
         let newAlpha = CGFloat(alpha) / CGFloat(divisor)
         
         // Return the new colour
         return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
      } else {
         
         // Return black as default.
         return UIColor.blackColor()
      }
   }
   
   static var appTintColour: UIColor {
      get {
         return UIColor.colorWith256RGBA(red: 0, green: 127, blue: 127)
      }
   }
}
