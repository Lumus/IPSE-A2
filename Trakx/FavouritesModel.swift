//
//  FavouritesModel.swift
//  Trakx
//
//  Created by Matt Croxson on 20/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import CoreData

class FavouritesModel: NSObject, NSFetchedResultsControllerDelegate {
   
   // Singleton instance.
   static let sharedModel = FavouritesModel()
   
   // Gets the reference to the CoreData managed object context from the app delegate.
   let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
   
   // Stores a fetched results controller for accessing CoreData.
   lazy var fetchedResultsController: NSFetchedResultsController = {
      
      let stopsFetchRequest = NSFetchRequest(entityName: "FavouriteStop")
      let primarySortDescriptor = NSSortDescriptor(key: "lineType.typeName", ascending: true)
      let secondarySortDescriptor = NSSortDescriptor(key: "locationName", ascending: true)
      stopsFetchRequest.sortDescriptors = [primarySortDescriptor]
      
      let frc = NSFetchedResultsController(fetchRequest: stopsFetchRequest, managedObjectContext: self.context, sectionNameKeyPath: "lineType.typeName", cacheName: nil)
      frc.delegate = self
      
      return frc
      
   }()
   
   // Initialiser
   private override init() {
      super.init()
      
      // Attempt a fetch from the fetched results controller.
      do {
         try fetchedResultsController.performFetch()
      } catch {
         print("An error occurred")
      }
   }
   
   // Adds a passed stop as a favourite to the database.
   func addStopAsFavourite(stop: PTVStop) -> Bool {
      
      // Stop entity description
      let entityDescription = NSEntityDescription.entityForName("FavouriteStop", inManagedObjectContext: self.context)
      let newStop = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: self.context) as! FavouriteStop
      
      // Set entity properties.
      newStop.stopID = stop.stopID
      newStop.locationName = stop.locationName
      
      // Encodes stop for saving using NSData.
      let encodedStop = NSKeyedArchiver.archivedDataWithRootObject(stop)
      newStop.stopObject = encodedStop
      
      // Line Type entity description. Used to group stops.
      let lineType = stop.transportType
      let lineEntity = NSEntityDescription.entityForName("FavouriteLineType", inManagedObjectContext: self.context)
      let newLine = NSManagedObject(entity: lineEntity!, insertIntoManagedObjectContext: self.context) as! FavouriteLineType
      
      // Set line properties.
      newLine.typeName = stop.transportType.description
      newLine.lineID = lineType.rawValue
      
      // Set new stop line type to create relationship.
      newStop.lineType = newLine
      
      // Attempt to save data.
      do {
         try newStop.managedObjectContext?.save()
         return true
      } catch {
         print(error)
         return false
      }
      
   }
   
   // Remove a specified stop from the database, and returns the success.
   func removeStopAsFavourite(stop: PTVStop) -> Bool {
      
      // Confirm object is a favourite.
      let status = self.favouriteStatus(forStop: stop)
      if let object = status.object {
         
         // Delete object from context
         self.context.deleteObject(object)
         
         do {
            
            // Attempt to save the change
            try self.context.save()
            
            // If there are no child objects left, remove the parent LineType.
            if object.lineType.favouriteStops?.count == 0 {
               
               if self.removeLineAsFavourite(object.lineType) == false {
                  return false
               }
            }
            
         } catch {
            print(error)
            return false
         }
         
         // Attempt to re-fetch new data.
         do {
            try fetchedResultsController.performFetch()
            return true
         } catch {
            print(error)
            return false
         }
         
         
      }
      
      return false
      
   }
   
   // Remove a specified line type from the database, and returns the success.
   private func removeLineAsFavourite(favouriteLine: FavouriteLineType) -> Bool {
      
      self.context.deleteObject(favouriteLine)
      
      do {
         try self.context.save()
         
         
         
      } catch {
         print(error)
         return false
      }
      
      do {
         try fetchedResultsController.performFetch()
         return true
      } catch {
         print(error)
         return false
      }
   
   }
   
   
   // Removes a stop at a specific index path.
   func removeStopAtIndexPath(indexPath: NSIndexPath) -> Bool {
      
      // Get object to remove.
      if let object = self.favouriteAtIndexPath(indexPath) {
         
         // Remove from context
         self.context.deleteObject(object)
         
         do {
            
            // Attempt save.
            try self.context.save()
            
            
            if object.lineType.favouriteStops?.count == 0 {
               if self.removeLineAsFavourite(object.lineType) == false {
                  return false
               }
            }
            
         } catch {
            print(error)
            return false
         }
      }
      
      return true
   }
   
   // Locate stop in database, and returns a tuple containing the status and the object if found.
   func favouriteStatus(forStop stop: PTVStop) -> (result: Bool, object: FavouriteStop?) {
      
      // Create fetch request
      let fetchRequest = NSFetchRequest()
      
      // Create entity to be retrieved and add to fetch request.
      let stopEntity = NSEntityDescription.entityForName("FavouriteStop", inManagedObjectContext: self.context)
      fetchRequest.entity = stopEntity
      
      // Set entity parameters.
      let stopID = stop.stopID
      
      // Create predicate used to search for stop
      let stopIDPredicate = NSPredicate(format: "stopID == %ld", stopID)
      
      // Add predicate to fetch request.
      fetchRequest.predicate = stopIDPredicate
      
      // Execute fetch request and return results.
      do {
         let results = try self.context.executeFetchRequest(fetchRequest)
         if results.count > 0 {
            print(results)
            return (true, results[0] as? FavouriteStop)
         } else {
            return (false, nil)
         }
      } catch {
         return (false, nil)
      }
      
   }
   
   // Return the number of sections in the results.
   var numberOfSections: Int {
      get {
         if let sections = fetchedResultsController.sections {
            return sections.count
         }
         
         return 0
      }
   }
   
   // Returns the total number of objects.
   var numberOfFavourites: Int {
      get {
         var count = 0
         
         if let sections = fetchedResultsController.sections {
            for (index, _) in sections.enumerate() {
               count = count + fetchedResultsController.sections![index].numberOfObjects
            }
         }
         
         return count
      }
   }
   
   // Returns the number of objects in a specified section.
   func numberOfRowsInSection(section: Int) -> Int {
      if let sections = fetchedResultsController.sections {
         if sections.count > 0 {
            if sections.indices.contains(section){
               let currentSection = sections[section]
               return currentSection.numberOfObjects
            }
         }
      }
      
      return 0
   }
   
   // Returns a favourite at a specific index path, or nil if not found.
   func favouriteAtIndexPath(indexPath: NSIndexPath) -> FavouriteStop? {
      let result = self.fetchedResultsController.objectAtIndexPath(indexPath) as? FavouriteStop
      return result
   }
   
   // Returns the seciton name for a specifiec section index, or nil if not found.
   func headerTitleForSection(section: Int) -> String? {
      if let sections = fetchedResultsController.sections {
         let currentSection = sections[section]
         return currentSection.name
      }
      
      return nil
   }
   
   // Returns a line type for a specific section index, or nil if not found.
   func lineTypeForSection(section: Int) -> PTVLineType? {
      if let sections = fetchedResultsController.sections {
         let currentSection = sections[section]
         let lineType = PTVLineType(description: currentSection.name)
         return lineType
      }
      
      return nil
   }
   
   // Helper function to post notifications to listening objects.
   private func postNotification(type: FavouriteCoreDataChangeNotificationType, object: AnyObject? = nil) {
      let nc = NSNotificationCenter.defaultCenter()
      let notification = NSNotification(name: type.notificationKey, object: object)
      nc.postNotification(notification)
   }
   
// MARK: - Fetched Results Controller Delegate
   
   func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
      
      switch type {
      case .Insert:
         self.postNotification(.InsertSection, object: sectionIndex)
         
      case .Delete:
         self.postNotification(.DeleteSection, object: sectionIndex)
         
      case .Update:
         self.postNotification(.UpdateSection, object: sectionIndex)
         
      case .Move:
         self.postNotification(.MoveSection, object: sectionIndex)
      }
   }
   
   func controllerWillChangeContent(controller: NSFetchedResultsController) {
   
      self.postNotification(.WillChange)
   }
   
   func controllerDidChangeContent(controller: NSFetchedResultsController) {
   
      self.postNotification(.DidChange)
   }
   
   func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
      switch (type) {
      case .Insert:
         self.postNotification(.Insert, object: newIndexPath)
         
      case .Delete:
         self.postNotification(.Delete, object: indexPath)
         
      case .Update:
         self.postNotification(.Update, object: indexPath)
         
      case .Move:
         self.postNotification(.Move, object: indexPath)
         
      }
   }
   
   
}

// Notification keys used by helper function to post notifications about coredata changes. 
enum FavouriteCoreDataChangeNotificationType: String {
   case WillChange, DidChange, Insert, Delete, Update, Move, InsertSection, DeleteSection, UpdateSection, MoveSection
   
   var notificationKey: String {
      switch self {
      case .WillChange: return "TrakxCoreDataWillChangeNotification"
      case .DidChange: return "TrakxCoreDataDidChangeNotification"
      case .Insert: return "TrakxCoreDataInsertNotification"
      case .Delete: return "TrakxCoreDataDeleteNotification"
      case .Update: return "TrakxCoreDataUpdateNotification"
      case .Move: return "TrakxCoreDataMoveNotification"
      case .InsertSection: return "TrakxCoreDataInsertSectionNotification"
      case .DeleteSection: return "TrakxCoreDataDeleteSectionNotification"
      case .UpdateSection: return "TrakxCoreDataUpdateSectionNotification"
      case .MoveSection: return "TrakxCoreDataMoveSectionNotification"
      }
   }
}
