//
//  FavouritesTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 20/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import CoreData

class FavouritesTableViewController: UITableViewController {
   
   var favouritesModel = FavouritesModel.sharedModel
   
   let timeFormatter = NSDateComponentsFormatter()
   
   var selectedStop: PTVStop? = nil
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
      self.navigationItem.rightBarButtonItem = self.editButtonItem()
      
      // Set up table view cell for automatic height.
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 40.0
      
      timeFormatter.unitsStyle = .Full
      timeFormatter.includesApproximationPhrase = true
      timeFormatter.allowedUnits = [.Minute ,.Hour]
      
      if traitCollection.forceTouchCapability == .Available {
         self.registerForPreviewingWithDelegate(self, sourceView: self.view)
      }
      
      let nc = NSNotificationCenter.defaultCenter()
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeContent),
                     name: FavouriteCoreDataChangeNotificationType.DidChange.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesWillChangeContent),
                     name: FavouriteCoreDataChangeNotificationType.WillChange.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeObject),
                     name: FavouriteCoreDataChangeNotificationType.Delete.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeObject),
                     name: FavouriteCoreDataChangeNotificationType.Insert.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeObject),
                     name: FavouriteCoreDataChangeNotificationType.Update.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeObject),
                     name: FavouriteCoreDataChangeNotificationType.Move.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeSection),
                     name: FavouriteCoreDataChangeNotificationType.DeleteSection.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeSection),
                     name: FavouriteCoreDataChangeNotificationType.InsertSection.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeSection),
                     name: FavouriteCoreDataChangeNotificationType.UpdateSection.notificationKey,
                     object: nil)
      
      nc.addObserver(self,
                     selector: #selector(favouritesDidChangeSection),
                     name: FavouriteCoreDataChangeNotificationType.MoveSection.notificationKey,
                     object: nil)
   }
   
   override func viewWillAppear(animated: Bool) {
      self.tableView.reloadData()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // MARK: - Table view data source
   
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      
      return self.favouritesModel.numberOfSections
      
      
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      
      return self.favouritesModel.numberOfRowsInSection(section)
      
   }
   
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
   }
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("FavouriteCell", forIndexPath: indexPath) as! FavouritesTableViewCell
      
      configureCell(cell, atIndexPath: indexPath)
      
      
      return cell
   }
   
   func configureCell(cell: FavouritesTableViewCell, atIndexPath indexPath: NSIndexPath) {
      if let favourite = self.favouritesModel.favouriteAtIndexPath(indexPath) {
         
         if let stop = favourite.stopItem() {
            
            cell.favNameLabel.text = stop.locationName
            cell.detailModel = StopDetailModel(stop: stop, delegate: cell)
            
         }
      }
   }
   
   func stringWithFormattedTimeInterval(date: NSDate) -> String {
      let timeInterval = date.timeIntervalSinceNow
      if let intervalString = timeFormatter.stringFromTimeInterval(timeInterval) {
         
         return intervalString
      }
      
      return ""
   }
   
   // Override to support conditional editing of the table view.
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      // Return false if you do not want the specified item to be editable.
      return true
   }
   
   override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      
      return self.favouritesModel.headerTitleForSection(section)
      
   }
   
   override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let key = self.favouritesModel.lineTypeForSection(section)
      
      let view = UITableViewHeaderFooterView()
      view.contentView.backgroundColor = key?.bgColor
      
      return view
   }
   
   override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
      let key = self.favouritesModel.lineTypeForSection(section)
      let header = view as! UITableViewHeaderFooterView
      header.textLabel?.textColor = key?.highlighColor
   }
   
   // Override to support editing the table view.
   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
      if editingStyle == .Delete {
         // Delete the row from the data source
         
         self.favouritesModel.removeStopAtIndexPath(indexPath)
      }
   }
   
   
   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      // Return false if you do not want the item to be re-orderable.
      return false
   }
   
   
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      self.selectedStop = self.favouritesModel.favouriteAtIndexPath(indexPath)?.stopItem()
      
      if self.selectedStop != nil {
         self.performSegueWithIdentifier("ShowStopDetailSegue", sender: nil)
      }
      
   }
   
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "ShowStopDetailSegue" {
         let destVC = segue.destinationViewController as? StopDetailTableViewController
         destVC?.stop = self.selectedStop
      }
   }
   
   
   func favouritesDidChangeContent(notification: NSNotification) {
      self.tableView.endUpdates()
   }
   
   func favouritesWillChangeContent(notification: NSNotification) {
      self.tableView.beginUpdates()
   }
   
   func favouritesDidChangeSection(notification: NSNotification) {
      switch notification.name {
      case FavouriteCoreDataChangeNotificationType.InsertSection.notificationKey:
         if let sectionIndex = notification.object as? Int {
            
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
         }
         
      case FavouriteCoreDataChangeNotificationType.DeleteSection.notificationKey:
         if let sectionIndex = notification.object as? Int {
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
         }
         
      default: print("Nothing")
      }
      
   }
   
   func favouritesDidChangeObject(notification: NSNotification) {
      
      switch notification.name {
      case FavouriteCoreDataChangeNotificationType.Insert.notificationKey:
         if let indexPath = notification.object as? NSIndexPath {
            
            print("Insert Rows: \(self.favouritesModel.numberOfRowsInSection(indexPath.section))")
            
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
         }
         
      case FavouriteCoreDataChangeNotificationType.Delete.notificationKey:
         if let indexPath = notification.object as? NSIndexPath {
            print("Delete Rows: \(self.favouritesModel.numberOfRowsInSection(indexPath.section))")
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
         }
         
      case FavouriteCoreDataChangeNotificationType.Update.notificationKey:
         if let indexPath = notification.object as? NSIndexPath {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FavouritesTableViewCell
            configureCell(cell, atIndexPath: indexPath)
         }
         
         
      default: print("Nothing")
      }
   }
}

// *********************************
// MARK: - 3D Touch Previewing Delegate
// *********************************
extension FavouritesTableViewController: UIViewControllerPreviewingDelegate {
   func forceTouchAvailable() -> Bool {
      return self.traitCollection.forceTouchCapability == .Available
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      guard let indexPath = self.tableView.indexPathForRowAtPoint(location) else { return nil }
      
      guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) else { return nil }
      
      guard let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("stopDetailTableViewController") as? StopDetailTableViewController else { return nil }
      
      let selectedFavourite = self.favouritesModel.favouriteAtIndexPath(indexPath)
      
      if let stopItem = selectedFavourite?.stopItem() {
      detailVC.stop = stopItem
      detailVC.preferredContentSize = CGSize(width: 0.0, height: 450)
      
      previewingContext.sourceRect = cell.frame
      
      return detailVC
      } else {
         return nil
      }
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
      showViewController(viewControllerToCommit, sender: self)
   }
}
