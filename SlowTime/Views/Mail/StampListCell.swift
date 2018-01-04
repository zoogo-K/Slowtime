//
//  StampListCell.swift
//  SlowTime
//
//  Created by KKING on 2018/1/4.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class StampListCell: UICollectionViewCell {
    
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var countBottomLbl: UILabel!

    @IBOutlet weak var iconBtn: UIButton!
    
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    
    var stampCount = Variable(0)
    
    let disposeBag = DisposeBag()

    
    var stamp: Stamp? {
        didSet {
            iconBtn.kf.setBackgroundImage(with: ImageResource(downloadURL: URL(string: (stamp?.icon)!) ?? URL(string: "")!), for: .normal, placeholder: RI.add_stamp())
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        stampCount.asObservable()
            .subscribe(onNext: { [unowned self](num) in
                self.countBottomLbl.isHidden = num <= 0
                self.cutBtn.isHidden = num <= 0
                self.addBtn.isHidden = num <= 0
                self.countLbl.isHidden = num <= 0
            })
            .disposed(by: disposeBag)
        

        iconBtn.rx.tap
            .bind { [unowned self] in
                self.changeStampCount(isAdd: true)
            }
            .disposed(by: disposeBag)
        
        addBtn.rx.tap
            .bind { [unowned self] in
                self.changeStampCount(isAdd: true)
            }
            .disposed(by: disposeBag)
        
        cutBtn.rx.tap
            .bind { [unowned self] in
                self.changeStampCount(isAdd: false)
            }
            .disposed(by: disposeBag)
    }
    
    
    @objc private func changeStampCount(isAdd: Bool) {        
        countLbl.text = isAdd ? "\(stampCount.value + 1)" : "\(stampCount.value - 1)"
        countBottomLbl.text = countLbl.text
        stampCount.value = Int(countLbl.text!)!
        contentView.layoutSubviews()
    }
    
    
}
