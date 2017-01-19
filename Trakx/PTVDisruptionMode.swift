//
//  PTVDisruptionMode.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

/**
 Represents a tranport mode when requesting disruptions from the PTV API.
 
 - General: General disruptions or information.
 - MetroBus: Metropolitan Melbourne buses.
 - MetroTrain: Metropolitan Melbourne trains (Metro Trains Melbourne).
 - MetroTram: Metropolitan Melbourne trams (Yarra Trams).
 - RegionalBus: Regional centre buses.
 - RegionalCoach: V/Line coaches.
 - RegionalTrain: V/Line trains.
 
 - See: **PTVDisruption**
 */
enum PTVDisruptionMode: String, CustomStringConvertible {
   
   /// General disruption or information.
   case General = "general"
   /// Metro Melbourne bus service disruptions (multiple operators).
   case MetroBus = "metro-bus"
   /// Metro Trains Melbourne service disruptions
   case MetroTrain = "metro-train"
   /// Yarra Trams service disruptions.
   case MetroTram = "metro-tram"
   /// Regional bus service disruptions (multiple operators).
   case RegionalBus = "regional-bus"
   /// V/Line coach service disruptions.
   case RegionalCoach = "regional-coach"
   /// V/Line train service diruptions.
   case RegionalTrain = "regional-train"
   
   /// Returns a human-readable textual description of the disruption mode.
   var description: String {
      get {
         switch self {
         case .General: return "General"
         case .MetroBus: return "Metro Bus"
         case .MetroTrain: return "Metro Train"
         case .MetroTram: return "Yarra Trams"
         case .RegionalBus: return "Regional Bus"
         case .RegionalCoach: return "V/Line Coach"
         case .RegionalTrain: return "V/Line Train"
         }
      }
   }
   
   /// Returns a **UIColor** object containing the marketing colour of the transport mode.
   var bgColor: UIColor {
      get {
         switch self {
            
         case .MetroTrain: return UIColor(red: 0.0/255.0, green: 109.0/255.0, blue: 167.0/255.0, alpha: 1)
            
         case .MetroTram: return UIColor(red: 114.0/255.0, green: 190.0/255.0, blue: 67.0/255.0, alpha: 1)
            
         case .MetroBus: fallthrough
         case .RegionalBus: return UIColor(red: 229.0/255.0, green: 144.0/255.0, blue: 48.0/255.0, alpha: 1)
            
         case .RegionalCoach: fallthrough
         case .RegionalTrain: return UIColor(red: 140.0/255.0, green: 63.0/255.0, blue: 146.0/255.0, alpha: 1)
            
         default: return UIColor.appTintColour
         }
      }
   }
   
   /// Returns a UIColor object containing either **UIColor.whiteColor()** or **UIColor.blackColor**. Intended for use when displaying text on top of the marketing colour.
   var textColor: UIColor {
      get {
         switch self {
         case .General: fallthrough
         case .MetroTrain :fallthrough
         case .MetroBus: fallthrough
         case .RegionalCoach: fallthrough
         case .MetroTram: fallthrough
         case .RegionalBus: fallthrough
         case .RegionalTrain: return UIColor.whiteColor()
            
            //         default: return UIColor.blackColor()
         }
      }
   }
   
   /// Returns an array of all disruption modes.
   static var allOptions: Array<PTVDisruptionMode> {
      get {
         return [.General, .MetroBus, .MetroTrain, .MetroTram, .RegionalBus, .RegionalCoach, .RegionalTrain]
      }
   }
   
   /// Returns a CSV list of all disruption modes.
   static var allOptionsCSV: String {
      get {
         return PTVDisruptionMode.allOptions.map({ "\($0.rawValue)" }).joinWithSeparator(",")
      }
   }
}