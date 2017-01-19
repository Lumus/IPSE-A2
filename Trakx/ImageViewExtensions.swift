//
//  ImageViewExtensions.swift
//  Trakx
//
//  Created by Matt Croxson on 5/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

extension UIImageView {
   var renderedImage: UIImage {
      get {
         UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
         
         let ref = UIGraphicsGetCurrentContext()
         self.layer.renderInContext(ref!)
         
         let returnImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         
         return returnImage
      }
   }
}
