//
//  TextCell.swift
//  SlowTime
//
//  Created by KKING on 2018/1/22.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

    @IBOutlet weak var contentTextView: UITextView!
    
    
    var tt: String? {
        didSet {
            contentTextView.text = tt
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
