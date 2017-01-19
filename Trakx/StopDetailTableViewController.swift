//
//  StopDetailTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 6/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import MapKit

class StopDetailTableViewController: UITableViewController {
   
   var stopDetailModel: StopDetailModel!
   var stop: PTVStop!
   var directionsFromLocation: CLLocationCoordinate2D?
   var directionsRoute: MKRoute?
   let locationManager = CLLocationManager()
   
   private var selectedItem: PTVTimetableItem!
   
   // IBOutlets
   @IBOutlet weak var lineTypeView: UIView!
   @IBOutlet weak var lineTypeIcon: UIImageView!
   @IBOutlet weak var lineTypeLabel: UILabel!
   
   @IBOutlet weak var reminderButton: UIButton!
   @IBOutlet weak var favouriteButton: UIButton!
   
   @IBOutlet weak var directionsButtonContainer: UIStackView!
   
   let dateFormatter = NSDateFormatter()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      self.stopDetailModel = StopDetailModel(stop: stop, delegate: self)
      
      // Set up line type icon view
      let transportType = stopDetailModel.stop.transportType
      lineTypeView.backgroundColor = transportType.bgColor
      lineTypeIcon.image = transportType.typeImage
      lineTypeIcon.tintColor = transportType.highlighColor
      lineTypeLabel.textColor = lineTypeIcon.tintColor
      lineTypeLabel.text = transportType.description
      
      self.title = stopDetailModel.stop.locationName
      
      if self.stopDetailModel.reminderSet {
         reminderButton.setImage(UIImage(named: "Geo-fence Filled-25"), forState: .Normal)
      } else {
         reminderButton.setImage(UIImage(named: "Geo-fence-25"), forState: .Normal)
      }
      
      if self.stopDetailModel.isFavourite {
         favouriteButton.setImage(UIImage(named: "Star Filled-25"), forState: .Normal)
      } else {
         favouriteButton.setImage(UIImage(named: "Star-25"), forState: .Normal)
      }
      
      if directionsFromLocation == nil {
         directionsButtonContainer.hidden = true
      } else {
         directionsButtonContainer.hidden = false
      }

      if traitCollection.forceTouchCapability == .Available {
         self.registerForPreviewingWithDelegate(self, sourceView: self.view)
      }
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // MARK: - Table view data source
   
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      // #warning Incomplete implementation, return the number of sections
      return stopDetailModel.timetableSections
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of rows
      return stopDetailModel.timetableRowsForSection(section)
   }
   
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("TimetableCell", forIndexPath: indexPath) as! TimetableTableViewCell
      
      if let timetableItem = stopDetailModel.timetableItemForIndexPath(indexPath) {
         
         dateFormatter.timeStyle = .ShortStyle
         let date = timetableItem.timetableTimeUTC
         cell.timeLabel.text = dateFormatter.stringFromDate(date)
         
         if timetableItem.timetableRun?.numSkipped > 0 {
            cell.speedLabel.text = "Limited Express"
         } else {
            cell.speedLabel.text = "All Stops"
         }
         
         if let _ = timetableItem.realtimeTimeUTC {
            cell.realtimeImageView.tintColor = UIColor.appTintColour
            cell.realtimeImageView.image = UIImage(named:"Clock Filled-15")
         } else {
            cell.realtimeImageView.tintColor = UIColor.lightGrayColor()
            cell.realtimeImageView.image = UIImage(named:"Clock-15")
         }
         
         
         var reminderButtonTitle: String
         
         if self.stopDetailModel.reminderSettingForTimetableItemAtIndexPath(indexPath).setting {
            cell.reminderImageView.tintColor = UIColor.appTintColour
            cell.reminderImageView.image = UIImage(named:"Appointment Reminders Filled-22")
            reminderButtonTitle = "Cancel Reminder"
            
         } else {
            cell.reminderImageView.tintColor = UIColor.lightGrayColor()
            cell.reminderImageView.image = UIImage(named:"Appointment Reminders-22")
            reminderButtonTitle = "Set Reminder"
         }
         
         
         let setReminderButton = MGSwipeButton(title: reminderButtonTitle, backgroundColor: UIColor.appTintColour, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            let toggleResult = self.stopDetailModel.toggleReminderForTimetableItemAtIndexPath(indexPath)
            
            if toggleResult.success == true {
               
               if toggleResult.newSetting == true {
                  cell.reminderImageView.image = UIImage(named: "Appointment Reminders Filled-22")
                  cell.reminderImageView.tintColor = UIColor.appTintColour
                  
                  (sender.rightButtons[0] as? MGSwipeButton)?.setTitle("Cancel Reminder", forState: .Normal)
                  
               } else {
                  cell.reminderImageView.image = UIImage(named: "Appointment Reminders-22")
                  cell.reminderImageView.tintColor = UIColor.lightGrayColor()
                  (sender.rightButtons[0] as? MGSwipeButton)?.setTitle("Set Reminder", forState: .Normal)
                  
               }
               
            } else {
               
               cell.hideSwipeAnimated(true)
               
               let failureAlert = UIAlertController(title: "Failure to toggle reminder", message: toggleResult.reason, preferredStyle: .Alert)
               let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
               failureAlert.addAction(okAction)
               
               // Present alert.
               self.presentViewController(failureAlert, animated: true, completion: nil)
               
            }
            
            return toggleResult.success
         })
         
         setReminderButton.imageView?.tintColor = UIColor.whiteColor()
         
         
         
         cell.rightButtons = [setReminderButton]
      }
      
      return cell
   }
   
   override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return stopDetailModel.headerTextForSection(section)
   }
   
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      self.selectedItem = self.stopDetailModel.timetableItemForIndexPath(indexPath)
      self.performSegueWithIdentifier("ShowStoppingPatternSegue", sender: nil)
   }
   
   // MARK: Stop Detail IB Actions
   @IBAction func reminderButtonTapped(sender: UIButton) {
      
      let currentSetting = self.stopDetailModel.reminderSet
      let newSetting = !currentSetting
      
      let result = self.stopDetailModel.setReminder(newSetting)
      
      if result.success == true {
         if newSetting == true {
            sender.setImage(UIImage(named: "Geo-fence Filled-25"), forState: .Normal)
         } else {
            sender.setImage(UIImage(named: "Geo-fence-25"), forState: .Normal)
         }
      } else {
         // Display failure alert
         let failAlert = UIAlertController(title: "Unable to set reminder", message: result.message, preferredStyle: .Alert)
         let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
         failAlert.addAction(okAction)
         
         self.presentViewController(failAlert,
                                    animated: true,
                                    completion: nil)
      }
      
   }
   
   @IBAction func favouriteButtonTapped(sender: UIButton) {
      let currentSetting = self.stopDetailModel.isFavourite
      let newSetting = !currentSetting
      
      if self.stopDetailModel.setFavourite(newSetting) {
         sender.setImage(UIImage(named: "Star Filled-25"), forState: .Normal)
      } else {
         sender.setImage(UIImage(named: "Star-25"), forState: .Normal)
      }
   }
   
   @IBAction func directionsButtonTapped(sender: UIButton) {
      
      if self.directionsFromLocation != nil {
         
         self.performDirectionsRequest()
         
      } else {
         
         locationManager.delegate = self
         locationManager.requestLocation()
         
      }
   }
   
   func performDirectionsRequest() {
      var routeType = MKDirectionsTransportType.Walking
      
      let typeAlert = UIAlertController(title: "Travel Type", message: "Select how you want to travel to this stop?", preferredStyle: .ActionSheet)
      let walkingAction = UIAlertAction(title: "Walking", style: .Default) { (action) in
         routeType = .Walking
         
         self.stopDetailModel.getDirections(self.directionsFromLocation!, withTransportType: routeType) { (route, error) in
            if error != nil {
               // TODO: Display Error Alert
               print(error?.localizedDescription)
            } else {
               if route != nil {
                  self.directionsRoute = route
                  self.performSegueWithIdentifier("ShowDirectionsSegue", sender: nil)
               } else {
                  // TODO: Display Error Alert
                  print("Route not returned")
               }
            }
         }
      }
      
      let drivingAction = UIAlertAction(title: "Driving", style: .Default) { (action) in
         routeType = .Automobile
         self.stopDetailModel.getDirections(self.directionsFromLocation!, withTransportType: routeType) { (route, error) in
            if error != nil {
               // TODO: Display Error Alert
               print(error?.localizedDescription)
            } else {
               if route != nil {
                  self.directionsRoute = route
                  self.performSegueWithIdentifier("ShowDirectionsSegue", sender: nil)
               } else {
                  // TODO: Display Error Alert
                  print("Route not returned")
               }
            }
         }
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
      
      typeAlert.addAction(drivingAction)
      typeAlert.addAction(walkingAction)
      typeAlert.addAction(cancelAction)
      
      self.presentViewController(typeAlert, animated: true, completion: nil)
   }
   
   // MARK: Navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "ShowStoppingPatternSegue" {
         let destVC = segue.destinationViewController as! StoppingPatternTableViewController
         destVC.timetableItem = self.selectedItem
      } else if segue.identifier == "ShowDirectionsSegue" {
         let destVC = segue.destinationViewController as! StopDirectionsTableViewController
         destVC.route = self.directionsRoute
         destVC.startCoordinate = self.directionsFromLocation
         destVC.endCoordinate = self.stop.coordinate
      }
   }
}

// MARK: - Stop Detail Model Delegate
extension StopDetailTableViewController: StopDetailModelDelegate {
   func timetableUpdateFailed() {
      // Display alert identifiying failure
      let failureAC = UIAlertController(title: "Timetable Retrieval Failed", message: "A failure has occured retrieving timetable information. Please try again later.", preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
      failureAC.addAction(okAction)
      
      self.presentViewController(failureAC, animated: true, completion: nil)
      
   }
   
   func timetableDidUpdate() {
      self.tableView.reloadData()
   }
   
   func favouriteStatusDidChange(newValue: Bool) {
      if self.stopDetailModel.isFavourite {
         self.favouriteButton.setImage(UIImage(named: "Star Filled-25"), forState: .Normal)
      } else {
         self.favouriteButton.setImage(UIImage(named: "Star-25"), forState: .Normal)
      }
   }
}

extension StopDetailTableViewController: CLLocationManagerDelegate {

   
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      self.directionsFromLocation = locations[0].coordinate
      self.performDirectionsRequest()
   }
   
   func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
      // TODO: Display error
   }
}

// *********************************
// MARK: - 3D Touch Previewing Delegate
// *********************************
extension StopDetailTableViewController: UIViewControllerPreviewingDelegate {
   func forceTouchAvailable() -> Bool {
      return self.traitCollection.forceTouchCapability == .Available
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      guard let indexPath = self.tableView.indexPathForRowAtPoint(location) else { return nil }
      
      guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) else { return nil }
      
      guard let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("stoppingPatternTableViewController") as? StoppingPatternTableViewController else { return nil }
      
      let selectedTimetable = self.stopDetailModel.timetableItemForIndexPath(indexPath)
      
      
         detailVC.timetableItem = selectedTimetable
         detailVC.preferredContentSize = CGSize(width: 0.0, height: 450)
         
         previewingContext.sourceRect = cell.frame
         
         return detailVC

   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
      showViewController(viewControllerToCommit, sender: self)
   }
   
   override func previewActionItems() -> [UIPreviewActionItem] {

      if self.stopDetailModel.isFavourite {
         let removeFavouriteAction = UIPreviewAction(title: "Remove from Favourites", style: .Destructive) { (previewAction, previewController) in
            if let controller = previewController as? StopDetailTableViewController {
               let stop = controller.stop
               
               controller.stopDetailModel.favouritesModel.removeStopAsFavourite(stop)
            }
         }
         
         return [removeFavouriteAction]
      } else {
         let addFavouriteAction = UIPreviewAction(title: "Add to Favourites", style: .Default) { (previewAction, previewController) in
            if let controller = previewController as? StopDetailTableViewController {
               let stop = controller.stop
               
               controller.stopDetailModel.favouritesModel.addStopAsFavourite(stop)
            }
         }
         
         
         return [addFavouriteAction]
      }
   }
}
