//
//  IntroViewController.swift
//  BrightOwl
//
//  Created by Khalid Usman on 4/19/16.
//  Copyright © 2016 Khalid Usman. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var _introView: UIView!
    @IBOutlet weak var _introTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.hidden = false
        
        self._introView.layer.cornerRadius = 10.0;
        self._introView.layer.masksToBounds = true;
        
        self.navigationItem.title = "Introduction"
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //self._introTextView.setContentOffset(CGPointZero, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UIBarButtonItems
    
    @IBAction func btnSignOutPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
