//
//  TrackingTableViewCell.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import UIKit

class TrackingTableViewCell: UITableViewCell, UITextFieldDelegate {

    var delegate: TrackingCellDelegate?
    var projectReport: ProjectReport = ProjectReport(time: 0, project: .Blank) {
        didSet {
            time.text = "\(projectReport.time)"
            project.text = projectReport.project.rawValue
            
            if projectReport.project == .Blank {
                time.userInteractionEnabled = false
                time.textColor = UIColor.grayColor()
                remove.hidden = true
            } else {
                time.userInteractionEnabled = true
                time.textColor = UIColor.blackColor()
                remove.hidden = false
            }
            
            delegate?.didChangeProjectReportForProject(self, projectReport: projectReport)
        }
    }
    
    @IBOutlet var remove: UIButton!
    @IBOutlet var time: UITextField!
    @IBOutlet var project: UILabel!
    
    override func awakeFromNib() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self,
            selector: #selector(textFieldTextChanged(_:)),
            name:UITextFieldTextDidChangeNotification,
            object: nil
        )
        
        time.delegate = self
        time.keyboardType = .NumberPad
        super.awakeFromNib()
    }
    
    @IBAction func removeHit(sender: AnyObject) {
        delegate?.didRemoveProjectReport(self)
    }
    
    func textFieldTextChanged(sender : AnyObject) {
        let plainText: String? = time.text
        
        if let text: String = plainText,
            numberValue: Int = Int(text) {
            projectReport.time = numberValue
        } else {
            time.text = "0"
            projectReport.time = 0
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let plainText: String? = time.text
        
        if let text: String = plainText,
            numberValue: Int = Int(text) {
            if numberValue == 0 {
                time.text = ""
            }
        }
    }
    
}

protocol TrackingCellDelegate: class {
    func didChangeProjectReportForProject(trackingCell: TrackingTableViewCell, projectReport: ProjectReport)
    func didRemoveProjectReport(trackingCell: TrackingTableViewCell)
}
