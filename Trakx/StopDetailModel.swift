//
//  StopDetailModel.swift
//  Trakx
//
//  Created by Matt Croxson on 6/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import MapKit
import Alamofire
import SwiftyJSON

protocol StopDetailModelDelegate {
   func timetableDidUpdate()
   func timetableUpdateFailed()
   func favouriteStatusDidChange(newValue: Bool)
}

class StopDetailModel: NSObject {
   
   // Stop the model relates to.
   let stop: PTVStop
   
   // Delegate this object responds to.
   var delegate: StopDetailModelDelegate?
   
   // Timetable for this stop.
   var timetable: [PTVDirection: [PTVTimetableItem]] {
      return self.departuresModel!.timetable
   }
   
   // List of dictionary keys for the timetable.
   var timetableKeys: [PTVDirection] {
      return self.departuresModel!.timetableKeys
   }
   
   // Reminder model reference
   let reminderModel = ReminderModel.sharedModel
   
   // Favourites model reference
   let favouritesModel = FavouritesModel.sharedModel
   
   // Departure model reference.
   var departuresModel: NextDeparturesModel?
   
   // Initialiser.
   init(stop: PTVStop, delegate: StopDetailModelDelegate? = nil) {
      
      self.stop = stop
      self.delegate = delegate
      super.init()
      
      // Set departures model reference.
      self.departuresModel = NextDeparturesModel(stop: self.stop, delegate: self)
      
      // Register for notifications sent by the favourites model.
      NSNotificationCenter.defaultCenter().addObserver(self,
                     selector: #selector(favouritesDidChange),
                     name: FavouriteCoreDataChangeNotificationType.DidChange.notificationKey,
                     object: nil)
   }
   
   // Returns the next departure from the timetable, or nil if not found.
   var nextDeparture: PTVTimetableItem? {
      return self.departuresModel?.nextDeparture
   }
   
   // Set the current stop as a favourite, and returns the success as a bool
   func setFavourite(setting: Bool) -> Bool {
      if setting == true {
         if favouritesModel.addStopAsFavourite(stop) {
            return true
         } else {
            return false
         }
      } else {
         if favouritesModel.removeStopAsFavourite(stop) {
            return false
         } else {
            return true
         }
      }
   }
   
   // Returns the favourite status of the stop.
   var isFavourite: Bool {
      get {
         return favouritesModel.favouriteStatus(forStop: stop).result
      }
   }
   
   // Receiver for favourites change notification.
   func favouritesDidChange(notification: NSNotification) {
      
      // Advise delegate favourite status changed,a nd provide it's new value.
      self.delegate?.favouriteStatusDidChange(self.isFavourite)
      
   }
   
   // Set a location reminder for this stop. Returns a tuple containing the success and an error message if required.
   func setReminder(setting: Bool) -> (success: Bool, message: String) {
      
      var success = false
      var message = "Unknown Error"
      
      // Sets location reminder and returns results.
      let toggleResult = reminderModel.setLocationReminder(forStop: stop, enabled: setting)
      
      success = toggleResult.success
      message = toggleResult.message
      
      return (success, message)
      
   }
   
   // Checks the reminder model if a reminder is set and returns the result.
   var reminderSet: Bool {
      get {
         
         let reminder = reminderModel.locationReminderIsSet(forStop: stop)
         return reminder.setting
      }
   }
   
   // Returns the total number of keys in the timetable dictionary.
   var timetableSections: Int {
      return self.timetableKeys.count
   }
   
   // Generates a header for use as a tableview header view based on the route type of the stop.
   func headerTextForSection(section: Int) -> String {
      let key = timetableKeys[section]
      let directionName = key.directionName
      let line = key.line!
      
      let type = key.line!.routeType
      
      switch type {
      case .MetroTrain, .Bus, .Tram: return "Towards \(directionName): \(line.lineNameShort)"
      case .NightRider: return "Towards \(directionName): Route \(line.lineNumber)"
      case .VLine: return "To \(directionName): \(line.lineNameShort) Route"
         
      default: return "To \(directionName): \(line.lineNumber) Line"
         
      }
   }
   
   // Returns a count of rows for a specified timetable section.
   func timetableRowsForSection(section: Int) -> Int {
      let key = timetableKeys[section]
      if let count = timetable[key]?.count
      {
         return count
      }
      
      return 0
   }
   
   
   // Returns a timetable item for a specific index path, or nil if not found.
   func timetableItemForIndexPath(indexPath: NSIndexPath) -> PTVTimetableItem? {
      let key = timetableKeys[indexPath.section]
      
      return timetable[key]?[indexPath.row]
   }
   
   // Sets a timetable reminder for a specific item, and returns a tuple containing the new setting, the success, and an error message if required.
   func toggleReminderForTimetableItemAtIndexPath(indexPath: NSIndexPath) -> (newSetting: Bool, success: Bool, reason: String) {
      
      // Store the status of the timetable setting)
      var success = false
      var newSetting = false
      var message = "Unknown Error"
      
      // Retreive timetable item
      guard let timetableItem = self.timetableItemForIndexPath(indexPath) else {
         message = "Unable to retrieve timetable item."
         return (newSetting, success, message)
      }
      
      // Retrieve current setting
      let currentSetting = reminderModel.timetableReminderIsSet(forTimetableItem: timetableItem)
      newSetting = !currentSetting.setting
      
      // Set new setting
      let setResult = reminderModel.setTimetableReminder(forTimetableItem: timetableItem, enabled: newSetting)
      success = setResult.success
      message = setResult.message
      
      // Return new setting.
      return (newSetting, success, message)
   }
   
   // Retrieves a timetable status for an item at a specific index path.
   func reminderSettingForTimetableItemAtIndexPath(indexPath: NSIndexPath) -> (setting: Bool, message: String) {
      
      // Retreive timetable item
      guard let timetableItem = self.timetableItemForIndexPath(indexPath) else {
         
         return (false, "Unable to locate timetable item.")
      }
      
      // Return reminder setting from reminder model.
      return reminderModel.timetableReminderIsSet(forTimetableItem: timetableItem)
      
   }
   
   // Accesses MapKit to get directions.
   func getDirections(fromLocation: CLLocationCoordinate2D, withTransportType transportType: MKDirectionsTransportType, completion: ((route: MKRoute?, error: NSError?) -> Void)?) {
      
      // Create map item with this stop's location
      let destPlacemark = MKPlacemark(coordinate: self.stop.coordinate, addressDictionary: nil)
      let destItem = MKMapItem(placemark: destPlacemark)
      
      // Create map item with source coordinates
      let sourcePlacemark = MKPlacemark(coordinate: fromLocation, addressDictionary: nil)
      let sourceItem = MKMapItem(placemark: sourcePlacemark)
      
      // Create directions request
      let directionsRequest = MKDirectionsRequest()
      
      // Set up directions request
      directionsRequest.transportType = transportType
      directionsRequest.source = sourceItem
      directionsRequest.destination = destItem
      
      // Create directions object
      let directions = MKDirections(request: directionsRequest)
      
      directions.calculateDirectionsWithCompletionHandler { (response, error) in
         if error != nil {
            completion?(route: nil, error: error)
         } else {
            let route = response?.routes[0]
            completion?(route: route, error: nil)
         }
      }
   }
}

extension StopDetailModel: NextDeparturesModelDelegate {
   func timetableWillUpdate() {
      // No Implementation in this class.
   }
   
   func timetableDidUpdate() {
      self.delegate?.timetableDidUpdate()
   }
   
   func timetableUpdateFailed() {
      self.delegate?.timetableUpdateFailed()
   }
}
