//
//  CommentTableViewCell.swift
//  OpenTrack
//
//  Created by Cole Herzog on 9/28/16.
//  Copyright © 2016 Spensa. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet var comments: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        comments.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
        comments.layer.borderWidth = 1
    }
    
}
