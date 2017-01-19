//
//  FavouritesTableViewCell.swift
//  Trakx
//
//  Created by Matt Croxson on 20/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class FavouritesTableViewCell: UITableViewCell {
   
   @IBOutlet weak var favNameLabel: UILabel!
   @IBOutlet weak var favDepartureTimeLabel: UILabel!
   @IBOutlet weak var favDepartureDestinationLabel: UILabel!
   @IBOutlet weak var favDepartureLineLabel: UILabel!
   
   @IBOutlet weak var favRealtimeImageView: UIImageView!
   
   var detailModel: StopDetailModel!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
   }
   
   override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
   
}

extension FavouritesTableViewCell: StopDetailModelDelegate {
   func timetableUpdateFailed() {
      // Deliberately Empty
   }
   
   func favouriteStatusDidChange(newValue: Bool) {
      // Deliberately Empty
   }
   
   func timetableDidUpdate() {
      if let nextDeparture = self.detailModel?.nextDeparture {
         let formatter = NSDateFormatter()
         formatter.timeStyle = .MediumStyle
         
         var departureDate: NSDate
         
         
         if nextDeparture.realtimeTimeUTC != nil {
            departureDate = nextDeparture.realtimeTimeUTC!
            self.favRealtimeImageView.tintColor = UIColor.appTintColour
            self.favRealtimeImageView.image = UIImage(named:"Clock Filled-15")
         } else {
            departureDate = nextDeparture.timetableTimeUTC
            self.favRealtimeImageView.tintColor = UIColor.lightGrayColor()
            self.favRealtimeImageView.image = UIImage(named:"Clock-15")
         }
         
         self.favDepartureTimeLabel.text = formatter.stringFromDate(departureDate)
         self.favDepartureLineLabel.text = nextDeparture.timetablePlatform?.platformDirection?.line?.lineNumber
         self.favDepartureDestinationLabel.text = nextDeparture.timetableRun?.destinationName
      }
   }
}