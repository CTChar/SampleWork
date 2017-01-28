//
//  ViewController.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {

    @IBOutlet var continueButton: UIButton!
    @IBOutlet var disclaimer: UITextView!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let first = defaults.objectForKey("first") as? String,
            last = defaults.objectForKey("last") as? String {
            
            if first != "" {
                firstName.text = first
            }
            
            if last != "" {
                lastName.text = last
            }
        }
    }

    @IBAction func warningHit(sender: AnyObject) {
        disclaimer.hidden = !disclaimer.hidden
        view.endEditing(true)
    }
    
    @IBAction func continueHit(sender: AnyObject) {
        if let first = firstName.text,
            last = lastName.text {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(first, forKey: "first")
            defaults.setObject(last, forKey: "last")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let nextView = segue.destinationViewController as? TrackingViewController else {
            fatalError("This isn't a tracking view controller, and you're not a nice person.")
        }
        
        if let first = firstName.text,
            last = lastName.text {
            nextView.firstName = first
            nextView.lastName = last
        } else {
            fatalError("How did you even perform a segue without these?")
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if firstName.text != "" && lastName.text != "" {
            return true
        } else {
            return false
        }
    }

}

