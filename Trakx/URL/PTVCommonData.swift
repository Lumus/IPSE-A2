//
//  PTVCommonData.swift
//  Trakx
//
//  Created by Matt Croxson on 30/07/2016.
//  Copyright © 2015 Matt Croxson. All rights reserved.
//

import Foundation

class PTVCommonData {
   
   /// Base URL used by the API
   static var baseURL: String {
      get {
         return "http://timetableapi.ptv.vic.gov.au/"
      }
   }
   
   /// API version
   static var apiVersion: String {
      get { return "v2" }
   }
   
   /// Base URL used by the API, with the version number appended.
   static var baseURLWithVersion: String {
      get { return baseURL + apiVersion + "/" }
   }
}
