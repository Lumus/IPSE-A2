//
//  OperatorExtensions.swift
//  Trakx
//
//  Created by Matt Croxson on 30/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

func ==(lhs: PTVDirection, rhs: PTVDirection) -> Bool {
   return lhs.hashValue == rhs.hashValue
}

func ==(lhs: PTVStop, rhs: PTVStop) -> Bool {
   return lhs.stopID == rhs.stopID
}