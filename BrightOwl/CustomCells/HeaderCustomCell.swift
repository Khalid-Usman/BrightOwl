//
//  HeaderCustomCell.swift
//  BrightOwl
//
//  Created by KhalidUsman on 3/24/16.
//  Copyright © 2016 KhalidUsman. All rights reserved.
//

import UIKit

class HeaderCustomCell: UITableViewCell {
    
    @IBOutlet weak var _sectionImage: UIImageView!
    @IBOutlet weak var _sectionTitle: UILabel!
    @IBOutlet weak var _sectionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
