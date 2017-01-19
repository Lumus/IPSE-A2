//
//  FavouriteStop.swift
//  Trakx
//
//  Created by Matt Croxson on 6/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation
import CoreData


class FavouriteStop: NSManagedObject {
   
   /// Returns the PTVStop saved in the object, or nil if not found/failed.
   func stopItem() -> PTVStop? {
      
      if let stop = NSKeyedUnarchiver.unarchiveObjectWithData(stopObject) as? PTVStop {
         return stop
      }
      
      return nil
   }
}
