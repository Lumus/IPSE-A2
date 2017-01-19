//
//  PTVDisruptionType.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

/**
 Represents the current types of a disruptions.
 
 - All: Covers all disruption types.
 - Current: Current disruption.
 - Planned: Planned disruption.
 
 */
public enum PTVDisruptionType: String, CustomStringConvertible, Equatable {
   
   /// Current active disruption.
   case Current = "Current"
   
   /// Planned future disruption.
   case Planned = "Planned"
   
   /// Returns a human-readable textual description of the disruption type.
   public var description: String {
      get {
         return self.rawValue
      }
   }
   
   /// Returns an array of all disruption type options.
   static public var allOptions: Array<PTVDisruptionType> {
      get {
         return [.Current, .Planned]
      }
   }
   
   var typeImage: UIImage? {
      get {
         switch self {
         case .Current: return UIImage(named: "Leave Filled-33")
            
         case .Planned: return UIImage(named: "Planner Filled-33")
            
         }
      }
   }
}