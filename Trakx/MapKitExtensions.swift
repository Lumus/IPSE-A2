//
//  MapKitExtensions.swift
//  Trakx
//
//  Created by Matt Croxson on 6/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import MapKit

extension MKDirectionsTransportType {
   var typeName: String {
      get {
         switch self {
         case MKDirectionsTransportType.Automobile: return "Driving"
         case MKDirectionsTransportType.Walking: return "Walking"
         case MKDirectionsTransportType.Transit: return "Transit"
         case MKDirectionsTransportType.Any: return "Any"
         default: return "Multiple"
         }
      }
   }
   
   var iconImage: UIImage? {
      get {
         switch self {
         case MKDirectionsTransportType.Automobile: return UIImage(named: "Sedan Filled-33")
         case MKDirectionsTransportType.Walking: return UIImage(named: "Walking Filled-33")
         default: return nil
         }
      }
   }
   
   var typeFlag: String? {
      get {
         switch self {
         case MKDirectionsTransportType.Automobile: return "d"
         case MKDirectionsTransportType.Walking: return "w"
         case MKDirectionsTransportType.Transit: return "t"
         default: return nil
         }
      }
   }
   
   var googleTypeFlag: String? {
      get {
         switch self {
         case MKDirectionsTransportType.Automobile: return "driving"
         case MKDirectionsTransportType.Walking: return "walking"
         case MKDirectionsTransportType.Transit: return "transit"
         default: return nil
         }
      }
   }
}