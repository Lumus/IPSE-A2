//
//  TimetableTableViewCell.swift
//  Trakx
//
//  Created by Matt Croxson on 19/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TimetableTableViewCell: MGSwipeTableCell {
   
   @IBOutlet weak var timeLabel: UILabel!
   @IBOutlet weak var speedLabel: UILabel!
   @IBOutlet weak var realtimeImageView: UIImageView!
   @IBOutlet weak var reminderImageView: UIImageView!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
   }
   
   override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
}
