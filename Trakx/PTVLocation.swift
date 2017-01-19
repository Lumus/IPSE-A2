//
//  PTVLocation.swift
//  PTVKit
//
//  Created by Matt Croxson on 3/01/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import MapKit
import SwiftyJSON

 class PTVLocation: NSObject, NSCoding, MKAnnotation {
   
   // *********************************
   // MARK: - Constants (Keys)
   // *********************************
   
   private static let kPTVLocationNameKey = "location_name"
   private static let kPTVLocationLatitudeKey = "lat"
   private static let kPTVLocationLongitudeKey = "lon"
   private static let kPTVLocationDistanceKey = "distance"
   
   // *********************************
   // MARK: - Variables
   // *********************************
   
   /// The latitude of the location.
    private(set) var lat: CLLocationDegrees = 0.0
   
   /// The longitude of the location.
    private(set) var lon: CLLocationDegrees = 0.0
   
   /// Distance as reported by the API (UNUSED)
    private(set) var distance: CLLocationDistance = 0.0 // NOT USED IN API 2.1
   
   /// The name of the location.
    private(set) var locationName: String = ""
   
   // *********************************
   // MARK: - Initialiser
   // *********************************
   
   /**
   Initialises and returns an instance using data from the API.
   
   - Parameter data: A Dictionary object containing the raw data from the API.
   - Returns: An initialised PTVDirection object.
   */
   init(_ data: [String: JSON]) {
      
      if let name = data[PTVStop.kPTVLocationNameKey]?.string {
         self.locationName = name
      } else {
         self.locationName = ""
      }
      
      if let lat = data[PTVStop.kPTVLocationLatitudeKey]?.double{
         self.lat = lat
      } else {
         self.lat = 0.0
      }
      
      if let lon = data[PTVStop.kPTVLocationLongitudeKey]?.double {
         self.lon = lon
      } else {
         self.lon = 0.0
      }
      
      if let dist = data[PTVStop.kPTVLocationDistanceKey]?.double {
         self.distance = dist
      } else {
         self.distance = 0.0
      }
      
   }
   
   /**
   Initialises and returns an instance.
   
   - Parameter lat: The latitude of the location.
   - Parameter lon: The longitude of the location.
   - Parameter locationName: The name of the location.
   - Parameter distance: (UNUSED) The distance of the location reported by the PTV API.
   - Returns: An initialised PTVDirection object.
   */
    init(lat: CLLocationDegrees, lon: CLLocationDegrees, locationName: String, distance: CLLocationDistance)
   {
      self.lat = lat
      self.lon = lon
      self.locationName = locationName
      self.distance = distance
   }
   
   override  init() {
      
      self.lat = 0.0
      self.lon = 0.0
      self.locationName = ""
      self.distance = 0.0
      
   }
   
   /**
    Returns the distance in metres from the provided location
    
    - Parameter otherCoordinate: 2D coordinate of the location to measure dstance from.
   */
    func distanceFrom(otherCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
      let thisLocation = CLLocation(latitude: self.lat, longitude: self.lon)
      let otherLocation = CLLocation(latitude: otherCoordinate.latitude, longitude: otherCoordinate.longitude)
      
      return thisLocation.distanceFromLocation(otherLocation)
   }
   
   // MARK: - NSCoding Protocol
   /**
   Returns an object initialized from data in a given unarchiver.
   
   - Parameter decoder: An unarchiver object.
   - Returns: `self`, initialized using the data in *decoder*.
   */
   required  init?(coder decoder: NSCoder) {
      
      if let locName = decoder.decodeObjectForKey(PTVStop.kPTVLocationNameKey) as? String {
         self.locationName = locName
      } else {
         self.locationName = ""
      }
      
      let dist = decoder.decodeDoubleForKey(PTVStop.kPTVLocationDistanceKey)
      let lat = decoder.decodeDoubleForKey(PTVStop.kPTVLocationLatitudeKey)
      let lon = decoder.decodeDoubleForKey(PTVStop.kPTVLocationLongitudeKey)
      
      self.lat = lat
      self.lon = lon
      self.distance = dist
      
   }
   
   /**
    Encodes the receiver using a given archiver.
    
    - Parameter coder: An archiver object.
   */
    func encodeWithCoder(coder: NSCoder) {
      coder.encodeObject(self.locationName, forKey: PTVStop.kPTVLocationNameKey)
      coder.encodeDouble(self.lat, forKey: PTVStop.kPTVLocationLatitudeKey)
      coder.encodeDouble(self.lon, forKey: PTVStop.kPTVLocationLongitudeKey)
      coder.encodeDouble(self.distance, forKey: PTVStop.kPTVLocationDistanceKey)
   }
   
   // MARK: - MKAnnotation Protocol
   /// Returns the map coordinate for the POI's location.
    var coordinate: CLLocationCoordinate2D {
      get {
         return CLLocationCoordinate2D(latitude: lat, longitude: lon)
      }
   }
   
   /// Returns the annotation title.
    var title: String? {
      get {
         return self.locationName
      }
   }
}
