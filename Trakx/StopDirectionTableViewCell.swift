//
//  StopDirectionTableViewCell.swift
//  Trakx
//
//  Created by Matt Croxson on 6/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class StopDirectionTableViewCell: UITableViewCell {
   
   @IBOutlet weak var directionLabel: UILabel!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
   }
   
   override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
   
}
