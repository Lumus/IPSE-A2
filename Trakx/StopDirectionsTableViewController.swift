//
//  StopDirectionsTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 6/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import MapKit

class StopDirectionsTableViewController: UITableViewController {
   
   var route: MKRoute!
   var startCoordinate: CLLocationCoordinate2D!
   var endCoordinate: CLLocationCoordinate2D!
   
   @IBOutlet weak var routeTypeImageView: UIImageView!
   @IBOutlet weak var routeTypeLabel: UILabel!
   @IBOutlet weak var routeNameLabel: UILabel!
   @IBOutlet weak var routeDistanceLabel: UILabel!
   @IBOutlet weak var routeETALabel: UILabel!
   
   //   let timeFormatter = NSDateFormatter()
   let timeFormatter = NSDateComponentsFormatter()
   let distanceFormatter = MKDistanceFormatter()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      //      timeFormatter.timeStyle = .MediumStyle
      timeFormatter.unitsStyle = .Short
      
      self.routeNameLabel.text = self.route.name
      self.routeDistanceLabel.text = self.distanceFormatter.stringFromDistance(self.route.distance)
      
      //      let newTime = NSDate().dateByAddingTimeInterval(self.route.expectedTravelTime)
      //      self.routeETALabel.text = self.timeFormatter.stringFromDate(newTime)
      self.routeETALabel.text = self.timeFormatter.stringFromTimeInterval(self.route.expectedTravelTime)
      
      self.routeTypeLabel.text = self.route.transportType.typeName
      self.routeTypeImageView.image = self.route.transportType.iconImage
      
      // Set up table view cell for automatic height.
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 40.0
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   
   @IBAction func openInMaps() {
      
      
      // Determine if Google Maps is avaiable.
      if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
         // Use alert controller to display option for Apple Maps or Google Maps
         let mapsAppAlert = UIAlertController(title: "Open in...", message: "Please select which app you want to view directions in?", preferredStyle: .ActionSheet)
         let googleAction = UIAlertAction(title: "Google Maps", style: .Default, handler: { (action) in
            let mapsString = "comgooglemaps://?saddr=\(self.startCoordinate.latitude),\(self.startCoordinate.longitude)&daddr=\(self.endCoordinate.latitude),\(self.endCoordinate.longitude)&directionsmode=\(self.route.transportType.googleTypeFlag!)&t=m"
            
            self.openMapsURLfromString(mapsString)
            
         })
         
         let appleAction = UIAlertAction(title: "Apple Maps", style: .Default, handler: { (action) in
            
            let mapsString = "http://maps.apple.com/?saddr=\(self.startCoordinate.latitude),\(self.startCoordinate.longitude)&daddr=\(self.endCoordinate.latitude),\(self.endCoordinate.longitude)&dirflg=\(self.route.transportType.typeFlag!)&t=m"
            self.openMapsURLfromString(mapsString)
         })
         
         let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
         
         mapsAppAlert.addAction(appleAction)
         mapsAppAlert.addAction(googleAction)
         mapsAppAlert.addAction(cancelAction)
         
         self.presentViewController(mapsAppAlert, animated: true, completion: nil)
         
         
      } else {
         let mapsString = "http://maps.apple.com/?saddr=\(startCoordinate.latitude),\(startCoordinate.longitude)&daddr=\(endCoordinate.latitude),\(endCoordinate.longitude)&dirflg=\(self.route.transportType.typeFlag!)&t=m"
         
         self.openMapsURLfromString(mapsString)
      }
      
   }
   
   func openMapsURLfromString(mapsString: String) {
      
      if let mapsURL = NSURL(string: mapsString) {
         UIApplication.sharedApplication().openURL(mapsURL)
      } else {
         // TODO: Display error alert view controller.
      }
   }
   
   
   // MARK: - Table view data source
   
   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
   }
   
   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      return self.route.steps.count
      
   }
   
   
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("DirectionCell", forIndexPath: indexPath) as! StopDirectionTableViewCell
      
      // Configure the cell...
      let routeItem = self.route.steps[indexPath.row]
      
      let instructionText = "In \(self.distanceFormatter.stringFromDistance(routeItem.distance)), \(routeItem.instructions)"
      
      cell.directionLabel.text = instructionText
      
      return cell
   }
   
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
   }
}
