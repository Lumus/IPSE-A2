//
//  PTVDirection.swift
//  Trakx
//
//  Created by Matt Croxson on 11/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//
import Foundation
import SwiftyJSON

/**
 A PTVDirection object forms part of a PTVPlatform object. It is used to define the direction along a line for a specific timetable entry.
 
 - See: [PTVPlatform](../Classes/PTVPlatform.html)
 - See: [PTVLine](../Classes/PTVLine.html)
 */
class PTVDirection: NSObject, NSCoding {
   
   // *********************************
   // MARK: - Constants (Keys)
   // *********************************
   
   private let kPTVDirectionLineIDKey = "linedir_id"
   private let kPTVDirectionIDKey = "direction_id"
   private let kPTVDirectionNameKey = "direction_name"
   private let kPTVDirectionLineKey = "line"
   
   override var description: String {
      get {
         return "{ LineDirID: \(lineDirectionID), DirID: \(directionID), Name: \(directionName), Line: \(line) }"
      }
   }
   
   // *********************************
   // MARK: - Variables
   // *********************************
   
   /// Unique identifier of a particular line and service direction.
   private(set) var lineDirectionID = 0
   
   /// Unique identifier of a particular service direction.
   private(set) var directionID = 0
   
   /// Name of the direciton of the service (e.g. "City (Flinders Street)")
   private(set) var directionName = ""
   
   /// Line related to the direction.
   private(set) var line: PTVLine?
   
   // *********************************
   // MARK: - Initialiser
   // *********************************
   
   /**
    Initialises and returns an instance using data provided by the API.
    
    - Parameter data: A Dictionary object containing the raw data from the API.
    - Returns: An initialised PTVDirection object.
    */
   init(_ data: [String: JSON])
   {
      if let ldID = data[kPTVDirectionLineIDKey]?.int {
         self.lineDirectionID = ldID
      }
      
      if let dID = data[kPTVDirectionIDKey]?.int {
         self.directionID = dID
      }
      
      if let name = data[kPTVDirectionNameKey]?.string {
         directionName = name
      }
      
      if let ln = data[kPTVDirectionLineKey]?.dictionary {
         line = PTVLine(ln)
      }
   }
   
   init(lineDirectionID: Int, directionID: Int, directionName: String, line: PTVLine?) {
      self.lineDirectionID = lineDirectionID
      self.directionID = directionID
      self.directionName = directionName
      self.line = line
   }
   
   // MARK: - NSCoding Protocol
   required init?(coder aDecoder: NSCoder) {
      let lineDirID = aDecoder.decodeIntegerForKey(self.kPTVDirectionLineIDKey)
      self.lineDirectionID = lineDirID
      
      let dirID = aDecoder.decodeIntegerForKey(self.kPTVDirectionIDKey)
      self.directionID = dirID
      
      if let name = aDecoder.decodeObjectForKey(self.kPTVDirectionNameKey) as? String {
         self.directionName = name
      }
      
      if let line = aDecoder.decodeObjectForKey(self.kPTVDirectionLineKey) as? PTVLine {
         self.line = line
      }
      
   }
   
   func encodeWithCoder(coder: NSCoder) {
      coder.encodeInteger(self.lineDirectionID, forKey: self.kPTVDirectionLineIDKey)
      coder.encodeInteger(self.directionID, forKey: self.kPTVDirectionIDKey)
      coder.encodeObject(self.directionName, forKey: kPTVDirectionNameKey)
      coder.encodeObject(self.line, forKey: kPTVDirectionLineKey)
   }
   
   // MARK: - Hashable Protocol
   override var hashValue: Int {
      get {
         return self.lineDirectionID
      }
   }
   
   override var hash: Int {
      get {
         return self.hashValue
      }
   }
   
   override func isEqual(object: AnyObject?) -> Bool {
      guard let otherObject = object as? PTVDirection else { return false }
      
      if otherObject.lineDirectionID == self.lineDirectionID {
         return true
      }
      
      return false
   }
}
