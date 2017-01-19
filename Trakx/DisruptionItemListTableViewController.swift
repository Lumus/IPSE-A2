//
//  DisruptionItemListTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 12/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class DisruptionItemListTableViewController: UITableViewController {
   
   var disruptionModel = DisruptionsModel.sharedModel
   var disruptionMode: PTVDisruptionMode!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      self.title = disruptionMode?.description
      
      // Set up table view cell for automatic height.
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 40.0
      
      // Uncomment the following line to preserve selection between presentations
      // self.clearsSelectionOnViewWillAppear = false
      
      // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
      // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      
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
      return 1 // Only 1 list of disruptions in this view.
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of rows
      return disruptionModel.disruptionCountForModes([disruptionMode])
   }
   
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("DisruptionItemCell", forIndexPath: indexPath)
      
      let disruption = disruptionModel.disruptionForMode(self.disruptionMode, atRow: indexPath.row)
      
      cell.textLabel?.text = disruption?.title
      
      return cell
   }
   
   
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      self.performSegueWithIdentifier("ShowDisruptionDetailSegue", sender: nil)
   }
   
   
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
   }
   
   
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
      
      if segue.identifier == "ShowDisruptionDetailSegue" {
         
         let detailVC = segue.destinationViewController as! DisruptionDetailTableViewController
         
         let selectedIndex = self.tableView.indexPathForSelectedRow
         let selectedDisruption = self.disruptionModel.disruptionForMode(self.disruptionMode, atRow: selectedIndex!.row)
         
         detailVC.disruption = selectedDisruption
         detailVC.disruptionMode = self.disruptionMode
         
      }
      
   }
   
}

// *********************************
// MARK: - 3D Touch Previewing Delegate
// *********************************
extension DisruptionItemListTableViewController: UIViewControllerPreviewingDelegate {
   func forceTouchAvailable() -> Bool {
      return self.traitCollection.forceTouchCapability == .Available
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      guard let indexPath = self.tableView.indexPathForRowAtPoint(location) else { return nil }
      
      guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) else { return nil }
      
      guard let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("disruptionDetailTableViewController") as? DisruptionDetailTableViewController else { return nil }
      
      let selectedDisruption = self.disruptionModel.disruptionForMode(self.disruptionMode, atRow: indexPath.row)
      
      detailVC.disruption = selectedDisruption
      detailVC.preferredContentSize = CGSize(width: 0.0, height: 450)
      detailVC.disruptionMode = self.disruptionMode
      
      previewingContext.sourceRect = cell.frame
      
      return detailVC
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
      showViewController(viewControllerToCommit, sender: self)
   }
}
