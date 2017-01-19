//
//  LineDetailTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 3/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class LineDetailTableViewController: UITableViewController {
   
   var line: PTVLine!
   var selectedStop: PTVStop? = nil
   
   private var lineDetailModel: LineDetailModel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      self.lineDetailModel = LineDetailModel(line: self.line, delegate: self)
      
      self.title = line.lineName
      
      self.lineDetailModel.getStopsOnLine()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // MARK: - Table view data source
   
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      
      return lineDetailModel.numberOfSections
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      return lineDetailModel.numberOfStopsInSection(section)
   }
   
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      // Configure the cell...
      
      let cell = tableView.dequeueReusableCellWithIdentifier("LineDetailCell", forIndexPath: indexPath) as! LineDetailTableViewCell
      
      let stopItem = lineDetailModel.stopAtIndexPath(indexPath)
      
      cell.nameLabel.text = stopItem.locationName
      
      var reminderButtonTitle: String
      
      if lineDetailModel.reminderSettingForStopAtIndexPath(indexPath).setting {
         cell.reminderImageView.tintColor = UIColor.appTintColour
         cell.reminderImageView.image = UIImage(named:"Geo-fence Filled-25")
         reminderButtonTitle = "Cancel Reminder"
      } else {
         cell.reminderImageView.tintColor = UIColor.lightGrayColor()
         cell.reminderImageView.image = UIImage(named: "Geo-fence-25")
         reminderButtonTitle = "Set Reminder"
      }
      
      let routeType = line.routeType
      
      cell.lineView.backgroundColor = routeType.bgColor
      
      cell.stationNodeView.backgroundColor = routeType.highlighColor
      cell.stationNodeView.layer.borderColor = routeType.bgColor.CGColor
      cell.stationNodeView.layer.borderWidth = 2.0
      cell.stationNodeView.layer.cornerRadius = 0.5 * cell.stationNodeView.frame.size.height
      
      let setReminderButton = MGSwipeButton(title: reminderButtonTitle, backgroundColor: UIColor.appTintColour) { (sender) -> Bool in
         let toggleResult = self.lineDetailModel.toggleReminderForItemAtIndexPath(indexPath)
         
         if toggleResult.success == true {
            
            if toggleResult.newSetting == true {
               cell.reminderImageView.image = UIImage(named: "Geo-fence Filled-25")
               cell.reminderImageView.tintColor = UIColor.appTintColour
               
               (sender.rightButtons[0] as? MGSwipeButton)?.setTitle("Cancel Reminder", forState: .Normal)
               
            } else {
               cell.reminderImageView.image = UIImage(named: "Geo-fence-25")
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
      }
      
      setReminderButton.imageView?.tintColor = UIColor.whiteColor()
      
      cell.rightButtons = [setReminderButton]
      
      return cell
   }
   
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
   }
 
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      let stopItem = self.lineDetailModel.stopAtIndexPath(indexPath)
      self.selectedStop = stopItem
   }
   
   // MARK: Navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "ShowStopDetailSegue" {
         let destVC = segue.destinationViewController as? StopDetailTableViewController
         destVC?.stop = self.selectedStop
      }
   }
   
}

extension LineDetailTableViewController: LineDetailModelDelegate {
   func lineDetailDidUpdate() {
      self.tableView.reloadData()
   }
   
   func lineDetailWillUpdate() {
      
   }
   
   func lineDetailUpdateFailed(message: String) {
      // Generate alert to advise user of error
      let searchFailure = UIAlertController(title: "Load Failed", message: message, preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
      searchFailure.addAction(okAction)
      
      self.presentViewController(searchFailure, animated: true, completion: nil)
   }
}
