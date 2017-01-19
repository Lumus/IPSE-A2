//
//  PTVURLParameterOptional.swift
//  Trakx
//
//  Created by Matt Croxson on 30/07/2016.
//  Copyright © 2015 Matt Croxson. All rights reserved.
//

class PTVURLOptionalParameter: PTVURLParameter {

   override var complete: String {
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
         
         if value == "" {
            return ""
         }
         
         // Return name and value
         return name + "=" + value
      }
   }
}
