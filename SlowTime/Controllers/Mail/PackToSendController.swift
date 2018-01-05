//
//  PackToSendController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya
import RxSwift

class PackToSendController: UIViewController {
    
    @IBOutlet weak var mailImage: UIImageView!
    @IBOutlet weak var enevlopeTopImg: UIImageView! {
        didSet {
            enevlopeTopImg.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        }
    }
    @IBOutlet weak var enevlopeBottomImg: UIImageView!

    @IBOutlet weak var enevlopBTopCons: NSLayoutConstraint!
    private var stamps: [Stamp]?
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var stampCollectionView: UICollectionView!
    
    @IBAction func disAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.userStamp)
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .flatMap(to: Stamp.self)
            .subscribe { [weak self] (event) in
                if case .next(let stamps) = event {
                    self?.stamps = stamps
                    DispatchQueue.main.async {
                        self?.stampCollectionView.reloadData()
                    }
                }else if case .error = event {
                    DLog("请求超时")
                }
            }
            .disposed(by: disposeBag)
    
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.enevlopeTopImg.layer.transform = CATransform3DMakeRotation(CGFloat.pi/2, 1, 0, 0)
        }){(finished) in
            self.enevlopeTopImg.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.enevlopBTopCons.constant = 190
                self.view.layoutIfNeeded()
            })
        }
    }
}

extension PackToSendController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stamps?.count ?? 0 + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stampCell", for: indexPath) as! MyStampCell
        if indexPath.row < stamps?.count ?? 0 {
            cell.stamp = stamps?[indexPath.row]
        }else {
            cell.iconImg.image = RI.add_stamp()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        present(R.storyboard.mail().instantiateViewController(withIdentifier: "StampListController"), animated: true, completion: nil)
    }
    
    
}
