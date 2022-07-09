//
//  SaveJobViewController.swift
//  BrightOwl
//
//  Created by KhalidUsman on 5/11/16.
//  Copyright © 2016 Khalid Usman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class SaveJobViewController: UIViewController, APIResponseDelegates, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var saveJobTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var _interestedJobsArray : NSMutableArray = []
    var _savedJobsArray : NSMutableArray = []
    var _appliedJobsArray : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.titleView = UIImageView(image:UIImage(named: "BrightOwl"))
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        let button =  UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 100, 40) as CGRect
        button.backgroundColor = UIColor.clearColor()
        button.setBackgroundImage(UIImage(named: "BrightOwl"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(SaveJobViewController.clickOnButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.titleView = button
        
        self.saveJobTableView.layer.borderWidth = 2.0
        self.saveJobTableView.layer.borderColor = UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0).CGColor
        
        saveJobTableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        getSaveJob()
        getInterestedJob()
        getAppliedJob()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    
    @IBAction func applyForJob(sender: AnyObject) {
        
        let applyJobVC = self.storyboard?.instantiateViewControllerWithIdentifier("applyJobVC") as! ApplyJobViewController
        let button = sender as! UIButton
        let buttonIndex = button.tag
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            let tempDic = _interestedJobsArray[buttonIndex] as! Dictionary<String, String>
            applyJobVC.newStr = tempDic["project_id"]!
            applyJobVC.titleStr = tempDic["project_title"]!
        case 1:
            let tempDic = _savedJobsArray[buttonIndex] as! Dictionary<String, String>
            applyJobVC.newStr = tempDic["project_id"]!
            applyJobVC.titleStr = tempDic["project_title"]!
        case 2:
            let tempDic = _appliedJobsArray[buttonIndex] as! Dictionary<String, String>
            applyJobVC.newStr = tempDic["project_id"]!
            applyJobVC.titleStr = tempDic["project_title"]!
        default:
            break;
        }
        self.navigationController?.pushViewController(applyJobVC, animated: true)
    }
    
    func clickOnButton(button: UIButton) {
        let introVC = self.storyboard?.instantiateViewControllerWithIdentifier("introVC")
        self.navigationController?.pushViewController(introVC!, animated: true)
    }
    
    //MARK: - UISegment Control 
    
    @IBAction func segmentIndexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            NSLog("Important Jobs selected")
            self.saveJobTableView.reloadData()
        case 1:
            NSLog("Saved Jobss selected")
            self.saveJobTableView.reloadData()
        case 2:
            NSLog("Applied Jobs selected")
            self.saveJobTableView.reloadData()
        default:
            break;
        }
    }
    
    //MARK:- UITableView Delegates/DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            return _interestedJobsArray.count
        case 1:
            return _savedJobsArray.count
        case 2:
            return _appliedJobsArray.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("saveJob", forIndexPath: indexPath) as? JobCustomTableViewCell
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            let tempDic = _interestedJobsArray[indexPath.row]
            let projectTitle  = tempDic.valueForKey("project_title")!.description
            cell!._titleLabel!.text = projectTitle
            cell?._applyJob.hidden = false
        case 1:
            let tempDic = _savedJobsArray[indexPath.row]
            let projectTitle  = tempDic.valueForKey("project_title")!.description
            cell!._titleLabel!.text = projectTitle
            cell?._applyJob.hidden = false
        case 2:
            let tempDic = _appliedJobsArray[indexPath.row]
            let projectTitle  = tempDic.valueForKey("project_title")!.description
            cell!._titleLabel!.text = projectTitle
            cell?._applyJob.hidden = true
        default:
            break;
        }
        cell!._applyJob.tag = indexPath.row
        
        return cell!
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    // Mark :- API calls
    
    func getInterestedJob() {
        if (isConnectedToNetwork()==true) {
            do {
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                if (expertId.isEmpty == false) {
                    let urlString = "expert/jobs/" + expertId + "/interested"
                    SVProgressHUD.showWithStatus("Loading...")
                    API.getRequest(urlString, jsonData:(nil), isLogin: true, delegate: self)
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    func getSaveJob() {
        if (isConnectedToNetwork()==true) {
            do {
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                if (expertId.isEmpty == false) {
                    let urlString = "expert/jobs/" + expertId + "/saved"
                    SVProgressHUD.showWithStatus("Loading...")
                    API.getRequest(urlString, jsonData:(nil), isLogin: true, delegate: self)
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
            }
    }
    
    func getAppliedJob() {
        if (isConnectedToNetwork()==true) {
            do {
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                if (expertId.isEmpty == false) {
                    let urlString = "expert/jobs/" + expertId + "/applied"
                    SVProgressHUD.showWithStatus("Loading...")
                    API.getRequest(urlString, jsonData:(nil), isLogin: true, delegate: self)
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    //MARK: - API Response Handling
    
    func apiSuccessResponseWithURL(json: JSON, urlString : String) {
        SVProgressHUD.dismiss()
        if urlString.containsString("interested") {
            let statusString = json["status"].stringValue
            if (statusString == "200") {
                let applications: Array<JSON> = json["Jobs"].arrayValue
                self._interestedJobsArray.removeAllObjects()
                for project in applications {
                    var tempDic = [String: AnyObject]()
                    tempDic["project_id"] = project["project_id"].stringValue
                    tempDic["project_title"] = project["project_title"].stringValue
                    [self._interestedJobsArray.addObject(tempDic)];
                }
                self.saveJobTableView.reloadData()
            }
        }
        else if urlString.containsString("saved") {
            let statusString = json["status"].stringValue
            if (statusString == "200") {
                let applications: Array<JSON> = json["Jobs"].arrayValue
                self._savedJobsArray.removeAllObjects()
                for project in applications {
                    var tempDic = [String: AnyObject]()
                    tempDic["project_id"] = project["project_id"].stringValue
                    tempDic["project_title"] = project["project_title"].stringValue
                    [self._savedJobsArray.addObject(tempDic)];
                }
                self.saveJobTableView.reloadData()
            }
        }
        else {
            let statusString = json["status"].stringValue
            if (statusString == "200") {
                let applications: Array<JSON> = json["Jobs"].arrayValue
                self._appliedJobsArray.removeAllObjects()
                for project in applications {
                    var tempDic = [String: AnyObject]()
                    tempDic["project_id"] = project["project_id"].stringValue
                    tempDic["project_title"] = project["project_title"].stringValue
                    [self._appliedJobsArray.addObject(tempDic)];
                }
                self.saveJobTableView.reloadData()
            }
        }
    }
    
    func apiFailureResponseWithURL(errorDesc: String, urlString: String) {
        SVProgressHUD.dismiss()
        print("Failed \(errorDesc)")
    }
}
