//
//  FavouriteLineType.swift
//  Trakx
//
//  Created by Matt Croxson on 7/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation
import CoreData


class FavouriteLineType: NSManagedObject {

   /// Returns the PTVLineType saved in the object, or nil if not found/failed.
   var lineType: PTVLineType? {
      get {
         if let type = PTVLineType(rawValue: self.lineID.integerValue) {
            return type
         }
         
         return nil
      }
   }
}
