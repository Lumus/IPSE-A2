//
//  StopsNearbyModel.swift
//  Trakx
//
//  Created by Matt Croxson on 28/06/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import MapKit
import Alamofire
import SwiftyJSON

// Delegate functions.
protocol StopsNearbyModelDelegate {
   func stopsNearbyDidUpdate()
   func stopsNearbyUpdateFailed()
}

class StopsNearbyModel {
   
   // Stops to be displayed. Internally accessible but only privately settable.
   private(set) var stops: [PTVStop] = []
   
   // Delegate reference.
   private var delegate: StopsNearbyModelDelegate?
   
   // Initialisers.
   convenience init() {
      self.init(delegate: nil)
   }
   
   init(delegate: StopsNearbyModelDelegate?) {
      self.delegate = delegate
      self.selectedLocation = mapInitialCentre
   }
   
   // Stores the selected location from the map.
   var selectedLocation: CLLocationCoordinate2D = CLLocationCoordinate2D() {
      didSet {
         // Get stops from API
         
         self.getStopsNearby()
         
      }
   }
   
   // Used to define the centre the map on first load.
   var mapInitialCentre: CLLocationCoordinate2D {
      get {
         // Set map initial view area to approximately zoom to Victoria.
         let mapCentre = CLLocationCoordinate2D(latitude: -36.6, longitude: 145.3)
         return mapCentre
      }
   }
   
   // Used to define the area of the map on first load.
   var mapInitialArea: MKCoordinateRegion {
      get {
         
         // Create map region based on device orientation
         switch UIDevice.currentDevice().orientation {
         case .LandscapeLeft: fallthrough
         case .LandscapeRight:
            let mapSpan = MKCoordinateSpan(latitudeDelta: 9.6, longitudeDelta: 10)
            let mapArea = MKCoordinateRegion(center: self.mapInitialCentre, span: mapSpan)
            return mapArea
            
         case .Portrait: fallthrough
         case .PortraitUpsideDown: fallthrough
            
         default:
            let mapSpan = MKCoordinateSpan(latitudeDelta: 11, longitudeDelta: 10)
            let mapArea = MKCoordinateRegion(center: self.mapInitialCentre, span: mapSpan)
            return mapArea
         }
      }
   }
   
   // Sets the selected location
   func setCoordinate(location: CLLocationCoordinate2D) {
      
      self.selectedLocation = location
      
   }
   
   // Retrieves stops nearby from the API. 
   private func getStopsNearby() {
      // Clear existing stops
      self.stops = []
      
      // Create an perform health check with completion handler
      var healthCheck = PTVHealthCheck()
      healthCheck.performHealthCheck { (healthCheckResult) in
         
         // Confirm health check returned positive result. Send failure to delegate if not.
         if healthCheckResult == .Fail || healthCheckResult == .Unknown {
            
            self.delegate?.stopsNearbyUpdateFailed()
            return
            
         }
         
         // Generate query URL
         let queryType: PTVURLQueryType = .StopsNearby
         let queryLatParam = PTVURLParameter("latitude", value: "\(self.selectedLocation.latitude)")
         let queryLonParam = PTVURLParameter("longitude", value: "\(self.selectedLocation.longitude)")
         
         guard let queryURL = PTVURLGenerator.generateUsing(queryType: queryType, parameters: [queryLatParam, queryLonParam]) else {
            self.delegate?.stopsNearbyUpdateFailed()
            return
         }
         
         // Perform request with Alamofire
         Alamofire.request(.GET, queryURL.absoluteString).responseJSON(completionHandler: { (responseData) in
            
            // Process response
            if let responseValue = responseData.result.value {
               let swiftyJSON = JSON(responseValue)
               
               for result in swiftyJSON.arrayValue {
                  let stop = PTVStop(result["result"].dictionaryValue)
                  
                  self.stops.append(stop)
               }
               
               self.delegate?.stopsNearbyDidUpdate()
            } else {
               self.delegate?.stopsNearbyUpdateFailed()
            }
         })
      }
   }
}
