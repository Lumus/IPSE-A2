//
//  StoppingPatternTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 20/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class StoppingPatternTableViewController: UITableViewController {
   
   var timetableItem: PTVTimetableItem!
   var stoppingPatternModel: StoppingPatternModel!
   let timeFormatter = NSDateFormatter()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false
      
      // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
      // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      let stop = timetableItem.timetablePlatform?.platformStop
      let run = timetableItem.timetableRun
      let line = timetableItem.timetablePlatform?.platformDirection?.line
      
      timeFormatter.timeStyle = .ShortStyle
      
      // Set up table view cell for automatic height.
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 40.0
      
      stoppingPatternModel = StoppingPatternModel(stop: stop!, run: run!, line: line!, delegate: self)
      stoppingPatternModel.getStoppingPattern()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // MARK: - Table view data source
   
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return stoppingPatternModel.numberOfSections
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      return stoppingPatternModel.numberOfStopsInSection(section)
   }
   
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("StoppingPatternCell", forIndexPath: indexPath) as! StoppingPatternTableViewCell
      
      let stoppingPatternItem = stoppingPatternModel.itemAtIndexPath(indexPath)
      
      if let realtimeTime = stoppingPatternItem.realtimeTimeUTC {
         cell.timeLabel.text = timeFormatter.stringFromDate(realtimeTime)
      } else {
         cell.timeLabel.text = timeFormatter.stringFromDate(stoppingPatternItem.timetableTimeUTC)
      }
      
      
      cell.destinationLabel.text = stoppingPatternItem.timetablePlatform?.platformStop?.locationName
      
      var reminderButtonTitle: String
      
      if stoppingPatternModel.reminderSettingForItemAtIndexPath(indexPath).setting {
         cell.reminderImageView.tintColor = UIColor.appTintColour
         cell.reminderImageView.image = UIImage(named:"Appointment Reminders Filled-22")
         reminderButtonTitle = "Cancel Reminder"
         
      } else {
         cell.reminderImageView.tintColor = UIColor.lightGrayColor()
         cell.reminderImageView.image = UIImage(named:"Appointment Reminders-22")
         reminderButtonTitle = "Set Reminder"
      }

      
      let routeType = stoppingPatternItem.timetablePlatform?.platformDirection?.line?.routeType
      cell.lineView.backgroundColor = routeType?.bgColor
      
      
      if stoppingPatternItem.timetablePlatform?.platformStop?.stopID == timetableItem.timetablePlatform?.platformStop?.stopID {
         cell.stationNodeView.backgroundColor = routeType?.bgColor
         cell.stationNodeView.layer.borderColor = routeType?.bgColor.CGColor
         cell.stationNodeView.layer.borderWidth = 2.0
         cell.stationNodeView.layer.cornerRadius = 0.5 * cell.stationNodeView.frame.size.height
      } else {
         cell.stationNodeView.backgroundColor = routeType?.highlighColor
         cell.stationNodeView.layer.borderColor = routeType?.bgColor.CGColor
         cell.stationNodeView.layer.borderWidth = 2.0
         cell.stationNodeView.layer.cornerRadius = 0.5 * cell.stationNodeView.frame.size.height
      }
      
      
      let setReminderButton = MGSwipeButton(title: reminderButtonTitle, backgroundColor: UIColor.appTintColour, callback: {
         (sender: MGSwipeTableCell!) -> Bool in
         
         let toggleResult = self.stoppingPatternModel.toggleReminderForItemAtIndexPath(indexPath)
         
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
      
      return cell
   }
   
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
   }
}


extension StoppingPatternTableViewController: StoppingPatternModelDelegate {
   func stoppingPatternDidUpdate() {
      self.tableView.reloadData()
   }
   
   func stoppingPatternUpdateFailed() {
      // Display alert identifiying failure
      let failureAC = UIAlertController(title: "Timetable Retrieval Failed", message: "A failure has occured retrieving timetable information. Please try again later.", preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
      failureAC.addAction(okAction)
      
      self.presentViewController(failureAC, animated: true, completion: nil)
      
      
   }
}
