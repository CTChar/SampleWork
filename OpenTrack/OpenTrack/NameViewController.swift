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
        
        let defaults = UserDefaults.standard
        if let first = defaults.object(forKey: "first") as? String,
            let last = defaults.object(forKey: "last") as? String {
            
            if first != "" {
                firstName.text = first
            }
            
            if last != "" {
                lastName.text = last
            }
        }
    }

    @IBAction func warningHit(_ sender: AnyObject) {
        disclaimer.isHidden = !disclaimer.isHidden
        view.endEditing(true)
    }
    
    @IBAction func continueHit(_ sender: AnyObject) {
        if let first = firstName.text,
            let last = lastName.text {
            let defaults = UserDefaults.standard
            defaults.set(first, forKey: "first")
            defaults.set(last, forKey: "last")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextView = segue.destination as? TrackingViewController else {
            fatalError("This isn't a tracking view controller, and you're not a nice person.")
        }
        
        if let first = firstName.text,
            let last = lastName.text {
            nextView.firstName = first
            nextView.lastName = last
        } else {
            fatalError("How did you even perform a segue without these?")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if firstName.text != "" && lastName.text != "" {
            return true
        } else {
            return false
        }
    }

}

