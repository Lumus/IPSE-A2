//
//  DisruptionSplitViewController.swift
//  Trakx
//
//  Created by Matt Croxson on 12/07/2016.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

import UIKit

class DisruptionSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // Do any additional setup after loading the view.
      
      self.delegate = self
      
      let detailView = self.viewControllers[1] as? UINavigationController
      detailView?.navigationItem.rightBarButtonItem = self.displayModeButtonItem()
      
      self.preferredDisplayMode = .AllVisible
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   
   /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
   
   func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
      return true
   }
   
}
