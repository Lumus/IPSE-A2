//
//  PTVDisruptionStatus.swift
//  Trakx
//
//  Created by Matt Croxson on 14/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

/**
 Represents the current types of a disruptions.
 
 - All: Covers all disruption types.
 - None: Current disruption.
 - Planned: Planned disruption.
 
 */
public enum PTVDisruptionStatus: String, CustomStringConvertible, Equatable {
   
   /// Current active disruption.
   case None = "None"
   
   /// Planned future disruption.
   case Several = "Several"
   
   /// Returns a human-readable textual description of the disruption status.
   public var description: String {
      get {
         return self.rawValue
      }
   }
   
   /// Returns an array of all disruption type options.
   static public var allOptions: Array<PTVDisruptionStatus> {
      get {
         return [.None, .Several]
      }
   }
   
   var statusImage: UIImage? {
      get {
         switch self {
         case .None: return UIImage(named: "Checked Filled Green-22")
            
         case .Several: return UIImage(named: "Attention Filled Orange-22")
            
         }
      }
   }
}