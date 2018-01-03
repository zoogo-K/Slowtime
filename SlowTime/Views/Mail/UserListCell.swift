//
//  MailListCell.swift
//  SlowTime
//
//  Created by KKING on 2018/1/3.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var youchuoImg: UIImageView!
    
    var friend: Friend? {
        didSet {
            titleLbl.text = friend?.nickname
            youchuoImg.isHidden = (friend?.hasNewMail)! ? false : true
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
