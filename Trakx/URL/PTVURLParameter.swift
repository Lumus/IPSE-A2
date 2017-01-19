//
//  PTVURLParameter.swift
//  Trakx
//
//  Created by Matt Croxson on 30/07/2016.
//  Copyright © 2015 Matt Croxson. All rights reserved.
//

class PTVURLParameter: CustomStringConvertible {
   
   var name = ""
   var value = ""
   
   var complete: String {
      get {
         // If name is blank, return only value
         if name == ""
         {
            if value == "" {
               return ""
            } else {
               return value
            }
         }
         
         // Return name and value
         return name + "/" + value
      }
   }
   
   init (_ name: String, value: String)
   {
      self.name = name
      self.value = value
   }
   
   var description: String {
      get {
         return self.complete
      }
   }
}
