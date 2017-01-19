//
//  PTVTimetableItem.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import SwiftyJSON

class PTVTimetableItem: NSObject, NSCoding {
   
   // Constants
   private let kPTVTimetableItemTimeTableUTCKey = "time_timetable_utc"
   private let kPTVTimetableItemRealtimeUTCKey = "time_realtime_utc"
   private let kPTVTimetableItemFlagsKey = "flags"
   private let kPTVTimetablePlatformKey = "platform"
   private let kPTVTimetableRunKey = "run"
   
   // Variables
   private(set) var timetableTimeUTC = NSDate()
   private(set) var realtimeTimeUTC: NSDate? = nil
   private(set) var timetableFlags: PTVTimetableFlags?
   private(set) var timetablePlatform: PTVPlatform?
   private(set) var timetableRun: PTVRun?
   
   override var description: String {
      get {
         return "{\n" +
            "\t Time: \(timetableTimeUTC) \n" +
            "\t Realtime: \(realtimeTimeUTC) \n" +
            "\t Flags: \(timetableFlags) \n" +
            "\t Platform: \(timetablePlatform) \n" +
            "\t Run: \(timetableRun) \n" +
         "}\n"
      }
   }
   
   init(timetableTime: NSDate, realtimeTime: NSDate?, flags: PTVTimetableFlags, platform: PTVPlatform, run: PTVRun) {
      self.timetableTimeUTC = timetableTime
      self.realtimeTimeUTC = realtimeTime
      self.timetableFlags = flags
      self.timetablePlatform = platform
      self.timetableRun = run
   }
   
   init(_ data: [String: JSON])
   {
      super.init()
      
      if let tTime = data[kPTVTimetableItemTimeTableUTCKey]?.string {
         let time = PTVUTCTime.dateForUTCTime(tTime)
         timetableTimeUTC = time
      }
      
      if let rTime = data[kPTVTimetableItemRealtimeUTCKey]?.string {
         let time = PTVUTCTime.dateForUTCTime(rTime)
         realtimeTimeUTC = NSDate()
         self.realtimeTimeUTC = time
      } else {
         self.realtimeTimeUTC = nil
      }
      
      if let flags = data[kPTVTimetableItemFlagsKey]?.string {
         self.timetableFlags = PTVTimetableFlags(flagString: flags)
      }
      
      if let platform = data[kPTVTimetablePlatformKey]?.dictionary {
         timetablePlatform = PTVPlatform(platform)
      }
      
      if let run = data[kPTVTimetableRunKey]?.dictionary {
         timetableRun = PTVRun(run)
      }
      
      let _ = self.reminderID
   }
   
   var reminderID: String {
      get {
         let runID = self.timetableRun?.runID
         let destinationID = self.timetableRun?.destinationID
         let directionID = self.timetablePlatform?.platformDirection?.directionID
         let lineDirectionID = self.timetablePlatform?.platformDirection?.lineDirectionID
         let departureTime = self.timetableTimeUTC
         let stopName = self.timetablePlatform?.platformStop?.locationName
         
         let reminderID = "\(runID!)-\(destinationID!)-\(directionID!)-\(lineDirectionID!)-\(PTVUTCTime.utcTimeForDate(departureTime))-\(stopName!))"
         print(reminderID)
         
         return reminderID
      }
   }
   
   
   // MARK: - NSCoding
   required init?(coder decoder: NSCoder) {
      if let timetableTime = decoder.decodeObjectForKey(self.kPTVTimetableItemTimeTableUTCKey) as? NSDate {
         self.timetableTimeUTC = timetableTime
      }
      
      if let realtimeTime = decoder.decodeObjectForKey(self.kPTVTimetableItemRealtimeUTCKey) as? NSDate {
         self.realtimeTimeUTC = realtimeTime
      }
      
      if let flags = decoder.decodeObjectForKey(self.kPTVTimetableItemFlagsKey) as? PTVTimetableFlags {
         self.timetableFlags = flags
      }
      
      if let platform = decoder.decodeObjectForKey(self.kPTVTimetablePlatformKey) as? PTVPlatform {
         self.timetablePlatform = platform
      }
      
      if let run = decoder.decodeObjectForKey(self.kPTVTimetableRunKey) as? PTVRun {
         self.timetableRun = run
      }
   }
   
   func encodeWithCoder(coder: NSCoder) {
      coder.encodeObject(self.timetableTimeUTC, forKey: self.kPTVTimetableItemTimeTableUTCKey)
      coder.encodeObject(self.realtimeTimeUTC, forKey: self.kPTVTimetableItemRealtimeUTCKey)
      coder.encodeObject(self.timetableFlags, forKey: self.kPTVTimetableItemFlagsKey)
      coder.encodeObject(self.timetablePlatform, forKey: self.kPTVTimetablePlatformKey)
      coder.encodeObject(self.timetableRun, forKey: self.kPTVTimetableRunKey)
   }
}
