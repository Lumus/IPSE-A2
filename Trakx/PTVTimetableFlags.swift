//
//  PTVTimetableFlags.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation

enum PTVTimetableFlag: String, CustomStringConvertible {
   case ReservationsRequired = "RR"
   case GuaranteedConnection = "GC"
   case DropOffOnly = "DOO"
   case PickUpOnly = "PUU"
   case MondaysOnly = "MO"
   case TuesdaysOnly = "TU"
   case WednesdaysOnly = "WE"
   case ThursdaysOnly = "TH"
   case FridaysOnly = "FR"
   case SchoolDaysOnly = "SS"
   case Ignore = "E"
   
   var description: String {
      get {
         switch self {
         case .ReservationsRequired: return "Reservations Required"
         case .GuaranteedConnection: return "Guaranteed Connection"
         case .DropOffOnly: return "Drop Off Only"
         case .PickUpOnly: return "Pick Up Only"
         case .MondaysOnly: return "Mondays Only"
         case .TuesdaysOnly: return "Tuesdays Only"
         case .WednesdaysOnly: return "Wednesdays Only"
         case .ThursdaysOnly: return "Thursdays Only"
         case .FridaysOnly: return "Fridays Only"
         case .SchoolDaysOnly: return "School Days Only"
         case .Ignore: return ""
            
         }
      }
   }
}

class PTVTimetableFlags: NSObject {
   
   private let kPTVTimetableFlagsKey = "flags"
   
   // Variables
   private(set) var flags: [PTVTimetableFlag]? = nil
   var flagsAsString: String {
      get {
         if flags == nil { return "" }
         if flags!.count == 0 { return "" }
         
         return flags!.map({$0.description}).joinWithSeparator(", ")
         
      }
   }
   
   override var description: String {
      get {
         return self.flagsAsString
      }
   }
   
   init(flagString: String){
      
      super.init()
      
      if flagString != "" {
         self.flags = self.parseFlagString(flagString)
      }
   }
   
   /// Parses a string containing timetable flags and returns an array of objects (or nil if none found)
   private func parseFlagString(flagString: String) -> [PTVTimetableFlag]? {
      let flagStringArray = flagString.componentsSeparatedByString("-")
      
      if flagStringArray.count == 0 { return nil }
      
      var flagArray = [PTVTimetableFlag]()
      
      for flagString in flagStringArray {
         if let flag = PTVTimetableFlag(rawValue: flagString) {
            if flag != .Ignore {
               flagArray.append(flag)
            }
         }
      }
      
      return flagArray
   }
   
   
   // MARK: - NSCoding
   required init?(coder decoder: NSCoder) {
      super.init()
      
      if let flagString = decoder.decodeObjectForKey(self.kPTVTimetableFlagsKey) as? String {
         self.flags = self.parseFlagString(flagString)
      }
   }
   
   func encodeWithCoder(coder: NSCoder) {
      let flagString = self.flagsAsString
      
      coder.encodeObject(flagString, forKey: kPTVTimetableFlagsKey)
   }
}