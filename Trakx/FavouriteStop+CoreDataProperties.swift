//
//  FavouriteStop+CoreDataProperties.swift
//  Trakx
//
//  Created by Matt Croxson on 7/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FavouriteStop {

    @NSManaged var stopID: NSNumber
    @NSManaged var stopObject: NSData
    @NSManaged var locationName: String
    @NSManaged var lineType: FavouriteLineType

}
