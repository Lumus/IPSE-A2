//
//  SearchModel.swift
//  Trakx
//
//  Created by Matt Croxson on 27/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

protocol SearchModelDelegate {
   func searchWillStart()
   func searchDidComplete()
   func searchFailed(reason: String)
}

class SearchModel {
   
   // Search results dictionary
   private var searchResults: [PTVSearchResultType: [PTVSearchResult]] = [:]
   
   // Delegate reference
   private var delegate: SearchModelDelegate?
   
   // Initaliser
   init(delegate: SearchModelDelegate? = nil) {
      self.delegate = delegate
   }

   // Returns the number of dictionary sections.
   var numberOfSections: Int {
      get {
         return searchResults.keys.count
      }
   }
   
   func numberOfRowsInSection(section: Int) -> Int {
      let key = self.typeForSection(section)
      
      if let results = self.searchResults[key] {
         return results.count
      }
      
      return 0
   }
   
   func searchResultAtIndexPath(indexPath: NSIndexPath) -> PTVSearchResult? {
      let key = self.typeForSection(indexPath.section)
      if let results = self.searchResults[key] {
         return results[indexPath.row]
      }
      
      return nil
   }
   
   func titleForSection(section: Int) -> String {
      let key = self.typeForSection(section)
      return key.description
   }
   
   func typeForSection(section: Int) -> PTVSearchResultType {
      let type = Array(self.searchResults.keys)[section]
      return type
   }
   
   // Retrieve search results from the API 
   func performSearch(withSearchTerm searchTerm: String) {
      
      // Tell delegate search is about to be performed
      self.delegate?.searchWillStart()
      
      // Clear existing results
      self.searchResults = [:]
      
      // Create and perform health check with completion handler
      var healthCheck = PTVHealthCheck()
      healthCheck.performHealthCheck { (healthCheckResult) in
         
         // Confirm health check returned positive result. Send failre to delegate if not.
         if healthCheckResult == .Fail || healthCheckResult == .Unknown {
            self.delegate?.searchFailed("Service not available")
            return
         }
      }
      
      // Generate query URL
      let queryType: PTVURLQueryType = .Search
      let querySearchParam = PTVURLParameter("search", value: searchTerm)
      
      guard let queryURL = PTVURLGenerator.generateUsing(queryType: queryType, parameter: querySearchParam) else {
         self.delegate?.searchFailed("An error has occured sending the request. Please try again later.")
         return
      }
      
      // Perform request with Alamofire
      Alamofire.request(.GET, queryURL.absoluteString).responseJSON { (responseData) in
         
         // Process response
         if let responseValue = responseData.result.value {
            let swiftyJSON = JSON(responseValue)
            
            for item in swiftyJSON.arrayValue {
               if let searchResult = PTVSearchResult(item.dictionaryValue) {
                  
                  let resultType = searchResult.searchResultType
                  
                  if self.searchResults[resultType] == nil {
                     self.searchResults[resultType] = []
                  }
                  
                  self.searchResults[resultType]?.append(searchResult)
                  
               }
            }
            
            self.delegate?.searchDidComplete()
            return
            
         } else {
            
            self.delegate?.searchFailed("An error occured processing the server response. Please try again later.")
            return
         }
      }
   }
}
