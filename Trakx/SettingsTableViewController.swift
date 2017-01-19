//
//  SettingsTableViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 16/08/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
   
   // MARK: Properties
   let model = SettingsModel()
   
   // MARK: IBOutlets
   @IBOutlet weak var clearAllRemindersButton: UIButton!
   
   // MARK: Controller
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   override func viewWillAppear(animated: Bool) {
      if self.model.reminderCount > 0 {
         self.clearAllRemindersButton.enabled = true
      } else {
         self.clearAllRemindersButton.enabled = false
      }
   }
   
   // MARK: IBActions
   @IBAction func clearAllRemindersButtonTapped(sender: UIButton) {
      // Generate confirmation alert
      let confAC = UIAlertController(title: "Clear all reminders?", message: "Are you sure you want to clear all reminders?", preferredStyle: .ActionSheet)
      
      let clearAction = UIAlertAction(title: "Clear", style: .Destructive) { (action) in
         self.model.deleteAllReminders()
         self.clearAllRemindersButton.enabled = false
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
      
      confAC.addAction(clearAction)
      confAC.addAction(cancelAction)
      
      self.presentViewController(confAC, animated: true, completion: nil)
      
   }
}
