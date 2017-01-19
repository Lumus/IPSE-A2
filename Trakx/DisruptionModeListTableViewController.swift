//
//  DisruptionModeListTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 12/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class DisruptionModeListTableViewController: UITableViewController {
   
   var disruptionModel = DisruptionsModel.sharedModel
   
   override func awakeFromNib() {
      self.title = "Disruptions"
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false
      
      // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
      // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      
      // Register for notifications from disruptionModel.
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.disruptionUpdateStateChanged), name: DisruptionsModel.disruptionModelDidUpdateNotificationID, object: nil)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.disruptionUpdateStateChanged), name:DisruptionsModel.disruptionModelWillUpdateNotificationID, object: nil)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.disruptionUpdateFailed), name:DisruptionsModel.disruptionModelFailedUpdateNotificationID, object: nil)
      
      // Set refresh control target
      self.refreshControl?.addTarget(self, action: #selector(self.refreshControlTriggered), forControlEvents: .ValueChanged)
      
      // Trigger disruption request.
      self.refreshControlTriggered()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func disruptionUpdateFailed() {
      // Display alert identifiying failure
      let failureAC = UIAlertController(title: "Disruption Update Failed", message: "A failure has occured updating disruptions. Please try again later.", preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
      failureAC.addAction(okAction)
      
      self.presentViewController(failureAC, animated: true, completion: nil)
      
      if refreshControl?.refreshing == true {
         refreshControl?.endRefreshing()
      }
   }
   
   func disruptionUpdateStateChanged() {
      
      // Update rows to display change in disruption state
      if let rows = tableView.indexPathsForVisibleRows {
         self.tableView.beginUpdates()
         self.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: .Automatic)
         self.tableView.endUpdates()
      }
      
      if refreshControl?.refreshing == true {
         refreshControl?.endRefreshing()
      }
   }
   
   // MARK: - Table view data source
   
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1 // There is only one list of disruption modes
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.disruptionModel.disruptionModeCount
   }
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("DisruptionModeCell", forIndexPath: indexPath) as! DisruptionModeTableViewCell
      
      
      if let disruptionMode = disruptionModel.disruptionModeForIndexPath(indexPath) {
         
         cell.disruptionModeTitle.text = disruptionMode.description
         cell.disruptionModeCornerPointImage.tintColor = disruptionMode.bgColor
         cell.disruptionCountLabelContainer.layer.cornerRadius = cell.disruptionCountLabelContainer.frame.height / 2
         
         if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            indicator.tintColor = UIColor.appTintColour
            cell.accessoryView = indicator
         }
         
         let indicator = cell.accessoryView as! UIActivityIndicatorView
         
         if disruptionModel.disruptionsUpdating {
            // Start animating activity indicator
            indicator.startAnimating()
            
            // Hide status icon and show activity indicator
            cell.disruptionModeStatusImage.hidden = true
            
            // Hide count label
            cell.disruptionCountLabelContainer.hidden = true
            
         } else {
            // Stop animating activity indicator and remove it to display disclosure indicator
            indicator.stopAnimating()
            cell.accessoryView = nil
            
            // Show status icon and hide activity indicator
            cell.disruptionModeStatusImage.hidden = false
            let disruptionStatus = disruptionModel.disruptionStatusForModeAtIndexPath(indexPath)
            cell.disruptionModeStatusImage.image = disruptionStatus.statusImage
            
            // Display and set count label (unless count is zero)
            let disruptionCount = disruptionModel.disruptionCountForSection(indexPath.row)
            
            if disruptionCount > 0 {
               cell.disruptionCountLabelContainer.hidden = false
               cell.disruptionCountLabel.text = "\(disruptionCount)"
            } else {
               cell.disruptionCountLabelContainer.hidden = true
            }
         }
      }
      return cell
   }
   
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      if !disruptionModel.disruptionsUpdating {
         let disruptionStatus = disruptionModel.disruptionStatusForModeAtIndexPath(indexPath)
         
         if disruptionStatus == .Several {
            self.performSegueWithIdentifier("ShowDisruptionsSegue", sender: nil)
            
            
         } else {
            self.performSegueWithIdentifier("ShowNoDisruptionsSegue", sender: nil)
            
         }
      } else {
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
      }
   }
   
   // MARK: - Refreshing
   func refreshControlTriggered(manually: Bool = false) {
      
      if manually {
         self.refreshControl?.beginRefreshing()
      }
      
      disruptionModel.getDisruptions()
   }
   
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "ShowDisruptionsSegue" {
         
         let dc = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! DisruptionItemListTableViewController
         
         let selectedCellIndexPath = self.tableView.indexPathForSelectedRow
         
         let disruptionMode = disruptionModel.disruptionModeForIndexPath(selectedCellIndexPath!)
         
         dc.disruptionMode = disruptionMode
         
         
      } else if segue.identifier == "ShowNoDisruptionsSegue" {
         let dc = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! NoDisruptionsViewController
         let selectedCellIndexPath = self.tableView.indexPathForSelectedRow
         let disruptionMode = disruptionModel.disruptionModeForIndexPath(selectedCellIndexPath!)
         
         dc.title = disruptionMode?.description
         
      }
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
   }
   
   
}
