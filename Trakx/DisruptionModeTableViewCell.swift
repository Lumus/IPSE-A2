//
//  DisruptionModeTableViewCell.swift
//  Trakx
//
//  Created by Matt Croxson on 12/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class DisruptionModeTableViewCell: UITableViewCell {
   
   @IBOutlet weak var disruptionModeTitle: UILabel!
   @IBOutlet weak var disruptionModeStatusImage: UIImageView!
   @IBOutlet weak var disruptionModeCornerPointImage: UIImageView!
   @IBOutlet weak var disruptionCountLabel: UILabel!
   @IBOutlet weak var disruptionCountLabelContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
   override func setSelected(selected: Bool, animated: Bool) {
      let colour = disruptionCountLabelContainer.backgroundColor
      super.setSelected(selected, animated: animated)
      
      if selected {
         disruptionCountLabelContainer.backgroundColor = colour
      }
   }
   
   override func setHighlighted(highlighted: Bool, animated: Bool) {
      let colour = disruptionCountLabelContainer.backgroundColor
      super.setHighlighted(highlighted, animated: animated)
      
      if highlighted {
         disruptionCountLabelContainer.backgroundColor = colour
      }
   }

}
