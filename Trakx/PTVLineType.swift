//
//  PTVLineType.swift
//  Trakx
//
//  Created by Matt Croxson on 28/06/2015.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

enum PTVLineType: Int, CustomStringConvertible {
   case MetroTrain = 0
   case Tram = 1
   case Bus = 2
   case VLine = 3
   case NightRider = 4
   case Line = -1
   
   // Init from string
   init?(stringValue: String)
   {
      switch stringValue {
      case "train": self = .MetroTrain
      case "tram": self = .Tram
      case "bus": self = .Bus
      case "vline": self = .VLine
      case "nightrider": self = .NightRider
      case "line": self = .Line
         
      default: return nil
      }
   }
   
   init?(description: String) {
      switch description {
      case "Metro Train": self = .MetroTrain
      case "Yarra Tram": self = .Tram
      case "PTV Bus": self = .Bus
      case "V/Line": self = .VLine
      case "NightRider Bus": self = .NightRider
      case "Line": self = .Line
         
      default: return nil
      }
   }
   
   // Return human-readable textual description of the transport mode
   var description: String {
      get {
         switch self {
         case .MetroTrain: return "Metro Train"
         case .Tram: return "Yarra Tram"
         case .Bus: return "PTV Bus"
         case .VLine: return "V/Line"
         case .NightRider: return "NightRider Bus"
         case .Line: return "Line"
         }
      }
   }
   
   // Returns a UI Color object containing the marketing colour of the transport mode.
   var bgColor: UIColor {
      get {
         switch self {
         case .MetroTrain: return UIColor.colorWith256RGBA(red: 0, green: 109, blue: 167)    // Blue
         case .Tram: return UIColor.colorWith256RGBA(red: 114, green: 190, blue: 67)         // Green
         case .VLine: return UIColor.colorWith256RGBA(red: 140, green: 63, blue: 146)        // Purple
         case .Bus: return UIColor.colorWith256RGBA(red: 229, green: 144, blue: 48)          // Orange
         case .NightRider: return UIColor.blackColor()                                       // Black
         case .Line: return UIColor.colorWith256RGBA(red: 80, green: 80, blue: 80)           // Dark Grey
         }
      }
   }
   
   
   // Returns a UIColor object the best text colour for use against the marketing colour.
   var highlighColor: UIColor {
      get {
         switch self {
         case .MetroTrain: fallthrough
         case .Tram :fallthrough
         case .Line: fallthrough
         case .Bus: fallthrough
         case .VLine: return UIColor.whiteColor()
            
         case .NightRider: return UIColor.colorWith256RGBA(red: 229, green: 144, blue: 48)   // Orange
            
         }
      }
   }
   
   
   // Returns string value corresponding to PTVLineType
   var stringValue: String {
      switch self {
      case .MetroTrain: return "train"
      case .Tram: return "tram"
      case .Bus: return "bus"
      case .VLine: return "vline"
      case .NightRider: return "nightrider"
      case .Line: return "line"
      }
   }
   
   var pinIcon: UIImage? {
      get {
         var lineTypeImage: UIImage?
         
         // Get image
         switch self {
            
         case .Bus: fallthrough
         case .NightRider: lineTypeImage = UIImage(named: "Bus Filled-25")
            
         case .VLine: fallthrough
         case .MetroTrain: lineTypeImage = UIImage(named: "Train Filled-25")
            
         case .Tram: lineTypeImage = UIImage(named: "Tram Filled-25")
            
         default: lineTypeImage = nil
         }
         
         return lineTypeImage
      }
   }
   
   // Returns a UIImage of the stop tinted with the highlight colour for the stop itself.
   var pinImage: UIImage? {
      get {
         
         let lineTypeImage = self.pinIcon
         
         // Create image view to manipulate image. Assumes images are 25 points in size.
         let lineTypeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
         lineTypeImageView.contentMode = .Center
         lineTypeImageView.image = lineTypeImage
         lineTypeImageView.tintColor = self.highlighColor
         lineTypeImageView.backgroundColor = self.bgColor.colorWithAlphaComponent(0.7)
         lineTypeImageView.layer.cornerRadius = 3.0
         lineTypeImageView.layer.borderColor = UIColor.blackColor().CGColor
         lineTypeImageView.layer.borderWidth = 2.0
         
         return lineTypeImageView.renderedImage
         
      }
   }
   
   // Gets a 33-point size image represneting the line type.
   var typeImage: UIImage? {
      get {
         var lineTypeImage: UIImage?
         
         // Get image
         switch self {
            
         case .Bus: fallthrough
         case .NightRider: lineTypeImage = UIImage(named: "Bus Filled-33")
            
         case .VLine: fallthrough
         case .MetroTrain: lineTypeImage = UIImage(named: "Train Filled-33")
            
         case .Tram: lineTypeImage = UIImage(named: "Tram Filled-33")
            
         default: lineTypeImage = nil
         }
         
         return lineTypeImage
      }
   }
   
   // Returns an array containing all line type options available
   static var allOptions: Array<PTVLineType> {
      return [.MetroTrain, .Tram, .Bus, .VLine, .NightRider]
   }
}