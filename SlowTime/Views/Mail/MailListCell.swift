//
//  MailListCell.swift
//  SlowTime
//
//  Created by KKING on 2018/1/3.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit

class MailListCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var createTimeLbl: UILabel!
    @IBOutlet weak var youchuoImg: UIImageView!
    
    var listMail: ListMail? {
        didSet {
            titleLbl.text = listMail?.abstract
            
            youchuoImg.isHidden = !(listMail?.isRead)! && listMail?.emailType == 1 ? false : true
            
            switch listMail?.emailType {
            case 1?:
                createTimeLbl.text = (listMail?.updateTime)! + " 收"
            case 2?:
                createTimeLbl.text = (listMail?.updateTime)! + " 寄"
            default:
                createTimeLbl.text = (listMail?.updateTime)! + " 草稿"
            }
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
