//
//  MPGTextField.swift
//  MPGTextField
//
//  Created by Gaurav Wadhwani on 08/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

import UIKit

@objc protocol MPGTextFieldDelegate {
    func dataForPopoverInTextField(textfield: MPGTextField) -> [Dictionary<String, AnyObject>]
    
    optional func textFieldDidEndEditing(textField: MPGTextField, withSelection data: Dictionary<String,AnyObject>)
    optional func textFieldShouldSelect(textField: MPGTextField) -> Bool
}

    private var tableViewController : UITableViewController?
    private var data = [Dictionary<String, AnyObject>]()
    private var filteredData = [Dictionary<String, AnyObject>]()


class MPGTextField: UITextField, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    //Set this to override the default color of suggestions popover. The default color is [UIColor colorWithWhite:0.8 alpha:0.9]
    @IBInspectable var popoverBackgroundColor : UIColor = UIColor(white: 0.75, alpha: 1.0)
    
    //Set this to override the default frame of the suggestions popover that will contain the suggestions pertaining to the search query. The default frame will be of the same width as textfield, of height 200px and be just below the textfield.
    @IBInspectable var popoverSize : CGRect?
    
    //Set this to override the default seperator color for tableView in search results. The default color is light gray.
    @IBInspectable var seperatorColor : UIColor = UIColor(white: 0.95, alpha: 1.0)
    
    var mDelegate : MPGTextFieldDelegate?
    var index = Int()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        let str : String = self.text!
        
        if (str.characters.count > 0) && (self.isFirstResponder()) {
            if (mDelegate != nil) {
                data = mDelegate!.dataForPopoverInTextField(self)
                self.provideSuggestions()
            } else {
                print("<MPGTextField> WARNING: You have not implemented the requred methods of the MPGTextField protocol.")
            }
        } else {
            if let table = tableViewController {
                if table.tableView.superview != nil{
                    table.tableView.removeFromSuperview()
                    tableViewController = nil
                }
            }
        }
    }
    
    override func resignFirstResponder() -> Bool {
        if tableViewController != nil {
            UIView.animateWithDuration(0.3,
                                       animations: ({
                                        tableViewController!.tableView.alpha = 0.0
                                       }),
                                       completion:{
                                        (finished : Bool) in
                                        tableViewController!.tableView.removeFromSuperview()
                                        tableViewController = nil
            })
            self.handleExit()
        }
        
        return super.resignFirstResponder()
    }
    
    func provideSuggestions() {
        self.applyFilterWithSearchQuery(self.text!)
        if let _ = tableViewController {
            tableViewController!.tableView.reloadData()
        } else if filteredData.count > 0 {
            //Add a tap gesture recogniser to dismiss the suggestions view when the user taps outside the suggestions view
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MPGTextField.tapped(_:)))
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.cancelsTouchesInView = false
            tapRecognizer.delegate = self
            self.superview!.addGestureRecognizer(tapRecognizer)
            
            tableViewController = UITableViewController()
            tableViewController!.tableView.delegate = self
            tableViewController!.tableView.dataSource = self
            tableViewController!.tableView.backgroundColor = self.popoverBackgroundColor
            tableViewController!.tableView.separatorColor = self.seperatorColor
            if let frameSize = self.popoverSize {
                tableViewController!.tableView.frame = frameSize
            } else {
                //PopoverSize frame has not been set. Use default parameters instead.
                var frameForPresentation = self.frame
                frameForPresentation.origin.y += self.frame.size.height
                frameForPresentation.size.height = 200
                tableViewController!.tableView.frame = frameForPresentation
            }
            
            var frameForPresentation = self.frame
            frameForPresentation.origin.y += self.frame.size.height;
            frameForPresentation.size.height = 200;
            tableViewController!.tableView.frame = frameForPresentation
            
            self.superview!.addSubview(tableViewController!.tableView)
            tableViewController!.tableView.alpha = 0.0
            UIView.animateWithDuration(0.3,
                                       animations: ({
                                        tableViewController!.tableView.alpha = 1.0
                                       }),
                                       completion:{
                                        (finished : Bool) in
                                        
            })
        }
        
    }
    
    func tapped (sender : UIGestureRecognizer!) {
        if let table = tableViewController {
            if !CGRectContainsPoint(table.tableView.frame, sender.locationInView(self.superview)) && self.isFirstResponder() {
                self.resignFirstResponder()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredData.count
        if count == 0 {
            UIView.animateWithDuration(0.3,
                                       animations: ({
                                        tableViewController!.tableView.alpha = 0.0
                                       }),
                                       completion: {
                                        (finished : Bool) in
                                        if let table = tableViewController {
                                            table.tableView.removeFromSuperview()
                                            tableViewController = nil
                                        }
            })
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MPGResultsCell") as UITableViewCell!
        
        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MPGResultsCell")
        }
        
        // Customize separator width
        tableView.separatorInset = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        // Customize cells
        cell.backgroundColor = UIColor.clearColor()
        let dataForRowAtIndexPath = filteredData[indexPath.row]
        let displayText : AnyObject? = dataForRowAtIndexPath["DisplayText"]
        cell.textLabel!.text = displayText as? String
        cell.textLabel!.font = cell!.textLabel?.font.fontWithSize(15)
        cell.textLabel?.textColor = UIColor.whiteColor()
        //let displaySubText : AnyObject? = dataForRowAtIndexPath["DisplaySubText"]
        //cell.detailTextLabel!.text = displaySubText as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // self.text = filteredData[indexPath.row]["DisplayText"] as? String
        self.index = indexPath.row
        self.resignFirstResponder()
    }
    
    
    // Mark: Filter Method
    
    func applyFilterWithSearchQuery(filter : String) -> Void {
        let matchingData = data.filter( {
            if let match : AnyObject  = $0["DisplayText"] {
                //println("LCS = \(filter.lowercaseString)")
                return (match as! NSString).lowercaseString.hasPrefix((filter as NSString).lowercaseString)
            } else {
                return false
            }
        })
        
        filteredData = matchingData
    }
    
    func handleExit() {
        if let table = tableViewController {
            table.tableView.removeFromSuperview()
        }
        if ((mDelegate?.textFieldShouldSelect?(self)) != nil) {
            if filteredData.count > 0 {
                
                let selectedData = filteredData[self.index]
                let displayText : AnyObject? = selectedData["DisplayText"]
                self.text = displayText as? String
                mDelegate?.textFieldDidEndEditing?(self, withSelection: selectedData)
            } else {
                mDelegate?.textFieldDidEndEditing?(self, withSelection: ["DisplayText":self.text!, "CustomObject":"NEW"])
            }
        }
        
    }
    
}
