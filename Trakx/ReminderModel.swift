//
//  ReminderModel.swift
//  Trakx
//
//  Created by Matt Croxson on 1/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import CoreLocation

class ReminderModel {
   
   // Singleton
   class var sharedModel: ReminderModel {
      struct Singleton  {
         static let instance = ReminderModel()
      }
      
      return Singleton.instance
   }
   
   // Date formatter for dates in notification body.
   private let dateFormatter = NSDateFormatter()
   
   // Initialiser for date formatter. Private to prevent instances.
   private init() {
      dateFormatter.timeStyle = .ShortStyle
   }
   
   /// Checks if location reminder has been set for the specified stop.
   func locationReminderIsSet(forStop stop: PTVStop) -> (setting: Bool, message: String) {
      
      var message = "Unknown Error."
      
      // Locate notification and return true if found.
      if let _ = self.retrieveLocationReminder(forStop: stop) {
         message = "Location reminder found."
         return (true, message)
      }
      
      // Default to return false assuming location not found.
      message = "Unable to locate location reminder."
      return (false, message)
   }
   
   /// Enables or removes a location reminder for the specified stop.
   func setLocationReminder(forStop stop: PTVStop, enabled: Bool) -> (success: Bool, message: String) {
      
      self.requestNotificationPermission()
      
      if enabled {
         return self.setLocationReminder(forStop: stop)
      } else {
         return self.removeLocationReminder(forStop: stop)
      }
   }
   
   /// Checks if reminder has been set for the specified timetable item.
   func timetableReminderIsSet(forTimetableItem item: PTVTimetableItem) -> (setting: Bool, message: String) {
      
      var message = "Unknown Error."
      
      // Locate notification and return true if found
      if let _ = self.retrieveTimetableReminder(forTimetableItem: item) {
         message = "Timetable reminder found."
         return (true, message)
      }
      
      // Default to return false assuming item not found.
      message = "Unable to locate timetable reminder."
      return (false, message)
   }
   
   /// Enables or removes a location reminder for the specified timetable item.
   func setTimetableReminder(forTimetableItem item: PTVTimetableItem, enabled: Bool) -> (success: Bool, message: String) {
      
      self.requestNotificationPermission()
      
      if enabled {
         return self.setTimetableReminder(forTimetableItem: item)
      } else {
         return self.removeTimetableReminder(forTimetableItem: item)
      }
   }
}

// MARK: - Private Functions
extension ReminderModel {
   
   // MARK: Location reminders
   private func setLocationReminder(forStop stop: PTVStop) -> (success: Bool, message: String) {
      
      // Notification radius
      let notificationRadius = 200.00 // 200 metres
      
      // Message to return
      var message = "Unknown Error"
      
      // Code object into user info dictionary for later identification
      let codedStop = NSKeyedArchiver.archivedDataWithRootObject(stop)
      let userInfo = ["stopObject": codedStop]
      
      // Create location notification
      let locationNotification = UILocalNotification()
      locationNotification.regionTriggersOnce = true
      locationNotification.region = CLCircularRegion(center: stop.coordinate, radius: notificationRadius, identifier: "\(stop.transportType.stringValue)\(stop.stopID)\(stop.locationName)")
      locationNotification.region?.notifyOnExit = false
      locationNotification.region?.notifyOnEntry = true
      
      // Add user info
      locationNotification.userInfo = userInfo
      
      // Add notification details
      locationNotification.alertBody = "Now Approaching: \(stop.locationName)"
      locationNotification.alertTitle = "Approaching Stop"
      locationNotification.soundName = UILocalNotificationDefaultSoundName
      
      // Schedule notification
      UIApplication.sharedApplication().scheduleLocalNotification(locationNotification)
      
      // Return true indicating successful schedule.
      message = "Reminder scheduled."
      return (true, message)
   }
   
   private func removeLocationReminder(forStop stop: PTVStop) -> (success: Bool, message: String) {
      
      // Message to return
      var message = "Unknown Error"
      
      // Locate notification and remove it if found.
      if let notification = self.retrieveLocationReminder(forStop: stop) {
         UIApplication.sharedApplication().cancelLocalNotification(notification)
         
         // Return true indicating successful removal
         message = "Location reminder removed"
         return (true, message)
      }
      
      // Return false indicating unsuccessful removal
      message = "Unable to locate location reminder to remove."
      return (false, message)
      
   }
   
   private func retrieveLocationReminder(forStop stop: PTVStop) -> UILocalNotification? {
      
      // Iterate through existing notifications.
      if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
         for notification in notifications {
            
            // Decode user info, return nil if error (e.g. notification does not contain user info).
            guard let codedUserInfo = notification.userInfo as? [String: NSData],
               let codedStop = codedUserInfo["stopObject"],
               let decodedStop = NSKeyedUnarchiver.unarchiveObjectWithData(codedStop) as? PTVStop else { return nil }
            
            // If notification relates to stop, return the notification.
            if decodedStop.stopID == stop.stopID {
               return notification
            }
         }
      }
      
      // Return nil to indicate no notification found.
      return nil
      
   }
   
   //MARK: Timetable Reminder
   private func setTimetableReminder(forTimetableItem item: PTVTimetableItem) -> (success: Bool, message: String) {
      
      let timeOffset = -300.00 // 300 Seconds (5 Minutes)
      
      // Message to return
      var message = "Unknown Error."
      
      // Code object into user info dictionary for later identification
      let codedItem = NSKeyedArchiver.archivedDataWithRootObject(item)
      let userInfo = ["timetableObject": codedItem]
      
      // Create timetable reminder notification
      let notification = UILocalNotification()
      
      // Add user info
      notification.userInfo = userInfo
      
      // Calculate notification time
      var notificationDate = item.timetableTimeUTC.dateByAddingTimeInterval(timeOffset)
      
      // Make sure notification is not set to a time prior to now
      if notificationDate.earlierDate(NSDate()).isEqualToDate(notificationDate) {
         
         // Set notification date to timetable time
         notificationDate = item.timetableTimeUTC
      }
      
      // Set notification fire date
      notification.fireDate = notificationDate
      
      // Confirm fire date is not before current date (i.e. user requests reminder for timetable item earlier than the current time)
      if notificationDate.earlierDate(NSDate()).isEqualToDate(notificationDate) {
         
         // Return unsuccessful schedule.
         message = "Unable to schedule reminder before current time."
         return (false, message)
      }
      
      // Add notification details
      notification.alertBody = "\(dateFormatter.stringFromDate(item.timetableTimeUTC)) - \(item.timetablePlatform!.platformStop!.locationName)"
      notification.alertTitle = "Upcoming Departure"
      notification.soundName = UILocalNotificationDefaultSoundName
      
      // Schedule notification
      UIApplication.sharedApplication().scheduleLocalNotification(notification)
      
      // Return successful schedule.
      message = "Reminder scheduled."
      return (true, message)
   }
   
   private func removeTimetableReminder(forTimetableItem item: PTVTimetableItem) -> (success: Bool, message: String) {
      
      // Message to return
      var message = "Unknown Error."
      
      // Locate notification and remove if found
      if let notification = self.retrieveTimetableReminder(forTimetableItem: item) {
         UIApplication.sharedApplication().cancelLocalNotification(notification)
         
         // Return true indicating successful removal.
         message = "Timetable reminder removed."
         return (true, message)
      }
      
      // Return false indicating unsuccessful removal.
      message = "Unable to locate timetable reminder to remove."
      return (false, message)
   }
   
   private func retrieveTimetableReminder(forTimetableItem item: PTVTimetableItem) -> UILocalNotification? {
      
      // Iterate through existing notifictions.
      if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
         
         for (index, notification) in notifications.enumerate() {
            print("\(index): \(notification.alertBody)")
            guard let codedUserInfo = notification.userInfo as? [String: NSData] else  { continue }
            guard let codedTimetableItem = codedUserInfo["timetableObject"] else { continue }
            guard let decodedTimetableItem = NSKeyedUnarchiver.unarchiveObjectWithData(codedTimetableItem) as? PTVTimetableItem else { continue }
            
            // If notification relates to the passed item, return the notification
            if decodedTimetableItem.reminderID == item.reminderID {
               return notification
            }
         }
      }
      
      // Return nil to indicate no notification found.
      return nil
   }
   
   private func requestNotificationPermission() {
      let newSettings = UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil)
      UIApplication.sharedApplication().registerUserNotificationSettings(newSettings)
   }
}