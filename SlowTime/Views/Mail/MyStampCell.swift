//
//  MyStampCell.swift
//  SlowTime
//
//  Created by KKING on 2018/1/4.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit
import Kingfisher

class MyStampCell: UICollectionViewCell {
    
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    
    var stamp: Stamp? {
        didSet {
            countLbl.text = "\(stamp?.count ?? 1)"
            iconImg.kf.setImage(with: ImageResource(downloadURL: URL(string: (stamp?.icon)!) ?? URL(string: "")!), placeholder: RI.add_stamp())
        }
    }
}
