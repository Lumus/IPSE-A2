//
//  PTVHealthCheckResult.swift
//  Trakx
//
//  Created by Matt Croxson on 30/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

/// Constants to indicate health check status.
enum PTVHealthCheckResult: UInt {

   /// Indicates a response has been received with a critical error. The operation should not continue and will likely fail.
   case Fail = 0
   
   /// Indicates a response has been received with a non-critical error. The operation may continue, but data may be inaccurate.
   case Unhealthy = 1
   
   /// Indicates a response has been recievied without error.
   case Healthy = 2
   
   /// Indicates an unexpected response, or no response has been received. The operation should not continue and will likely fail.
   case Unknown = 3
   
   /// Textual description of the health check status.
   var description: String {
      get {
         switch self {
         case .Fail:       return "Fail"        // Indicates a response has been received with a critical error.
         case .Unhealthy:  return "Unhealthy"   // Indicates a response has been received with a non-critical error.
         case .Healthy:    return "Healthy"     // Indicates a response has been recievied without error.
         case .Unknown:    return "Unknown"     // Indicates an unexpected response, or no response has been received.
         }
      }
   }
}
