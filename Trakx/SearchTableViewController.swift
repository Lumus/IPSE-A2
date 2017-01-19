
//
//  SearchTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 3/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
   
   var searchModel: SearchModel!
   
   // MARK: - Constants (Objects)
   let searchController = UISearchController(searchResultsController: nil)
   
   // MARK: - IB Outlets
   
   // MARK: - Variables
   var searchTimer = NSTimer()
   var searchText = ""
   
   var selectedResult: PTVSearchResult? = nil
   
   override func viewDidLoad() {
      
      super.viewDidLoad()
      
      self.searchModel = SearchModel(delegate: self)
      
      // Set up table view cell for automatic height.
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 160.0
      
      // Set up search results controller
      self.searchController.searchResultsUpdater = self
      self.searchController.dimsBackgroundDuringPresentation = false
      self.searchController.extendedLayoutIncludesOpaqueBars = true
      self.searchController.searchBar.sizeToFit()
      
      self.definesPresentationContext = true
      self.tableView.tableHeaderView = searchController.searchBar
      self.tableView.backgroundView = UIView()
      
      if traitCollection.forceTouchCapability == .Available {
         self.registerForPreviewingWithDelegate(self, sourceView: self.view)
      }
      
   }
   
   override func viewWillAppear(animated: Bool) {
      
      // Deselects selected row when re-appearing (if one is selected).
      guard let row = tableView.indexPathForSelectedRow else { return }
      tableView.deselectRowAtIndexPath(row, animated: true)
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // MARK: - Table view data source
   
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return self.searchModel.numberOfSections
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.searchModel.numberOfRowsInSection(section)
   }
   
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath)
      
      // Configure the cell...
      if let searchResult = searchModel.searchResultAtIndexPath(indexPath) {
         cell.textLabel?.text = searchResult.title
         cell.detailTextLabel?.text = searchResult.subtitle
         cell.accessoryType = .DisclosureIndicator
      }
      
      return cell
   }
   
   override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return self.searchModel.titleForSection(section)
   }
   
   override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
      let header = view as! UITableViewHeaderFooterView
      
      header.textLabel?.textColor = UIColor.whiteColor()
   }
   
   override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
      // Create a new header view
      let view = UITableViewHeaderFooterView()
      
      // Set header view background
      
      view.contentView.backgroundColor = UIColor.appTintColour
      
      // Return the new view.
      return view

   }
   
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      let result = self.searchModel.searchResultAtIndexPath(indexPath)
      let type = self.searchModel.typeForSection(indexPath.section)
      
      self.selectedResult = result
      
      if type == .Stop {
         self.performSegueWithIdentifier("ShowStopDetailSegue", sender: nil)
      } else if type == .Line {
         self.performSegueWithIdentifier("ShowLineDetailSegue", sender: nil)
      }
   }
   
   // MARK: - Search
   
   func performSearch(searchText text: String) {
      
      if text == "" || text.characters.count < 3 {
         // Clear Table
         tableView.reloadData()
      } else {
         // print("search")
         self.searchText = text.stringByReplacingOccurrencesOfString(" ", withString: "%20")
         
         // Invalidated existing search timer.
         searchTimer.invalidate()
         
         // Re-create search timer to buffer search requests.
         searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.runSearch), userInfo: nil, repeats: false)
         
      }
   }
   
   func runSearch() {
      self.searchModel.performSearch(withSearchTerm: self.searchText)
   }
   
   
   // MARK: Navigation
   
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "ShowStopDetailSegue" {
         let destVC = segue.destinationViewController as? StopDetailTableViewController
         destVC?.stop = self.selectedResult?.stopObject
      } else if segue.identifier == "ShowLineDetailSegue" {
         let destVC = segue.destinationViewController as? LineDetailTableViewController
         destVC?.line = self.selectedResult?.lineObject
      }
   }
}


// MARK: - Search Results Protocol
extension SearchTableViewController: UISearchResultsUpdating {
   func updateSearchResultsForSearchController(searchController: UISearchController) {
      
      self.performSearch(searchText: searchController.searchBar.text!)
   }
   
}

// MARK: - Search Model Delegate
extension SearchTableViewController: SearchModelDelegate {
   func searchWillStart() {
      //TODO: Design some indication search is being performed.b
   }
   
   func searchDidComplete() {
      self.tableView.reloadData()
   }
   
   func searchFailed(response: String) {
      // Generate alert to advise user of error
      let searchFailure = UIAlertController(title: "Search Failed", message: response, preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
      searchFailure.addAction(okAction)
      
      self.presentViewController(searchFailure, animated: true, completion: nil)
   }
}

// *********************************
// MARK: - 3D Touch Previewing Delegate
// *********************************
extension SearchTableViewController: UIViewControllerPreviewingDelegate {
   func forceTouchAvailable() -> Bool {
      return self.traitCollection.forceTouchCapability == .Available
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      guard let indexPath = self.tableView.indexPathForRowAtPoint(location) else { return nil }
      
      guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) else { return nil }
      
      let selectedResult = self.searchModel.searchResultAtIndexPath(indexPath)
      
      switch selectedResult!.searchResultType {
      case .Line:
         
         guard let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("lineDetailTableViewController") as? LineDetailTableViewController else { return nil }
         
         detailVC.line = selectedResult!.lineObject!
         detailVC.preferredContentSize = CGSize(width: 0.0, height: 450)
         
         previewingContext.sourceRect = cell.frame
         
         return detailVC

         
      case .Stop:
         
         guard let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("stopDetailTableViewController") as? StopDetailTableViewController else { return nil }
         
         detailVC.stop = selectedResult!.stopObject!
         detailVC.preferredContentSize = CGSize(width: 0.0, height: 450)
         
         previewingContext.sourceRect = cell.frame
         
         return detailVC
         
      }
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
      showViewController(viewControllerToCommit, sender: self)
   }
}
