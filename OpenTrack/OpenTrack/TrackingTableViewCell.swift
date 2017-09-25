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
                time.isUserInteractionEnabled = false
                time.textColor = UIColor.gray
                remove.isHidden = true
            } else {
                time.isUserInteractionEnabled = true
                time.textColor = UIColor.black
                remove.isHidden = false
            }
            
            delegate?.didChangeProjectReportForProject(self, projectReport: projectReport)
        }
    }
    
    @IBOutlet var remove: UIButton!
    @IBOutlet var time: UITextField!
    @IBOutlet var project: UILabel!
    
    override func awakeFromNib() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(textFieldTextChanged(_:)),
            name:NSNotification.Name.UITextFieldTextDidChange,
            object: nil
        )
        
        time.delegate = self
        time.keyboardType = .numberPad
        super.awakeFromNib()
    }
    
    @IBAction func removeHit(_ sender: AnyObject) {
        delegate?.didRemoveProjectReport(self)
    }
    
    func textFieldTextChanged(_ sender : AnyObject) {
        let plainText: String? = time.text
        
        if let text: String = plainText,
            let numberValue: Int = Int(text) {
            projectReport.time = numberValue
        } else {
            time.text = "0"
            projectReport.time = 0
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let plainText: String? = time.text
        
        if let text: String = plainText,
            let numberValue: Int = Int(text) {
            if numberValue == 0 {
                time.text = ""
            }
        }
    }
    
}

protocol TrackingCellDelegate: class {
    func didChangeProjectReportForProject(_ trackingCell: TrackingTableViewCell, projectReport: ProjectReport)
    func didRemoveProjectReport(_ trackingCell: TrackingTableViewCell)
}
