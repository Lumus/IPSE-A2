//
//  DisruptionDetailTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 14/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit
import TUSafariActivity
import ARChromeActivity

class DisruptionDetailTableViewController: UITableViewController {
   
   var disruption: PTVDisruption!
   let dateFormatter = NSDateFormatter()
   var disruptionMode: PTVDisruptionMode!
   
   @IBOutlet weak var disruptionTypeImageView: UIImageView!
   @IBOutlet weak var disruptionTypeLabel: UILabel!
   @IBOutlet weak var disruptionFromDateLabel: UILabel!
   @IBOutlet weak var disruptionToDateLabel: UILabel!
   
   @IBOutlet weak var disruptionTitleLabel: UILabel!
   @IBOutlet weak var disruptionDescriptionLabel: UILabel!
   @IBOutlet weak var disruptionModeBackgroundView: UIView!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // Set up table view cell for automatic height.
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 40.0
      
      // set up date formatter
      dateFormatter.dateStyle = .ShortStyle
      dateFormatter.timeStyle = .ShortStyle
      
      self.disruptionTypeImageView.image = disruption.disruptionType.typeImage
      self.disruptionTypeLabel.text = disruption.disruptionType.description
      self.disruptionToDateLabel.text = dateFormatter.stringFromDate(disruption.toDate)
      self.disruptionFromDateLabel.text = dateFormatter.stringFromDate(disruption.fromDate)
      self.disruptionTitleLabel.text = disruption.title
      self.disruptionDescriptionLabel.text = disruption.disruptionDescription
      self.disruptionModeBackgroundView.backgroundColor = disruptionMode.bgColor
   
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
   }
   
   
   // MARK: - IB Actions
   @IBAction func actionButtonTapped(sender: UIBarButtonItem) {
      
      let shareText = "\(disruption.title): \(disruption.disruptionDescription)"
      let shareURL = disruption.url
      
      let safariActivity = TUSafariActivity()
      let chromeActivity = ARChromeActivity()
      
      let activityVC = UIActivityViewController(activityItems: [shareText, shareURL], applicationActivities: [safariActivity, chromeActivity])
      activityVC.popoverPresentationController?.barButtonItem = sender
      self.presentViewController(activityVC, animated: true, completion: nil)
      
   }
   
   @IBAction func openInBrowserButtonTapped(sender: UIButton) {
      print("Opening url: \(disruption.url.absoluteString)")
      UIApplication.sharedApplication().openURL(disruption.url)
   }
}

// *********************************
// MARK: - 3D Touch Previewing Delegate
// *********************************
extension DisruptionDetailTableViewController: UIViewControllerPreviewingDelegate {
   
   func forceTouchAvailable() -> Bool {
      return self.traitCollection.forceTouchCapability == .Available
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      // Implementation deliberately emtpy
      return nil
   }
   
   func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
      // Implementation deliberately emtpy
   }
   
   override func previewActionItems() -> [UIPreviewActionItem] {
      let openInBrowserAction = UIPreviewAction(title: "Open in Browser", style: .Default) { (previewAction, previewController) in
         print("Opening url: \(self.disruption.url.absoluteString)")
         UIApplication.sharedApplication().openURL(self.disruption.url)
      }
      
      return [openInBrowserAction]
   }
}
