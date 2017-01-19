//
//  PTVDisruption.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import SwiftyJSON

/**
 A PTVDisruption object contains information relating to a current disruption on the PTV network.
 
 - See: [PTVDisruptionMode](../Enums/PTVDisruptionMode.html)
 */
struct PTVDisruption {
   
   // *********************************
   // MARK: - Constants (Keys)
   // *********************************
   private let kPTVDisruptionIDKey = "disruption_id"
   private let kPTVDisruptionTitleKey = "title"
   private let kPTVDisruptionURLKey = "url"
   private let kPTVDisruptionDescriptionKey = "description"
   private let kPTVDisruptionPublishedOnKey = "publishedOn"
   private let kPTVDisruptionTypeKey = "status"
   private let kPTVDisruptionFromDateKey = "fromDate"
   private let kPTVDisruptionToDateKey = "toDate"
   private let kPTVDisruptionLinesKey = "lines"
   
   // *********************************
   // MARK: - Variables
   // *********************************
   
   /// Unique identifier for the disruption.
   private(set) var disruptionID = 0
   
   /// Title of the disruption.
   private(set) var title = ""
   
   /// URL for further details on the PTV website.
   private(set) var url = NSURL()
   
   /// Detailed description of the disrution.
   private(set) var disruptionDescription = ""
   
   /** Status of the disruption.
    
    - See: PTVDisruptionType
    */
   private(set) var disruptionType = PTVDisruptionType.Current
   
   /// Date and time the disruption was published.
   private(set) var publishedOn = NSDate()
   
   /// Date and time the disruption is due to start.
   private(set) var fromDate = NSDate()
   
   /// Date and time the disruption is due to end.
   private(set) var toDate = NSDate()
   
   /// Lines affected by the disruptions
   private(set) var lines = [PTVLine]()
   
   /// Returns a human readable string describing the disruption.
   var description: String {
      get {
         return "\(disruptionID) - \( NSString(string: title).substringToIndex(20) )"
      }
   }
   
   // *********************************
   // MARK: - Initialiser
   // *********************************
   
   /**
    Initialises and returns an instance using data provided by the API.
    
    - Parameter data: A Dictionary object containing the raw data from the API.
    - Returns: An initialised PTVDisruption object.
    */
   init (_ data: [String: JSON])
   {
      if let newID = data[kPTVDisruptionIDKey]?.int {
         self.disruptionID = newID
      }
      
      if let newTitle = data[kPTVDisruptionTitleKey]?.string {
         self.title = newTitle
      }
      
      if let url = data[kPTVDisruptionURLKey]?.string {
         if let newUrl = NSURL(string: url) {
            self.url = newUrl
         }
      }
      
      if let desc = data[kPTVDisruptionDescriptionKey]?.string {
         disruptionDescription = desc
      }
      
      if let newPubDate = data[kPTVDisruptionPublishedOnKey]?.string {
         self.publishedOn = PTVUTCTime.dateForUTCTime(newPubDate)
      }
      
      if let newStatus = data[kPTVDisruptionTypeKey]?.string {
         if let status = PTVDisruptionType(rawValue: newStatus){
            self.disruptionType = status
         }
      }
      
      if let newFromDate = data[kPTVDisruptionFromDateKey]?.string {
         self.fromDate = PTVUTCTime.dateForUTCTime(newFromDate)
      }
      
      if let newToDate = data[kPTVDisruptionToDateKey]?.string {
         self.toDate = PTVUTCTime.dateForUTCTime(newToDate)
      }
      
      if let rawLineData = data[kPTVDisruptionLinesKey]?.arrayObject {
         for lineDict in rawLineData {
            if let dict = lineDict as? [String: JSON] {
               let newLine = PTVLine(dict)
               self.lines.append(newLine)
            }
         }
      }
   }
   
   init(disruptionID: Int,
        title: String,
        url: NSURL,
        disruptionDescription: String,
        disruptionType: PTVDisruptionType,
        publishedOn: NSDate,
        fromDate: NSDate,
        toDate: NSDate,
        lines: [PTVLine]) {
      
      self.disruptionID = disruptionID
      self.title = title
      self.url = url
      self.disruptionDescription = disruptionDescription
      self.publishedOn = publishedOn
      self.disruptionType = disruptionType
      self.fromDate = fromDate
      self.toDate = toDate
      self.lines = lines
      
   }
}
