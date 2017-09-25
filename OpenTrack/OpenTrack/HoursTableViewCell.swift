//
//  HoursTableViewCell.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import UIKit

class HoursTableViewCell: UITableViewCell {

    @IBOutlet var hoursField: UITextField!
    var hours: Int {
        get {
            if let text = hoursField.text,
                let hours = Int(text) {
                return hours
            } else {
                return 40
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hoursField.keyboardType = .numberPad
    }
    
}
