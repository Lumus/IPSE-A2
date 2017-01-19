//
//  SettingsModel.swift
//  Trakx
//
//  Created by Matt Croxson on 27/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class SettingsModel {
   
   // Returns the number of reminders in the application. 
   var reminderCount: Int {
      get {
         if let count = UIApplication.sharedApplication().scheduledLocalNotifications?.count {
            return count
         }
         
         return 0
      }
   }
   
   // Remove all reminders from the application.
   func deleteAllReminders() {
      if self.reminderCount > 0 {
         UIApplication.sharedApplication().cancelAllLocalNotifications()
      }
   }
}
