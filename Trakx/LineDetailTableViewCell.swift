//
//  LineDetailTableViewCell.swift
//  Trakx
//
//  Created by Matt Croxson on 3/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class LineDetailTableViewCell: MGSwipeTableCell {
   
   @IBOutlet weak var nameLabel: UILabel!
   
   @IBOutlet weak var lineView: UIView!
   @IBOutlet weak var stationNodeView: UIView!
   
   @IBOutlet weak var reminderImageView: UIImageView!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
   }
   
   override func setSelected(selected: Bool, animated: Bool) {
      let lineColour = lineView.backgroundColor
      let nodeColour = stationNodeView.backgroundColor
      super.setSelected(selected, animated: animated)
      
      if selected {
         lineView.backgroundColor = lineColour
         stationNodeView.backgroundColor = nodeColour
         
      }
   }
   
   override func setHighlighted(highlighted: Bool, animated: Bool) {
      let lineColour = lineView.backgroundColor
      let nodeColour = stationNodeView.backgroundColor
      super.setSelected(selected, animated: animated)
      
      if selected {
         lineView.backgroundColor = lineColour
         stationNodeView.backgroundColor = nodeColour
         
      }
   }
   
}
