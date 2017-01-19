//
//  StopsNearbyViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 28/06/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import MapKit

class StopsNearbyViewController: UIViewController {
   
   // Model
   var model: StopsNearbyModel!
   let locationManager = CLLocationManager()
   
   var showingUserLocation: Bool = false
   var locationButtonTapped: Bool = false
   
   var directionsFromLocation: CLLocationCoordinate2D? = nil
   
   // IBOutlets
   @IBOutlet weak var mapView: MKMapView!
   @IBOutlet weak var trackUserButton: UIButton!
   @IBOutlet weak var trackUserButtonContainerView: UIView!
   @IBOutlet weak var trackUserActivityIndicatorView: UIActivityIndicatorView!
   
   override func awakeFromNib() {
      self.title = "Stops Nearby"
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      model = StopsNearbyModel(delegate: self)
      
      // Do any additional setup after loading the view.
      // Set map view initial region
      mapView.setRegion(model.mapInitialArea, animated: false)
      mapView.showsScale = true
      
      
      // Add long press gesture recogniser to allow pin-drop
      let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.userDidDropPin))
      self.mapView.addGestureRecognizer(longPressGesture)
      
      // Set location manager delegate
      locationManager.delegate = self
      
      // Check if location services are available and removes locate user button if not.
      if CLLocationManager.locationServicesEnabled() {
         self.trackUserButtonContainerView.hidden = false
      } else {
         self.trackUserButtonContainerView.hidden = true
      }
      
      self.trackUserActivityIndicatorView.hidesWhenStopped = true
      self.trackUserActivityIndicatorView.stopAnimating()
      
      // Set up track button background
      self.trackUserButtonContainerView.layer.cornerRadius = 5
      self.trackUserButtonContainerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
      
   }
   
   deinit {
      self.removeObserver(self, forKeyPath: "self.mapView.userTrackingMode")
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func userDidDropPin(gestureRecogniser: UILongPressGestureRecognizer) {
      if gestureRecogniser.state == .Began {
         print("Long Press Touch Down")
         let touchPoint = gestureRecogniser.locationInView(mapView)
         let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
         
         let selectedLocation = MKPointAnnotation()
         selectedLocation.coordinate = newCoordinates
         selectedLocation.title = "Selected Location"
         
         self.mapView.removeAnnotations(self.mapView.annotations)
         self.mapView.showsUserLocation = false
         self.mapView.addAnnotation(selectedLocation)
         
         self.model.selectedLocation = selectedLocation.coordinate
         model.setCoordinate(selectedLocation.coordinate)
         
         self.directionsFromLocation = selectedLocation.coordinate
      } else {
         print("Long Press Other Touch")
      }
   }
   
   @IBAction func clearDroppedPin(sender: AnyObject) {
      // Locate pin in annotations
      self.mapView.removeAnnotations(self.mapView.selectedAnnotations)
   }
   
   @IBAction func trackUserButtonTapped(sender: UIButton) {
      
      self.locationButtonTapped = true
      
      print("Track user button tapped")
      
      // Check authorisation, just in case the button fails to disable
      if CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted {
         let userAlert = UIAlertController(title: "Locations Services Not Available", message: "Trakx is not allowed to access your location. Please tap-and-hold to drop a pin instead.", preferredStyle: .Alert)
         let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
         userAlert.addAction(okAction)
         self.presentViewController(userAlert, animated: true, completion: nil)
         
      } else {
         if (CLLocationManager.authorizationStatus() == .NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
         } else {
            self.centreMapOnUser()
         }
      }
      
   }
   
   func centreMapOnUser() {
      self.mapView.removeAnnotations(self.mapView.annotations)
      self.mapView.showsUserLocation = true
      
      if mapView.userLocationVisible {
         self.mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
         self.model.setCoordinate(mapView.userLocation.coordinate)
         
         self.directionsFromLocation = mapView.userLocation.coordinate
         
         self.trackUserActivityIndicatorView.stopAnimating()
         self.trackUserButton.hidden = false
      } else {
         
         self.locationManager.requestLocation()
         
         self.trackUserActivityIndicatorView.startAnimating()
         self.trackUserButton.hidden = true
      }
      
      self.locationButtonTapped = false
   }
   
   func setTrackUserButtonImage() {
      let mode = self.mapView.userTrackingMode
      
      if mode == .Follow {
         if let buttonImage = UIImage(named: "Near Me Filled-25") {
            self.trackUserButton.setImage(buttonImage, forState: .Normal)
         }
      } else {
         if let buttonImage = UIImage(named: "Near Me-25") {
            self.trackUserButton.setImage(buttonImage, forState: .Normal)
         }
      }
   }
   
}

// MARK: - Map View Delegate
extension StopsNearbyViewController: MKMapViewDelegate {
   
   func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
      self.setTrackUserButtonImage()
      if self.locationButtonTapped {
         self.centreMapOnUser()
      }
   }
   
   // Custom annotation for map view annotations.
   func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
      
      // Ignore any annotations other than PTVStop annotations.
      print ("View for Annotation")
      switch annotation {
         
      case is MKPointAnnotation:
         
         let pinView = MKPinAnnotationView()
         pinView.animatesDrop = true
         pinView.pinTintColor = UIColor.appTintColour
         pinView.canShowCallout = true
         
         let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
         
         clearButton.addTarget(self, action: #selector(self.clearDroppedPin), forControlEvents: .TouchUpInside)
         
         clearButton.setTitle("Clear", forState: .Normal)
         clearButton.backgroundColor = UIColor.redColor()
         
         pinView.rightCalloutAccessoryView = clearButton
         
         return pinView
         
      case is PTVStop:
         
         
         let stop = annotation as! PTVStop
         
         // Set reuse ID for annotation
         let reuseID = "stopPin"
         
         // Dequeue existing annoation view if possible.
         var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
         
         // Create annotation view if none could be dequeued
         if pinView == nil {
            pinView = MKAnnotationView()
         }
         
         // Set up pin view to display call out with detail disclosure
         pinView?.annotation = stop
         pinView?.canShowCallout = true
         pinView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
         
         // Create distance label
         let distanceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
         distanceLabel.numberOfLines = 0
         distanceLabel.textAlignment = .Center
         
         // Set distance label attributes to set size and text effects.
         let distanceTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(11), NSTextEffectAttributeName: NSTextEffectLetterpressStyle]
         
         // Get distance from point
         let fromCoordinate = CLLocation(latitude: model.selectedLocation.latitude, longitude: model.selectedLocation.longitude)
         let toCoordinate = CLLocation(latitude: stop.coordinate.latitude, longitude:  stop.coordinate.longitude)
         
         // Calculate distance
         let distance = fromCoordinate.distanceFromLocation(toCoordinate)
         
         // Create formatter to display distance in an easy to read format
         let distanceFormatter = MKDistanceFormatter()
         
         // Create distance string (replaces spaces to force two-line label given limited horizontal space).
         let distanceString = "\(distanceFormatter.stringFromDistance(distance))".stringByReplacingOccurrencesOfString(" ", withString: "\n")
         
         // Create attributed string using distance string and attributes
         let distanceText = NSAttributedString(string: distanceString, attributes: distanceTextAttributes)
         
         // Set label text
         distanceLabel.attributedText = distanceText
         
         // Set label as left callout view.
         pinView?.leftCalloutAccessoryView = distanceLabel
         
         // Set the pin image
         pinView?.image = stop.transportType.pinImage
         
         pinView?.accessibilityLabel = "\(stop.locationName) Pin"
         
         // Return pin view.
         return pinView
         
      default: return nil
         
      }
   }
   
   func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
      
      // Perform segue when stop detail control is tapped in callout
      if control is UIButton && !(view is MKPinAnnotationView) {
         
         
         
         self.performSegueWithIdentifier("ShowStopDetailSegue", sender: view.annotation as! PTVStop)
      }
   }
   
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
      // Check segue identifer
      if segue.identifier == "ShowStopDetailSegue" {
         
         // Set destination segue selected stop to the currently selected stop.
         let destination = segue.destinationViewController as! StopDetailTableViewController
         
         let selectedStop = sender as! PTVStop
         
         destination.stop = selectedStop
         destination.directionsFromLocation = self.directionsFromLocation
         
      }
   }
}

// MARK: - Stops Nearby Model Delegate
extension StopsNearbyViewController: StopsNearbyModelDelegate {
   func stopsNearbyDidUpdate() {
      
      self.mapView.showAnnotations(model.stops, animated: true)
      
   }
   
   func stopsNearbyUpdateFailed() {
      // Display alert identifiying failure
      let failureAC = UIAlertController(title: "Stop Retrieval Failed", message: "A failure has occured retrieving stops nearby. Please try again later.", preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
      failureAC.addAction(okAction)
      
      self.presentViewController(failureAC, animated: true, completion: nil)
      
   }
}

// MARK: - Location Manager Delegate
extension StopsNearbyViewController: CLLocationManagerDelegate {
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
      print("Location Received)")
      // TODO: Introduce buffer
      // Function can occasionally produce multiple responses in quick succession. Buffering this will prevent multiple requests to the API.
      self.mapView.setCenterCoordinate(locations[0].coordinate, animated: true)
      self.model.setCoordinate(locations[0].coordinate)
      
      self.directionsFromLocation = locations[0].coordinate
      
      self.trackUserActivityIndicatorView.stopAnimating()
      self.trackUserButton.hidden = false
   }
   
   func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
      let locationFailAlert = UIAlertController(title: "Unable to determine location", message: "Trakx is unable to determine your locations. Please tap-and-hold to drop a pin instead.", preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
      locationFailAlert.addAction(okAction)
      self.presentViewController(locationFailAlert, animated: true, completion: nil)
      
      self.trackUserActivityIndicatorView.stopAnimating()
      self.trackUserButton.hidden = false
   }
   
   func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
      switch status {
         
      case .AuthorizedAlways, .AuthorizedWhenInUse:
         print("Location Access: Authorised")
         self.trackUserButton.enabled = true
         self.trackUserButtonContainerView.hidden = false
         self.mapView.showsUserLocation = true
         if self.locationButtonTapped {
            self.centreMapOnUser()
         }
         
      case .Restricted, .Denied:
         print("Location Access: Denied")
         // Disable location button
         self.trackUserActivityIndicatorView.stopAnimating()
         self.trackUserButtonContainerView.hidden = true
         
         // Show message to inform the user that location services are not available.
         let locAlert = UIAlertController(title: "Location Services Not Available", message: "Trakx does not have permission to access your location. Please check your settings. Alternatively tap-and-hold to drop a pin and get stops nearby.", preferredStyle: .Alert)
         let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
         locAlert.addAction(okAction)
         self.presentViewController(locAlert, animated: true, completion: nil)
         
      case .NotDetermined:
         print("Status: Not Determined")
         self.trackUserButton.enabled = true
         self.trackUserButtonContainerView.hidden = false
         
      }
   }
}