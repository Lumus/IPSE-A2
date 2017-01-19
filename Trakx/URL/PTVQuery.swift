//
//  PTVQuery.swift
//  Trakx
//
//  Created by Matt Croxson on 30/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

/// Struct representing a query being made to the PTVAPI
struct PTVQuery {
   let queryType: PTVURLQueryType
   let parameters: Array<PTVURLParameter>
   
   init(_ queryType: PTVURLQueryType, parameters: PTVURLParameter...) {
      self.init(queryType, parameters: parameters)
   }
   
   init (_ queryType: PTVURLQueryType, parameters: [PTVURLParameter])
   {
      self.queryType = queryType
      self.parameters = parameters
   }
}
