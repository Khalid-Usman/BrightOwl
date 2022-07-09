//
//  JobCustomTableViewCell.swift
//  BrightOwl
//
//  Created by KhalidUsman on 3/14/16.
//  Copyright © 2016 KhalidUsman. All rights reserved.
//

import UIKit

class JobCustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var _titleLabel: UILabel!
     @IBOutlet weak var _applyJob: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         self._applyJob.layer.cornerRadius = 2.0;
    }
}
