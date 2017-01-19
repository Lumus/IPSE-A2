//
//  PTVUTCTime.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

public class PTVUTCTime: NSObject {
   /// Date format string for timestamps
   private static var dateFormat: String {
      get { return "yyyy-MM-dd'T'HH:mm:ss'Z'" }
   }
   
   
   /// Takes an NSDate object, converts it to UTC and returns it as a String object formatted to ISO 8601 specifications.
   /// - Parameter date: NSDate object containing time to be converted.
   /// - Returns: String object containing the formatted UTC time.
   public class func utcTimeForDate(date: NSDate) -> String
   {
      
      // Create date formatter for conversion.
      let formatter = NSDateFormatter()
      formatter.dateFormat = self.dateFormat
      formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
      
      // Return formatted date as a string.
      return formatter.stringFromDate(date)
   }
   
   /// Returns a String object containing the current time in UTC formatted to ISO 8601 specifications.
   /// - Returns: String object containing the formatted UTC time.
   public static var currentUTCTime: String {
      get {
         // Calls format function for current date.
         return self.utcTimeForDate(NSDate())
      }
   }
   
   /// Takes a String containing UTC time formatted in ISO 8601, and returns an NSDate object in the users current timezone. If the conversion fails, the current time is returned instead.
   /// - Parameter time: String containing the formatted UTC time.
   /// - Returns: NSDate containing the converted time.
   public class func dateForUTCTime(time: String) -> NSDate {
      
      // Create date formatter for conversion
      let formatter = NSDateFormatter()
      formatter.dateFormat = self.dateFormat
      formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
      
      // Attempt to extract date from string. If fails, returns current date
      guard let newDate = formatter.dateFromString(time) else { return NSDate() }
      
      // Return extracted date.
      return newDate
   }
}
